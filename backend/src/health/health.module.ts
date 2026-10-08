import { Controller, Get, Injectable, Module, ServiceUnavailableException } from '@nestjs/common';
import { ApiServiceUnavailableResponse, ApiTags } from '@nestjs/swagger';
import { readFileSync } from 'fs';
import { join } from 'path';
import { PrismaService } from '../prisma/prisma.service';
import { Public } from '../common/auth';

/** Phiên bản lấy từ package.json (dist/health => ../../package.json). */
export const APP_VERSION: string = (() => {
  try {
    return JSON.parse(readFileSync(join(__dirname, '..', '..', 'package.json'), 'utf8')).version;
  } catch {
    return 'unknown';
  }
})();

@Injectable()
export class HealthService {
  constructor(private readonly prisma: PrismaService) {}

  /** Ping DB; DB lỗi => 503 cùng cấu trúc để load balancer / docker healthcheck đọc được. */
  async check() {
    try {
      await this.prisma.$queryRaw`SELECT 1`;
      return { status: 'ok', db: 'up', version: APP_VERSION };
    } catch {
      throw new ServiceUnavailableException({ status: 'error', db: 'down', version: APP_VERSION });
    }
  }
}

@ApiTags('health')
@Controller('health')
export class HealthController {
  constructor(private readonly health: HealthService) {}

  /** Công khai: `{status, db, version}`; DB không kết nối được => 503 */
  @Public() @Get() @ApiServiceUnavailableResponse()
  check() {
    return this.health.check();
  }
}

@Module({ controllers: [HealthController], providers: [HealthService] })
export class HealthModule {}
