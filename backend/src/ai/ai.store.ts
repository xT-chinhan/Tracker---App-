/**
 * Truy cập dữ liệu AI có phạm vi theo principal.
 *
 * Quy tắc cô lập (không thể quên): code AI KHÔNG gọi `prisma.ai*` trực tiếp cho dữ liệu user. Mọi đọc/ghi đi qua
 * `AiStore.for(principal)` → `AiRepo`, nơi MỌI câu where đều gắn `userId = principal.id` (principal lấy từ JWT,
 * không bao giờ từ nội dung tin nhắn). Id thuộc user khác → 404 như phần còn lại của API.
 * Dữ liệu GLOBAL (luật / ví dụ chung đã ẩn danh) chỉ được ĐỌC ở trạng thái ACTIVE qua repo; ghi do chu trình học / admin.
 */
import { Injectable, NotFoundException } from '@nestjs/common';
import { AiDraftStatus, AiMessageRole, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import type { Principal } from './ai.types';
import { fromBytes, toBytes } from './ai.text';

/** Nội dung tin USER đại diện cho 1 ảnh gửi lên (ảnh không được lưu). */
export const OCR_USER_TEXT = '[Ảnh hóa đơn]';

export const GLOBAL = 'global';
/** Luật của user tự bật khi đủ bằng chứng (giống ai/learn/store.ts: support ≥ 3, precision ≥ 0.85) */
export const USER_RULE_MIN_SUPPORT = 3;
export const USER_RULE_MIN_PRECISION = 0.85;

export interface KnnRow {
  id: string;
  scope: 'USER' | 'GLOBAL';
  input: string;
  inputNorm: string;
  output: Prisma.JsonValue;
  vec: Float32Array | null;
}

@Injectable()
export class AiStore {
  constructor(private readonly prisma: PrismaService) {}

  /** Cửa duy nhất vào dữ liệu AI của user. */
  for(principal: Principal): AiRepo {
    if (!principal?.id) throw new Error('AiStore.for: thiếu principal');
    return new AiRepo(this.prisma, principal);
  }
}

export class AiRepo {
  constructor(private readonly db: PrismaService, readonly principal: Principal) {}

  private get uid() {
    return this.principal.id;
  }

  /* ---------- hội thoại ---------- */

  async listConversations(q: { archived?: boolean; page: number; limit: number }) {
    const where = { userId: this.uid, archived: q.archived ?? false };
    const [items, total] = await this.db.$transaction([
      this.db.aiConversation.findMany({
        where,
        orderBy: [{ pinned: 'desc' }, { updatedAt: 'desc' }],
        skip: (q.page - 1) * q.limit,
        take: q.limit,
        include: { _count: { select: { messages: true } } },
      }),
      this.db.aiConversation.count({ where }),
    ]);
    return { items: items.map(({ _count, ...c }) => ({ ...c, messageCount: _count.messages })), total, page: q.page, limit: q.limit };
  }

  countConversations() {
    return this.db.aiConversation.count({ where: { userId: this.uid } });
  }

  countActiveConversations() {
    return this.db.aiConversation.count({ where: { userId: this.uid, archived: false } });
  }

  /** Đạt giới hạn: lưu trữ cuộc cũ nhất CHƯA GHIM (null = mọi cuộc đều ghim) */
  async archiveOldestUnpinned() {
    const c = await this.db.aiConversation.findFirst({ where: { userId: this.uid, archived: false, pinned: false }, orderBy: { updatedAt: 'asc' } });
    if (!c) return null;
    await this.db.aiConversation.updateMany({ where: { id: c.id, userId: this.uid }, data: { archived: true } });
    return { id: c.id, title: c.title };
  }

  /* ---------- cài đặt AI của user ---------- */

  async getSetting() {
    const s = await this.db.aiUserSetting.findUnique({ where: { userId: this.uid } });
    return { shareExamples: s?.shareExamples ?? false, consentedAt: s?.consentedAt ?? null, asked: !!s };
  }

  async setSetting(shareExamples: boolean) {
    const now = new Date();
    await this.db.aiUserSetting.upsert({
      where: { userId: this.uid },
      create: { userId: this.uid, shareExamples, consentedAt: shareExamples ? now : null },
      update: { shareExamples, ...(shareExamples ? { consentedAt: now } : {}) },
    });
    return this.getSetting();
  }

  createConversation(title?: string | null) {
    return this.db.aiConversation.create({ data: { userId: this.uid, scope: this.principal.role === 'ADMIN' ? 'ADMIN' : 'USER', title: title || null } });
  }

  async getConversation(id: string) {
    const c = await this.db.aiConversation.findFirst({ where: { id, userId: this.uid } });
    if (!c) throw new NotFoundException('Không tìm thấy hội thoại');
    return c;
  }

  async updateConversation(id: string, data: { title?: string | null; archived?: boolean; pinned?: boolean }) {
    await this.getConversation(id);
    return this.db.aiConversation.update({ where: { id }, data });
  }

  async deleteConversation(id: string) {
    const { count } = await this.db.aiConversation.deleteMany({ where: { id, userId: this.uid } });
    if (!count) throw new NotFoundException('Không tìm thấy hội thoại');
  }

  /* ---------- tin nhắn ---------- */

  async createMessage(conversationId: string, data: {
    role: AiMessageRole; content: string; skill?: string | null; routeBy?: string | null; status?: string;
    latencyMs?: number | null; promptTokens?: number | null; evalTokens?: number | null; meta?: Prisma.InputJsonValue;
  }) {
    await this.getConversation(conversationId);
    const m = await this.db.aiMessage.create({ data: { ...data, conversationId, userId: this.uid } });
    await this.db.aiConversation.update({ where: { id: conversationId }, data: { updatedAt: new Date() } });
    return m;
  }

  async getMessage(id: string) {
    const m = await this.db.aiMessage.findFirst({ where: { id, userId: this.uid }, include: { draft: true } });
    if (!m) throw new NotFoundException('Không tìm thấy tin nhắn');
    return m;
  }

  /** Tin USER ngay trước một tin (để reroute lấy lại câu hỏi) */
  previousUserMessage(conversationId: string, before: Date) {
    return this.db.aiMessage.findFirst({
      where: { conversationId, userId: this.uid, role: 'USER', createdAt: { lte: before } },
      orderBy: { createdAt: 'desc' },
    });
  }

  async listMessages(conversationId: string) {
    await this.getConversation(conversationId);
    return this.db.aiMessage.findMany({ where: { conversationId, userId: this.uid }, orderBy: [{ createdAt: 'asc' }, { role: 'desc' }], include: { draft: true } });
  }

  async history(conversationId: string, n: number) {
    const rows = await this.db.aiMessage.findMany({
      where: { conversationId, userId: this.uid },
      orderBy: { createdAt: 'desc' },
      take: n,
      select: { role: true, content: true },
    });
    return rows.reverse().map((r) => ({ role: r.role === 'USER' ? ('user' as const) : ('assistant' as const), content: r.content }));
  }

/** Số câu trả lời của một skill từ mốc `since` (vd số ảnh đã đọc hôm nay). */
  countSkillRepliesSince(skill: string, since: Date) {
    return this.db.aiMessage.count({ where: { userId: this.uid, role: 'ASSISTANT', skill, createdAt: { gte: since } } });
  }

    countUserMessagesSince(since: Date) {
    // ảnh hóa đơn có hạn mức riêng (ai.ocrDailyLimitPerUser), không tính vào số tin chat
    return this.db.aiMessage.count({ where: { userId: this.uid, role: 'USER', createdAt: { gte: since }, NOT: { content: OCR_USER_TEXT } } });
  }

  /* ---------- nháp ---------- */

  createDraft(messageId: string, skill: string, kind: string, payload: Prisma.InputJsonValue) {
    return this.db.aiDraft.create({ data: { messageId, userId: this.uid, skill, kind, payload } });
  }

  async getDraft(id: string) {
    const d = await this.db.aiDraft.findFirst({ where: { id, userId: this.uid } });
    if (!d) throw new NotFoundException('Không tìm thấy nháp');
    return d;
  }

  /** Chuyển trạng thái có điều kiện (chặn xác nhận 2 lần đồng thời). Trả số dòng đổi (0 = đã bị người khác đổi). */
  async transitionDraft(id: string, from: AiDraftStatus[], data: Prisma.AiDraftUpdateManyMutationInput) {
    const { count } = await this.db.aiDraft.updateMany({ where: { id, userId: this.uid, status: { in: from } }, data });
    return count;
  }

  /** Nháp còn mở của hội thoại (reroute thì hủy) */
  openDraftsOf(conversationId: string) {
    return this.db.aiDraft.findMany({ where: { userId: this.uid, status: 'PROPOSED', message: { conversationId } } });
  }

  /* ---------- phản hồi ---------- */

  upsertFeedback(messageId: string, kind: 'DRAFT_OUTCOME' | 'REROUTE' | 'THUMBS', data: Omit<Prisma.AiFeedbackUncheckedCreateInput, 'userId' | 'messageId' | 'kind'>) {
    return this.db.aiFeedback.upsert({
      where: { messageId_kind: { messageId, kind } },
      create: { ...data, userId: this.uid, messageId, kind },
      update: data,
    });
  }

  /* ---------- trí nhớ ---------- */

  listMemory() {
    return this.db.aiMemory.findMany({ where: { userId: this.uid }, orderBy: [{ helpful: 'desc' }, { updatedAt: 'desc' }], take: 100 });
  }

  getMemory(key: string) {
    return this.db.aiMemory.findUnique({ where: { userId_key: { userId: this.uid, key } } });
  }

  upsertMemory(key: string, value: string, source: string, delta: { helpful?: number; harmful?: number } = {}) {
    return this.db.aiMemory.upsert({
      where: { userId_key: { userId: this.uid, key } },
      create: { userId: this.uid, key, value, source, helpful: delta.helpful ?? 0, harmful: delta.harmful ?? 0 },
      update: { value, source, helpful: { increment: delta.helpful ?? 0 }, harmful: { increment: delta.harmful ?? 0 } },
    });
  }

  touchMemory(keys: string[]) {
    if (!keys.length) return Promise.resolve({ count: 0 });
    return this.db.aiMemory.updateMany({ where: { userId: this.uid, key: { in: keys } }, data: { lastUsedAt: new Date() } });
  }

  deleteMemoryKey(key: string) {
    return this.db.aiMemory.deleteMany({ where: { userId: this.uid, key } });
  }

  async deleteMemory(id: string) {
    const { count } = await this.db.aiMemory.deleteMany({ where: { id, userId: this.uid } });
    if (count) return;
    // mục "đã học" trong danh sách trí nhớ có thể là luật riêng của user → quên luật đó
    const r = await this.db.aiRule.deleteMany({ where: { id, userId: this.uid, scope: 'USER' } });
    if (!r.count) throw new NotFoundException('Không tìm thấy mục trí nhớ');
  }

  /** Luật riêng đang bật của user (hiện trong "Trợ lý đã học về bạn") */
  ownActiveRules() {
    return this.db.aiRule.findMany({
      where: { userId: this.uid, scope: 'USER', status: 'ACTIVE' },
      orderBy: [{ support: 'desc' }, { updatedAt: 'desc' }],
      take: 50,
      select: { id: true, kind: true, pattern: true, value: true, support: true, createdAt: true, updatedAt: true },
    });
  }

  /* ---------- ví dụ ---------- */

  upsertExample(skill: string, input: string, inputNorm: string, output: Prisma.InputJsonValue, vec: number[] | null, embedModel: string | null) {
    const emb = vec ? { embedding: toBytes(vec), embedModel } : {};
    return this.db.aiExample.upsert({
      where: { ownerKey_skill_inputNorm: { ownerKey: this.uid, skill, inputNorm } },
      create: { scope: 'USER', userId: this.uid, ownerKey: this.uid, skill, input, inputNorm, output, status: 'ACTIVE', ...emb },
      update: { input, output, confirmations: { increment: 1 }, ...emb },
    });
  }

  countExamples(skill: string) {
    return this.db.aiExample.count({ where: { userId: this.uid, skill } });
  }

  /** Ứng viên kNN: ví dụ của chính user + ví dụ CHUNG đang bật. Vector của model khác bị bỏ (vec = null). */
  async knnRows(skill: string, embedModel: string, limit = 2000): Promise<KnnRow[]> {
    const rows = await this.db.aiExample.findMany({
      where: { skill, status: 'ACTIVE', OR: [{ userId: this.uid }, { scope: 'GLOBAL' }] },
      select: { id: true, scope: true, input: true, inputNorm: true, output: true, embedding: true, embedModel: true },
      orderBy: { updatedAt: 'desc' },
      take: limit,
    });
    return rows.map((r) => ({ id: r.id, scope: r.scope, input: r.input, inputNorm: r.inputNorm, output: r.output, vec: r.embedding && r.embedModel === embedModel ? fromBytes(r.embedding) : null }));
  }

  /** Ghi lại embedding cho ví dụ của CHÍNH user (đổi model embed). */
  setOwnEmbedding(id: string, vec: number[], embedModel: string) {
    return this.db.aiExample.updateMany({ where: { id, userId: this.uid }, data: { embedding: toBytes(vec), embedModel } });
  }

  /* ---------- luật ---------- */

  /** Luật đang bật: của user trước, rồi luật CHUNG. */
  async activeRules(kind: string, skill: string) {
    const rows = await this.db.aiRule.findMany({
      where: { kind, skill, status: 'ACTIVE', OR: [{ userId: this.uid }, { scope: 'GLOBAL' }] },
      select: { id: true, scope: true, pattern: true, value: true, support: true },
    });
    return rows.sort((a, b) => Number(a.scope === 'GLOBAL') - Number(b.scope === 'GLOBAL') || b.support - a.support);
  }

  /** Quan sát pattern → value (user scope) rồi tính lại trạng thái các luật cùng pattern. */
  async observeRule(kind: string, skill: string, pattern: string, value: string, opts: { force?: boolean } = {}) {
    await this.db.aiRule.upsert({
      where: { ownerKey_kind_pattern_value: { ownerKey: this.uid, kind, pattern, value } },
      create: { scope: 'USER', userId: this.uid, ownerKey: this.uid, skill, kind, pattern, value, support: 1, status: 'PROPOSED' },
      update: { support: { increment: 1 } },
    });
    await this.recomputeRules(kind, pattern, opts.force ? value : undefined);
  }

  async ruleFeedback(ids: string[], helpful: boolean) {
    if (!ids.length) return;
    // Luật của user: cập nhật ngay; luật CHUNG: chỉ đếm (chu trình đêm / admin xử lý)
    await this.db.aiRule.updateMany({
      where: { id: { in: ids }, OR: [{ userId: this.uid }, { scope: 'GLOBAL' }] },
      data: helpful ? { helpful: { increment: 1 } } : { harmful: { increment: 1 } },
    });
    const own = await this.db.aiRule.findMany({ where: { id: { in: ids }, userId: this.uid }, select: { kind: true, pattern: true } });
    for (const r of own) await this.recomputeRules(r.kind, r.pattern);
  }

  /** Bật luật khi support ≥ 3 và precision ≥ 0.85; tắt khi có hại ≥ 2 và nhiều hơn có ích. `force` = user nói thẳng (reroute). */
  private async recomputeRules(kind: string, pattern: string, force?: string) {
    const rows = await this.db.aiRule.findMany({ where: { ownerKey: this.uid, kind, pattern } });
    const total = rows.reduce((s, r) => s + r.support, 0);
    for (const r of rows) {
      const precision = total ? r.support / total : 0;
      const bad = r.harmful >= 2 && r.harmful > r.helpful;
      const active = force ? r.value === force : !bad && r.support >= USER_RULE_MIN_SUPPORT && precision >= USER_RULE_MIN_PRECISION;
      await this.db.aiRule.update({ where: { id: r.id }, data: { precision, status: active ? 'ACTIVE' : 'PROPOSED' } });
    }
  }

  /* ---------- thống kê của chính mình ---------- */

  async myUsage(since: Date) {
    const [today, conversations] = await Promise.all([this.countUserMessagesSince(since), this.countConversations()]);
    return { messagesToday: today, conversations };
  }
}
