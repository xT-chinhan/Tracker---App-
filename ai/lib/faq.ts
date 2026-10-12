/** Tra FAQ tĩnh bằng từ khóa (bỏ dấu) → top-k; model chỉ chọn 1 id trong top-k (enum). Câu trả lời lấy nguyên văn FAQ. */
import type { Llm, SkillResult } from './contracts.js';
import { llmJson } from './skillkit.js';
import { fold } from './text.js';

export interface FaqEntry { id: string; title: string; keywords: string[]; answer: string }

const STOP = new Set('lam sao the nao nhu nao cach huong dan o dau toi minh em ban co khong duoc the cho voi mot cai nay do de muon can phai bam vao dung gi la va hay thi khi nao app ung dung'.split(' '));

export function score(text: string, e: FaqEntry): number {
  const f = ` ${fold(text).replace(/[^a-z0-9]+/g, ' ')} `;
  let s = 0;
  for (const k of e.keywords) if (f.includes(` ${fold(k)} `)) s += fold(k).split(' ').length * 2;
  const words = new Set(f.trim().split(' ').filter((w) => w.length > 1 && !STOP.has(w)));
  const tw = new Set(fold(e.title).split(/[^a-z0-9]+/).filter((w) => w.length > 1 && !STOP.has(w)));
  for (const w of words) if (tw.has(w)) s += 1;
  return s;
}

export function topK(text: string, faq: FaqEntry[], k = 3) {
  return faq.map((e) => ({ e, s: score(text, e) })).filter((x) => x.s > 0).sort((a, b) => b.s - a.s).slice(0, k);
}

export async function answerFaq(text: string, faq: FaqEntry[], llm: Llm, notFound: string, topics: string[]): Promise<SkillResult & { meta: any }> {
  const top = topK(text, faq);
  if (!top.length) return { reply: notFound, followUps: topics.slice(0, 3), askBack: notFound, meta: { faq: null, llm: { calls: 0, ms: 0, accepted: null } } };
  let pick = top[0].e, ms = 0, calls = 0, accepted: boolean | null = null;
  // Chỉ hỏi model khi 2 ứng viên đầu sát điểm nhau; còn lại code chọn.
  if (top.length > 1 && top[1].s >= top[0].s - 1) {
    const ids = top.map((x) => x.e.id);
    const r = await llmJson<{ id: string }>(llm,
      'Chọn MỘT mục hướng dẫn khớp nhất với câu hỏi. Chỉ trả JSON {"id": ...}.',
      `Câu hỏi: «${text}»\nCác mục:\n${top.map((x) => `- ${x.e.id}: ${x.e.title}`).join('\n')}`,
      { type: 'object', properties: { id: { type: 'string', enum: ids } }, required: ['id'] }, 30);
    ms = r.ms; calls = 1;
    const hit = top.find((x) => x.e.id === r.data?.id);
    accepted = !!hit;
    if (hit) pick = hit.e;
  }
  const others = top.filter((x) => x.e.id !== pick.id).map((x) => x.e.title);
  return { reply: `${pick.title}:\n${pick.answer}`, followUps: others.slice(0, 2), meta: { faq: pick.id, candidates: top.map((x) => x.e.id), llm: { calls, ms: Math.round(ms), accepted } } };
}
