import { createHash } from 'node:crypto';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';

export const OLLAMA = process.env.OLLAMA_URL ?? 'http://localhost:11434';
export const LLM = process.env.LLM_MODEL ?? 'gemma2:2b';

export interface ChatMsg { role: 'system' | 'user' | 'assistant'; content: string }
export interface ChatResult { content: string; ms: number; promptTokens: number; evalTokens: number }

/**
 * Bỏ các từ khóa JSON schema làm Ollama (0.30, Vulkan) BỎ QUA CẢ GRAMMAR mà không báo lỗi — hiện biết: `pattern`.
 * Ràng buộc kiểu đó phải kiểm bằng code sau khi nhận JSON. Không đổi object gốc.
 */
export const UNSUPPORTED_SCHEMA_KEYS = ['pattern'];
export function stripUnsupported<T>(schema: T): T {
  if (Array.isArray(schema)) return schema.map(stripUnsupported) as T;
  if (!schema || typeof schema !== 'object') return schema;
  // chỉ bỏ TỪ KHÓA (giá trị chuỗi); thuộc tính tên "pattern" trong `properties` (giá trị object) vẫn giữ
  return Object.fromEntries(Object.entries(schema).filter(([k, v]) => !(UNSUPPORTED_SCHEMA_KEYS.includes(k) && typeof v === 'string')).map(([k, v]) => [k, stripUnsupported(v)])) as T;
}

/** stop "\n\n": cắt khoảng trắng rác gemma2 hay sinh sau JSON (đo thực tế: không đổi độ trễ đáng kể, xem results/latency.json). */
export async function chat(messages: ChatMsg[], format: object, numPredict = 256, stop: string[] = ['\n\n']): Promise<ChatResult> {
  const t = performance.now();
  const r = await fetch(`${OLLAMA}/api/chat`, {
    method: 'POST',
    body: JSON.stringify({
      model: LLM, messages, format: stripUnsupported(format), stream: false, keep_alive: '30m',
      options: { temperature: 0, seed: 7, num_ctx: 4096, num_predict: numPredict, stop },
    }),
  });
  if (!r.ok) throw new Error(`ollama chat ${r.status}: ${await r.text()}`);
  const j: any = await r.json();
  return { content: j.message.content, ms: performance.now() - t, promptTokens: j.prompt_eval_count ?? 0, evalTokens: j.eval_count ?? 0 };
}

// nomic-embed-text cần tiền tố tác vụ; bge-m3 thì không.
const PREFIX: Record<string, string> = { 'nomic-embed-text': 'classification: ' };
const CACHE_DIR = new URL('../.cache/', import.meta.url);
const caches = new Map<string, Record<string, number[]>>();

function cacheFor(model: string) {
  if (!caches.has(model)) {
    const f = new URL(`emb-${model.replace(/\W/g, '_')}.json`, CACHE_DIR);
    caches.set(model, existsSync(f) ? JSON.parse(readFileSync(f, 'utf8')) : {});
  }
  return caches.get(model)!;
}

export function saveEmbCache() {
  mkdirSync(CACHE_DIR, { recursive: true });
  for (const [m, c] of caches) writeFileSync(new URL(`emb-${m.replace(/\W/g, '_')}.json`, CACHE_DIR), JSON.stringify(c));
}

/** Embedding (chuẩn hoá L2), có cache đĩa theo model + text. */
export async function embed(model: string, texts: string[], useCache = true): Promise<number[][]> {
  const c = cacheFor(model);
  const key = (t: string) => createHash('sha1').update(t).digest('hex');
  const miss = texts.filter((t) => !useCache || !c[key(t)]);
  for (let i = 0; i < miss.length; i += 32) {
    const batch = miss.slice(i, i + 32);
    const r = await fetch(`${OLLAMA}/api/embed`, {
      method: 'POST',
      body: JSON.stringify({ model, input: batch.map((t) => (PREFIX[model] ?? '') + t), keep_alive: '30m' }),
    });
    if (!r.ok) throw new Error(`ollama embed ${r.status}: ${await r.text()}`);
    const j: any = await r.json();
    batch.forEach((t, k) => (c[key(t)] = norm(j.embeddings[k])));
  }
  return texts.map((t) => c[key(t)]);
}

const norm = (v: number[]) => { const n = Math.hypot(...v) || 1; return v.map((x) => x / n); };
export const cos = (a: number[], b: number[]) => a.reduce((s, x, i) => s + x * b[i], 0);
