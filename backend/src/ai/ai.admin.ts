/**
 * Trung tâm học AI cho admin. Chỉ số liệu tổng hợp + dữ liệu CHUNG đã ẩn danh.
 * KHÔNG có đường nào trả nội dung tin nhắn / nháp / trí nhớ / luật riêng của user (usage chỉ là số đếm).
 */
import { Injectable, NotFoundException } from '@nestjs/common';
import { AiKnowledgeStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import type { AuthUser } from '../common/auth';
import { AiLearningService } from './ai.learning';
import { GLOBAL } from './ai.store';

const pct = (a: number, b: number) => (b ? Math.round((a / b) * 1000) / 10 : null);

@Injectable()
export class AiAdminService {
  constructor(private readonly prisma: PrismaService, private readonly learning: AiLearningService) {}

  /** Theo skill: số tin, độ trễ (avg / p50 / p95), lỗi; nháp: tỉ lệ chấp nhận không sửa; theo ngày (giờ VN). */
  async stats(days: number) {
    const since = new Date(Date.now() - days * 86400_000);
    const perSkill = await this.prisma.$queryRaw<{ skill: string | null; messages: number; errors: number; asks: number; avg: number | null; p50: number | null; p95: number | null }[]>`
      SELECT "skill", count(*)::int AS messages,
             (count(*) FILTER (WHERE "status" = 'error'))::int AS errors,
             (count(*) FILTER (WHERE "status" = 'ask'))::int AS asks,
             avg("latencyMs")::float AS avg,
             percentile_cont(0.5) WITHIN GROUP (ORDER BY "latencyMs")::float AS p50,
             percentile_cont(0.95) WITHIN GROUP (ORDER BY "latencyMs")::float AS p95
      FROM "AiMessage" WHERE "role" = 'ASSISTANT' AND "createdAt" >= ${since}
      GROUP BY "skill" ORDER BY messages DESC`;
    const drafts = await this.prisma.aiDraft.groupBy({ by: ['skill', 'status'], where: { createdAt: { gte: since } }, _count: true });
    const daily = await this.prisma.$queryRaw<{ day: string; skill: string; confirmed: number; edited: number; cancelled: number; proposed: number }[]>`
      SELECT to_char("createdAt" + interval '7 hour', 'YYYY-MM-DD') AS day, "skill",
             (count(*) FILTER (WHERE "status" = 'CONFIRMED'))::int AS confirmed,
             (count(*) FILTER (WHERE "status" = 'EDITED'))::int AS edited,
             (count(*) FILTER (WHERE "status" = 'CANCELLED'))::int AS cancelled,
             (count(*) FILTER (WHERE "status" = 'PROPOSED'))::int AS proposed
      FROM "AiDraft" WHERE "createdAt" >= ${since} GROUP BY 1, 2 ORDER BY 1, 2`;
    const volume = await this.prisma.$queryRaw<{ day: string; messages: number; users: number }[]>`
      SELECT to_char("createdAt" + interval '7 hour', 'YYYY-MM-DD') AS day, count(*)::int AS messages, count(DISTINCT "userId")::int AS users
      FROM "AiMessage" WHERE "role" = 'USER' AND "createdAt" >= ${since} GROUP BY 1 ORDER BY 1`;
    const fb = await this.prisma.aiFeedback.groupBy({ by: ['kind', 'rating', 'skill'], where: { createdAt: { gte: since }, kind: { in: ['THUMBS', 'REROUTE'] } }, _count: true });
    const d = (skill: string | null, st: string) => drafts.find((x) => x.skill === skill && x.status === st)?._count ?? 0;
    const skills = [...new Set([...perSkill.map((r) => r.skill), ...drafts.map((x) => x.skill)])];
    return {
      days,
      since,
      skills: skills.map((skill) => {
        const m = perSkill.find((r) => r.skill === skill);
        const confirmed = d(skill, 'CONFIRMED'), edited = d(skill, 'EDITED'), cancelled = d(skill, 'CANCELLED');
        return {
          skill,
          messages: m?.messages ?? 0,
          errors: m?.errors ?? 0,
          askBacks: m?.asks ?? 0,
          latencyMs: { avg: m?.avg != null ? Math.round(m.avg) : null, p50: m?.p50 != null ? Math.round(m.p50) : null, p95: m?.p95 != null ? Math.round(m.p95) : null },
          drafts: { proposed: d(skill, 'PROPOSED'), confirmed, edited, cancelled },
          acceptanceWithoutEditRate: pct(confirmed, confirmed + edited + cancelled),
          thumbsUp: fb.filter((x) => x.kind === 'THUMBS' && x.skill === skill && (x.rating ?? 0) > 0).reduce((s, x) => s + x._count, 0),
          thumbsDown: fb.filter((x) => x.kind === 'THUMBS' && x.skill === skill && (x.rating ?? 0) < 0).reduce((s, x) => s + x._count, 0),
          reroutedAway: fb.filter((x) => x.kind === 'REROUTE' && x.skill === skill).reduce((s, x) => s + x._count, 0),
        };
      }),
      daily: daily.map((r) => ({ ...r, acceptanceWithoutEditRate: pct(r.confirmed, r.confirmed + r.edited + r.cancelled) })),
      volume,
    };
  }

  async rules(q: { status?: AiKnowledgeStatus; skill?: string; q?: string; page: number; limit: number }) {
    const where: Prisma.AiRuleWhereInput = { scope: 'GLOBAL', status: q.status, skill: q.skill, pattern: q.q ? { contains: q.q } : undefined };
    const [items, total] = await this.prisma.$transaction([
      this.prisma.aiRule.findMany({ where, orderBy: [{ status: 'asc' }, { userCount: 'desc' }, { support: 'desc' }], skip: (q.page - 1) * q.limit, take: q.limit, select: { id: true, kind: true, skill: true, pattern: true, value: true, support: true, helpful: true, harmful: true, userCount: true, precision: true, status: true, approvedById: true, approvedAt: true, evalReport: true, createdAt: true, updatedAt: true } }),
      this.prisma.aiRule.count({ where }),
    ]);
    return { items, total, page: q.page, limit: q.limit };
  }

  async examples(q: { status?: AiKnowledgeStatus; skill?: string; q?: string; page: number; limit: number }) {
    const where: Prisma.AiExampleWhereInput = { scope: 'GLOBAL', status: q.status, skill: q.skill, inputNorm: q.q ? { contains: q.q } : undefined };
    const [items, total] = await this.prisma.$transaction([
      this.prisma.aiExample.findMany({ where, orderBy: [{ status: 'asc' }, { userCount: 'desc' }, { updatedAt: 'desc' }], skip: (q.page - 1) * q.limit, take: q.limit, select: { id: true, skill: true, input: true, output: true, confirmations: true, userCount: true, status: true, approvedById: true, approvedAt: true, evalReport: true, createdAt: true, updatedAt: true } }),
      this.prisma.aiExample.count({ where }),
    ]);
    return { items, total, page: q.page, limit: q.limit };
  }

  /** Duyệt / từ chối chỉ áp cho dữ liệu CHUNG (id luật riêng của user → 404). */
  async decideRule(actor: AuthUser, id: string, approve: boolean) {
    const r = await this.prisma.aiRule.findFirst({ where: { id, scope: 'GLOBAL' } });
    if (!r) throw new NotFoundException('Không tìm thấy luật chung');
    return this.prisma.aiRule.update({ where: { id }, data: { status: approve ? 'ACTIVE' : 'REJECTED', approvedById: actor.id, approvedAt: new Date() } });
  }

  async decideExample(actor: AuthUser, id: string, approve: boolean) {
    const x = await this.prisma.aiExample.findFirst({ where: { id, scope: 'GLOBAL' } });
    if (!x) throw new NotFoundException('Không tìm thấy ví dụ chung');
    const out = await this.prisma.aiExample.update({ where: { id }, data: { status: approve ? 'ACTIVE' : 'REJECTED', approvedById: actor.id, approvedAt: new Date() }, select: { id: true, skill: true, input: true, output: true, status: true, approvedAt: true } });
    const cat = (x.output as any)?.categoryName;
    if (approve && x.skill === 'ghi-giao-dich' && cat) await this.learning.addEvalCase(x.inputNorm, cat);
    return out;
  }

  runLearning(trigger: string) {
    return this.learning.run(trigger);
  }

  async runs(limit: number) {
    return this.prisma.aiLearningRun.findMany({ orderBy: { startedAt: 'desc' }, take: limit });
  }

  /** Mức dùng theo user: CHỈ số đếm, không nội dung. */
  async usage(q: { q?: string; page: number; limit: number }) {
    const users = q.q
      ? await this.prisma.user.findMany({ where: { OR: [{ email: { contains: q.q, mode: 'insensitive' } }, { name: { contains: q.q, mode: 'insensitive' } }] }, select: { id: true } })
      : null;
    const where: Prisma.AiMessageWhereInput = { role: 'USER', ...(users ? { userId: { in: users.map((u) => u.id) } } : {}) };
    const msgs = await this.prisma.aiMessage.groupBy({ by: ['userId'], where, _count: true, _max: { createdAt: true } });
    msgs.sort((a, b) => b._count - a._count);
    const page = msgs.slice((q.page - 1) * q.limit, q.page * q.limit);
    const ids = page.map((m) => m.userId);
    const [info, convs, drafts, today] = await Promise.all([
      this.prisma.user.findMany({ where: { id: { in: ids } }, select: { id: true, email: true, name: true, role: true, status: true } }),
      this.prisma.aiConversation.groupBy({ by: ['userId'], where: { userId: { in: ids } }, _count: true }),
      this.prisma.aiDraft.groupBy({ by: ['userId', 'status'], where: { userId: { in: ids } }, _count: true }),
      this.prisma.aiMessage.groupBy({ by: ['userId'], where: { userId: { in: ids }, role: 'USER', createdAt: { gte: new Date(Date.now() - 86400_000) } }, _count: true }),
    ]);
    return {
      items: page.map((m) => {
        const dr = (st: string) => drafts.find((x) => x.userId === m.userId && x.status === st)?._count ?? 0;
        return {
          user: info.find((u) => u.id === m.userId) ?? null,
          messages: m._count,
          messages24h: today.find((x) => x.userId === m.userId)?._count ?? 0,
          conversations: convs.find((x) => x.userId === m.userId)?._count ?? 0,
          drafts: { confirmed: dr('CONFIRMED'), edited: dr('EDITED'), cancelled: dr('CANCELLED'), proposed: dr('PROPOSED') },
          lastActiveAt: m._max.createdAt,
        };
      }),
      total: msgs.length,
      page: q.page,
      limit: q.limit,
    };
  }

  /** Số dòng AI theo userId (kể cả khi user đã bị xóa → kiểm chứng xóa dây chuyền). */
  async usageOf(userId: string) {
    const w = { userId };
    const [exists, conversations, messages, drafts, feedback, memory, examples, rules] = await Promise.all([
      this.prisma.user.count({ where: { id: userId } }),
      this.prisma.aiConversation.count({ where: w }),
      this.prisma.aiMessage.count({ where: w }),
      this.prisma.aiDraft.count({ where: w }),
      this.prisma.aiFeedback.count({ where: w }),
      this.prisma.aiMemory.count({ where: w }),
      this.prisma.aiExample.count({ where: w }),
      this.prisma.aiRule.count({ where: w }),
    ]);
    return { userId, exists: exists > 0, conversations, messages, drafts, feedback, memory, examples, rules };
  }

  /** Dữ liệu chung có dính userId nào không (bất biến ẩn danh, dùng cho e2e / giám sát). */
  async globalIntegrity() {
    const [rulesWithUser, examplesWithUser] = await Promise.all([
      this.prisma.aiRule.count({ where: { ownerKey: GLOBAL, NOT: { userId: null } } }),
      this.prisma.aiExample.count({ where: { ownerKey: GLOBAL, NOT: { userId: null } } }),
    ]);
    return { rulesWithUser, examplesWithUser };
  }
}
