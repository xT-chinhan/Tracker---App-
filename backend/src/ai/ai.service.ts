/**
 * Pipeline trợ lý: tin user → router → skill (context theo principal + LLM) → nháp (chuẩn hóa) → lưu tin/nháp.
 * Xác nhận nháp → thực thi qua service nghiệp vụ → tín hiệu học.
 */
import { BadRequestException, ConflictException, ForbiddenException, HttpException, Injectable, Logger } from '@nestjs/common';
import { AiConversation, AiDraft, AiMessage, Prisma } from '@prisma/client';
import { SystemConfigService } from '../system-config/system-config.module';
import { AiContextService } from './ai.context';
import { DraftKinds } from './ai.drafts';
import { AiLearningService, diffPayload } from './ai.learning';
import { FakeLlm, OllamaClient } from './ai.llm';
import { AiRouter } from './ai.router';
import { SkillRegistry } from './ai.skills';
import { AiRepo, AiStore } from './ai.store';
import type { ChatMsg, ChatOptions, LlmClient, Principal, RouteResult, SkillResult } from './ai.types';

@Injectable()
export class AiLlmFactory {
  private readonly fake = new FakeLlm();
  private cached?: { sig: string; client: LlmClient };

  constructor(private readonly sys: SystemConfigService) {}

  async get(): Promise<LlmClient> {
    const c = await this.sys.ai();
    if (c.provider === 'fake') return this.fake;
    const sig = JSON.stringify([c.ollamaUrl, c.chatModel, c.embedModel, c.timeoutMs]);
    if (this.cached?.sig !== sig) this.cached = { sig, client: new OllamaClient(c.ollamaUrl, c.chatModel, c.embedModel, c.timeoutMs) };
    return this.cached.client;
  }
}

/** Ghi lại các lời gọi LLM (chế độ debug, không production) để test kiểm tra prompt không chứa dữ liệu người khác. */
function recording(llm: LlmClient, calls: { messages: ChatMsg[] }[]): LlmClient {
  return {
    provider: llm.provider,
    chatModel: llm.chatModel,
    embedModel: llm.embedModel,
    chat: (messages: ChatMsg[], opts?: ChatOptions) => {
      calls.push({ messages });
      return llm.chat(messages, opts);
    },
    embed: (texts: string[]) => llm.embed(texts),
  };
}

/** 0h hôm nay giờ VN */
function vnMidnight(now = Date.now()) {
  const d = new Date(now + 7 * 3600_000);
  return new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate()) - 7 * 3600_000);
}

export function draftView(d: AiDraft | null | undefined) {
  if (!d) return null;
  return { id: d.id, messageId: d.messageId, skill: d.skill, kind: d.kind, status: d.status, payload: d.payload, finalPayload: d.finalPayload, result: d.result, resolvedAt: d.resolvedAt, createdAt: d.createdAt };
}

export function messageView(m: AiMessage & { draft?: AiDraft | null }) {
  const meta = (m.meta ?? {}) as Record<string, unknown>;
  return {
    id: m.id,
    conversationId: m.conversationId,
    role: m.role,
    content: m.content,
    skill: m.skill,
    routeBy: m.routeBy,
    status: m.status,
    latencyMs: m.latencyMs,
    tokens: m.promptTokens != null || m.evalTokens != null ? { prompt: m.promptTokens, eval: m.evalTokens } : null,
    followUps: (meta.followUps as string[] | undefined) ?? [],
    createdAt: m.createdAt,
    draft: draftView(m.draft),
  };
}

export type AiEvent = (event: string, data: unknown) => void;

@Injectable()
export class AiService {
  private readonly logger = new Logger('Ai');

  constructor(
    private readonly store: AiStore,
    private readonly sys: SystemConfigService,
    private readonly ctxs: AiContextService,
    private readonly skills: SkillRegistry,
    private readonly router: AiRouter,
    private readonly drafts: DraftKinds,
    private readonly learning: AiLearningService,
    private readonly llms: AiLlmFactory,
  ) {}

  /* ============================== hội thoại ============================== */

  list(p: Principal, q: { archived?: boolean; page: number; limit: number }) {
    return this.store.for(p).listConversations(q);
  }

  async create(p: Principal, title?: string) {
    const repo = this.store.for(p);
    const { maxConversationsPerUser: max } = await this.sys.ai();
    // Đạt giới hạn (tính cuộc chưa lưu trữ): tự lưu trữ cuộc cũ nhất chưa ghim; tất cả đều ghim → 409
    let autoArchived: { id: string; title: string | null } | null = null;
    while ((await repo.countActiveConversations()) >= max) {
      autoArchived = await repo.archiveOldestUnpinned();
      if (!autoArchived) {
        throw new ConflictException({ statusCode: 409, code: 'AI_CONVERSATION_LIMIT', message: `Đã có ${max} hội thoại đang ghim, hãy bỏ ghim hoặc xóa bớt`, limit: max });
      }
    }
    return { ...(await repo.createConversation(title)), autoArchived };
  }

  async get(p: Principal, id: string) {
    const repo = this.store.for(p);
    const c = await repo.getConversation(id);
    return { ...c, messages: (await repo.listMessages(id)).map(messageView) };
  }

  update(p: Principal, id: string, dto: { title?: string; archived?: boolean; pinned?: boolean }) {
    return this.store.for(p).updateConversation(id, dto);
  }

  remove(p: Principal, id: string) {
    return this.store.for(p).deleteConversation(id);
  }

  /* ============================== hạn mức ============================== */

  async usage(p: Principal) {
    const c = await this.sys.ai();
    const u = await this.store.for(p).myUsage(vnMidnight());
    return { ...u, dailyMessageLimit: c.dailyMessageLimitPerUser, maxConversations: c.maxConversationsPerUser, resetAt: new Date(vnMidnight().getTime() + 86400_000) };
  }

  private async assertDailyLimit(repo: AiRepo) {
    const { dailyMessageLimitPerUser: limit } = await this.sys.ai();
    if ((await repo.countUserMessagesSince(vnMidnight())) >= limit) {
      const resetAt = new Date(vnMidnight().getTime() + 86400_000);
      throw new HttpException(
        { statusCode: 429, code: 'AI_DAILY_LIMIT', message: `Bạn đã dùng hết ${limit} tin nhắn AI hôm nay, quay lại sau 0h nhé`, limit, resetAt, retryAfterSeconds: Math.ceil((resetAt.getTime() - Date.now()) / 1000) },
        429,
      );
    }
  }

  /* ============================== tin nhắn ============================== */

  /** Kiểm tra trước (404 / 409 / 429) + lưu tin của user. Tách riêng để SSE trả lỗi HTTP chuẩn trước khi mở stream. */
  async accept(p: Principal, conversationId: string, text: string) {
    const repo = this.store.for(p);
    const conv = await repo.getConversation(conversationId);
    if (conv.archived) throw new ConflictException('Hội thoại đã lưu trữ, hãy khôi phục trước khi nhắn');
    await this.assertDailyLimit(repo);
    const userMessage = await repo.createMessage(conversationId, { role: 'USER', content: text });
    if (!conv.title) await repo.updateConversation(conversationId, { title: text.replace(/\s+/g, ' ').slice(0, 60) });
    return { repo, conv, userMessage };
  }

  async post(p: Principal, conversationId: string, text: string, opts: { debug?: boolean; onEvent?: AiEvent } = {}) {
    const { repo, conv, userMessage } = await this.accept(p, conversationId, text);
    const out = await this.answer(repo, conv, text, opts);
    return { userMessage: messageView(userMessage), ...out };
  }

  /** Trả lời 1 câu (cũng dùng cho reroute với skill ép buộc). Lỗi skill/LLM không làm hỏng request: lưu tin trạng thái error. */
  async answer(repo: AiRepo, conv: AiConversation, text: string, opts: { forced?: string; debug?: boolean; onEvent?: AiEvent } = {}) {
    const t0 = Date.now();
    const p = repo.principal;
    const cfg = await this.sys.ai();
    const calls: { messages: ChatMsg[] }[] = [];
    const base = await this.llms.get();
    const llm = opts.debug ? recording(base, calls) : base;
    const now = new Date().toISOString();
    const env = { p, repo, llm, now };
    const history = (await repo.history(conv.id, 9)).slice(0, -1);

    const router = await this.ctxs.build(env, ['userContext'], history, opts.debug);
    const uctx = router.ctx.data.userContext as any;
    let route: RouteResult;
    try {
      route = opts.forced ? { skill: opts.forced, by: 'reroute' } : await this.router.route(text, router.ctx, conv.scope, uctx, base.provider);
    } catch (e) {
      this.logger.warn(`router lỗi: ${(e as Error).message}`);
      route = { skill: 'hoi-lai', by: 'fallback' };
    }
    opts.onEvent?.('route', route);

    const skill = this.skills.get(route.skill);
    let result: SkillResult;
    let status = 'ok';
    let traced: { name: string; args?: unknown; data: unknown }[] = [...router.trace];
    const meta: Record<string, unknown> = { route: { by: route.by, score: route.score } };
    if (!skill) {
      result = { reply: 'Việc này mình chưa làm được. Bạn thử ghi thu chi, hỏi số dư hoặc tổng kết tháng nhé.', followUps: ['số dư hiện tại', 'tháng này tiêu bao nhiêu'] };
      status = 'unsupported';
    } else {
      try {
        const built = await this.ctxs.build(env, skill.context ?? [], history, opts.debug, router.ctx.data);
        traced = [...traced, ...built.trace];
        try {
          result = await Promise.race([
            this.skills.run(skill, { input: text, context: built.ctx, llm, now }),
            new Promise<never>((_, rej) => setTimeout(() => rej(new Error(`skill ${skill.name} quá thời gian`)), cfg.timeoutMs * 2 + 1000).unref()),
          ]);
        } finally {
          // provider gọi lười trong lúc skill chạy
          traced = [...router.trace, ...built.trace];
        }
        status = result.askBack ? 'ask' : 'ok';
      } catch (e) {
        this.logger.warn(`skill ${route.skill} lỗi: ${(e as Error).message}`);
        result = { reply: 'Xin lỗi, trợ lý đang bận hoặc gặp lỗi. Bạn thử lại sau ít phút nhé.' };
        status = 'error';
        meta.error = (e as Error).message.slice(0, 300);
      }
    }

    let draftPayload: unknown = null;
    if (result.draft && status === 'ok') {
      if (!this.drafts.has(result.draft.kind)) meta.droppedDraft = result.draft.kind;
      else {
        try {
          draftPayload = await this.drafts.normalize(p, repo, result.draft.kind, result.draft.payload, now);
        } catch (e) {
          meta.droppedDraft = `${result.draft.kind}: ${(e as Error).message}`;
        }
      }
    }
    const sm = result.meta ?? {};
    const msg = await repo.createMessage(conv.id, {
      role: 'ASSISTANT',
      content: result.reply.slice(0, 8000),
      skill: route.skill,
      routeBy: route.by,
      status,
      latencyMs: Date.now() - t0,
      promptTokens: typeof sm.promptTokens === 'number' ? sm.promptTokens : null,
      evalTokens: typeof sm.evalTokens === 'number' ? sm.evalTokens : null,
      meta: JSON.parse(JSON.stringify({ ...meta, skillMeta: sm, followUps: result.followUps ?? [], context: traced.map((t) => t.name), llm: `${llm.provider}:${llm.chatModel}` })) as Prisma.InputJsonValue,
    });
    const draft = draftPayload ? await repo.createDraft(msg.id, route.skill, result.draft!.kind, draftPayload as Prisma.InputJsonValue) : null;
    const message = messageView({ ...msg, draft });
    return {
      message,
      draft: draftView(draft),
      ...(opts.debug ? { debug: { route, context: traced, llmCalls: calls } } : {}),
    };
  }

  /* ============================== nháp ============================== */

  async confirm(p: Principal, id: string, edited?: unknown) {
    const repo = this.store.for(p);
    const d = await repo.getDraft(id);
    const done = (x: AiDraft) => ({ draft: draftView(x), result: x.result, idempotent: true });
    if (d.status === 'CONFIRMED' || d.status === 'EDITED') return done(d);
    if (d.status === 'CANCELLED') throw new ConflictException('Nháp đã bị hủy');
    if (d.status === 'EXECUTING') throw new ConflictException('Nháp đang được thực hiện');
    const now = new Date().toISOString();
    const final = edited !== undefined ? await this.drafts.normalize(p, repo, d.kind, DraftKinds.withTrace(d.kind, d.payload, edited), now) : d.payload;
    const diff = diffPayload(d.kind, d.payload, final);
    const isEdited = edited !== undefined && (d.kind === 'transactions' ? (diff as any).items.length > 0 : Object.keys(diff).length > 0);

    if (!(await repo.transitionDraft(id, ['PROPOSED'], { status: 'EXECUTING' }))) {
      const again = await repo.getDraft(id);
      if (again.status === 'CONFIRMED' || again.status === 'EDITED') return done(again);
      throw new ConflictException('Nháp đang được thực hiện hoặc đã đóng');
    }
    let result: any;
    try {
      result = await this.drafts.execute(p, d.kind, final);
    } catch (e) {
      await repo.transitionDraft(id, ['EXECUTING'], { status: 'PROPOSED' });
      throw e;
    }
    const stored = JSON.parse(JSON.stringify(d.kind === 'search_filter' ? { total: result?.total ?? 0 } : result ?? null));
    await repo.transitionDraft(id, ['EXECUTING'], { status: isEdited ? 'EDITED' : 'CONFIRMED', finalPayload: final as Prisma.InputJsonValue, result: stored ?? Prisma.JsonNull, resolvedAt: new Date() });
    try {
      await this.learning.onDraftResolved(repo, await this.llms.get(), d, isEdited ? 'edited' : 'confirmed', final);
    } catch (e) {
      this.logger.warn(`học từ nháp lỗi: ${(e as Error).message}`);
    }
    return { draft: draftView(await repo.getDraft(id)), result, idempotent: false };
  }

  async cancel(p: Principal, id: string) {
    const repo = this.store.for(p);
    const d = await repo.getDraft(id);
    if (d.status === 'CANCELLED') return { draft: draftView(d), idempotent: true };
    if (!(await repo.transitionDraft(id, ['PROPOSED'], { status: 'CANCELLED', resolvedAt: new Date() }))) {
      throw new ConflictException('Nháp đã được xác nhận hoặc đang thực hiện, không hủy được');
    }
    try {
      await this.learning.onDraftResolved(repo, await this.llms.get(), d, 'cancelled', null);
    } catch (e) {
      this.logger.warn(`ghi tín hiệu hủy lỗi: ${(e as Error).message}`);
    }
    return { draft: draftView(await repo.getDraft(id)), idempotent: false };
  }

  /* ============================== phản hồi / sửa định tuyến ============================== */

  async feedback(p: Principal, messageId: string, dto: { rating: number; comment?: string }) {
    const repo = this.store.for(p);
    const m = await repo.getMessage(messageId);
    if (m.role !== 'ASSISTANT') throw new BadRequestException('Chỉ đánh giá được câu trả lời của trợ lý');
    const f = await repo.upsertFeedback(messageId, 'THUMBS', { skill: m.skill, rating: dto.rating, comment: dto.comment ?? null });
    return { id: f.id, messageId, rating: f.rating, comment: f.comment };
  }

  /** "Ý tôi là…": trả lời lại câu trước bằng skill user chọn + ghi tín hiệu học định tuyến. */
  async reroute(p: Principal, messageId: string, skillName: string, opts: { debug?: boolean } = {}) {
    const repo = this.store.for(p);
    const m = await repo.getMessage(messageId);
    if (m.role !== 'ASSISTANT') throw new BadRequestException('Chỉ sửa định tuyến cho câu trả lời của trợ lý');
    const conv = await repo.getConversation(m.conversationId);
    if (conv.archived) throw new ConflictException('Hội thoại đã lưu trữ');
    if (!this.skills.get(skillName)) throw new BadRequestException(`Không có skill "${skillName}"`);
    if (!this.skills.allowed(skillName, p, conv.scope)) throw new ForbiddenException({ statusCode: 403, code: 'AI_SKILL_FORBIDDEN', message: 'Bạn không dùng được skill này' });
    const q = await repo.previousUserMessage(conv.id, m.createdAt);
    if (!q) throw new BadRequestException('Không tìm thấy câu hỏi để trả lời lại');
    if (m.draft?.status === 'PROPOSED') await repo.transitionDraft(m.draft.id, ['PROPOSED'], { status: 'CANCELLED', resolvedAt: new Date() });
    const llm = await this.llms.get();
    await this.learning.onReroute(repo, llm, m.id, q.content, m.skill, skillName);
    return this.answer(repo, conv, q.content, { forced: skillName, debug: opts.debug });
  }

  settings(p: Principal) {
    return this.store.for(p).getSetting();
  }

  setSettings(p: Principal, shareExamples: boolean) {
    return this.store.for(p).setSetting(shareExamples);
  }

  skillsFor(p: Principal) {
    return this.skills.list(p);
  }

  async memory(p: Principal) {
    return (await this.store.for(p).listMemory()).map((m) => ({ id: m.id, key: m.key, value: m.value, helpful: m.helpful, harmful: m.harmful, source: m.source, lastUsedAt: m.lastUsedAt, updatedAt: m.updatedAt }));
  }

  deleteMemory(p: Principal, id: string) {
    return this.store.for(p).deleteMemory(id);
  }
}
