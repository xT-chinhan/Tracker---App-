import { Body, ConflictException, Controller, Delete, Get, HttpCode, Injectable, Module, NotFoundException, Param, ParseUUIDPipe, Patch, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags, IntersectionType } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { ArrayMaxSize, ArrayMinSize, IsArray, IsDateString, IsEnum, IsInt, IsOptional, IsString, IsUUID, Max, MaxLength, Min, MinLength, ValidateNested } from 'class-validator';
import { Prisma, Transaction, TxType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser } from '../common/auth';
import { MAX_AMOUNT, PageQuery, paged, RangeQuery, Trim } from '../common/dto';
import { monthOf, parseDate, resolveRange } from '../common/time';
import { CategoriesModule, CategoriesService } from '../categories/categories.module';
import { WalletsModule, WalletsService } from '../wallets/wallets.module';
import { BudgetsModule, BudgetsService } from '../budgets/budgets.module';

export class CreateTransactionDto {
  @IsUUID() categoryId: string;
  /** Ví phát sinh (của user, chưa lưu trữ) */
  @IsUUID() walletId: string;
  /** Số tiền dương (VND). Loại thu/chi lấy theo danh mục. */
  @Type(() => Number) @IsInt() @Min(1) @Max(MAX_AMOUNT) amount: number;
  @Trim() @IsString() @MinLength(1) @MaxLength(120) title: string;
  @IsOptional() @IsString() @MaxLength(500) note?: string;
  /** ISO 8601, mặc định là thời điểm hiện tại */
  @IsOptional() @IsDateString() occurredAt?: string;
}

class UpdateTransactionDto {
  @IsOptional() @IsUUID() categoryId?: string;
  @IsOptional() @IsUUID() walletId?: string;
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(MAX_AMOUNT) amount?: number;
  @IsOptional() @Trim() @IsString() @MinLength(1) @MaxLength(120) title?: string;
  @IsOptional() @IsString() @MaxLength(500) note?: string;
  @IsOptional() @IsDateString() occurredAt?: string;
}

export class TransactionFilter extends IntersectionType(PageQuery, RangeQuery) {
  @IsOptional() @IsEnum(TxType) type?: TxType;
  @IsOptional() @IsUUID() categoryId?: string;
  @IsOptional() @IsUUID() walletId?: string;
  /** Tìm trong tiêu đề / ghi chú */
  @IsOptional() @Trim() @IsString() @MaxLength(100) q?: string;
}

export const TX_CATEGORY_SELECT = { select: { id: true, name: true, icon: true, color: true, type: true } } as const;
export const TX_WALLET_SELECT = { select: { id: true, name: true, type: true, icon: true, color: true, isArchived: true } } as const;
const TX_INCLUDE = { category: TX_CATEGORY_SELECT, wallet: TX_WALLET_SELECT } as const;

export function buildTxWhere(f: TransactionFilter): Prisma.TransactionWhereInput {
  const range = resolveRange(f);
  return {
    type: f.type,
    categoryId: f.categoryId,
    walletId: f.walletId,
    occurredAt: range.gte || range.lt ? range : undefined,
    OR: f.q
      ? [
          { title: { contains: f.q, mode: 'insensitive' } },
          { note: { contains: f.q, mode: 'insensitive' } },
        ]
      : undefined,
  };
}

/** Cờ `recurring` = giao dịch sinh từ giao dịch định kỳ. */
export const withFlags = <T extends Transaction>(t: T) => ({ ...t, recurring: t.recurringRuleId !== null || t.scheduledFor !== null });

@Injectable()
export class TransactionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly categories: CategoriesService,
    private readonly wallets: WalletsService,
    private readonly budgets: BudgetsService,
  ) {}

  async list(userId: string, f: TransactionFilter) {
    const where = { ...buildTxWhere(f), userId };
    const [items, total] = await this.prisma.$transaction([
      this.prisma.transaction.findMany({
        where,
        include: TX_INCLUDE,
        orderBy: [{ occurredAt: 'desc' }, { createdAt: 'desc' }],
        skip: (f.page - 1) * f.limit,
        take: f.limit,
      }),
      this.prisma.transaction.count({ where }),
    ]);
    return paged(items.map(withFlags), total, f);
  }

  async get(userId: string, id: string) {
    const tx = await this.prisma.transaction.findFirst({ where: { id, userId }, include: TX_INCLUDE });
    if (!tx) throw new NotFoundException('Không tìm thấy giao dịch');
    return withFlags(tx);
  }

  /**
   * Điểm tạo giao dịch duy nhất (API, mẫu nhập nhanh, giao dịch định kỳ) => cùng kiểm tra + cảnh báo ngân sách.
   * `recurring` chỉ dùng nội bộ: gắn rule + kỳ để unique chặn sinh trùng.
   */
  async create(userId: string, dto: CreateTransactionDto, recurring?: { ruleId: string; scheduledFor: Date }) {
    const category = await this.categories.usableForUser(userId, dto.categoryId);
    const wallet = await this.wallets.usable(userId, dto.walletId);
    const tx = await this.prisma.transaction.create({
      data: {
        userId,
        categoryId: category.id,
        walletId: wallet.id,
        type: category.type,
        amount: BigInt(dto.amount),
        title: dto.title.trim(),
        note: dto.note?.trim() || null,
        occurredAt: dto.occurredAt ? parseDate(dto.occurredAt) : new Date(),
        recurringRuleId: recurring?.ruleId,
        scheduledFor: recurring?.scheduledFor,
      },
      include: TX_INCLUDE,
    });
    if (tx.type === 'EXPENSE') await this.budgets.checkThresholds(userId, monthOf(tx.occurredAt), tx.categoryId);
    return withFlags(tx);
  }

  async update(userId: string, id: string, dto: UpdateTransactionDto) {
    const current = await this.get(userId, id);
    if (current.wallet.isArchived) {
      throw new ConflictException('Giao dịch thuộc ví đã lưu trữ, hãy khôi phục ví trước khi sửa');
    }
    let type = current.type;
    if (dto.categoryId && dto.categoryId !== current.categoryId) {
      type = (await this.categories.usableForUser(userId, dto.categoryId)).type;
    }
    if (dto.walletId && dto.walletId !== current.walletId) await this.wallets.usable(userId, dto.walletId);
    const tx = await this.prisma.transaction.update({
      where: { id },
      data: {
        categoryId: dto.categoryId,
        walletId: dto.walletId,
        type,
        amount: dto.amount !== undefined ? BigInt(dto.amount) : undefined,
        title: dto.title?.trim(),
        note: dto.note !== undefined ? dto.note.trim() || null : undefined,
        occurredAt: dto.occurredAt ? parseDate(dto.occurredAt) : undefined,
      },
      include: TX_INCLUDE,
    });
    // Tháng / danh mục cũ cũng được tính lại (giao dịch dời đi => chi cũ giảm, dấu cảnh báo được xóa)
    const checks = new Set<string>();
    if (current.type === 'EXPENSE') checks.add(`${monthOf(current.occurredAt)}|${current.categoryId}`);
    if (tx.type === 'EXPENSE') checks.add(`${monthOf(tx.occurredAt)}|${tx.categoryId}`);
    for (const key of checks) {
      const [month, categoryId] = key.split('|');
      await this.budgets.checkThresholds(userId, month, categoryId);
    }
    return withFlags(tx);
  }

  async remove(userId: string, id: string) {
    const tx = await this.prisma.transaction.findFirst({ where: { id, userId }, include: { wallet: true } });
    if (!tx) throw new NotFoundException('Không tìm thấy giao dịch');
    if (tx.wallet.isArchived) throw new ConflictException('Giao dịch thuộc ví đã lưu trữ, hãy khôi phục ví trước khi xóa');
    await this.prisma.transaction.delete({ where: { id } });
    if (tx.type === 'EXPENSE') await this.budgets.checkThresholds(userId, monthOf(tx.occurredAt), tx.categoryId);
  }

  /** Nhập nhiều giao dịch một lần. Tất cả hoặc không gì cả. */
  async createMany(userId: string, items: CreateTransactionDto[]) {
    const cats = new Map<string, TxType>();
    for (const it of items) {
      if (!cats.has(it.categoryId)) cats.set(it.categoryId, (await this.categories.usableForUser(userId, it.categoryId)).type);
    }
    for (const walletId of new Set(items.map((it) => it.walletId))) await this.wallets.usable(userId, walletId);
    const now = new Date();
    const data = items.map((it) => ({
      userId,
      categoryId: it.categoryId,
      walletId: it.walletId,
      type: cats.get(it.categoryId)!,
      amount: BigInt(it.amount),
      title: it.title.trim(),
      note: it.note?.trim() || null,
      occurredAt: it.occurredAt ? parseDate(it.occurredAt) : now,
    }));
    const { count } = await this.prisma.transaction.createMany({ data });
    const checks = new Set(data.filter((d) => d.type === 'EXPENSE').map((d) => `${monthOf(d.occurredAt)}|${d.categoryId}`));
    for (const key of checks) {
      const [month, categoryId] = key.split('|');
      await this.budgets.checkThresholds(userId, month, categoryId);
    }
    return { created: count };
  }
}

class BulkCreateDto {
  @IsArray() @ArrayMinSize(1) @ArrayMaxSize(100) @ValidateNested({ each: true }) @Type(() => CreateTransactionDto)
  items: CreateTransactionDto[];
}

@ApiTags('transactions')
@ApiBearerAuth()
@Controller('transactions')
export class TransactionsController {
  constructor(private readonly txs: TransactionsService) {}

  @Get()
  list(@CurrentUser() u: AuthUser, @Query() f: TransactionFilter) {
    return this.txs.list(u.id, f);
  }

  @Get(':id')
  get(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.txs.get(u.id, id);
  }

  @Post()
  create(@CurrentUser() u: AuthUser, @Body() dto: CreateTransactionDto) {
    return this.txs.create(u.id, dto);
  }

  @Post('bulk')
  createMany(@CurrentUser() u: AuthUser, @Body() dto: BulkCreateDto) {
    return this.txs.createMany(u.id, dto.items);
  }

  @Patch(':id')
  update(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateTransactionDto) {
    return this.txs.update(u.id, id, dto);
  }

  @Delete(':id') @HttpCode(204)
  remove(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.txs.remove(u.id, id);
  }
}

@Module({
  imports: [CategoriesModule, WalletsModule, BudgetsModule],
  controllers: [TransactionsController],
  providers: [TransactionsService],
  exports: [TransactionsService],
})
export class TransactionsModule {}
