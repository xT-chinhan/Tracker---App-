import { ExecutionContext, Injectable } from '@nestjs/common';
import { ThrottlerGuard, ThrottlerLimitDetail } from '@nestjs/throttler';

/**
 * ThrottlerGuard có thêm header `Retry-After` chuẩn cho mọi throttler có tên (login theo email, smtpTest):
 * thư viện chỉ đặt `Retry-After-<tên>`, còn app / trang admin đọc `Retry-After`.
 */
@Injectable()
export class AppThrottlerGuard extends ThrottlerGuard {
  protected async throwThrottlingException(context: ExecutionContext, detail: ThrottlerLimitDetail): Promise<void> {
    context.switchToHttp().getResponse().header('Retry-After', String(detail.timeToBlockExpire));
    return super.throwThrottlingException(context, detail);
  }
}
