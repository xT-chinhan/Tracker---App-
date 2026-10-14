/** Danh bạ skill Track B theo tên (eval + kiểm tra scope). Backend dùng `ai/skills/index.ts`. */
import type { Skill } from '../lib/contracts.js';
import { TRACK_B_SKILLS } from '../skills/index.js';

export const SKILLS: Record<string, Skill> = Object.fromEntries(TRACK_B_SKILLS.map((s) => [s.name, s]));

/** Skill có chạy được trong phiên scope này không. Chặt hơn backend: skill USER cũng KHÔNG chạy trong phiên ADMIN. */
export const allowed = (name: string, scope: 'USER' | 'ADMIN') => {
  if (name === 'ghi-giao-dich') return scope === 'USER';
  const s = SKILLS[name];
  return !!s && (s.scope === 'ANY' || s.scope === scope);
};
