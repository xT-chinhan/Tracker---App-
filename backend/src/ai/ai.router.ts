/**
 * Định tuyến câu → skill: luật học được ("ý tôi là…") → luật admin → luật từ khóa (ai/router) → kNN câu mẫu → hỏi lại.
 * Skill admin chỉ chọn được khi principal là ADMIN trong hội thoại phạm vi ADMIN; ngoài ra → ngoai-pham-vi (by 'guard').
 */
import { Injectable } from '@nestjs/common';
import { aiLib, type AiUserContext } from './ai.external';
import { SkillRegistry } from './ai.skills';
import { fold, norm } from './ai.text';
import type { RouteResult, SkillContext } from './ai.types';

/** Điểm cosine top-1 tối thiểu của kNN (bge-m3 chọn trên dev: 0.30 — xem ai/results/BENCHMARK-2026-10-08.md) */
export const KNN_MIN_SCORE = 0.35;

const ADMIN_RULES: [string, RegExp][] = [
  ['admin-gui-thong-bao', /\b(gui (thong bao|broadcast)|thong bao cho (tat ca|moi nguoi))\b/],
  ['admin-khoa-user', /\b(khoa (tai khoan|user|nguoi dung|tk)|lock user)\b/],
  ['admin-tim-user', /\b(tim (user|nguoi dung|tai khoan)|user nao|nguoi dung nao)\b/],
  ['admin-bat-thuong', /\b(bat thuong|dang ngo|kha nghi|spam)\b/],
  ['admin-lich-su-cau-hinh', /\b(lich su cau hinh|doi cau hinh|thay doi cau hinh)\b/],
  ['admin-tong-quan', /\b(tong quan|thong ke he thong|bao nhieu (user|nguoi dung))\b/],
];
const BUDGET_SET = /\b(dat|tao|lap|dat lai|sua) (ngan sach|han muc)\b/;

@Injectable()
export class AiRouter {
  constructor(private readonly skills: SkillRegistry) {}

  async route(text: string, ctx: SkillContext, convScope: 'USER' | 'ADMIN', uctx: AiUserContext): Promise<RouteResult> {
    const p = { id: ctx.principal.id, role: ctx.principal.role, email: '', name: ctx.principal.name };
    const guard = (r: RouteResult): RouteResult => (this.skills.get(r.skill) && !this.skills.allowed(r.skill, p, convScope) ? { skill: 'ngoai-pham-vi', by: 'guard' } : r);
    const f = fold(text);

    // 1) Luật học được từ "ý tôi là…": khớp nguyên câu đã chuẩn hóa (còn dấu)
    const learned = await ctx.get<{ pattern: string; value: string }[]>('userRules', { kind: 'route', skill: 'router' });
    const key = norm(text);
    const hit = learned.find((r) => r.pattern === key);
    if (hit) return guard({ skill: hit.value, by: 'learned' });

    // 2) Skill admin (chỉ trong hội thoại admin của admin)
    if (p.role === 'ADMIN' && convScope === 'ADMIN') {
      for (const [skill, re] of ADMIN_RULES) if (re.test(f)) return { skill, by: 'rule' };
    }

    // 3) Luật từ khóa
    if (BUDGET_SET.test(f)) return { skill: 'dat-ngan-sach', by: 'rule' };
    const lib = await aiLib();
    const r = lib?.routeRules?.(text, uctx);
    if (r) return guard({ skill: r.skill, by: 'rule' });

    // 4) kNN trên câu mẫu (của user từ reroute + chung)
    const [nn] = await ctx.get<{ output: any; score: number }[][]>('similarExamples', { skill: 'router', texts: [key], k: 5 });
    if (nn?.length && nn[0].score >= KNN_MIN_SCORE) {
      const votes = new Map<string, number>();
      for (const x of nn) if (typeof x.output?.skill === 'string') votes.set(x.output.skill, (votes.get(x.output.skill) ?? 0) + x.score);
      const best = [...votes.entries()].sort((a, b) => b[1] - a[1])[0];
      if (best) return guard({ skill: best[0], by: 'knn', score: Math.round(nn[0].score * 1000) / 1000 });
    }
    return { skill: 'hoi-lai', by: 'fallback', score: nn?.[0] ? Math.round(nn[0].score * 1000) / 1000 : undefined };
  }
}
