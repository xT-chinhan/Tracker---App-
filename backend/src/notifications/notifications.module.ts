import { Controller, Get, HttpCode, Injectable, Module, NotFoundException, Param, ParseUUIDPipe, Post, Query } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsBoolean, IsIn, IsOptional } from 'class-validator';
import { Notification } from '@prisma/client';
import { CATEGORY_OF, NOTIFICATION_CATEGORIES, NotificationCategory, typesOf } from './categories';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser } from '../common/auth';
import { PageQuery, paged } from '../common/dto';

class NotificationQuery extends PageQuery {
  /** true => chỉ thông báo chưa đọc */
  @IsOptional() @Transform(({ value }) => (value === 'true' ? true : value === 'false' ? false : value)) @IsBoolean()
  unread?: boolean;
  /** Lọc theo nhóm: balance | budget | system | security */
  @IsOptional() @IsIn(NOTIFICATION_CATEGORIES) category?: NotificationCategory;
}

class CategoryQuery {
  @IsOptional() @IsIn(NOTIFICATION_CATEGORIES) category?: NotificationCategory;
}

const withCategory = (n: Notification) => ({ ...n, category: CATEGORY_OF[n.type] });

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async list(userId: string, q: NotificationQuery) {
    const where = { userId, readAt: q.unread ? null : undefined, type: q.category ? { in: typesOf(q.category) } : undefined };
    const [items, total] = await this.prisma.$transaction([
      this.prisma.notification.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: (q.page - 1) * q.limit,
        take: q.limit,
      }),
      this.prisma.notification.count({ where }),
    ]);
    return paged(items.map(withCategory), total, q);
  }

  /** `count` tổng (app cũ dùng) + `byCategory` cho badge từng nhóm */
  async unreadCount(userId: string) {
    const rows = await this.prisma.notification.groupBy({ by: ['type'], where: { userId, readAt: null }, _count: true });
    const byCategory = Object.fromEntries(NOTIFICATION_CATEGORIES.map((c) => [c, 0])) as Record<NotificationCategory, number>;
    for (const r of rows) byCategory[CATEGORY_OF[r.type]] += r._count;
    return { count: rows.reduce((a, r) => a + r._count, 0), byCategory };
  }

  async read(userId: string, id: string) {
    const n = await this.prisma.notification.findFirst({ where: { id, userId } });
    if (!n) throw new NotFoundException('Không tìm thấy thông báo');
    return withCategory(n.readAt ? n : await this.prisma.notification.update({ where: { id }, data: { readAt: new Date() } }));
  }

  async readAll(userId: string, category?: NotificationCategory) {
    const { count } = await this.prisma.notification.updateMany({
      where: { userId, readAt: null, type: category ? { in: typesOf(category) } : undefined },
      data: { readAt: new Date() },
    });
    return { updated: count };
  }
}

@ApiTags('notifications')
@ApiBearerAuth()
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly notifications: NotificationsService) {}

  @Get()
  list(@CurrentUser() u: AuthUser, @Query() q: NotificationQuery) {
    return this.notifications.list(u.id, q);
  }

  @Get('unread-count')
  unreadCount(@CurrentUser() u: AuthUser) {
    return this.notifications.unreadCount(u.id);
  }

  /** ?category= → chỉ đánh dấu đã đọc trong nhóm đó */
  @Post('read-all') @HttpCode(200)
  readAll(@CurrentUser() u: AuthUser, @Query() q: CategoryQuery) {
    return this.notifications.readAll(u.id, q.category);
  }

  @Post(':id/read') @HttpCode(200)
  read(@CurrentUser() u: AuthUser, @Param('id', ParseUUIDPipe) id: string) {
    return this.notifications.read(u.id, id);
  }
}

@Module({ controllers: [NotificationsController], providers: [NotificationsService] })
export class NotificationsModule {}
