import type { UserContext } from '../../lib/types.js';

/** Schema V1+: n khoản, mỗi khoản title + categoryName (enum khóa theo danh mục của user). */
export const schemaV1 = (ctx: UserContext, n: number) => ({
  type: 'object',
  properties: {
    items: {
      type: 'array', minItems: n, maxItems: n,
      items: {
        type: 'object',
        properties: { title: { type: 'string' }, categoryName: { type: 'string', enum: ctx.categories.map((c) => c.name) } },
        required: ['title', 'categoryName'],
      },
    },
  },
  required: ['items'],
});

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
