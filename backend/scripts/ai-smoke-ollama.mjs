// Smoke test trợ lý AI với Ollama THẬT: 5 hội thoại end-to-end (route → skill → LLM → nháp → xác nhận), in độ trễ.
// Lưu ý: xác nhận nháp tạo giao dịch THẬT cho USER_EMAIL — chạy trên DB dev/test, không chạy trên dữ liệu thật.
// Server phải chạy với AI_PROVIDER=ollama (vd: AI_PROVIDER=ollama NODE_ENV=test node dist/main).
// Máy chỉ 1 GPU: bọc bằng khóa  flock /tmp/app-tracker-gpu.lock node scripts/ai-smoke-ollama.mjs
//   API_URL (mặc định http://localhost:3000/api), USER_EMAIL/USER_PASSWORD (demo@thuchi.vn/demo123), ADMIN_EMAIL/ADMIN_PASSWORD
const BASE = process.env.API_URL ?? 'http://localhost:3000/api';
const req = async (method, path, token, body) => {
  const t = performance.now();
  const r = await fetch(BASE + path, { method, headers: { 'content-type': 'application/json', ...(token ? { authorization: `Bearer ${token}` } : {}) }, body: body ? JSON.stringify(body) : undefined });
  const text = await r.text();
  let data; try { data = JSON.parse(text); } catch { data = text; }
  return { status: r.status, data, ms: Math.round(performance.now() - t) };
};
const login = async (email, password) => (await req('POST', '/auth/login', null, { email, password })).data.accessToken;
const user = await login(process.env.USER_EMAIL ?? 'demo@thuchi.vn', process.env.USER_PASSWORD ?? 'demo123');
const admin = await login(process.env.ADMIN_EMAIL ?? 'admin@thuchi.vn', process.env.ADMIN_PASSWORD ?? 'admin123');

const CONVS = [
  { who: 'user', title: 'Ghi nhiều khoản', turns: ['cà phê 45k với bánh mì 20k sáng nay', 'hôm qua đổ xăng 80k trả momo'], confirm: true },
  { who: 'user', title: 'Tổng kết + gợi ý (Track B)', turns: ['tuần này tiêu hết bao nhiêu', 'gợi ý ngân sách tháng sau', 'mẹo tiết kiệm cho mình với'] },
  { who: 'user', title: 'Tìm + hỏi đáp (Track B)', turns: ['tìm các khoản ăn uống trên 100k tháng này', 'mình còn bao nhiêu tiền', 'ngân sách tháng này thế nào'], confirm: true },
  { who: 'user', title: 'Mơ hồ / ngoài phạm vi', turns: ['ừ', 'thời tiết hôm nay thế nào', 'mua giày 1tr2 shopee'] },
  { who: 'admin', title: 'Admin (Track B)', turns: ['tổng quan hệ thống', 'có tài khoản nào bất thường không', 'soạn thông báo bảo trì hệ thống tối nay lúc 23h'] },
];

// Khởi động: lần đầu backend nhúng (bge-m3) câu mẫu router + kho ví dụ chung và nạp model vào GPU — đo riêng
{
  const conv = (await req('POST', '/ai/conversations', user, { title: '[smoke] warm-up' })).data;
  const w = await req('POST', `/ai/conversations/${conv.id}/messages`, user, { text: 'trà sữa 30k' });
  console.log(`warm-up (nhúng kho câu mẫu + nạp model): ${w.ms}ms, skill ${w.data.message?.skill}`);
  await req('DELETE', `/ai/conversations/${conv.id}`, user);
}

const rows = [];
let fails = 0;
for (const c of CONVS) {
  const token = c.who === 'admin' ? admin : user;
  const conv = (await req('POST', '/ai/conversations', token, { title: `[smoke] ${c.title}` })).data;
  for (const text of c.turns) {
    const r = await req('POST', `/ai/conversations/${conv.id}/messages`, token, { text });
    const m = r.data.message ?? {};
    const ok = r.status === 201 && m.status !== 'error';
    if (!ok) fails++;
    rows.push({ conv: c.title, text, status: r.status, skill: m.skill, by: m.routeBy, msgStatus: m.status, serverMs: m.latencyMs, httpMs: r.ms, tokens: m.tokens ? `${m.tokens.prompt}/${m.tokens.eval}` : '', draft: r.data.draft ? r.data.draft.payload.items?.map((i) => `${i.title}|${i.amount}|${i.categoryName}|${i.walletName}`).join('; ') ?? `${r.data.draft.kind} ${JSON.stringify(r.data.draft.payload).slice(0, 120)}` : '', reply: (m.content ?? '').replace(/\n/g, ' ⏎ ').slice(0, 160) });
    if (c.confirm && r.data.draft) {
      const k = await req('POST', `/ai/drafts/${r.data.draft.id}/confirm`, token, {});
      if (k.status !== 200) fails++;
      rows.push({ conv: c.title, text: '  ↳ xác nhận', status: k.status, skill: '', by: '', msgStatus: k.data.draft?.status, serverMs: '', httpMs: k.ms, tokens: '', draft: JSON.stringify(k.data.result) });
    }
  }
  await req('DELETE', `/ai/conversations/${conv.id}`, token);
}

const cols = ['conv', 'text', 'status', 'skill', 'by', 'msgStatus', 'serverMs', 'httpMs', 'tokens', 'draft', 'reply'];
console.log(cols.join(' | '));
for (const r of rows) console.log(cols.map((k) => String(r[k] ?? '')).join(' | '));
const lat = rows.filter((r) => typeof r.serverMs === 'number').map((r) => r.serverMs).sort((a, b) => a - b);
const p = (q) => lat[Math.min(lat.length - 1, Math.floor(q * lat.length))];
const llm = rows.filter((r) => r.tokens).map((r) => r.serverMs).sort((a, b) => a - b);
console.log(`\n${lat.length} tin, độ trễ server p50 ${p(0.5)}ms, p95 ${p(0.95)}ms, max ${lat.at(-1)}ms; tin có gọi LLM p50 ${llm[Math.floor(llm.length / 2)]}ms; lỗi ${fails}`);
process.exit(fails ? 1 : 0);
