import { Injectable, Logger } from '@nestjs/common';
import { SystemConfigService } from '../system-config/system-config.module';
import { MailContent, resetOtpMail } from './mail-templates';

/** Gửi mail theo SMTP trong Cấu hình hệ thống (fallback SMTP_* env); chưa cấu hình máy chủ => in OTP ra log (dev / e2e). */
@Injectable()
export class MailService {
  private readonly logger = new Logger('Mail');

  constructor(private readonly sys: SystemConfigService) {}

  async sendOtp(email: string, otp: string, minutes: number, name?: string) {
    const m = await this.sys.mailer();
    if (!m) {
      this.logger.warn(`[DEV] OTP đặt lại mật khẩu cho ${email}: ${otp} (hạn ${minutes} phút)`);
      return;
    }
    await this.deliver(email, resetOtpMail(await this.brand(), { otp, minutes, name }));
  }

  /** Thông báo bảo mật (gắn / gỡ số, đặt lại mật khẩu bằng SĐT). Lỗi gửi chỉ ghi log, không làm hỏng thao tác chính. */
  async notify(email: string, build: (b: Awaited<ReturnType<MailService['brand']>>) => MailContent) {
    const content = build(await this.brand());
    const m = await this.sys.mailer();
    if (!m) {
      this.logger.warn(`[DEV] Mail tới ${email}: ${content.subject}`);
      return;
    }
    await this.deliver(email, content).catch((e) => this.logger.error(`gửi mail ${content.subject}: ${e?.message ?? e}`));
  }

  private async brand() {
    return { appName: await this.sys.get<string>('general.appName'), supportEmail: (await this.sys.get<string>('general.supportEmail')) || null };
  }

  private async deliver(email: string, c: MailContent) {
    const m = (await this.sys.mailer())!;
    await m.transport.sendMail({ from: m.from, to: email, subject: c.subject, html: c.html, text: c.text });
  }
}

