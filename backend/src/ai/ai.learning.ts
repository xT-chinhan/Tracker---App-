/**
 * Vòng học.
 *  - NGAY (phạm vi user): xác nhận / sửa / hủy nháp, "ý tôi là…", thích/không thích → tín hiệu + ví dụ + luật + trí nhớ của CHÍNH user.
 *  - BAN ĐÊM (02:30 giờ VN, tuần tự, khóa advisory): gom luật/ví dụ của nhiều user → ẩn danh (k-ẩn danh ≥ 2 user, bỏ tên,
 *    bỏ ghi chú, tiền làm tròn) → ứng viên CHUNG → cổng kiểm định (bộ đề hồi quy trong DB)
 *    → tự bật theo ngưỡng trong Cấu hình hệ thống, còn lại chờ admin duyệt.
 */
import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { AiDraft, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { SystemConfigService } from '../system-config/system-config.module';
import { aiData, aiLib, type AiUserContext } from './ai.external';
import { GLOBAL, type AiRepo } from './ai.store';
import { accentedClean, norm, roundAmount, ruleKeys } from './ai.text';
import type { LlmClient } from './ai.types';

const ADVISORY_KEY = 7_311_001;
/** k-ẩn danh tối thiểu cho mọi ứng viên chung: ≥ 5 người khác nhau (đã đồng ý góp), kể cả khi admin hạ ngưỡng tự bật */
export const MIN_USERS_FOR_GLOBAL = 5;
/** Giữ lịch sử chat 12 tháng */
export const RETENTION_DAYS = 365;

type Verdict = 'pass' | 'fail' | 'no-coverage';
interface EvalReport { verdict: Verdict; matched: number; correct: number; source: 'db' | 'ai' }

@Injectable()
export class AiLearningService implements OnModuleInit {
  private readonly logger = new Logger('AiLearning');
  private running = false;

  constructor(private readonly prisma: PrismaService, private readonly sys: SystemConfigService) {}

  async onModuleInit() {
    // Không chặn khởi động: nạp câu mẫu router + kho ví dụ khởi đầu + bộ đề hồi quy (dữ liệu hệ thống, idempotent)
    this.seed().catch((e) => this.logger.warn(`Seed AI: ${(e as Error).message}`));
  }

  /* ============================== học ngay (user) ============================== */

  async onDraftResolved(repo: AiRepo, llm: LlmClient, draft: AiDraft, outcome: 'confirmed' | 'edited' | 'cancelled', finalPayload: any) {
    const orig: any = draft.payload;
    const diff = outcome === 'edited' ? diffPayload(draft.kind, orig, finalPayload) : null;
    await repo.upsertFeedback(draft.messageId, 'DRAFT_OUTCOME', { skill: draft.skill, outcome, diff: (diff ?? Prisma.JsonNull) as Prisma.InputJsonValue });
    if (outcome === 'cancelled' || draft.kind !== 'transactions') return;

    const items: any[] = finalPayload?.items ?? [];
    const learn = items.map((f, i) => ({ f, o: orig?.items?.[i] ?? {} })).filter(({ f, o }) => (f.clean ?? o.clean) && f.categoryName);
    let vecs: number[][] = [];
    try {
      vecs = await llm.embed(learn.map(({ f, o }) => f.clean ?? o.clean));
    } catch (e) {
      this.logger.warn(`embed khi học: ${(e as Error).message}`);
    }
    for (const [k, { f, o }] of learn.entries()) {
      const clean: string = f.clean ?? o.clean;
      await repo.upsertExample('ghi-giao-dich', clean, norm(clean), { title: f.title, categoryName: f.categoryName, amount: Number(f.amount) || 0 }, vecs[k] ?? null, vecs[k] ? llm.embedModel : null);
      for (const key of ruleKeys(norm(clean))) await repo.observeRule('category', 'ghi-giao-dich', key, f.categoryName);
      // Luật đã áp vào khoản này: giữ nguyên danh mục = có ích, bị sửa = có hại
      if (o.ruleId) await repo.ruleFeedback([o.ruleId], f.categoryName === o.categoryName);
    }
    // Trí nhớ: ví mặc định khi câu không nói ví (nháp đoán ví). Giữ = có ích; đổi = có hại + đếm chuỗi đổi liên tiếp sang cùng 1 ví.
    // Đổi 2 lần liên tiếp sang cùng ví (hoặc hại > ích) → nhớ ví mới (thói quen đổi thì trí nhớ đổi theo, không bị kẹt bởi lịch sử cũ).
    const guessed = items.find((f, i) => orig?.items?.[i]?.walletGuessed && f.walletName);
    if (guessed) {
      const chosen: string = guessed.walletName;
      const src = outcome === 'edited' ? 'edit' : 'confirm';
      const mem = await repo.getMemory('wallet.default');
      if (!mem || mem.value === chosen) {
        await repo.upsertMemory('wallet.default', chosen, mem?.source ?? src, { helpful: 1 });
        await repo.deleteMemoryKey('wallet.default.pending');
      } else {
        const pend = await repo.getMemory('wallet.default.pending');
        const streak = pend?.value === chosen ? pend.helpful + 1 : 1;
        if (streak >= 2 || mem.harmful + 1 > mem.helpful) {
          await repo.upsertMemory('wallet.default', chosen, src, { helpful: streak - mem.helpful, harmful: -mem.harmful });
          await repo.deleteMemoryKey('wallet.default.pending');
        } else {
          await repo.upsertMemory('wallet.default', mem.value, mem.source, { harmful: 1 });
          await repo.upsertMemory('wallet.default.pending', chosen, src, { helpful: streak - (pend?.helpful ?? 0) });
        }
      }
    }
  }

  async onReroute(repo: AiRepo, llm: LlmClient, messageId: string, text: string, fromSkill: string | null, toSkill: string) {
    await repo.upsertFeedback(messageId, 'REROUTE', { skill: fromSkill, fromSkill, toSkill });
    let vec: number[] | null = null;
    try {
      [vec] = await llm.embed([norm(text)]);
    } catch (e) {
      this.logger.warn(`embed khi reroute: ${(e as Error).message}`);
    }
    await repo.upsertExample('router', text.slice(0, 500), norm(text).slice(0, 500), { skill: toSkill }, vec, vec ? llm.embedModel : null);
    // User nói thẳng → luật định tuyến của user bật ngay cho đúng câu này
    await repo.observeRule('route', 'router', norm(text).slice(0, 500), toSkill, { force: true });
  }

  /* ============================== seed dữ liệu hệ thống ============================== */

  private async seedCtx(): Promise<AiUserContext> {
    const cats = await this.prisma.category.findMany({ where: { userId: null, isArchived: false }, select: { name: true, type: true } });
    const extra: AiUserContext['categories'] = [{ name: 'Hiếu hỉ', type: 'EXPENSE' }, { name: 'Du lịch', type: 'EXPENSE' }, { name: 'Gia đình', type: 'EXPENSE' }];
    return {
      userId: 'seed',
      displayName: 'seed',
      now: '2026-10-08T09:00:00+07:00',
      categories: [...cats, ...extra.filter((e) => !cats.some((c) => c.name === e.name))],
      wallets: ['MoMo', 'MB Bank', 'Techcombank', 'Tiền mặt', 'Vietcombank', 'ZaloPay'].map((name) => ({ name, type: 'BANK' })),
    };
  }

  async seed() {
    const lib = await aiLib();
    if (!lib) return;
    const ctx = await this.seedCtx();
    const cleanOf = (text: string) => {
      const s = lib.analyze(text, ctx).segs[0];
      return s ? accentedClean(s.text, s.clean) || norm(text) : norm(text);
    };
    // 1) Câu mẫu router theo scope (ai/router/bank.ts → SCOPED_BANK); bộ cũ không có scope (đợt 1) thì thay
    const seedRows = await this.prisma.aiExample.findMany({ where: { ownerKey: GLOBAL, skill: 'router', userCount: 0 }, select: { id: true, output: true } });
    const hasScoped = seedRows.some((r) => (r.output as any)?.scope);
    if (lib.SCOPED_BANK && !hasScoped) {
      if (seedRows.length) await this.prisma.aiExample.deleteMany({ where: { id: { in: seedRows.map((r) => r.id) } } });
      const rows = (['USER', 'ADMIN'] as const).flatMap((scope) => Object.entries(lib.SCOPED_BANK![scope] ?? {}).flatMap(([skill, xs]) => xs.map((input) => ({ scope, skill, input }))));
      await this.prisma.aiExample.createMany({
        // inputNorm kèm scope: cùng câu mẫu có thể nằm ở cả 2 scope (vd "hoi-lai")
        data: rows.map((r) => ({ scope: 'GLOBAL' as const, ownerKey: GLOBAL, skill: 'router', input: r.input, inputNorm: `${norm(r.input)}#${r.scope}`, output: { skill: r.skill, scope: r.scope }, status: 'ACTIVE' as const, userCount: 0 })),
        skipDuplicates: true,
      });
    } else if (!seedRows.length) {
      const src = await aiData<{ BANK?: Record<string, string[]> }>('eval/data/router-source.ts');
      const rows = Object.entries(src?.BANK ?? {}).flatMap(([skill, xs]) => xs.map((input) => ({ skill, input })));
      await this.prisma.aiExample.createMany({
        data: rows.map((r) => ({ scope: 'GLOBAL' as const, ownerKey: GLOBAL, skill: 'router', input: r.input, inputNorm: norm(r.input), output: { skill: r.skill, scope: 'USER' }, status: 'ACTIVE' as const, userCount: 0 })),
        skipDuplicates: true,
      });
    }
    // 2) Kho ví dụ khởi đầu của ghi-giao-dich (ai/eval/data/bank.seed.json, V3 trong benchmark)
    const bank = await aiData<{ text: string; title: string; categoryName: string }[]>('eval/data/bank.seed.json');
    if (bank && !(await this.prisma.aiExample.count({ where: { ownerKey: GLOBAL, skill: 'ghi-giao-dich' } }))) {
      await this.prisma.aiExample.createMany({
        data: bank.map((b) => {
          const c = cleanOf(b.text);
          return { scope: 'GLOBAL' as const, ownerKey: GLOBAL, skill: 'ghi-giao-dich', input: c, inputNorm: norm(c), output: { title: b.title, categoryName: b.categoryName }, status: 'ACTIVE' as const, userCount: 0 };
        }),
        skipDuplicates: true,
      });
    }
    // 3) Bộ đề hồi quy: bank.seed + ghi.dev (câu 1 khoản; KHÔNG dùng ghi.test — tập giữ riêng để đo)
    if (!(await this.prisma.aiEvalCase.count())) {
      const test = (await aiData<{ text: string; items: { categoryName: string }[] }[]>('eval/data/ghi.dev.json')) ?? [];
      const cases = [...(bank ?? []).map((b) => ({ text: b.text, categoryName: b.categoryName })), ...test.filter((t) => t.items.length === 1).map((t) => ({ text: t.text, categoryName: t.items[0].categoryName }))];
      await this.prisma.aiEvalCase.createMany({
        data: cases.map((c) => ({ skill: 'ghi-giao-dich', input: c.text, inputNorm: norm(cleanOf(c.text)), expected: { categoryName: c.categoryName }, source: 'seed' })),
        skipDuplicates: true,
      });
    }
  }

  /* ============================== cổng kiểm định ============================== */

  /**
   * Cổng tất định trên bộ đề hồi quy trong DB. ai/eval/gate.ts (evaluateRule) chạy model thật trên bộ đề có nhãn đầy đủ —
   * dùng cho đánh giá offline; nối vào chu trình đêm là việc trong docs/BACKLOG.md.
   */
  private async evalRule(pattern: string, value: string, cases: { inputNorm: string; expected: any }[]): Promise<EvalReport> {
    const hit = cases.filter((c) => ruleKeys(c.inputNorm).includes(pattern));
    const correct = hit.filter((c) => c.expected?.categoryName === value).length;
    return { verdict: !hit.length ? 'no-coverage' : correct === hit.length ? 'pass' : 'fail', matched: hit.length, correct, source: 'db' };
  }

  private evalExample(inputNorm: string, categoryName: string, cases: { inputNorm: string; expected: any }[]): EvalReport {
    const hit = cases.filter((c) => c.inputNorm === inputNorm);
    const correct = hit.filter((c) => c.expected?.categoryName === categoryName).length;
    return { verdict: !hit.length ? 'no-coverage' : correct === hit.length ? 'pass' : 'fail', matched: hit.length, correct, source: 'db' };
  }

  /* ============================== giữ lịch sử 12 tháng ============================== */

  @Cron('20 3 * * *', { timeZone: 'Asia/Ho_Chi_Minh' })
  async retentionCron() {
    await this.retention(new Date()).catch((e) => this.logger.error(`Dọn lịch sử chat lỗi: ${(e as Error).message}`));
  }

  /** Xóa tin nhắn cũ hơn 12 tháng (nháp / phản hồi đi theo) rồi xóa hội thoại không còn tin và không cập nhật trong 12 tháng. */
  async retention(now: Date) {
    const cutoff = new Date(now.getTime() - RETENTION_DAYS * 86400_000);
    const messages = await this.prisma.aiMessage.deleteMany({ where: { createdAt: { lt: cutoff } } });
    const conversations = await this.prisma.aiConversation.deleteMany({ where: { updatedAt: { lt: cutoff }, messages: { none: {} } } });
    return { cutoff, messages: messages.count, conversations: conversations.count };
  }

  /* ============================== chu trình ban đêm ============================== */

  /** User đã đồng ý góp ví dụ ẩn danh (chưa đồng ý → không lấy gì của họ cho học chung) */
  private async consenting() {
    const rows = await this.prisma.aiUserSetting.findMany({ where: { shareExamples: true }, select: { userId: true } });
    return new Set(rows.map((r) => r.userId));
  }

  @Cron('30 2 * * *', { timeZone: 'Asia/Ho_Chi_Minh' })
  async nightly() {
    await this.run('cron').catch((e) => this.logger.error(`Học ban đêm lỗi: ${(e as Error).message}`));
  }

  async run(trigger: string) {
    if (this.running) return { skipped: true, reason: 'RUNNING' };
    this.running = true;
    const [{ locked }] = await this.prisma.$queryRaw<{ locked: boolean }[]>`SELECT pg_try_advisory_lock(${ADVISORY_KEY}) AS locked`;
    if (!locked) {
      this.running = false;
      return { skipped: true, reason: 'LOCKED' };
    }
    const runRow = await this.prisma.aiLearningRun.create({ data: { trigger } });
    try {
      await this.seed();
      const stats = { rules: await this.mineRules(), examples: await this.mineExamples() };
      await this.prisma.aiLearningRun.update({ where: { id: runRow.id }, data: { finishedAt: new Date(), stats } });
      this.logger.log(`Học (${trigger}): ${JSON.stringify(stats)}`);
      return { id: runRow.id, ...stats };
    } catch (e) {
      await this.prisma.aiLearningRun.update({ where: { id: runRow.id }, data: { finishedAt: new Date(), error: (e as Error).message.slice(0, 500) } });
      throw e;
    } finally {
      await this.prisma.$queryRaw`SELECT pg_advisory_unlock(${ADVISORY_KEY})`;
      this.running = false;
    }
  }

  /** Token tên người đóng góp (tên + phần trước @ của email) — bị loại khỏi dữ liệu chung. */
  private async nameTokens(userIds: string[]) {
    const users = await this.prisma.user.findMany({ where: { id: { in: userIds } }, select: { name: true, email: true } });
    return new Set(users.flatMap((u) => [...norm(u.name).split(' '), ...norm(u.email.split('@')[0]).split(' ')]).filter((t) => t.length > 1));
  }

  private decide(cfg: Awaited<ReturnType<SystemConfigService['ai']>>, users: number, support: number, precision: number, verdict: Verdict, kind: 'rule' | 'example') {
    if (verdict === 'fail') return 'REJECTED' as const;
    const t = cfg.autoApprove;
    const meets = t.enabled && users >= t.minUsers && support >= t.minSupport && precision >= t.minPrecision;
    // Luật ghi đè cả model nên phải có bằng chứng trên bộ đề; ví dụ chỉ là few-shot nên "chưa có đề" vẫn được tự bật
    const evalOk = kind === 'rule' ? verdict === 'pass' : true;
    return meets && evalOk ? ('ACTIVE' as const) : ('PROPOSED' as const);
  }

  private async mineRules() {
    const cfg = await this.sys.ai();
    const cases = await this.prisma.aiEvalCase.findMany({ where: { skill: 'ghi-giao-dich' }, select: { inputNorm: true, expected: true } });
    const ok = await this.consenting();
    const all = (await this.prisma.aiRule.findMany({ where: { scope: 'USER', kind: 'category', skill: 'ghi-giao-dich' }, select: { userId: true, pattern: true, value: true, support: true, status: true } })).filter((r) => ok.has(r.userId!));
    const seen = new Set<string>();
    const totals = new Map<string, number>();
    for (const r of all) totals.set(r.pattern, (totals.get(r.pattern) ?? 0) + r.support);
    const groups = new Map<string, { pattern: string; value: string; users: Set<string>; support: number }>();
    for (const r of all.filter((x) => x.status === 'ACTIVE')) {
      const k = `${r.pattern}\u0000${r.value}`;
      const g = groups.get(k) ?? { pattern: r.pattern, value: r.value, users: new Set<string>(), support: 0 };
      g.users.add(r.userId!);
      g.support += r.support;
      groups.set(k, g);
    }
    const out = { candidates: 0, active: 0, proposed: 0, rejected: 0, skippedAnonymity: 0, skippedPrivate: 0 };
    for (const g of groups.values()) {
      if (g.users.size < MIN_USERS_FOR_GLOBAL) { out.skippedAnonymity++; continue; }
      const names = await this.nameTokens([...g.users]);
      if (/\d|@/.test(g.pattern) || g.pattern.split(' ').some((t) => names.has(t))) { out.skippedPrivate++; continue; }
      const precision = g.support / (totals.get(g.pattern) ?? g.support);
      const report = await this.evalRule(g.pattern, g.value, cases);
      const status = this.decide(cfg, g.users.size, g.support, precision, report.verdict, 'rule');
      out.candidates++;
      out[status === 'ACTIVE' ? 'active' : status === 'PROPOSED' ? 'proposed' : 'rejected']++;
      seen.add(`${g.pattern}\u0000${g.value}`);
      const key = { ownerKey_kind_pattern_value: { ownerKey: GLOBAL, kind: 'category', pattern: g.pattern, value: g.value } };
      const existing = await this.prisma.aiRule.findUnique({ where: key });
      const counters = { support: g.support, userCount: g.users.size, precision, evalReport: report as unknown as Prisma.InputJsonValue };
      if (!existing) {
        await this.prisma.aiRule.create({ data: { scope: 'GLOBAL', ownerKey: GLOBAL, skill: 'ghi-giao-dich', kind: 'category', pattern: g.pattern, value: g.value, status, approvedAt: status === 'ACTIVE' ? new Date() : null, ...counters } });
      } else if (existing.approvedById) {
        await this.prisma.aiRule.update({ where: { id: existing.id }, data: counters }); // admin đã quyết: giữ trạng thái
      } else {
        await this.prisma.aiRule.update({ where: { id: existing.id }, data: { ...counters, status, approvedAt: status === 'ACTIVE' ? existing.approvedAt ?? new Date() : null } });
      }
    }
    // Luật chung tự bật trước đây nay không còn đủ người đồng ý / đủ ngưỡng → về chờ duyệt
    const stale = await this.prisma.aiRule.findMany({ where: { ownerKey: GLOBAL, kind: 'category', approvedById: null, status: 'ACTIVE' }, select: { id: true, pattern: true, value: true } });
    const demote = stale.filter((r) => !seen.has(`${r.pattern}\u0000${r.value}`)).map((r) => r.id);
    if (demote.length) await this.prisma.aiRule.updateMany({ where: { id: { in: demote } }, data: { status: 'PROPOSED', approvedAt: null } });
    (out as any).demoted = demote.length;
    return out;
  }

  private async mineExamples() {
    const cfg = await this.sys.ai();
    const cases = await this.prisma.aiEvalCase.findMany({ where: { skill: 'ghi-giao-dich' }, select: { inputNorm: true, expected: true } });
    const ok = await this.consenting();
    const rows = (await this.prisma.aiExample.findMany({ where: { scope: 'USER', skill: 'ghi-giao-dich' }, select: { userId: true, inputNorm: true, output: true, confirmations: true } })).filter((r) => ok.has(r.userId!));
    const groups = new Map<string, { inputNorm: string; categoryName: string; users: Set<string>; confirmations: number; titles: Map<string, number>; amounts: number[] }>();
    const totals = new Map<string, number>();
    for (const r of rows) {
      const o = r.output as any;
      if (!o?.categoryName) continue;
      totals.set(r.inputNorm, (totals.get(r.inputNorm) ?? 0) + r.confirmations);
      const k = `${r.inputNorm}\u0000${o.categoryName}`;
      const g = groups.get(k) ?? { inputNorm: r.inputNorm, categoryName: o.categoryName, users: new Set<string>(), confirmations: 0, titles: new Map<string, number>(), amounts: [] as number[] };
      g.users.add(r.userId!);
      g.confirmations += r.confirmations;
      if (o.title) g.titles.set(o.title, (g.titles.get(o.title) ?? 0) + 1);
      if (o.amount) g.amounts.push(Number(o.amount));
      groups.set(k, g);
    }
    const out = { candidates: 0, active: 0, proposed: 0, rejected: 0, skippedAnonymity: 0, skippedPrivate: 0 };
    for (const g of groups.values()) {
      if (g.users.size < MIN_USERS_FOR_GLOBAL) { out.skippedAnonymity++; continue; }
      const names = await this.nameTokens([...g.users]);
      if (/\d|@/.test(g.inputNorm) || g.inputNorm.split(' ').some((t) => names.has(t))) { out.skippedPrivate++; continue; }
      // Tiêu đề phổ biến nhất, bỏ từ trùng tên người; tiền: trung vị làm tròn 1 chữ số có nghĩa; không có ghi chú
      const title = ([...g.titles.entries()].sort((a, b) => b[1] - a[1])[0]?.[0] ?? g.inputNorm).split(' ').filter((w) => !names.has(norm(w))).join(' ') || g.inputNorm;
      const amounts = g.amounts.sort((a, b) => a - b);
      const typicalAmount = amounts.length ? roundAmount(amounts[Math.floor(amounts.length / 2)]) : null;
      const precision = g.confirmations / (totals.get(g.inputNorm) ?? g.confirmations);
      const report = this.evalExample(g.inputNorm, g.categoryName, cases);
      const status = this.decide(cfg, g.users.size, g.confirmations, precision, report.verdict, 'example');
      out.candidates++;
      out[status === 'ACTIVE' ? 'active' : status === 'PROPOSED' ? 'proposed' : 'rejected']++;
      const output = { title, categoryName: g.categoryName, typicalAmount };
      const key = { ownerKey_skill_inputNorm: { ownerKey: GLOBAL, skill: 'ghi-giao-dich', inputNorm: g.inputNorm } };
      const existing = await this.prisma.aiExample.findUnique({ where: key });
      const common = { output, userCount: g.users.size, confirmations: g.confirmations, evalReport: report as unknown as Prisma.InputJsonValue };
      if (!existing) {
        await this.prisma.aiExample.create({ data: { scope: 'GLOBAL', ownerKey: GLOBAL, skill: 'ghi-giao-dich', input: g.inputNorm, inputNorm: g.inputNorm, status, approvedAt: status === 'ACTIVE' ? new Date() : null, ...common } });
      } else if (existing.approvedById || (existing.userCount === 0 && existing.status === 'ACTIVE')) {
        // admin đã quyết / ví dụ seed: không ghi đè trạng thái
        if (existing.approvedById) await this.prisma.aiExample.update({ where: { id: existing.id }, data: { userCount: g.users.size, confirmations: g.confirmations } });
      } else {
        await this.prisma.aiExample.update({ where: { id: existing.id }, data: { ...common, status, embedding: null, embedModel: null } });
      }
    }
    return out;
  }

  /**
   * Ví dụ chung được ADMIN duyệt → thêm vào bộ đề hồi quy để các thay đổi sau không làm hỏng nó.
   * (Ví dụ tự bật không được thêm: tránh vòng tự xác nhận ví dụ tự bật → làm "đề" cho luật tự bật.)
   */
  async addEvalCase(inputNorm: string, categoryName: string) {
    await this.prisma.aiEvalCase.upsert({
      where: { skill_inputNorm: { skill: 'ghi-giao-dich', inputNorm } },
      create: { skill: 'ghi-giao-dich', input: inputNorm, inputNorm, expected: { categoryName }, source: 'approved' },
      update: {},
    });
  }
}

/** Khác biệt nháp → bản cuối (theo khoản), chỉ các trường nghiệp vụ. */
export function diffPayload(kind: string, a: any, b: any) {
  if (kind === 'transactions') {
    const fields = ['title', 'amount', 'categoryId', 'walletId', 'date'];
    const n = Math.max(a?.items?.length ?? 0, b?.items?.length ?? 0);
    const items = [];
    for (let i = 0; i < n; i++) {
      const x = a?.items?.[i], y = b?.items?.[i];
      if (!x || !y) { items.push({ index: i, change: x ? 'removed' : 'added' }); continue; }
      const ch = Object.fromEntries(fields.filter((f) => String(x[f] ?? '') !== String(y[f] ?? '')).map((f) => [f, { from: x[f] ?? null, to: y[f] ?? null }]));
      if (Object.keys(ch).length) items.push({ index: i, ...ch });
    }
    return { items };
  }
  const keys = new Set([...Object.keys(a ?? {}), ...Object.keys(b ?? {})]);
  return Object.fromEntries([...keys].filter((k) => JSON.stringify(a?.[k]) !== JSON.stringify(b?.[k])).map((k) => [k, { from: a?.[k] ?? null, to: b?.[k] ?? null }]));
}
