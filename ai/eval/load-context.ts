/**
 * Dựng UserContext cho MỘT user từ Postgres (chỉ đọc). Mọi truy vấn đều lọc theo userId của user đó;
 * danh mục = hệ thống (userId IS NULL) ∪ của chính user. Không có dữ liệu user khác đi vào pipeline.
 * Chạy: npm run context -- demo@thuchi.vn
 */
import { writeFileSync } from 'node:fs';
import pg from 'pg';
import type { UserContext } from '../lib/types.js';

const email = process.argv[2] ?? 'demo@thuchi.vn';
const db = new pg.Client({ connectionString: process.env.DATABASE_URL ?? 'postgresql://tracker:tracker@localhost:5433/tracker' });
await db.connect();
const { rows: [u] } = await db.query('SELECT id, name FROM "User" WHERE email = $1', [email]);
if (!u) throw new Error(`không có user ${email}`);
const cats = await db.query(
  `SELECT name, type FROM "Category" WHERE ("userId" IS NULL OR "userId" = $1) AND "isArchived" = false
   ORDER BY "userId" NULLS FIRST, "createdAt"`, [u.id]);
const wallets = await db.query('SELECT name, type FROM "Wallet" WHERE "userId" = $1 ORDER BY "createdAt"', [u.id]);
await db.end();

const ctx: UserContext = {
  userId: u.id, displayName: u.name, now: '2026-10-08T09:00:00+07:00',
  categories: cats.rows, wallets: wallets.rows,
};
writeFileSync(new URL('./user-context.json', import.meta.url), JSON.stringify(ctx, null, 2) + '\n');
console.log(`${email}: ${ctx.categories.length} danh mục, ${ctx.wallets.length} ví`);
