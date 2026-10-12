/**
 * Nạp code từ thư mục `ai/` của repo (ESM + TypeScript) lúc chạy bằng `tsx` (tsImport) — không copy, không build riêng.
 *   - Thư viện: parser (tiền / ngày / ví), prompt + schema của ghi-giao-dich, router luật.
 *   - Skill ngoài: `ai/skills/index.ts` (export `skills` | default = Skill[]) và/hoặc `ai/skills/<tên>/index.ts`
 *     (export `skill` | default). Skill hợp lệ (có `name` + `run`) được đăng ký theo tên, ghi đè built-in cùng tên
 *     => thêm skill mới KHÔNG cần sửa backend.
 * Thư mục: env `AI_DIR` (mặc định `<repo>/ai`). Không có (vd image Docker chỉ chứa backend/) => chỉ dùng built-in, ghi log cảnh báo.
 */
import { Logger } from '@nestjs/common';
import { existsSync, readdirSync } from 'fs';
import * as path from 'path';
import { pathToFileURL } from 'url';
import type { Skill } from './ai.types';

const logger = new Logger('AiExternal');
export const AI_DIR = process.env.AI_DIR || path.resolve(__dirname, '..', '..', '..', 'ai');

let tsImport: ((spec: string, parent: string) => Promise<any>) | null = null;

async function load(rel: string): Promise<any> {
  if (!tsImport) tsImport = require('tsx/esm/api').tsImport;
  return tsImport!(pathToFileURL(path.join(AI_DIR, rel)).href, __filename);
}

/** Kiểu tối thiểu của UserContext trong ai/lib/types.ts */
export interface AiUserContext {
  userId: string;
  displayName: string;
  now: string;
  categories: { name: string; type: 'INCOME' | 'EXPENSE' }[];
  wallets: { name: string; type: string }[];
}

export interface AiSegment {
  text: string;
  clean: string;
  amount: number;
  date: string;
  walletName: string | null;
}

export interface AiLib {
  parse(text: string, ctx: AiUserContext): AiSegment[];
  systemV1(ctx: AiUserContext): string;
  userV1(text: string, segs: string[]): string;
  schemaV1(ctx: AiUserContext, n: number): object;
  /** Router luật của ai/router (có thể không có) */
  routeRules?: (text: string, ctx: AiUserContext) => { skill: string; by: string } | null;
}

let libPromise: Promise<AiLib | null> | null = null;

/** Thư viện ai/ (cache). null = không nạp được (thiếu thư mục / lỗi cú pháp) → skill phụ thuộc trả "chưa sẵn sàng". */
export function aiLib(): Promise<AiLib | null> {
  libPromise ??= (async () => {
    try {
      const [parser, prompt, schema] = await Promise.all([
        load('parser/index.ts'),
        load('skills/ghi-giao-dich/prompt.ts'),
        load('skills/ghi-giao-dich/schema.ts'),
      ]);
      let routeRules: AiLib['routeRules'];
      try {
        routeRules = (await load('router/index.ts')).routeRules;
      } catch (e) {
        logger.warn(`Không nạp được ai/router: ${(e as Error).message}`);
      }
      return { parse: parser.parse, systemV1: prompt.systemV1, userV1: prompt.userV1, schemaV1: schema.schemaV1, routeRules };
    } catch (e) {
      logger.warn(`Không nạp được thư viện ai/ (${AI_DIR}): ${(e as Error).message}`);
      return null;
    }
  })();
  return libPromise;
}

const isSkill = (x: any): x is Skill => !!x && typeof x === 'object' && typeof x.name === 'string' && typeof x.run === 'function';

/** Skill do ai/ cung cấp theo hợp đồng `run({input, context, llm, now})`. Lỗi từng file chỉ ghi log. */
export async function loadExternalSkills(): Promise<Skill[]> {
  const dir = path.join(AI_DIR, 'skills');
  if (!existsSync(dir)) return [];
  const found: Skill[] = [];
  const take = (mod: any, rel: string) => {
    const xs = [mod?.skills, mod?.default, mod?.skill].flatMap((v) => (Array.isArray(v) ? v : v ? [v] : []));
    for (const s of xs) if (isSkill(s)) found.push(s);
    if (!xs.some(isSkill)) logger.warn(`${rel}: không có export skill hợp lệ ({name, run})`);
  };
  if (existsSync(path.join(dir, 'index.ts'))) {
    try {
      take(await load('skills/index.ts'), 'skills/index.ts');
    } catch (e) {
      logger.warn(`skills/index.ts: ${(e as Error).message}`);
    }
  }
  for (const d of readdirSync(dir, { withFileTypes: true })) {
    if (!d.isDirectory() || !existsSync(path.join(dir, d.name, 'index.ts'))) continue;
    try {
      take(await load(`skills/${d.name}/index.ts`), `skills/${d.name}/index.ts`);
    } catch (e) {
      logger.warn(`skills/${d.name}/index.ts: ${(e as Error).message}`);
    }
  }
  // trùng tên: bản sau ghi đè
  return [...new Map(found.map((s) => [s.name, s])).values()];
}

/** Đọc file JSON trong ai/ (bộ đề hồi quy, câu mẫu router). Không có → null. */
export async function aiData<T>(rel: string): Promise<T | null> {
  try {
    const f = path.join(AI_DIR, rel);
    if (!existsSync(f)) return null;
    if (rel.endsWith('.json')) return JSON.parse(require('fs').readFileSync(f, 'utf8')) as T;
    return (await load(rel)) as T;
  } catch (e) {
    logger.warn(`Không đọc được ai/${rel}: ${(e as Error).message}`);
    return null;
  }
}
