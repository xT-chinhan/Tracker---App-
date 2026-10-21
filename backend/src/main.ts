import { ValidationPipe } from '@nestjs/common';
import { HttpAdapterHost, NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { PrismaExceptionFilter } from './common/prisma-exception.filter';
import { APP_VERSION } from './health/health.module';

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

  const doc = new DocumentBuilder().setTitle('App Tracker API').setVersion(APP_VERSION).addBearerAuth().build();
  SwaggerModule.setup('docs', app, () => SwaggerModule.createDocument(app, doc), {
    jsonDocumentUrl: 'docs/openapi.json',
  });

  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
