import { Body, Controller, Delete, Get, HttpCode, Injectable, Module, NotFoundException, Param, ParseUUIDPipe, Patch, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags, IntersectionType } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { ArrayMaxSize, ArrayMinSize, IsArray, IsDateString, IsEnum, IsInt, IsOptional, IsString, IsUUID, Max, MaxLength, Min, MinLength, ValidateNested } from 'class-validator';
import { Prisma, TxType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser } from '../common/auth';
import { MAX_AMOUNT, PageQuery, paged, RangeQuery, Trim } from '../common/dto';
import { resolveRange } from '../common/time';
import { CategoriesModule, CategoriesService } from '../categories/categories.module';

class CreateTransactionDto {
  @IsUUID() categoryId: string;
  /** Số tiền dương (VND). Loại thu/chi lấy theo danh mục. */
  @Type(() => Number) @IsInt() @Min(1) @Max(MAX_AMOUNT) amount: number;
  @Trim() @IsString() @MinLength(1) @MaxLength(120) title: string;
  @IsOptional() @IsString() @MaxLength(500) note?: string;
  /** ISO 8601, mặc định là thời điểm hiện tại */
  @IsOptional() @IsDateString() occurredAt?: string;
}

class UpdateTransactionDto {
  @IsOptional() @IsUUID() categoryId?: string;
  @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(MAX_AMOUNT) amount?: number;
  @IsOptional() @Trim() @IsString() @MinLength(1) @MaxLength(120) title?: string;
  @IsOptional() @IsString() @MaxLength(500) note?: string;
  @IsOptional() @IsDateString() occurredAt?: string;
}

export class TransactionFilter extends IntersectionType(PageQuery, RangeQuery) {
  @IsOptional() @IsEnum(TxType) type?: TxType;
  @IsOptional() @IsUUID() categoryId?: string;
  /** Tìm trong tiêu đề / ghi chú */
  @IsOptional() @IsString() @MaxLength(100) q?: string;
}

export const TX_CATEGORY_SELECT = { select: { id: true, name: true, icon: true, color: true, type: true } } as const;

export function buildTxWhere(f: TransactionFilter): Prisma.TransactionWhereInput {
  const range = resolveRange(f);
  return {
    type: f.type,
    categoryId: f.categoryId,
    occurredAt: range.gte || range.lt ? range : undefined,
    OR: f.q
      ? [
          { title: { contains: f.q, mode: 'insensitive' } },
          { note: { contains: f.q, mode: 'insensitive' } },
        ]
      : undefined,
  };
}

@Injectable()
export class TransactionsService {
  constructor(private readonly prisma: PrismaService, private readonly categories: CategoriesService) {}

  async list(userId: string, f: TransactionFilter) {
    const where = { ...buildTxWhere(f), userId };
    const [items, total] = await this.prisma.$transaction([
      this.prisma.transaction.findMany({
        where,
        include: { category: TX_CATEGORY_SELECT },
        orderBy: [{ occurredAt: 'desc' }, { createdAt: 'desc' }],
        skip: (f.page - 1) * f.limit,
        take: f.limit,
      }),
      this.prisma.transaction.count({ where }),
    ]);
    return paged(items, total, f);
  }

  async get(userId: string, id: string) {
    const tx = await this.prisma.transaction.findFirst({
      where: { id, userId },
      include: { category: TX_CATEGORY_SELECT },
    });
    if (!tx) throw new NotFoundException('Không tìm thấy giao dịch');
    return tx;
  }

  async create(userId: string, dto: CreateTransactionDto) {
    const category = await this.categories.usableForUser(userId, dto.categoryId);
    return this.prisma.transaction.create({
      data: {
        userId,
        categoryId: category.id,
        type: category.type,
        amount: BigInt(dto.amount),
        title: dto.title.trim(),
        note: dto.note?.trim() || null,
        occurredAt: dto.occurredAt ? new Date(dto.occurredAt) : new Date(),
      },
      include: { category: TX_CATEGORY_SELECT },
    });
  }

  async update(userId: string, id: string, dto: UpdateTransactionDto) {
    const current = await this.get(userId, id);
    let type = current.type;
    if (dto.categoryId && dto.categoryId !== current.categoryId) {
      type = (await this.categories.usableForUser(userId, dto.categoryId)).type;
    }
    return this.prisma.transaction.update({
      where: { id },
      data: {
        categoryId: dto.categoryId,
        type,
        amount: dto.amount !== undefined ? BigInt(dto.amount) : undefined,
        title: dto.title?.trim(),
        note: dto.note !== undefined ? dto.note.trim() || null : undefined,
        occurredAt: dto.occurredAt ? new Date(dto.occurredAt) : undefined,
      },
      include: { category: TX_CATEGORY_SELECT },
    });
  }

  async remove(userId: string, id: string) {
    const { count } = await this.prisma.transaction.deleteMany({ where: { id, userId } });
    if (!count) throw new NotFoundException('Không tìm thấy giao dịch');
  }

  /** Nhập nhiều giao dịch một lần (vd: từ màn hình nhập nhanh). Tất cả hoặc không gì cả. */
  async createMany(userId: string, items: CreateTransactionDto[]) {
    const cats = new Map<string, TxType>();
    for (const it of items) {
      if (!cats.has(it.categoryId)) cats.set(it.categoryId, (await this.categories.usableForUser(userId, it.categoryId)).type);
    }
    const now = new Date();
    const { count } = await this.prisma.transaction.createMany({
      data: items.map((it) => ({
        userId,
        categoryId: it.categoryId,
        type: cats.get(it.categoryId)!,
        amount: BigInt(it.amount),
        title: it.title.trim(),
        note: it.note?.trim() || null,
        occurredAt: it.occurredAt ? new Date(it.occurredAt) : now,
      })),
    });
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

@Module({ imports: [CategoriesModule], controllers: [TransactionsController], providers: [TransactionsService] })
export class TransactionsModule {}
