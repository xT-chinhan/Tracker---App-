import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import type { GhiCase, UserContext } from '../lib/types.js';
import { ExampleBank, type Example } from '../learn/store.js';
import { parse } from '../parser/index.js';

export const load = <T>(rel: string): T => JSON.parse(readFileSync(new URL(rel, import.meta.url), 'utf8'));
export const ctx = load<UserContext>('./user-context.json');
export const ghi = (split: string) => load<GhiCase[]>(`./data/ghi.${split}.json`);

export function arg(name: string, def: string) {
  const i = process.argv.indexOf(`--${name}`);
  return i > 0 ? process.argv[i + 1] : def;
}

export function writeResult(name: string, data: unknown) {
  mkdirSync(new URL('../results/', import.meta.url), { recursive: true });
  writeFileSync(new URL(`../results/${name}`, import.meta.url), JSON.stringify(data, null, 1) + '\n');
}

/** Ví dụ khởi đầu dạng Example (clean tính bằng parser như lúc chạy thật). */
export function seedExamples(n = Infinity): Example[] {
  return load<{ text: string; title: string; categoryName: string }[]>('./data/bank.seed.json')
    .slice(0, n)
    .map((e) => ({ ...e, clean: parse(e.text, ctx)[0]?.clean ?? e.text, source: 'seed' as const }));
}

export async function bankOf(model: string, ex: Example[]) {
  const b = new ExampleBank(model);
  for (const e of ex) await b.add(e);
  return b;
}

export function table(rows: Record<string, unknown>[]) {
  const cols = Object.keys(rows[0]);
  const w = cols.map((c) => Math.max(c.length, ...rows.map((r) => String(r[c]).length)));
  const line = (v: string[]) => '| ' + v.map((x, i) => x.padEnd(w[i])).join(' | ') + ' |';
  return [line(cols), '|' + w.map((n) => '-'.repeat(n + 2)).join('|') + '|', ...rows.map((r) => line(cols.map((c) => String(r[c]))))].join('\n');
}

export const pctl = (xs: number[], p: number) => {
  const s = [...xs].sort((a, b) => a - b);
  return s.length ? Math.round(s[Math.min(s.length - 1, Math.floor((p / 100) * s.length))]) : 0;
};
