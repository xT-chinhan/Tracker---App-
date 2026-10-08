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
    // Chỉ áp cho các route auth công khai (@UseGuards(ThrottlerGuard)); đếm theo IP + route.
    // NODE_ENV=test nới giới hạn (cửa sổ 10s) để e2e chạy được; mọi giá trị ghi đè được bằng env.
    ThrottlerModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => {
        const test = config.get('NODE_ENV') === 'test';
        const num = (key: string, dev: number, testValue: number) => Number(config.get(key) ?? (test ? testValue : dev));
        const authLimit = num('THROTTLE_AUTH_LIMIT', 10, 200);
        const forgotLimit = num('THROTTLE_FORGOT_LIMIT', 3, 20);
        return {
          errorMessage: 'Bạn thao tác quá nhiều lần, vui lòng thử lại sau',
          throttlers: [{
            ttl: num('THROTTLE_TTL_SEC', 60, 10) * 1000,
            limit: (ctx) => (ctx.getHandler().name === 'forgotPassword' ? forgotLimit : authLimit),
          }],
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
