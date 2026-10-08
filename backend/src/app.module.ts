import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { JwtModule } from '@nestjs/jwt';
import { ScheduleModule } from '@nestjs/schedule';
import { ThrottlerModule } from '@nestjs/throttler';
import { PrismaModule } from './prisma/prisma.service';
import { AuthGuard } from './common/auth';
import { AuthModule } from './auth/auth.module';
import { CategoriesModule } from './categories/categories.module';
import { TransactionsModule } from './transactions/transactions.module';
import { BudgetsModule } from './budgets/budgets.module';
import { SavingGoalsModule } from './saving-goals/saving-goals.module';
import { StatsModule } from './stats/stats.module';
import { AdminModule } from './admin/admin.module';
import { WalletsModule } from './wallets/wallets.module';
import { TransfersModule } from './transfers/transfers.module';
import { NotificationsModule } from './notifications/notifications.module';
import { QuickTemplatesModule } from './quick-templates/quick-templates.module';
import { ExportModule } from './export/export.module';
import { RecurringModule } from './recurring/recurring.module';
import { HealthModule } from './health/health.module';
import { SystemConfigModule, SystemConfigService } from './system-config/system-config.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    JwtModule.registerAsync({
      global: true,
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const secret = config.getOrThrow<string>('JWT_SECRET');
        if (config.get('NODE_ENV') === 'production' && secret.length < 16) throw new Error('JWT_SECRET phải dài >= 16 ký tự ở production');
        return {
          secret,
          signOptions: { expiresIn: config.get('JWT_EXPIRES_IN', '30d') },
        };
      },
    }),
    ScheduleModule.forRoot(),
    SystemConfigModule,
    // Chỉ áp cho các route có @UseGuards(ThrottlerGuard) (auth công khai + gửi email thử).
    //  - default: theo IP + route. NODE_ENV=test nới giới hạn (cửa sổ 10s) để e2e chạy được; ghi đè được bằng env.
    //  - login: theo email, số lần / khung thời gian lấy từ Cấu hình hệ thống (access.loginMaxAttempts / loginWindowMinutes).
    //  - smtpTest: gửi email thử, 5 lần / phút / admin.
    ThrottlerModule.forRootAsync({
      imports: [SystemConfigModule],
      inject: [ConfigService, SystemConfigService],
      useFactory: (config: ConfigService, sys: SystemConfigService) => {
        const test = config.get('NODE_ENV') === 'test';
        const num = (key: string, dev: number, testValue: number) => Number(config.get(key) ?? (test ? testValue : dev));
        const authLimit = num('THROTTLE_AUTH_LIMIT', 10, 200);
        const forgotLimit = num('THROTTLE_FORGOT_LIMIT', 3, 20);
        return {
          errorMessage: 'Bạn thao tác quá nhiều lần, vui lòng thử lại sau',
          throttlers: [
            {
              name: 'default',
              ttl: num('THROTTLE_TTL_SEC', 60, 10) * 1000,
              limit: (ctx) => (ctx.getHandler().name === 'forgotPassword' ? forgotLimit : authLimit),
              skipIf: (ctx) => ctx.getHandler().name === 'testSmtp',
            },
            {
              name: 'login',
              ttl: async () => (await sys.loginLimit()).ttlMs,
              limit: async () => (await sys.loginLimit()).limit,
              skipIf: (ctx) => ctx.getHandler().name !== 'login',
              getTracker: (req) => String(req.body?.email ?? '').toLowerCase().trim(),
            },
            {
              name: 'smtpTest',
              ttl: 60_000,
              limit: 5,
              skipIf: (ctx) => ctx.getHandler().name !== 'testSmtp',
              getTracker: (req) => String(req.user?.id ?? req.ip),
            },
          ],
        };
      },
    }),
    PrismaModule,
    AuthModule,
    WalletsModule,
    CategoriesModule,
    TransactionsModule,
    BudgetsModule,
    SavingGoalsModule,
    StatsModule,
    TransfersModule,
    NotificationsModule,
    QuickTemplatesModule,
    RecurringModule,
    ExportModule,
    AdminModule,
    HealthModule,
  ],
  providers: [{ provide: APP_GUARD, useClass: AuthGuard }],
})
export class AppModule {}
