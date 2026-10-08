import { BadRequestException, Body, ConflictException, Controller, Delete, Get, HttpCode, Injectable, Module, NotFoundException, Param, ParseUUIDPipe, Patch, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsEnum, IsHexColor, IsInt, IsOptional, IsString, Max, MaxLength, Min, MinLength } from 'class-validator';
import { Prisma, Wallet, WalletType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser } from '../common/auth';
import { MAX_AMOUNT, Trim } from '../common/dto';

class CreateWalletDto {
  @Trim() @IsString() @MinLength(1) @MaxLength(50) name: string;
  @IsEnum(WalletType) type: WalletType;
  /** Số dư ban đầu (>= 0), mặc định 0 */
  @IsOptional() @Type(() => Number) @IsInt() @Min(0) @Max(MAX_AMOUNT) initialBalance?: number;
  @IsOptional() @IsString() @MaxLength(50) icon?: string;
  @IsOptional() @IsHexColor() color?: string;
}

class UpdateWalletDto {
  @IsOptional() @Trim() @IsString() @MinLength(1) @MaxLength(50) name?: string;
  @IsOptional() @IsEnum(WalletType) type?: WalletType;
  @IsOptional() @Type(() => Number) @IsInt() @Min(0) @Max(MAX_AMOUNT) initialBalance?: number;
  @IsOptional() @IsString() @MaxLength(50) icon?: string;
  @IsOptional() @IsHexColor() color?: string;
}

/** Client Prisma thường hoặc client trong $transaction (để tính số dư sau khi đã khóa). */
export type Db = Prisma.TransactionClient;

/** Khóa theo user để các thao tác rút tiền khỏi ví chạy tuần tự, không cùng vượt qua kiểm tra số dư. */
export async function lockUser(db: Db, userId: string) {
  await db.$queryRaw`SELECT 1 FROM "User" WHERE id = ${userId} FOR UPDATE`;
}

const n = (v: bigint | number | null | undefined) => Number(v ?? 0);
const add = (m: Map<string, number>, k: string, v: number) => m.set(k, (m.get(k) ?? 0) + v);

/**
 * Số dư ví = ban đầu + thu − chi + chuyển vào − chuyển ra − nạp tiết kiệm + rút tiết kiệm.
 * Luôn tính từ dữ liệu, không lưu cộng dồn.
 */
@Injectable()
export class WalletsService {
  constructor(private readonly prisma: PrismaService) {}

  async balances(userId: string, db: Db = this.prisma): Promise<Map<string, number>> {
    const [wallets, tx, out, inc, entries] = await Promise.all([
      db.wallet.findMany({ where: { userId }, select: { id: true, initialBalance: true } }),
      db.transaction.groupBy({ by: ['walletId', 'type'], where: { userId }, _sum: { amount: true } }),
      db.transfer.groupBy({ by: ['fromWalletId'], where: { userId }, _sum: { amount: true } }),
      db.transfer.groupBy({ by: ['toWalletId'], where: { userId }, _sum: { amount: true } }),
      db.savingEntry.groupBy({ by: ['walletId', 'type'], where: { userId }, _sum: { amount: true } }),
    ]);
    const m = new Map(wallets.map((w) => [w.id, n(w.initialBalance)]));
    for (const r of tx) add(m, r.walletId, r.type === 'INCOME' ? n(r._sum.amount) : -n(r._sum.amount));
    for (const r of out) add(m, r.fromWalletId, -n(r._sum.amount));
    for (const r of inc) add(m, r.toWalletId, n(r._sum.amount));
    for (const r of entries) add(m, r.walletId, r.type === 'DEPOSIT' ? -n(r._sum.amount) : n(r._sum.amount));
    return m;
  }

  async list(userId: string) {
    const [wallets, bal] = await Promise.all([
      this.prisma.wallet.findMany({ where: { userId }, orderBy: [{ isArchived: 'asc' }, { createdAt: 'asc' }] }),
      this.balances(userId),
    ]);
    const items = wallets.map((w) => withBalance(w, bal.get(w.id) ?? 0));
    return { totalBalance: items.reduce((s, w) => s + w.balance, 0), items };
  }

  async get(userId: string, id: string) {
    const w = await this.findOwned(userId, id);
    return withBalance(w, (await this.balances(userId)).get(id) ?? 0);
  }

  async create(userId: string, dto: CreateWalletDto) {
    await this.assertNameFree(userId, dto.name);
    const w = await this.prisma.wallet.create({
      data: { userId, name: dto.name, type: dto.type, initialBalance: BigInt(dto.initialBalance ?? 0), icon: dto.icon, color: dto.color },
    });
    return withBalance(w, n(w.initialBalance));
  }

  async update(userId: string, id: string, dto: UpdateWalletDto) {
    const w = await this.findOwned(userId, id);
    if (dto.name && dto.name !== w.name) await this.assertNameFree(userId, dto.name, id);
    // Ví lưu trữ phải giữ số dư = 0
    if (w.isArchived && dto.initialBalance !== undefined && BigInt(dto.initialBalance) !== w.initialBalance) {
      throw new ConflictException(`Ví "${w.name}" đã lưu trữ, hãy khôi phục trước khi đổi số dư ban đầu`);
    }
    await this.prisma.wallet.update({
      where: { id },
      data: {
        name: dto.name,
        type: dto.type,
        initialBalance: dto.initialBalance !== undefined ? BigInt(dto.initialBalance) : undefined,
        icon: dto.icon,
        color: dto.color,
      },
    });
    return this.get(userId, id);
  }

  /** Chưa phát sinh (giao dịch, chuyển tiền, tiết kiệm, định kỳ) => xóa hẳn, mẫu nhập nhanh dùng ví bị xóa theo. Có phát sinh => chỉ lưu trữ khi số dư = 0. */
  /** Khóa theo user => chuyển tiền / nạp tiết kiệm đồng thời không lọt vào ví vừa lưu trữ với số dư 0. */
  async remove(userId: string, id: string) {
    await this.findOwned(userId, id);
    return this.prisma.$transaction(async (db) => {
      await lockUser(db, userId);
      const [tx, tr, se, rr] = await Promise.all([
        db.transaction.count({ where: { walletId: id } }),
        db.transfer.count({ where: { OR: [{ fromWalletId: id }, { toWalletId: id }] } }),
        db.savingEntry.count({ where: { walletId: id } }),
        db.recurringRule.count({ where: { walletId: id } }),
      ]);
      if (tx + tr + se + rr === 0) {
        await db.wallet.delete({ where: { id } });
        return { archived: false };
      }
      const balance = (await this.balances(userId, db)).get(id) ?? 0;
      if (balance !== 0) throw new ConflictException('Ví còn số dư, hãy chuyển hết tiền sang ví khác trước khi lưu trữ');
      await db.wallet.update({ where: { id }, data: { isArchived: true } });
      return { archived: true };
    });
  }

  async restore(userId: string, id: string) {
    const w = await this.findOwned(userId, id);
    await this.assertNameFree(userId, w.name, id);
    await this.prisma.wallet.update({ where: { id }, data: { isArchived: false } });
    return this.get(userId, id);
  }

  /** Ví dùng được cho phát sinh mới: thuộc user và chưa lưu trữ. */
  async usable(userId: string, id: string, db: Db = this.prisma) {
    const w = await db.wallet.findFirst({ where: { id, userId } });
    if (!w) throw new BadRequestException('Ví không tồn tại');
    if (w.isArchived) throw new ConflictException(`Ví "${w.name}" đã lưu trữ`);
    return w;
  }

  async findOwned(userId: string, id: string) {
    const w = await this.prisma.wallet.findFirst({ where: { id, userId } });
    if (!w) throw new NotFoundException('Không tìm thấy ví');
    return w;
  }

  private async assertNameFree(userId: string, name: string, exceptId?: string) {
    const dup = await this.prisma.wallet.findFirst({
      where: { userId, isArchived: false, id: exceptId ? { not: exceptId } : undefined, name: { equals: name, mode: 'insensitive' } },
    });
    if (dup) throw new ConflictException(`Ví "${name}" đã tồn tại`);
  }
}

export function withBalance(w: Wallet, balance: number) {
  return { ...w, initialBalance: n(w.initialBalance), balance };
}

@ApiTags('wallets')
@ApiBearerAuth()
@Controller('wallets')
export class WalletsController {
  constructor(private readonly wallets: WalletsService) {}

  /** Tất cả ví (kể cả đã lưu trữ) kèm số dư + tổng số dư */
  @Get()
  list(@CurrentUser() u: AuthUser) {
    return this.wallets.list(u.id);
  }

  @Get(':id')
  get(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.wallets.get(u.id, id);
  }

  @Post()
  create(@CurrentUser() u: AuthUser, @Body() dto: CreateWalletDto) {
    return this.wallets.create(u.id, dto);
  }

  @Patch(':id')
  update(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateWalletDto) {
    return this.wallets.update(u.id, id, dto);
  }

  /** Chưa phát sinh => xóa hẳn; có phát sinh và số dư = 0 => lưu trữ; còn tiền => 409 */
  @Delete(':id') @HttpCode(200)
  remove(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.wallets.remove(u.id, id);
  }

  @Post(':id/restore') @HttpCode(200)
  restore(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.wallets.restore(u.id, id);
  }
}

@Module({ controllers: [WalletsController], providers: [WalletsService], exports: [WalletsService] })
export class WalletsModule {}
