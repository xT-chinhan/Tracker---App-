import { BadRequestException, Body, ConflictException, Controller, Delete, Get, HttpCode, Injectable, Module, NotFoundException, Param, ParseUUIDPipe, Patch, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags, IntersectionType } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsDateString, IsInt, IsOptional, IsString, IsUUID, Max, MaxLength, Min } from 'class-validator';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser } from '../common/auth';
import { MAX_AMOUNT, PageQuery, paged, RangeQuery } from '../common/dto';
import { parseDate, resolveRange } from '../common/time';
import { Db, lockUser, WalletsModule, WalletsService } from '../wallets/wallets.module';

class CreateTransferDto {
  @IsUUID() fromWalletId: string;
  @IsUUID() toWalletId: string;
  @Type(() => Number) @IsInt() @Min(1) @Max(MAX_AMOUNT) amount: number;
  /** ISO 8601, mặc định hiện tại */
  @IsOptional() @IsDateString() occurredAt?: string;
  @IsOptional() @IsString() @MaxLength(500) note?: string;
}

class UpdateTransferDto {
  @IsOptional() @IsUUID() fromWalletId?: string;
  @IsOptional() @IsUUID() toWalletId?: string;
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(MAX_AMOUNT) amount?: number;
  @IsOptional() @IsDateString() occurredAt?: string;
  @IsOptional() @IsString() @MaxLength(500) note?: string;
}

class TransferFilter extends IntersectionType(PageQuery, RangeQuery) {
  /** Lọc chuyển tiền có liên quan tới ví (vào hoặc ra) */
  @IsOptional() @IsUUID() walletId?: string;
}

const WALLET = { select: { id: true, name: true, type: true, icon: true, color: true } } as const;
const INCLUDE = { fromWallet: WALLET, toWallet: WALLET } as const;

/** Chuyển tiền giữa các ví của user. Không tính vào thu/chi, thống kê, ngân sách. */
@Injectable()
export class TransfersService {
  constructor(private readonly prisma: PrismaService, private readonly wallets: WalletsService) {}

  async list(userId: string, f: TransferFilter) {
    const range = resolveRange(f);
    const where: Prisma.TransferWhereInput = {
      userId,
      occurredAt: range.gte || range.lt ? range : undefined,
      OR: f.walletId ? [{ fromWalletId: f.walletId }, { toWalletId: f.walletId }] : undefined,
    };
    const [items, total] = await this.prisma.$transaction([
      this.prisma.transfer.findMany({
        where,
        include: INCLUDE,
        orderBy: [{ occurredAt: 'desc' }, { createdAt: 'desc' }],
        skip: (f.page - 1) * f.limit,
        take: f.limit,
      }),
      this.prisma.transfer.count({ where }),
    ]);
    return paged(items, total, f);
  }

  async get(userId: string, id: string) {
    const t = await this.prisma.transfer.findFirst({ where: { id, userId }, include: INCLUDE });
    if (!t) throw new NotFoundException('Không tìm thấy giao dịch chuyển tiền');
    return t;
  }

  async create(userId: string, dto: CreateTransferDto) {
    return this.prisma.$transaction(async (db) => {
      await lockUser(db, userId);
      await this.validate(db, userId, dto.fromWalletId, dto.toWalletId);
      await this.assertNoOverdraft(db, userId, null, { from: dto.fromWalletId, to: dto.toWalletId, amount: dto.amount });
      return db.transfer.create({
        data: {
          userId,
          fromWalletId: dto.fromWalletId,
          toWalletId: dto.toWalletId,
          amount: BigInt(dto.amount),
          note: dto.note?.trim() || null,
          occurredAt: dto.occurredAt ? parseDate(dto.occurredAt) : new Date(),
        },
        include: INCLUDE,
      });
    });
  }

  async update(userId: string, id: string, dto: UpdateTransferDto) {
    return this.prisma.$transaction(async (db) => {
      await lockUser(db, userId);
      const cur = await db.transfer.findFirst({ where: { id, userId } });
      if (!cur) throw new NotFoundException('Không tìm thấy giao dịch chuyển tiền');
      const from = dto.fromWalletId ?? cur.fromWalletId;
      const to = dto.toWalletId ?? cur.toWalletId;
      const amount = dto.amount ?? Number(cur.amount);
      await this.assertNotArchived(db, userId, [cur.fromWalletId, cur.toWalletId]);
      await this.validate(db, userId, from, to);
      await this.assertNoOverdraft(db, userId, cur, { from, to, amount });
      return db.transfer.update({
        where: { id },
        data: {
          fromWalletId: from,
          toWalletId: to,
          amount: BigInt(amount),
          note: dto.note !== undefined ? dto.note.trim() || null : undefined,
          occurredAt: dto.occurredAt ? parseDate(dto.occurredAt) : undefined,
        },
        include: INCLUDE,
      });
    });
  }

  /** Xóa = trả tiền về ví nguồn => ví đích phải còn đủ số tiền đã nhận. */
  async remove(userId: string, id: string) {
    await this.prisma.$transaction(async (db) => {
      await lockUser(db, userId);
      const cur = await db.transfer.findFirst({ where: { id, userId } });
      if (!cur) throw new NotFoundException('Không tìm thấy giao dịch chuyển tiền');
      await this.assertNotArchived(db, userId, [cur.fromWalletId, cur.toWalletId]);
      await this.assertNoOverdraft(db, userId, cur, null);
      await db.transfer.delete({ where: { id } });
    });
  }

  private async validate(db: Db, userId: string, from: string, to: string) {
    if (from === to) throw new BadRequestException('Ví nguồn và ví đích phải khác nhau');
    await this.wallets.usable(userId, from, db);
    await this.wallets.usable(userId, to, db);
  }

  /**
   * Tạo / sửa / xóa chuyển tiền không được làm ví nào bị trừ tiền xuống dưới 0:
   * hoàn tác giao dịch cũ (`cur`) rồi áp giao dịch mới (`next`), ví có thay đổi âm phải còn đủ.
   * Vd xóa A→B khi B đã chuyển tiếp số tiền đó đi => B không đủ để hoàn lại => 400.
   */
  private async assertNoOverdraft(
    db: Db,
    userId: string,
    cur: { fromWalletId: string; toWalletId: string; amount: bigint } | null,
    next: { from: string; to: string; amount: number } | null,
  ) {
    const delta = new Map<string, number>();
    const add = (id: string, v: number) => delta.set(id, (delta.get(id) ?? 0) + v);
    if (cur) { add(cur.fromWalletId, Number(cur.amount)); add(cur.toWalletId, -Number(cur.amount)); }
    if (next) { add(next.from, -next.amount); add(next.to, next.amount); }
    const balances = await this.wallets.balances(userId, db);
    for (const [walletId, d] of delta) {
      const balance = balances.get(walletId) ?? 0;
      if (d >= 0 || balance + d >= 0) continue;
      const w = await db.wallet.findUniqueOrThrow({ where: { id: walletId }, select: { name: true } });
      // "còn" = số dư khả dụng cho thao tác này (đã hoàn tác phần của chính giao dịch cũ)
      const available = balance + d + (next && next.from === walletId ? next.amount : 0);
      throw new BadRequestException(`Số dư ví "${w.name}" không đủ (còn ${available})`);
    }
  }

  /** Không sửa/xóa phát sinh của ví đã lưu trữ (giữ số dư ví lưu trữ = 0). */
  private async assertNotArchived(db: Db, userId: string, ids: string[]) {
    const archived = await db.wallet.findFirst({ where: { userId, id: { in: ids }, isArchived: true } });
    if (archived) throw new ConflictException(`Ví "${archived.name}" đã lưu trữ, hãy khôi phục trước`);
  }
}

@ApiTags('transfers')
@ApiBearerAuth()
@Controller('transfers')
export class TransfersController {
  constructor(private readonly transfers: TransfersService) {}

  @Get()
  list(@CurrentUser() u: AuthUser, @Query() f: TransferFilter) {
    return this.transfers.list(u.id, f);
  }

  @Get(':id')
  get(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.transfers.get(u.id, id);
  }

  @Post()
  create(@CurrentUser() u: AuthUser, @Body() dto: CreateTransferDto) {
    return this.transfers.create(u.id, dto);
  }

  @Patch(':id')
  update(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateTransferDto) {
    return this.transfers.update(u.id, id, dto);
  }

  @Delete(':id') @HttpCode(204)
  remove(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.transfers.remove(u.id, id);
  }
}

@Module({ imports: [WalletsModule], controllers: [TransfersController], providers: [TransfersService] })
export class TransfersModule {}
