import type { UserContext } from '../../lib/types.js';

/**
 * Schema V1+: n khoản, mỗi khoản title + categoryName (enum khóa theo danh mục của user).
 * `allowed[i]` (tuỳ chọn): enum riêng cho khoản i — vd. chỉ danh mục THU khi parser thấy tín hiệu thu,
 * hoặc đúng 1 danh mục khi luật/từ điển đã chốt. Dùng `prefixItems` (Ollama dịch sang grammar được).
 * KHÔNG dùng `pattern` ở bất kỳ đâu (Ollama bỏ qua cả grammar) — ràng buộc dạng chuỗi kiểm bằng code.
 */
export const schemaV1 = (ctx: UserContext, n: number, allowed?: string[][]) => {
  const item = (en: string[]) => ({
    type: 'object',
    properties: { title: { type: 'string' }, categoryName: { type: 'string', enum: en } },
    required: ['title', 'categoryName'],
  });
  return {
    type: 'object',
    properties: {
      // Có `allowed` → CHỈ `prefixItems` (tuple). Nếu để cả `items`, grammar của Ollama/llama.cpp dùng `items`
      // và lặng lẽ bỏ qua enum riêng từng khoản (đã đo: 2026-10-12).
      items: allowed
        ? { type: 'array', minItems: n, maxItems: n, prefixItems: allowed.map(item) }
        : { type: 'array', minItems: n, maxItems: n, items: item(ctx.categories.map((c) => c.name)) },
    },
    required: ['items'],
  };
};

/** Schema V0: model tự điền mọi trường. */
export const schemaV0 = (ctx: UserContext) => ({
  type: 'object',
  properties: {
    ask: { type: 'boolean' },
    items: {
      type: 'array', maxItems: 6,
      items: {
        type: 'object',
        properties: {
          title: { type: 'string' },
          amount: { type: 'integer' },
          categoryName: { type: 'string', enum: ctx.categories.map((c) => c.name) },
          type: { type: 'string', enum: ['INCOME', 'EXPENSE'] },
          date: { type: 'string' }, // KHÔNG dùng `pattern`: Ollama 0.30 bỏ qua cả grammar khi gặp pattern
          walletName: { anyOf: [{ type: 'string', enum: ctx.wallets.map((w) => w.name) }, { type: 'null' }] },
        },
        required: ['title', 'amount', 'categoryName', 'type', 'date', 'walletName'],
      },
    },
  },
  required: ['ask', 'items'],
});
