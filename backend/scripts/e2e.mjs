// E2E kiểm thử toàn bộ API (fetch thuần, không framework). Chạy: npm run test:e2e
//   API_URL   mặc định http://localhost:3000/api
//   API_LOG   file log của server (đọc OTP quên mật khẩu khi chưa cấu hình SMTP), mặc định /tmp/tracker-api.log
//   ADMIN_EMAIL / ADMIN_PASSWORD  mặc định theo .env.example
// Email/tên ngẫu nhiên nên chạy lặp được không cần reset DB. Exit code 1 nếu có lỗi.
// Server phải chạy với NODE_ENV=test (cần POST /recurring/run-due + giới hạn tần suất nới cho test: cửa sổ 10s).
// Có 1 lần chờ 61s (giới hạn gửi lại OTP), ~31s (chờ gửi lại OTP theo cấu hình) và ~10s chờ hết khóa 429 ở cuối.
// Nhóm "config:" đổi Cấu hình hệ thống rồi khôi phục giá trị ban đầu ở cuối nhóm (kể cả khi lỗi).
import { readFileSync } from 'node:fs';
import net from 'node:net';

const BASE = process.env.API_URL ?? 'http://localhost:3000/api';
const API_LOG = process.env.API_LOG ?? '/tmp/tracker-api.log';
const ADMIN_EMAIL = process.env.ADMIN_EMAIL ?? 'admin@tracker.local';
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD ?? 'admin123';

let pass = 0, fail = 0, section = '';
const fails = [];
const matrix = new Map();
function group(name) { section = name; if (!matrix.has(name)) matrix.set(name, { pass: 0, fail: 0 }); }
function check(name, cond, extra) {
  const m = matrix.get(section);
  if (cond) { pass++; m.pass++; } else {
    fail++; m.fail++; fails.push(`[${section}] ${name}`);
    console.log(`FAIL [${section}]`, name, extra !== undefined ? JSON.stringify(extra).slice(0, 700) : '');
  }
}
async function req(method, path, { token, body } = {}) {
  const r = await fetch(BASE + path, {
    method,
    headers: { 'content-type': 'application/json', ...(token ? { authorization: `Bearer ${token}` } : {}) },
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });
  const text = await r.text();
  let data; try { data = text ? JSON.parse(text) : null; } catch { data = text; }
  return { status: r.status, data, text, headers: r.headers };
}
const sleep = (ms) => new Promise((res) => setTimeout(res, ms));
const S = `${Date.now()}${Math.floor(Math.random() * 1000)}`;
const DAY = 86400000;
const vnDate = (iso) => new Date(new Date(iso).getTime() + 7 * 3600000).toISOString().slice(0, 10);
const iso = (ms) => new Date(Math.floor(ms / 60000) * 60000).toISOString();
let userSeq = 0;
async function newUser(prefix) {
  const email = `${prefix}${S}-${++userSeq}@test.local`;
  const r = await req('POST', '/auth/register', { body: { email, password: 'secret1', name: prefix } });
  const w = await req('GET', '/wallets', { token: r.data.accessToken });
  return { email, token: r.data.accessToken, id: r.data.user.id, cash: w.data.items[0].id };
}

/** Máy chủ SMTP giả (đủ lệnh cho nodemailer): ghi lại AUTH PLAIN + nội dung thư, trả 250. */
function fakeSmtp() {
  const mails = [];
  const server = net.createServer((sock) => {
    let data = null, buf = '', auth = null;
    sock.write('220 fake ESMTP\r\n');
    sock.on('data', (chunk) => {
      buf += chunk.toString('utf8');
      let i;
      while ((i = buf.indexOf('\r\n')) >= 0) {
        const line = buf.slice(0, i); buf = buf.slice(i + 2);
        if (data) {
          if (line === '.') { mails.push({ auth, raw: data.join('\n') }); data = null; sock.write('250 2.0.0 OK queued\r\n'); }
          else data.push(line.startsWith('..') ? line.slice(1) : line);
          continue;
        }
        const cmd = line.slice(0, 4).toUpperCase();
        if (cmd === 'EHLO') sock.write('250-fake\r\n250-AUTH PLAIN\r\n250 8BITMIME\r\n');
        else if (cmd === 'AUTH') { const p = Buffer.from(line.split(' ')[2] ?? '', 'base64').toString().split('\0'); auth = { user: p[1], pass: p[2] }; sock.write('235 2.7.0 Authentication successful\r\n'); }
        else if (cmd === 'DATA') { data = []; sock.write('354 End data with <CR><LF>.<CR><LF>\r\n'); }
        else if (cmd === 'QUIT') { sock.write('221 Bye\r\n'); sock.end(); }
        else sock.write('250 OK\r\n');
      }
    });
    sock.on('error', () => {});
  });
  return new Promise((res) => server.listen(0, '127.0.0.1', () => res({ port: server.address().port, mails, close: () => new Promise((r2) => server.close(r2)) })));
}

// ================= AUTH =================
group('auth: đăng ký / đăng nhập / hồ sơ');
const emailA = `a${S}@test.local`, emailB = `b${S}@test.local`;
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
r = await req('POST', '/auth/register', { body: { email: `c${S}@x.local`, password: 'secret1', name: '   ' } });
check('register blank name 400', r.status === 400, r);
r = await req('POST', '/auth/login', { body: { email: emailA, password: 'wrong' } });
check('login wrong pw 401', r.status === 401, r);
r = await req('POST', '/auth/login', { body: { email: `nobody${S}@test.local`, password: 'secret1' } });
check('login unknown email 401', r.status === 401, r);
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
check('patch me trims', r.status === 200 && r.data.name === 'Alice', r);
r = await req('PATCH', '/me', { token: tA, body: { name: '   ' } });
check('patch me blank name 400', r.status === 400, r);
r = await req('POST', '/me/password', { token: tA, body: { currentPassword: 'nope', newPassword: 'secret9' } });
check('change pw wrong current 400', r.status === 400, r);
r = await req('POST', '/me/password', { token: tA, body: { currentPassword: 'secret1', newPassword: '123' } });
check('change pw too short 400', r.status === 400, r);
r = await req('POST', '/me/password', { token: tA, body: { currentPassword: 'secret1', newPassword: 'secret9' } });
check('change pw 200 + fresh token', r.status === 200 && r.data.accessToken && r.data.user.id === idA && !('tokenVersion' in r.data.user), r);
{
  const fresh = r.data.accessToken;
  r = await req('GET', '/me', { token: tA });
  check('old token after change pw 401', r.status === 401, r);
  r = await req('GET', '/me', { token: fresh });
  check('fresh token from change pw works', r.status === 200 && r.data.id === idA && !('tokenVersion' in r.data), r);
}
r = await req('POST', '/auth/login', { body: { email: emailA, password: 'secret1' } });
check('login old pw 401', r.status === 401, r);
r = await req('POST', '/auth/login', { body: { email: emailA, password: 'secret9' } });
check('login new pw', r.status === 200, r);
tA = r.data.accessToken;

// ================= WALLETS =================
group('wallets: CRUD / số dư / lưu trữ');
r = await req('GET', '/wallets', { token: tA });
check('register auto-creates "Tiền mặt" CASH 0', r.status === 200 && r.data.items.length === 1 && r.data.items[0].name === 'Tiền mặt' && r.data.items[0].type === 'CASH' && r.data.items[0].balance === 0 && r.data.totalBalance === 0, r.data);
const wCash = r.data.items[0].id;
r = await req('POST', '/wallets', { token: tA, body: { name: 'Ngân hàng', type: 'BANK', initialBalance: 5000000, color: '#123456' } });
check('create bank wallet', r.status === 201 && r.data.balance === 5000000 && r.data.initialBalance === 5000000, r.data);
const wBank = r.data.id;
r = await req('POST', '/wallets', { token: tA, body: { name: 'ngân HÀNG', type: 'BANK' } });
check('dup wallet name 409', r.status === 409, r);
r = await req('POST', '/wallets', { token: tA, body: { name: 'Âm', type: 'CASH', initialBalance: -1 } });
check('negative initialBalance 400', r.status === 400, r);
r = await req('POST', '/wallets', { token: tA, body: { name: 'X', type: 'CRYPTO' } });
check('bad wallet type 400', r.status === 400, r);
r = await req('POST', '/wallets', { token: tA, body: { name: '  ', type: 'CASH' } });
check('blank wallet name 400', r.status === 400, r);
r = await req('POST', '/wallets', { token: tA, body: { name: 'MoMo', type: 'EWALLET' } });
const wMomo = r.data.id;
r = await req('PATCH', `/wallets/${wMomo}`, { token: tA, body: { name: 'Ví MoMo', initialBalance: 200 } });
check('update wallet', r.status === 200 && r.data.name === 'Ví MoMo' && r.data.balance === 200, r.data);
r = await req('PATCH', `/wallets/${wMomo}`, { token: tA, body: { name: 'Ngân hàng' } });
check('rename to existing 409', r.status === 409, r);
r = await req('GET', `/wallets/${wMomo}`, { token: tB });
check('B get A wallet 404', r.status === 404, r);
r = await req('PATCH', `/wallets/${wMomo}`, { token: tB, body: { name: 'hack' } });
check('B patch A wallet 404', r.status === 404, r);
r = await req('DELETE', `/wallets/${wMomo}`, { token: tB });
check('B delete A wallet 404', r.status === 404, r);
r = await req('DELETE', `/wallets/${wMomo}`, { token: tA });
check('delete wallet without activity -> hard delete', r.status === 200 && r.data.archived === false, r.data);
r = await req('GET', `/wallets/${wMomo}`, { token: tA });
check('hard-deleted wallet 404', r.status === 404, r);
r = await req('GET', '/wallets', { token: tB });
check('B sees only own wallet', r.data.items.length === 1 && r.data.items[0].id !== wCash, r.data);
const wCashB = r.data.items[0].id;

// ================= CATEGORIES =================
group('categories: CRUD / trùng tên / lưu trữ');
r = await req('GET', '/categories', { token: tA });
check('categories list = system only', r.status === 200 && r.data.length >= 14 && r.data.every((c) => c.userId === null), r.data?.length);
const sysCount = r.data.length;
const sysIncome = r.data.filter((c) => c.type === 'INCOME').length;
const sys = Object.fromEntries(r.data.map((c) => [c.name, c]));
const C = (name) => sys[name].id;
const viSorted = (names) => [...names].sort(new Intl.Collator('vi').compare);
check('system categories sorted Vietnamese (Ăn uống before Sức khỏe)', JSON.stringify(r.data.map((c) => c.name)) === JSON.stringify(viSorted(r.data.map((c) => c.name)))
  && r.data.findIndex((c) => c.name === 'Ăn uống') < r.data.findIndex((c) => c.name === 'Sức khỏe') && r.data.findIndex((c) => c.name === 'Di chuyển') < r.data.findIndex((c) => c.name === 'Đầu tư'), r.data.map((c) => c.name));
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
r = await req('PATCH', `/categories/${C('Ăn uống')}`, { token: tA, body: { name: 'hack' } });
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
check('user categories listed after system ones', r.data.at(-1).id === coffeeB.id, r.data.map((c) => c.name));

// ================= TRANSACTIONS =================
group('transactions: CRUD / lọc / bulk / cách ly');
// Aug 2026 (VN): Lương 20M (cash); Đi chợ 1M (cash, sau sửa 1.2M); Ăn tối 500k lúc 23:59 VN 31/8 (cash)
// Sep 2026 (VN): Lương 22M (cash); Tiệc 3M lúc 00:30 VN 1/9 (cash); Grab 400k (bank); Highlands 100k lúc 23:30 VN 30/9 (cash, Cafe)
const exp = { cash: 0, bank: 5000000 };
const txs = [
  { categoryId: C('Lương'), walletId: wCash, amount: 20000000, title: 'Lương T8', occurredAt: '2026-08-05T03:00:00Z' },
  { categoryId: C('Ăn uống'), walletId: wCash, amount: 1000000, title: 'Đi chợ', note: 'siêu thị', occurredAt: '2026-08-10T05:00:00Z' },
  { categoryId: C('Ăn uống'), walletId: wCash, amount: 500000, title: 'Ăn tối cuối tháng', occurredAt: '2026-08-31T16:59:00Z' },
];
const created = [];
for (const t of txs) {
  r = await req('POST', '/transactions', { token: tA, body: t });
  const cat = Object.values(sys).find((c) => c.id === t.categoryId);
  check(`create tx ${t.title}`, r.status === 201 && r.data.type === cat.type && r.data.amount === t.amount && r.data.category?.name && r.data.wallet?.id === wCash && r.data.recurring === false, r);
  created.push(r.data);
}
r = await req('POST', '/transactions/bulk', { token: tA, body: { items: [
  { categoryId: C('Lương'), walletId: wCash, amount: 22000000, title: 'Lương T9', occurredAt: '2026-09-05T03:00:00Z' },
  { categoryId: C('Ăn uống'), walletId: wCash, amount: 3000000, title: 'Tiệc nửa đêm', occurredAt: '2026-08-31T17:30:00Z' },
  { categoryId: C('Di chuyển'), walletId: wBank, amount: 400000, title: 'Grab', note: 'đi làm', occurredAt: '2026-09-15T02:00:00Z' },
  { categoryId: coffee.id, walletId: wCash, amount: 100000, title: 'Highlands', occurredAt: '2026-09-30T16:30:00Z' },
] } });
check('bulk create 4', r.status === 201 && r.data.created === 4, r);
exp.cash += 20000000 - 1000000 - 500000 + 22000000 - 3000000 - 100000;
exp.bank -= 400000;
r = await req('POST', '/transactions/bulk', { token: tA, body: { items: [
  { categoryId: C('Lương'), walletId: wCash, amount: 1, title: 'ok' },
  { categoryId: coffeeB.id, walletId: wCash, amount: 1, title: 'other user cat' },
] } });
check('bulk with foreign cat 400 (all-or-nothing)', r.status === 400, r);
r = await req('POST', '/transactions/bulk', { token: tA, body: { items: [{ categoryId: C('Lương'), walletId: wCashB, amount: 1, title: 'x' }] } });
check('bulk with foreign wallet 400', r.status === 400, r);
r = await req('POST', '/transactions/bulk', { token: tA, body: { items: [] } });
check('bulk empty 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Lương'), amount: 5, title: 'no wallet' } });
check('missing walletId 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Lương'), walletId: wCashB, amount: 5, title: 'B wallet' } });
check('other user wallet 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Lương'), walletId: wCash, amount: -5, title: 'neg' } });
check('negative amount 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Lương'), walletId: wCash, amount: 5, title: '  ' } });
check('blank title 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Lương'), walletId: wCash, amount: 1e14, title: 'too big' } });
check('amount > MAX 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Lương'), walletId: wCash, amount: 1.5, title: 'frac' } });
check('fractional amount 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Lương'), walletId: wCash, amount: 5, title: 'x', type: 'EXPENSE' } });
check('unknown field type 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: coffeeB.id, walletId: wCash, amount: 5, title: 'x' } });
check('use other user cat 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Lương'), walletId: wCash, amount: 5, title: 'x', occurredAt: 'yesterday' } });
check('bad date 400', r.status === 400, r);

r = await req('GET', '/transactions', { token: tA });
check('list all 7', r.status === 200 && r.data.total === 7 && r.data.page === 1 && r.data.limit === 20 && r.data.items.length === 7 && r.data.items.every((t) => t.wallet && t.recurring === false), r.data);
check('list sorted desc', r.data.items.every((t, i, a) => i === 0 || new Date(a[i - 1].occurredAt) >= new Date(t.occurredAt)));
r = await req('GET', '/transactions?month=2026-08', { token: tA });
check('filter month 08 = 3 (00:30 VN 1/9 excluded)', r.data.total === 3 && !r.data.items.some((t) => t.title === 'Tiệc nửa đêm'), r.data.items?.map((t) => t.title));
r = await req('GET', '/transactions?month=2026-09', { token: tA });
check('filter month 09 = 4 (00:30 VN 1/9 included)', r.data.total === 4 && r.data.items.some((t) => t.title === 'Tiệc nửa đêm'), r.data.items?.map((t) => t.title));
r = await req('GET', '/transactions?type=INCOME', { token: tA });
check('filter type INCOME', r.data.total === 2 && r.data.items.every((t) => t.type === 'INCOME'), r.data);
r = await req('GET', `/transactions?categoryId=${C('Ăn uống')}`, { token: tA });
check('filter categoryId', r.data.total === 3, r.data);
r = await req('GET', `/transactions?walletId=${wBank}`, { token: tA });
check('filter walletId', r.data.total === 1 && r.data.items[0].title === 'Grab', r.data);
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
r = await req('GET', '/transactions?page=0', { token: tA });
check('page 0 400', r.status === 400, r);
r = await req('GET', '/transactions?month=2026-13', { token: tA });
check('bad month 400', r.status === 400, r);
r = await req('GET', '/transactions?month=2026-8', { token: tA });
check('bad month (2026-8) 400', r.status === 400, r);
r = await req('GET', '/transactions?from=2026-09-01T00:00:00%2B07:00&to=2026-09-15T00:00:00%2B07:00', { token: tA });
check('filter from/to (to exclusive)', r.data.total === 2, r.data.items?.map((t) => t.title));
r = await req('GET', '/transactions?foo=1', { token: tA });
check('unknown query param 400', r.status === 400, r);

const txA = created[1];
r = await req('GET', `/transactions/${txA.id}`, { token: tA });
check('get tx', r.status === 200 && r.data.id === txA.id && r.data.wallet.name === 'Tiền mặt', r);
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
r = await req('PATCH', `/transactions/${txA.id}`, { token: tA, body: { walletId: wBank } });
check('patch tx wallet', r.status === 200 && r.data.wallet.id === wBank, r.data);
r = await req('GET', '/wallets', { token: tA });
check('balance moved with wallet change (income 1M now in bank)', r.data.items.find((w) => w.id === wBank).balance === exp.bank + 1000000, r.data);
r = await req('PATCH', `/transactions/${txA.id}`, { token: tA, body: { walletId: wCashB } });
check('patch tx to B wallet 400', r.status === 400, r);
r = await req('PATCH', `/transactions/${txA.id}`, { token: tA, body: { categoryId: C('Ăn uống'), walletId: wCash, amount: 1200000, note: '' } });
check('patch tx back + amount + clear note', r.status === 200 && r.data.type === 'EXPENSE' && r.data.amount === 1200000 && r.data.note === null && r.data.wallet.id === wCash, r);
exp.cash -= 200000;
r = await req('PATCH', `/transactions/${txA.id}`, { token: tA, body: { amount: 0 } });
check('patch amount 0 400', r.status === 400, r);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Chi khác'), walletId: wCash, amount: 7, title: 'temp' } });
const tmp = r.data;
check('create default occurredAt now', r.status === 201 && Math.abs(new Date(tmp.occurredAt) - Date.now()) < 60000, r);
r = await req('DELETE', `/transactions/${tmp.id}`, { token: tA });
check('delete tx 204', r.status === 204, r);
r = await req('DELETE', `/transactions/${tmp.id}`, { token: tA });
check('delete again 404', r.status === 404, r);
let txCountA = 7;

group('categories: lưu trữ khi đã dùng');
r = await req('DELETE', `/categories/${coffee.id}`, { token: tA });
check('delete used cat -> archived', r.status === 200 && r.data.archived === true, r);
r = await req('GET', '/categories', { token: tA });
check('archived hidden from list', !r.data.some((c) => c.id === coffee.id), r.data.length);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: coffee.id, walletId: wCash, amount: 5, title: 'x' } });
check('create tx in archived cat 400', r.status === 400, r);
r = await req('GET', '/transactions?month=2026-09', { token: tA });
check('tx in archived cat still listed', r.data.items.some((t) => t.category.id === coffee.id), r.data);
r = await req('POST', '/categories', { token: tA, body: { name: 'Cafe', type: 'EXPENSE' } });
check('recreate same name after archive ok', r.status === 201, r);

// ================= STATS =================
group('stats: số dư / tổng hợp / theo ví / mốc nửa đêm');
// cash = 20M - 1.2M - 0.5M + 22M - 3M - 0.1M = 37.2M ; bank = 5M - 0.4M = 4.6M
check('expected cash/bank', exp.cash === 37200000 && exp.bank === 4600000, exp);
r = await req('GET', '/stats/balance', { token: tA });
check('balance = sum wallets', r.status === 200 && r.data.balance === 41800000 && r.data.totalIncome === 42000000 && r.data.totalExpense === 5200000 && r.data.savings === 0
  && r.data.wallets.length === 2 && r.data.wallets.find((w) => w.id === wCash).balance === 37200000 && r.data.wallets.find((w) => w.id === wBank).balance === 4600000, r.data);
r = await req('GET', '/stats/summary?month=2026-08', { token: tA });
check('summary Aug', r.data.income === 20000000 && r.data.expense === 1700000 && r.data.net === 18300000 && r.data.incomeCount === 1 && r.data.expenseCount === 2 && r.data.balance === 41800000, r.data);
r = await req('GET', '/stats/summary?month=2026-09', { token: tA });
check('summary Sep', r.data.income === 22000000 && r.data.expense === 3500000 && r.data.expenseCount === 3, r.data);
r = await req('GET', `/stats/summary?month=2026-09&walletId=${wBank}`, { token: tA });
check('summary Sep wallet=bank', r.data.income === 0 && r.data.expense === 400000 && r.data.expenseCount === 1 && r.data.balance === 4600000, r.data);
r = await req('GET', `/stats/summary?walletId=${wCashB}`, { token: tA });
check('summary foreign wallet 404', r.status === 404, r);
r = await req('GET', '/stats/summary', { token: tA });
check('summary all-time', r.data.income === 42000000 && r.data.expense === 5200000, r.data);
r = await req('GET', '/stats/summary?month=bad', { token: tA });
check('summary bad month 400', r.status === 400, r);
r = await req('GET', '/stats/by-category?month=2026-09', { token: tA });
check('by-category Sep expense', r.status === 200 && r.data.length === 3 && r.data[0].category.name === 'Ăn uống' && r.data[0].amount === 3000000 && r.data[0].percentage === 85.7 && r.data[1].amount === 400000 && r.data[1].percentage === 11.4 && r.data[2].percentage === 2.9, r.data);
r = await req('GET', `/stats/by-category?month=2026-09&walletId=${wCash}`, { token: tA });
check('by-category Sep wallet=cash', r.data.length === 2 && r.data[0].amount === 3000000 && r.data[0].percentage === 96.8 && r.data[1].amount === 100000, r.data);
r = await req('GET', '/stats/by-category?month=2026-08&type=INCOME', { token: tA });
check('by-category Aug income', r.data.length === 1 && r.data[0].amount === 20000000 && r.data[0].percentage === 100, r.data);
r = await req('GET', '/stats/daily?month=2026-08', { token: tA });
check('daily Aug (23:59 VN on 08-31)', JSON.stringify(r.data) === JSON.stringify([
  { date: '2026-08-05', income: 20000000, expense: 0 },
  { date: '2026-08-10', income: 0, expense: 1200000 },
  { date: '2026-08-31', income: 0, expense: 500000 },
]), r.data);
r = await req('GET', '/stats/daily?month=2026-09', { token: tA });
check('daily Sep (00:30 VN on 09-01, 23:30 VN on 09-30)', JSON.stringify(r.data) === JSON.stringify([
  { date: '2026-09-01', income: 0, expense: 3000000 },
  { date: '2026-09-05', income: 22000000, expense: 0 },
  { date: '2026-09-15', income: 0, expense: 400000 },
  { date: '2026-09-30', income: 0, expense: 100000 },
]), r.data);
r = await req('GET', `/stats/daily?month=2026-09&walletId=${wBank}`, { token: tA });
check('daily Sep wallet=bank', JSON.stringify(r.data) === JSON.stringify([{ date: '2026-09-15', income: 0, expense: 400000 }]), r.data);
r = await req('GET', '/stats/trend?month=2026-09&months=3', { token: tA });
check('trend', JSON.stringify(r.data) === JSON.stringify([
  { month: '2026-07', income: 0, expense: 0, net: 0 },
  { month: '2026-08', income: 20000000, expense: 1700000, net: 18300000 },
  { month: '2026-09', income: 22000000, expense: 3500000, net: 18500000 },
]), r.data);
r = await req('GET', `/stats/trend?month=2026-09&months=2&walletId=${wBank}`, { token: tA });
check('trend wallet=bank', JSON.stringify(r.data) === JSON.stringify([
  { month: '2026-08', income: 0, expense: 0, net: 0 },
  { month: '2026-09', income: 0, expense: 400000, net: -400000 },
]), r.data);
r = await req('GET', '/stats/trend?months=0', { token: tA });
check('trend months=0 400', r.status === 400, r);
r = await req('GET', '/stats/trend', { token: tA });
check('trend default 6 months', r.status === 200 && r.data.length === 6, r);
r = await req('GET', '/stats/report?month=2026-09&observationMonths=3', { token: tA });
{
  const d = r.data;
  check('report totals', d.income === 22000000 && d.expense === 3500000 && d.net === 18500000 && d.savingRate === 84.1, d);
  check('report comparison', d.comparison.previousMonth === '2026-08' && d.comparison.income.difference === 2000000 && d.comparison.income.percentageChange === 10 && d.comparison.income.trend === 'increase'
    && d.comparison.expense.difference === 1800000 && d.comparison.expense.percentageChange === 105.9 && d.comparison.expense.trend === 'increase', d.comparison);
  check('report breakdown', d.expenseByCategory.length === 3 && d.incomeByCategory.length === 1 && d.incomeByCategory[0].amount === 22000000, d);
  check('report largest/smallest', d.largestExpense.transaction.amount === 3000000 && d.largestExpense.percentage === 85.7 && d.smallestExpense.transaction.amount === 100000 && d.smallestExpense.percentage === 2.9
    && d.largestIncome.transaction.amount === 22000000 && d.smallestIncome.transaction.amount === 22000000, { l: d.largestExpense, s: d.smallestExpense });
  // chi: [0, 1.7M, 3.5M] trọng số 1,2,3 => (0 + 3.4M + 10.5M)/6 = 2,316,667; TB = 1,733,333
  check('report forecast weighted', d.forecast.month === '2026-10' && d.forecast.expense.predicted === 2316667 && d.forecast.expense.average === 1733333 && d.forecast.expense.method === 'weighted_average'
    && d.forecast.income.predicted === Math.round((0 + 40000000 + 66000000) / 6), d.forecast);
  check('report history', d.history.length === 3, d.history);
}
r = await req('GET', `/stats/report?month=2026-09&observationMonths=3&walletId=${wCash}`, { token: tA });
check('report wallet=cash', r.data.expense === 3100000 && r.data.income === 22000000 && r.data.walletId === wCash && r.data.smallestExpense.transaction.amount === 100000 && r.data.expenseByCategory.length === 2, r.data);
r = await req('GET', `/stats/report?walletId=${wCashB}`, { token: tA });
check('report foreign wallet 404', r.status === 404, r);
r = await req('GET', '/stats/report?month=2026-09&observationMonths=1', { token: tA });
check('report obs=1 simple avg', r.status === 200 && r.data.forecast.expense.method === 'simple_average' && r.data.forecast.expense.predicted === 3500000 && r.data.comparison.previousMonth === '2026-08', r.data?.forecast);
r = await req('GET', '/stats/report?month=2026-07', { token: tA });
check('report empty month', r.status === 200 && r.data.largestExpense === null && r.data.savingRate === 0, r.data);
r = await req('GET', '/stats/balance', { token: tB });
check('B balance 0 + 1 wallet', r.data.balance === 0 && r.data.wallets.length === 1, r.data);
r = await req('POST', '/transactions/bulk', { token: tB, body: { items: [
  { categoryId: C('Lương'), walletId: wCashB, amount: 1000000, title: 'b1', occurredAt: '2026-08-10T00:00:00Z' },
  { categoryId: C('Lương'), walletId: wCashB, amount: 1040000, title: 'b2', occurredAt: '2026-09-10T00:00:00Z' },
  { categoryId: C('Hóa đơn'), walletId: wCashB, amount: 1000000, title: 'b3', occurredAt: '2026-08-10T00:00:00Z' },
  { categoryId: C('Hóa đơn'), walletId: wCashB, amount: 940000, title: 'b4', occurredAt: '2026-09-10T00:00:00Z' },
] } });
r = await req('GET', '/stats/report?month=2026-09', { token: tB });
check('report ±5% => stable / -6% => decrease', r.data.comparison.income.percentageChange === 4 && r.data.comparison.income.trend === 'stable' && r.data.comparison.expense.percentageChange === -6 && r.data.comparison.expense.trend === 'decrease', r.data.comparison);
r = await req('GET', '/transactions', { token: tA });
check('A list unaffected by B data', r.data.total === txCountA, r.data.total);

// ================= BUDGETS =================
group('budgets: danh mục / tổng / copy');
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Ăn uống'), month: '2026-09', limitAmount: 3500000 } });
check('budget create warning (3.0M/3.5M = 85.7%)', r.status === 201 && r.data.spent === 3000000 && r.data.remaining === 500000 && r.data.percentage === 85.7 && r.data.status === 'warning', r.data);
const bFood = r.data;
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Di chuyển'), month: '2026-09', limitAmount: 400000 } });
check('budget exceeded at 100%', r.data.status === 'exceeded' && r.data.percentage === 100 && r.data.remaining === 0, r.data);
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Mua sắm'), month: '2026-09', limitAmount: 1000000 } });
check('budget ok 0 spent', r.data.status === 'ok' && r.data.spent === 0, r.data);
const bShop = r.data;
r = await req('POST', '/budgets', { token: tA, body: { month: '2026-09', limitAmount: 4000000 } });
check('overall budget (3.5M/4M = 87.5%)', r.status === 201 && r.data.categoryId === null && r.data.spent === 3500000 && r.data.percentage === 87.5 && r.data.status === 'warning', r.data);
const bOverallSep = r.data;
r = await req('POST', '/budgets', { token: tA, body: { month: '2026-09', limitAmount: 1 } });
check('second overall budget same month 409', r.status === 409, r);
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Ăn uống'), month: '2026-09', limitAmount: 1 } });
check('budget dup 409', r.status === 409, r);
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Lương'), month: '2026-09', limitAmount: 1000 } });
check('budget INCOME cat 400', r.status === 400, r);
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Mua sắm'), month: '2026/09', limitAmount: 1000 } });
check('budget bad month 400', r.status === 400, r);
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Mua sắm'), month: '2026-10', limitAmount: -1 } });
check('budget negative 400', r.status === 400, r);
r = await req('GET', '/budgets?month=2026-09', { token: tA });
check('budget list: overall separate + 3 items', r.status === 200 && r.data.overall?.id === bOverallSep.id && r.data.overall.spent === 3500000 && r.data.items.length === 3 && r.data.items.every((b) => b.categoryId)
  && r.data.totalLimit === 4900000 && r.data.totalSpent === 3400000 && r.data.totalRemaining === 1500000, r.data);
r = await req('PATCH', `/budgets/${bFood.id}`, { token: tA, body: { limitAmount: 2000000 } });
check('budget patch -> exceeded 150%', r.data.status === 'exceeded' && r.data.percentage === 150 && r.data.remaining === -1000000, r.data);
r = await req('PATCH', `/budgets/${bFood.id}`, { token: tB, body: { limitAmount: 1 } });
check('B patch A budget 404', r.status === 404, r);
r = await req('DELETE', `/budgets/${bFood.id}`, { token: tB });
check('B delete A budget 404', r.status === 404, r);
r = await req('GET', '/budgets?month=2026-09', { token: tB });
check('B budget list empty', r.data.items.length === 0 && r.data.overall === null, r.data);
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Mua sắm'), month: '2026-10', limitAmount: 777 } });
check('pre-existing target budget', r.status === 201, r);
r = await req('POST', '/budgets/copy', { token: tA, body: { fromMonth: '2026-09', toMonth: '2026-10' } });
check('budget copy 2 cat + overall (skip existing)', r.status === 201 && r.data.copied === 3, r.data);
r = await req('POST', '/budgets/copy', { token: tA, body: { fromMonth: '2026-09', toMonth: '2026-10' } });
check('budget copy again copies 0 (no dup overall)', r.data.copied === 0, r.data);
r = await req('GET', '/budgets?month=2026-10', { token: tA });
check('budget copy result', r.data.items.length === 3 && r.data.overall?.limitAmount === 4000000 && r.data.items.find((b) => b.category.id === C('Mua sắm')).limitAmount === 777 && r.data.items.find((b) => b.category.id === C('Ăn uống')).limitAmount === 2000000, r.data);
r = await req('POST', '/budgets/copy', { token: tA, body: { fromMonth: '2026-09', toMonth: '2026-09' } });
check('budget copy same month 400', r.status === 400, r);
r = await req('POST', '/budgets/copy', { token: tA, body: { fromMonth: '2026-9', toMonth: '2026-10' } });
check('budget copy bad month 400', r.status === 400, r);
r = await req('GET', '/budgets?month=2026-00', { token: tA });
check('budget list bad month 400', r.status === 400, r);
r = await req('DELETE', `/budgets/${bShop.id}`, { token: tA });
check('budget delete 204', r.status === 204, r);

group('notifications: cảnh báo ngân sách 80% / 100%');
r = await req('GET', '/notifications', { token: tA });
check('no notifications yet (budget creation does not notify)', r.data.total === 0, r.data);
r = await req('POST', '/budgets', { token: tA, body: { month: '2026-11', limitAmount: 1000000 } });
const bOverallNov = r.data;
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Ăn uống'), month: '2026-11', limitAmount: 500000 } });
const bFoodNov = r.data;
const nov = (d) => `2026-11-${String(d).padStart(2, '0')}T05:00:00Z`;
const addTx = async (cat, amount, d, title = 't') => {
  const x = await req('POST', '/transactions', { token: tA, body: { categoryId: C(cat), walletId: wCash, amount, title, occurredAt: nov(d) } });
  exp.cash -= amount; txCountA++;
  return x;
};
await addTx('Ăn uống', 300000, 1);
r = await req('GET', '/notifications/unread-count', { token: tA });
check('60% food / 30% overall => no notification', r.data.count === 0, r.data);
await addTx('Ăn uống', 150000, 2);
r = await req('GET', '/notifications', { token: tA });
check('food 90% => 1 BUDGET_WARNING', r.data.total === 1 && r.data.items[0].type === 'BUDGET_WARNING' && r.data.items[0].data.budgetId === bFoodNov.id && r.data.items[0].data.percentage === 90 && r.data.items[0].title.includes('Ăn uống'), r.data);
await addTx('Ăn uống', 100000, 3);
r = await req('GET', '/notifications', { token: tA });
check('food 110% => BUDGET_EXCEEDED (total 2)', r.data.total === 2 && r.data.items[0].type === 'BUDGET_EXCEEDED' && r.data.items[0].data.spent === 550000, r.data);
await addTx('Ăn uống', 10000, 4);
r = await req('GET', '/notifications/unread-count', { token: tA });
check('crossing again does not re-notify', r.data.count === 2, r.data);
const tx5 = (await addTx('Di chuyển', 300000, 5)).data;
r = await req('GET', '/notifications', { token: tA });
check('overall 86% => overall BUDGET_WARNING', r.data.total === 3 && r.data.items[0].type === 'BUDGET_WARNING' && r.data.items[0].data.budgetId === bOverallNov.id && r.data.items[0].data.categoryId === null, r.data);
r = await req('PATCH', `/transactions/${tx5.id}`, { token: tA, body: { amount: 500000 } });
exp.cash -= 200000;
r = await req('GET', '/notifications', { token: tA });
check('editing tx => overall 106% BUDGET_EXCEEDED', r.data.total === 4 && r.data.items[0].type === 'BUDGET_EXCEEDED' && r.data.items[0].data.budgetId === bOverallNov.id && r.data.items[0].data.spent === 1060000, r.data);
const notifs = r.data.items;
r = await req('GET', '/budgets?month=2026-11', { token: tA });
check('budget flags stored', r.data.overall.exceededAt && r.data.overall.warnedAt && r.data.overall.spent === 1060000 && r.data.items[0].spent === 560000 && r.data.items[0].percentage === 112, r.data);
r = await req('PATCH', `/budgets/${bFoodNov.id}`, { token: tA, body: { limitAmount: 2000000 } });
check('raising limit below 80% clears flags', r.data.warnedAt === null && r.data.exceededAt === null && r.data.percentage === 28, r.data);
r = await req('PATCH', `/budgets/${bFoodNov.id}`, { token: tA, body: { limitAmount: 600000 } });
check('limit 600k => 93.3% keeps exceededAt cleared', r.data.exceededAt === null && r.data.status === 'warning', r.data);
await addTx('Ăn uống', 50000, 6);
r = await req('GET', '/notifications', { token: tA });
check('after reset: food 101.7% => exceeded notification again (1 only)', r.data.total === 5 && r.data.items[0].type === 'BUDGET_EXCEEDED' && r.data.items[0].data.budgetId === bFoodNov.id, r.data);

group('notifications: đọc / đếm / cách ly');
r = await req('GET', '/notifications?page=1&limit=2', { token: tA });
check('notifications paged', r.data.items.length === 2 && r.data.total === 5, r.data);
r = await req('POST', `/notifications/${notifs[0].id}/read`, { token: tB });
check('B read A notification 404', r.status === 404, r);
r = await req('GET', '/notifications', { token: tB });
check('B sees no A notifications', r.data.total === 0, r.data);
r = await req('POST', `/notifications/${notifs[0].id}/read`, { token: tA });
check('mark read', r.status === 200 && r.data.readAt, r.data);
r = await req('GET', '/notifications/unread-count', { token: tA });
check('unread-count 4', r.data.count === 4, r.data);
r = await req('GET', '/notifications?unread=true', { token: tA });
check('filter unread', r.data.total === 4 && r.data.items.every((x) => x.readAt === null), r.data);
r = await req('POST', '/notifications/read-all', { token: tA });
check('read-all updated 4', r.data.updated === 4, r.data);
r = await req('GET', '/notifications/unread-count', { token: tA });
check('unread-count 0', r.data.count === 0, r.data);
r = await req('POST', `/notifications/not-uuid/read`, { token: tA });
check('read bad id 400', r.status === 400, r);

// ================= TRANSFERS =================
group('transfers: CRUD / đủ số dư / không vào thu chi');
// base: cash 37.2M - 1.11M (chi T11) = 36.09M ; bank 4.6M
check('expected base', exp.cash === 36090000 && exp.bank === 4600000, exp);
const balOf = async (t = tA) => Object.fromEntries((await req('GET', '/wallets', { token: t })).data.items.map((w) => [w.id, w.balance]));
r = await req('POST', '/transfers', { token: tA, body: { fromWalletId: wCash, toWalletId: wBank, amount: 1000000, occurredAt: '2026-09-20T03:00:00Z', note: 'nạp thẻ' } });
check('create transfer', r.status === 201 && r.data.amount === 1000000 && r.data.fromWallet.id === wCash && r.data.toWallet.id === wBank, r.data);
const tr1 = r.data;
let bal = await balOf();
check('balances after transfer', bal[wCash] === exp.cash - 1000000 && bal[wBank] === exp.bank + 1000000, bal);
r = await req('GET', '/stats/summary?month=2026-09', { token: tA });
check('transfer not counted in income/expense', r.data.income === 22000000 && r.data.expense === 3500000 && r.data.balance === exp.cash + exp.bank, r.data);
r = await req('GET', '/budgets?month=2026-09', { token: tA });
check('transfer not counted in budgets', r.data.overall.spent === 3500000, r.data.overall);
r = await req('POST', '/transfers', { token: tA, body: { fromWalletId: wBank, toWalletId: wCash, amount: 5600001 } });
check('transfer > source balance 400', r.status === 400, r);
r = await req('POST', '/transfers', { token: tA, body: { fromWalletId: wCash, toWalletId: wCash, amount: 1 } });
check('same wallet 400', r.status === 400, r);
r = await req('POST', '/transfers', { token: tA, body: { fromWalletId: wCash, toWalletId: wCashB, amount: 1 } });
check('to foreign wallet 400', r.status === 400, r);
r = await req('POST', '/transfers', { token: tB, body: { fromWalletId: wCash, toWalletId: wCashB, amount: 1 } });
check('B from A wallet 400', r.status === 400, r);
r = await req('POST', '/transfers', { token: tA, body: { fromWalletId: wCash, toWalletId: wBank, amount: 0 } });
check('amount 0 400', r.status === 400, r);
r = await req('GET', `/transfers/${tr1.id}`, { token: tB });
check('B get A transfer 404', r.status === 404, r);
r = await req('PATCH', `/transfers/${tr1.id}`, { token: tB, body: { amount: 1 } });
check('B patch A transfer 404', r.status === 404, r);
r = await req('DELETE', `/transfers/${tr1.id}`, { token: tB });
check('B delete A transfer 404', r.status === 404, r);
r = await req('PATCH', `/transfers/${tr1.id}`, { token: tA, body: { amount: 2000000 } });
check('update transfer amount', r.status === 200 && r.data.amount === 2000000, r.data);
bal = await balOf();
check('balances after update', bal[wCash] === exp.cash - 2000000 && bal[wBank] === exp.bank + 2000000, bal);
// đảo chiều: bank (6.6M, trong đó 2M từ chính giao dịch này) -> cash; khả dụng thật = 4.6M
r = await req('PATCH', `/transfers/${tr1.id}`, { token: tA, body: { fromWalletId: wBank, toWalletId: wCash, amount: 4600001 } });
check('swap direction exceeding real availability 400', r.status === 400, r);
r = await req('PATCH', `/transfers/${tr1.id}`, { token: tA, body: { fromWalletId: wBank, toWalletId: wCash, amount: 4600000 } });
check('swap direction exact availability ok', r.status === 200 && r.data.fromWallet.id === wBank, r.data);
bal = await balOf();
check('balances after swap', bal[wBank] === 0 && bal[wCash] === exp.cash + 4600000, bal);
r = await req('PATCH', `/transfers/${tr1.id}`, { token: tA, body: { toWalletId: wBank } });
check('update to same from/to 400', r.status === 400, r);
r = await req('POST', '/transfers', { token: tA, body: { fromWalletId: wCash, toWalletId: wBank, amount: 300000, occurredAt: '2026-10-02T03:00:00Z' } });
const tr2 = r.data;
r = await req('GET', '/transfers', { token: tA });
check('list transfers', r.data.total === 2 && r.data.items[0].id === tr2.id, r.data);
r = await req('GET', '/transfers?month=2026-09', { token: tA });
check('list transfers month filter', r.data.total === 1 && r.data.items[0].id === tr1.id, r.data);
r = await req('GET', `/transfers?walletId=${wBank}&month=2026-10`, { token: tA });
check('list transfers wallet filter', r.data.total === 1 && r.data.items[0].id === tr2.id, r.data);
r = await req('GET', '/transfers?month=13', { token: tA });
check('list transfers bad month 400', r.status === 400, r);
r = await req('GET', '/transfers', { token: tB });
check('B transfers empty', r.data.total === 0, r.data);
r = await req('DELETE', `/transfers/${tr1.id}`, { token: tA });
check('delete transfer 204', r.status === 204, r);
r = await req('DELETE', `/transfers/${tr2.id}`, { token: tA });
bal = await balOf();
check('balances back to base', bal[wCash] === exp.cash && bal[wBank] === exp.bank, bal);

group('wallets: lưu trữ khi có phát sinh');
r = await req('POST', '/wallets', { token: tA, body: { name: 'Ví tạm', type: 'EWALLET' } });
const wTmp = r.data.id;
r = await req('POST', '/quick-templates', { token: tA, body: { label: 'Tạm', title: 'Dùng ví tạm', amount: 1000, categoryId: C('Chi khác'), walletId: wTmp } });
const tplTmp = r.data;
r = await req('POST', '/transfers', { token: tA, body: { fromWalletId: wCash, toWalletId: wTmp, amount: 100000 } });
r = await req('DELETE', `/wallets/${wTmp}`, { token: tA });
check('archive wallet with balance != 0 => 409', r.status === 409, r);
r = await req('POST', '/transfers', { token: tA, body: { fromWalletId: wTmp, toWalletId: wCash, amount: 100000 } });
const trBack = r.data;
r = await req('DELETE', `/wallets/${wTmp}`, { token: tA });
check('activity + balance 0 => archived', r.status === 200 && r.data.archived === true, r.data);
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Lương'), walletId: wTmp, amount: 5, title: 'x' } });
check('tx in archived wallet 409', r.status === 409, r);
r = await req('POST', '/transfers', { token: tA, body: { fromWalletId: wCash, toWalletId: wTmp, amount: 5 } });
check('transfer to archived wallet 409', r.status === 409, r);
r = await req('DELETE', `/transfers/${trBack.id}`, { token: tA });
check('delete transfer of archived wallet 409', r.status === 409, r);
r = await req('POST', '/transactions/bulk', { token: tA, body: { items: [{ categoryId: C('Lương'), walletId: wTmp, amount: 1, title: 'x' }] } });
check('bulk with archived wallet 409', r.status === 409, r);
r = await req('POST', `/quick-templates/${tplTmp.id}/use`, { token: tA, body: {} });
check('template with archived wallet => use 409', r.status === 409 && /Ví "Ví tạm"/.test(r.data.message), r.data);
r = await req('GET', '/wallets', { token: tA });
check('archived wallet listed last with flag, total unchanged', r.data.items.at(-1).id === wTmp && r.data.items.at(-1).isArchived && r.data.totalBalance === exp.cash + exp.bank, r.data);
r = await req('POST', `/wallets/${wTmp}/restore`, { token: tA });
check('restore wallet', r.status === 200 && r.data.isArchived === false, r.data);
r = await req('DELETE', `/wallets/${wTmp}`, { token: tA });
check('archive again', r.data.archived === true, r.data);

// ================= SAVING GOALS =================
group('saving-goals: nạp theo ví / rút / trạng thái');
// cash 36.09M, bank 4.6M
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
check('deposit without walletId 400', r.status === 400, r);
r = await req('POST', `/saving-goals/${g1.id}/deposit`, { token: tA, body: { amount: 10000000, walletId: wCash } });
check('deposit 10M from cash', r.status === 200 && r.data.deposited === 10000000 && r.data.capped === false && r.data.goal.savedAmount === 10000000 && r.data.goal.status === 'ACTIVE', r.data);
exp.cash -= 10000000;
r = await req('GET', '/stats/balance', { token: tA });
check('balance after deposit', r.data.balance === exp.cash + exp.bank && r.data.savings === 10000000 && r.data.wallets.find((w) => w.id === wCash).balance === exp.cash, r.data);
r = await req('POST', `/saving-goals/${g1.id}/deposit`, { token: tA, body: { amount: 26900000, walletId: wCash } });
check('deposit capped at remaining 20M => COMPLETED', r.status === 200 && r.data.deposited === 20000000 && r.data.capped === true && r.data.goal.status === 'COMPLETED' && r.data.goal.progress === 100, r.data);
exp.cash -= 20000000;
r = await req('POST', `/saving-goals/${g1.id}/deposit`, { token: tA, body: { amount: 1, walletId: wCash } });
check('deposit to completed 409', r.status === 409, r);
r = await req('POST', '/saving-goals', { token: tA, body: { name: 'Xe', targetAmount: 100000000, targetDate: '2028-01-01T00:00:00Z', color: '#FF0000' } });
const g2 = r.data;
r = await req('POST', `/saving-goals/${g2.id}/deposit`, { token: tA, body: { amount: exp.bank + 1, walletId: wBank } });
check('deposit > wallet balance 400 (even though total enough)', r.status === 400 && exp.cash + exp.bank > exp.bank + 1, r);
r = await req('POST', `/saving-goals/${g2.id}/deposit`, { token: tA, body: { amount: 1, walletId: wTmp } });
check('deposit from archived wallet 409', r.status === 409, r);
r = await req('POST', `/saving-goals/${g2.id}/deposit`, { token: tA, body: { amount: 1, walletId: wCashB } });
check('deposit from foreign wallet 400', r.status === 400, r);
r = await req('POST', `/saving-goals/${g2.id}/deposit`, { token: tA, body: { amount: exp.bank, walletId: wBank, date: '2026-09-20T00:00:00Z' } });
check('deposit exact bank balance ok', r.status === 200 && r.data.deposited === 4600000, r.data);
exp.bank = 0;
bal = await balOf();
check('bank 0', bal[wBank] === 0 && bal[wCash] === exp.cash, bal);
r = await req('POST', `/saving-goals/${g2.id}/deposit`, { token: tB, body: { amount: 1, walletId: wCashB } });
check('B deposit A goal 404', r.status === 404, r);
r = await req('GET', `/saving-goals/${g2.id}`, { token: tB });
check('B get A goal 404', r.status === 404, r);
r = await req('POST', `/saving-goals/${g2.id}/withdraw`, { token: tB, body: { walletId: wCashB } });
check('B withdraw A goal 404', r.status === 404, r);
r = await req('DELETE', `/saving-goals/${g1.id}`, { token: tA });
check('delete goal with money 409', r.status === 409, r);
r = await req('GET', '/saving-goals', { token: tA });
check('goal list', r.status === 200 && r.data.length === 2, r.data);
r = await req('GET', '/saving-goals?status=COMPLETED', { token: tA });
check('goal list filter status', r.data.length === 1 && r.data[0].id === g1.id, r.data);
r = await req('GET', `/saving-goals/${g1.id}`, { token: tA });
check('goal detail entries with wallet', r.status === 200 && r.data.entries.length === 2 && r.data.entries.every((e) => e.type === 'DEPOSIT' && e.wallet.id === wCash), r.data);
r = await req('POST', `/saving-goals/${g1.id}/withdraw`, { token: tA, body: {} });
check('withdraw without walletId 400', r.status === 400, r);
r = await req('POST', `/saving-goals/${g1.id}/withdraw`, { token: tA, body: { walletId: wTmp } });
check('withdraw to archived wallet 409', r.status === 409, r);
r = await req('POST', `/saving-goals/${g1.id}/withdraw`, { token: tA, body: { walletId: wBank } });
check('withdraw completed -> WITHDRAWN into bank', r.status === 200 && r.data.withdrawn === 30000000 && r.data.goal.status === 'WITHDRAWN' && r.data.goal.savedAmount === 0, r.data);
exp.bank += 30000000;
bal = await balOf();
check('bank received 30M', bal[wBank] === exp.bank && bal[wCash] === exp.cash, bal);
r = await req('POST', `/saving-goals/${g1.id}/deposit`, { token: tA, body: { amount: 1, walletId: wCash } });
check('deposit to withdrawn 409', r.status === 409, r);
r = await req('POST', `/saving-goals/${g1.id}/withdraw`, { token: tA, body: { walletId: wCash } });
check('withdraw twice 409', r.status === 409, r);
r = await req('POST', `/saving-goals/${g2.id}/withdraw`, { token: tA, body: { walletId: wCash } });
check('early withdraw -> EARLY_WITHDRAWN into cash', r.status === 200 && r.data.goal.status === 'EARLY_WITHDRAWN' && r.data.withdrawn === 4600000, r.data);
exp.cash += 4600000;
r = await req('GET', '/stats/balance', { token: tA });
check('balance fully restored (= base 40.69M)', r.data.balance === 40690000 && r.data.balance === exp.cash + exp.bank && r.data.savings === 0, r.data);
r = await req('PATCH', `/saving-goals/${g2.id}`, { token: tA, body: { name: 'Xe máy', targetAmount: 50 } });
check('patch closed goal keeps status', r.status === 200 && r.data.name === 'Xe máy' && r.data.status === 'EARLY_WITHDRAWN', r.data);
r = await req('POST', '/saving-goals', { token: tA, body: { name: 'Empty', targetAmount: 1000, targetDate: '2027-01-01T00:00:00Z' } });
const g3 = r.data;
r = await req('POST', `/saving-goals/${g3.id}/withdraw`, { token: tA, body: { walletId: wCash } });
check('withdraw empty goal 400', r.status === 400, r);
await req('POST', `/saving-goals/${g3.id}/deposit`, { token: tA, body: { amount: 400, walletId: wCash } });
r = await req('PATCH', `/saving-goals/${g3.id}`, { token: tA, body: { targetAmount: 400 } });
check('patch target down to saved -> COMPLETED', r.data.status === 'COMPLETED', r.data);
r = await req('PATCH', `/saving-goals/${g3.id}`, { token: tA, body: { targetAmount: 1000 } });
check('patch target up -> ACTIVE', r.data.status === 'ACTIVE', r.data);
r = await req('PATCH', `/saving-goals/${g3.id}`, { token: tA, body: { targetDate: '2000-01-01T00:00:00Z' } });
check('patch targetDate before start 400', r.status === 400, r);
await req('POST', `/saving-goals/${g3.id}/withdraw`, { token: tA, body: { walletId: wCash } });
r = await req('DELETE', `/saving-goals/${g3.id}`, { token: tA });
check('delete emptied goal 204', r.status === 204, r);
r = await req('DELETE', `/saving-goals/${g1.id}`, { token: tA });
check('delete withdrawn goal 204', r.status === 204, r);
bal = await balOf();
check('deleting goal keeps per-wallet balances (deposit cash -> withdraw bank)', bal[wCash] === exp.cash && bal[wBank] === exp.bank, { bal, exp });
r = await req('POST', `/saving-goals/${g2.id}/deposit`, { token: tA, body: { amount: 0, walletId: wCash } });
check('deposit 0 400', r.status === 400, r);

group('saving-goals: nạp đồng thời không làm âm ví');
r = await req('POST', '/wallets', { token: tA, body: { name: 'Quỹ', type: 'BANK', initialBalance: 1000000 } });
const wFund = r.data.id;
r = await req('POST', '/saving-goals', { token: tA, body: { name: 'Du lịch', targetAmount: 50000000, targetDate: '2028-01-01T00:00:00Z' } });
const g4 = r.data;
let rs = await Promise.all([1, 2].map(() => req('POST', `/saving-goals/${g4.id}/deposit`, { token: tA, body: { amount: 700000, walletId: wFund } })));
check('2 parallel deposits of 700k from 1M => exactly 1 ok, 1 rejected 400', rs.filter((x) => x.status === 200).length === 1 && rs.filter((x) => x.status === 400).length === 1, rs.map((x) => x.status));
rs = await Promise.all([1, 2, 3, 4, 5].map(() => req('POST', `/saving-goals/${g4.id}/deposit`, { token: tA, body: { amount: 100000, walletId: wFund } })));
check('5 parallel deposits of 100k from 300k => 3 ok, 2 rejected', rs.filter((x) => x.status === 200).length === 3 && rs.filter((x) => x.status === 400).length === 2, rs.map((x) => x.status));
bal = await balOf();
r = await req('GET', `/saving-goals/${g4.id}`, { token: tA });
check('fund wallet = 0 (never negative), goal saved 1M', bal[wFund] === 0 && r.data.savedAmount === 1000000 && r.data.entries.length === 4, { fund: bal[wFund], saved: r.data.savedAmount });
await req('POST', `/saving-goals/${g4.id}/withdraw`, { token: tA, body: { walletId: wFund } });
bal = await balOf();
check('withdraw back to fund', bal[wFund] === 1000000, bal);
exp.fund = 1000000;

// ================= QUICK TEMPLATES =================
group('quick-templates: CRUD / use / lưu trữ');
r = await req('POST', '/budgets', { token: tA, body: { categoryId: C('Giải trí'), month: '2026-11', limitAmount: 100000 } });
const bFunNov = r.data;
r = await req('POST', '/quick-templates', { token: tA, body: { label: 'Xem phim', title: 'Vé CGV', amount: 90000, categoryId: C('Giải trí'), walletId: wCash, note: 'cuối tuần' } });
check('create template', r.status === 201 && r.data.amount === 90000 && r.data.category.name === 'Giải trí' && r.data.wallet.id === wCash, r.data);
const tpl = r.data;
r = await req('POST', '/quick-templates', { token: tA, body: { label: 'x', title: 'x', amount: 1, categoryId: C('Giải trí'), walletId: wCashB } });
check('template with foreign wallet 400', r.status === 400, r);
r = await req('POST', '/quick-templates', { token: tA, body: { label: 'x', title: 'x', amount: 1, categoryId: coffeeB.id, walletId: wCash } });
check('template with foreign category 400', r.status === 400, r);
r = await req('POST', '/quick-templates', { token: tA, body: { label: '', title: 'x', amount: 1, categoryId: C('Giải trí'), walletId: wCash } });
check('template blank label 400', r.status === 400, r);
r = await req('POST', '/quick-templates', { token: tA, body: { label: 'x', title: 'x', amount: 0, categoryId: C('Giải trí'), walletId: wCash } });
check('template amount 0 400', r.status === 400, r);
r = await req('GET', '/quick-templates', { token: tA });
check('list templates', r.data.length === 2 && r.data.some((t) => t.id === tpl.id), r.data);
r = await req('GET', '/quick-templates', { token: tB });
check('B list templates empty', r.data.length === 0, r.data);
r = await req('POST', `/quick-templates/${tpl.id}/use`, { token: tB, body: {} });
check('B use A template 404', r.status === 404, r);
r = await req('PATCH', `/quick-templates/${tpl.id}`, { token: tB, body: { amount: 1 } });
check('B patch A template 404', r.status === 404, r);
r = await req('POST', `/quick-templates/${tpl.id}/use`, { token: tA, body: { occurredAt: nov(10) } });
check('use template => real transaction', r.status === 201 && r.data.amount === 90000 && r.data.title === 'Vé CGV' && r.data.note === 'cuối tuần' && r.data.category.id === C('Giải trí') && r.data.wallet.id === wCash && vnDate(r.data.occurredAt) === '2026-11-10', r.data);
exp.cash -= 90000; txCountA++;
r = await req('GET', '/notifications', { token: tA });
check('template use goes through budget check (Giải trí 90% warning)', r.data.items[0].type === 'BUDGET_WARNING' && r.data.items[0].data.budgetId === bFunNov.id, r.data.items[0]);
r = await req('POST', `/quick-templates/${tpl.id}/use`, { token: tA, body: { amount: 15000, occurredAt: nov(11) } });
check('use with amount override', r.status === 201 && r.data.amount === 15000, r.data);
exp.cash -= 15000; txCountA++;
r = await req('GET', '/notifications', { token: tA });
check('Giải trí 105% => exceeded notification', r.data.items[0].type === 'BUDGET_EXCEEDED' && r.data.items[0].data.budgetId === bFunNov.id, r.data.items[0]);
r = await req('POST', `/quick-templates/${tpl.id}/use`, { token: tA, body: { amount: -1 } });
check('use with negative amount 400', r.status === 400, r);
r = await req('PATCH', `/quick-templates/${tpl.id}`, { token: tA, body: { amount: 95000, label: 'Phim' } });
check('update template', r.status === 200 && r.data.amount === 95000 && r.data.label === 'Phim', r.data);
r = await req('PATCH', `/quick-templates/${tpl.id}`, { token: tA, body: { walletId: wTmp } });
check('update template to archived wallet 409', r.status === 409, r);
r = await req('POST', '/categories', { token: tA, body: { name: 'Trà sữa', type: 'EXPENSE' } });
const catTea = r.data;
r = await req('POST', '/quick-templates', { token: tA, body: { label: 'Trà sữa', title: 'Trà sữa', amount: 50000, categoryId: catTea.id, walletId: wCash } });
const tplTea = r.data;
r = await req('POST', `/quick-templates/${tplTea.id}/use`, { token: tA, body: { occurredAt: '2026-10-05T05:00:00Z' } });
exp.cash -= 50000; txCountA++;
await req('DELETE', `/categories/${catTea.id}`, { token: tA });
r = await req('POST', `/quick-templates/${tplTea.id}/use`, { token: tA, body: {} });
check('template with archived category => use 409 with clear message', r.status === 409 && /Danh mục "Trà sữa"/.test(r.data.message), r.data);
r = await req('POST', '/categories', { token: tA, body: { name: 'Tạm xóa', type: 'EXPENSE' } });
const catDel = r.data;
r = await req('POST', '/quick-templates', { token: tA, body: { label: 'del', title: 'del', amount: 1, categoryId: catDel.id, walletId: wCash } });
const tplDel = r.data;
await req('DELETE', `/categories/${catDel.id}`, { token: tA });
r = await req('GET', '/quick-templates', { token: tA });
check('hard-deleting unused category removes its templates', !r.data.some((t) => t.id === tplDel.id), r.data.map((t) => t.label));
r = await req('DELETE', `/quick-templates/${tplTea.id}`, { token: tA });
check('delete template 204', r.status === 204, r);
r = await req('DELETE', `/quick-templates/${tplTea.id}`, { token: tA });
check('delete template again 404', r.status === 404, r);

// ================= RECURRING =================
group('recurring: cuối tháng 31 -> tháng 2 -> 31/3');
{
  const u = await newUser('rec');
  // Năm nhuận: 00:30 VN 31/1/2028 (= 17:30Z 30/1) => 29/2 => 31/3 => 30/4
  r = await req('POST', '/recurring', { token: u.token, body: { walletId: u.cash, categoryId: C('Nhà ở'), amount: 5000000, title: 'Tiền nhà', frequency: 'MONTHLY', startDate: '2028-01-30T17:30:00Z' } });
  check('create monthly rule (anchorDay 31 VN)', r.status === 201 && r.data.anchorDay === 31 && r.data.nextRunAt === '2028-01-30T17:30:00.000Z' && r.data.isActive, r.data);
  const leap = r.data;
  r = await req('GET', `/recurring/${leap.id}/preview?count=5`, { token: u.token });
  check('preview leap: 31/1, 29/2, 31/3, 30/4, 31/5 (VN)', JSON.stringify(r.data.items.map((x) => x.date)) === JSON.stringify(['2028-01-31', '2028-02-29', '2028-03-31', '2028-04-30', '2028-05-31'])
    && r.data.items[1].scheduledFor === '2028-02-28T17:30:00.000Z', r.data);
  r = await req('POST', '/recurring/run-due?now=2028-04-01T00:00:00Z', { token: u.token });
  check('run-due to 01/04/2028 => 3 created', r.status === 200 && r.data.created === 3, r.data);
  r = await req('GET', '/transactions', { token: u.token });
  check('generated tx dates (VN) 31/1, 29/2, 31/3 + recurring flag', JSON.stringify(r.data.items.map((t) => vnDate(t.occurredAt)).sort()) === JSON.stringify(['2028-01-31', '2028-02-29', '2028-03-31'])
    && r.data.items.every((t) => t.recurring === true && t.recurringRuleId === leap.id && t.scheduledFor === t.occurredAt), r.data.items);
  r = await req('GET', '/transactions?month=2028-02', { token: u.token });
  check('00:30 VN 29/2 lands in Feb (VN month)', r.data.total === 1, r.data);
  r = await req('GET', '/transactions?month=2028-01', { token: u.token });
  check('00:30 VN 31/1 (17:30Z 30/1) lands in Jan', r.data.total === 1 && r.data.items[0].occurredAt === '2028-01-30T17:30:00.000Z', r.data);
  r = await req('GET', `/recurring/${leap.id}`, { token: u.token });
  check('rule nextRunAt = 30/4 VN, lastRunAt set, count 3', r.data.nextRunAt === '2028-04-29T17:30:00.000Z' && r.data.lastRunAt && r.data._count.transactions === 3, r.data);
  // Sửa rule chỉ ảnh hưởng kỳ tương lai
  r = await req('PATCH', `/recurring/${leap.id}`, { token: u.token, body: { amount: 5500000, title: 'Tiền nhà mới' } });
  check('patch amount/title keeps nextRunAt', r.status === 200 && r.data.amount === 5500000 && r.data.nextRunAt === '2028-04-29T17:30:00.000Z', r.data);
  r = await req('POST', '/recurring/run-due?now=2028-05-01T00:00:00Z', { token: u.token });
  r = await req('GET', '/transactions', { token: u.token });
  check('old tx unchanged, new tx uses new amount', r.data.total === 4 && r.data.items.filter((t) => t.amount === 5000000).length === 3 && r.data.items.find((t) => vnDate(t.occurredAt) === '2028-04-30')?.amount === 5500000, r.data.items.map((t) => [vnDate(t.occurredAt), t.amount]));

  // Năm không nhuận: 23:30 VN 31/1/2027 => 28/2 => 31/3
  r = await req('POST', '/recurring', { token: u.token, body: { walletId: u.cash, categoryId: C('Lương'), amount: 1000, title: 'Non-leap', frequency: 'MONTHLY', startDate: '2027-01-31T16:30:00Z' } });
  const nonLeap = r.data;
  r = await req('GET', `/recurring/${nonLeap.id}/preview?count=3`, { token: u.token });
  check('preview non-leap: 31/1, 28/2, 31/3', JSON.stringify(r.data.items.map((x) => x.date)) === JSON.stringify(['2027-01-31', '2027-02-28', '2027-03-31']) && r.data.items[1].scheduledFor === '2027-02-28T16:30:00.000Z', r.data);
  r = await req('POST', '/recurring/run-due?now=2027-04-01T00:00:00Z', { token: u.token });
  check('run-due non-leap => 3 created', r.data.created === 3, r.data);
  r = await req('GET', '/transactions?type=INCOME', { token: u.token });
  check('non-leap dates 31/1, 28/2, 31/3', JSON.stringify(r.data.items.map((t) => vnDate(t.occurredAt)).sort()) === JSON.stringify(['2027-01-31', '2027-02-28', '2027-03-31']), r.data.items.map((t) => t.occurredAt));
  // Xóa rule giữ giao dịch
  r = await req('DELETE', `/recurring/${nonLeap.id}`, { token: u.token });
  check('delete rule 204', r.status === 204, r);
  r = await req('GET', '/transactions?type=INCOME', { token: u.token });
  check('generated tx kept, recurringRuleId null, still flagged recurring', r.data.total === 3 && r.data.items.every((t) => t.recurringRuleId === null && t.recurring === true), r.data.items);
  r = await req('GET', `/recurring/${nonLeap.id}`, { token: u.token });
  check('deleted rule 404', r.status === 404, r);
  // YEARLY 29/2 => năm không nhuận rơi 28/2
  r = await req('POST', '/recurring', { token: u.token, body: { walletId: u.cash, categoryId: C('Lương'), amount: 1, title: 'Y', frequency: 'YEARLY', startDate: '2028-02-29T02:00:00Z' } });
  r = await req('GET', `/recurring/${r.data.id}/preview?count=5`, { token: u.token });
  check('yearly 29/2 => 28/2 in non-leap, 29/2 in 2032', JSON.stringify(r.data.items.map((x) => x.date)) === JSON.stringify(['2028-02-29', '2029-02-28', '2030-02-28', '2031-02-28', '2032-02-29']), r.data);
  await req('DELETE', `/recurring/${r.data.ruleId}`, { token: u.token });
  // Cách ly
  r = await req('GET', `/recurring/${leap.id}`, { token: tB });
  check('B get other user rule 404', r.status === 404, r);
  r = await req('GET', `/recurring/${leap.id}/preview`, { token: tB });
  check('B preview other rule 404', r.status === 404, r);
  r = await req('POST', `/recurring/${leap.id}/pause`, { token: tB });
  check('B pause other rule 404', r.status === 404, r);
  r = await req('PATCH', `/recurring/${leap.id}`, { token: tB, body: { amount: 1 } });
  check('B patch other rule 404', r.status === 404, r);
  r = await req('DELETE', `/recurring/${leap.id}`, { token: tB });
  check('B delete other rule 404', r.status === 404, r);
  r = await req('POST', '/recurring/run-due?now=2030-01-01T00:00:00Z', { token: tB });
  check('B run-due does not touch other users rules', r.data.created === 0, r.data);
  r = await req('GET', `/recurring/${leap.id}`, { token: u.token });
  check('rule untouched by B', r.data._count.transactions === 4 && r.data.nextRunAt === '2028-05-30T17:30:00.000Z', r.data);
  r = await req('GET', '/recurring', { token: tB });
  check('B list rules empty', r.data.length === 0, r.data);
  r = await req('POST', '/recurring', { token: tB, body: { walletId: u.cash, categoryId: C('Lương'), amount: 1, title: 'x', frequency: 'DAILY', startDate: '2027-01-01T00:00:00Z' } });
  check('B create rule with other user wallet 400', r.status === 400, r);
}

group('recurring: bù kỳ lỡ / idempotent / chạy đồng thời');
{
  const u = await newUser('rec');
  const start = iso(Date.now() - 35 * DAY);
  r = await req('POST', '/recurring', { token: u.token, body: { walletId: u.cash, categoryId: C('Lương'), amount: 100, title: '2 tuần/lần', frequency: 'WEEKLY', interval: 2, startDate: start } });
  const rule = r.data;
  // Các kỳ: -35d, -21d, -7d đã đến hạn => bù 3
  rs = await Promise.all([1, 2].map(() => req('POST', '/recurring/run-due', { token: u.token })));
  check('2 concurrent run-due => total created 3 (no dup)', rs.every((x) => x.status === 200) && rs.reduce((s, x) => s + x.data.created, 0) <= 3, rs.map((x) => x.data));
  r = await req('POST', '/recurring/run-due', { token: u.token });
  check('3rd run creates 0', r.data.created === 0, r.data);
  r = await req('GET', '/transactions', { token: u.token });
  check('exactly 3 backfilled tx with distinct dates', r.data.total === 3 && new Set(r.data.items.map((t) => t.occurredAt)).size === 3
    && r.data.items.map((t) => t.occurredAt).sort().join() === [0, 14, 28].map((d) => new Date(new Date(start).getTime() + d * DAY).toISOString()).join(), r.data.items.map((t) => t.occurredAt));
  r = await req('GET', `/recurring/${rule.id}`, { token: u.token });
  check('nextRunAt = start + 42d', r.data.nextRunAt === new Date(new Date(start).getTime() + 42 * DAY).toISOString(), r.data);
  r = await req('POST', '/recurring', { token: u.token, body: { walletId: u.cash, categoryId: C('Lương'), amount: 1, title: 'x', frequency: 'WEEKLY', interval: 0, startDate: start } });
  check('interval 0 400', r.status === 400, r);
  r = await req('POST', '/recurring', { token: u.token, body: { walletId: u.cash, categoryId: C('Lương'), amount: 1, title: 'x', frequency: 'HOURLY', startDate: start } });
  check('bad frequency 400', r.status === 400, r);
  r = await req('POST', '/recurring', { token: u.token, body: { walletId: u.cash, categoryId: C('Lương'), amount: 1, title: 'x', frequency: 'DAILY', startDate: '2027-05-10T00:00:00Z', endDate: '2027-05-01' } });
  check('endDate before start 400', r.status === 400, r);
  r = await req('POST', '/recurring', { token: u.token, body: { walletId: u.cash, categoryId: C('Lương'), amount: 1, title: 'x', frequency: 'DAILY' } });
  check('missing startDate 400', r.status === 400, r);
  r = await req('GET', `/recurring/${rule.id}/preview?count=0`, { token: u.token });
  check('preview count 0 400', r.status === 400, r);
}

group('recurring: pause / resume không sinh bù');
{
  const u = await newUser('rec');
  const start = iso(Date.now() - 10 * DAY - 60000);
  r = await req('POST', '/recurring', { token: u.token, body: { walletId: u.cash, categoryId: C('Lương'), amount: 10, title: 'Hằng ngày', frequency: 'DAILY', startDate: start } });
  const rule = r.data;
  r = await req('POST', `/recurring/${rule.id}/pause`, { token: u.token });
  check('pause', r.status === 200 && r.data.isActive === false, r.data);
  r = await req('POST', '/recurring/run-due', { token: u.token });
  check('paused rule not run', r.data.created === 0, r.data);
  r = await req('GET', `/recurring/${rule.id}/preview?count=2`, { token: u.token });
  const expectNext = new Date(new Date(start).getTime() + 11 * DAY).toISOString();
  check('preview of paused rule starts after now', r.data.isActive === false && r.data.items[0].scheduledFor === expectNext, r.data);
  r = await req('POST', `/recurring/${rule.id}/resume`, { token: u.token });
  check('resume => nextRunAt jumps to first occurrence after now', r.status === 200 && r.data.isActive === true && r.data.nextRunAt === expectNext, r.data);
  r = await req('POST', '/recurring/run-due', { token: u.token });
  r = await req('GET', '/transactions', { token: u.token });
  check('resume does not backfill 11 missed occurrences', r.data.total === 0, r.data.total);
  r = await req('POST', `/recurring/run-due?now=${encodeURIComponent(new Date(Date.now() + 3 * DAY).toISOString())}`, { token: u.token });
  check('after resume, future occurrences run normally (3)', r.data.created === 3, r.data);
  r = await req('POST', `/recurring/${rule.id}/resume`, { token: u.token });
  check('resume active rule is no-op', r.status === 200 && r.data.isActive === true, r.data);
}

group('recurring: endDate / cảnh báo ngân sách');
{
  const u = await newUser('rec');
  await req('POST', '/budgets', { token: u.token, body: { month: '2027-05', limitAmount: 120 } });
  // 23:30 VN 30/4/2027, hết hạn 2/5 (VN) => 30/4, 1/5, 2/5
  r = await req('POST', '/recurring', { token: u.token, body: { walletId: u.cash, categoryId: C('Ăn uống'), amount: 100, title: 'Ăn đêm', frequency: 'DAILY', startDate: '2027-04-30T16:30:00Z', endDate: '2027-05-02' } });
  const rule = r.data;
  check('endDate normalized to end of VN day', r.data.endDate === '2027-05-02T16:59:59.999Z', r.data);
  r = await req('GET', `/recurring/${rule.id}/preview?count=10`, { token: u.token });
  check('preview stops at endDate (3 items)', JSON.stringify(r.data.items.map((x) => x.date)) === JSON.stringify(['2027-04-30', '2027-05-01', '2027-05-02']), r.data);
  r = await req('POST', '/recurring/run-due?now=2027-06-01T00:00:00Z', { token: u.token });
  check('run-due creates exactly 3', r.data.created === 3, r.data);
  r = await req('GET', `/recurring/${rule.id}`, { token: u.token });
  check('rule inactive after endDate', r.data.isActive === false && r.data._count.transactions === 3, r.data);
  r = await req('GET', '/transactions?month=2027-04', { token: u.token });
  check('23:30 VN 30/4 stays in April', r.data.total === 1, r.data);
  r = await req('GET', '/notifications', { token: u.token });
  check('recurring tx goes through budget check: 100/120 warning, 200/120 exceeded', r.data.total === 2 && r.data.items.map((x) => x.type).sort().join() === 'BUDGET_EXCEEDED,BUDGET_WARNING', r.data.items);
  r = await req('POST', `/recurring/${rule.id}/resume`, { token: u.token });
  check('resume expired rule 409', r.status === 409, r);
  r = await req('PATCH', `/recurring/${rule.id}`, { token: u.token, body: { endDate: null } });
  check('remove endDate via null', r.status === 200 && r.data.endDate === null, r.data);
}

group('recurring: ví lưu trữ => tự dừng + thông báo');
{
  const u = await newUser('rec');
  r = await req('POST', '/wallets', { token: u.token, body: { name: 'Ví phụ', type: 'EWALLET' } });
  const wSide = r.data.id;
  const start = iso(Date.now() + DAY);
  r = await req('POST', '/recurring', { token: u.token, body: { walletId: wSide, categoryId: C('Hóa đơn'), amount: 100, title: 'Internet', frequency: 'MONTHLY', startDate: start } });
  const rule = r.data;
  r = await req('DELETE', `/wallets/${wSide}`, { token: u.token });
  check('wallet used by rule => archived (not deleted)', r.data.archived === true, r.data);
  r = await req('POST', `/recurring/run-due?now=${encodeURIComponent(new Date(Date.now() + 2 * DAY).toISOString())}`, { token: u.token });
  check('due occurrence skipped (0 created)', r.data.created === 0, r.data);
  r = await req('GET', `/recurring/${rule.id}`, { token: u.token });
  check('rule auto-paused, nextRunAt moved past skipped', r.data.isActive === false && new Date(r.data.nextRunAt) > new Date(start), r.data);
  r = await req('GET', '/notifications', { token: u.token });
  check('RECURRING_PAUSED notification', r.data.total === 1 && r.data.items[0].type === 'RECURRING_PAUSED' && r.data.items[0].data.ruleId === rule.id && /Ví phụ/.test(r.data.items[0].body), r.data);
  r = await req('POST', `/recurring/${rule.id}/resume`, { token: u.token });
  check('resume with archived wallet 409', r.status === 409, r);
  r = await req('PATCH', `/recurring/${rule.id}`, { token: u.token, body: { walletId: wSide } });
  check('patch rule to archived wallet... same wallet allowed (no change)', r.status === 200, r);
  r = await req('PATCH', `/recurring/${rule.id}`, { token: u.token, body: { walletId: u.cash } });
  r = await req('POST', `/recurring/${rule.id}/resume`, { token: u.token });
  check('after switching wallet, resume ok', r.status === 200 && r.data.isActive, r.data);
  r = await req('GET', '/transactions', { token: u.token });
  check('no tx generated for skipped occurrence', r.data.total === 0, r.data);
}

// ================= EXPORT =================
group('export: CSV');
r = await req('POST', '/transactions', { token: tA, body: { categoryId: C('Ăn uống'), walletId: wCash, amount: 1234, title: 'Ăn "phở", bún\nbò', note: 'ghi chú, có phẩy', occurredAt: '2026-06-15T13:05:00Z' } });
exp.cash -= 1234; txCountA++;
r = await fetch(`${BASE}/export/transactions.csv?month=2026-06`, { headers: { authorization: `Bearer ${tA}` } });
let csv = await r.text();
const raw = new Uint8Array(await (await fetch(`${BASE}/export/transactions.csv?month=2026-06`, { headers: { authorization: `Bearer ${tA}` } })).arrayBuffer());
check('content-type csv + attachment', r.status === 200 && /text\/csv/.test(r.headers.get('content-type')) && /attachment; filename="transactions.csv"/.test(r.headers.get('content-disposition')), [...r.headers]);
check('UTF-8 BOM bytes EF BB BF', raw[0] === 0xef && raw[1] === 0xbb && raw[2] === 0xbf, [...raw.slice(0, 3)]);
// fetch().text() tự bỏ BOM (BOM đã kiểm ở byte thô phía trên)
const expectedCsv = 'Ngày,Loại,Danh mục,Ví,Tiêu đề,Ghi chú,Số tiền\r\n2026-06-15 20:05,Chi,Ăn uống,Tiền mặt,"Ăn ""phở"", bún\nbò","ghi chú, có phẩy",1234\r\n';
check('CSV content + escaping exact', csv === expectedCsv, csv);
r = await fetch(`${BASE}/export/transactions.csv?month=2026-09&walletId=${wBank}`, { headers: { authorization: `Bearer ${tA}` } });
csv = await r.text();
check('CSV Sep wallet=bank = header + Grab', csv === 'Ngày,Loại,Danh mục,Ví,Tiêu đề,Ghi chú,Số tiền\r\n2026-09-15 09:00,Chi,Di chuyển,Ngân hàng,Grab,đi làm,400000\r\n', csv);
r = await fetch(`${BASE}/export/transactions.csv?month=2026-09`, { headers: { authorization: `Bearer ${tA}` } });
csv = await r.text();
check('CSV Sep all = 4 rows sorted asc, midnight row first', csv.split('\r\n').length === 6 && csv.split('\r\n')[1].startsWith('2026-09-01 00:30,Chi,Ăn uống'), csv);
r = await fetch(`${BASE}/export/transactions.csv?from=2026-09-01T00:00:00%2B07:00&to=2026-09-06T00:00:00%2B07:00`, { headers: { authorization: `Bearer ${tA}` } });
csv = await r.text();
check('CSV from/to', csv.split('\r\n').length === 4, csv);
r = await fetch(`${BASE}/export/transactions.csv?walletId=${wCashB}`, { headers: { authorization: `Bearer ${tA}` } });
check('CSV foreign wallet 404', r.status === 404, r.status);
r = await fetch(`${BASE}/export/transactions.csv?month=2026-6`, { headers: { authorization: `Bearer ${tA}` } });
check('CSV bad month 400', r.status === 400, r.status);
r = await fetch(`${BASE}/export/transactions.csv`);
check('CSV no token 401', r.status === 401, r.status);
r = await fetch(`${BASE}/export/transactions.csv?month=2026-09`, { headers: { authorization: `Bearer ${tB}` } });
csv = await r.text();
check('CSV B only own data (Sep: b2, b4)', csv.split('\r\n').length === 4 && !csv.includes('Grab'), csv);

group('final balance check A');
r = await req('GET', '/stats/balance', { token: tA });
check('total = cash + bank + fund (tracked)', r.data.balance === exp.cash + exp.bank + exp.fund && r.data.wallets.find((w) => w.id === wCash).balance === exp.cash && r.data.wallets.find((w) => w.id === wBank).balance === exp.bank, { got: r.data, exp });

// ================= ADMIN =================
group('admin: phân quyền / user / khóa');
r = await req('GET', '/admin/overview', { token: tA });
check('non-admin overview 403', r.status === 403, r);
r = await req('GET', '/admin/users', { token: tB });
check('non-admin users 403', r.status === 403, r);
r = await req('POST', '/auth/login', { body: { email: ADMIN_EMAIL, password: ADMIN_PASSWORD } });
check('admin login', r.status === 200 && r.data.user.role === 'ADMIN', r);
const tAd = r.data.accessToken; const idAd = r.data.user.id;
r = await req('GET', '/admin/overview', { token: tAd });
check('admin overview', r.status === 200 && r.data.users.total >= 3 && r.data.transactions.total >= txCountA && Array.isArray(r.data.trend) && r.data.trend.length === 6, r.data);
r = await req('GET', '/admin/users', { token: tAd });
check('admin users list', r.status === 200 && r.data.total >= 3 && r.data.items.every((u) => !('passwordHash' in u)) && r.data.items[0]._count, r.data);
r = await req('GET', `/admin/users?q=${encodeURIComponent('a' + S)}`, { token: tAd });
check('admin users search', r.data.total === 1 && r.data.items[0].id === idA && r.data.items[0]._count.transactions === txCountA, r.data);
r = await req('GET', '/admin/users?role=ADMIN', { token: tAd });
check('admin users role filter', r.data.items.every((u) => u.role === 'ADMIN') && r.data.total >= 1, r.data);
r = await req('GET', `/admin/users/${idA}`, { token: tAd });
check('admin user detail with wallets + balances', r.status === 200 && r.data.finance.balance === exp.cash + exp.bank + exp.fund && !('passwordHash' in r.data) && r.data._count.transactions === txCountA && r.data.trend.length === 6
  && r.data.wallets.length === 4 && r.data.wallets.find((w) => w.id === wCash).balance === exp.cash && r.data.wallets.find((w) => w.id === wTmp).isArchived, r.data);
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

group('admin: broadcast');
r = await req('GET', '/admin/users?status=ACTIVE&limit=1', { token: tAd });
const activeCount = r.data.total;
r = await req('POST', '/admin/broadcasts', { token: tAd, body: { title: `Bảo trì ${S}`, body: 'Hệ thống bảo trì 22h' } });
check('broadcast to all ACTIVE users', r.status === 201 && r.data.recipients === activeCount, { got: r.data, activeCount });
const bc = r.data;
r = await req('POST', '/admin/broadcasts', { token: tA, body: { title: 'x', body: 'y' } });
check('non-admin broadcast 403', r.status === 403, r);
r = await req('POST', '/admin/broadcasts', { token: tAd, body: { title: ' ', body: 'y' } });
check('broadcast blank title 400', r.status === 400, r);
r = await req('GET', '/notifications', { token: tA });
check('A received broadcast', r.data.items[0].type === 'BROADCAST' && r.data.items[0].broadcastId === bc.id && r.data.items[0].title === `Bảo trì ${S}`, r.data.items[0]);
await req('POST', `/notifications/${r.data.items[0].id}/read`, { token: tA });
r = await req('GET', '/admin/broadcasts', { token: tAd });
check('broadcast history with recipients + readCount', r.status === 200 && r.data.items[0].id === bc.id && r.data.items[0].recipients === activeCount && r.data.items[0].readCount === 1, r.data.items[0]);
check('broadcast history includes sender', r.data.items[0].createdBy?.email === ADMIN_EMAIL && !!r.data.items[0].createdBy?.name, r.data.items[0].createdBy);
r = await req('GET', '/admin/broadcasts', { token: tA });
check('non-admin broadcast history 403', r.status === 403, r);
r = await req('GET', `/admin/users/${idA}`, { token: tAd });
check('admin user detail: recurringRules count + lastLoginAt', typeof r.data._count?.recurringRules === 'number' && !!r.data.lastLoginAt && !('passwordHash' in r.data), { c: r.data._count, l: r.data.lastLoginAt });
{
  const res = await fetch(BASE + '/auth/login', { method: 'OPTIONS', headers: { origin: 'http://localhost:5173', 'access-control-request-method': 'POST' } });
  const res2 = await fetch(BASE + '/health', { headers: { origin: 'http://localhost:5173' } });
  check('CORS exposes Retry-After + Content-Disposition', /retry-after/i.test(res2.headers.get('access-control-expose-headers') ?? '') && /content-disposition/i.test(res2.headers.get('access-control-expose-headers') ?? '') && res.status < 300, res2.headers.get('access-control-expose-headers'));
}
r = await req('PATCH', `/admin/users/${idB}`, { token: tAd, body: { status: 'ACTIVE' } });
r = await req('GET', '/me', { token: tB });
check('unlocked B: token issued before lock stays invalid 401', r.status === 401, r);
r = await req('POST', '/auth/login', { body: { email: emailB, password: 'secret2' } });
check('unlocked B can log in again', r.status === 200, r);
tB = r.data.accessToken;
r = await req('GET', '/me', { token: tB });
check('unlocked B new token works', r.status === 200, r);
r = await req('GET', '/notifications', { token: tB });
check('locked user did not receive broadcast', !r.data.items.some((x) => x.broadcastId === bc.id), r.data);

group('admin: giao dịch / danh mục hệ thống');
r = await req('GET', `/admin/transactions?userId=${idA}`, { token: tAd });
check('admin tx filter userId (+wallet)', r.status === 200 && r.data.total === txCountA && r.data.items.every((t) => t.user.id === idA && t.wallet?.name), r.data);
r = await req('GET', `/admin/transactions?userId=${idA}&month=2026-09&type=EXPENSE`, { token: tAd });
check('admin tx filter combo', r.data.total === 3, r.data);
r = await req('GET', `/admin/transactions?userId=${idA}&walletId=${wBank}`, { token: tAd });
check('admin tx filter walletId', r.data.total === 1, r.data);
r = await req('GET', `/admin/transactions?userId=bad`, { token: tAd });
check('admin tx bad userId 400', r.status === 400, r);
r = await req('GET', `/admin/transactions`, { token: tAd });
check('admin tx all paged default', r.status === 200 && r.data.page === 1 && r.data.limit === 20, r.data);
r = await req('GET', '/admin/categories', { token: tAd });
check('admin system categories', r.status === 200 && r.data.filter((c) => !c.isArchived).length === sysCount && r.data.every((c) => c.userId === null && c._count), r.data?.length);
r = await req('GET', '/admin/categories?type=EXPENSE', { token: tAd });
check('admin system categories filter', r.data.length > 0 && r.data.every((c) => c.type === 'EXPENSE'), r.data.length);
{
  const active = r.data.filter((c) => !c.isArchived).map((c) => c.name);
  const firstArchived = r.data.findIndex((c) => c.isArchived);
  check('admin categories sorted Vietnamese, archived last', JSON.stringify(active) === JSON.stringify(viSorted(active)) && active.indexOf('Ăn uống') < active.indexOf('Sức khỏe')
    && (firstArchived === -1 || r.data.slice(firstArchived).every((c) => c.isArchived)), r.data.map((c) => c.name));
}
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
r = await req('POST', '/transactions', { token: tB, body: { categoryId: charity.id, walletId: wCashB, amount: 50000, title: 'Quyên góp' } });
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
r = await req('POST', '/admin/categories', { token: tAd, body: { name: `Tạm ${S}`, type: 'INCOME' } });
r = await req('DELETE', `/admin/categories/${r.data.id}`, { token: tAd });
check('admin delete unused system cat -> hard', r.status === 200 && r.data.archived === false, r.data);
r = await req('POST', '/admin/categories', { token: tA, body: { name: 'Hack', type: 'INCOME' } });
check('non-admin create system cat 403', r.status === 403, r);
r = await req('DELETE', `/transactions/${txCharity.id}`, { token: tB });
r = await req('DELETE', `/admin/categories/${charity.id}`, { token: tAd });
check('cleanup: unused system cat hard-deleted', r.status === 200 && r.data.archived === false, r.data);

// ================= SESSION (tokenVersion) =================
group('auth: phiên đăng nhập / tokenVersion');
{
  const s = await newUser('sess');
  const t2 = (await req('POST', '/auth/login', { body: { email: s.email, password: 'secret1' } })).data.accessToken;
  r = await req('GET', '/me', { token: t2 });
  check('2 devices: both tokens valid', r.status === 200 && (await req('GET', '/me', { token: s.token })).status === 200, r);
  r = await req('POST', '/me/password', { token: s.token, body: { currentPassword: 'secret1', newPassword: 'secret2' } });
  check('change pw on device 1 => 200 + token', r.status === 200 && typeof r.data.accessToken === 'string', r);
  const t3 = r.data.accessToken;
  r = await req('GET', '/wallets', { token: t2 });
  check('device 2 token rejected 401 with message', r.status === 401 && /hết hiệu lực/.test(r.data.message), r);
  r = await req('GET', '/wallets', { token: s.token });
  check('device 1 old token rejected 401', r.status === 401, r);
  r = await req('GET', '/wallets', { token: t3 });
  check('device 1 keeps session with fresh token', r.status === 200, r);
  // Đăng xuất mọi thiết bị
  const t4 = (await req('POST', '/auth/login', { body: { email: s.email, password: 'secret2' } })).data.accessToken;
  r = await req('POST', '/auth/logout-all');
  check('logout-all without token 401', r.status === 401, r);
  r = await req('POST', '/auth/logout-all', { token: t3 });
  check('logout-all 204', r.status === 204 && r.text === '', r);
  r = await req('GET', '/me', { token: t3 });
  check('logout-all: calling token invalid', r.status === 401, r);
  r = await req('GET', '/me', { token: t4 });
  check('logout-all: other device invalid', r.status === 401, r);
  r = await req('POST', '/auth/logout-all', { token: t4 });
  check('logout-all again with dead token 401', r.status === 401, r);
  r = await req('POST', '/auth/login', { body: { email: s.email, password: 'secret2' } });
  check('login after logout-all works', r.status === 200 && (await req('GET', '/me', { token: r.data.accessToken })).status === 200, r);
  const t5 = r.data.accessToken;
  // Admin khóa => token cũ 403 (khóa) rồi sau mở khóa thành 401; đăng nhập lại được
  r = await req('PATCH', `/admin/users/${s.id}`, { token: tAd, body: { status: 'LOCKED' } });
  check('admin lock => 200, tokenVersion not exposed', r.status === 200 && !('tokenVersion' in r.data), r.data);
  r = await req('GET', '/me', { token: t5 });
  check('locked: old token 403 "bị khóa"', r.status === 403 && /bị khóa/.test(r.data.message), r);
  await req('PATCH', `/admin/users/${s.id}`, { token: tAd, body: { status: 'ACTIVE' } });
  r = await req('GET', '/me', { token: t5 });
  check('unlocked: token from before lock 401', r.status === 401, r);
  r = await req('POST', '/auth/login', { body: { email: s.email, password: 'secret2' } });
  const t6 = r.data.accessToken;
  r = await req('PATCH', `/admin/users/${s.id}`, { token: tAd, body: { role: 'ADMIN' } });
  r = await req('GET', '/admin/overview', { token: t6 });
  check('role change (not lock) keeps token valid, role read from DB', r.status === 200, r);
  await req('PATCH', `/admin/users/${s.id}`, { token: tAd, body: { role: 'USER' } });
  r = await req('GET', '/admin/overview', { token: t6 });
  check('demoted: same token loses admin 403', r.status === 403, r);
  r = await req('GET', '/admin/users?q=' + encodeURIComponent(s.email), { token: tAd });
  check('admin user list hides tokenVersion', r.data.items.length === 1 && !('tokenVersion' in r.data.items[0]), r.data);
}

// ================= ADMIN RECURRING RUN-DUE (đường cron) =================
group('admin: chạy định kỳ cho mọi user (đường cron) / user bị khóa');
{
  const L = await newUser('lock');
  const N = await newUser('norm');
  const start = iso(Date.now() + DAY);
  const ruleL = (await req('POST', '/recurring', { token: L.token, body: { walletId: L.cash, categoryId: C('Hóa đơn'), amount: 100, title: 'Điện', frequency: 'DAILY', startDate: start } })).data;
  const ruleN = (await req('POST', '/recurring', { token: N.token, body: { walletId: N.cash, categoryId: C('Hóa đơn'), amount: 100, title: 'Nước', frequency: 'DAILY', startDate: start } })).data;
  check('rules created', ruleL.id && ruleN.id, { ruleL, ruleN });
  const now = encodeURIComponent(new Date(Date.now() + DAY + 3600000).toISOString());
  r = await req('POST', `/admin/recurring/run-due?now=${now}`, { token: L.token });
  check('non-admin => 403', r.status === 403, r);
  r = await req('POST', '/admin/recurring/run-due?now=bad', { token: tAd });
  check('bad now 400', r.status === 400, r);
  await req('PATCH', `/admin/users/${L.id}`, { token: tAd, body: { status: 'LOCKED' } });
  r = await req('POST', `/admin/recurring/run-due?now=${now}`, { token: tAd });
  check('admin run-due (all users) 200', r.status === 200 && r.data.skipped === false && r.data.rules >= 2 && r.data.created >= 1, r.data);
  r = await req('POST', `/admin/recurring/run-due?now=${now}`, { token: tAd });
  check('second run same now: nothing due for these rules', r.status === 200, r.data);
  r = await req('GET', '/transactions', { token: N.token });
  check('normal user: exactly 1 tx generated (idempotent)', r.data.total === 1 && r.data.items[0].recurring === true && r.data.items[0].title === 'Nước', r.data);
  r = await req('GET', `/recurring/${ruleN.id}`, { token: N.token });
  check('normal user rule still active, nextRunAt advanced 1 day', r.data.isActive === true && new Date(r.data.nextRunAt).getTime() === new Date(start).getTime() + DAY, r.data);
  await req('PATCH', `/admin/users/${L.id}`, { token: tAd, body: { status: 'ACTIVE' } });
  const tL = (await req('POST', '/auth/login', { body: { email: L.email, password: 'secret1' } })).data.accessToken;
  r = await req('GET', '/transactions', { token: tL });
  check('locked user: no tx generated', r.data.total === 0, r.data);
  r = await req('GET', `/recurring/${ruleL.id}`, { token: tL });
  check('locked user rule auto-paused, skipped occurrence passed', r.data.isActive === false && r.data._count.transactions === 0 && new Date(r.data.nextRunAt) > new Date(start), r.data);
  r = await req('GET', '/notifications', { token: tL });
  check('locked user got RECURRING_PAUSED (reason: account locked)', r.data.total === 1 && r.data.items[0].type === 'RECURRING_PAUSED' && r.data.items[0].data.ruleId === ruleL.id && /bị khóa/.test(r.data.items[0].body), r.data);
  r = await req('POST', `/recurring/${ruleL.id}/resume`, { token: tL });
  check('after unlock user can resume (no back-fill)', r.status === 200 && r.data.isActive === true && new Date(r.data.nextRunAt) > new Date(), r.data);
  r = await req('POST', `/admin/recurring/run-due?now=${now}`, { token: tAd });
  r = await req('GET', '/transactions', { token: tL });
  check('resumed rule: skipped period not back-filled', r.data.total === 0, r.data);
}

// ================= NGHIỆP VỤ: các lỗ hổng đã vá =================
group('nghiệp vụ: chuyển tiền không làm âm ví khi sửa / xóa');
{
  const u = await newUser('ovd');
  const mk = async (name, initialBalance = 0) => (await req('POST', '/wallets', { token: u.token, body: { name, type: 'BANK', initialBalance } })).data.id;
  const w1 = await mk('W1', 1000), w2 = await mk('W2'), w3 = await mk('W3');
  const t1 = (await req('POST', '/transfers', { token: u.token, body: { fromWalletId: w1, toWalletId: w2, amount: 1000 } })).data;
  const t2 = (await req('POST', '/transfers', { token: u.token, body: { fromWalletId: w2, toWalletId: w3, amount: 1000 } })).data;
  const bal = async () => Object.fromEntries((await req('GET', '/wallets', { token: u.token })).data.items.map((w) => [w.name, w.balance]));
  check('chain W1->W2->W3', JSON.stringify(await bal()) === JSON.stringify({ 'Tiền mặt': 0, W1: 0, W2: 0, W3: 1000 }), await bal());
  r = await req('DELETE', `/transfers/${t1.id}`, { token: u.token });
  check('delete W1->W2 when W2 already forwarded => 400 (W2 không đủ)', r.status === 400 && /W2/.test(r.data.message), r);
  r = await req('PATCH', `/transfers/${t1.id}`, { token: u.token, body: { amount: 10 } });
  check('shrink W1->W2 amount => 400', r.status === 400 && /W2/.test(r.data.message), r);
  r = await req('PATCH', `/transfers/${t1.id}`, { token: u.token, body: { toWalletId: w3 } });
  check('redirect W1->W2 to W3 => 400 (W2 loses money)', r.status === 400 && /W2/.test(r.data.message), r);
  r = await req('PATCH', `/transfers/${t1.id}`, { token: u.token, body: { occurredAt: '2026-01-01T00:00:00Z', note: 'đổi ngày' } });
  check('change date/note only => ok (số dư không phụ thuộc ngày)', r.status === 200 && r.data.note === 'đổi ngày', r);
  r = await req('PATCH', `/transfers/${t2.id}`, { token: u.token, body: { amount: 1001 } });
  check('grow W2->W3 beyond W2 => 400 với số còn khả dụng', r.status === 400 && /còn 1000/.test(r.data.message), r);
  r = await req('PATCH', `/transfers/${t2.id}`, { token: u.token, body: { amount: 400 } });
  check('shrink W2->W3 (W3 still >= 0) ok', r.status === 200, r);
  r = await req('PATCH', `/transfers/${t1.id}`, { token: u.token, body: { amount: 400 } });
  check('now shrink W1->W2 to 400 ok (W2 = 0)', r.status === 200, r);
  check('balances', JSON.stringify(await bal()) === JSON.stringify({ 'Tiền mặt': 0, W1: 600, W2: 0, W3: 400 }), await bal());
  r = await req('DELETE', `/transfers/${t2.id}`, { token: u.token });
  check('delete W2->W3 ok', r.status === 204, r);
  r = await req('DELETE', `/transfers/${t1.id}`, { token: u.token });
  check('then delete W1->W2 ok', r.status === 204, r);
  check('balances restored', JSON.stringify(await bal()) === JSON.stringify({ 'Tiền mặt': 0, W1: 1000, W2: 0, W3: 0 }), await bal());
  // Ví lưu trữ phải giữ số dư 0
  await req('POST', '/transactions', { token: u.token, body: { categoryId: C('Lương'), walletId: w3, amount: 5, title: 'x' } });
  await req('POST', '/transactions', { token: u.token, body: { categoryId: C('Chi khác'), walletId: w3, amount: 5, title: 'x' } });
  r = await req('DELETE', `/wallets/${w3}`, { token: u.token });
  check('W3 archived (activity, balance 0)', r.data.archived === true, r.data);
  r = await req('PATCH', `/wallets/${w3}`, { token: u.token, body: { initialBalance: 500 } });
  check('archived wallet: change initialBalance 409', r.status === 409, r);
  r = await req('PATCH', `/wallets/${w3}`, { token: u.token, body: { name: 'W3 cũ', color: '#000000' } });
  check('archived wallet: cosmetic edit ok, balance still 0', r.status === 200 && r.data.balance === 0 && r.data.name === 'W3 cũ', r.data);
}

group('nghiệp vụ: ngân sách báo lại sau khi chi giảm / tháng theo giờ VN');
{
  const u = await newUser('bud');
  const food = C('Ăn uống');
  const b = (await req('POST', '/budgets', { token: u.token, body: { categoryId: food, month: '2026-12', limitAmount: 1000 } })).data;
  const types = async () => (await req('GET', '/notifications?limit=100', { token: u.token })).data.items.map((x) => x.type);
  let t = (await req('POST', '/transactions', { token: u.token, body: { categoryId: food, walletId: u.cash, amount: 900, title: 'a', occurredAt: '2026-12-10T05:00:00Z' } })).data;
  check('90% => 1 warning', JSON.stringify(await types()) === '["BUDGET_WARNING"]', await types());
  await req('DELETE', `/transactions/${t.id}`, { token: u.token });
  t = (await req('POST', '/transactions', { token: u.token, body: { categoryId: food, walletId: u.cash, amount: 850, title: 'b', occurredAt: '2026-12-11T05:00:00Z' } })).data;
  check('delete re-arms: crossing 80% again => 2nd warning', (await types()).filter((x) => x === 'BUDGET_WARNING').length === 2, await types());
  r = await req('PATCH', `/transactions/${t.id}`, { token: u.token, body: { amount: 1000 } });
  check('100% => exceeded', (await types())[0] === 'BUDGET_EXCEEDED', await types());
  r = await req('PATCH', `/transactions/${t.id}`, { token: u.token, body: { occurredAt: '2026-11-11T05:00:00Z' } });
  r = await req('GET', '/budgets?month=2026-12', { token: u.token });
  check('moved to Nov: Dec spent 0, status ok', r.data.items[0].spent === 0 && r.data.items[0].status === 'ok' && r.data.items[0].warnedAt === null && r.data.items[0].exceededAt === null, r.data.items[0]);
  r = await req('PATCH', `/transactions/${t.id}`, { token: u.token, body: { occurredAt: '2026-12-12T05:00:00Z' } });
  check('moved back => exceeded notified again', (await types()).filter((x) => x === 'BUDGET_EXCEEDED').length === 2, await types());
  r = await req('PATCH', `/transactions/${t.id}`, { token: u.token, body: { categoryId: C('Di chuyển') } });
  r = await req('GET', '/budgets?month=2026-12', { token: u.token });
  check('category change re-checks old category budget (spent 0, flags cleared)', r.data.items[0].spent === 0 && r.data.items[0].exceededAt === null, r.data.items[0]);
  r = await req('PATCH', `/transactions/${t.id}`, { token: u.token, body: { categoryId: C('Lương') } });
  check('expense -> income category ok', r.status === 200 && r.data.type === 'INCOME', r.data);
  // Mốc tháng theo giờ VN: 23:59:59 VN 31/12 thuộc tháng 12; 00:00 VN 1/1 thuộc tháng 1
  await req('POST', '/transactions', { token: u.token, body: { categoryId: food, walletId: u.cash, amount: 300, title: 'giao thừa', occurredAt: '2026-12-31T16:59:59Z' } });
  await req('POST', '/transactions', { token: u.token, body: { categoryId: food, walletId: u.cash, amount: 700, title: 'năm mới', occurredAt: '2026-12-31T17:00:00Z' } });
  await req('POST', '/budgets', { token: u.token, body: { categoryId: food, month: '2027-01', limitAmount: 1000 } });
  r = await req('GET', '/budgets?month=2026-12', { token: u.token });
  check('Dec budget: 23:59:59 VN 31/12 counted (300)', r.data.items[0].spent === 300, r.data.items[0]);
  r = await req('GET', '/budgets?month=2027-01', { token: u.token });
  check('Jan budget: 00:00 VN 1/1 counted (700)', r.data.items[0].spent === 700, r.data.items[0]);
  r = await req('GET', '/stats/report?month=2026-12', { token: u.token });
  check('Dec report expense 300, income 1000', r.data.expense === 300 && r.data.income === 1000, r.data);
  r = await req('GET', '/stats/report?month=2027-01', { token: u.token });
  check('Jan report expense 700, compares with Dec', r.data.expense === 700 && r.data.comparison.expense.previous === 300, r.data.comparison);
  r = await req('GET', '/stats/daily?month=2026-12', { token: u.token });
  check('daily: last row 2026-12-31 = 300', r.data.at(-1).date === '2026-12-31' && r.data.at(-1).expense === 300, r.data);
  r = await req('GET', '/stats/trend?month=2027-01&months=2', { token: u.token });
  check('trend Dec/Jan split at VN midnight', r.data[0].expense === 300 && r.data[1].expense === 700, r.data);
  // Ngày không kèm múi giờ => giờ VN (độc lập TZ máy chủ)
  r = await req('POST', '/transactions', { token: u.token, body: { categoryId: food, walletId: u.cash, amount: 1, title: 'no tz', occurredAt: '2027-01-31T23:30:00' } });
  check('datetime without offset = VN time', r.status === 201 && r.data.occurredAt === '2027-01-31T16:30:00.000Z', r.data);
  r = await req('POST', '/transactions', { token: u.token, body: { categoryId: food, walletId: u.cash, amount: 1, title: 'date only', occurredAt: '2027-02-01' } });
  check('date-only = 00:00 VN', r.status === 201 && r.data.occurredAt === '2027-01-31T17:00:00.000Z', r.data);
  r = await req('GET', '/transactions?from=2027-02-01&to=2027-02-02', { token: u.token });
  check('from/to date-only = VN days', r.status === 200 && r.data.total === 1 && r.data.items[0].title === 'date only', r.data);
  r = await req('POST', '/transactions', { token: u.token, body: { categoryId: food, walletId: u.cash, amount: 1, title: 'x', occurredAt: '1999-12-31T00:00:00Z' } });
  check('date before 2000 => 400', r.status === 400, r);
  r = await req('POST', '/transactions', { token: u.token, body: { categoryId: food, walletId: u.cash, amount: 1, title: 'x', occurredAt: '2100-01-01T00:00:00+07:00' } });
  check('date >= 2100 => 400', r.status === 400, r);
  r = await req('GET', '/transactions?from=2027-02-02&to=2027-02-01', { token: u.token });
  check('from >= to => 400', r.status === 400 && /from/.test(r.data.message), r);
  r = await req('GET', '/stats/summary?from=2027-02-02&to=2027-02-02', { token: u.token });
  check('stats from == to => 400', r.status === 400, r);
}

group('nghiệp vụ: phân trang / tràn số tiền');
{
  const u = await newUser('lim');
  for (const [q, code] of [['page=0', 400], ['page=10001', 400], ['limit=0', 400], ['limit=201', 400], ['page=abc', 400], ['page=1e20', 400], ['page=10000&limit=200', 200]]) {
    r = await req('GET', `/transactions?${q}`, { token: u.token });
    check(`transactions ?${q} => ${code}`, r.status === code, r);
  }
  r = await req('GET', '/notifications?page=10001', { token: u.token });
  check('notifications page cap 400', r.status === 400, r);
  r = await req('GET', '/admin/users?page=10001', { token: tAd });
  check('admin users page cap 400', r.status === 400, r);
  const base = { categoryId: C('Lương'), walletId: u.cash, title: 'big' };
  for (const [amount, code] of [[10000000000000, 201], [10000000000001, 400], [1e20, 400], ['1e3', 201], [1.5, 400], [-5, 400], [0, 400], ['abc', 400]]) {
    r = await req('POST', '/transactions', { token: u.token, body: { ...base, amount } });
    check(`amount ${JSON.stringify(amount)} => ${code}`, r.status === code, r);
  }
  r = await req('POST', '/transactions/bulk', { token: u.token, body: { items: Array.from({ length: 100 }, () => ({ ...base, amount: 10000000000000 })) } });
  check('bulk 100 x max amount ok', r.status === 201 && r.data.created === 100, r.data);
  r = await req('GET', '/wallets', { token: u.token });
  check('balance 1.01e15 still exact (< 2^53)', r.data.totalBalance === 101 * 10000000000000 + 1000, r.data.totalBalance);
  r = await req('POST', '/transactions/bulk', { token: u.token, body: { items: Array.from({ length: 101 }, () => ({ ...base, amount: 1 })) } });
  check('bulk 101 items 400', r.status === 400, r);
  r = await req('POST', '/wallets', { token: u.token, body: { name: 'big', type: 'BANK', initialBalance: 10000000000001 } });
  check('initialBalance overflow 400', r.status === 400, r);
  r = await req('POST', '/budgets', { token: u.token, body: { month: '2026-12', limitAmount: 10000000000001 } });
  check('budget limit overflow 400', r.status === 400, r);
  r = await req('POST', '/saving-goals', { token: u.token, body: { name: 'g', targetAmount: 10000000000001, targetDate: '2030-01-01' } });
  check('goal target overflow 400', r.status === 400, r);
}

group('nghiệp vụ: 404 cho tài nguyên của user khác, 400 cho id tham chiếu');
{
  const o = await newUser('own');
  const x = await newUser('oth');
  const cat = (await req('POST', '/categories', { token: o.token, body: { name: 'Riêng', type: 'EXPENSE' } })).data;
  const w = (await req('POST', '/wallets', { token: o.token, body: { name: 'Bank', type: 'BANK', initialBalance: 1000 } })).data;
  const tx = (await req('POST', '/transactions', { token: o.token, body: { categoryId: cat.id, walletId: o.cash, amount: 1, title: 'x' } })).data;
  const tr = (await req('POST', '/transfers', { token: o.token, body: { fromWalletId: w.id, toWalletId: o.cash, amount: 1 } })).data;
  const bud = (await req('POST', '/budgets', { token: o.token, body: { month: '2026-12', limitAmount: 100 } })).data;
  const g = (await req('POST', '/saving-goals', { token: o.token, body: { name: 'g', targetAmount: 100, targetDate: '2030-01-01' } })).data;
  const tpl = (await req('POST', '/quick-templates', { token: o.token, body: { label: 'q', title: 'q', amount: 1, categoryId: cat.id, walletId: o.cash } })).data;
  const rule = (await req('POST', '/recurring', { token: o.token, body: { walletId: o.cash, categoryId: cat.id, amount: 1, title: 'r', frequency: 'MONTHLY', startDate: iso(Date.now() + 5 * DAY) } })).data;
  await req('POST', '/transactions', { token: o.token, body: { categoryId: cat.id, walletId: o.cash, amount: 100, title: 'trigger', occurredAt: '2026-12-05T05:00:00Z' } });
  const notif = (await req('GET', '/notifications', { token: o.token })).data.items[0];
  const paths = [
    ['GET', `/wallets/${w.id}`], ['PATCH', `/wallets/${w.id}`, { name: 'h' }], ['DELETE', `/wallets/${w.id}`], ['POST', `/wallets/${w.id}/restore`],
    ['PATCH', `/categories/${cat.id}`, { name: 'h' }], ['DELETE', `/categories/${cat.id}`],
    ['GET', `/transactions/${tx.id}`], ['PATCH', `/transactions/${tx.id}`, { amount: 2 }], ['DELETE', `/transactions/${tx.id}`],
    ['GET', `/transfers/${tr.id}`], ['PATCH', `/transfers/${tr.id}`, { amount: 2 }], ['DELETE', `/transfers/${tr.id}`],
    ['PATCH', `/budgets/${bud.id}`, { limitAmount: 5 }], ['DELETE', `/budgets/${bud.id}`],
    ['GET', `/saving-goals/${g.id}`], ['PATCH', `/saving-goals/${g.id}`, { name: 'h' }], ['POST', `/saving-goals/${g.id}/deposit`, { amount: 1, walletId: x.cash }],
    ['POST', `/saving-goals/${g.id}/withdraw`, { walletId: x.cash }], ['DELETE', `/saving-goals/${g.id}`],
    ['PATCH', `/quick-templates/${tpl.id}`, { label: 'h' }], ['POST', `/quick-templates/${tpl.id}/use`, {}], ['DELETE', `/quick-templates/${tpl.id}`],
    ['GET', `/recurring/${rule.id}`], ['GET', `/recurring/${rule.id}/preview`], ['PATCH', `/recurring/${rule.id}`, { amount: 2 }],
    ['POST', `/recurring/${rule.id}/pause`], ['POST', `/recurring/${rule.id}/resume`], ['DELETE', `/recurring/${rule.id}`],
    ['POST', `/notifications/${notif.id}/read`],
    ['GET', `/stats/summary?walletId=${w.id}`], ['GET', `/stats/report?walletId=${w.id}`], ['GET', `/export/transactions.csv?walletId=${w.id}`],
  ];
  const bad = [];
  for (const [m, p, body] of paths) { const rr = await req(m, p, { token: x.token, body }); if (rr.status !== 404) bad.push([m, p, rr.status]); }
  check(`other user's resource => 404 on all ${paths.length} routes`, bad.length === 0, bad);
  const refs = [
    ['POST', '/transactions', { categoryId: cat.id, walletId: x.cash, amount: 1, title: 'x' }],
    ['POST', '/transactions', { categoryId: C('Ăn uống'), walletId: o.cash, amount: 1, title: 'x' }],
    ['POST', '/transfers', { fromWalletId: x.cash, toWalletId: w.id, amount: 1 }],
    ['POST', '/budgets', { categoryId: cat.id, month: '2026-12', limitAmount: 1 }],
    ['POST', '/quick-templates', { label: 'q', title: 'q', amount: 1, categoryId: cat.id, walletId: x.cash }],
    ['POST', '/recurring', { walletId: o.cash, categoryId: C('Ăn uống'), amount: 1, title: 'r', frequency: 'DAILY', startDate: iso(Date.now() + DAY) }],
  ];
  const bad2 = [];
  for (const [m, p, body] of refs) { const rr = await req(m, p, { token: x.token, body }); if (rr.status !== 400) bad2.push([m, p, rr.status]); }
  check(`foreign id in body => 400 on all ${refs.length} routes`, bad2.length === 0, bad2);
  r = await req('GET', '/transactions', { token: o.token });
  check('owner data untouched', r.data.total === 2, r.data.total);
}

group('nghiệp vụ: xóa danh mục hệ thống đang được ngân sách / mẫu dùng');
{
  const u = await newUser('sysc');
  const c1 = (await req('POST', '/admin/categories', { token: tAd, body: { name: `NS ${S}`, type: 'EXPENSE' } })).data;
  const c2 = (await req('POST', '/admin/categories', { token: tAd, body: { name: `Mẫu ${S}`, type: 'EXPENSE' } })).data;
  const bud = (await req('POST', '/budgets', { token: u.token, body: { categoryId: c1.id, month: '2026-12', limitAmount: 100 } })).data;
  const tpl = (await req('POST', '/quick-templates', { token: u.token, body: { label: 'q', title: 'q', amount: 1, categoryId: c2.id, walletId: u.cash } })).data;
  r = await req('DELETE', `/admin/categories/${c1.id}`, { token: tAd });
  check('system cat used only by a user budget => archived', r.status === 200 && r.data.archived === true, r.data);
  r = await req('GET', '/budgets?month=2026-12', { token: u.token });
  check('user budget kept', r.data.items.some((b) => b.id === bud.id), r.data);
  r = await req('DELETE', `/admin/categories/${c2.id}`, { token: tAd });
  check('system cat used only by a template => archived', r.status === 200 && r.data.archived === true, r.data);
  r = await req('GET', '/quick-templates', { token: u.token });
  check('user template kept (category archived flag)', r.data.some((t) => t.id === tpl.id && t.category.isArchived), r.data);
  r = await req('POST', `/quick-templates/${tpl.id}/use`, { token: u.token, body: {} });
  check('template on archived system cat => use 409', r.status === 409, r);
  r = await req('POST', '/budgets', { token: u.token, body: { categoryId: c1.id, month: '2027-01', limitAmount: 100 } });
  check('budget for archived category 400', r.status === 400, r);
  r = await req('POST', '/budgets/copy', { token: u.token, body: { fromMonth: '2026-12', toMonth: '2027-02' } });
  check('copy skips archived-category budget', r.status === 201 && r.data.copied === 0, r.data);
  // User tự xóa danh mục riêng chưa có giao dịch => xóa hẳn, ngân sách đi theo (hành vi đã ghi trong README)
  const own = (await req('POST', '/categories', { token: u.token, body: { name: 'Riêng', type: 'EXPENSE' } })).data;
  await req('POST', '/budgets', { token: u.token, body: { categoryId: own.id, month: '2026-12', limitAmount: 100 } });
  r = await req('DELETE', `/categories/${own.id}`, { token: u.token });
  check('own unused category => hard delete', r.data.archived === false, r.data);
  r = await req('GET', '/budgets?month=2026-12', { token: u.token });
  check('its budget removed with it', r.data.items.length === 1, r.data.items.length);
  // Ví đang được quy tắc định kỳ dùng => lưu trữ, không xóa
  const w = (await req('POST', '/wallets', { token: u.token, body: { name: 'Ví RR', type: 'BANK' } })).data;
  await req('POST', '/recurring', { token: u.token, body: { walletId: w.id, categoryId: C('Ăn uống'), amount: 1, title: 'r', frequency: 'DAILY', startDate: iso(Date.now() + 9 * DAY) } });
  r = await req('DELETE', `/wallets/${w.id}`, { token: u.token });
  check('wallet referenced by recurring => archived', r.data.archived === true, r.data);
}

group('export: CSV khoảng lớn (stream theo lô)');
{
  const u = await newUser('csv');
  for (let b = 0; b < 25; b++) {
    // Mỗi lô cùng 1 thời điểm => nhiều dòng trùng occurredAt vắt qua ranh giới lô 1000 dòng
    const at = new Date(Date.UTC(2026, 0, 1 + b, 3)).toISOString();
    await req('POST', '/transactions/bulk', { token: u.token, body: { items: Array.from({ length: 100 }, (_, i) => ({ categoryId: C('Ăn uống'), walletId: u.cash, amount: 1, title: `csv-${String(b * 100 + i).padStart(4, '0')}`, occurredAt: at })) } });
  }
  const res = await fetch(`${BASE}/export/transactions.csv?from=2026-01-01&to=2027-01-01`, { headers: { authorization: `Bearer ${u.token}` } });
  const body = await res.text();
  const lines = body.split('\r\n').filter(Boolean);
  const titles = lines.slice(1).map((l) => l.split(',')[4]);
  check('2500 rows + header, all unique (no dup/missing across batches)', lines.length === 2501 && new Set(titles).size === 2500 && titles.every((t) => /^csv-\d{4}$/.test(t)), { lines: lines.length, uniq: new Set(titles).size });
  check('sorted by date asc', lines[1].startsWith('2026-01-01 10:00') && lines.at(-1).startsWith('2026-01-25 10:00'), [lines[1], lines.at(-1)]);
  check('streamed (chunked, no content-length)', res.headers.get('transfer-encoding') === 'chunked' && !res.headers.get('content-length'), [...res.headers]);
  r = await fetch(`${BASE}/export/transactions.csv?from=2027-01-01&to=2026-01-01`, { headers: { authorization: `Bearer ${u.token}` } });
  check('CSV from > to => 400 (before stream starts)', r.status === 400, r.status);
}

// ================= DELETE ACCOUNT =================
group('auth: xóa tài khoản');
{
  const d = await newUser('del');
  // Tạo đủ loại dữ liệu để kiểm cascade
  const cat = (await req('POST', '/categories', { token: d.token, body: { name: 'Riêng', type: 'EXPENSE' } })).data;
  const w2 = (await req('POST', '/wallets', { token: d.token, body: { name: 'Bank', type: 'BANK', initialBalance: 1000 } })).data;
  await req('POST', '/transactions', { token: d.token, body: { categoryId: cat.id, walletId: d.cash, amount: 10, title: 'x' } });
  await req('POST', '/transactions', { token: d.token, body: { categoryId: C('Lương'), walletId: d.cash, amount: 1000, title: 'x' } });
  await req('POST', '/transfers', { token: d.token, body: { fromWalletId: w2.id, toWalletId: d.cash, amount: 100 } });
  const g = (await req('POST', '/saving-goals', { token: d.token, body: { name: 'g', targetAmount: 1000, targetDate: '2030-01-01T00:00:00Z' } })).data;
  await req('POST', `/saving-goals/${g.id}/deposit`, { token: d.token, body: { amount: 50, walletId: d.cash } });
  await req('POST', '/budgets', { token: d.token, body: { month: '2026-10', limitAmount: 100 } });
  await req('POST', '/quick-templates', { token: d.token, body: { label: 'q', title: 'q', amount: 1, categoryId: cat.id, walletId: d.cash } });
  await req('POST', '/recurring', { token: d.token, body: { walletId: d.cash, categoryId: cat.id, amount: 1, title: 'r', frequency: 'DAILY', startDate: iso(Date.now() + DAY) } });
  r = await req('DELETE', '/me', { token: d.token, body: { password: 'wrong' } });
  check('delete account wrong password 400', r.status === 400, r);
  r = await req('DELETE', '/me', { token: d.token, body: {} });
  check('delete account missing password 400', r.status === 400, r);
  r = await req('DELETE', '/me', { token: d.token, body: { password: 'secret1' } });
  check('delete account with full data => 204 (cascade)', r.status === 204, r);
  r = await req('GET', '/me', { token: d.token });
  check('deleted user token 401', r.status === 401, r);
  r = await req('POST', '/auth/login', { body: { email: d.email, password: 'secret1' } });
  check('deleted user login 401', r.status === 401, r);
  r = await req('GET', `/admin/users/${d.id}`, { token: tAd });
  check('admin: deleted user 404', r.status === 404, r);
  r = await req('GET', '/admin/users?role=ADMIN&limit=1', { token: tAd });
  if (r.data.total === 1) {
    r = await req('DELETE', '/me', { token: tAd, body: { password: ADMIN_PASSWORD } });
    check('last admin cannot delete self 409', r.status === 409, r);
  } else check('last admin rule (skipped: >1 admin exists)', true);
  const d2 = await newUser('del');
  await req('PATCH', `/admin/users/${d2.id}`, { token: tAd, body: { role: 'ADMIN' } });
  r = await req('DELETE', '/me', { token: d2.token, body: { password: 'secret1' } });
  check('non-last admin can delete self', r.status === 204, r);
}

// ================= FORGOT / RESET PASSWORD =================
group('auth: quên mật khẩu OTP');
{
  const f = await newUser('otp');
  const readOtps = () => {
    try {
      const lines = readFileSync(API_LOG, 'utf8').split('\n').filter((l) => l.includes(`OTP đặt lại mật khẩu cho ${f.email}:`));
      return lines.map((l) => l.match(/OTP đặt lại mật khẩu cho \S+: (\d{6})/)[1]);
    } catch { return null; }
  };
  const waitOtp = async (n) => { for (let i = 0; i < 40; i++) { const o = readOtps(); if (o && o.length >= n) return o[n - 1]; await sleep(100); } return null; };
  r = await req('POST', '/auth/forgot-password', { body: { email: `ghost${S}@test.local` } });
  check('unknown email => 204 (no enumeration)', r.status === 204 && r.text === '', r);
  r = await req('POST', '/auth/forgot-password', { body: { email: f.email.toUpperCase() } });
  check('known email => 204 identical', r.status === 204 && r.text === '', r);
  const otp1 = await waitOtp(1);
  check(`OTP logged to ${API_LOG}`, !!otp1, readOtps());
  r = await req('POST', '/auth/forgot-password', { body: { email: f.email } });
  await sleep(800);
  check('resend within 60s ignored (still 1 OTP)', r.status === 204 && readOtps()?.length === 1, readOtps());
  r = await req('POST', '/auth/forgot-password', { body: { email: 'not-an-email' } });
  check('forgot invalid email 400', r.status === 400, r);
  r = await req('POST', '/auth/reset-password', { body: { email: f.email, otp: '12ab56', newPassword: 'newpass1' } });
  check('otp format 400', r.status === 400, r);
  r = await req('POST', '/auth/reset-password', { body: { email: `ghost${S}@test.local`, otp: '123456', newPassword: 'newpass1' } });
  check('reset unknown email 400 generic', r.status === 400 && r.data.message === 'Mã OTP không đúng hoặc đã hết hạn', r);
  const wrong = otp1 === '000000' ? '111111' : '000000';
  for (let i = 0; i < 4; i++) r = await req('POST', '/auth/reset-password', { body: { email: f.email, otp: wrong, newPassword: 'newpass1' } });
  check('4 wrong attempts => 400', r.status === 400, r);
  r = await req('POST', '/auth/reset-password', { body: { email: f.email, otp: otp1, newPassword: 'short' } });
  check('reset weak password 400', r.status === 400, r);
  r = await req('POST', '/auth/reset-password', { body: { email: f.email, otp: otp1, newPassword: 'newpass1' } });
  check('correct OTP on 5th try => 204', r.status === 204, r);
  r = await req('GET', '/me', { token: f.token });
  check('reset via OTP invalidates existing tokens 401', r.status === 401, r);
  r = await req('POST', '/auth/login', { body: { email: f.email, password: 'newpass1' } });
  check('login with new password', r.status === 200, r);
  r = await req('POST', '/auth/reset-password', { body: { email: f.email, otp: otp1, newPassword: 'newpass2' } });
  check('used OTP cannot be reused', r.status === 400, r);
  // OTP 2: sai 5 lần => chết
  await req('POST', '/auth/forgot-password', { body: { email: f.email } });
  const otp2 = await waitOtp(2);
  check('new OTP issued after previous consumed', !!otp2, readOtps());
  const wrong2 = otp2 === '000000' ? '111111' : '000000';
  for (let i = 0; i < 5; i++) await req('POST', '/auth/reset-password', { body: { email: f.email, otp: wrong2, newPassword: 'newpass2' } });
  r = await req('POST', '/auth/reset-password', { body: { email: f.email, otp: otp2, newPassword: 'newpass2' } });
  check('after 5 wrong attempts OTP is dead (correct OTP rejected)', r.status === 400, r);
  // OTP mới vô hiệu OTP cũ (cần chờ hết 60s giới hạn gửi lại)
  await req('POST', '/auth/forgot-password', { body: { email: f.email } });
  const otp3 = await waitOtp(3);
  console.log('… chờ 61s để kiểm tra OTP mới vô hiệu OTP cũ');
  await sleep(61000);
  await req('POST', '/auth/forgot-password', { body: { email: f.email } });
  const otp4 = await waitOtp(4);
  check('resend allowed after 60s', !!otp4, readOtps());
  r = await req('POST', '/auth/reset-password', { body: { email: f.email, otp: otp3, newPassword: 'newpass3' } });
  check('old OTP invalid after new one issued', otp3 === otp4 || r.status === 400, r);
  r = await req('POST', '/auth/reset-password', { body: { email: f.email, otp: otp4, newPassword: 'newpass3' } });
  check('newest OTP works', r.status === 204, r);
  r = await req('POST', '/auth/login', { body: { email: f.email, password: 'newpass3' } });
  check('login after second reset', r.status === 200, r);
  // Tài khoản bị khóa không nhận OTP
  await req('PATCH', `/admin/users/${f.id}`, { token: tAd, body: { status: 'LOCKED' } });
  await req('POST', '/auth/forgot-password', { body: { email: f.email } });
  await sleep(1000);
  check('locked account gets no OTP', readOtps()?.length === 4, readOtps());
}

// ================= CẤU HÌNH HỆ THỐNG =================
// Mọi thay đổi được khôi phục về giá trị ban đầu ở khối finally (chạy lặp được).
{
  const SECRET = `S3cr3t-${S}`;
  const decode = (t) => JSON.parse(Buffer.from(t.split('.')[1], 'base64url').toString());
  const patch = (body, token = tAd) => req('PATCH', '/admin/config', { token, body });
  const hist = async (q = '') => (await req('GET', `/admin/config/history${q}`, { token: tAd })).data;
  const loginAd = async () => (await req('POST', '/auth/login', { body: { email: ADMIN_EMAIL, password: ADMIN_PASSWORD } })).data.accessToken;
  const C2 = C;
  let initial = null;
  try {
    group('config: quyền / hình dạng / public');
    r = await req('GET', '/admin/config');
    check('GET /admin/config no token 401', r.status === 401, r);
    r = await req('GET', '/admin/config', { token: tA });
    check('GET /admin/config user 403', r.status === 403, r);
    r = await req('PATCH', '/admin/config', { token: tA, body: { general: { appName: 'hack' } } });
    check('PATCH /admin/config user 403', r.status === 403, r);
    r = await req('GET', '/admin/config/history', { token: tA });
    check('GET history user 403', r.status === 403, r);
    r = await req('POST', '/admin/config/maintenance', { token: tA, body: { enabled: true } });
    check('POST maintenance user 403', r.status === 403, r);
    r = await req('POST', '/admin/config/smtp/test', { token: tA });
    check('POST smtp/test user 403', r.status === 403, r);
    r = await req('GET', '/admin/config', { token: tAd });
    check('GET /admin/config admin 200: 6 sections + maintenance + smtp meta + stats',
      r.status === 200 && ['general', 'access', 'smtp', 'password', 'business', 'mobile'].every((s) => typeof r.data.values[s] === 'object')
      && typeof r.data.maintenance.enabled === 'boolean' && typeof r.data.smtp.configured === 'boolean' && typeof r.data.stats.activeUsers === 'number', r.data);
    check('smtp password never in GET (only hasPassword)', !('password' in r.data.values.smtp) && typeof r.data.values.smtp.hasPassword === 'boolean', r.data.values.smtp);
    initial = r.data.values;
    check('defaults = old behaviour (6 chars, OTP 10/5/60, 80/100, "Tiền mặt", features on, 30 ngày)',
      initial.password.minLength === 6 && initial.password.otpExpiryMinutes === 10 && initial.password.otpMaxAttempts === 5 && initial.password.otpResendSeconds === 60
      && initial.business.budgetWarningPercent === 80 && initial.business.budgetExceededPercent === 100 && initial.business.defaultWalletName === 'Tiền mặt'
      && ['featureSavingGoals', 'featureRecurring', 'featureTransfers', 'featureCsvExport', 'featureQuickTemplates'].every((k) => initial.business[k] === true)
      && initial.access.registrationEnabled === true && initial.access.sessionDays === 30, initial);
    r = await req('GET', '/config/public');
    const pub = r.data;
    check('GET /config/public no auth 200, full shape', r.status === 200 && typeof pub.appName === 'string' && pub.currency === 'VND' && typeof pub.registrationEnabled === 'boolean'
      && pub.maintenance && 'enabled' in pub.maintenance && 'message' in pub.maintenance && 'endsAt' in pub.maintenance
      && ['savingGoals', 'recurring', 'transfers', 'csvExport', 'quickTemplates'].every((k) => typeof pub.features[k] === 'boolean')
      && pub.budget.warningPercent === 80 && pub.budget.exceededPercent === 100 && pub.password.minLength === 6
      && pub.mobile.android && pub.mobile.ios && 'latestVersion' in pub.mobile.android && 'minVersion' in pub.mobile.ios && 'storeUrl' in pub.mobile.ios && 'releaseNotes' in pub.mobile
      && 'supportEmail' in pub && 'hotline' in pub && 'termsUrl' in pub && 'privacyUrl' in pub, pub);
    r = await req('GET', '/config/public', { token: 'garbage' });
    check('public config ignores bad token', r.status === 200, r);

    group('config: kiểm tra hợp lệ');
    const bad = async (name, body, key) => {
      const x = await patch(body);
      check(`${name} => 400 errors["${key}"]`, x.status === 400 && typeof x.data.errors?.[key] === 'string', x.data);
      return x;
    };
    r = await bad('privacy link http', { general: { privacyUrl: 'http://thuchi.vn/bao-mat' } }, 'general.privacyUrl');
    check('error message Vietnamese', r.data.errors['general.privacyUrl'] === 'Link phải bắt đầu bằng https://', r.data);
    await bad('support email invalid', { general: { supportEmail: 'hotro@' } }, 'general.supportEmail');
    await bad('hotline invalid', { general: { hotline: 'abc' } }, 'general.hotline');
    await bad('appName empty', { general: { appName: '   ' } }, 'general.appName');
    await bad('sessionDays 0', { access: { sessionDays: 0 } }, 'access.sessionDays');
    await bad('sessionDays 366', { access: { sessionDays: 366 } }, 'access.sessionDays');
    await bad('sessionDays not int', { access: { sessionDays: '30' } }, 'access.sessionDays');
    await bad('registrationEnabled not bool', { access: { registrationEnabled: 'yes' } }, 'access.registrationEnabled');
    await bad('maintenanceEnabled via PATCH', { access: { maintenanceEnabled: true } }, 'access.maintenanceEnabled');
    await bad('maintenanceEndsAt in the past', { access: { maintenanceEndsAt: new Date(Date.now() - 60000).toISOString() } }, 'access.maintenanceEndsAt');
    await bad('maintenance message > 200', { access: { maintenanceMessage: 'x'.repeat(201) } }, 'access.maintenanceMessage');
    await bad('smtp port 70000', { smtp: { port: 70000 } }, 'smtp.port');
    await bad('smtp security enum', { smtp: { security: 'tls' } }, 'smtp.security');
    await bad('smtp from format', { smtp: { from: 'Thu Chi <khong-hop-le>' } }, 'smtp.from');
    await bad('password minLength 5', { password: { minLength: 5 } }, 'password.minLength');
    await bad('otp attempts 11', { password: { otpMaxAttempts: 11 } }, 'password.otpMaxAttempts');
    await bad('otp resend >= expiry', { password: { otpExpiryMinutes: 1, otpResendSeconds: 60 } }, 'password.otpResendSeconds');
    await bad('warning >= exceeded', { business: { budgetWarningPercent: 100, budgetExceededPercent: 100 } }, 'business.budgetWarningPercent');
    await bad('wallet name empty', { business: { defaultWalletName: '' } }, 'business.defaultWalletName');
    await bad('version format', { mobile: { androidLatestVersion: '1.4' } }, 'mobile.androidLatestVersion');
    await bad('min > latest', { mobile: { iosLatestVersion: '1.2.0', iosMinVersion: '1.3.0' } }, 'mobile.iosMinVersion');
    await bad('store link http', { mobile: { androidStoreUrl: 'http://play.google.com/x' } }, 'mobile.androidStoreUrl');
    await bad('release notes > 300', { mobile: { releaseNotes: 'x'.repeat(301) } }, 'mobile.releaseNotes');
    await bad('unknown section', { foo: { a: 1 } }, 'foo');
    await bad('unknown field', { general: { color: 'red' } }, 'general.color');
    r = await patch({ general: { appName: 'Không lưu' }, business: { budgetWarningPercent: 5 } });
    check('one invalid field => nothing saved (all or nothing)', r.status === 400 && 'business.budgetWarningPercent' in r.data.errors, r.data);
    r = await req('GET', '/admin/config', { token: tAd });
    check('state unchanged after rejected PATCH', r.data.values.general.appName === initial.general.appName, r.data.values.general);
    r = await req('GET', '/admin/config/history?section=nope', { token: tAd });
    check('history bad section 400', r.status === 400, r);

    group('config: lưu / áp dụng ngay / lịch sử');
    const h0 = (await hist()).total;
    r = await patch({ general: { appName: `Thu Chi E2E`, supportEmail: 'hotro@thuchi.vn', hotline: '028 7300 6868', termsUrl: 'https://thuchi.vn/dieu-khoan', privacyUrl: 'https://thuchi.vn/bao-mat' } });
    check('PATCH general 200 returns new state', r.status === 200 && r.data.values.general.appName === 'Thu Chi E2E' && r.data.values.general.hotline === '028 7300 6868', r.data);
    check('lastSaved by admin', r.data.lastSaved && r.data.lastSaved.by && r.data.lastSaved.at, r.data.lastSaved);
    r = await req('GET', '/config/public');
    check('public reflects immediately (cache invalidated on save)', r.data.appName === 'Thu Chi E2E' && r.data.supportEmail === 'hotro@thuchi.vn' && r.data.privacyUrl === 'https://thuchi.vn/bao-mat', r.data);
    let h = await hist('?section=general&limit=50');
    const nameRow = h.items.find((x) => x.key === 'appName');
    check('history: 1 row per changed field (5)', (await hist()).total === h0 + 5, h.total);
    check('history row: actor, section, old -> new', nameRow && nameRow.section === 'general' && nameRow.oldValue === initial.general.appName && nameRow.newValue === 'Thu Chi E2E' && nameRow.actor?.email === ADMIN_EMAIL && nameRow.secret === false, nameRow);
    r = await patch({ general: { appName: 'Thu Chi E2E' } });
    check('PATCH with unchanged value => no new history row', r.status === 200 && (await hist()).total === h0 + 5, r.status);
    h = await hist('?page=1&limit=2');
    check('history paginated (limit 2, newest first)', h.items.length === 2 && h.limit === 2 && h.total >= 5 && new Date(h.items[0].createdAt) >= new Date(h.items[1].createdAt), h);
    h = await hist('?section=general&limit=200');
    check('history filter by section', h.items.length > 0 && h.items.every((x) => x.section === 'general') && h.counts.general >= 5, h.counts);

    group('config: SMTP (bí mật mã hóa, gửi thử)');
    r = await patch({ smtp: { host: '127.0.0.1', port: 2599, security: 'none', user: 'no-reply@thuchi.vn', password: SECRET, from: 'Thu Chi <no-reply@thuchi.vn>' } });
    check('PATCH smtp 200, password not echoed', r.status === 200 && !r.text.includes(SECRET) && r.data.values.smtp.hasPassword === true && r.data.smtp.configured === true && r.data.smtp.source === 'db', r.data.smtp);
    check('passwordSavedAt / passwordSavedBy', !!r.data.smtp.passwordSavedAt && !!r.data.smtp.passwordSavedBy, r.data.smtp);
    r = await req('GET', '/admin/config', { token: tAd });
    check('GET /admin/config never contains secret', r.status === 200 && !r.text.includes(SECRET), r.text.length);
    r = await req('GET', '/admin/config/history?limit=200', { token: tAd });
    const pwRow = r.data.items.find((x) => x.section === 'smtp' && x.key === 'password');
    check('history: secret row masked ••••, flagged secret', !r.text.includes(SECRET) && pwRow && pwRow.oldValue === '••••' && pwRow.newValue === '••••' && pwRow.secret === true, pwRow);
    r = await req('GET', '/config/public');
    check('public config never contains SMTP data', !r.text.includes(SECRET) && !r.text.includes('2599') && !('smtp' in r.data), r.data);
    {
      const smtp = await fakeSmtp();
      try {
        r = await patch({ smtp: { port: smtp.port } });
        r = await req('POST', '/admin/config/smtp/test', { token: tAd });
        check('smtp test with working server => {ok:true, response 250}', r.status === 200 && r.data.ok === true && /^250/.test(r.data.response) && r.data.to === ADMIN_EMAIL, r.data);
        check('server received mail to admin, AUTH with the decrypted saved password', smtp.mails.length === 1 && smtp.mails[0].auth?.user === 'no-reply@thuchi.vn' && smtp.mails[0].auth?.pass === SECRET && smtp.mails[0].raw.includes(ADMIN_EMAIL), smtp.mails.map((m) => ({ auth: m.auth, len: m.raw.length })));
        const se = `smtp${S}@test.local`;
        await req('POST', '/auth/register', { body: { email: se, password: 'secret1234', name: 'SMTP' } });
        await req('POST', '/auth/forgot-password', { body: { email: se } });
        for (let i = 0; i < 50 && smtp.mails.length < 2; i++) await sleep(100);
        const raw = smtp.mails[1]?.raw ?? '';
        const otp = raw.replace(/=\r?\n/g, '').match(/OTP[\s\S]{0,80}?(\d{6})/)?.[1];
        check('forgot-password OTP sent via DB SMTP config (not logged), "10 phút" + app name in mail', !!otp && raw.includes(se) && /10 ph/.test(raw.replace(/=C3=BA/g, 'ú')) && !readFileSync(API_LOG, 'utf8').includes(`cho ${se}:`), raw.slice(0, 600));
        r = await req('POST', '/auth/reset-password', { body: { email: se, otp, newPassword: 'secret5678' } });
        check('OTP from email works', r.status === 204, r.data);
      } finally {
        await smtp.close();
      }
      r = await patch({ smtp: { port: 2599 } });
    }
    r = await req('POST', '/admin/config/smtp/test', { token: tAd });
    check('smtp test with unreachable server => 200 {ok:false, error detail}, sent to admin email', r.status === 200 && r.data.ok === false && /ECONNREFUSED|ESOCKET|ECONNECTION/.test(r.data.error) && r.data.to === ADMIN_EMAIL && !r.text.includes(SECRET), r.data);
    let last = r;
    for (let i = 0; i < 6 && last.status !== 429; i++) last = await req('POST', '/admin/config/smtp/test', { token: tAd });
    check('smtp test rate-limited (5/min) => 429', last.status === 429 && Number(last.headers.get('retry-after-smtptest') ?? last.headers.get('retry-after')) > 0, { status: last.status, h: [...last.headers] });
    r = await patch({ smtp: { password: `${SECRET}-2` } });
    check('change password only => still hidden', r.status === 200 && !r.text.includes(SECRET) && r.data.values.smtp.hasPassword, r.data.smtp);
    r = await patch({ smtp: { host: '', password: '' } });
    check('clear host + password => not configured, hasPassword false', r.status === 200 && r.data.smtp.configured === false && r.data.values.smtp.hasPassword === false, r.data.smtp);

    group('config: đăng ký / ví mặc định / độ dài mật khẩu');
    r = await patch({ business: { defaultWalletName: 'Ví chính E2E' }, password: { minLength: 10 } });
    check('PATCH wallet name + min length', r.status === 200 && r.data.values.password.minLength === 10, r.data.values.password);
    r = await req('GET', '/config/public');
    check('public password.minLength = 10', r.data.password.minLength === 10, r.data.password);
    const pe = `pw${S}@test.local`;
    r = await req('POST', '/auth/register', { body: { email: pe, password: 'secret12', name: 'PW' } });
    check('register with 8 chars < 10 => 400 Vietnamese', r.status === 400 && /ít nhất 10 ký tự/.test(r.data.message), r.data);
    r = await req('POST', '/auth/register', { body: { email: pe, password: 'secret1234', name: 'PW' } });
    check('register with 10 chars => 201', r.status === 201, r.data);
    let tPw = r.data.accessToken; const idPw = r.data.user?.id;
    r = await req('GET', '/wallets', { token: tPw });
    check('register creates default wallet with configured name', r.data.items.length === 1 && r.data.items[0].name === 'Ví chính E2E' && r.data.items[0].type === 'CASH', r.data.items);
    r = await req('POST', '/me/password', { token: tPw, body: { currentPassword: 'secret1234', newPassword: 'short1234' } });
    check('change password 9 chars => 400', r.status === 400 && /ít nhất 10 ký tự/.test(r.data.message), r.data);
    r = await req('POST', '/me/password', { token: tPw, body: { currentPassword: 'secret1234', newPassword: 'longer12345' } });
    check('change password 11 chars => 200', r.status === 200, r.data);
    tPw = r.data.accessToken;
    {
      const readOtps = () => { try { return readFileSync(API_LOG, 'utf8').split('\n').filter((l) => l.includes(`OTP đặt lại mật khẩu cho ${pe}:`)); } catch { return []; } };
      await req('POST', '/auth/forgot-password', { body: { email: pe } });
      let line; for (let i = 0; i < 40 && !line; i++) { line = readOtps()[0]; if (!line) await sleep(100); }
      const otp = line?.match(/: (\d{6})/)?.[1];
      r = await req('POST', '/auth/reset-password', { body: { email: pe, otp, newPassword: 'short1234' } });
      check('reset password 9 chars => 400 (OTP kept)', r.status === 400 && /ít nhất 10 ký tự/.test(r.data.message), r.data);
      r = await req('POST', '/auth/reset-password', { body: { email: pe, otp, newPassword: 'resetpass123' } });
      check('reset password 12 chars => 204', r.status === 204, r.data);
    }
    r = await patch({ password: { minLength: 6 } });
    r = await req('POST', '/auth/register', { body: { email: `pw6${S}@test.local`, password: 'secret', name: 'PW6' } });
    check('min length back to 6 => 6 chars accepted', r.status === 201, r.data);
    r = await patch({ access: { registrationEnabled: false } });
    check('disable registration', r.status === 200 && r.data.values.access.registrationEnabled === false, r.data.values.access);
    r = await req('GET', '/config/public');
    check('public registrationEnabled false', r.data.registrationEnabled === false, r.data);
    r = await req('POST', '/auth/register', { body: { email: `closed${S}@test.local`, password: 'secret1234', name: 'X' } });
    check('register when disabled => 403 REGISTRATION_DISABLED Vietnamese', r.status === 403 && r.data.code === 'REGISTRATION_DISABLED' && /tạm ngưng nhận đăng ký/.test(r.data.message), r.data);
    r = await req('POST', '/auth/login', { body: { email: pe, password: 'resetpass123' } });
    check('existing users still log in when registration disabled', r.status === 200, r.data);
    r = await patch({ access: { registrationEnabled: true } });
    r = await req('POST', '/auth/register', { body: { email: `open${S}@test.local`, password: 'secret1234', name: 'X' } });
    check('re-enabled => register 201', r.status === 201, r.data);

    group('config: thời hạn phiên (JWT exp)');
    r = await req('POST', '/auth/login', { body: { email: pe, password: 'resetpass123' } });
    let p = decode(r.data.accessToken);
    check('default (env 30d) => exp - iat = 30 days', p.exp - p.iat === 30 * 86400, p);
    await patch({ access: { sessionDays: 7 } });
    r = await req('POST', '/auth/login', { body: { email: pe, password: 'resetpass123' } });
    p = decode(r.data.accessToken);
    check('sessionDays 7 => login token exp - iat = 7 days', p.exp - p.iat === 7 * 86400, p);
    r = await req('POST', '/me/password', { token: r.data.accessToken, body: { currentPassword: 'resetpass123', newPassword: 'resetpass456' } });
    p = decode(r.data.accessToken);
    check('sessionDays 7 => change-password token also 7 days', p.exp - p.iat === 7 * 86400, p);
    await patch({ access: { sessionDays: 90 } });
    r = await req('POST', '/auth/register', { body: { email: `jwt${S}@test.local`, password: 'secret1234', name: 'J' } });
    p = decode(r.data.accessToken);
    check('sessionDays 90 => register token 90 days', p.exp - p.iat === 90 * 86400, p);

    group('config: giới hạn đăng nhập theo email');
    await patch({ access: { loginMaxAttempts: 3, loginWindowMinutes: 1 } });
    const le = `lim${S}@test.local`;
    await req('POST', '/auth/register', { body: { email: le, password: 'secret1234', name: 'L' } });
    const le2 = `lim2${S}@test.local`;
    await req('POST', '/auth/register', { body: { email: le2, password: 'secret1234', name: 'L2' } });
    const codes = [];
    for (let i = 0; i < 3; i++) codes.push((await req('POST', '/auth/login', { body: { email: le, password: 'wrong-pass' } })).status);
    check('3 wrong attempts => 401 x3', codes.every((c) => c === 401), codes);
    r = await req('POST', '/auth/login', { body: { email: le, password: 'secret1234' } });
    check('4th attempt (even correct) => 429 + Retry-After ≈ 60s', r.status === 429 && Number(r.headers.get('retry-after-login')) > 50, { s: r.status, h: [...r.headers] });
    check('standard Retry-After header too (app/admin read it)', Number(r.headers.get('retry-after')) > 50, [...r.headers]);
    r = await req('POST', '/auth/login', { body: { email: le2, password: 'secret1234' } });
    check('other email from same IP not blocked (per email)', r.status === 200, r.data);
    check('login limit header reflects config (3)', r.headers.get('x-ratelimit-limit-login') === '3', [...r.headers]);
    await patch({ access: { loginMaxAttempts: initial.access.loginMaxAttempts, loginWindowMinutes: initial.access.loginWindowMinutes } });

    group('config: OTP (hạn / số lần sai / chờ gửi lại)');
    r = await patch({ password: { otpExpiryMinutes: 2, otpMaxAttempts: 2, otpResendSeconds: 30 } });
    check('PATCH otp params', r.status === 200 && r.data.values.password.otpResendSeconds === 30, r.data.values.password);
    r = await req('GET', '/config/public');
    check('public otp params', r.data.otp.expiryMinutes === 2 && r.data.otp.resendSeconds === 30, r.data.otp);
    {
      const oe = `otp${S}@test.local`;
      await req('POST', '/auth/register', { body: { email: oe, password: 'secret1234', name: 'O' } });
      const lines = () => { try { return readFileSync(API_LOG, 'utf8').split('\n').filter((l) => l.includes(`OTP đặt lại mật khẩu cho ${oe}:`)); } catch { return []; } };
      const waitN = async (n) => { for (let i = 0; i < 40; i++) { if (lines().length >= n) return lines()[n - 1]; await sleep(100); } return null; };
      const t0 = Date.now();
      await req('POST', '/auth/forgot-password', { body: { email: oe } });
      let l1 = await waitN(1);
      check('OTP mail says expiry 2 minutes', !!l1 && /hạn 2 phút/.test(l1), l1);
      const o1 = l1?.match(/: (\d{6})/)?.[1];
      const w1 = o1 === '000000' ? '111111' : '000000';
      for (let i = 0; i < 2; i++) await req('POST', '/auth/reset-password', { body: { email: oe, otp: w1, newPassword: 'secret5678' } });
      r = await req('POST', '/auth/reset-password', { body: { email: oe, otp: o1, newPassword: 'secret5678' } });
      check('max attempts 2 => after 2 wrong, correct OTP rejected', r.status === 400, r.data);
      await req('POST', '/auth/forgot-password', { body: { email: oe } });
      const l2 = await waitN(2);
      check('dead OTP => new one issued immediately', !!l2, lines().length);
      await req('POST', '/auth/forgot-password', { body: { email: oe } });
      await sleep(800);
      check('resend within 30s ignored', lines().length === 2, lines().length);
      const wait = 31000 - (Date.now() - t0) + 1500;
      console.log(`… chờ ${Math.round(Math.max(wait, 31000) / 1000)}s kiểm tra chờ gửi lại 30s (mặc định 60s)`);
      await sleep(Math.max(wait, 31000));
      await req('POST', '/auth/forgot-password', { body: { email: oe } });
      const l3 = await waitN(3);
      check('resend allowed after 30s (< default 60s)', !!l3, lines().length);
      r = await req('POST', '/auth/reset-password', { body: { email: oe, otp: l3?.match(/: (\d{6})/)?.[1], newPassword: 'secret5678' } });
      check('newest OTP works', r.status === 204, r.data);
    }
    await patch({ password: { otpExpiryMinutes: 10, otpMaxAttempts: 5, otpResendSeconds: 60 } });

    group('config: ngưỡng ngân sách điều khiển thông báo');
    r = await patch({ business: { budgetWarningPercent: 50, budgetExceededPercent: 120 } });
    check('PATCH thresholds 50 / 120', r.status === 200 && r.data.values.business.budgetWarningPercent === 50, r.data.values.business);
    {
      const U = await newUser('budg');
      const month = '2026-12';
      await req('POST', '/budgets', { token: U.token, body: { categoryId: C2('Ăn uống'), month, limitAmount: 1000000 } });
      const add = (amount) => req('POST', '/transactions', { token: U.token, body: { categoryId: C2('Ăn uống'), walletId: U.cash, amount, title: 'ăn', occurredAt: `${month}-05T05:00:00Z` } });
      const notes = async () => (await req('GET', '/notifications', { token: U.token })).data.items;
      const status = async () => (await req('GET', `/budgets?month=${month}`, { token: U.token })).data;
      await add(400000);
      check('40% => no notification, status ok', (await notes()).length === 0 && (await status()).items[0].status === 'ok', await notes());
      await add(150000);
      let n = await notes();
      let st = await status();
      check('55% (>= 50) => BUDGET_WARNING, status warning', n.length === 1 && n[0].type === 'BUDGET_WARNING' && st.items[0].status === 'warning', { n, st });
      check('GET /budgets returns thresholds in use', st.thresholds?.warningPercent === 50 && st.thresholds?.exceededPercent === 120, st.thresholds);
      await add(500000);
      n = await notes(); st = await status();
      check('105% (< 120) => no exceeded notification, still warning', n.length === 1 && st.items[0].status === 'warning', { n, st: st.items[0] });
      await add(200000);
      n = await notes(); st = await status();
      check('125% (>= 120) => BUDGET_EXCEEDED, status exceeded', n.length === 2 && n[0].type === 'BUDGET_EXCEEDED' && st.items[0].status === 'exceeded', { n, st: st.items[0] });
      r = await req('GET', '/config/public');
      check('public budget thresholds', r.data.budget.warningPercent === 50 && r.data.budget.exceededPercent === 120, r.data.budget);
    }
    await patch({ business: { budgetWarningPercent: 80, budgetExceededPercent: 100 } });

    group('config: tính năng tắt => ghi 403, đọc vẫn được');
    {
      const U = await newUser('feat');
      const bank = (await req('POST', '/wallets', { token: U.token, body: { name: 'NH', type: 'BANK', initialBalance: 5000000 } })).data.id;
      const goal = (await req('POST', '/saving-goals', { token: U.token, body: { name: 'Mục tiêu', targetAmount: 1000000, targetDate: '2027-06-01T00:00:00Z' } })).data;
      const tr = (await req('POST', '/transfers', { token: U.token, body: { fromWalletId: bank, toWalletId: U.cash, amount: 1000 } })).data;
      const tpl = (await req('POST', '/quick-templates', { token: U.token, body: { label: 'Cà phê', title: 'Cà phê', amount: 30000, categoryId: C2('Ăn uống'), walletId: U.cash } })).data;
      const rule = (await req('POST', '/recurring', { token: U.token, body: { walletId: U.cash, categoryId: C2('Hóa đơn'), amount: 100, title: 'Điện', frequency: 'DAILY', startDate: iso(Date.now() + DAY) } })).data;
      check('setup data for 5 features', goal?.id && tr?.id && tpl?.id && rule?.id, { goal, tr, tpl, rule });
      r = await patch({ business: { featureSavingGoals: false, featureRecurring: false, featureTransfers: false, featureCsvExport: false, featureQuickTemplates: false } });
      check('disable 5 features', r.status === 200 && r.data.values.business.featureTransfers === false, r.data.values.business);
      r = await req('GET', '/config/public');
      check('public features all false', Object.values(r.data.features).every((v) => v === false), r.data.features);
      const off = (name, x) => check(`${name} => 403 FEATURE_DISABLED`, x.status === 403 && x.data.code === 'FEATURE_DISABLED' && typeof x.data.message === 'string', x.data);
      const on = (name, x) => check(`${name} => 200 (read allowed, data kept)`, x.status === 200, x.data);
      on('GET /saving-goals', r = await req('GET', '/saving-goals', { token: U.token }));
      check('saving goal still listed', r.data.length === 1 || r.data.items?.length === 1, r.data);
      on('GET /saving-goals/:id', await req('GET', `/saving-goals/${goal.id}`, { token: U.token }));
      off('POST /saving-goals', await req('POST', '/saving-goals', { token: U.token, body: { name: 'x', targetAmount: 1000, targetDate: '2027-06-01T00:00:00Z' } }));
      off('PATCH /saving-goals/:id', await req('PATCH', `/saving-goals/${goal.id}`, { token: U.token, body: { name: 'y' } }));
      off('POST /saving-goals/:id/deposit', await req('POST', `/saving-goals/${goal.id}/deposit`, { token: U.token, body: { amount: 1000, walletId: bank } }));
      off('DELETE /saving-goals/:id', await req('DELETE', `/saving-goals/${goal.id}`, { token: U.token }));
      on('GET /transfers', r = await req('GET', '/transfers', { token: U.token }));
      check('transfer still listed', r.data.total === 1, r.data);
      off('POST /transfers', await req('POST', '/transfers', { token: U.token, body: { fromWalletId: bank, toWalletId: U.cash, amount: 1000 } }));
      off('DELETE /transfers/:id', await req('DELETE', `/transfers/${tr.id}`, { token: U.token }));
      on('GET /quick-templates', await req('GET', '/quick-templates', { token: U.token }));
      off('POST /quick-templates', await req('POST', '/quick-templates', { token: U.token, body: { label: 'x', title: 'x', amount: 1, categoryId: C2('Ăn uống'), walletId: U.cash } }));
      off('POST /quick-templates/:id/use', await req('POST', `/quick-templates/${tpl.id}/use`, { token: U.token, body: {} }));
      on('GET /recurring', await req('GET', '/recurring', { token: U.token }));
      on('GET /recurring/:id/preview', await req('GET', `/recurring/${rule.id}/preview?count=3`, { token: U.token }));
      off('POST /recurring', await req('POST', '/recurring', { token: U.token, body: { walletId: U.cash, categoryId: C2('Hóa đơn'), amount: 1, title: 'x', frequency: 'DAILY', startDate: iso(Date.now() + DAY) } }));
      off('POST /recurring/:id/pause', await req('POST', `/recurring/${rule.id}/pause`, { token: U.token }));
      off('POST /recurring/run-due (user)', await req('POST', `/recurring/run-due?now=${iso(Date.now() + 3 * DAY)}`, { token: U.token }));
      r = await req('POST', '/admin/recurring/run-due', { token: tAd });
      check('cron path (admin run-due) paused while recurring disabled', r.status === 200 && r.data.skipped === true && r.data.reason === 'FEATURE_DISABLED', r.data);
      off('GET /export/transactions.csv (export is the feature itself)', await req('GET', '/export/transactions.csv?month=2026-12', { token: U.token }));
      on('GET /transactions unaffected', await req('GET', '/transactions', { token: U.token }));
      r = await patch({ business: { featureSavingGoals: true, featureRecurring: true, featureTransfers: true, featureCsvExport: true, featureQuickTemplates: true } });
      check('re-enable features', r.status === 200 && r.data.values.business.featureCsvExport === true, r.data.values.business);
      r = await req('POST', '/transfers', { token: U.token, body: { fromWalletId: bank, toWalletId: U.cash, amount: 1000 } });
      check('re-enabled: POST /transfers 201', r.status === 201, r.data);
      r = await req('POST', `/saving-goals/${goal.id}/deposit`, { token: U.token, body: { amount: 1000, walletId: bank } });
      check('re-enabled: deposit 200', r.status === 200, r.data);
      r = await req('POST', `/quick-templates/${tpl.id}/use`, { token: U.token, body: {} });
      check('re-enabled: template use 201', r.status === 201, r.data);
      r = await req('GET', '/export/transactions.csv?month=2026-12', { token: U.token });
      check('re-enabled: CSV 200', r.status === 200, r.status);
      r = await req('POST', `/recurring/run-due?now=${iso(Date.now() + 3 * DAY)}`, { token: U.token });
      check('re-enabled: recurring catches up missed periods', r.status === 200 && r.data.created >= 2, r.data);
      h = await hist('?section=business&limit=20');
      check('history: feature toggles recorded (bool old -> new)', h.items.some((x) => x.key === 'featureCsvExport' && x.oldValue === false && x.newValue === true), h.items.slice(0, 3));
    }

    group('config: bảo trì (admin không bị chặn, tự tắt theo giờ)');
    {
      const M = await newUser('maint');
      r = await req('POST', '/admin/config/maintenance', { token: tAd, body: { enabled: true, message: 'x', endsAt: new Date(Date.now() - 1000).toISOString() } });
      check('turn on with endsAt in the past => 400', r.status === 400 && 'access.maintenanceEndsAt' in r.data.errors, r.data);
      r = await req('POST', '/admin/config/maintenance', { token: tAd, body: { enabled: true, message: '' } });
      check('turn on with empty message => 400', r.status === 400, r.data);
      r = await req('POST', '/admin/config/maintenance', { token: tAd, body: { enabled: 'yes' } });
      check('enabled not boolean => 400', r.status === 400, r.data);
      r = await req('POST', '/admin/config/maintenance', { token: tAd, body: { enabled: true, message: `Bảo trì E2E ${S}` } });
      check('turn on 200 (startedBy admin, startedAt)', r.status === 200 && r.data.enabled === true && r.data.message === `Bảo trì E2E ${S}` && !!r.data.startedBy && !!r.data.startedAt && r.data.endsAt === null, r.data);
      r = await req('GET', '/me', { token: M.token });
      check('user request => 503 {code:MAINTENANCE, message, endsAt}', r.status === 503 && r.data.code === 'MAINTENANCE' && r.data.message === `Bảo trì E2E ${S}` && r.data.endsAt === null, r.data);
      r = await req('GET', '/wallets', { token: M.token });
      check('user any route => 503', r.status === 503, r.status);
      r = await req('POST', '/auth/login', { body: { email: M.email, password: 'secret1' } });
      check('user login => 503 MAINTENANCE', r.status === 503 && r.data.code === 'MAINTENANCE', r.data);
      r = await req('POST', '/auth/register', { body: { email: `mreg${S}@test.local`, password: 'secret1', name: 'X' } });
      check('register => 503 MAINTENANCE', r.status === 503 && r.data.code === 'MAINTENANCE', r.data);
      const tAd2 = await loginAd();
      check('admin login still works', !!tAd2, tAd2);
      r = await req('GET', '/admin/overview', { token: tAd2 });
      check('admin routes unaffected', r.status === 200, r.status);
      r = await req('GET', '/me', { token: tAd });
      check('admin own /me unaffected', r.status === 200, r.status);
      r = await req('GET', '/config/public');
      check('public config works + shows maintenance', r.status === 200 && r.data.maintenance.enabled === true && r.data.maintenance.message === `Bảo trì E2E ${S}`, r.data.maintenance);
      r = await req('GET', '/health');
      check('health works during maintenance', r.status === 200, r.status);
      r = await req('GET', '/admin/config', { token: tAd });
      check('admin view: maintenance on', r.data.maintenance.enabled === true, r.data.maintenance);
      r = await req('POST', '/admin/config/maintenance', { token: tAd, body: { enabled: false } });
      check('turn off 200', r.status === 200 && r.data.enabled === false, r.data);
      r = await req('GET', '/me', { token: M.token });
      check('user works again after off', r.status === 200, r.status);
      h = await hist('?section=access&limit=10');
      check('history: manual on/off recorded with actor', h.items.filter((x) => x.key === 'maintenanceEnabled' && x.actor?.email === ADMIN_EMAIL).length >= 2, h.items.slice(0, 4));
      // Tự tắt theo giờ dự kiến xong
      const endsAt = new Date(Date.now() + 3000).toISOString();
      r = await req('POST', '/admin/config/maintenance', { token: tAd, body: { enabled: true, endsAt } });
      check('turn on with endsAt +3s', r.status === 200 && r.data.enabled === true && r.data.endsAt === endsAt, r.data);
      r = await req('GET', '/me', { token: M.token });
      check('503 carries endsAt', r.status === 503 && r.data.endsAt === endsAt, r.data);
      r = await req('GET', '/config/public');
      check('public maintenance.endsAt', r.data.maintenance.endsAt === endsAt, r.data.maintenance);
      await sleep(3500);
      r = await req('GET', '/me', { token: M.token });
      check('after endsAt passes => auto off, user 200', r.status === 200, r.data);
      await sleep(500);
      r = await req('GET', '/admin/config', { token: tAd });
      check('admin view: maintenance off, endsAt cleared', r.data.maintenance.enabled === false && r.data.values.access.maintenanceEndsAt === null, r.data.maintenance);
      h = await hist('?section=access&limit=5');
      const sys = h.items.find((x) => x.key === 'maintenanceEnabled');
      check('history: auto-off recorded as system (actor null), true -> false', sys && sys.actor === null && sys.oldValue === true && sys.newValue === false, h.items.slice(0, 3));
      r = await req('POST', '/admin/config/maintenance', { token: tAd, body: { enabled: false } });
      check('turn off when already off => 200 no-op', r.status === 200 && r.data.enabled === false, r.data);
    }
  } finally {
    group('config: khôi phục mặc định');
    await req('POST', '/admin/config/maintenance', { token: tAd, body: { enabled: false } });
    if (initial) {
      const body = JSON.parse(JSON.stringify(initial));
      delete body.smtp.hasPassword;
      body.smtp.password = '';
      r = await patch(body);
      check('restore initial values 200', r.status === 200, r.data);
      const now = (await req('GET', '/admin/config', { token: tAd })).data.values;
      check('state equals initial (re-runnable)', JSON.stringify(now) === JSON.stringify(initial), { now, initial });
    }
  }
}

// ================= SWAGGER =================
group('swagger');
r = await fetch(BASE.replace(/\/api$/, '') + '/docs/openapi.json');
{
  const doc = r.status === 200 ? await r.json() : { paths: {}, components: { schemas: {} } };
  check('openapi.json 59 paths (+health, logout-all, admin run-due, 5 cấu hình)', Object.keys(doc.paths).length === 59, Object.keys(doc.paths).length);
  check('config PATCH body documented per section', ['general', 'access', 'smtp', 'password', 'business', 'mobile'].every((k) => k in (doc.paths['/api/admin/config']?.patch?.requestBody?.content?.['application/json']?.schema?.properties ?? {})), doc.paths['/api/admin/config']);
  check('DTO schemas populated', ['amount', 'categoryId', 'walletId', 'title'].every((k) => k in (doc.components.schemas.CreateTransactionDto?.properties ?? {})), doc.components.schemas.CreateTransactionDto);
}

// ================= HEALTH =================
group('health');
r = await req('GET', '/health');
check('GET /health public 200 {status, db, version}', r.status === 200 && r.data.status === 'ok' && r.data.db === 'up' && /^\d+\.\d+\.\d+/.test(r.data.version), r);
r = await req('GET', '/health', { token: 'garbage' });
check('health ignores bad token', r.status === 200, r);

// ================= RATE LIMIT (để cuối: làm cạn hạn mức rồi chờ hết khóa) =================
group('rate limit: 429 theo IP + route');
{
  const routes = [['/auth/login', { email: 'x' }], ['/auth/register', { email: 'x' }], ['/auth/reset-password', { email: 'x' }], ['/auth/forgot-password', { email: 'x' }]];
  const limits = {};
  for (const [path, body] of routes) {
    const first = await req('POST', path, { body });
    const limit = Number(first.headers.get('x-ratelimit-limit'));
    limits[path] = limit;
    check(`${path}: X-RateLimit-Limit/Remaining headers`, limit > 0 && first.headers.get('x-ratelimit-remaining') !== null, [...first.headers]);
    let last = first, n = 1;
    while (last.status !== 429 && n < 2 * limit + 2) { last = await req('POST', path, { body }); n++; }
    check(`${path}: 429 after exceeding limit ${limit}`, last.status === 429 && /quá nhiều/.test(last.data.message) && Number(last.headers.get('retry-after')) > 0, { n, status: last.status, data: last.data });
    if (path === '/auth/login') {
      r = await req('POST', '/auth/login', { body: { email: emailA, password: 'secret9' } });
      check('blocked => even correct credentials get 429', r.status === 429, r);
      r = await req('POST', '/auth/register', { body });
      check('counters are per route: register not blocked by login', r.status === 400, r);
    }
  }
  check('forgot-password limit stricter than login', limits['/auth/forgot-password'] < limits['/auth/login'], limits);
  r = await req('GET', '/me', { token: tA });
  check('authenticated routes not throttled (no rate-limit headers)', r.status === 200 && r.headers.get('x-ratelimit-limit') === null, [...r.headers]);
  r = await req('GET', '/health');
  check('health not throttled', r.status === 200, r);
  let wait = 0;
  for (const [path, body] of routes) wait = Math.max(wait, Number((await req('POST', path, { body })).headers.get('retry-after') ?? 0));
  console.log(`… chờ ${wait + 1}s hết khóa 429`);
  await sleep((wait + 1) * 1000);
  r = await req('POST', '/auth/login', { body: { email: emailA, password: 'secret9' } });
  check('after Retry-After: login works again', r.status === 200 && r.data.accessToken, r);
  r = await req('POST', '/auth/forgot-password', { body: { email: `ghost${S}@test.local` } });
  check('after Retry-After: forgot-password works again', r.status === 204, r);
}

console.log('\nMa trận test:');
for (const [name, m] of matrix) console.log(`  ${m.fail ? 'FAIL' : 'PASS'}  ${name}  (${m.pass}/${m.pass + m.fail})`);
console.log(`\nPASS ${pass}  FAIL ${fail}`);
if (fails.length) console.log('Failed:', fails);
process.exit(fail ? 1 : 0);
