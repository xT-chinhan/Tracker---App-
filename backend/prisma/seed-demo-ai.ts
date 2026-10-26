/**
 * Dữ liệu demo cho trợ lý AI — chạy SAU `npm run db:seed:demo`: npm run db:seed:demo:ai
 *
 * Không chèn tay vào bảng ai*: mọi thứ đi qua đúng service của backend (chat → nháp → xác nhận / sửa / "ý tôi là…" / 👍👎,
 * đọc ảnh, giao dịch tự ghi từ ngân hàng, chu trình học ban đêm, admin duyệt luật chung) nên luật / trí nhớ / ví dụ
 * sinh ra y như khi người dùng thật dùng app. Sau mỗi hội thoại, mốc thời gian được lùi về ngày tương ứng.
 *
 *  - demo@thuchi.vn (dùng model thật trên Ollama, cần Ollama đang chạy):
 *      · "cf …" xác nhận nhiều lần → luật riêng "cf → Ăn uống" bật.
 *      · "gửi mẹ …" AI đoán sai, user sửa thành Gia đình 3 lần → luật riêng bật; lần sau AI tự xếp đúng.
 *      · Đổi ví đoán sang MoMo 2 lần liên tiếp → trí nhớ ví mặc định = MoMo.
 *      · Một lần "ý tôi là…" sửa định tuyến, 👍 / 👎, một ảnh hóa đơn, 3 giao dịch tự ghi từ thông báo ngân hàng.
 *  - 6 user demo đồng ý góp ví dụ ẩn danh (LLM giả lập tất định) → chu trình học gom thành luật CHUNG chờ duyệt,
 *    admin duyệt 1 luật → chạy lại lần 2.
 */
import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { PrismaClient } from '@prisma/client';
import sharp from 'sharp';
import { AppModule } from '../src/app.module';
import { AiLlmFactory, AiService } from '../src/ai/ai.service';
import { AiLearningService } from '../src/ai/ai.learning';
import { AiAdminService } from '../src/ai/ai.admin';
import { FakeLlm } from '../src/ai/ai.llm';
import { TransactionsService } from '../src/transactions/transactions.module';
import { TransfersService } from '../src/transfers/transfers.module';
import { notifySecurity } from '../src/notifications/categories';
import type { Principal } from '../src/ai/ai.types';

const DAY = 86_400_000;
const prisma = new PrismaClient();

type P = Principal;
const principal = async (email: string): Promise<P> => {
  const u = await prisma.user.findUniqueOrThrow({ where: { email } });
  return { id: u.id, email: u.email, name: u.name, role: u.role };
};

/** Lùi mọi thứ của user tạo từ `since` (hội thoại, tin, nháp, phản hồi, giao dịch, thông báo) về `daysAgo` ngày trước. */
async function backdate(userId: string, since: Date, daysAgo: number, hour: number) {
  const base = new Date(Date.now() - daysAgo * DAY);
  const vn = new Date(base.getTime() + 7 * 3600_000);
  const target = new Date(Date.UTC(vn.getUTCFullYear(), vn.getUTCMonth(), vn.getUTCDate(), hour - 7, 0, 0));
  const shift = `${Math.round((Date.now() - target.getTime()) / 1000)} seconds`;
  // Ngày "hôm nay" trong nội dung trả lời / nháp → ngày đã lùi
  const iso = (d: Date) => new Date(d.getTime() + 7 * 3600_000).toISOString().slice(0, 10);
  const dm = (d: string) => `${d.slice(8, 10)}/${d.slice(5, 7)}`;
  const [today, then] = [iso(new Date()), iso(target)];
  if (today !== then) {
    await prisma.$executeRawUnsafe(`UPDATE "AiMessage" SET content = replace(content, $3, $4) WHERE "userId" = $1 AND "createdAt" >= $2`, userId, since, ` · ${dm(today)}`, ` · ${dm(then)}`);
    for (const col of ['payload', '"finalPayload"']) {
      await prisma.$executeRawUnsafe(`UPDATE "AiDraft" SET ${col} = replace(${col}::text, $3, $4)::jsonb WHERE "userId" = $1 AND "createdAt" >= $2 AND ${col} IS NOT NULL`, userId, since, today, then);
    }
  }
  const q = (sql: string) => prisma.$executeRawUnsafe(sql, userId, since, shift);
  await q(`UPDATE "AiMessage" SET "createdAt" = "createdAt" - $3::interval WHERE "userId" = $1 AND "createdAt" >= $2`);
  await q(`UPDATE "AiConversation" SET "createdAt" = "createdAt" - $3::interval, "updatedAt" = "updatedAt" - $3::interval WHERE "userId" = $1 AND "createdAt" >= $2`);
  await q(`UPDATE "AiDraft" SET "createdAt" = "createdAt" - $3::interval, "updatedAt" = "updatedAt" - $3::interval, "resolvedAt" = "resolvedAt" - $3::interval WHERE "userId" = $1 AND "createdAt" >= $2`);
  await q(`UPDATE "AiFeedback" SET "createdAt" = "createdAt" - $3::interval, "updatedAt" = "updatedAt" - $3::interval WHERE "userId" = $1 AND "createdAt" >= $2`);
  await q(`UPDATE "Transaction" SET "occurredAt" = "occurredAt" - $3::interval, "createdAt" = "createdAt" - $3::interval, "updatedAt" = "updatedAt" - $3::interval WHERE "userId" = $1 AND "createdAt" >= $2`);
  await q(`UPDATE "Notification" SET "createdAt" = "createdAt" - $3::interval, "readAt" = COALESCE("readAt", now() - $3::interval) WHERE "userId" = $1 AND "createdAt" >= $2`);
}

async function main() {
  const t0 = Date.now();
  process.env.AI_WARMUP = '0';
  const app = await NestFactory.createApplicationContext(AppModule, { logger: ['error', 'warn'] });
  const ai = app.get(AiService);
  const learning = app.get(AiLearningService);
  const admin = app.get(AiAdminService);
  const llms = app.get(AiLlmFactory);
  const txs = app.get(TransactionsService);
  const realGet = llms.get.bind(llms);
  const fake = new FakeLlm();

  const demo = await principal('demo@thuchi.vn');
  const adm = await principal('admin@thuchi.vn');
  const old = await prisma.aiConversation.count({ where: { userId: demo.id } });
  if (old) throw new Error('demo@thuchi.vn đã có hội thoại AI — chạy lại `npm run db:seed:demo` trước');
  // Dữ liệu học CHUNG cũ (sinh từ user demo đã bị xóa) + lịch sử chạy: làm lại từ đầu. Ví dụ seed hệ thống (userCount 0) giữ nguyên.
  await prisma.aiRule.deleteMany({ where: { scope: 'GLOBAL' } });
  await prisma.aiExample.deleteMany({ where: { scope: 'GLOBAL', userCount: { gt: 0 } } });
  await prisma.aiLearningRun.deleteMany({});

  /** Gửi 1 câu, trả về tin trả lời của trợ lý (kèm nháp nếu có). */
  const lastReply = (convId: string) => prisma.aiMessage.findFirstOrThrow({ where: { conversationId: convId, role: 'ASSISTANT' }, orderBy: { createdAt: 'desc' }, include: { draft: true } });
  /** Lỗi model (quá thời gian chờ) → xóa cặp tin lỗi rồi hỏi lại, tối đa 3 lần */
  const dropLastPair = async (convId: string) => {
    const two = await prisma.aiMessage.findMany({ where: { conversationId: convId }, orderBy: { createdAt: 'desc' }, take: 2, select: { id: true } });
    await prisma.aiMessage.deleteMany({ where: { id: { in: two.map((x) => x.id) } } });
  };
  const say = async (p: P, convId: string, text: string) => {
    for (let i = 0; ; i++) {
      await ai.post(p, convId, text);
      const m = await lastReply(convId);
      if (m.status !== 'error' || i === 2) return m;
      await dropLastPair(convId);
    }
  };
  const items = (d: any) => ((d?.payload as any)?.items ?? []) as any[];
  /** Xác nhận nháp; `patch(item)` trả bản sửa (null = giữ nguyên). */
  const resolve = async (p: P, m: Awaited<ReturnType<typeof say>>, patch?: (it: any) => Record<string, unknown> | null) => {
    if (!m.draft || m.draft.kind !== 'transactions') return 'no-draft';
    const its = items(m.draft);
    const edits = patch ? its.map((it) => patch(it)) : [];
    if (!edits.some(Boolean)) {
      await ai.confirm(p, m.draft.id);
      return 'confirmed';
    }
    const edited = { items: its.map((it, i) => ({ title: it.title, amount: it.amount, categoryId: it.categoryId, walletId: it.walletId, occurredAt: it.occurredAt, ...(it.note ? { note: it.note } : {}), ...(edits[i] ?? {}) })) };
    await ai.confirm(p, m.draft.id, edited);
    return 'edited';
  };

  const cats = await prisma.category.findMany({ where: { OR: [{ userId: null }, { userId: demo.id }] } });
  const cat = (name: string) => cats.find((c) => c.name === name)!.id;
  const wallets = await prisma.wallet.findMany({ where: { userId: demo.id } });
  const wal = (name: string) => wallets.find((w) => w.name === name)!.id;
  const log: string[] = [];
  // Nạp MoMo từ MB Bank trước khi bắt đầu dùng MoMo cho cà phê (ví MoMo của showcase vốn ít tiền)
  await app.get(TransfersService).create(demo.id, { fromWalletId: wal('MB Bank'), toWalletId: wal('MoMo'), amount: 500_000, occurredAt: new Date(Date.now() - 22 * DAY).toISOString(), note: 'Nạp MoMo' } as any);

  /* ======================= demo@thuchi.vn — model thật ======================= */
  llms.get = realGet;
  const llm = await realGet();
  if (llm.provider === 'ollama') {
    const ok = await fetch('http://localhost:11434/api/tags').then((r) => r.ok).catch(() => false);
    if (!ok) throw new Error('Ollama chưa chạy — cần model thật để tạo hội thoại demo');
    // nạp model vào GPU trước (câu đầu không bị quá thời gian chờ)
    await llm.embed(['khởi động']);
    await llm.chat([{ role: 'user', content: 'ok' }], { numPredict: 1 });
  }

  // Kịch bản: [ngày trước, giờ, tiêu đề hội thoại, các bước]
  type Step = { say: string; patch?: (it: any) => Record<string, unknown> | null; thumbs?: 1 | -1; reroute?: { unless: string; to: string } };
  const toFamily = (it: any) => (it.categoryId === cat('Gia đình') ? null : { categoryId: cat('Gia đình') });
  const cafe = (it: any) => (/ca phe/.test(it.title.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase()) ? null : { title: 'Cà phê' });
  const toMomo = (it: any) => (it.walletId === wal('MoMo') ? cafe(it) : { walletId: wal('MoMo'), ...cafe(it) });
  // Ví: lần đầu xác nhận Tiền mặt → AI nhớ Tiền mặt; 2 lần liền đổi cà phê sang MoMo → trí nhớ chuyển sang MoMo.
  // "gửi mẹ … qua MB Bank": câu đã nói ví nên không đụng trí nhớ ví; AI lúc đầu chưa biết "gửi mẹ" thuộc Gia đình hay không,
  // user xác nhận / sửa thành Gia đình → đủ 3 lần thì luật riêng bật.
  const plan: [number, number, string, Step[]][] = [
    [21, 12, 'Ghi chi tiêu', [{ say: 'trưa cơm 55k, gửi xe 5k' }]],
    [20, 8, 'Cà phê sáng', [{ say: 'cf 45k', patch: toMomo }]],
    [19, 8, 'Cà phê', [{ say: 'cf 39k', patch: toMomo }]],
    [17, 20, 'Gửi tiền nhà', [{ say: 'gửi mẹ 300k qua MB Bank', patch: toFamily }]],
    [14, 21, 'Gửi mẹ tiền chợ', [{ say: 'gửi mẹ 200k qua MB Bank', patch: toFamily }]],
    [12, 19, 'Hỏi ngân sách', [{ say: 'ăn uống tháng này còn bao nhiêu', reroute: { unless: 'kiem-tra-ngan-sach', to: 'kiem-tra-ngan-sach' }, thumbs: 1 }]],
    [10, 12, 'Ghi trưa', [{ say: 'cf 35k, grab 42k', patch: (it) => (/^c/i.test(it.title) ? cafe(it) : null) }]],
    [9, 20, 'Gửi mẹ', [{ say: 'gửi mẹ 250k qua MB Bank', patch: toFamily }]],
    [7, 21, 'Tổng kết', [{ say: 'tổng kết tháng này giúp mình', thumbs: 1 }, { say: 'mẹo tiết kiệm tiền cà phê', thumbs: -1 }]],
    [3, 8, 'Cà phê', [{ say: 'cf 45k', patch: cafe }]],
    [1, 20, 'Gửi mẹ', [{ say: 'gửi mẹ 300k qua MB Bank' }]],
  ];
  for (const [daysAgo, hour, title, steps] of plan) {
    const since = new Date();
    const conv = await ai.create(demo, title);
    for (const s of steps) {
      const m = await say(demo, conv.id, s.say);
      let outcome = await resolve(demo, m, s.patch);
      if (s.reroute && m.skill !== s.reroute.unless) {
        await ai.reroute(demo, m.id, s.reroute.to);
        outcome = `reroute ${m.skill} → ${s.reroute.to}`;
      }
      if (s.thumbs) {
        const last = await prisma.aiMessage.findFirstOrThrow({ where: { conversationId: conv.id, role: 'ASSISTANT' }, orderBy: { createdAt: 'desc' } });
        await ai.feedback(demo, last.id, { rating: s.thumbs });
      }
      const it = items(m.draft)[0];
      log.push(`  -${daysAgo}d "${s.say}" → ${m.skill}${it ? ` [${it.categoryName} · ${it.walletName}${it.ruleId ? ' · luật đã học' : ''}]` : ''} ${outcome}`);
    }
    await backdate(demo.id, since, daysAgo, hour);
  }

  // Đọc ảnh hóa đơn (vision thật)
  {
    const since = new Date();
    const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="560" height="760"><rect width="100%" height="100%" fill="#fbfaf6"/>
      <g font-family="DejaVu Sans Mono, monospace" fill="#111">
      <text x="280" y="70" font-size="30" font-weight="bold" text-anchor="middle">BÁCH HÓA XANH</text>
      <text x="280" y="105" font-size="18" text-anchor="middle">CN 312 Nguyễn Xí, Bình Thạnh</text>
      <text x="40" y="160" font-size="18">HÓA ĐƠN BÁN HÀNG  #BHX-48213</text>
      <text x="40" y="190" font-size="18">Ngày: ${new Date(Date.now() - 5 * DAY).toLocaleDateString('vi-VN')}  18:42</text>
      <line x1="40" y1="215" x2="520" y2="215" stroke="#111" stroke-dasharray="6 6"/>
      <text x="40" y="255" font-size="20">Sữa tươi Vinamilk 1L</text><text x="520" y="255" font-size="20" text-anchor="end">32.000</text>
      <text x="40" y="295" font-size="20">Trứng gà 10 quả</text><text x="520" y="295" font-size="20" text-anchor="end">35.000</text>
      <text x="40" y="335" font-size="20">Rau cải xanh 500g</text><text x="520" y="335" font-size="20" text-anchor="end">18.000</text>
      <text x="40" y="375" font-size="20">Thịt heo xay 300g</text><text x="520" y="375" font-size="20" text-anchor="end">40.000</text>
      <line x1="40" y1="410" x2="520" y2="410" stroke="#111" stroke-dasharray="6 6"/>
      <text x="40" y="460" font-size="26" font-weight="bold">TỔNG CỘNG</text><text x="520" y="460" font-size="26" font-weight="bold" text-anchor="end">125.000</text>
      <text x="40" y="505" font-size="18">Thanh toán: MB Bank (QR)</text>
      <text x="280" y="600" font-size="18" text-anchor="middle">Cảm ơn quý khách!</text></g></svg>`;
    const buffer = await sharp(Buffer.from(svg)).png().toBuffer();
    const conv = await ai.create(demo, 'Quét hóa đơn');
    try {
      let m = null as Awaited<ReturnType<typeof lastReply>> | null;
      for (let i = 0; i < 3; i++) {
        await ai.postImage(demo, conv.id, { buffer, mimetype: 'image/png', size: buffer.length });
        m = await lastReply(conv.id);
        if (m.status !== 'error') break;
        await dropLastPair(conv.id);
      }
      if (!m) throw new Error('không đọc được ảnh');
      const out = await resolve(demo, m, (it) => (it.walletId === wal('MB Bank') && it.categoryId === cat('Ăn uống') ? null : { walletId: wal('MB Bank'), categoryId: cat('Ăn uống') }));
      log.push(`  -5d [ảnh hóa đơn] → ${m.skill} ${JSON.stringify(items(m.draft).map((i) => `${i.title} ${i.amount}`))} ${out}`);
    } catch (e) {
      log.push(`  -5d [ảnh hóa đơn] lỗi: ${(e as Error).message}`);
    }
    await backdate(demo.id, since, 5, 18);
  }

  /* ======================= thông báo ngân hàng tự ghi + bảo mật ======================= */
  const bank: [number, number, Parameters<TransactionsService['create']>[1]][] = [
    [6, 10, { categoryId: cat('Thu khác'), walletId: wal('Techcombank'), amount: 1_200_000, title: 'Nhận tiền', note: 'Từ thông báo Techcombank · TRAN THI HOA chuyen tien', source: 'bank_auto', externalRef: 'tcb:demo-6d-1200000' } as any],
    [4, 12, { categoryId: cat('Ăn uống'), walletId: wal('MB Bank'), amount: 350_000, title: 'Bách Hóa Xanh', note: 'Từ thông báo MB Bank · TT BACH HOA XANH', source: 'bank_auto', externalRef: 'mb:demo-4d-350000' } as any],
    [0, 8, { categoryId: cat('Ăn uống'), walletId: wal('MB Bank'), amount: 45_000, title: 'Cà phê', note: 'Từ thông báo MB Bank · HIGHLANDS COFFEE', source: 'bank_auto', externalRef: 'mb:demo-0d-45000' } as any],
  ];
  for (const [daysAgo, hour, dto] of bank) {
    const since = new Date();
    await txs.create(demo.id, dto);
    if (daysAgo) await backdate(demo.id, since, daysAgo, hour);
  }
  {
    const since = new Date();
    await notifySecurity(prisma, demo.id, 'Đã đổi mật khẩu', 'Mọi thiết bị khác đã được đăng xuất. Không phải bạn? Đặt lại mật khẩu ngay bằng email.');
    await backdate(demo.id, since, 11, 22);
  }
  // giữ đúng 1 thông báo mới (biến động số dư hôm nay) chưa đọc trong số thông báo do script tạo
  const keep = await prisma.notification.findFirst({ where: { userId: demo.id, type: 'BALANCE_CHANGE' }, orderBy: { createdAt: 'desc' } });
  await prisma.notification.updateMany({ where: { userId: demo.id, createdAt: { gte: new Date(t0) }, readAt: null, NOT: { id: keep?.id } }, data: { readAt: new Date() } });
  // tổng chưa đọc giữ như trước khi chạy script: đổi 1 thông báo ngân sách cũ nhất chưa đọc sang đã đọc
  if (keep) {
    const oldest = await prisma.notification.findFirst({ where: { userId: demo.id, readAt: null, type: { in: ['BUDGET_WARNING', 'BUDGET_EXCEEDED'] } }, orderBy: { createdAt: 'asc' } });
    if (oldest) await prisma.notification.update({ where: { id: oldest.id }, data: { readAt: new Date() } });
  }
  await prisma.aiUserSetting.upsert({ where: { userId: demo.id }, create: { userId: demo.id, shareExamples: true, consentedAt: new Date(Date.now() - 20 * DAY) }, update: {} });

  /* ======================= 6 user góp ví dụ ẩn danh — LLM giả lập ======================= */
  llms.get = async () => fake;
  const contributors = await prisma.user.findMany({ where: { email: { endsWith: '@demo.thuchi.vn' }, role: 'USER', status: 'ACTIVE' }, orderBy: { email: 'asc' }, take: 6 });
  const habits = ['cf 30k', 'cf 45k', 'cf 39k', 'grab 42k', 'grab 38k', 'grab 55k', 'trà sữa 35k', 'trà sữa 40k', 'trà sữa 32k'];
  for (const [k, u] of contributors.entries()) {
    const p: P = { id: u.id, email: u.email, name: u.name, role: u.role };
    await ai.setSettings(p, true);
    const since = new Date();
    const conv = await ai.create(p, 'Ghi chi tiêu');
    for (const h of habits) await resolve(p, await say(p, conv.id, h));
    await backdate(u.id, since, 8 + k, 9);
  }

  /* ======================= chu trình học ban đêm + admin duyệt ======================= */
  const run1 = await learning.run('manual');
  const firstProposed = await prisma.aiRule.findFirst({ where: { scope: 'GLOBAL', status: 'PROPOSED' }, orderBy: { userCount: 'desc' } });
  if (firstProposed) await admin.decideRule({ id: adm.id, email: adm.email, role: adm.role } as any, firstProposed.id, true);
  const run2 = await learning.run('cron');
  const runs = await prisma.aiLearningRun.findMany({ orderBy: { startedAt: 'asc' } });
  // lần 1 coi như đêm 3 ngày trước, lần 2 đêm qua (02:30 giờ VN)
  const night = (daysAgo: number) => {
    const vn = new Date(Date.now() + 7 * 3600_000 - daysAgo * DAY);
    return new Date(Date.UTC(vn.getUTCFullYear(), vn.getUTCMonth(), vn.getUTCDate(), 2 - 7, 30));
  };
  for (const [i, r] of runs.slice(-2).entries()) {
    const s = night(i === 0 ? 3 : 0);
    await prisma.aiLearningRun.update({ where: { id: r.id }, data: { startedAt: s, finishedAt: new Date(s.getTime() + 4000) } });
  }
  if (firstProposed) await prisma.aiRule.update({ where: { id: firstProposed.id }, data: { approvedAt: night(2) } });

  /* ======================= tóm tắt ======================= */
  const rules = await prisma.aiRule.findMany({ where: { userId: demo.id }, select: { pattern: true, value: true, support: true, status: true }, orderBy: { status: 'asc' } });
  const mem = await prisma.aiMemory.findMany({ where: { userId: demo.id }, select: { key: true, value: true, helpful: true, harmful: true } });
  const global = await prisma.aiRule.findMany({ where: { scope: 'GLOBAL' }, select: { pattern: true, value: true, userCount: true, status: true } });
  console.log(log.join('\n'));
  console.log('Luật riêng demo@thuchi.vn:', rules);
  console.log('Trí nhớ:', mem);
  console.log('Học ban đêm:', JSON.stringify(run1), JSON.stringify(run2));
  console.log('Luật chung:', global);
  console.log(`Xong sau ${Math.round((Date.now() - t0) / 1000)}s`);
  await app.close();
}

main()
  .catch((e) => {
    console.error(e);
    process.exitCode = 1;
  })
  .finally(() => prisma.$disconnect());
