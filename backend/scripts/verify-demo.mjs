// Kiểm tra dữ liệu demo QUA API THẬT (sau npm run db:seed:demo). Chạy: npm run demo:verify
//   API_URL  mặc định http://localhost:3000/api
// Đăng nhập tối đa 8 lần (rate limit login mặc định 10/phút). Exit code 1 nếu có bất biến bị vi phạm.
const BASE = process.env.API_URL ?? 'http://localhost:3000/api';
const NOW = Date.now();
const monthOf = (t) => new Date(t + 7 * 3600_000).toISOString().slice(0, 7);
const shift = (m, d) => { const [y, mo] = m.split('-').map(Number); return new Date(Date.UTC(y, mo - 1 + d, 1)).toISOString().slice(0, 7); };
const CUR = monthOf(NOW);
const fmt = (v) => Math.round(v).toLocaleString('vi-VN') + 'đ';

let pass = 0;
const fails = [];
const check = (name, cond, extra) => { if (cond) pass++; else { fails.push(name); console.log('FAIL', name, extra !== undefined ? JSON.stringify(extra).slice(0, 300) : ''); } };

async function req(method, path, token, body) {
  const r = await fetch(BASE + path, {
    method,
    headers: { 'content-type': 'application/json', ...(token ? { authorization: `Bearer ${token}` } : {}) },
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await r.text();
  return { status: r.status, data: text ? JSON.parse(text) : null };
}
async function get(path, token) {
  const r = await req('GET', path, token);
  if (r.status !== 200) throw new Error(`GET ${path} -> ${r.status} ${JSON.stringify(r.data)}`);
  return r.data;
}
async function all(path, token) {
  const out = [];
  for (let page = 1; ; page++) {
    const sep = path.includes('?') ? '&' : '?';
    const r = await get(`${path}${sep}page=${page}&limit=200`, token);
    out.push(...r.items);
    if (out.length >= r.total || !r.items.length) return out;
  }
}
/** Rate limit đăng nhập (mặc định 10/phút) => chờ hết cửa sổ rồi thử lại */
async function login(email, password) {
  for (;;) {
    const r = await fetch(BASE + '/auth/login', { method: 'POST', headers: { 'content-type': 'application/json' }, body: JSON.stringify({ email, password }) });
    if (r.status === 429) {
      const wait = Number(r.headers.get('retry-after') ?? 10);
      console.log(`  (429, chờ ${wait}s)`);
      await new Promise((res) => setTimeout(res, (wait + 1) * 1000));
      continue;
    }
    const text = await r.text();
    return { status: r.status, data: text ? JSON.parse(text) : null };
  }
}

// ---------------- admin
const adminLogin = await login('admin@thuchi.vn', 'admin123');
check('admin@thuchi.vn đăng nhập', adminLogin.status === 200, adminLogin);
const admin = adminLogin.data.accessToken;
const ov = await get('/admin/overview', admin);
console.log(`Admin overview: ${ov.users.total} user (${ov.users.active} hoạt động, ${ov.users.locked} khóa, +${ov.users.new30d} 30 ngày) · ${ov.transactions.total} giao dịch (+${ov.transactions.new30d}) · thu ${fmt(ov.transactions.totalIncome)} · chi ${fmt(ov.transactions.totalExpense)}`);
console.log(`  mục tiêu: ${JSON.stringify(ov.savingGoals)} · trend: ${ov.trend.map((t) => `${t.month.slice(5)} ${Math.round(t.income / 1e6)}/${Math.round(t.expense / 1e6)}tr`).join(' ')}`);
check('overview ≥ 40 user', ov.users.total >= 40);
check('overview có user khóa', ov.users.locked >= 3);
check('overview giao dịch ≥ 30k', ov.transactions.total >= 30000);
check('overview chi < thu', ov.transactions.totalExpense < ov.transactions.totalIncome);
check('overview đủ 4 trạng thái mục tiêu', ['ACTIVE', 'COMPLETED', 'WITHDRAWN', 'EARLY_WITHDRAWN'].every((s) => ov.savingGoals[s] > 0), ov.savingGoals);
check('overview trend 6 tháng đều có thu & chi', ov.trend.length === 6 && ov.trend.every((t) => t.income > 0 && t.expense > 0), ov.trend);
const demoUsers = await all('/admin/users?q=demo.thuchi.vn', admin);
check('~39 user @demo.thuchi.vn', demoUsers.length >= 35, demoUsers.length);
check('có 1 admin demo', demoUsers.filter((u) => u.role === 'ADMIN').length === 1);
check('createdAt user demo không ở tương lai', demoUsers.every((u) => Date.parse(u.createdAt) <= NOW));
const bc = await get('/admin/broadcasts', admin);
const bcItems = bc.items ?? bc;
check('có ≥ 3 broadcast', bcItems.length >= 3, bcItems.length);
const someTx = await get('/admin/transactions?limit=5', admin);
check('admin giao dịch mới nhất không ở tương lai', someTx.items.every((t) => Date.parse(t.occurredAt) <= NOW));

const locked = demoUsers.find((u) => u.status === 'LOCKED');
const lockedLogin = await login(locked.email, 'demo123');
check(`user khóa ${locked.email} đăng nhập => 403`, lockedLogin.status === 403, lockedLogin.status);

// ---------------- từng user
const active = demoUsers.filter((u) => u.status === 'ACTIVE' && u.role === 'USER');
const sample = ['demo@thuchi.vn', ...[0, 7, 14, 21, 28].map((i) => active[(i * 3) % active.length].email)];
for (const email of [...new Set(sample)]) {
  const l = await login(email, 'demo123');
  check(`${email} đăng nhập`, l.status === 200, l.status);
  if (l.status !== 200) continue;
  const t = l.data.accessToken;
  const tag = email.split('@')[0];
  const wallets = await get('/wallets', t);
  const txs = await all('/transactions', t);
  const transfers = await all('/transfers', t);
  const goals = await get('/saving-goals', t);
  const details = await Promise.all(goals.map((g) => get(`/saving-goals/${g.id}`, t)));
  const entries = details.flatMap((d) => d.entries.map((e) => ({ ...e, goalId: d.id })));

  check(`${tag}: mọi ví số dư ≥ 0`, wallets.items.every((w) => w.balance >= 0), wallets.items.map((w) => [w.name, w.balance]));
  check(`${tag}: tổng số dư = tổng các ví`, wallets.totalBalance === wallets.items.reduce((s, w) => s + w.balance, 0));
  check(`${tag}: ví lưu trữ có số dư 0`, wallets.items.filter((w) => w.isArchived).every((w) => w.balance === 0));
  check(`${tag}: không có phát sinh ở tương lai`, [...txs.map((x) => x.occurredAt), ...transfers.map((x) => x.occurredAt), ...entries.map((e) => e.date)].every((d) => Date.parse(d) <= NOW));

  // Phát lại theo thời gian: chuyển tiền / nạp tiết kiệm không bao giờ làm ví nguồn âm
  const bal = new Map(wallets.items.map((w) => [w.id, w.initialBalance]));
  const ev = [
    ...txs.map((x) => ({ at: Date.parse(x.occurredAt), what: `${x.title} ${x.amount}`, pri: x.type === 'INCOME' ? 0 : 2, apply: () => bal.set(x.walletId, bal.get(x.walletId) + (x.type === 'INCOME' ? x.amount : -x.amount)) })),
    ...transfers.map((x) => ({ at: Date.parse(x.occurredAt), what: `chuyển ${x.note} ${x.amount}`, pri: 1, check: x.fromWalletId, apply: () => { bal.set(x.fromWalletId, bal.get(x.fromWalletId) - x.amount); bal.set(x.toWalletId, bal.get(x.toWalletId) + x.amount); } })),
    ...entries.map((e) => ({ at: Date.parse(e.date), pri: e.type === 'WITHDRAW' ? 0 : 1, check: e.type === 'DEPOSIT' ? e.walletId : undefined, apply: () => bal.set(e.walletId, bal.get(e.walletId) + (e.type === 'DEPOSIT' ? -e.amount : e.amount)) })),
  ].sort((a, b) => a.at - b.at || a.pri - b.pri);
  let badMoves = 0, anyNegative = 0, firstNeg;
  for (const e of ev) {
    e.apply();
    if (e.check && bal.get(e.check) < 0) badMoves++;
    if ([...bal.values()].some((v) => v < 0)) { anyNegative++; firstNeg ??= `${new Date(e.at).toISOString()} ${e.what}`; }
  }
  check(`${tag}: chuyển tiền / nạp tiết kiệm không làm ví âm tại thời điểm đó`, badMoves === 0, badMoves);
  check(`${tag}: không ví nào từng âm`, anyNegative === 0, [anyNegative, firstNeg]);
  check(`${tag}: phát lại khớp số dư API`, wallets.items.every((w) => bal.get(w.id) === w.balance));

  // Mục tiêu tiết kiệm
  for (const d of details) {
    const dep = d.entries.filter((e) => e.type === 'DEPOSIT').reduce((s, e) => s + e.amount, 0);
    const wd = d.entries.filter((e) => e.type === 'WITHDRAW').reduce((s, e) => s + e.amount, 0);
    check(`${tag}/${d.name}: savedAmount = nạp − rút`, d.savedAmount === dep - wd, [d.savedAmount, dep, wd]);
    const ok = { ACTIVE: d.savedAmount < d.targetAmount, COMPLETED: d.savedAmount >= d.targetAmount, WITHDRAWN: d.savedAmount === 0 && wd > 0 && dep >= d.targetAmount, EARLY_WITHDRAWN: d.savedAmount === 0 && wd > 0 && dep < d.targetAmount }[d.status];
    check(`${tag}/${d.name}: trạng thái ${d.status} nhất quán`, ok, d);
  }

  // Ngân sách 3 tháng gần nhất
  const notis = await all('/notifications', t);
  const notiBudgetIds = new Set(notis.filter((n) => n.type.startsWith('BUDGET')).map((n) => n.data?.budgetId));
  for (const m of [shift(CUR, -2), shift(CUR, -1), CUR]) {
    const b = await get(`/budgets?month=${m}`, t);
    const spentMonth = txs.filter((x) => x.type === 'EXPENSE' && monthOf(Date.parse(x.occurredAt)) === m).reduce((s, x) => s + x.amount, 0);
    for (const it of [b.overall, ...b.items].filter(Boolean)) {
      const label = `${tag}/${m}/${it.category?.name ?? 'tổng'}`;
      if (!it.categoryId) check(`${label}: spent = tổng chi tháng`, it.spent === spentMonth, [it.spent, spentMonth]);
      check(`${label}: exceededAt ⇒ ≥ 100%`, !it.exceededAt || it.percentage >= 100, it);
      check(`${label}: warnedAt ⇒ ≥ 80%`, !it.warnedAt || it.percentage >= 80, it);
      check(`${label}: exceededAt ⇒ warnedAt`, !it.exceededAt || !!it.warnedAt, it);
      check(`${label}: có dấu ⇒ có thông báo`, (!it.warnedAt && !it.exceededAt) || notiBudgetIds.has(it.id), it);
    }
  }

  // Định kỳ
  const rules = await get('/recurring', t);
  for (const r of rules) {
    const gen = txs.filter((x) => x.recurringRuleId === r.id);
    check(`${tag}/${r.title}: đang chạy ⇒ nextRunAt ở tương lai`, !r.isActive || Date.parse(r.nextRunAt) > NOW, r.nextRunAt);
    check(`${tag}/${r.title}: số giao dịch sinh = _count`, gen.length === r._count.transactions, [gen.length, r._count]);
    check(`${tag}/${r.title}: scheduledFor không trùng`, new Set(gen.map((x) => x.scheduledFor)).size === gen.length);
    check(`${tag}/${r.title}: kỳ sinh đều < nextRunAt`, gen.every((x) => Date.parse(x.scheduledFor) < Date.parse(r.nextRunAt)));
    check(`${tag}/${r.title}: lastRunAt ≥ kỳ cuối`, !gen.length || Date.parse(r.lastRunAt) >= Math.max(...gen.map((x) => Date.parse(x.scheduledFor))));
    check(`${tag}/${r.title}: hết hạn ⇒ tắt`, !r.endDate || Date.parse(r.endDate) > NOW || !r.isActive);
  }

  // Thống kê
  const sum = await get(`/stats/summary?month=${CUR}`, t);
  const curTx = txs.filter((x) => monthOf(Date.parse(x.occurredAt)) === CUR);
  check(`${tag}: summary tháng này khớp danh sách giao dịch`, sum.income === curTx.filter((x) => x.type === 'INCOME').reduce((s, x) => s + x.amount, 0) && sum.expense === curTx.filter((x) => x.type === 'EXPENSE').reduce((s, x) => s + x.amount, 0), sum);
  const rep = await get(`/stats/report?month=${shift(CUR, -1)}`, t);
  check(`${tag}: báo cáo tháng trước có thu, chi, cơ cấu, dự báo`, rep.income > 0 && rep.expense > 0 && rep.expenseByCategory.length >= 3 && rep.forecast.expense.predicted > 0, rep);
  const trend = await get(`/stats/trend?months=12`, t);
  check(`${tag}: xu hướng 12 tháng đều có chi`, (trend.items ?? trend).every((m) => m.expense > 0), trend);

  const unread = await get('/notifications/unread-count', t);
  const templates = await get('/quick-templates', t);
  const bNow = await get(`/budgets?month=${CUR}`, t);
  const archived = wallets.items.filter((w) => w.isArchived).length;
  console.log(
    `${email.padEnd(34)} ${wallets.items.length} ví${archived ? ` (${archived} lưu trữ)` : ''} tổng ${fmt(wallets.totalBalance).padStart(14)} · ${txs.length} gd · ${transfers.length} chuyển · ` +
      `chi T${CUR.slice(5)} ${fmt(sum.expense)}${bNow.overall ? ` / ${fmt(bNow.overall.limitAmount)} (${bNow.overall.percentage}%)` : ''} · ${goals.length} mục tiêu [${goals.map((g) => g.status[0]).join('')}] · ` +
      `${rules.length} định kỳ (${rules.filter((r) => r.isActive).length} chạy) · ${templates.length} mẫu · ${unread.count} chưa đọc`,
  );
  if (email === 'demo@thuchi.vn') {
    console.log(`  ví: ${wallets.items.map((w) => `${w.name} ${fmt(w.balance)}`).join(', ')}`);
    console.log(`  mẫu: ${templates.map((x) => `${x.label} ${x.amount / 1000}k`).join(', ')} · mục tiêu: ${goals.map((g) => `${g.name} ${fmt(g.savedAmount)}/${fmt(g.targetAmount)}`).join(', ')}`);
    console.log(`  ngân sách T${CUR.slice(5)}: ${bNow.items.map((i) => `${i.category.name} ${i.percentage}% ${i.status}`).join(', ')}`);
    check('showcase: 4 ví, tổng 25–27tr', wallets.items.length === 4 && wallets.totalBalance > 25e6 && wallets.totalBalance < 27e6, wallets.totalBalance);
    check('showcase: chi tháng này 50–70% ngân sách 14tr', bNow.overall?.limitAmount === 14e6 && bNow.overall.percentage >= 50 && bNow.overall.percentage <= 70, bNow.overall);
    check('showcase: mẫu Cà phê 45k / Cơm trưa 55k / Grab 38k', ['Cà phê:45000', 'Cơm trưa:55000', 'Grab:38000'].every((k) => templates.some((x) => `${x.label}:${x.amount}` === k)));
    check('showcase: 3 mục tiêu, 5 định kỳ', goals.length === 3 && rules.length === 5);
    check('showcase: có 1–4 thông báo chưa đọc', unread.count >= 1 && unread.count <= 4, unread);
  }
}

console.log(`\nverify-demo: ${pass} đạt, ${fails.length} lỗi`);
if (fails.length) process.exit(1);
