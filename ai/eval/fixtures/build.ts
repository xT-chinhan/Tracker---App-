/**
 * Dựng fixture cho eval skill từ DB dev (CHỈ ĐỌC: phiên READ ONLY). Chạy: npx tsx eval/fixtures/build.ts
 * - user-<x>.json: dữ liệu thô của MỘT user (ví+số dư, danh mục, giao dịch 6 tháng, ngân sách, mục tiêu)
 * - admin.json: tổng hợp hệ thống (overview, hoạt động theo user, broadcast). Lịch sử cấu hình trong DB dev đang trống
 *   nên dùng bộ thay đổi tự viết (`configHistory`, đánh dấu synthetic).
 * Provider (eval/fixtures/providers.ts) tính phần còn lại giống backend.
 */
import { writeFileSync } from 'node:fs';
import pg from 'pg';

const NOW = '2026-10-08T20:00:00+07:00'; // dữ liệu demo kết thúc 08/10/2026
const USERS: Record<string, string> = { demo: 'demo@thuchi.vn', thu: 'minhthu.do@demo.thuchi.vn' };
// Cột DateTime của Prisma là timestamp KHÔNG múi giờ, lưu UTC → đọc như UTC.
pg.types.setTypeParser(1114, (v: string) => new Date(v.replace(' ', 'T') + 'Z'));
const db = new pg.Client({ connectionString: process.env.DATABASE_URL ?? 'postgresql://tracker:tracker@localhost:5433/tracker' });
await db.connect();
await db.query('BEGIN TRANSACTION READ ONLY');
const q = async (sql: string, args: unknown[] = []) => (await db.query(sql, args)).rows;
const N = (v: unknown) => Number(v ?? 0);
const VN = `AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh'`;
const out = (f: string, d: unknown) => writeFileSync(new URL(f, import.meta.url), JSON.stringify(d, null, 1) + '\n');

for (const [key, email] of Object.entries(USERS)) {
  const [u] = await q('SELECT id, name, role FROM "User" WHERE email = $1', [email]);
  const wallets = await q(`
    SELECT w.name, w.type, w."isArchived", w."initialBalance"
      + COALESCE((SELECT SUM(CASE WHEN t.type='INCOME' THEN t.amount ELSE -t.amount END) FROM "Transaction" t WHERE t."walletId"=w.id),0)
      + COALESCE((SELECT SUM(amount) FROM "Transfer" x WHERE x."toWalletId"=w.id),0)
      - COALESCE((SELECT SUM(amount) FROM "Transfer" x WHERE x."fromWalletId"=w.id),0)
      - COALESCE((SELECT SUM(CASE WHEN e.type='DEPOSIT' THEN e.amount ELSE -e.amount END) FROM "SavingEntry" e WHERE e."walletId"=w.id),0) AS balance
    FROM "Wallet" w WHERE w."userId"=$1 ORDER BY w."isArchived", w."createdAt"`, [u.id]);
  const [sav] = await q(`SELECT COALESCE(SUM(CASE WHEN type='DEPOSIT' THEN amount ELSE -amount END),0) s FROM "SavingEntry" WHERE "userId"=$1`, [u.id]);
  const categories = await q(`SELECT name, type FROM "Category" WHERE ("userId" IS NULL OR "userId"=$1) AND "isArchived"=false ORDER BY "userId" NULLS FIRST, "createdAt"`, [u.id]);
  const transactions = await q(`
    SELECT t.title, t.amount, t.type, c.name AS "categoryName", w.name AS "walletName", to_char(t."occurredAt" ${VN}, 'YYYY-MM-DD') AS date
    FROM "Transaction" t JOIN "Category" c ON c.id=t."categoryId" JOIN "Wallet" w ON w.id=t."walletId"
    WHERE t."userId"=$1 AND t."occurredAt" >= '2026-03-31T17:00:00Z' ORDER BY t."occurredAt", t."createdAt"`, [u.id]);
  const budgets = await q(`SELECT b.month, c.name AS "categoryName", b."limitAmount" FROM "Budget" b LEFT JOIN "Category" c ON c.id=b."categoryId" WHERE b."userId"=$1 ORDER BY b.month, b."createdAt"`, [u.id]);
  const goals = await q(`SELECT name, "targetAmount", "savedAmount", "targetDate", status FROM "SavingGoal" WHERE "userId"=$1 ORDER BY "createdAt"`, [u.id]);
  out(`user-${key}.json`, {
    now: NOW,
    principal: { userId: u.id, role: u.role, displayName: u.name },
    wallets: wallets.map((w) => ({ name: w.name, type: w.type, isArchived: w.isArchived, balance: N(w.balance) })),
    savings: N(sav.s),
    categories,
    transactions: transactions.map((t) => ({ ...t, amount: N(t.amount) })),
    budgets: budgets.map((b) => ({ month: b.month, categoryName: b.categoryName, limitAmount: N(b.limitAmount) })),
    goals: goals.map((g) => ({ name: g.name, targetAmount: N(g.targetAmount), savedAmount: N(g.savedAmount), targetDate: new Date(g.targetDate).toISOString(), status: g.status })),
  });
  console.log(`${key}: ${wallets.length} ví, ${transactions.length} giao dịch, ${budgets.length} ngân sách, ${goals.length} mục tiêu`);
}

// ── admin ──
const nowTs = new Date(NOW);
const since30 = new Date(nowTs.getTime() - 30 * 86400000).toISOString();
const nowUtc = nowTs.toISOString();
const [admin] = await q(`SELECT id, name FROM "User" WHERE email='admin@thuchi.vn'`);
const byStatus = await q(`SELECT status, COUNT(*) c FROM "User" GROUP BY 1`);
const [newUsers] = await q(`SELECT COUNT(*) c FROM "User" WHERE "createdAt" >= $1 AND "createdAt" <= $2`, [since30, nowUtc]);
const txType = await q(`SELECT type, COUNT(*) c, SUM(amount) s FROM "Transaction" GROUP BY 1`);
const [tx30] = await q(`SELECT COUNT(*) c FROM "Transaction" WHERE "createdAt" >= $1`, [since30]);
const goalSt = await q(`SELECT status, COUNT(*) c FROM "SavingGoal" GROUP BY 1`);
const trend = await q(`SELECT to_char("occurredAt" ${VN}, 'YYYY-MM') m, type, SUM(amount) s FROM "Transaction" WHERE "occurredAt" >= '2026-04-30T17:00:00Z' GROUP BY 1,2`);
const cnt = (s: string) => N(byStatus.find((r) => r.status === s)?.c);
const months = ['2026-05', '2026-06', '2026-07', '2026-08', '2026-09', '2026-10'];
const overview = {
  users: { total: cnt('ACTIVE') + cnt('LOCKED'), active: cnt('ACTIVE'), locked: cnt('LOCKED'), new30d: N(newUsers.c) },
  transactions: {
    total: txType.reduce((s, r) => s + N(r.c), 0), new30d: N(tx30.c),
    totalIncome: N(txType.find((r) => r.type === 'INCOME')?.s), totalExpense: N(txType.find((r) => r.type === 'EXPENSE')?.s),
  },
  savingGoals: Object.fromEntries(goalSt.map((g) => [g.status, N(g.c)])),
  trend: months.map((m) => {
    const inc = N(trend.find((r) => r.m === m && r.type === 'INCOME')?.s), exp = N(trend.find((r) => r.m === m && r.type === 'EXPENSE')?.s);
    return { month: m, income: inc, expense: exp, net: inc - exp };
  }),
};
const activity = await q(`
  SELECT u.id, u.email, u.name, u.role, u.status, u."createdAt", u."lastLoginAt",
    (SELECT COUNT(*) FROM "Transaction" t WHERE t."userId"=u.id AND t."occurredAt" >= $1) AS tx30,
    (SELECT COALESCE(SUM(amount),0) FROM "Transaction" t WHERE t."userId"=u.id AND t.type='EXPENSE' AND to_char(t."occurredAt" ${VN},'YYYY-MM')='2026-10') AS exp_cur,
    (SELECT COALESCE(SUM(amount),0)/3 FROM "Transaction" t WHERE t."userId"=u.id AND t.type='EXPENSE' AND to_char(t."occurredAt" ${VN},'YYYY-MM') IN ('2026-07','2026-08','2026-09')) AS exp_avg,
    (SELECT COALESCE(MAX(amount),0) FROM "Transaction" t WHERE t."userId"=u.id AND t.type='EXPENSE' AND t."occurredAt" >= $1) AS big
  FROM "User" u ORDER BY u."createdAt"`, [since30]);
const broadcasts = await q(`
  SELECT b.title, b.body, b.recipients, b."createdAt", (SELECT COUNT(*) FROM "Notification" n WHERE n."broadcastId"=b.id AND n."readAt" IS NOT NULL) rc
  FROM "Broadcast" b ORDER BY b."createdAt" DESC`);
await db.query('ROLLBACK');
await db.end();

// DB dev chưa có dòng SystemConfigChange nào → lịch sử tự viết, đúng định dạng GET /admin/config/history.
const configHistory = [
  { createdAt: '2026-10-08T09:12:00+07:00', actorName: 'Administrator', section: 'access', key: 'maintenanceEndsAt', oldValue: null, newValue: '2026-10-12T05:00:00+07:00', secret: false },
  { createdAt: '2026-10-08T09:11:00+07:00', actorName: 'Administrator', section: 'access', key: 'maintenanceMessage', oldValue: 'Hệ thống đang bảo trì, vui lòng quay lại sau.', newValue: 'Bảo trì nâng cấp máy chủ từ 0h đến 5h ngày 12/10.', secret: false },
  { createdAt: '2026-10-07T16:40:00+07:00', actorName: 'Trần Quốc Bảo', section: 'business', key: 'budgetWarningPercent', oldValue: 80, newValue: 75, secret: false },
  { createdAt: '2026-10-07T16:40:00+07:00', actorName: 'Trần Quốc Bảo', section: 'business', key: 'featureCsvExport', oldValue: true, newValue: false, secret: false },
  { createdAt: '2026-10-06T10:05:00+07:00', actorName: 'Administrator', section: 'smtp', key: 'password', oldValue: '••••', newValue: '••••', secret: true },
  { createdAt: '2026-10-06T10:05:00+07:00', actorName: 'Administrator', section: 'smtp', key: 'host', oldValue: '', newValue: 'smtp.thuchi.vn', secret: false },
  { createdAt: '2026-10-05T08:30:00+07:00', actorName: 'Administrator', section: 'password', key: 'minLength', oldValue: 6, newValue: 8, secret: false },
  { createdAt: '2026-10-03T14:00:00+07:00', actorName: 'Trần Quốc Bảo', section: 'access', key: 'loginMaxAttempts', oldValue: 10, newValue: 5, secret: false },
  { createdAt: '2026-10-01T00:00:00+07:00', actorName: null, section: 'access', key: 'maintenanceEnabled', oldValue: true, newValue: false, secret: false },
  { createdAt: '2026-09-28T11:20:00+07:00', actorName: 'Administrator', section: 'mobile', key: 'androidMinVersion', oldValue: '1.0.0', newValue: '1.1.0', secret: false },
];
out('admin.json', {
  now: NOW, synthetic: ['configHistory'],
  principal: { userId: admin.id, role: 'ADMIN', displayName: admin.name },
  overview,
  userActivity: activity.map((a) => ({
    id: a.id, email: a.email, name: a.name, role: a.role, status: a.status, createdAt: new Date(a.createdAt).toISOString(),
    lastLoginAt: a.lastLoginAt ? new Date(a.lastLoginAt).toISOString() : null,
    txCount30d: N(a.tx30), expenseThisMonth: N(a.exp_cur), expenseAvgPrev3: Math.round(N(a.exp_avg)), largestExpense30d: N(a.big),
  })),
  broadcasts: broadcasts.map((b) => ({ title: b.title, body: b.body, recipients: N(b.recipients), readCount: N(b.rc), createdAt: new Date(b.createdAt).toISOString() })),
  configHistory,
  publicConfig: { appName: 'Thu Chi', supportEmail: 'hotro@thuchi.vn', hotline: '1900 6868', maintenance: { enabled: false, message: 'Hệ thống đang bảo trì, vui lòng quay lại sau.', endsAt: null } },
});
console.log(`admin: ${activity.length} user, ${broadcasts.length} broadcast`);
