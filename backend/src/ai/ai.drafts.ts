/**
 * Loại nháp: chuẩn hóa payload của skill (tên → id TRONG dữ liệu của principal) và thực thi khi xác nhận
 * qua ĐÚNG service nghiệp vụ sẵn có (cùng validate DTO, cùng cảnh báo ngân sách, cùng quyền) — AI không có đường ghi riêng.
 */
import { BadRequestException, ForbiddenException, Injectable } from '@nestjs/common';
import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { Role } from '@prisma/client';
import { CreateTransactionDto, TransactionFilter, TransactionsService } from '../transactions/transactions.module';
import { BudgetsService, CreateBudgetDto } from '../budgets/budgets.module';
import { AdminService, BroadcastDto, UserListQuery } from '../admin/admin.module';
import { CategoriesService } from '../categories/categories.module';
import { WalletsService } from '../wallets/wallets.module';
import { SystemConfigService } from '../system-config/system-config.module';
import type { FeatureName } from '../common/auth';
import { MONTH_REGEX } from '../common/time';
import type { AiRepo } from './ai.store';
import type { Principal } from './ai.types';
import { fold } from './ai.text';

interface DraftKind {
  /** Quyền cần có lúc XÁC NHẬN (đọc lại từ DB mỗi request) */
  role?: Role;
  feature?: FeatureName;
  /** Payload skill → payload lưu (đủ id + tên hiển thị). Ném 400 nếu không dùng được. */
  normalize(p: Principal, repo: AiRepo, payload: any, now: string): Promise<any>;
  execute(p: Principal, payload: any): Promise<unknown>;
}

/** Validate như ValidationPipe toàn cục (whitelist + forbidNonWhitelisted + transform). */
async function dto<T extends object>(cls: new () => T, plain: unknown, label: string): Promise<T> {
  const obj = plainToInstance(cls, plain ?? {});
  const errs = await validate(obj as object, { whitelist: true, forbidNonWhitelisted: true });
  if (errs.length) {
    const msgs = errs.flatMap((e) => Object.values(e.constraints ?? { [e.property]: `${e.property} không hợp lệ` }));
    throw new BadRequestException({ statusCode: 400, message: msgs.map((m) => `${label}: ${m}`), error: 'Bad Request' });
  }
  return obj;
}

const pick = <T extends object>(o: any, keys: (keyof T)[]) => Object.fromEntries(keys.filter((k) => o?.[k] !== undefined && o?.[k] !== null).map((k) => [k, o[k]])) as Partial<T>;

@Injectable()
export class DraftKinds {
  private readonly kinds: Record<string, DraftKind>;

  constructor(
    private readonly txs: TransactionsService,
    private readonly budgets: BudgetsService,
    private readonly admin: AdminService,
    private readonly categories: CategoriesService,
    private readonly wallets: WalletsService,
    private readonly sys: SystemConfigService,
  ) {
    this.kinds = {
      transactions: {
        normalize: async (p, repo, payload, now) => {
          const items = Array.isArray(payload?.items) ? payload.items : [];
          const [cats, ws, mem] = await Promise.all([this.categories.listForUser(p.id), this.wallets.list(p.id), repo.getMemory('wallet.default')]);
          const usable = ws.items.filter((w) => !w.isArchived);
          const byFold = <T extends { name: string }>(xs: T[], name: unknown) => (typeof name === 'string' ? xs.find((x) => fold(x.name) === fold(name)) : undefined);
          const def = byFold(usable, mem?.value) ?? usable.find((w) => w.type === 'CASH') ?? usable[0];
          const today = new Date(new Date(now).getTime() + 7 * 3600_000).toISOString().slice(0, 10);
          return {
            items: items.map((it: any) => {
              // id gửi kèm (user sửa nháp) giữ nguyên để service kiểm tra (id của người khác => 400 như API thường)
              const cat = it.categoryId ? cats.find((c) => c.id === it.categoryId) : byFold(cats, it.categoryName);
              const w = it.walletId ? usable.find((x) => x.id === it.walletId) : byFold(usable, it.walletName) ?? def;
              const date = typeof it.date === 'string' ? it.date : today;
              return {
                title: it.title,
                amount: it.amount,
                categoryId: it.categoryId ?? cat?.id ?? null,
                categoryName: cat?.name ?? null,
                type: cat?.type ?? null,
                walletId: it.walletId ?? w?.id ?? null,
                walletName: w?.name ?? null,
                walletGuessed: it.walletGuessed ?? (!it.walletId && !it.walletName),
                // hôm nay => giờ hiện tại (giữ thứ tự tự nhiên); ngày khác => 12:00 giờ VN
                occurredAt: it.occurredAt ?? (date === today ? new Date(now).toISOString() : `${date}T12:00:00+07:00`),
                date,
                ...(it.note ? { note: it.note } : {}),
                source: it.source ?? null,
                clean: it.clean ?? null,
                ruleId: it.ruleId ?? null,
              };
            }),
          };
        },
        execute: async (p, payload) => {
          const items = Array.isArray(payload?.items) ? payload.items : [];
          if (items.length < 1 || items.length > 100) throw new BadRequestException('Nháp phải có 1–100 giao dịch');
          const dtos: CreateTransactionDto[] = [];
          for (const [i, it] of items.entries()) dtos.push(await dto(CreateTransactionDto, pick<CreateTransactionDto>(it, ['categoryId', 'walletId', 'amount', 'title', 'note', 'occurredAt']), `items[${i}]`));
          return this.txs.createMany(p.id, dtos);
        },
      },
      budgets: {
        normalize: async (p, _repo, payload) => {
          const cats = await this.categories.listForUser(p.id, 'EXPENSE');
          const items = Array.isArray(payload?.items) ? payload.items : [];
          return {
            items: items.map((it: any) => {
              const cat = it.categoryId ? cats.find((c) => c.id === it.categoryId) : it.categoryName ? cats.find((c) => fold(c.name) === fold(String(it.categoryName))) : null;
              return { categoryId: it.categoryId ?? cat?.id ?? null, categoryName: cat?.name ?? null, month: it.month, limitAmount: it.limitAmount };
            }),
          };
        },
        execute: async (p, payload) => {
          const items = Array.isArray(payload?.items) ? payload.items : [];
          if (items.length < 1 || items.length > 50) throw new BadRequestException('Nháp phải có 1–50 ngân sách');
          const dtos: CreateBudgetDto[] = [];
          for (const [i, it] of items.entries()) dtos.push(await dto(CreateBudgetDto, pick<CreateBudgetDto>(it, ['categoryId', 'month', 'limitAmount']), `items[${i}]`));
          const created = [];
          for (const d of dtos) created.push(await this.budgets.create(p.id, d));
          return { created: created.length, budgets: created.map((b) => ({ id: b.id, categoryId: b.categoryId, month: b.month, limitAmount: b.limitAmount, status: b.status })) };
        },
      },
      search_filter: {
        normalize: async (_p, _repo, payload) => ({
          target: payload?.target === 'users' ? 'users' : 'transactions',
          q: typeof payload?.q === 'string' ? payload.q.slice(0, 100) : null,
          month: typeof payload?.month === 'string' && MONTH_REGEX.test(payload.month) ? payload.month : null,
        }),
        // target users (admin): tìm người dùng; transactions: giao dịch của CHÍNH người hỏi
        execute: async (p, payload) => {
          if (payload?.target === 'users') {
            if (p.role !== 'ADMIN') throw new ForbiddenException('Bạn không có quyền thực hiện nháp này');
            return this.admin.users(Object.assign(new UserListQuery(), { q: payload.q ?? undefined, page: 1, limit: 50 }));
          }
          const f = Object.assign(new TransactionFilter(), { page: 1, limit: 50, q: payload?.q ?? undefined, month: payload?.month ?? undefined });
          return this.txs.list(p.id, f);
        },
      },
      broadcast: {
        role: 'ADMIN',
        normalize: async (_p, _repo, payload) => ({ title: payload?.title, body: payload?.body }),
        execute: async (p, payload) => {
          const d = await dto(BroadcastDto, pick<BroadcastDto>(payload, ['title', 'body']), 'broadcast');
          const b = await this.admin.broadcast(p as any, d);
          return { broadcastId: b.id, recipients: b.recipients };
        },
      },
      lock_user: {
        role: 'ADMIN',
        normalize: async (_p, _repo, payload) => ({ userId: payload?.userId, email: payload?.email ?? null, name: payload?.name ?? null }),
        execute: async (p, payload) => {
          if (typeof payload?.userId !== 'string' || !/^[0-9a-f-]{36}$/i.test(payload.userId)) throw new BadRequestException('userId không hợp lệ');
          const u = await this.admin.updateUser(p as any, payload.userId, { status: 'LOCKED' });
          return { userId: u.id, email: u.email, status: u.status };
        },
      },
    };
  }

  has(kind: string) {
    return kind in this.kinds;
  }

  async normalize(p: Principal, repo: AiRepo, kind: string, payload: unknown, now: string) {
    const k = this.kinds[kind];
    if (!k) throw new BadRequestException(`Loại nháp không hỗ trợ: ${kind}`);
    return k.normalize(p, repo, payload, now);
  }

  /** Kiểm tra quyền + tính năng rồi chạy qua service nghiệp vụ. */
  async execute(p: Principal, kind: string, payload: unknown) {
    const k = this.kinds[kind];
    if (!k) throw new BadRequestException(`Loại nháp không hỗ trợ: ${kind}`);
    if (k.role && p.role !== k.role) throw new ForbiddenException('Bạn không có quyền thực hiện nháp này');
    if (k.feature) await this.sys.assertFeature(k.feature);
    return k.execute(p, payload);
  }

  /** Bản user sửa: giữ dấu vết học (source/clean/ruleId) theo thứ tự khoản của nháp gốc. */
  static withTrace(kind: string, original: any, edited: any): any {
    if (kind !== 'transactions' || !Array.isArray(edited?.items)) return edited;
    return {
      items: edited.items.map((it: any, i: number) => {
        const o = original?.items?.[i] ?? {};
        return { ...it, source: o.source ?? null, clean: o.clean ?? null, ruleId: o.ruleId ?? null, walletGuessed: o.walletGuessed ?? false, date: it.date ?? (it.occurredAt ? undefined : o.date) };
      }),
    };
  }
}
