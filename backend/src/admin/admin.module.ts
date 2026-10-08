import { BadRequestException, Body, Controller, Delete, Get, HttpCode, Injectable, Module, NotFoundException, Param, ParseUUIDPipe, Patch, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { IsEnum, IsOptional, IsString, IsUUID, MaxLength, MinLength } from 'class-validator';
import { Prisma, Role, TxType, UserStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser, Roles } from '../common/auth';
import { PageQuery, paged, Trim } from '../common/dto';
import { monthOf } from '../common/time';
import { publicUser } from '../auth/auth.module';
import { CategoriesModule, CategoriesService, CreateCategoryDto, UpdateCategoryDto } from '../categories/categories.module';
import { StatsModule, StatsService } from '../stats/stats.module';
import { buildTxWhere, TransactionFilter, TX_CATEGORY_SELECT, TX_WALLET_SELECT, withFlags } from '../transactions/transactions.module';
import { WalletsModule, WalletsService } from '../wallets/wallets.module';

class UserListQuery extends PageQuery {
  /** Tìm theo email / tên */
  @IsOptional() @IsString() @MaxLength(100) q?: string;
  @IsOptional() @IsEnum(UserStatus) status?: UserStatus;
  @IsOptional() @IsEnum(Role) role?: Role;
}

class UpdateUserDto {
  @IsOptional() @IsEnum(UserStatus) status?: UserStatus;
  @IsOptional() @IsEnum(Role) role?: Role;
}

class AdminTxFilter extends TransactionFilter {
  @IsOptional() @IsUUID() userId?: string;
}

class BroadcastDto {
  @Trim() @IsString() @MinLength(1) @MaxLength(120) title: string;
  @Trim() @IsString() @MinLength(1) @MaxLength(2000) body: string;
}

class SystemCategoryQuery {
  @IsOptional() @IsEnum(TxType) type?: TxType;
}

const DAY_MS = 24 * 60 * 60 * 1000;

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService, private readonly stats: StatsService, private readonly wallets: WalletsService) {}

  async overview() {
    const since30d = new Date(Date.now() - 30 * DAY_MS);
    const [byStatus, newUsers30d, txByType, tx30d, goals] = await Promise.all([
      this.prisma.user.groupBy({ by: ['status'], _count: true }),
      this.prisma.user.count({ where: { createdAt: { gte: since30d } } }),
      this.prisma.transaction.groupBy({ by: ['type'], _sum: { amount: true }, _count: true }),
      this.prisma.transaction.count({ where: { createdAt: { gte: since30d } } }),
      this.prisma.savingGoal.groupBy({ by: ['status'], _count: true }),
    ]);
    const count = (s: UserStatus) => byStatus.find((r) => r.status === s)?._count ?? 0;
    const tx = (t: TxType) => txByType.find((r) => r.type === t);
    return {
      users: { total: count('ACTIVE') + count('LOCKED'), active: count('ACTIVE'), locked: count('LOCKED'), new30d: newUsers30d },
      transactions: {
        total: (tx('INCOME')?._count ?? 0) + (tx('EXPENSE')?._count ?? 0),
        new30d: tx30d,
        totalIncome: Number(tx('INCOME')?._sum.amount ?? 0),
        totalExpense: Number(tx('EXPENSE')?._sum.amount ?? 0),
      },
      savingGoals: Object.fromEntries(goals.map((g) => [g.status, g._count])),
      trend: await this.stats.monthlyTotals(null, monthOf(new Date()), 6),
    };
  }

  async users(q: UserListQuery) {
    const where: Prisma.UserWhereInput = {
      status: q.status,
      role: q.role,
      OR: q.q
        ? [
            { email: { contains: q.q, mode: 'insensitive' } },
            { name: { contains: q.q, mode: 'insensitive' } },
          ]
        : undefined,
    };
    const [items, total] = await this.prisma.$transaction([
      this.prisma.user.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (q.page - 1) * q.limit,
        take: q.limit,
        include: { _count: { select: { transactions: true, savingGoals: true } } },
      }),
      this.prisma.user.count({ where }),
    ]);
    return paged(items.map(publicUser), total, q);
  }

  async user(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      include: { _count: { select: { transactions: true, categories: true, budgets: true, savingGoals: true } } },
    });
    if (!user) throw new NotFoundException('Không tìm thấy người dùng');
    return {
      ...publicUser(user),
      finance: await this.stats.balance(id),
      wallets: (await this.wallets.list(id)).items,
      trend: await this.stats.monthlyTotals(id, monthOf(new Date()), 6),
    };
  }

  async updateUser(actor: AuthUser, id: string, dto: UpdateUserDto) {
    if (id === actor.id && (dto.status === 'LOCKED' || dto.role === 'USER')) {
      throw new BadRequestException('Không thể tự khóa hoặc tự hạ quyền chính mình');
    }
    return publicUser(await this.prisma.user.update({ where: { id }, data: dto }));
  }

  async transactions(f: AdminTxFilter) {
    const where = { ...buildTxWhere(f), userId: f.userId };
    const [items, total] = await this.prisma.$transaction([
      this.prisma.transaction.findMany({
        where,
        include: { category: TX_CATEGORY_SELECT, wallet: TX_WALLET_SELECT, user: { select: { id: true, email: true, name: true } } },
        orderBy: [{ occurredAt: 'desc' }, { createdAt: 'desc' }],
        skip: (f.page - 1) * f.limit,
        take: f.limit,
      }),
      this.prisma.transaction.count({ where }),
    ]);
    return paged(items.map(withFlags), total, f);
  }

  /** Gửi thông báo cho mọi user ACTIVE, lưu lịch sử + số người nhận. */
  async broadcast(actor: AuthUser, dto: BroadcastDto) {
    return this.prisma.$transaction(async (db) => {
      const users = await db.user.findMany({ where: { status: 'ACTIVE' }, select: { id: true } });
      const b = await db.broadcast.create({ data: { title: dto.title, body: dto.body, createdById: actor.id, recipients: users.length } });
      await db.notification.createMany({
        data: users.map((u) => ({ userId: u.id, type: 'BROADCAST' as const, title: dto.title, body: dto.body, broadcastId: b.id })),
      });
      return b;
    });
  }

  async broadcasts(q: PageQuery) {
    const [items, total] = await this.prisma.$transaction([
      this.prisma.broadcast.findMany({
        orderBy: { createdAt: 'desc' },
        skip: (q.page - 1) * q.limit,
        take: q.limit,
        include: { _count: { select: { notifications: { where: { readAt: { not: null } } } } } },
      }),
      this.prisma.broadcast.count(),
    ]);
    return paged(items.map(({ _count, ...b }) => ({ ...b, readCount: _count.notifications })), total, q);
  }
}

@ApiTags('admin')
@ApiBearerAuth()
@Roles('ADMIN')
@Controller('admin')
export class AdminController {
  constructor(private readonly admin: AdminService, private readonly categories: CategoriesService) {}

  @Get('overview')
  overview() {
    return this.admin.overview();
  }

  @Get('users')
  users(@Query() q: UserListQuery) {
    return this.admin.users(q);
  }

  @Get('users/:id')
  user(@Param('id', ParseUUIDPipe) id: string) {
    return this.admin.user(id);
  }

  /** Khóa / mở khóa, đổi quyền */
  @Patch('users/:id')
  updateUser(@CurrentUser() actor: AuthUser, @Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateUserDto) {
    return this.admin.updateUser(actor, id, dto);
  }

  @Get('transactions')
  transactions(@Query() f: AdminTxFilter) {
    return this.admin.transactions(f);
  }

  /** Gửi thông báo trong app cho mọi user ACTIVE */
  @Post('broadcasts')
  broadcast(@CurrentUser() actor: AuthUser, @Body() dto: BroadcastDto) {
    return this.admin.broadcast(actor, dto);
  }

  /** Lịch sử broadcast: số người nhận + số người đã đọc */
  @Get('broadcasts')
  broadcasts(@Query() q: PageQuery) {
    return this.admin.broadcasts(q);
  }

  /** Danh mục hệ thống (dùng chung cho mọi user), kèm số giao dịch đang dùng */
  @Get('categories')
  listCategories(@Query() q: SystemCategoryQuery) {
    return this.categories.listSystem(q.type);
  }

  @Post('categories')
  createCategory(@Body() dto: CreateCategoryDto) {
    return this.categories.create(null, dto);
  }

  @Patch('categories/:id')
  updateCategory(@Param('id', ParseUUIDPipe) id: string, @Body() dto: UpdateCategoryDto) {
    return this.categories.update(null, id, dto);
  }

  /** Đang được dùng => lưu trữ (ẩn với user), chưa dùng => xóa hẳn */
  @Delete('categories/:id') @HttpCode(200)
  removeCategory(@Param('id', ParseUUIDPipe) id: string) {
    return this.categories.remove(null, id);
  }

  @Post('categories/:id/restore') @HttpCode(200)
  restoreCategory(@Param('id', ParseUUIDPipe) id: string) {
    return this.categories.restore(null, id);
  }
}

@Module({ imports: [CategoriesModule, StatsModule, WalletsModule], controllers: [AdminController], providers: [AdminService] })
export class AdminModule {}
