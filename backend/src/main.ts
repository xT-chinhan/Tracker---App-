import { ValidationPipe } from '@nestjs/common';
import { HttpAdapterHost, NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { PrismaExceptionFilter } from './common/prisma-exception.filter';
import { APP_VERSION } from './health/health.module';
import { decorateDocument, SWAGGER_UI_OPTIONS } from './openapi-docs';

// Tiền lưu BigInt trong DB, trả ra JSON dạng number (an toàn tới ~9 triệu tỷ).
(BigInt.prototype as unknown as { toJSON: () => number }).toJSON = function (this: bigint) {
  return Number(this);
};

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.setGlobalPrefix('api');
  // Sau reverse proxy: TRUST_PROXY=1 (số hop) | true | danh sách IP => rate limit đếm theo IP thật của client
  const trustProxy = process.env.TRUST_PROXY;
  if (trustProxy) app.getHttpAdapter().getInstance().set('trust proxy', trustProxy === 'true' ? true : /^\d+$/.test(trustProxy) ? Number(trustProxy) : trustProxy);
  // CORS_ORIGINS: danh sách cách nhau dấu phẩy; "*" là ký tự đại diện (vd http://localhost:* cho flutter run -d chrome, cổng đổi mỗi lần)
  const origins = (process.env.CORS_ORIGINS ?? '').split(',').map((o) => o.trim()).filter(Boolean)
    .map((o) => (o.includes('*') ? new RegExp(`^${o.replace(/[.+?^${}()|[\]\\]/g, '\\$&').replace(/\*/g, '[^/]*')}$`) : o));
  app.enableCors({
    origin: origins,
    exposedHeaders: ['Retry-After', 'Content-Disposition'],
  });
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }));
  app.useGlobalFilters(new PrismaExceptionFilter(app.get(HttpAdapterHost).httpAdapter));

  // Swagger: không cho CDN (Cloudflare) / trình duyệt giữ bản cũ của tài liệu
  app.use((req: { url: string }, res: { setHeader(k: string, v: string): void }, next: () => void) => {
    if (req.url.startsWith('/docs') || req.url.startsWith('/api/docs')) res.setHeader('Cache-Control', 'no-store');
    next();
  });
  const doc = new DocumentBuilder().setTitle('TrackerX API').setVersion(APP_VERSION).addBearerAuth().build();
  SwaggerModule.setup('docs', app, () => decorateDocument(SwaggerModule.createDocument(app, doc)), {
    jsonDocumentUrl: 'docs/openapi.json',
    ...SWAGGER_UI_OPTIONS,
  });
  // bản sao dưới /api/docs (cùng nội dung) — đi qua cùng đường tunnel với API
  SwaggerModule.setup('api/docs', app, () => decorateDocument(SwaggerModule.createDocument(app, doc)), {
    jsonDocumentUrl: 'api/docs/openapi.json',
    ...SWAGGER_UI_OPTIONS,
  });

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
