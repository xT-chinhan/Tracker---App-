/**
 * Client LLM: Ollama (timeout, retry lỗi mạng/5xx, hàng đợi 1 request/lúc vì OLLAMA_NUM_PARALLEL=1) và FAKE tất định cho test.
 * `chatJson` = gọi có JSON schema + sửa JSON hỏng không cần LLM + retry 1 lần kèm lỗi.
 */
import type { ChatMsg, ChatOptions, ChatResult, LlmClient } from './ai.types';
import { fold, l2 } from './ai.text';

/* ============================== Hàng đợi GPU (trong tiến trình) ============================== */

let chain: Promise<unknown> = Promise.resolve();

/** Giữ model trong GPU bao lâu sau lần gọi cuối (Ollama keep_alive). Lâu hơn = ít bị nạp lại (lần đầu ~7–16 s); "-1" = giữ mãi. */
export const KEEP_ALIVE = process.env.AI_KEEP_ALIVE || '12h';
/** Chạy tuần tự mọi lời gọi Ollama của instance này (GPU 1 luồng: gọi song song chỉ làm tăng độ trễ và dễ timeout). */
function serial<T>(fn: () => Promise<T>): Promise<T> {
  const next = chain.then(fn, fn);
  chain = next.catch(() => undefined);
  return next;
}

export class LlmError extends Error {
  constructor(message: string, readonly code: 'TIMEOUT' | 'UNAVAILABLE' | 'BAD_RESPONSE') {
    super(message);
  }
}

/* ============================== Ollama ============================== */

export class OllamaClient implements LlmClient {
  readonly provider = 'ollama' as const;
  constructor(
    private readonly url: string,
    readonly chatModel: string,
    readonly embedModel: string,
    private readonly timeoutMs: number,
    private readonly retries = 2,
  ) {}

  private async post(path: string, body: unknown): Promise<any> {
    let last: Error | null = null;
    for (let attempt = 0; attempt <= this.retries; attempt++) {
      try {
        const r = await fetch(`${this.url.replace(/\/$/, '')}${path}`, {
          method: 'POST',
          headers: { 'content-type': 'application/json' },
          body: JSON.stringify(body),
          signal: AbortSignal.timeout(this.timeoutMs),
        });
        if (r.status >= 500) throw new LlmError(`ollama ${path} ${r.status}: ${(await r.text()).slice(0, 200)}`, 'UNAVAILABLE');
        if (!r.ok) throw new LlmError(`ollama ${path} ${r.status}: ${(await r.text()).slice(0, 200)}`, 'BAD_RESPONSE');
        return await r.json();
      } catch (e) {
        const err = e as Error;
        // Hết giờ: không thử lại (GPU đang bận, thử lại chỉ dồn hàng); 4xx: lỗi cấu hình, không thử lại
        if (err.name === 'TimeoutError' || err.name === 'AbortError') throw new LlmError(`ollama ${path} quá ${this.timeoutMs}ms`, 'TIMEOUT');
        if (err instanceof LlmError && err.code === 'BAD_RESPONSE') throw err;
        last = err instanceof LlmError ? err : new LlmError(`ollama ${path}: ${err.message}`, 'UNAVAILABLE');
        if (attempt < this.retries) await new Promise((res) => setTimeout(res, 300 * (attempt + 1)));
      }
    }
    throw last!;
  }

  chat(messages: ChatMsg[], opts: ChatOptions = {}): Promise<ChatResult> {
    return serial(async () => {
      const t = performance.now();
      const j = await this.post('/api/chat', {
        model: this.chatModel,
        messages,
        format: opts.format,
        stream: false,
        keep_alive: KEEP_ALIVE,
        // qwen3.5 mặc định "suy nghĩ" trước khi trả lời: chậm và có thể làm hỏng JSON → tắt (model không có chế độ này bỏ qua cờ)
        think: false,
        options: { temperature: opts.temperature ?? 0, seed: 7, num_ctx: 4096, num_predict: opts.numPredict ?? 256, stop: opts.stop ?? ['\n\n'] },
      });
      return { content: String(j?.message?.content ?? ''), ms: performance.now() - t, promptTokens: j.prompt_eval_count ?? 0, evalTokens: j.eval_count ?? 0 };
    });
  }

  embed(texts: string[]): Promise<number[][]> {
    if (!texts.length) return Promise.resolve([]);
    return serial(async () => {
      const out: number[][] = [];
      for (let i = 0; i < texts.length; i += 32) {
        const j = await this.post('/api/embed', { model: this.embedModel, input: texts.slice(i, i + 32), keep_alive: KEEP_ALIVE });
        if (!Array.isArray(j?.embeddings)) throw new LlmError('ollama embed: thiếu embeddings', 'BAD_RESPONSE');
        out.push(...j.embeddings.map((v: number[]) => l2(v)));
      }
      return out;
    });
  }
}

/* ============================== FAKE (tất định) ============================== */

/** Từ khóa (bỏ dấu) → danh mục, đủ cho e2e. */
const FAKE_CATS: [RegExp, string][] = [
  [/\b(ca phe|cafe|tra sua|tra da|an|com|pho|bun|banh|nuoc ngot|lau|nhau|bia)\b/, 'Ăn uống'],
  [/\b(grab|xang|taxi|be|gui xe|ve xe|xe om)\b/, 'Di chuyển'],
  [/\b(dien|internet|cuoc|wifi)\b/, 'Hóa đơn'],
  [/\b(ao|giay|shopee|lazada|quan)\b/, 'Mua sắm'],
  [/\b(thuoc|kham|gym)\b/, 'Sức khỏe'],
  [/\b(phim|netflix|game|karaoke)\b/, 'Giải trí'],
  [/\b(luong)\b/, 'Lương'],
  [/\b(thuong)\b/, 'Thưởng'],
];

/**
 * LLM giả: trả JSON hợp lệ theo `format` (schema) một cách tất định.
 * - Schema ghi-giao-dich (items[].categoryName enum): đọc danh sách "Các khoản" trong tin user cuối, đoán danh mục theo từ khóa.
 * - "FAKE_LLM_BROKEN": JSON kèm rác + dấu phẩy thừa (repairJson cứu được); "FAKE_LLM_GARBAGE": lần đầu không có JSON (phải retry).
 * - Không có schema: câu trả lời mẫu.
 * Embedding = băm trigram ký tự (đã bỏ dấu) vào 256 chiều → câu giống nhau có cosine cao.
 */
export class FakeLlm implements LlmClient {
  readonly provider = 'fake' as const;
  readonly chatModel = 'fake-chat';
  readonly embedModel = 'fake-embed';
  calls = 0;

  async chat(messages: ChatMsg[], opts: ChatOptions = {}): Promise<ChatResult> {
    this.calls++;
    const isRetry = (m: ChatMsg) => m.role === 'user' && m.content.startsWith('Lỗi:');
    const lastUser = [...messages].reverse().find((m) => m.role === 'user' && !isRetry(m))?.content ?? '';
    const prompt = messages.map((m) => m.content).join('\n');
    const done = (content: string): ChatResult => ({ content, ms: 1, promptTokens: Math.ceil(prompt.length / 4), evalTokens: Math.ceil(content.length / 4) });
    const firstTry = !messages.some(isRetry);
    if (!opts.format) return done('Đây là câu trả lời mẫu của trợ lý (FAKE).');
    const value = this.fill(opts.format as Schema, lastUser);
    const json = JSON.stringify(value);
    // FAKE_LLM_GARBAGE: lần đầu không có JSON → skill phải retry kèm lỗi
    if (firstTry && lastUser.includes('FAKE_LLM_GARBAGE')) return done('xin lỗi, tôi không hiểu');
    // FAKE_LLM_BROKEN: rác đầu/cuối + dấu phẩy thừa → repairJson phải cứu được ngay lần đầu
    if (lastUser.includes('FAKE_LLM_BROKEN')) return done(`Kết quả: ${json.replace(/\]\}$/, ',]}')} xong`);
    return done(json);
  }

  private fill(schema: Schema, userText: string): unknown {
    const itemsSchema = schema.properties?.items;
    // enum chung (`items`) hoặc enum riêng từng khoản (`prefixItems`)
    const enumAt = (i: number) => (itemsSchema?.prefixItems?.[i] ?? itemsSchema?.items)?.properties?.categoryName?.enum as string[] | undefined;
    if (itemsSchema?.type === 'array' && enumAt(0)) {
      const lines = [...userText.matchAll(/^\d+\.\s+(.*?)(?:\s+\((?:THU|CHI)\))?$/gm)].map((m) => m[1]);
      const segs = lines.length ? lines : [userText];
      return {
        items: segs.map((line, i) => {
          const catEnum = enumAt(i) ?? enumAt(0)!;
          const f = fold(line);
          const hit = FAKE_CATS.find(([re, cat]) => re.test(f) && catEnum.includes(cat))?.[1];
          const words = line.replace(/[0-9][0-9.,]*\s*(k|tr|triệu|nghìn|ngàn|đ|củ)?\b/giu, ' ').replace(/[^\p{L}\s]/gu, ' ').trim().split(/\s+/).filter(Boolean).slice(0, 3);
          const title = words.length ? words.join(' ').replace(/^./u, (c) => c.toUpperCase()) : 'Khoản chi';
          return { title, categoryName: hit ?? (catEnum.includes('Chi khác') ? 'Chi khác' : catEnum[0]) };
        }),
      };
    }
    return this.generic(schema);
  }

  private generic(s: Schema): unknown {
    if (s.enum) return s.enum[0];
    if (s.anyOf) return this.generic(s.anyOf[0]);
    switch (s.type) {
      case 'object':
        return Object.fromEntries(Object.entries(s.properties ?? {}).map(([k, v]) => [k, this.generic(v)]));
      case 'array':
        return Array.from({ length: s.minItems ?? 1 }, () => this.generic(s.items ?? { type: 'string' }));
      case 'integer':
      case 'number':
        return 0;
      case 'boolean':
        return false;
      case 'null':
        return null;
      default:
        return 'ok';
    }
  }

  async embed(texts: string[]): Promise<number[][]> {
    return texts.map((t) => {
      const v = new Array(256).fill(0);
      const s = ` ${fold(t).replace(/\s+/g, ' ').trim()} `;
      for (let i = 0; i + 3 <= s.length; i++) {
        let h = 2166136261;
        for (const c of s.slice(i, i + 3)) h = Math.imul(h ^ c.charCodeAt(0), 16777619);
        v[(h >>> 0) % 256] += 1;
      }
      return l2(v);
    });
  }
}

interface Schema {
  type?: string;
  enum?: unknown[];
  anyOf?: Schema[];
  properties?: Record<string, Schema & { enum?: unknown[] }>;
  items?: Schema & { properties?: Record<string, Schema> };
  prefixItems?: (Schema & { properties?: Record<string, Schema> })[];
  minItems?: number;
}

/* ============================== JSON có kiểm tra ============================== */

/** Bóc JSON từ output model: cắt rác đầu/cuối, bỏ dấu phẩy thừa (giống ai/skills/ghi-giao-dich/pipeline.ts). */
export function repairJson(s: string): any {
  const a = s.indexOf('{'), b = s.lastIndexOf('}');
  if (a < 0 || b < a) throw new Error('không thấy JSON');
  return JSON.parse(s.slice(a, b + 1).replace(/,\s*([}\]])/g, '$1'));
}

export interface JsonCallResult<T> {
  value: T | null;
  calls: number;
  ms: number;
  promptTokens: number;
  evalTokens: number;
  retried: boolean;
  error?: string;
}

/**
 * Gọi LLM với schema; `check` ném lỗi nếu nội dung sai (vd sai số khoản) → gửi lại kèm lỗi (tối đa `retries` lần).
 * Hết lượt vẫn sai → value null (skill tự lùi về mặc định).
 */
export async function chatJson<T>(llm: LlmClient, messages: ChatMsg[], schema: object, check: (j: any) => T, opts: { numPredict?: number; retries?: number } = {}): Promise<JsonCallResult<T>> {
  const msgs = [...messages];
  const out: JsonCallResult<T> = { value: null, calls: 0, ms: 0, promptTokens: 0, evalTokens: 0, retried: false };
  for (let attempt = 0; attempt <= (opts.retries ?? 1); attempt++) {
    const r = await llm.chat(msgs, { format: schema, numPredict: opts.numPredict });
    out.calls++;
    out.ms += r.ms;
    out.promptTokens += r.promptTokens;
    out.evalTokens += r.evalTokens;
    try {
      out.value = check(repairJson(r.content));
      return out;
    } catch (e) {
      out.retried = true;
      out.error = (e as Error).message;
      msgs.push({ role: 'assistant', content: r.content }, { role: 'user', content: `Lỗi: ${(e as Error).message}. Trả lại JSON đúng schema.` });
    }
  }
  return out;
}
