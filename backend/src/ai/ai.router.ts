/**
 * Định tuyến câu → skill THEO SCOPE của hội thoại (USER | ADMIN):
 *   luật học được ("ý tôi là…") → [USER] đặt ngân sách → `routeRulesScoped` của ai/router (chặn injection / ngoài phạm vi /
 *   hỏi dữ liệu người khác + luật của scope) → kNN trên câu mẫu CỦA SCOPE (chung + của user) → hỏi lại.
 * Kết quả luôn được `guard`: skill không thuộc scope (hoặc principal không đủ quyền) → ngoai-pham-vi.
 */
import { Injectable } from '@nestjs/common';
import { aiLib, type AiUserContext } from './ai.external';
import { SkillRegistry } from './ai.skills';
import { fold, norm } from './ai.text';
import type { RouteResult, SkillContext } from './ai.types';

/** Ngưỡng kNN với FAKE embedding (trigram băm); Ollama dùng DEFAULT_THRESHOLD của Track B (bge-m3, 0.6) */
export const KNN_MIN_SCORE_FAKE = 0.35;
export const KNN_MIN_SCORE_FALLBACK = 0.6;

/** Router dự phòng khi không nạp được ai/router (vd thiếu thư mục ai/): chỉ luật admin tối thiểu */
const ADMIN_FALLBACK: [string, RegExp][] = [
  ['soan-thong-bao', /\b(gui|soan|viet) (thong bao|broadcast)|thong bao cho (tat ca|moi nguoi)\b/],
  ['de-xuat-khoa', /\b(khoa (tai khoan|user|nguoi dung|tk)|lock user)\b/],
  ['tra-cuu-nguoi-dung', /\b(tim (user|nguoi dung|tai khoan))\b/],
  ['phat-hien-bat-thuong', /\b(bat thuong|dang ngo|kha nghi)\b/],
  ['tom-tat-cau-hinh', /\b(lich su cau hinh|thay doi cau hinh)\b/],
  ['tong-quan-he-thong', /\b(tong quan|thong ke he thong)\b/],
];
const BUDGET_SET = /\b(dat|tao|lap|dat lai|sua) (ngan sach|han muc)\b/;

@Injectable()
export class AiRouter {
  constructor(private readonly skills: SkillRegistry) {}

  async route(text: string, ctx: SkillContext, convScope: 'USER' | 'ADMIN', uctx: AiUserContext, embedProvider: 'ollama' | 'fake' = 'fake'): Promise<RouteResult> {
    const p = { id: ctx.principal.id, role: ctx.principal.role, email: '', name: ctx.principal.name };
    const guard = (r: RouteResult): RouteResult => (this.skills.allowed(r.skill, p, convScope) || !this.skills.get(r.skill) ? r : { skill: 'ngoai-pham-vi', by: 'guard' });
    const f = fold(text);
    const key = norm(text);

    // 1) "ý tôi là…" của chính user: khớp nguyên câu đã chuẩn hóa (còn dấu)
    const learned = await ctx.get<{ pattern: string; value: string }[]>('userRules', { kind: 'route', skill: 'router' });
    const hit = learned.find((r) => r.pattern === key && this.skills.allowed(r.value, p, convScope));
    if (hit) return { skill: hit.value, by: 'learned' };

    // 2) luật
    const lib = await aiLib();
    if (convScope === 'USER' && BUDGET_SET.test(f) && !/\b(goi y|de xuat|nen)\b/.test(f)) return { skill: 'dat-ngan-sach', by: 'rule' };
    if (lib?.routeRulesScoped) {
      const r = lib.routeRulesScoped(text, convScope);
      if (r) return guard({ skill: r.skill, by: r.by === 'guard' ? 'guard' : 'rule' });
    } else if (convScope === 'ADMIN') {
      for (const [skill, re] of ADMIN_FALLBACK) if (re.test(f)) return guard({ skill, by: 'rule' });
    } else {
      const r = lib?.routeRules?.(text, uctx);
      if (r) return guard({ skill: r.skill, by: 'rule' });
    }

    // 3) kNN trên câu mẫu của scope (chung) + câu user đã sửa định tuyến; chỉ giữ skill dùng được trong scope
    const [nn] = await ctx.get<{ output: any; score: number }[][]>('similarExamples', { skill: 'router', texts: [key], k: 25 });
    const inScope = (nn ?? []).filter((x) => typeof x.output?.skill === 'string' && (!x.output.scope || x.output.scope === convScope) && this.skills.allowed(x.output.skill, p, convScope)).slice(0, 5);
    const min = embedProvider === 'fake' ? KNN_MIN_SCORE_FAKE : (lib?.DEFAULT_THRESHOLD ?? KNN_MIN_SCORE_FALLBACK);
    if (inScope.length && inScope[0].score >= min) {
      const votes = new Map<string, number>();
      for (const x of inScope) votes.set(x.output.skill, (votes.get(x.output.skill) ?? 0) + x.score);
      const best = [...votes.entries()].sort((a, b) => b[1] - a[1])[0];
      return guard({ skill: best[0], by: 'knn', score: Math.round(inScope[0].score * 1000) / 1000 });
    }
    return { skill: 'hoi-lai', by: 'fallback', score: inScope[0] ? Math.round(inScope[0].score * 1000) / 1000 : undefined };
  }
}
