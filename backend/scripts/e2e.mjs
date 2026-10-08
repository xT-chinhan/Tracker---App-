// E2E kiểm thử toàn bộ API (fetch thuần, không framework). Chạy: npm run test:e2e (API_URL mặc định http://localhost:3000/api)
// Dùng email/tên ngẫu nhiên nên chạy lặp được mà không cần reset DB. Exit code 1 nếu có lỗi.
const BASE = process.env.API_URL ?? 'http://localhost:3000/api';
const ADMIN_EMAIL = process.env.ADMIN_EMAIL ?? 'admin@tracker.local';
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD ?? 'admin123';
let pass = 0, fail = 0;
const fails = [];
function check(name, cond, extra) {
  if (cond) { pass++; } else { fail++; fails.push(name); console.log('FAIL:', name, extra !== undefined ? JSON.stringify(extra).slice(0, 600) : ''); }
}
async function req(method, path, { token, body } = {}) {
  const r = await fetch(BASE + path, {
    method,
    headers: { 'content-type': 'application/json', ...(token ? { authorization: `Bearer ${token}` } : {}) },
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });
  const text = await r.text();
  let data; try { data = text ? JSON.parse(text) : null; } catch { data = text; }
  return { status: r.status, data };
}
const S = Date.now();
const emailA = `a${S}@test.local`, emailB = `b${S}@test.local`;

// ---------- AUTH ----------
let r = await req('POST', '/auth/register', { body: { email: emailA.toUpperCase(), password: 'secret1', name: 'User A' } });
check('register A 201', r.status === 201 && r.data.accessToken && !r.data.user.passwordHash && r.data.user.email === emailA, r);
let tA = r.data.accessToken; const idA = r.data.user.id;
r = await req('POST', '/auth/register', { body: { email: emailA, password: 'secret1', name: 'dup' } });
check('register dup 409', r.status === 409, r);
r = await req('POST', '/auth/register', { body: { email: emailB, password: 'secret2', name: 'User B' } });
check('register B 201', r.status === 201, r);
let tB = r.data.accessToken; const idB = r.data.user.id;
r = await req('POST', '/auth/register', { body: { email: 'bad', password: '1', name: '' } });
check('register invalid 400', r.status === 400, r);
r = await req('POST', '/auth/register', { body: { email: `c${S}@x.local`, password: 'secret1', name: 'C', role: 'ADMIN' } });
check('register unknown field (role) 400', r.status === 400, r);
r = await req('POST', '/auth/login', { body: { email: emailA, password: 'wrong' } });
check('login wrong pw 401', r.status === 401, r);
r = await req('POST', '/auth/login', { body: { email: emailA, password: 'secret1' } });
check('login A 200', r.status === 200 && r.data.accessToken, r);
tA = r.data.accessToken;
r = await req('GET', '/me');
check('me no token 401', r.status === 401, r);
r = await req('GET', '/me', { token: 'garbage' });
check('me bad token 401', r.status === 401, r);
r = await req('GET', '/me', { token: tA });
check('me A', r.status === 200 && r.data.id === idA && r.data.role === 'USER' && !('passwordHash' in r.data), r);
r = await req('PATCH', '/me', { token: tA, body: { name: '  Alice  ' } });
check('patch me', r.status === 200 && r.data.name === 'Alice', r);
r = await req('PATCH', '/me', { token: tA, body: { name: '   ' } });
check('patch me blank name 400', r.status === 400, r);
r = await req('POST', '/me/password', { token: tA, body: { currentPassword: 'nope', newPassword: 'secret9' } });
check('change pw wrong current 400', r.status === 400, r);
r = await req('POST', '/me/password', { token: tA, body: { currentPassword: 'secret1', newPassword: 'secret9' } });
check('change pw 204', r.status === 204, r);
r = await req('POST', '/auth/login', { body: { email: emailA, password: 'secret1' } });
check('login old pw 401', r.status === 401, r);
r = await req('POST', '/auth/login', { body: { email: emailA, password: 'secret9' } });
check('login new pw', r.status === 200, r);
tA = r.data.accessToken;

// ---------- CATEGORIES ----------
r = await req('GET', '/categories', { token: tA });
check('categories list = system only', r.status === 200 && r.data.length >= 14 && r.data.every((c) => c.userId === null), r.data?.length);
const sysCount = r.data.length;
const sysIncome = r.data.filter((c) => c.type === 'INCOME').length;
const sys = Object.fromEntries(r.data.map((c) => [c.name, c]));
r = await req('GET', '/categories?type=INCOME', { token: tA });
check('categories filter INCOME', r.status === 200 && r.data.length === sysIncome && r.data.every((c) => c.type === 'INCOME'), r);
r = await req('GET', '/categories?type=FOO', { token: tA });
check('categories bad type 400', r.status === 400, r);
r = await req('POST', '/categories', { token: tA, body: { name: 'Cà phê', type: 'EXPENSE', icon: 'coffee', color: '#112233' } });
check('create custom cat', r.status === 201 && r.data.userId === idA, r);
const coffee = r.data;
r = await req('POST', '/categories', { token: tA, body: { name: 'cà PHÊ', type: 'EXPENSE' } });
check('dup custom cat 409', r.status === 409, r);
r = await req('POST', '/categories', { token: tA, body: { name: 'ăn uống', type: 'EXPENSE' } });
check('dup vs system cat 409', r.status === 409, r);
r = await req('POST', '/categories', { token: tA, body: { name: 'Ăn uống', type: 'INCOME' } });
check('same name other type ok', r.status === 201, r);
const anUongIncome = r.data;
r = await req('POST', '/categories', { token: tB, body: { name: 'Cà phê', type: 'EXPENSE' } });
check('B same name as A ok', r.status === 201, r);
const coffeeB = r.data;
r = await req('POST', '/categories', { token: tA, body: { name: '   ', type: 'EXPENSE' } });
check('blank category name 400', r.status === 400, r);
r = await req('POST', '/categories', { token: tA, body: { name: 'X', type: 'EXPENSE', color: 'red' } });
check('bad color 400', r.status === 400, r);
r = await req('PATCH', `/categories/${coffee.id}`, { token: tA, body: { name: 'Cafe', color: '#445566' } });
check('update cat', r.status === 200 && r.data.name === 'Cafe' && r.data.color === '#445566', r);
r = await req('PATCH', `/categories/${coffee.id}`, { token: tA, body: { name: 'Mua sắm' } });
check('rename to system name 409', r.status === 409, r);
r = await req('PATCH', `/categories/${sys['Ăn uống'].id}`, { token: tA, body: { name: 'hack' } });
check('user edit system cat 404', r.status === 404, r);
r = await req('PATCH', `/categories/${coffee.id}`, { token: tB, body: { name: 'hack' } });
check('B edit A cat 404', r.status === 404, r);
r = await req('DELETE', `/categories/${coffee.id}`, { token: tB });
check('B delete A cat 404', r.status === 404, r);
r = await req('DELETE', `/categories/${anUongIncome.id}`, { token: tA });
check('delete unused cat -> hard', r.status === 200 && r.data.archived === false, r);
r = await req('PATCH', `/categories/not-a-uuid`, { token: tA, body: {} });
check('bad uuid 400', r.status === 400, r);
r = await req('GET', '/categories', { token: tB });
check('B sees own + system only', r.data.length === sysCount + 1 && !r.data.some((c) => c.id === coffee.id), r.data.length);

// ---------- TRANSACTIONS ----------
const C = (name) => sys[name].id;
// Aug 2026 (VN): income 20,000,000 lương; expense ăn uống 1,000,000 + 500,000; edge 23:59 VN Aug 31
// Sep 2026 (VN): income 22,000,000; expense ăn uống 3,000,000 at 00:30 VN Sep 1 (=Aug 31 17:30Z); di chuyển 400,000; cafe 100,000
const txs = [
  { categoryId: C('Lương'), amount: 20000000, title: 'Lương T8', occurredAt: '2026-08-05T03:00:00Z' },
  { categoryId: C('Ăn uống'), amount: 1000000, title: 'Đi chợ', note: 'siêu thị', occurredAt: '2026-08-10T05:00:00Z' },
  { categoryId: C('Ăn uống'), amount: 500000, title: 'Ăn tối cuối tháng', occurredAt: '2026-08-31T16:59:00Z' }, // 23:59 VN 31/8
];
const created = [];
for (const t of txs) {
  r = await req('POST', '/transactions', { token: tA, body: t });
  check(`create tx ${t.title}`, r.status === 201 && r.data.type === sys[Object.keys(sys).find((k) => sys[k].id === t.categoryId)].type && r.data.amount === t.amount && r.data.category?.name, r);
  created.push(r.data);
}
r = await req('POST', '/transactions/bulk', { token: tA, body: { items: [
  { categoryId: C('Lương'), amount: 22000000, title: 'Lương T9', occurredAt: '2026-09-05T03:00:00Z' },
  { categoryId: C('Ăn uống'), amount: 3000000, title: 'Tiệc nửa đêm', occurredAt: '2026-08-31T17:30:00Z' }, // 00:30 VN 1/9
  { categoryId: C('Di chuyển'), amount: 400000, title: 'Grab', note: 'đi làm', occurredAt: '2026-09-15T02:00:00Z' },
  { categoryId: coffee.id, amount: 100000, title: 'Highlands', occurredAt: '2026-09-30T16:30:00Z' }, // 23:30 VN 30/9
] } });
check('bulk create 4', r.status === 201 && r.data.created === 4, r);
r = await req('POST', '/transactions/bulk', { token: tA, body: { items: [
  { categoryId: C('Lương'), amount: 1, title: 'ok' },
  { categoryId: coffeeB.id, amount: 1, title: 'other user cat' },
] } });
check('bulk with foreign cat 400 & nothing created', r.status === 400, r);
r = await req('POST', '/transactions/bulk', { token: tA, body: { items: [] } });
check('bulk empty 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Lương'), amount: -5, title: 'neg' } });
check('negative amount 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Lương'), amount: 5, title: '  ' } });
check('blank title 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Lương'), amount: 1e14, title: 'too big' } });
check('amount > MAX 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Lương'), amount: 1.5, title: 'frac' } });
check('fractional amount 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Lương'), amount: 5, title: 'x', type: 'EXPENSE' } });
check('unknown field type 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: coffeeB.id, amount: 5, title: 'x' } });
check('use other user cat 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Lương'), amount: 5, title: 'x', occurredAt: 'yesterday' } });
check('bad date 400', r.status === 400, r);

r = await req('GET', '/transactions', { token: tA });
check('list all 7', r.status === 200 && r.data.total === 7 && r.data.page === 1 && r.data.limit === 20 && r.data.items.length === 7, r.data);
check('list sorted desc', r.data.items.every((t, i, a) => i === 0 || new Date(a[i - 1].occurredAt) >= new Date(t.occurredAt)));
r = await req('GET', '/transactions?month=2026-08', { token: tA });
check('filter month 08 = 3 (midnight tx excluded)', r.data.total === 3 && !r.data.items.some((t) => t.title === 'Tiệc nửa đêm'), r.data.items?.map((t) => t.title));
r = await req('GET', '/transactions?month=2026-09', { token: tA });
check('filter month 09 = 4 (midnight tx included)', r.data.total === 4 && r.data.items.some((t) => t.title === 'Tiệc nửa đêm'), r.data.items?.map((t) => t.title));
r = await req('GET', '/transactions?type=INCOME', { token: tA });
check('filter type INCOME', r.data.total === 2 && r.data.items.every((t) => t.type === 'INCOME'), r.data);
r = await req('GET', `/transactions?categoryId=${C('Ăn uống')}`, { token: tA });
check('filter categoryId', r.data.total === 3, r.data);
r = await req('GET', `/transactions?q=SIÊU`, { token: tA });
check('filter q note (insensitive)', r.data.total === 1 && r.data.items[0].title === 'Đi chợ', r.data);
r = await req('GET', `/transactions?q=grab`, { token: tA });
check('filter q title', r.data.total === 1, r.data);
r = await req('GET', '/transactions?page=2&limit=3', { token: tA });
check('pagination', r.data.total === 7 && r.data.items.length === 3 && r.data.page === 2 && r.data.limit === 3, r.data);
r = await req('GET', '/transactions?page=3&limit=3', { token: tA });
check('pagination last page', r.data.items.length === 1, r.data);
r = await req('GET', '/transactions?limit=500', { token: tA });
check('limit > 200 400', r.status === 400, r);
r = await req('GET', '/transactions?month=2026-13', { token: tA });
check('bad month 400', r.status === 400, r);
r = await req('GET', '/transactions?month=2026-8', { token: tA });
check('bad month (2026-8) 400', r.status === 400, r);
r = await req('GET', '/transactions?from=2026-09-01T00:00:00%2B07:00&to=2026-09-15T00:00:00%2B07:00', { token: tA });
check('filter from/to', r.data.total === 2, r.data.items?.map((t) => t.title));
r = await req('GET', '/transactions?foo=1', { token: tA });
check('unknown query param 400', r.status === 400, r);

const txA = created[1];
r = await req('GET', `/transactions/${txA.id}`, { token: tA });
check('get tx', r.status === 200 && r.data.id === txA.id, r);
r = await req('GET', `/transactions/${txA.id}`, { token: tB });
check('B get A tx 404', r.status === 404, r);
r = await req('PATCH', `/transactions/${txA.id}`, { token: tB, body: { amount: 1 } });
check('B patch A tx 404', r.status === 404, r);
r = await req('DELETE', `/transactions/${txA.id}`, { token: tB });
check('B delete A tx 404', r.status === 404, r);
r = await req('GET', '/transactions', { token: tB });
check('B list empty', r.data.total === 0, r.data);
r = await req('PATCH', `/transactions/${txA.id}`, { token: tA, body: { categoryId: C('Thưởng') } });
check('patch tx category -> type INCOME', r.status === 200 && r.data.type === 'INCOME' && r.data.category.name === 'Thưởng', r);
r = await req('PATCH', `/transactions/${txA.id}`, { token: tA, body: { categoryId: C('Ăn uống'), amount: 1200000, note: '' } });
check('patch tx back + amount + clear note', r.status === 200 && r.data.type === 'EXPENSE' && r.data.amount === 1200000 && r.data.note === null, r);
r = await req('PATCH', `/transactions/${txA.id}`, { token: tA, body: { amount: 0 } });
check('patch amount 0 400', r.status === 400, r);
// temp tx then delete
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Chi khác'), amount: 7, title: 'temp' } });
const tmp = r.data;
check('create default occurredAt now', r.status === 201 && Math.abs(new Date(tmp.occurredAt) - Date.now()) < 60000, r);
r = await req('DELETE', `/transactions/${tmp.id}`, { token: tA });
check('delete tx 204', r.status === 204, r);
r = await req('DELETE', `/transactions/${tmp.id}`, { token: tA });
check('delete again 404', r.status === 404, r);

// Now A data: Aug: income 20,000,000; expense 1,200,000 + 500,000 = 1,700,000
// Sep: income 22,000,000; expense 3,000,000 + 400,000 + 100,000 = 3,500,000
// ---------- CATEGORY ARCHIVE ----------
r = await req('DELETE', `/categories/${coffee.id}`, { token: tA });
check('delete used cat -> archived', r.status === 200 && r.data.archived === true, r);
r = await req('GET', '/categories', { token: tA });
check('archived hidden from list', !r.data.some((c) => c.id === coffee.id), r.data.length);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: coffee.id, amount: 5, title: 'x' } });
check('create tx in archived cat 400', r.status === 400, r);
r = await req('GET', '/transactions?month=2026-09', { token: tA });
check('tx in archived cat still listed', r.data.items.some((t) => t.category.id === coffee.id), r.data);
r = await req('POST', '/categories', { token: tA, body: { name: 'Cafe', type: 'EXPENSE' } });
check('recreate same name after archive ok', r.status === 201, r);

// ---------- STATS ----------
r = await req('GET', '/stats/balance', { token: tA });
check('balance', r.status === 200 && r.data.totalIncome === 42000000 && r.data.totalExpense === 5200000 && r.data.savings === 0 && r.data.balance === 36800000, r.data);
r = await req('GET', '/stats/summary?month=2026-08', { token: tA });
check('summary Aug', r.data.income === 20000000 && r.data.expense === 1700000 && r.data.net === 18300000 && r.data.incomeCount === 1 && r.data.expenseCount === 2 && r.data.balance === 36800000, r.data);
r = await req('GET', '/stats/summary?month=2026-09', { token: tA });
check('summary Sep', r.data.income === 22000000 && r.data.expense === 3500000 && r.data.expenseCount === 3, r.data);
r = await req('GET', '/stats/summary', { token: tA });
check('summary all-time', r.data.income === 42000000 && r.data.expense === 5200000, r.data);
r = await req('GET', '/stats/summary?month=bad', { token: tA });
check('summary bad month 400', r.status === 400, r);
r = await req('GET', '/stats/by-category?month=2026-09', { token: tA });
check('by-category Sep expense', r.status === 200 && r.data.length === 3 && r.data[0].category.name === 'Ăn uống' && r.data[0].amount === 3000000 && r.data[0].percentage === 85.7 && r.data[1].amount === 400000 && r.data[1].percentage === 11.4 && r.data[2].percentage === 2.9, r.data);
r = await req('GET', '/stats/by-category?month=2026-08&type=INCOME', { token: tA });
check('by-category Aug income', r.data.length === 1 && r.data[0].amount === 20000000 && r.data[0].percentage === 100, r.data);
r = await req('GET', '/stats/daily?month=2026-08', { token: tA });
check('daily Aug', JSON.stringify(r.data) === JSON.stringify([
  { date: '2026-08-05', income: 20000000, expense: 0 },
  { date: '2026-08-10', income: 0, expense: 1200000 },
  { date: '2026-08-31', income: 0, expense: 500000 },
]), r.data);
r = await req('GET', '/stats/daily?month=2026-09', { token: tA });
check('daily Sep (midnight on 09-01, 23:30 on 09-30)', JSON.stringify(r.data) === JSON.stringify([
  { date: '2026-09-01', income: 0, expense: 3000000 },
  { date: '2026-09-05', income: 22000000, expense: 0 },
  { date: '2026-09-15', income: 0, expense: 400000 },
  { date: '2026-09-30', income: 0, expense: 100000 },
]), r.data);
r = await req('GET', '/stats/trend?month=2026-09&months=3', { token: tA });
check('trend', JSON.stringify(r.data) === JSON.stringify([
  { month: '2026-07', income: 0, expense: 0, net: 0 },
  { month: '2026-08', income: 20000000, expense: 1700000, net: 18300000 },
  { month: '2026-09', income: 22000000, expense: 3500000, net: 18500000 },
]), r.data);
r = await req('GET', '/stats/trend?months=0', { token: tA });
check('trend months=0 400', r.status === 400, r);
r = await req('GET', '/stats/trend', { token: tA });
check('trend default 6 months ending current', r.status === 200 && r.data.length === 6, r);
r = await req('GET', '/stats/report?month=2026-09&observationMonths=3', { token: tA });
{
  const d = r.data;
  // forecast expense: series [0, 1,700,000, 3,500,000] weights 1,2,3 => (0+3,400,000+10,500,000)/6 = 2,316,667; avg = 1,733,333
  check('report totals', d.income === 22000000 && d.expense === 3500000 && d.net === 18500000 && d.savingRate === 84.1, d);
  check('report comparison', d.comparison.previousMonth === '2026-08' && d.comparison.income.difference === 2000000 && d.comparison.income.percentageChange === 10 && d.comparison.income.trend === 'increase'
    && d.comparison.expense.difference === 1800000 && d.comparison.expense.percentageChange === 105.9 && d.comparison.expense.trend === 'increase', d.comparison);
  check('report breakdown', d.expenseByCategory.length === 3 && d.incomeByCategory.length === 1 && d.incomeByCategory[0].amount === 22000000, d);
  check('report largest/smallest', d.largestExpense.transaction.amount === 3000000 && d.largestExpense.percentage === 85.7 && d.smallestExpense.transaction.amount === 100000 && d.smallestExpense.percentage === 2.9
    && d.largestIncome.transaction.amount === 22000000 && d.smallestIncome.transaction.amount === 22000000, { l: d.largestExpense, s: d.smallestExpense });
  check('report forecast', d.forecast.month === '2026-10' && d.forecast.expense.predicted === 2316667 && d.forecast.expense.average === 1733333 && d.forecast.expense.method === 'weighted_average'
    && d.forecast.income.predicted === Math.round((0 + 40000000 + 66000000) / 6), d.forecast);
  check('report history', d.history.length === 3, d.history);
}
r = await req('GET', '/stats/report?month=2026-09&observationMonths=1', { token: tA });
check('report obs=1 simple avg', r.status === 200 && r.data.forecast.expense.method === 'simple_average' && r.data.forecast.expense.predicted === 3500000 && r.data.comparison.previousMonth === '2026-08', r.data?.forecast);
r = await req('GET', '/stats/report?month=2026-07', { token: tA });
check('report empty month', r.status === 200 && r.data.largestExpense === null && r.data.savingRate === 0, r.data);
// stable trend check: add a month Oct? use compare directly via Jul->Aug not stable. Skip; ±5% verified via code review below.
r = await req('GET', '/stats/balance', { token: tB });
check('B balance 0', r.data.balance === 0, r.data);
// Luật ±5% = stable: B thu 1,000,000 (T8) -> 1,040,000 (T9) = +4%; chi 1,000,000 -> 940,000 = -6% decrease
r = await req('POST', '/transactions/bulk', { token: tB, body: { items: [
  { categoryId: C('Lương'), amount: 1000000, title: 'b1', occurredAt: '2026-08-10T00:00:00Z' },
  { categoryId: C('Lương'), amount: 1040000, title: 'b2', occurredAt: '2026-09-10T00:00:00Z' },
  { categoryId: C('Hóa đơn'), amount: 1000000, title: 'b3', occurredAt: '2026-08-10T00:00:00Z' },
  { categoryId: C('Hóa đơn'), amount: 940000, title: 'b4', occurredAt: '2026-09-10T00:00:00Z' },
] } });
r = await req('GET', '/stats/report?month=2026-09', { token: tB });
check('report ±5% stable / decrease', r.data.comparison.income.percentageChange === 4 && r.data.comparison.income.trend === 'stable' && r.data.comparison.expense.percentageChange === -6 && r.data.comparison.expense.trend === 'decrease', r.data.comparison);
r = await req('GET', '/transactions', { token: tA });
check('A list unaffected by B data', r.data.total === 7, r.data.total);

// ---------- BUDGETS ----------
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Ăn uống'), month: '2026-09', limitAmount: 3500000 } });
check('budget create warning (3.0M/3.5M = 85.7%)', r.status === 201 && r.data.spent === 3000000 && r.data.remaining === 500000 && r.data.percentage === 85.7 && r.data.status === 'warning', r.data);
const bFood = r.data;
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Di chuyển'), month: '2026-09', limitAmount: 400000 } });
check('budget exceeded at 100%', r.data.status === 'exceeded' && r.data.percentage === 100 && r.data.remaining === 0, r.data);
const bMove = r.data;
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Mua sắm'), month: '2026-09', limitAmount: 1000000 } });
check('budget ok 0 spent', r.data.status === 'ok' && r.data.spent === 0, r.data);
const bShop = r.data;
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Ăn uống'), month: '2026-09', limitAmount: 1 } });
check('budget dup 409', r.status === 409, r);
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Lương'), month: '2026-09', limitAmount: 1000 } });
check('budget INCOME cat 400', r.status === 400, r);
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Mua sắm'), month: '2026/09', limitAmount: 1000 } });
check('budget bad month 400', r.status === 400, r);
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Mua sắm'), month: '2026-10', limitAmount: -1 } });
check('budget negative 400', r.status === 400, r);
r = await req('GET', '/budgets?month=2026-09', { token: tA });
check('budget list', r.status === 200 && r.data.items.length === 3 && r.data.totalLimit === 4900000 && r.data.totalSpent === 3400000 && r.data.totalRemaining === 1500000, r.data);
r = await req('PATCH', `/budgets/${bFood.id}`, { token: tA, body: { limitAmount: 2000000 } });
check('budget patch -> exceeded 150%', r.data.status === 'exceeded' && r.data.percentage === 150 && r.data.remaining === -1000000, r.data);
r = await req('PATCH', `/budgets/${bFood.id}`, { token: tB, body: { limitAmount: 1 } });
check('B patch A budget 404', r.status === 404, r);
r = await req('DELETE', `/budgets/${bFood.id}`, { token: tB });
check('B delete A budget 404', r.status === 404, r);
r = await req('GET', '/budgets?month=2026-09', { token: tB });
check('B budget list empty', r.data.items.length === 0, r.data);
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Mua sắm'), month: '2026-10', limitAmount: 777 } });
check('pre-existing target budget', r.status === 201, r);
r = await req('POST', '/budgets/copy', { token: tA, body: { fromMonth: '2026-09', toMonth: '2026-10' } });
check('budget copy (skip existing)', r.status === 201 && r.data.copied === 2, r.data);
r = await req('GET', '/budgets?month=2026-10', { token: tA });
check('budget copy result', r.data.items.length === 3 && r.data.items.find((b) => b.category.id === C('Mua sắm')).limitAmount === 777 && r.data.items.find((b) => b.category.id === C('Ăn uống')).limitAmount === 2000000, r.data);
r = await req('POST', '/budgets/copy', { token: tA, body: { fromMonth: '2026-9', toMonth: '2026-10' } });
check('budget copy bad month 400', r.status === 400, r);
r = await req('GET', '/budgets?month=2026-00', { token: tA });
check('budget list bad month 400', r.status === 400, r);
r = await req('DELETE', `/budgets/${bShop.id}`, { token: tA });
check('budget delete 204', r.status === 204, r);

// ---------- SAVING GOALS ----------
// balance now 36,800,000
r = await req('POST', '/saving-goals', { token: tA, body: { name: 'Laptop', targetAmount: 30000000, targetDate: '2027-06-01T00:00:00Z' } });
check('goal create', r.status === 201 && r.data.status === 'ACTIVE' && r.data.savedAmount === 0 && r.data.remaining === 30000000, r.data);
const g1 = r.data;
r = await req('POST', '/saving-goals', { token: tA, body: { name: 'Bad', targetAmount: 1000, startDate: '2027-01-01T00:00:00Z', targetDate: '2026-01-01T00:00:00Z' } });
check('goal targetDate before start 400', r.status === 400, r);
r = await req('POST', '/saving-goals', { token: tA, body: { name: ' ', targetAmount: 1000, targetDate: '2027-01-01T00:00:00Z' } });
check('goal blank name 400', r.status === 400, r);
r = await req('POST', '/saving-goals', { token: tA, body: { name: 'x', targetAmount: 1000 } });
check('goal missing targetDate 400', r.status === 400, r);
r = await req('POST', `/saving-goals/${g1.id}/deposit`, { token: tA, body: { amount: 10000000 } });
check('deposit 10M', r.status === 200 && r.data.deposited === 10000000 && r.data.capped === false && r.data.goal.savedAmount === 10000000 && r.data.goal.status === 'ACTIVE', r.data);
r = await req('GET', '/stats/balance', { token: tA });
check('balance after deposit', r.data.balance === 26800000 && r.data.savings === 10000000, r.data);
r = await req('POST', `/saving-goals/${g1.id}/deposit`, { token: tA, body: { amount: 26900000 } });
check('deposit capped at 20M (remaining needed) even though > balance', r.status === 200 && r.data.deposited === 20000000 && r.data.capped === true && r.data.goal.status === 'COMPLETED' && r.data.goal.progress === 100, r.data);
r = await req('GET', '/stats/balance', { token: tA });
check('balance after complete', r.data.balance === 6800000 && r.data.savings === 30000000, r.data);
r = await req('POST', `/saving-goals/${g1.id}/deposit`, { token: tA, body: { amount: 1 } });
check('deposit to completed 409', r.status === 409, r);
r = await req('POST', '/saving-goals', { token: tA, body: { name: 'Xe', targetAmount: 100000000, targetDate: '2028-01-01T00:00:00Z', color: '#FF0000' } });
const g2 = r.data;
r = await req('POST', `/saving-goals/${g2.id}/deposit`, { token: tA, body: { amount: 6800001 } });
check('deposit insufficient balance 400', r.status === 400, r);
r = await req('POST', `/saving-goals/${g2.id}/deposit`, { token: tA, body: { amount: 6800000, date: '2026-09-20T00:00:00Z' } });
check('deposit exact balance ok', r.status === 200 && r.data.deposited === 6800000, r.data);
r = await req('GET', '/stats/balance', { token: tA });
check('balance 0', r.data.balance === 0, r.data);
r = await req('POST', `/saving-goals/${g2.id}/deposit`, { token: tB, body: { amount: 1 } });
check('B deposit A goal 404', r.status === 404, r);
r = await req('GET', `/saving-goals/${g2.id}`, { token: tB });
check('B get A goal 404', r.status === 404, r);
r = await req('POST', `/saving-goals/${g2.id}/withdraw`, { token: tB });
check('B withdraw A goal 404', r.status === 404, r);
r = await req('DELETE', `/saving-goals/${g1.id}`, { token: tA });
check('delete goal with money 409', r.status === 409, r);
r = await req('GET', '/saving-goals', { token: tA });
check('goal list', r.status === 200 && r.data.length === 2, r.data);
r = await req('GET', '/saving-goals?status=COMPLETED', { token: tA });
check('goal list filter status', r.data.length === 1 && r.data[0].id === g1.id, r.data);
r = await req('GET', `/saving-goals/${g1.id}`, { token: tA });
check('goal detail entries', r.status === 200 && r.data.entries.length === 2 && r.data.entries.every((e) => e.type === 'DEPOSIT'), r.data);
r = await req('POST', `/saving-goals/${g1.id}/withdraw`, { token: tA });
check('withdraw completed -> WITHDRAWN', r.status === 200 && r.data.withdrawn === 30000000 && r.data.goal.status === 'WITHDRAWN' && r.data.goal.savedAmount === 0, r.data);
r = await req('GET', '/stats/balance', { token: tA });
check('balance restored after withdraw', r.data.balance === 30000000 && r.data.savings === 6800000, r.data);
r = await req('POST', `/saving-goals/${g1.id}/deposit`, { token: tA, body: { amount: 1 } });
check('deposit to withdrawn 409', r.status === 409, r);
r = await req('POST', `/saving-goals/${g1.id}/withdraw`, { token: tA });
check('withdraw twice 409', r.status === 409, r);
r = await req('POST', `/saving-goals/${g2.id}/withdraw`, { token: tA });
check('early withdraw', r.status === 200 && r.data.goal.status === 'EARLY_WITHDRAWN' && r.data.withdrawn === 6800000, r.data);
r = await req('GET', '/stats/balance', { token: tA });
check('balance fully restored', r.data.balance === 36800000 && r.data.savings === 0, r.data);
r = await req('PATCH', `/saving-goals/${g2.id}`, { token: tA, body: { name: 'Xe máy', targetAmount: 50 } });
check('patch closed goal keeps status', r.status === 200 && r.data.name === 'Xe máy' && r.data.status === 'EARLY_WITHDRAWN', r.data);
r = await req('POST', '/saving-goals', { token: tA, body: { name: 'Empty', targetAmount: 1000, targetDate: '2027-01-01T00:00:00Z' } });
const g3 = r.data;
r = await req('POST', `/saving-goals/${g3.id}/withdraw`, { token: tA });
check('withdraw empty goal 400', r.status === 400, r);
r = await req('POST', `/saving-goals/${g3.id}/deposit`, { token: tA, body: { amount: 400 } });
r = await req('PATCH', `/saving-goals/${g3.id}`, { token: tA, body: { targetAmount: 400 } });
check('patch target down to saved -> COMPLETED', r.data.status === 'COMPLETED', r.data);
r = await req('PATCH', `/saving-goals/${g3.id}`, { token: tA, body: { targetAmount: 1000 } });
check('patch target up -> ACTIVE', r.data.status === 'ACTIVE', r.data);
r = await req('PATCH', `/saving-goals/${g3.id}`, { token: tA, body: { targetDate: '2000-01-01T00:00:00Z' } });
check('patch targetDate before start 400', r.status === 400, r);
r = await req('POST', `/saving-goals/${g3.id}/withdraw`, { token: tA });
r = await req('DELETE', `/saving-goals/${g3.id}`, { token: tA });
check('delete emptied goal 204', r.status === 204, r);
r = await req('DELETE', `/saving-goals/${g1.id}`, { token: tA });
check('delete withdrawn goal 204', r.status === 204, r);
r = await req('POST', `/saving-goals/${g2.id}/deposit`, { token: tA, body: { amount: 0 } });
check('deposit 0 400', r.status === 400, r);

// ---------- ADMIN ----------
r = await req('GET', '/admin/overview', { token: tA });
check('non-admin overview 403', r.status === 403, r);
r = await req('GET', '/admin/users', { token: tB });
check('non-admin users 403', r.status === 403, r);
r = await req('POST', '/auth/login', { body: { email: ADMIN_EMAIL, password: ADMIN_PASSWORD } });
check('admin login', r.status === 200 && r.data.user.role === 'ADMIN', r);
const tAd = r.data.accessToken; const idAd = r.data.user.id;
r = await req('GET', '/admin/overview', { token: tAd });
check('admin overview', r.status === 200 && r.data.users.total >= 3 && r.data.transactions.total >= 7 && Array.isArray(r.data.trend) && r.data.trend.length === 6, r.data);
const ov = r.data;
r = await req('GET', '/admin/users', { token: tAd });
check('admin users list', r.status === 200 && r.data.total >= 3 && r.data.items.every((u) => !('passwordHash' in u)) && r.data.items[0]._count, r.data);
r = await req('GET', `/admin/users?q=${encodeURIComponent('a' + S)}`, { token: tAd });
check('admin users search', r.data.total === 1 && r.data.items[0].id === idA && r.data.items[0]._count.transactions === 7, r.data);
r = await req('GET', '/admin/users?role=ADMIN', { token: tAd });
check('admin users role filter', r.data.items.every((u) => u.role === 'ADMIN') && r.data.total >= 1, r.data);
r = await req('GET', `/admin/users/${idA}`, { token: tAd });
check('admin user detail', r.status === 200 && r.data.finance.balance === 36800000 && !('passwordHash' in r.data) && r.data._count.transactions === 7 && r.data.trend.length === 6, r.data);
r = await req('GET', `/admin/users/00000000-0000-4000-8000-000000000000`, { token: tAd });
check('admin user detail 404', r.status === 404, r);
r = await req('PATCH', `/admin/users/${idAd}`, { token: tAd, body: { status: 'LOCKED' } });
check('admin lock self 400', r.status === 400, r);
r = await req('PATCH', `/admin/users/${idAd}`, { token: tAd, body: { role: 'USER' } });
check('admin demote self 400', r.status === 400, r);
r = await req('PATCH', `/admin/users/00000000-0000-4000-8000-000000000000`, { token: tAd, body: { status: 'LOCKED' } });
check('admin lock unknown 404', r.status === 404, r);
r = await req('PATCH', `/admin/users/${idB}`, { token: tAd, body: { status: 'FROZEN' } });
check('admin bad status 400', r.status === 400, r);
r = await req('PATCH', `/admin/users/${idB}`, { token: tAd, body: { status: 'LOCKED' } });
check('admin lock B', r.status === 200 && r.data.status === 'LOCKED' && !('passwordHash' in r.data), r.data);
r = await req('GET', '/me', { token: tB });
check('locked B token 403', r.status === 403, r);
r = await req('GET', '/transactions', { token: tB });
check('locked B token 403 on data route', r.status === 403, r);
r = await req('POST', '/auth/login', { body: { email: emailB, password: 'secret2' } });
check('locked B login fails 403', r.status === 403, r);
r = await req('GET', '/admin/users?status=LOCKED', { token: tAd });
check('admin users filter LOCKED', r.data.items.some((u) => u.id === idB), r.data);
r = await req('PATCH', `/admin/users/${idB}`, { token: tAd, body: { status: 'ACTIVE' } });
r = await req('GET', '/me', { token: tB });
check('unlocked B token works', r.status === 200, r);
r = await req('GET', `/admin/transactions?userId=${idA}`, { token: tAd });
check('admin tx filter userId', r.status === 200 && r.data.total === 7 && r.data.items.every((t) => t.user.id === idA), r.data);
r = await req('GET', `/admin/transactions?userId=${idA}&month=2026-09&type=EXPENSE`, { token: tAd });
check('admin tx filter combo', r.data.total === 3, r.data);
r = await req('GET', `/admin/transactions?userId=bad`, { token: tAd });
check('admin tx bad userId 400', r.status === 400, r);
r = await req('GET', `/admin/transactions`, { token: tAd });
check('admin tx all paged default', r.status === 200 && r.data.page === 1 && r.data.limit === 20, r.data);
// system categories
r = await req('GET', '/admin/categories', { token: tAd });
check('admin system categories', r.status === 200 && r.data.filter((c) => !c.isArchived).length === sysCount && r.data.every((c) => c.userId === null && c._count), r.data?.length);
r = await req('GET', '/admin/categories?type=EXPENSE', { token: tAd });
check('admin system categories filter', r.data.length > 0 && r.data.every((c) => c.type === 'EXPENSE'), r.data.length);
r = await req('POST', '/admin/categories', { token: tAd, body: { name: `Từ thiện ${S}`, type: 'EXPENSE', icon: 'heart' } });
check('admin create system cat', r.status === 201 && r.data.userId === null, r.data);
const charity = r.data;
r = await req('POST', '/admin/categories', { token: tAd, body: { name: `TỪ THIỆN ${S}`, type: 'EXPENSE' } });
check('admin dup system cat 409', r.status === 409, r);
r = await req('GET', '/categories', { token: tB });
check('user sees new system cat', r.data.some((c) => c.id === charity.id), r.data.length);
r = await req('PATCH', `/admin/categories/${charity.id}`, { token: tAd, body: { color: '#ABCDEF' } });
check('admin update system cat', r.status === 200 && r.data.color === '#ABCDEF', r.data);
r = await req('PATCH', `/admin/categories/${coffeeB.id}`, { token: tAd, body: { color: '#ABCDEF' } });
check('admin update user cat via system route 404', r.status === 404, r);
r = await req('POST', '/transactions', { token: tB, body: { categoryId: charity.id, amount: 50000, title: 'Quyên góp' } });
check('B uses system cat', r.status === 201, r);
const txCharity = r.data;
r = await req('DELETE', `/admin/categories/${charity.id}`, { token: tAd });
check('admin delete used system cat -> archived', r.status === 200 && r.data.archived === true, r.data);
r = await req('GET', '/categories', { token: tB });
check('archived system cat hidden from user', !r.data.some((c) => c.id === charity.id), r.data.length);
r = await req('GET', '/admin/categories', { token: tAd });
check('admin still sees archived', r.data.some((c) => c.id === charity.id && c.isArchived), null);
r = await req('POST', `/admin/categories/${charity.id}/restore`, { token: tAd });
check('admin restore', r.status === 200 && r.data.isArchived === false, r.data);
r = await req('GET', '/categories', { token: tB });
check('restored visible', r.data.some((c) => c.id === charity.id), null);
r = await req('POST', '/admin/categories', { token: tAd, body: { name: `Tạm ${S}`, type: 'INCOME' } });
r = await req('DELETE', `/admin/categories/${r.data.id}`, { token: tAd });
check('admin delete unused system cat -> hard', r.status === 200 && r.data.archived === false, r.data);
r = await req('POST', '/admin/categories', { token: tA, body: { name: 'Hack', type: 'INCOME' } });
check('non-admin create system cat 403', r.status === 403, r);
// Dọn: bỏ giao dịch dùng danh mục hệ thống thử nghiệm rồi xóa hẳn danh mục đó để lần chạy sau không lệch số lượng
r = await req('DELETE', `/transactions/${txCharity.id}`, { token: tB });
r = await req('DELETE', `/admin/categories/${charity.id}`, { token: tAd });
check('cleanup: unused system cat hard-deleted', r.status === 200 && r.data.archived === false, r.data);
r = await fetch(BASE.replace(/\/api$/, '') + '/docs/openapi.json');
{
  const doc = r.status === 200 ? await r.json() : { paths: {}, components: { schemas: {} } };
  check('swagger openapi.json (29 paths)', Object.keys(doc.paths).length === 29, Object.keys(doc.paths).length);
  check('swagger DTO schemas populated', ['amount', 'categoryId', 'title'].every((k) => k in (doc.components.schemas.CreateTransactionDto?.properties ?? {})), doc.components.schemas.CreateTransactionDto);
}

console.log(`\nPASS ${pass}  FAIL ${fail}`);
if (fails.length) console.log('Failed:', fails);
process.exit(fail ? 1 : 0);
