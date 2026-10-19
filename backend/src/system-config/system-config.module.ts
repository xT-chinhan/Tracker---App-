import {
  BadRequestException,
  Body,
  Controller,
  ForbiddenException,
  Get,
  Global,
  HttpCode,
  Injectable,
  Logger,
  Module,
  Patch,
  Post,
  Query,
  ServiceUnavailableException,
  UseGuards,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Cron } from '@nestjs/schedule';
import { AppThrottlerGuard } from '../common/throttle';
import { ApiBearerAuth, ApiBody, ApiTags, ApiTooManyRequestsResponse } from '@nestjs/swagger';
import { IsBoolean, IsIn, IsOptional, IsString } from 'class-validator';
import { Prisma, Role } from '@prisma/client';
import { createCipheriv, createDecipheriv, createHash, randomBytes } from 'crypto';
import * as nodemailer from 'nodemailer';
import { PrismaService } from '../prisma/prisma.service';
import { AuthUser, CurrentUser, FeatureName, Public, Roles, SYSTEM_CONFIG } from '../common/auth';
import { PageQuery, paged } from '../common/dto';

/* ============================== Định nghĩa cấu hình ============================== */

export const SECTIONS = ['general', 'access', 'smtp', 'password', 'business', 'mobile', 'ai'] as const;
export type Section = (typeof SECTIONS)[number];

type Kind = 'string' | 'int' | 'bool' | 'datetime' | 'enum';
type Format = 'email' | 'https' | 'version' | 'phone' | 'from' | 'url';

interface Def {
  section: Section;
  field: string;
  kind: Kind;
  min?: number;
  max?: number;
  /** Độ dài tối đa (string) */
  maxLen?: number;
  /** Bắt buộc có nội dung (string) */
  required?: boolean;
  values?: readonly string[];
  format?: Format;
  secret?: boolean;
  /** Không sửa qua PATCH (vd trạng thái bảo trì có endpoint riêng) */
  internal?: boolean;
  def: (env: EnvDefaults) => unknown;
}

interface EnvDefaults {
  test: boolean;
  smtpHost: string;
  smtpPort: number;
  smtpSecure: boolean;
  smtpUser: string;
  smtpPass: string;
  smtpFrom: string;
  jwtDays: number;
  loginLimit: number;
  aiProvider: string;
  ollamaUrl: string;
  aiChatModel: string;
  aiEmbedModel: string;
}

const FEATURE_FIELDS: Record<FeatureName, string> = {
  savingGoals: 'featureSavingGoals',
  recurring: 'featureRecurring',
  transfers: 'featureTransfers',
  csvExport: 'featureCsvExport',
  quickTemplates: 'featureQuickTemplates',
  ai: 'featureAi',
  // Chỉ app Android: đọc thông báo biến động số dư ngân hàng / ví (mobile/modules/bank_notification_listener) để gợi ý ghi giao dịch.
  // Không có route riêng ở backend (app tạo giao dịch qua POST /transactions sau khi người dùng xác nhận); cờ chỉ để app ẩn / hiện.
  bankNotifications: 'featureBankNotifications',
};

export const FEATURE_LABELS: Record<FeatureName, string> = {
  savingGoals: 'Mục tiêu tiết kiệm',
  recurring: 'Giao dịch định kỳ',
  transfers: 'Chuyển tiền giữa ví',
  csvExport: 'Xuất CSV',
  quickTemplates: 'Mẫu nhập nhanh',
  ai: 'Trợ lý AI',
  bankNotifications: 'Ghi từ thông báo ngân hàng',
};

export const DEFAULT_MAINTENANCE_MESSAGE = 'Ứng dụng đang bảo trì để nâng cấp hệ thống. Dữ liệu của bạn vẫn an toàn, vui lòng quay lại sau ít phút.';

const DEFS: Def[] = [
  { section: 'general', field: 'appName', kind: 'string', required: true, maxLen: 50, def: () => 'Thu Chi' },
  { section: 'general', field: 'supportEmail', kind: 'string', maxLen: 120, format: 'email', def: () => '' },
  { section: 'general', field: 'hotline', kind: 'string', maxLen: 20, format: 'phone', def: () => '' },
  { section: 'general', field: 'termsUrl', kind: 'string', maxLen: 300, format: 'https', def: () => '' },
  { section: 'general', field: 'privacyUrl', kind: 'string', maxLen: 300, format: 'https', def: () => '' },

  { section: 'access', field: 'registrationEnabled', kind: 'bool', def: () => true },
  { section: 'access', field: 'sessionDays', kind: 'int', min: 1, max: 365, def: (e) => e.jwtDays },
  { section: 'access', field: 'loginMaxAttempts', kind: 'int', min: 1, max: 1000, def: (e) => e.loginLimit },
  { section: 'access', field: 'loginWindowMinutes', kind: 'int', min: 1, max: 60, def: () => 1 },
  { section: 'access', field: 'maintenanceMessage', kind: 'string', required: true, maxLen: 200, def: () => DEFAULT_MAINTENANCE_MESSAGE },
  { section: 'access', field: 'maintenanceEndsAt', kind: 'datetime', def: () => null },
  { section: 'access', field: 'maintenanceEnabled', kind: 'bool', internal: true, def: () => false },
  { section: 'access', field: 'maintenanceStartedAt', kind: 'datetime', internal: true, def: () => null },

  { section: 'smtp', field: 'host', kind: 'string', maxLen: 200, def: (e) => e.smtpHost },
  { section: 'smtp', field: 'port', kind: 'int', min: 1, max: 65535, def: (e) => e.smtpPort },
  { section: 'smtp', field: 'security', kind: 'enum', values: ['starttls', 'ssl', 'none'], def: (e) => (e.smtpSecure ? 'ssl' : 'starttls') },
  { section: 'smtp', field: 'user', kind: 'string', maxLen: 200, def: (e) => e.smtpUser },
  { section: 'smtp', field: 'password', kind: 'string', maxLen: 500, secret: true, def: (e) => e.smtpPass },
  { section: 'smtp', field: 'from', kind: 'string', maxLen: 200, format: 'from', def: (e) => e.smtpFrom },

  { section: 'password', field: 'minLength', kind: 'int', min: 6, max: 64, def: () => 6 },
  { section: 'password', field: 'otpExpiryMinutes', kind: 'int', min: 1, max: 60, def: () => 10 },
  { section: 'password', field: 'otpMaxAttempts', kind: 'int', min: 1, max: 10, def: () => 5 },
  { section: 'password', field: 'otpResendSeconds', kind: 'int', min: 30, max: 600, def: () => 60 },

  { section: 'business', field: 'budgetWarningPercent', kind: 'int', min: 10, max: 100, def: () => 80 },
  { section: 'business', field: 'budgetExceededPercent', kind: 'int', min: 50, max: 200, def: () => 100 },
  { section: 'business', field: 'defaultWalletName', kind: 'string', required: true, maxLen: 100, def: () => 'Tiền mặt' },
  ...(Object.values(FEATURE_FIELDS).map((field) => ({ section: 'business', field, kind: 'bool', def: () => true })) as Def[]),

  { section: 'mobile', field: 'androidLatestVersion', kind: 'string', required: true, format: 'version', def: () => '1.0.0' },
  { section: 'mobile', field: 'androidMinVersion', kind: 'string', required: true, format: 'version', def: () => '1.0.0' },
  { section: 'mobile', field: 'androidStoreUrl', kind: 'string', maxLen: 300, format: 'https', def: () => '' },
  { section: 'mobile', field: 'iosLatestVersion', kind: 'string', required: true, format: 'version', def: () => '1.0.0' },
  { section: 'mobile', field: 'iosMinVersion', kind: 'string', required: true, format: 'version', def: () => '1.0.0' },
  { section: 'mobile', field: 'iosStoreUrl', kind: 'string', maxLen: 300, format: 'https', def: () => '' },
  { section: 'mobile', field: 'releaseNotes', kind: 'string', maxLen: 300, def: () => '' },

  // Trợ lý AI. `ai.enabled` và `business.featureAi` là CÙNG MỘT công tắc (sửa trường nào cũng ghi cả hai).
  // Tắt => route ghi của /ai trả 403 FEATURE_DISABLED.
  // provider: env AI_PROVIDER ghi đè; NODE_ENV=test luôn dùng fake (e2e nhanh, tất định).
  { section: 'ai', field: 'enabled', kind: 'bool', def: () => true },
  { section: 'ai', field: 'provider', kind: 'enum', values: ['ollama', 'fake'], def: (e) => e.aiProvider },
  { section: 'ai', field: 'ollamaUrl', kind: 'string', required: true, maxLen: 300, format: 'url', def: (e) => e.ollamaUrl },
  { section: 'ai', field: 'chatModel', kind: 'string', required: true, maxLen: 100, def: (e) => e.aiChatModel },
  { section: 'ai', field: 'embedModel', kind: 'string', required: true, maxLen: 100, def: (e) => e.aiEmbedModel },
  { section: 'ai', field: 'timeoutSeconds', kind: 'int', min: 5, max: 600, def: () => 15 },
  { section: 'ai', field: 'dailyMessageLimitPerUser', kind: 'int', min: 1, max: 100000, def: () => 30 },
  { section: 'ai', field: 'maxConversationsPerUser', kind: 'int', min: 1, max: 10000, def: () => 50 },
  // Ngưỡng tự bật luật / ví dụ CHUNG do chu trình học ban đêm đề xuất (không đạt => chờ admin duyệt)
  { section: 'ai', field: 'autoApproveEnabled', kind: 'bool', def: () => true },
  { section: 'ai', field: 'autoApproveMinUsers', kind: 'int', min: 5, max: 100000, def: () => 50 },
  { section: 'ai', field: 'autoApproveMinSupport', kind: 'int', min: 1, max: 100000, def: () => 50 },
  { section: 'ai', field: 'autoApproveMinPrecision', kind: 'int', min: 50, max: 100, def: () => 97 },
];

const keyOf = (d: Pick<Def, 'section' | 'field'>) => `${d.section}.${d.field}`;
const DEF_BY_KEY = new Map(DEFS.map((d) => [keyOf(d), d]));
export const SECRET_MASK = '••••';
const CACHE_TTL_MS = 15_000;

const EMAIL_RE = /^[^\s@<>]+@[^\s@<>]+\.[^\s@<>]+$/;
const VERSION_RE = /^\d{1,4}\.\d{1,4}\.\d{1,4}$/;
const PHONE_RE = /^\+?[0-9][0-9 .-]{4,18}[0-9]$/;
const FROM_RE = /^(?:[^<>]{1,100}<[^\s@<>]+@[^\s@<>]+\.[^\s@<>]+>|[^\s@<>]+@[^\s@<>]+\.[^\s@<>]+)$/;

function cmpVersion(a: string, b: string) {
  const pa = a.split('.').map(Number), pb = b.split('.').map(Number);
  for (let i = 0; i < 3; i++) if (pa[i] !== pb[i]) return pa[i] - pb[i];
  return 0;
}

/** Kiểm tra 1 giá trị theo định nghĩa; trả câu lỗi tiếng Việt hoặc null. Giá trị hợp lệ được chuẩn hóa vào `out`. */
function validateValue(d: Def, raw: unknown, out: { value?: unknown }): string | null {
  switch (d.kind) {
    case 'bool':
      if (typeof raw !== 'boolean') return 'Phải là true hoặc false';
      out.value = raw;
      return null;
    case 'int':
      if (typeof raw !== 'number' || !Number.isInteger(raw)) return 'Phải là số nguyên';
      if (raw < d.min! || raw > d.max!) return `Phải từ ${d.min} đến ${d.max}`;
      out.value = raw;
      return null;
    case 'enum':
      if (typeof raw !== 'string' || !d.values!.includes(raw)) return `Phải là một trong: ${d.values!.join(', ')}`;
      out.value = raw;
      return null;
    case 'datetime': {
      if (raw === null || raw === '') { out.value = null; return null; }
      if (typeof raw !== 'string' || Number.isNaN(Date.parse(raw))) return 'Thời gian không hợp lệ';
      out.value = new Date(raw).toISOString();
      return null;
    }
    case 'string': {
      if (typeof raw !== 'string') return 'Phải là chuỗi';
      const v = d.secret ? raw : raw.trim();
      if (d.required && !v) return 'Không được để trống';
      if (d.maxLen && v.length > d.maxLen) return `Tối đa ${d.maxLen} ký tự`;
      if (v && d.format === 'email' && !EMAIL_RE.test(v)) return 'Email không hợp lệ';
      if (v && d.format === 'https' && !/^https:\/\/[^\s/]+\.[^\s]+$/.test(v)) return 'Link phải bắt đầu bằng https://';
      if (v && d.format === 'version' && !VERSION_RE.test(v)) return 'Phiên bản dạng x.y.z, vd 1.4.0';
      if (v && d.format === 'phone' && !PHONE_RE.test(v)) return 'Số điện thoại không hợp lệ';
      if (v && d.format === 'from' && !FROM_RE.test(v)) return 'Dạng "Tên <email@miền>" hoặc một email';
      if (v && d.format === 'url' && !/^https?:\/\/[^\s/]+(\/[^\s]*)?$/.test(v)) return 'Link phải bắt đầu bằng http:// hoặc https://';
      out.value = v;
      return null;
    }
  }
}

/* ============================== Mã hóa bí mật ============================== */

function secretKey(config: ConfigService) {
  const raw = config.get<string>('CONFIG_SECRET') || `config:${config.get<string>('JWT_SECRET') ?? ''}`;
  return createHash('sha256').update(raw).digest();
}

function encrypt(key: Buffer, plain: string) {
  const iv = randomBytes(12);
  const c = createCipheriv('aes-256-gcm', key, iv);
  const ct = Buffer.concat([c.update(plain, 'utf8'), c.final()]);
  return `v1:${iv.toString('base64')}:${c.getAuthTag().toString('base64')}:${ct.toString('base64')}`;
}

function decrypt(key: Buffer, enc: string) {
  const [v, iv, tag, ct] = enc.split(':');
  if (v !== 'v1') throw new Error('Định dạng bí mật không hỗ trợ');
  const d = createDecipheriv('aes-256-gcm', key, Buffer.from(iv, 'base64'));
  d.setAuthTag(Buffer.from(tag, 'base64'));
  return Buffer.concat([d.update(Buffer.from(ct, 'base64')), d.final()]).toString('utf8');
}

/* ============================== Service ============================== */

export interface SmtpConfig {
  host: string;
  port: number;
  security: 'starttls' | 'ssl' | 'none';
  user: string;
  password: string;
  from: string;
}

interface Row {
  key: string;
  value: Prisma.JsonValue;
  updatedAt: Date;
  updatedById: string | null;
  updatedByName: string | null;
}

interface Snapshot {
  at: number;
  values: Map<string, unknown>;
  rows: Map<string, Row>;
}

export interface Actor {
  id: string;
  name: string;
  email: string;
}

@Injectable()
export class SystemConfigService {
  private readonly logger = new Logger('SystemConfig');
  private readonly env: EnvDefaults;
  private readonly key: Buffer;
  private cache?: Snapshot;
  private loading?: Promise<Snapshot>;
  private transport?: { sig: string; t: nodemailer.Transporter };

  constructor(private readonly prisma: PrismaService, private readonly config: ConfigService) {
    const test = config.get('NODE_ENV') === 'test';
    const jwt = /^(\d+)d$/.exec(config.get<string>('JWT_EXPIRES_IN') ?? '30d');
    this.env = {
      test,
      smtpHost: config.get<string>('SMTP_HOST') ?? '',
      smtpPort: Number(config.get('SMTP_PORT') ?? 587),
      smtpSecure: config.get('SMTP_SECURE') === 'true',
      smtpUser: config.get<string>('SMTP_USER') ?? '',
      smtpPass: config.get<string>('SMTP_PASS') ?? '',
      smtpFrom: config.get<string>('SMTP_FROM') ?? '',
      jwtDays: jwt ? Math.min(365, Math.max(1, Number(jwt[1]))) : 30,
      loginLimit: Number(config.get('THROTTLE_AUTH_LIMIT') ?? (test ? 200 : 10)),
      aiProvider: config.get<string>('AI_PROVIDER') === 'fake' || test ? 'fake' : 'ollama',
      ollamaUrl: config.get<string>('OLLAMA_URL') || 'http://localhost:11434',
      aiChatModel: config.get<string>('AI_CHAT_MODEL') || 'qwen3.5:4b',
      aiEmbedModel: config.get<string>('AI_EMBED_MODEL') || 'bge-m3',
    };
    this.key = secretKey(config);
  }

  /* ---------- đọc (cache ngắn hạn) ---------- */

  invalidate() {
    this.cache = undefined;
  }

  private async snapshot(): Promise<Snapshot> {
    if (this.cache && Date.now() - this.cache.at < CACHE_TTL_MS) return this.cache;
    if (!this.loading) {
      this.loading = (async () => {
        const rows = await this.prisma.systemSetting.findMany();
        const byKey = new Map(rows.map((r) => [r.key, r]));
        const values = new Map<string, unknown>();
        for (const d of DEFS) {
          const k = keyOf(d);
          const row = byKey.get(k);
          let v: unknown = row ? row.value : d.def(this.env);
          if (row && d.secret && typeof v === 'string' && v) {
            try {
              v = decrypt(this.key, v);
            } catch (e) {
              this.logger.error(`Không giải mã được ${k} (đổi CONFIG_SECRET?): ${(e as Error).message}`);
              v = '';
            }
          }
          values.set(k, v);
        }
        const snap = { at: Date.now(), values, rows: byKey };
        this.cache = snap;
        return snap;
      })().finally(() => (this.loading = undefined));
    }
    return this.loading;
  }

  async get<T = unknown>(key: string): Promise<T> {
    return (await this.snapshot()).values.get(key) as T;
  }

  /** Trạng thái bảo trì hiệu lực: hết `endsAt` => coi như tắt ngay và ghi tắt vào DB (lịch sử: hệ thống). */
  async maintenance() {
    const s = await this.snapshot();
    const enabled = s.values.get('access.maintenanceEnabled') === true;
    const endsAt = (s.values.get('access.maintenanceEndsAt') as string | null) ?? null;
    if (enabled && endsAt && Date.parse(endsAt) <= Date.now()) {
      this.autoOff().catch((e) => this.logger.error(`Tự tắt bảo trì lỗi: ${(e as Error).message}`));
      return { enabled: false, message: s.values.get('access.maintenanceMessage') as string, endsAt: null, startedAt: null, startedBy: null };
    }
    const started = s.rows.get('access.maintenanceEnabled');
    return {
      enabled,
      message: s.values.get('access.maintenanceMessage') as string,
      endsAt,
      startedAt: enabled ? ((s.values.get('access.maintenanceStartedAt') as string | null) ?? started?.updatedAt.toISOString() ?? null) : null,
      startedBy: enabled ? (started?.updatedByName ?? null) : null,
    };
  }

  /** Ném 503 MAINTENANCE nếu đang bảo trì và người dùng không phải ADMIN. */
  async assertNotMaintenance(role: Role) {
    if (role === 'ADMIN') return;
    const m = await this.maintenance();
    if (m.enabled) {
      throw new ServiceUnavailableException({ statusCode: 503, code: 'MAINTENANCE', message: m.message, endsAt: m.endsAt });
    }
  }

  async featureEnabled(f: FeatureName) {
    if (f === 'ai' && (await this.get<boolean>('ai.enabled')) === false) return false;
    return (await this.get<boolean>(`business.${FEATURE_FIELDS[f]}`)) !== false;
  }

  /** Cấu hình trợ lý AI đang hiệu lực (provider: env AI_PROVIDER ghi đè, NODE_ENV=test => fake). */
  async ai() {
    const s = await this.snapshot();
    const v = (f: string) => s.values.get(`ai.${f}`);
    const envProvider = this.config.get<string>('AI_PROVIDER');
    return {
      enabled: (await this.featureEnabled('ai')),
      provider: (envProvider === 'fake' || envProvider === 'ollama' ? envProvider : this.env.test ? 'fake' : v('provider')) as 'ollama' | 'fake',
      ollamaUrl: v('ollamaUrl') as string,
      chatModel: v('chatModel') as string,
      embedModel: v('embedModel') as string,
      timeoutMs: (v('timeoutSeconds') as number) * 1000,
      dailyMessageLimitPerUser: v('dailyMessageLimitPerUser') as number,
      maxConversationsPerUser: v('maxConversationsPerUser') as number,
      autoApprove: {
        enabled: v('autoApproveEnabled') as boolean,
        minUsers: v('autoApproveMinUsers') as number,
        minSupport: v('autoApproveMinSupport') as number,
        minPrecision: (v('autoApproveMinPrecision') as number) / 100,
      },
    };
  }

  async assertFeature(f: FeatureName) {
    if (!(await this.featureEnabled(f))) {
      throw new ForbiddenException({ statusCode: 403, code: 'FEATURE_DISABLED', feature: f, message: `Tính năng "${FEATURE_LABELS[f]}" đang tạm tắt` });
    }
  }

  async budgetThresholds() {
    const s = await this.snapshot();
    return { warningPercent: s.values.get('business.budgetWarningPercent') as number, exceededPercent: s.values.get('business.budgetExceededPercent') as number };
  }

  async otp() {
    const s = await this.snapshot();
    return {
      expiryMinutes: s.values.get('password.otpExpiryMinutes') as number,
      maxAttempts: s.values.get('password.otpMaxAttempts') as number,
      resendSeconds: s.values.get('password.otpResendSeconds') as number,
    };
  }

  /** Admin đã đặt => "<n>d"; chưa đặt => giữ JWT_EXPIRES_IN của env (hành vi cũ). */
  async jwtExpiresIn(): Promise<string> {
    const s = await this.snapshot();
    return s.rows.has('access.sessionDays') ? `${s.values.get('access.sessionDays')}d` : (this.config.get<string>('JWT_EXPIRES_IN') ?? '30d');
  }

  async loginLimit() {
    const s = await this.snapshot();
    return { limit: s.values.get('access.loginMaxAttempts') as number, ttlMs: (s.values.get('access.loginWindowMinutes') as number) * 60_000 };
  }

  async smtp(): Promise<SmtpConfig> {
    const s = await this.snapshot();
    const v = (f: string) => s.values.get(`smtp.${f}`);
    return { host: v('host') as string, port: v('port') as number, security: v('security') as SmtpConfig['security'], user: v('user') as string, password: v('password') as string, from: v('from') as string };
  }

  /** Transport theo cấu hình SMTP đã lưu (DB, fallback env); host trống => null (OTP ghi log). */
  async mailer(): Promise<{ transport: nodemailer.Transporter; from: string; config: SmtpConfig } | null> {
    const c = await this.smtp();
    if (!c.host) return null;
    const sig = JSON.stringify(c);
    if (this.transport?.sig !== sig) {
      this.transport?.t.close();
      this.transport = {
        sig,
        t: nodemailer.createTransport({
          host: c.host,
          port: c.port,
          secure: c.security === 'ssl',
          ignoreTLS: c.security === 'none',
          auth: c.user ? { user: c.user, pass: c.password } : undefined,
          connectionTimeout: 15_000,
          greetingTimeout: 10_000,
          socketTimeout: 20_000,
        }),
      };
    }
    return { transport: this.transport.t, from: c.from || c.user, config: c };
  }

  /* ---------- API công khai cho app ---------- */

  async publicConfig() {
    const s = await this.snapshot();
    const v = (k: string) => s.values.get(k);
    const m = await this.maintenance();
    return {
      appName: v('general.appName'),
      supportEmail: v('general.supportEmail') || null,
      hotline: v('general.hotline') || null,
      termsUrl: v('general.termsUrl') || null,
      privacyUrl: v('general.privacyUrl') || null,
      currency: 'VND',
      registrationEnabled: v('access.registrationEnabled'),
      maintenance: { enabled: m.enabled, message: m.enabled ? m.message : null, endsAt: m.enabled ? m.endsAt : null },
      // Trợ lý AI có khối riêng `ai` bên dưới (bật = ai.enabled && business.featureAi)
      features: Object.fromEntries((Object.keys(FEATURE_FIELDS) as FeatureName[]).filter((f) => f !== 'ai').map((f) => [f, v(`business.${FEATURE_FIELDS[f]}`) !== false])),
      ai: {
        enabled: v('ai.enabled') !== false && v('business.featureAi') !== false,
        dailyMessageLimitPerUser: v('ai.dailyMessageLimitPerUser'),
        maxConversationsPerUser: v('ai.maxConversationsPerUser'),
      },
      budget: { warningPercent: v('business.budgetWarningPercent'), exceededPercent: v('business.budgetExceededPercent') },
      password: { minLength: v('password.minLength') },
      otp: { expiryMinutes: v('password.otpExpiryMinutes'), resendSeconds: v('password.otpResendSeconds') },
      mobile: {
        android: { latestVersion: v('mobile.androidLatestVersion'), minVersion: v('mobile.androidMinVersion'), storeUrl: v('mobile.androidStoreUrl') || null },
        ios: { latestVersion: v('mobile.iosLatestVersion'), minVersion: v('mobile.iosMinVersion'), storeUrl: v('mobile.iosStoreUrl') || null },
        releaseNotes: v('mobile.releaseNotes') || null,
      },
    };
  }

  /* ---------- API admin ---------- */

  async adminView() {
    const s = await this.snapshot();
    const values: Record<string, Record<string, unknown>> = Object.fromEntries(SECTIONS.map((x) => [x, {}]));
    for (const d of DEFS) {
      if (d.internal || d.secret) continue;
      values[d.section][d.field] = s.values.get(keyOf(d));
    }
    const pwRow = s.rows.get('smtp.password');
    const hasPassword = !!s.values.get('smtp.password');
    values.smtp.hasPassword = hasPassword;
    const updated: Record<string, { at: Date; by: string | null }> = {};
    for (const r of s.rows.values()) if (!DEF_BY_KEY.get(r.key)?.internal) updated[r.key] = { at: r.updatedAt, by: r.updatedByName };
    const [last, activeUsers, savingGoals, recurringRules] = await Promise.all([
      this.prisma.systemConfigChange.findFirst({ where: { actorId: { not: null } }, orderBy: { createdAt: 'desc' } }),
      this.prisma.user.count({ where: { status: 'ACTIVE', role: 'USER' } }),
      this.prisma.savingGoal.count(),
      this.prisma.recurringRule.count(),
    ]);
    return {
      values,
      maintenance: await this.maintenance(),
      smtp: {
        configured: !!s.values.get('smtp.host'),
        hasPassword,
        passwordSavedAt: hasPassword && pwRow ? pwRow.updatedAt : null,
        passwordSavedBy: hasPassword && pwRow ? pwRow.updatedByName : null,
        /** db: đã lưu trong cấu hình; env: lấy từ SMTP_* của máy chủ; none: chưa cấu hình */
        source: [...s.rows.keys()].some((k) => k.startsWith('smtp.')) ? 'db' : this.env.smtpHost ? 'env' : 'none',
      },
      updated,
      lastSaved: last ? { at: last.createdAt, by: last.actorName } : null,
      stats: { activeUsers, savingGoals, recurringRules },
    };
  }

  /**
   * PATCH: body dạng `{ general: { appName: "..." }, smtp: { password: "..." } }`, chỉ gửi trường đổi.
   * Kiểm tra từng trường + ràng buộc chéo (trên trạng thái sau khi gộp); lỗi => 400 kèm `errors` theo "section.field".
   */
  async update(actor: Actor, body: unknown) {
    if (!body || typeof body !== 'object' || Array.isArray(body)) throw new BadRequestException('Body phải là object');
    const errors: Record<string, string> = {};
    const changes = new Map<string, unknown>();
    for (const [section, fields] of Object.entries(body as Record<string, unknown>)) {
      if (!SECTIONS.includes(section as Section)) { errors[section] = 'Không có mục cấu hình này'; continue; }
      if (!fields || typeof fields !== 'object' || Array.isArray(fields)) { errors[section] = 'Phải là object'; continue; }
      for (const [field, raw] of Object.entries(fields as Record<string, unknown>)) {
        const k = `${section}.${field}`;
        const d = DEF_BY_KEY.get(k);
        if (!d || d.internal) { errors[k] = d?.internal ? 'Dùng endpoint bảo trì để bật/tắt' : 'Không có cấu hình này'; continue; }
        const out: { value?: unknown } = {};
        const err = validateValue(d, raw, out);
        if (err) errors[k] = err;
        else changes.set(k, out.value);
      }
    }
    const s = await this.snapshot();
    const merged = (k: string) => (changes.has(k) ? changes.get(k) : s.values.get(k));
    const touched = (...ks: string[]) => ks.some((k) => changes.has(k));
    const cross = (k: string, msg: string) => { if (!errors[k]) errors[k] = msg; };
    if (touched('business.budgetWarningPercent', 'business.budgetExceededPercent') && (merged('business.budgetWarningPercent') as number) >= (merged('business.budgetExceededPercent') as number)) {
      cross(changes.has('business.budgetWarningPercent') ? 'business.budgetWarningPercent' : 'business.budgetExceededPercent', 'Ngưỡng cảnh báo phải nhỏ hơn ngưỡng vượt');
    }
    if (touched('password.otpResendSeconds', 'password.otpExpiryMinutes') && (merged('password.otpResendSeconds') as number) >= (merged('password.otpExpiryMinutes') as number) * 60) {
      cross(changes.has('password.otpResendSeconds') ? 'password.otpResendSeconds' : 'password.otpExpiryMinutes', 'Thời gian chờ gửi lại phải ngắn hơn thời hạn mã');
    }
    for (const p of ['android', 'ios']) {
      const lk = `mobile.${p}LatestVersion`, mk = `mobile.${p}MinVersion`;
      if (touched(lk, mk) && !errors[lk] && !errors[mk] && cmpVersion(merged(mk) as string, merged(lk) as string) > 0) {
        cross(changes.has(mk) ? mk : lk, 'Bản tối thiểu không được mới hơn bản mới nhất');
      }
    }
    // Một công tắc AI: ai.enabled ⇔ business.featureAi
    if (changes.has('ai.enabled') && changes.has('business.featureAi') && changes.get('ai.enabled') !== changes.get('business.featureAi')) {
      cross('ai.enabled', 'ai.enabled và business.featureAi là cùng một công tắc, phải cùng giá trị');
    } else if (changes.has('ai.enabled')) changes.set('business.featureAi', changes.get('ai.enabled'));
    else if (changes.has('business.featureAi')) changes.set('ai.enabled', changes.get('business.featureAi'));
    if (changes.has('access.maintenanceEndsAt')) {
      const v = changes.get('access.maintenanceEndsAt') as string | null;
      if (v && Date.parse(v) <= Date.now()) cross('access.maintenanceEndsAt', 'Giờ dự kiến xong phải ở tương lai');
    }
    if (Object.keys(errors).length) {
      throw new BadRequestException({ statusCode: 400, message: 'Cấu hình không hợp lệ', errors });
    }
    // Bỏ các trường không đổi (so với giá trị hiệu lực)
    for (const [k, v] of [...changes]) if (s.values.get(k) === v) changes.delete(k);
    if (changes.size) await this.write(actor, changes);
    return this.adminView();
  }

  /** Ghi các thay đổi + lịch sử trong 1 transaction, rồi xóa cache. actor null = hệ thống. */
  private async write(actor: Actor | null, changes: Map<string, unknown>, opts: { history?: boolean } = {}) {
    const s = await this.snapshot();
    await this.prisma.$transaction(async (db) => {
      for (const [k, v] of changes) {
        const d = DEF_BY_KEY.get(k)!;
        const stored = (d.secret && typeof v === 'string' && v ? encrypt(this.key, v) : v) as Prisma.InputJsonValue;
        const data = { value: stored ?? Prisma.JsonNull, updatedById: actor?.id ?? null, updatedByName: actor?.name ?? null };
        await db.systemSetting.upsert({ where: { key: k }, create: { key: k, ...data }, update: data });
        if (opts.history === false || d.field === 'maintenanceStartedAt') continue;
        const old = s.values.get(k);
        await db.systemConfigChange.create({
          data: {
            actorId: actor?.id ?? null,
            actorName: actor?.name ?? null,
            actorEmail: actor?.email ?? null,
            section: d.section,
            key: d.field,
            oldValue: (d.secret ? SECRET_MASK : old ?? Prisma.JsonNull) as Prisma.InputJsonValue,
            newValue: (d.secret ? SECRET_MASK : v ?? Prisma.JsonNull) as Prisma.InputJsonValue,
            secret: !!d.secret,
          },
        });
      }
    });
    this.invalidate();
  }

  /** Bật / tắt bảo trì ngay (không qua thanh Lưu). Bật: lưu luôn nội dung + giờ dự kiến xong gửi kèm. */
  async setMaintenance(actor: Actor, dto: { enabled: boolean; message?: string; endsAt?: string | null }) {
    const errors: Record<string, string> = {};
    const changes = new Map<string, unknown>();
    const s = await this.snapshot();
    const current = await this.maintenance();
    if (dto.enabled) {
      if (dto.message !== undefined) {
        const out: { value?: unknown } = {};
        const e = validateValue(DEF_BY_KEY.get('access.maintenanceMessage')!, dto.message, out);
        if (e) errors['access.maintenanceMessage'] = e;
        else changes.set('access.maintenanceMessage', out.value);
      }
      if (dto.endsAt !== undefined) {
        const out: { value?: unknown } = {};
        const e = validateValue(DEF_BY_KEY.get('access.maintenanceEndsAt')!, dto.endsAt, out);
        if (e) errors['access.maintenanceEndsAt'] = e;
        else changes.set('access.maintenanceEndsAt', out.value);
      }
      const endsAt = (changes.has('access.maintenanceEndsAt') ? changes.get('access.maintenanceEndsAt') : s.values.get('access.maintenanceEndsAt')) as string | null;
      if (!errors['access.maintenanceEndsAt'] && endsAt && Date.parse(endsAt) <= Date.now()) errors['access.maintenanceEndsAt'] = 'Giờ dự kiến xong phải ở tương lai';
      if (Object.keys(errors).length) throw new BadRequestException({ statusCode: 400, message: 'Cấu hình không hợp lệ', errors });
      if (!current.enabled) {
        changes.set('access.maintenanceEnabled', true);
        changes.set('access.maintenanceStartedAt', new Date().toISOString());
      }
    } else if (current.enabled || s.values.get('access.maintenanceEnabled') === true) {
      changes.set('access.maintenanceEnabled', false);
      changes.set('access.maintenanceStartedAt', null);
      if (s.values.get('access.maintenanceEndsAt')) changes.set('access.maintenanceEndsAt', null);
    }
    for (const [k, v] of [...changes]) if (s.values.get(k) === v) changes.delete(k);
    if (changes.size) await this.write(actor, changes);
    return this.maintenance();
  }

  /** Hết giờ dự kiến => tự tắt. updateMany có điều kiện => nhiều instance / gọi đồng thời chỉ ghi lịch sử 1 lần. */
  async autoOff(now = new Date()) {
    const row = await this.prisma.systemSetting.findUnique({ where: { key: 'access.maintenanceEndsAt' } });
    const endsAt = row?.value as string | null | undefined;
    if (!endsAt || Date.parse(endsAt) > now.getTime()) return false;
    const done = await this.prisma.$transaction(async (db) => {
      const { count } = await db.systemSetting.updateMany({
        where: { key: 'access.maintenanceEnabled', value: { equals: true } },
        data: { value: false, updatedById: null, updatedByName: null },
      });
      if (!count) return false;
      await db.systemSetting.updateMany({ where: { key: { in: ['access.maintenanceEndsAt', 'access.maintenanceStartedAt'] } }, data: { value: Prisma.JsonNull, updatedById: null, updatedByName: null } });
      await db.systemConfigChange.createMany({
        data: [
          { section: 'access', key: 'maintenanceEnabled', oldValue: true, newValue: false },
          { section: 'access', key: 'maintenanceEndsAt', oldValue: endsAt, newValue: Prisma.JsonNull },
        ],
      });
      return true;
    });
    this.invalidate();
    if (done) this.logger.log(`Tự tắt bảo trì (dự kiến xong ${endsAt})`);
    return done;
  }

  @Cron('* * * * *')
  async tick() {
    await this.autoOff().catch((e) => this.logger.error(`Tự tắt bảo trì lỗi: ${(e as Error).message}`));
  }

  async history(q: HistoryQuery) {
    const where = { section: q.section };
    const [items, total] = await this.prisma.$transaction([
      this.prisma.systemConfigChange.findMany({ where, orderBy: [{ createdAt: 'desc' }, { id: 'asc' }], skip: (q.page - 1) * q.limit, take: q.limit }),
      this.prisma.systemConfigChange.count({ where }),
    ]);
    const bySection = await this.prisma.systemConfigChange.groupBy({ by: ['section'], _count: true });
    return {
      ...paged(
        items.map((c) => ({
          id: c.id,
          createdAt: c.createdAt,
          section: c.section,
          key: c.key,
          secret: c.secret,
          oldValue: c.secret ? SECRET_MASK : c.oldValue,
          newValue: c.secret ? SECRET_MASK : c.newValue,
          actor: c.actorId ? { id: c.actorId, name: c.actorName, email: c.actorEmail } : null,
        })),
        total,
        q,
      ),
      counts: Object.fromEntries(bySection.map((r) => [r.section, r._count])),
    };
  }

  /** Gửi thư thử tới email của admin bằng cấu hình đã lưu. Không ném lỗi SMTP: trả `{ok:false, error}` để UI hiện. */
  async testSmtp(actor: Actor) {
    const m = await this.mailer();
    if (!m) throw new BadRequestException('Chưa cấu hình SMTP (máy chủ gửi thư đang trống)');
    const started = Date.now();
    const appName = await this.get<string>('general.appName');
    try {
      const info = await m.transport.sendMail({
        from: m.from,
        to: actor.email,
        subject: `[${appName}] Email thử cấu hình SMTP`,
        text: `Email thử từ trang quản trị ${appName}. Nếu bạn nhận được thư này, cấu hình SMTP đang hoạt động.`,
      });
      return { ok: true, to: actor.email, at: new Date(), durationMs: Date.now() - started, response: String(info.response ?? '').slice(0, 200) };
    } catch (e) {
      const err = e as Error & { code?: string; responseCode?: number; response?: string };
      const detail = [err.code, err.responseCode, err.response ?? err.message].filter(Boolean).join(' · ');
      return { ok: false, to: actor.email, at: new Date(), durationMs: Date.now() - started, error: detail.slice(0, 300) };
    }
  }
}

/* ============================== Controllers ============================== */

class HistoryQuery extends PageQuery {
  @IsOptional() @IsIn(SECTIONS) section?: Section;
}

class MaintenanceDto {
  @IsBoolean() enabled: boolean;
  /** Nội dung người dùng thấy (1–200 ký tự) */
  @IsOptional() @IsString() message?: string;
  /** ISO, tương lai; null = không hẹn giờ (chỉ tắt tay). Tới giờ => tự tắt */
  @IsOptional() endsAt?: string | null;
}

const PATCH_SCHEMA = {
  type: 'object',
  description: 'Chỉ gửi các trường đổi. Lỗi => 400 `{message, errors: {"section.field": "lý do"}}`',
  properties: Object.fromEntries(
    SECTIONS.map((sec) => [
      sec,
      {
        type: 'object',
        properties: Object.fromEntries(
          DEFS.filter((d) => d.section === sec && !d.internal).map((d) => [
            d.field,
            {
              type: d.kind === 'int' ? 'integer' : d.kind === 'bool' ? 'boolean' : 'string',
              ...(d.kind === 'datetime' ? { format: 'date-time', nullable: true } : {}),
              ...(d.values ? { enum: [...d.values] } : {}),
              ...(d.min !== undefined ? { minimum: d.min, maximum: d.max } : {}),
              ...(d.maxLen ? { maxLength: d.maxLen } : {}),
              ...(d.format ? { description: d.format } : {}),
              ...(d.secret ? { description: 'Bí mật: chỉ ghi, không bao giờ trả về. Chuỗi rỗng = xóa' } : {}),
            },
          ]),
        ),
      },
    ]),
  ),
};

function actorOf(u: AuthUser): Actor {
  return { id: u.id, email: u.email, name: u.name || u.email };
}

@ApiTags('config')
@Controller('config')
export class PublicConfigController {
  constructor(private readonly sys: SystemConfigService) {}

  /** Công khai (không cần token, chạy cả khi bảo trì): app đọc khi khởi động / định kỳ */
  @Public() @Get('public')
  publicConfig() {
    return this.sys.publicConfig();
  }
}

@ApiTags('admin config')
@ApiBearerAuth()
@Roles('ADMIN')
@Controller('admin/config')
export class AdminConfigController {
  constructor(private readonly sys: SystemConfigService) {}

  /** Mọi cấu hình theo mục; mật khẩu SMTP không bao giờ trả về (chỉ `smtp.hasPassword`, `passwordSavedAt/By`) */
  @Get()
  get() {
    return this.sys.adminView();
  }

  /** Sửa một phần, kiểm tra hợp lệ, ghi lịch sử từng trường; trả trạng thái mới */
  @Patch() @ApiBody({ schema: PATCH_SCHEMA })
  update(@CurrentUser() u: AuthUser, @Body() body: Record<string, unknown>) {
    return this.sys.update(actorOf(u), body);
  }

  /** Lịch sử thay đổi (mới nhất trước), lọc theo mục; giá trị bí mật luôn là "••••" */
  @Get('history')
  history(@Query() q: HistoryQuery) {
    return this.sys.history(q);
  }

  /** Bật/tắt bảo trì ngay. User thường nhận 503 {code:'MAINTENANCE'} (kể cả đăng nhập); admin không bị chặn. Tới `endsAt` tự tắt */
  @Post('maintenance') @HttpCode(200)
  maintenance(@CurrentUser() u: AuthUser, @Body() dto: MaintenanceDto) {
    return this.sys.setMaintenance(actorOf(u), dto);
  }

  /** Gửi email thử tới email của admin đang đăng nhập bằng cấu hình đã lưu → `{ok, response | error, durationMs}`. Giới hạn 5 lần/phút */
  @Post('smtp/test') @HttpCode(200) @UseGuards(AppThrottlerGuard) @ApiTooManyRequestsResponse()
  testSmtp(@CurrentUser() u: AuthUser) {
    return this.sys.testSmtp(actorOf(u));
  }
}

@Global()
@Module({
  controllers: [PublicConfigController, AdminConfigController],
  providers: [SystemConfigService, { provide: SYSTEM_CONFIG, useExisting: SystemConfigService }],
  exports: [SystemConfigService, SYSTEM_CONFIG],
})
export class SystemConfigModule {}
