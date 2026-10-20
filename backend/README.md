# Backend API — TrackerX

NestJS 11 + Prisma 6 + PostgreSQL 16. Mỗi module một file `src/<module>/<module>.module.ts` (DTO + service + controller). Dùng chung: `src/common/` (auth guard JWT, DTO, giờ VN, filter lỗi Prisma), `src/prisma/`. Tiền lưu `BigInt` (VND), trả ra JSON dạng number. Cron (`@nestjs/schedule`) sinh giao dịch định kỳ. Rate limit các route đăng nhập/đăng ký/OTP bằng `@nestjs/throttler`.

> Cách nhanh nhất: ở thư mục gốc chạy `npm run setup` rồi `npm run dev` (xem [README gốc](../README.md)). Phần dưới là chạy riêng backend.

## Chạy riêng

```bash
docker compose up -d db         # (ở thư mục gốc) Postgres ở localhost:5433
cd backend
npm i
cp .env.example .env
npx prisma migrate deploy
npm run db:seed                 # 14 danh mục hệ thống + admin (ADMIN_EMAIL / ADMIN_PASSWORD trong .env)
npm run db:seed:demo            # (tùy chọn) ~40 user demo, 12 tháng dữ liệu
npm run dev                     # http://localhost:3000/api
```

- Swagger UI: http://localhost:3000/docs — OpenAPI JSON: http://localhost:3000/docs/openapi.json
- Health: `GET /api/health` (công khai) → `{status, db, version}`; DB không kết nối được → 503.
- Gửi OTP quên mật khẩu qua SMTP (`SMTP_*` trong `.env`). Bỏ trống `SMTP_HOST` thì OTP được in ra log server.

| Script | Việc |
|---|---|
| `npm run dev` / `build` / `start` | Dev (watch) / build ra `dist/` / chạy bản build |
| `npm run db:deploy` / `db:migrate` | `prisma migrate deploy` / `migrate dev` |
| `npm run db:seed` | Danh mục hệ thống + admin từ `ADMIN_*` (idempotent) |
| `npm run db:seed:demo` | Dữ liệu demo (idempotent, xem dưới) |
| `npm run demo:verify` | Kiểm tra bất biến dữ liệu demo qua API đang chạy (`API_URL`, mặc định `http://localhost:3000/api`) |
| `npm run test:e2e` | E2E toàn bộ API (xem dưới) |

### Biến môi trường (`backend/.env`)

| Biến | Mặc định | Ý nghĩa |
|---|---|---|
| `DATABASE_URL` | — | PostgreSQL |
| `PORT` | 3000 | |
| `JWT_SECRET` | — | Bắt buộc; `NODE_ENV=production` thì phải ≥ 16 ký tự (không thì API không khởi động) |
| `JWT_EXPIRES_IN` | 30d | |
| `CORS_ORIGINS` | — | Danh sách origin, phân cách bằng dấu phẩy (dev admin: `http://localhost:5173`) |
| `ADMIN_EMAIL` / `ADMIN_PASSWORD` | — | Seed tạo/nâng quyền admin này (bỏ trống = không tạo) |
| `NODE_ENV` | — | `production`: tắt các endpoint run-due (404). `test`: nới rate limit cho e2e |
| `SMTP_HOST` `SMTP_PORT` `SMTP_SECURE` `SMTP_USER` `SMTP_PASS` `SMTP_FROM` | | Gửi OTP; `SMTP_HOST` trống → OTP ra log |
| `THROTTLE_TTL_SEC` | 60 (test: 10) | Cửa sổ rate limit (giây) |
| `THROTTLE_AUTH_LIMIT` | 10 (test: 200) | Số request / cửa sổ / IP cho mỗi route login, register, reset-password |
| `THROTTLE_FORGOT_LIMIT` | 3 (test: 20) | Như trên cho forgot-password |
| `TRUST_PROXY` | — | Chạy sau reverse proxy: `1` (số hop), `true` hoặc danh sách IP, để rate limit đếm theo IP thật |
| `AI_PROVIDER` | — | `ollama` \| `fake`: ghi đè `ai.provider` của Cấu hình hệ thống. Không đặt + `NODE_ENV=test` → `fake` |
| `OLLAMA_URL` / `AI_CHAT_MODEL` / `AI_EMBED_MODEL` | `http://localhost:11434` / `qwen3.5:4b` / `bge-m3` | Mặc định cho mục `ai` của Cấu hình hệ thống |
| `AI_DIR` | `<repo>/ai` | Thư mục `ai/` (parser, prompt, skill ngoài) nạp lúc chạy bằng `tsx` |
| `AI_EXTERNAL_SKILLS` | 1 | `0` = không nạp skill từ `ai/skills/*` (chỉ built-in) |
| `CONFIG_SECRET` | (dẫn xuất từ `JWT_SECRET`) | Khóa mã hóa AES-256-GCM cho giá trị bí mật trong Cấu hình hệ thống (mật khẩu SMTP). Đổi khóa thì mật khẩu SMTP đã lưu không giải mã được, phải nhập lại |

Các giá trị `SMTP_*`, `JWT_EXPIRES_IN`, `THROTTLE_AUTH_LIMIT` là **mặc định** cho Cấu hình hệ thống: chưa có admin sửa thì hệ thống chạy đúng như env (xem mục Cấu hình hệ thống bên dưới).

## Dữ liệu demo (`prisma/seed-demo.ts`)

`npm run db:seed:demo` (cần chạy `db:seed` trước), ~5 giây. Chạy lại bao nhiêu lần cũng được: chỉ xóa và tạo lại user có email `@demo.thuchi.vn` + `demo@thuchi.vn` cùng 3 broadcast demo (id cố định); user thật không bị đụng tới. `admin@thuchi.vn` / `admin123` được tạo nếu chưa có (đã có thì giữ mật khẩu).

- 40 user tên Việt (6 kiểu: văn phòng, thu nhập cao, sinh viên, freelancer, gia đình có con, bán hàng online), đăng ký rải 12 tháng (gần đây nhiều hơn), 3 user bị khóa, 1 admin demo. Mật khẩu chung `demo123`.
- Mỗi user 2–4 ví (Tiền mặt, MB Bank, Techcombank, Vietcombank…, MoMo / ZaloPay / ShopeePay), ~1.000 giao dịch trong 12 tháng: lương ngày cố định, tiền nhà, điện nước, cà phê/ăn trưa, Grab, Shopee, cuối tuần, Tết, mua lớn, thưởng; danh mục riêng; chuyển tiền giữa ví (rút ATM, nạp ví); ngân sách 3 tháng gần nhất (tổng + danh mục, có cảnh báo / vượt); mục tiêu tiết kiệm đủ 4 trạng thái; giao dịch định kỳ (đang chạy, tạm dừng, hết hạn, bị dừng do ví lưu trữ); mẫu nhập nhanh; thông báo.
- `demo@thuchi.vn` / `demo123` (Nguyễn Minh Anh) khớp mockup mobile: 4 ví tổng 26.022.000đ (MB Bank 18.672.000đ), chi tháng này ~60% ngân sách 14 triệu, mẫu Cà phê 45k / Cơm trưa 55k / Grab 38k / Gửi xe 5k, 3 mục tiêu (52,2 triệu), 5 định kỳ, 2 thông báo chưa đọc.
- Giữ mọi bất biến nhờ **mô phỏng theo thời gian**: chuyển tiền / nạp tiết kiệm chỉ xảy ra khi ví đủ tiền lúc đó (ví thiếu thì có giao dịch "Rút tiền mặt ATM" / "Nạp ví MoMo" ngay trước), `savedAmount` = nạp − rút, trạng thái mục tiêu suy ra từ sổ, `warnedAt`/`exceededAt` + thông báo sinh đúng như `checkThresholds` theo thứ tự tạo giao dịch, giao dịch định kỳ sinh bằng `occurrence()` của backend (unique `ruleId + scheduledFor`, `nextRunAt` > hiện tại), giờ theo giờ VN, không có phát sinh ở tương lai.
- `npm run demo:verify` đăng nhập admin + 6 user qua API thật, phát lại toàn bộ sổ theo thời gian (không ví nào từng âm, số dư khớp API), kiểm tra mục tiêu, ngân sách, định kỳ, thống kê, báo cáo, admin overview (564 kiểm tra).

## Docker

Xem [README gốc](../README.md#triển-khai-bằng-docker). Image `backend/Dockerfile` (build context = gốc repo, kèm `ai/`): multi-stage node 22-alpine, `prisma generate` lúc build, seed + seed demo biên dịch sẵn ra JS (`seed-dist/`). Khi khởi động: chờ DB (tối đa ~30s) → `prisma migrate deploy` → seed (danh mục hệ thống + admin nếu có `ADMIN_*`) → nếu `SEED_DEMO=true` thì nạp lại dữ liệu demo → `node dist/main`. Trong container: `npm run db:seed:demo` chạy bản JS. Có `HEALTHCHECK` gọi `/api/health`.

## E2E

Cách nhanh: ở thư mục gốc `npm run test` (tự tạo DB test có dữ liệu demo, bật/tắt server). Chạy tay: server phải chạy với `NODE_ENV=test` (bật endpoint run-due và nới rate limit: cửa sổ 10s, 200 req/route, forgot 20), log ghi ra file để script đọc OTP:

```bash
npm run build && NODE_ENV=test node dist/main > /tmp/tracker-api.log 2>&1 &
npm run test:e2e              # API_URL=http://host:port/api  API_LOG=/đường/dẫn/log  ADMIN_EMAIL / ADMIN_PASSWORD (mặc định admin@thuchi.vn / admin123)
```

- 940 kiểm tra (708 cũ + 232 của trợ lý AI ở `scripts/e2e-ai.mjs`, provider FAKE). Email ngẫu nhiên nên chạy lặp được không cần reset DB, kể cả DB đã có dữ liệu demo. Mất khoảng 2 phút: 1 lần chờ 61s (giới hạn gửi lại OTP), ~31s (chờ gửi lại OTP theo cấu hình) và ~11s chờ hết khóa 429 ở cuối.
- Nhóm `config:` sửa Cấu hình hệ thống (đủ mọi trường, bảo trì tự tắt theo giờ, máy chủ SMTP giả trong script) rồi khôi phục giá trị ban đầu ở cuối nhóm, kể cả khi lỗi.
- Có thể chạy server với `TZ=UTC` để chắc chắn không phụ thuộc múi giờ máy chủ (`npm run test` chạy như vậy).
- In ra ma trận test theo nhóm; exit code 1 nếu có lỗi.
- Chỉ nhóm AI (nhanh, ~15s): `API_URL=… node scripts/e2e-ai.mjs`. Smoke với Ollama thật (5 hội thoại, in độ trễ; xác nhận nháp tạo giao dịch thật nên chỉ chạy trên DB dev): chạy server với `AI_PROVIDER=ollama` rồi `flock /tmp/app-tracker-gpu.lock node scripts/ai-smoke-ollama.mjs`.

## Endpoint (prefix `/api`; trừ register / login / forgot / reset / health, còn lại đều cần `Authorization: Bearer <token>`)

Quy ước lỗi: id trên **đường dẫn** thuộc user khác → 404 (không lộ sự tồn tại); id tham chiếu trong **body** (ví, danh mục) không thuộc user → 400; route admin với user thường → 403; token cũ/hết hiệu lực → 401; tài khoản bị khóa → 403; vượt rate limit → 429 (kèm `Retry-After`).

| Module | Method | Path | Mô tả |
|---|---|---|---|
| health | GET | `/health` | Công khai: `{status, db, version}`, DB lỗi → 503 |
| config | GET | `/config/public` | Công khai (cả khi bảo trì): cấu hình app đọc khi khởi động, xem mục Cấu hình hệ thống |
| auth | POST | `/auth/register` | Đăng ký, tự tạo ví mặc định (tên theo cấu hình, mặc định "Tiền mặt"); tắt đăng ký → 403 `REGISTRATION_DISABLED` (rate limit) |
| | POST | `/auth/login` | Đăng nhập (tài khoản khóa → 403; bảo trì → user thường 503; rate limit theo IP + theo email) |
| | POST | `/auth/forgot-password` | Luôn 204; gửi OTP 6 số nếu email tồn tại (rate limit chặt hơn) |
| | POST | `/auth/reset-password` | `{email, otp, newPassword}`; mọi phiên cũ hết hiệu lực (rate limit) |
| | POST | `/auth/logout-all` | 204; đăng xuất mọi thiết bị, kể cả token đang dùng |
| | GET / PATCH | `/me` | Xem / đổi tên |
| | DELETE | `/me` | `{password}`: xóa tài khoản và toàn bộ dữ liệu |
| | POST | `/me/password` | Đổi mật khẩu → 200 `{accessToken, user}`; token cũ ở mọi thiết bị hết hiệu lực |
| wallets | GET | `/wallets` | Mọi ví kèm `balance` + `totalBalance` |
| | GET / POST / PATCH / DELETE | `/wallets[/:id]` | Xóa: chưa phát sinh → xóa hẳn; có phát sinh → lưu trữ (số dư phải = 0) |
| | POST | `/wallets/:id/restore` | Khôi phục ví đã lưu trữ |
| categories | GET | `/categories?type=` | Danh mục hệ thống + của mình (xếp theo tiếng Việt) |
| | POST / PATCH / DELETE | `/categories[/:id]` | Xóa danh mục đã dùng → lưu trữ |
| transactions | GET | `/transactions?month=&from=&to=&type=&categoryId=&walletId=&q=&minAmount=&maxAmount=&page=&limit=` | Có cờ `recurring` |
| | GET / PATCH / DELETE | `/transactions/:id` | |
| | POST | `/transactions` | `walletId` bắt buộc |
| | POST | `/transactions/bulk` | 1–100 giao dịch, tất cả hoặc không |
| transfers | GET | `/transfers?month=&from=&to=&walletId=&page=&limit=` | |
| | GET / POST / PATCH / DELETE | `/transfers[/:id]` | Chuyển tiền giữa 2 ví |
| budgets | GET | `/budgets?month=YYYY-MM` | `overall` (ngân sách tổng) + `items` theo danh mục |
| | POST / PATCH / DELETE | `/budgets[/:id]` | Bỏ trống `categoryId` → ngân sách tổng |
| | POST | `/budgets/copy` | `fromMonth` → `toMonth` |
| saving-goals | GET | `/saving-goals?status=` | |
| | GET / POST / PATCH / DELETE | `/saving-goals[/:id]` | Chi tiết kèm sổ nạp/rút |
| | POST | `/saving-goals/:id/deposit` | `{amount, walletId, date?}` |
| | POST | `/saving-goals/:id/withdraw` | `{walletId}` nhận tiền |
| quick-templates | GET / POST / PATCH / DELETE | `/quick-templates[/:id]` | Mẫu nhập nhanh |
| | POST | `/quick-templates/:id/use` | `{occurredAt?, amount?}` → tạo giao dịch thật |
| recurring | GET / POST / PATCH / DELETE | `/recurring[/:id]` | Giao dịch định kỳ |
| | POST | `/recurring/:id/pause`, `/recurring/:id/resume` | |
| | GET | `/recurring/:id/preview?count=5` | Các kỳ sắp chạy |
| | POST | `/recurring/run-due?now=ISO` | Chỉ dev/test (`NODE_ENV` khác `production`): chạy ngay các kỳ đến hạn của user hiện tại |
| notifications | GET | `/notifications?unread=&page=&limit=` | |
| | GET | `/notifications/unread-count` | |
| | POST | `/notifications/:id/read`, `/notifications/read-all` | |
| stats | GET | `/stats/balance` | Tổng + từng ví |
| | GET | `/stats/summary?month=\|from=&to=&walletId=` | Thu/chi + số dư (của ví nếu lọc) |
| | GET | `/stats/by-category?month=&type=&walletId=` | |
| | GET | `/stats/daily?month=&walletId=` | |
| | GET | `/stats/trend?month=&months=&walletId=` | |
| | GET | `/stats/report?month=&observationMonths=&walletId=` | Báo cáo tháng |
| export | GET | `/export/transactions.csv?month=\|from=&to=&walletId=` | CSV UTF-8 BOM, stream theo lô 1000 dòng |
| admin (role ADMIN) | GET | `/admin/overview` | |
| | GET | `/admin/users?q=&status=&role=&page=&limit=` | |
| | GET / PATCH | `/admin/users/:id` | Chi tiết + tài chính + ví; khóa/mở, đổi quyền. Khóa → mọi token của user hết hiệu lực |
| | POST | `/admin/recurring/run-due?now=ISO` | Chỉ dev/test (`production` → 404): chạy đúng đường của cron cho mọi user tới mốc `now` |
| | GET | `/admin/transactions?userId=&walletId=&...` | Kèm user + ví |
| | GET / POST | `/admin/broadcasts` | Lịch sử (số người nhận / đã đọc) / gửi cho mọi user ACTIVE |
| | GET / POST / PATCH / DELETE | `/admin/categories[/:id]` | Danh mục hệ thống |
| | POST | `/admin/categories/:id/restore` | |
| | GET / PATCH | `/admin/config` | Mọi cấu hình theo mục / sửa một phần (kiểm tra hợp lệ, lỗi → 400 `{errors: {"mục.trường": "lý do"}}`), trả trạng thái mới |
| | GET | `/admin/config/history?section=&page=&limit=` | Lịch sử thay đổi (mỗi trường một dòng, bí mật hiện `••••`) |
| | POST | `/admin/config/maintenance` | `{enabled, message?, endsAt?}` bật/tắt bảo trì ngay |
| | POST | `/admin/config/smtp/test` | Gửi email thử tới email admin bằng cấu hình đã lưu → `{ok, response \| error, durationMs}` (5 lần/phút) |
| ai (USER + ADMIN, tính năng `ai`) | GET / POST | `/ai/conversations` | Hội thoại của chính mình (`?archived=true`) / tạo (phạm vi USER/ADMIN theo role; quá hạn → 409 `AI_CONVERSATION_LIMIT`) |
| | GET / PATCH / DELETE | `/ai/conversations/:id` | Chi tiết + tin nhắn + nháp / đổi tên, lưu trữ, ghim (`pinned`) / xóa |
| | POST | `/ai/conversations/:id/messages` | `{text}` → `{userMessage, message, draft}`; quá hạn mức ngày → 429 `AI_DAILY_LIMIT` + `Retry-After` |
| | POST | `/ai/conversations/:id/messages/stream` | Như trên, Server-Sent Events: `user` → `route` → `delta`… → `done` \| `error` |
| | POST | `/ai/drafts/:id/confirm` | `{payload?}` (bản sửa) → thực thi qua service nghiệp vụ → `{draft, result, idempotent}` |
| | POST | `/ai/drafts/:id/cancel` | Hủy nháp (lặp lại → `idempotent: true`; đã xác nhận → 409) |
| | POST | `/ai/messages/:id/feedback` | `{rating: 1 \| -1, comment?}` |
| | POST | `/ai/messages/:id/reroute` | `{skill}` "ý tôi là…": trả lời lại câu trước bằng skill đó + học định tuyến (skill admin với USER → 403) |
| | GET | `/ai/skills`, `/ai/usage` | Skill dùng được / số tin hôm nay + hạn mức |
| | GET / PUT | `/ai/settings` | `{shareExamples, consentedAt, asked}` — đồng ý góp ví dụ ẩn danh vào kho chung (bật/tắt) |
| | GET / DELETE | `/ai/memory[/:id]` | Trí nhớ AI về chính mình |
| admin ai (ADMIN) | GET | `/admin/ai/stats?days=` | Theo skill: số tin, độ trễ avg/p50/p95, lỗi, nháp, tỉ lệ chấp nhận không sửa, 👍/👎, reroute; theo ngày |
| | GET / POST | `/admin/ai/rules`, `/admin/ai/rules/:id/approve\|reject` | Luật CHUNG (lọc `status`, `q`) / duyệt |
| | GET / POST | `/admin/ai/examples`, `/admin/ai/examples/:id/approve\|reject` | Ví dụ CHUNG đã ẩn danh / duyệt |
| | POST / GET | `/admin/ai/learning/run`, `/admin/ai/learning/runs` | Chạy ngay chu trình học (production → 404) / lịch sử |
| | GET | `/admin/ai/usage?q=`, `/admin/ai/usage/:userId` | Mức dùng theo user — chỉ số đếm, không nội dung |
| | GET | `/admin/ai/integrity` | Bất biến: dữ liệu chung không gắn userId |
| | POST | `/admin/ai/retention/run?now=` | Dev/test (production → 404): chạy ngay dọn lịch sử chat > 12 tháng |

## Nghiệp vụ v1

- **Múi giờ**: mọi nhóm theo ngày/tháng dùng Asia/Ho_Chi_Minh (UTC+7). `month=YYYY-MM`; `from` tính bao gồm, `to` không bao gồm, `from` phải trước `to`.
  - Ngày giờ client gửi lên không kèm múi giờ (`2026-09-01`, `2026-09-01T08:00`) được hiểu là giờ VN, không phụ thuộc TZ của máy chủ. Ngày ngoài năm 2000 – 2099 → 400.
- **Phân trang**: `page` 1 – 10000, `limit` 1 – 200.
- **Số tiền**: số nguyên 1 – 10 nghìn tỷ mỗi giao dịch / hạn mức / mục tiêu (số dư ban đầu 0 – 10 nghìn tỷ).
- **Ví**: loại CASH / BANK / EWALLET, `initialBalance` ≥ 0. Số dư ví = ban đầu + thu − chi + chuyển vào − chuyển ra − nạp tiết kiệm + rút tiết kiệm, luôn tính từ dữ liệu, không lưu cộng dồn. Số dư tổng = tổng các ví.
  - Phát sinh gồm giao dịch, chuyển tiền, sổ tiết kiệm và giao dịch định kỳ. Xóa ví chưa có phát sinh thì xóa hẳn, mẫu nhập nhanh dùng ví đó bị xóa theo. Ví có phát sinh chỉ lưu trữ được khi số dư = 0, ngược lại trả 409.
  - Ví lưu trữ không dùng được cho phát sinh mới, và phát sinh cũ của nó không sửa/xóa được cho tới khi khôi phục ví.
- **Giao dịch**: bắt buộc ví và danh mục của user, chưa lưu trữ. Loại INCOME/EXPENSE lấy theo danh mục. Mọi đường tạo giao dịch (API, bulk, mẫu nhập nhanh, định kỳ) đều chạy cùng logic, kể cả cảnh báo ngân sách.
- **Chuyển tiền**: 2 ví khác nhau của cùng user. Tạo / sửa / xóa không được làm ví nào bị trừ xuống dưới 0: hoàn tác giao dịch cũ rồi áp giao dịch mới, ví bị giảm tiền phải còn đủ (vd xóa A→B khi B đã chuyển tiếp số tiền đó đi → 400). Số dư không phụ thuộc ngày nên đổi ngày/ghi chú luôn được. Chuyển tiền không tính vào thu/chi, thống kê hay ngân sách.
  - Thu/chi thì không chặn âm (ghi nhận thực tế, vd thẻ thấu chi); sửa/xóa giao dịch thu hay đổi số dư ban đầu cũng vậy. Chỉ chuyển tiền và nạp tiết kiệm (tiền đi giữa các "túi" của chính user) mới bắt buộc đủ số dư.
  - Ví đã lưu trữ không đổi được số dư ban đầu (409) để luôn giữ số dư 0; đổi tên/màu vẫn được.
- **Danh mục**: `userId = null` là danh mục hệ thống. Tên không trùng (không phân biệt hoa thường) trong phạm vi hệ thống + của user, theo từng loại. Danh mục đã dùng (giao dịch hoặc định kỳ) khi xóa sẽ bị lưu trữ; chưa dùng thì xóa hẳn, ngân sách + mẫu nhập nhanh của nó xóa theo. Riêng danh mục hệ thống: ngân sách / mẫu nhập nhanh của bất kỳ user nào cũng tính là "đã dùng" → admin xóa chỉ lưu trữ, không làm mất dữ liệu của user. Danh sách xếp theo tiếng Việt.
- **Ngân sách**: theo danh mục chi tiêu, hoặc ngân sách tổng (`categoryId = null`, mỗi user/tháng 1, spent = tổng chi của tháng). `status`: `ok`, `warning` (≥ 80%), `exceeded` (≥ 100%).
  - Tạo/sửa giao dịch chi làm ngân sách vượt 80% / 100% thì sinh 1 thông báo. Mỗi ngưỡng báo 1 lần, dấu đã báo lưu ở `warnedAt` / `exceededAt`.
  - Đổi hạn mức, hoặc xóa / sửa / dời giao dịch (đổi tháng, danh mục, số tiền) làm tỷ lệ tụt dưới ngưỡng thì dấu được xóa, để lần vượt sau báo lại. Sửa giao dịch tính lại cả ngân sách cũ lẫn mới.
  - Ngân sách chỉ tạo cho danh mục chi chưa lưu trữ; ngân sách cũ của danh mục đã lưu trữ vẫn hiển thị nhưng không được sao chép sang tháng khác.
- **Mục tiêu tiết kiệm**: nạp từ một ví, bị cắt về số còn thiếu; số dư của ví đó phải đủ. Nạp/rút khóa theo user nên các lần nạp đồng thời không làm âm ví.
  - Đủ mục tiêu thì chuyển `COMPLETED`. Rút trả toàn bộ về ví được chọn: `WITHDRAWN` nếu đã hoàn thành, ngược lại `EARLY_WITHDRAWN`.
  - Mục tiêu đã rút không nạp thêm được; mục tiêu còn tiền không xóa được. Xóa mục tiêu vẫn giữ sổ nạp/rút (`goalId = null`) nên số dư từng ví không đổi.
- **Mẫu nhập nhanh**: `use` tạo giao dịch thật, có thể ghi đè ngày và số tiền. Danh mục hoặc ví của mẫu bị lưu trữ thì `use` trả 409 kèm thông báo rõ ràng.
- **Giao dịch định kỳ**: DAILY / WEEKLY / MONTHLY / YEARLY × `interval`. Ngày và giờ theo giờ VN, lấy từ `startDate`.
  - MONTHLY/YEARLY giữ `anchorDay`: ngày 31 rơi vào ngày cuối của tháng thiếu ngày, tháng sau quay lại 31 (31/1 → 28 hoặc 29/2 → 31/3).
  - Cron chạy 15 phút/lần và chạy bù ngay khi khởi động. Mọi kỳ ≤ hiện tại đều được sinh, kể cả kỳ lỡ lúc server tắt; `startDate` ở quá khứ cũng được sinh bù. Mỗi lần chạy sinh tối đa 500 kỳ cho mỗi quy tắc.
  - Idempotent nhờ `unique(recurringRuleId, scheduledFor)` cùng việc đẩy `nextRunAt` có điều kiện, nên chạy lặp hay nhiều instance cũng không sinh trùng.
  - Ví hoặc danh mục bị lưu trữ, hay user bị khóa: kỳ đó bị bỏ qua, quy tắc tự tạm dừng và user nhận thông báo `RECURRING_PAUSED`. Mở khóa không tự bật lại quy tắc; user resume (không sinh bù).
  - Dev/test: `POST /recurring/run-due` (chỉ quy tắc của user hiện tại) và `POST /admin/recurring/run-due` (mọi user, cùng hàm `runAll` mà cron gọi).
  - Quá `endDate` (tính đến cuối ngày VN) thì `isActive = false`. Resume không sinh bù: `nextRunAt` nhảy tới kỳ đầu tiên sau hiện tại.
  - Sửa quy tắc chỉ ảnh hưởng các kỳ tương lai. Xóa quy tắc vẫn giữ giao dịch đã sinh (`recurringRuleId = null`, cờ `recurring` vẫn true).
- **Thông báo**: BUDGET_WARNING, BUDGET_EXCEEDED, BROADCAST, RECURRING_PAUSED. Admin broadcast gửi cho mọi user ACTIVE và lưu lịch sử cùng số người nhận.
- **Tài khoản**:
  - Phiên đăng nhập: JWT mang `tv` = `User.tokenVersion`. Đổi mật khẩu, đặt lại bằng OTP, bị admin khóa, `POST /auth/logout-all` đều tăng `tokenVersion` → mọi token cũ bị 401. Đổi mật khẩu trả token mới cho thiết bị hiện tại. Token của user đang bị khóa trả 403 "Tài khoản đã bị khóa"; mở khóa xong phải đăng nhập lại. Đổi quyền không cần đăng nhập lại (quyền đọc từ DB mỗi request).
  - Rate limit theo IP + route: login / register / reset-password 10 lần/phút, forgot-password 3 lần/phút (cấu hình `THROTTLE_*`), quá → 429 + `Retry-After`. Lưu trong bộ nhớ của từng instance. Đăng nhập với email không tồn tại vẫn chạy bcrypt (không dò email qua thời gian phản hồi).
  - Quên mật khẩu luôn trả 204 và xử lý nền, nên không dò được email nào tồn tại. OTP 6 số được lưu dạng hash, hạn 10 phút; mã mới thay mã cũ; gửi lại tối thiểu sau 60 giây; sai 5 lần thì mã bị hủy. Tài khoản bị khóa không nhận OTP.
  - Xóa tài khoản cần mật khẩu và xóa cascade toàn bộ dữ liệu. Admin cuối cùng không tự xóa được.
- **Báo cáo**: so với tháng trước (|thay đổi| ≤ 5% = `stable`), cơ cấu theo danh mục, giao dịch lớn/nhỏ nhất, dự báo tháng sau bằng trung bình có trọng số (≥ 3 tháng quan sát, ngược lại trung bình cộng). Mọi thống kê đều lọc được theo ví.
- **Xuất CSV**: UTF-8 có BOM, cột Ngày (giờ VN), Loại, Danh mục, Ví, Tiêu đề, Ghi chú, Số tiền. Escape theo RFC 4180 (dấu phẩy, ngoặc kép, xuống dòng). Đọc DB theo lô 1000 dòng (keyset) và stream ra response nên khoảng thời gian lớn không dồn hết vào RAM; lỗi tham số (ví lạ, from ≥ to) vẫn trả 4xx trước khi stream.
- **Admin**: user bị khóa thì token đang có bị 403, không đăng nhập được, và mọi token cũ vô hiệu vĩnh viễn. Admin không tự khóa hay tự hạ quyền được.
- **Cấu hình hệ thống** (admin, trang "Cấu hình"): xem mục riêng bên dưới.
- **Để sau**: vay/nợ, push FCM.
- **Trợ lý AI**: xem mục riêng bên dưới.

## Trợ lý AI (`src/ai/`)

Chỉ API (giao diện chat app/admin theo mockup `design/mockup` mục J, `design/admin-mockup` mục I). Mô hình local qua Ollama (`gemma2:2b` + `bge-m3`), thiết kế theo `ai/research/DE-XUAT.md`, quyết định sản phẩm ở `docs/AI-DECISIONS.md`, số đo ở `ai/results/`. Skill nằm ở `ai/skills/` (Track B, 17 skill + `ghi-giao-dich` của Track A); backend chỉ có bản dự phòng cùng tên.

| File | Việc |
|---|---|
| `ai.module.ts` | DTO + controller `/ai/*`, `/admin/ai/*` |
| `ai.service.ts` | Pipeline: tin → router → skill → nháp → lưu; xác nhận / hủy / phản hồi / reroute; giới hạn hội thoại; chọn LLM |
| `ai.store.ts` | `AiStore.for(principal)` → `AiRepo`: cửa duy nhất vào dữ liệu AI của user (cả cài đặt đồng ý) |
| `ai.context.ts` | Context provider (dữ liệu cho skill qua service sẵn có) |
| `ai.router.ts` · `ai.skills.ts` | Định tuyến theo scope + skill dự phòng + registry (nạp skill từ `ai/`) |
| `ai.drafts.ts` | Loại nháp: chuẩn hóa (tên → id, phát hiện trùng) + thực thi qua service nghiệp vụ |
| `ai.learning.ts` · `ai.admin.ts` | Vòng học (ngay + ban đêm), giữ lịch sử 12 tháng · trung tâm học cho admin |
| `ai.llm.ts` · `ai.external.ts` · `ai.text.ts` | Client Ollama / FAKE · nạp `ai/` bằng tsx · chuẩn hóa chữ, vector |

### Luồng một tin nhắn
1. Kiểm tra: hội thoại của mình (404), chưa lưu trữ (409), hạn mức ngày theo giờ VN (429). Lưu tin user; hội thoại chưa có tên → lấy 60 ký tự đầu.
2. **Router theo scope** của hội thoại (USER / ADMIN, lấy theo role lúc tạo): luật học được của chính user ("ý tôi là…", khớp nguyên câu chuẩn hóa còn dấu) → [USER] "đặt ngân sách …" → `routeRulesScoped(text, scope)` của `ai/router` (chặn prompt injection, chủ đề ngoài phạm vi, hỏi dữ liệu người khác, việc của scope kia + luật của scope) → kNN trên câu mẫu **của scope đó** (`ai/router/bank.ts`, kèm câu user đã sửa định tuyến; ngưỡng 0.6 với bge-m3) → `hoi-lai`. Mọi kết quả qua `SkillRegistry.allowed`: skill `USER` chỉ chạy trong hội thoại USER, skill `ADMIN` chỉ trong hội thoại ADMIN của người đang là ADMIN, `ANY` (`ngoai-pham-vi`, `hoi-lai`) cả hai; sai scope → `ngoai-pham-vi`, reroute sai scope → 403 `AI_SKILL_FORBIDDEN`.
3. **Skill** chạy với `run({input, context, llm, now})`; context chỉ chứa dữ liệu của principal. Lỗi/timeout skill → vẫn trả 201 với tin `status: error` (không mất tin user).
4. Nháp được **chuẩn hóa** rồi lưu `PROPOSED`:
   - `transactions`: tên danh mục/ví → id của mình (không nói ví → ví nhớ được / Tiền mặt, `walletGuessed`); **phát hiện trùng**: mỗi khoản có `possibleDuplicate {transactionId, title, occurredAt, walletId}` nếu đã có giao dịch cùng số tiền + danh mục cách ≤ 1 ngày, nháp có `duplicates` = số khoản nghi trùng (app hiện "Có thể đã ghi rồi").
   - `budgets`: `categoryName: null` = ngân sách tổng; giữ `median3m/avg3m/monthsSeen` của gợi ý. Xác nhận = **upsert**: tháng đã có ngân sách cùng danh mục (hoặc tổng) → cập nhật hạn mức (`action: 'updated'`), không 409.
   - `search_filter` target `transactions`: `q, month, from, to, type, categoryName → categoryId, walletName → walletId, minAmount, maxAmount` (validate như `GET /transactions`); target `users` (chỉ ADMIN): `q, status, role`.
   - `lock_user`: `{userId, email, name, reasons[]}` (lý do lưu cùng nháp và trả lại trong kết quả); `broadcast`: `{title, body}`.
5. `confirm` (tùy chọn kèm bản sửa) → chuyển trạng thái có điều kiện `PROPOSED → EXECUTING` (chặn chạy 2 lần) → thực thi qua **đúng service của API thường**: `TransactionsService.createMany` (cảnh báo ngân sách), `BudgetsService.create/update`, `AdminService.broadcast`, `AdminService.updateUser` (khóa; không tự khóa được), tìm kiếm. Payload qua `class-validator` như `ValidationPipe`; id của người khác → 400. Lỗi → nháp quay về `PROPOSED`. Thành công → `CONFIRMED`/`EDITED` + `result`; xác nhận lại trả nguyên `result` với `idempotent: true`. Quyền (ADMIN) kiểm tra lại lúc xác nhận.

**Skill**: nạp từ `ai/skills/index.ts` (`skills`) và `ai/skills/<tên>/index.ts` (`skill`), object `{name, scope: 'USER'|'ADMIN'|'ANY', description, context, run}` (kiểu: `ai/lib/contracts.ts` = `src/ai/ai.types.ts`), trùng tên thì đè bản dự phòng của backend → thêm skill không cần sửa backend. USER: `ghi-giao-dich`, `hoi-so-du`, `tong-ket-thang`, `kiem-tra-ngan-sach`, `tim-giao-dich`, `tien-do-tiet-kiem`, `goi-y-ngan-sach`, `meo-tiet-kiem`, `huong-dan`, `dat-ngan-sach` (backend); ADMIN: `tong-quan-he-thong`, `tra-cuu-nguoi-dung`, `phat-hien-bat-thuong`, `soan-thong-bao`, `de-xuat-khoa`, `tom-tat-cau-hinh`, `huong-dan-quan-tri`; ANY: `ngoai-pham-vi`, `hoi-lai`. Bí danh cũ `admin-*` bị bỏ qua khi nạp. `ghi-giao-dich` hiện chạy bản backend (parser + prompt + schema của `ai/`, luật học được trước model, kNN few-shot, JSON schema, sửa JSON hỏng + retry 1 lần, hậu kiểm thu/chi theo danh mục, cắt số tiền/ví khỏi tên khoản).

**Context provider** (`context` khai báo = nạp sẵn vào `context.data`; `context.get(name, args)` gọi lười). Tham số qua danh sách trắng `q, month, from, to, limit (≤50), skill, texts, k, kind` — không có tham số nào chọn user.

| Provider | Tham số | Dữ liệu |
|---|---|---|
| `userContext` | | UserContext của `ai/lib/types.ts` (danh mục + ví) |
| `balance`, `wallets`, `categories`, `savingGoals`, `userMemory` | | như tên |
| `monthSummary` | `month?, limit?` (mặc định 5) | thu, chi, net, `topExpenses`, `largestExpense {title, amount, categoryName, date}` |
| `periodSummary` | `from, to` (to không gồm; mặc định 7 ngày) | thu, chi, net, `incomeCount`, `expenseCount`, `topExpenses`, `largestExpense` |
| `budgets` | `month?` | tổng + theo danh mục |
| `recentTransactions`, `searchTransactions` | `limit` / `q, month, limit` | giao dịch của mình |
| `userRules`, `similarExamples` | `kind, skill` / `skill, texts, k` | luật đang bật (riêng + chung) / kNN few-shot |
| `publicConfig` | | `{appName, supportEmail, hotline}` |
| ADMIN: `adminOverview`, `adminUsersSearch {q}`, `adminAnomalies`, `adminConfigHistory {limit}`, `adminBroadcasts {limit}` | | như API admin |
| ADMIN: `adminUserActivity` | | mỗi user `{id, email, name, role, status, createdAt, lastLoginAt, txCount30d, expenseThisMonth, expenseAvgPrev3, largestExpense30d, failedLogins24h}` (user có đăng nhập sai / giao dịch nhiều trước, rồi user mới; tối đa 200) |

**Đăng nhập sai**: `POST /auth/login` sai mật khẩu với email có thật → 1 dòng `LoginFailure {userId, ip, createdAt}` (không lưu mật khẩu đã nhập; email không tồn tại không ghi gì). Xóa sau 30 ngày (cron 03:10). Dùng cho `failedLogins24h` → `phat-hien-bat-thuong` / `de-xuat-khoa` (≥ 10 lần/24h là dấu hiệu dò mật khẩu).

### Hội thoại
- Ghim / bỏ ghim: `PATCH /ai/conversations/:id {pinned}`; danh sách xếp cuộc ghim trước.
- Đạt `ai.maxConversationsPerUser` (đếm cuộc chưa lưu trữ) khi tạo mới → **tự lưu trữ cuộc cũ nhất chưa ghim** (trả `autoArchived {id, title}`); mọi cuộc đều ghim → 409 `AI_CONVERSATION_LIMIT`.
- Giữ lịch sử **12 tháng**: cron 03:20 giờ VN xóa tin nhắn cũ hơn 12 tháng (nháp / phản hồi đi theo) và hội thoại không còn tin; user tự xóa bất cứ lúc nào. Dev/test: `POST /admin/ai/retention/run?now=ISO`. Trí nhớ / luật / ví dụ đã học không bị xóa theo (user xóa trí nhớ ở `DELETE /ai/memory/:id`).

### Cô lập dữ liệu
- Bảng AI đều có `userId` (FK cascade → xóa tài khoản xóa sạch). Code AI chỉ vào dữ liệu user qua `AiStore.for(principal)`; mọi where trong `AiRepo` gắn `userId = principal.id`, không method nào nhận userId làm tham số (e2e đọc mã nguồn để giữ bất biến này). Principal lấy từ JWT qua `AuthGuard` (role đọc từ DB mỗi request).
- Id thuộc người khác trên đường dẫn → 404 (hội thoại, tin, nháp, trí nhớ), kể cả với admin. Admin **không** xem được nội dung hội thoại, trí nhớ hay luật riêng của từng user: `/admin/ai/*` chỉ trả số đếm và dữ liệu chung đã ẩn danh.
- Chống prompt injection: câu người dùng không bao giờ quyết định principal; router Track B chặn câu hỏi về người khác / câu injection; provider admin chỉ chạy cho role ADMIN; skill chặn scope cả hai chiều; nháp admin kiểm tra role lại lúc xác nhận.
- `x-ai-debug: 1` (không production) trả thêm `debug: {route, context, llmCalls}` để e2e kiểm tra context/prompt của A không chứa dữ liệu B dù câu có email/id của B.

### Vòng học
- **Ngay (riêng user)**: xác nhận/sửa → ví dụ (khoản đã làm sạch → tên + danh mục, embedding) + bộ đếm luật theo bigram **còn dấu** (bật khi support ≥ 3, precision ≥ 0.85; tắt khi có hại ≥ 2 và > có ích) + có ích/có hại cho luật đã áp; trí nhớ ví mặc định (đổi 2 lần liên tiếp sang cùng ví → nhớ ví mới). Hủy / sửa → `AiFeedback` (`DRAFT_OUTCOME` kèm diff). "Ý tôi là…" → luật định tuyến của user bật ngay cho câu đó + câu mẫu kNN. 👍/👎 → `THUMBS`.
- **Đồng ý góp ví dụ** (`GET/PUT /ai/settings {shareExamples}`): hỏi một lần (`asked`), lưu `consentedAt`, tắt được bất cứ lúc nào. Chưa đồng ý / đã tắt → dữ liệu của user không được dùng cho học chung.
- **Ban đêm** (cron 02:30 giờ VN, khóa advisory Postgres, tuần tự; dev/test chạy tay `POST /admin/ai/learning/run`): gom luật đang bật + ví dụ của **user đã đồng ý** → **ẩn danh**: chỉ giữ mẫu có **≥ 5 người khác nhau** (sàn cứng), bỏ mẫu chứa số / `@` / từ trùng tên hoặc email của người đóng góp, không mang ghi chú, tiền chỉ giữ trung vị làm tròn 1 chữ số có nghĩa, không lưu userId → ứng viên CHUNG → **cổng kiểm định** trên bộ đề hồi quy `AiEvalCase` (seed từ `ai/eval/data/bank.seed.json` + câu 1 khoản của `ghi.test.json`; ví dụ được admin duyệt được thêm vào; nếu `ai/eval/gate.ts` export `evaluateRule` thì dùng nó): mâu thuẫn bộ đề → `REJECTED`; luật cần có đề phủ và đạt mới tự bật; ví dụ không mâu thuẫn là được → tự `ACTIVE` khi đạt `ai.autoApprove*` (mặc định ≥ 50 người, đúng ≥ 97%), còn lại `PROPOSED` chờ admin. Quyết định của admin không bị lần chạy sau ghi đè; luật tự bật không còn đủ người đồng ý → về `PROPOSED`.
- Luật/ví dụ CHUNG đang bật dùng sau dữ liệu của user (luật user trước, rồi luật chung; few-shot lấy cả hai).
- Seed hệ thống lúc khởi động (idempotent): câu mẫu router theo scope (`ai/router/bank.ts`), 40 ví dụ khởi đầu, bộ đề hồi quy. Embedding tính lười theo model đang cấu hình.

### Vector
Embedding lưu `Bytes` (Float32) + tên model; kNN chạy trong tiến trình trên ví dụ của user + chung (`AiRepo.knnRows` → `similarExamples`). Postgres đang là image alpine không có pgvector — chuyển sang pgvector ghi ở `docs/BACKLOG.md`.

### Cấu hình (mục `ai`; `ai.enabled` ≡ `business.featureAi`)
| Trường | Mặc định | |
|---|---|---|
| `enabled` | true | **Cùng một công tắc** với `business.featureAi`: sửa trường nào cũng ghi cả hai (gửi 2 giá trị khác nhau trong 1 PATCH → 400). Tắt → route ghi `/ai/*` 403 `FEATURE_DISABLED` (cả admin), đọc vẫn được; `/admin/ai/*` vẫn chạy |
| `provider` (`ollama`/`fake`), `ollamaUrl`, `chatModel`, `embedModel` | env `AI_PROVIDER`/`OLLAMA_URL`/`AI_CHAT_MODEL`/`AI_EMBED_MODEL` | Env `AI_PROVIDER` ghi đè; `NODE_ENV=test` → fake |
| `timeoutSeconds` (5–600) | 15 | Mỗi lời gọi Ollama (retry 2 lần với lỗi mạng/5xx, không retry khi hết giờ); cả skill ≤ 2× |
| `dailyMessageLimitPerUser` (1–100000) | 30 | Theo ngày giờ VN → 429 |
| `maxConversationsPerUser` (1–10000) | 50 | Đạt → tự lưu trữ cuộc cũ nhất chưa ghim |
| `autoApproveEnabled`, `autoApproveMinUsers` (≥ 5), `autoApproveMinSupport`, `autoApproveMinPrecision` (%) | true, 50, 50, 97 | Ngưỡng tự áp dụng luật/ví dụ chung |

Bảo trì: như mọi route khác (USER 503, ADMIN qua). `GET /config/public` có thêm `ai: {enabled, dailyMessageLimitPerUser, maxConversationsPerUser}` (`features` giữ nguyên 5 khóa cũ). Gọi Ollama trong một instance được xếp hàng tuần tự (GPU 1 luồng, `OLLAMA_NUM_PARALLEL=1`).

### Dữ liệu
`AiConversation` (userId, scope USER/ADMIN, title, archived, pinned) · `AiMessage` (role, content, skill, routeBy, status ok/ask/error/unsupported, latencyMs, tokens, meta) · `AiDraft` (messageId 1–1, kind, payload, status PROPOSED/EXECUTING/CONFIRMED/EDITED/CANCELLED, finalPayload, result, resolvedAt) · `AiFeedback` (DRAFT_OUTCOME/REROUTE/THUMBS, unique theo tin + loại) · `AiMemory` (key/value, helpful/harmful, source, lastUsedAt) · `AiExample` (scope USER/GLOBAL, ownerKey = userId \| "global", skill, input, inputNorm, output, embedding, confirmations, userCount, status) · `AiRule` (scope, kind category/route, pattern còn dấu → value, support/helpful/harmful/precision, status, approvedBy, evalReport) · `AiUserSetting` (shareExamples, consentedAt) · `AiEvalCase` · `AiLearningRun` · `LoginFailure`. Migration `20261012090000_ai_assistant`, `20261014090000_ai_round2`.

### Docker
Image API build từ **gốc repo** (`docker build -f backend/Dockerfile .`, compose đã đổi `context: .`) để chép `ai/` (không kèm `ai/node_modules`, `ai/results`, `ai/research` — xem `.dockerignore`) vào `/app/ai` (`AI_DIR`); `tsx` là dependency của backend nên skill nạp được trong container.

### Smoke với Ollama thật (`scripts/ai-smoke-ollama.mjs`, RTX 3050, gemma2:2b + bge-m3, chạy dưới `flock /tmp/app-tracker-gpu.lock`)
- 2026-10-14 (skill Track B): 5 hội thoại / 14 tin + 3 lần xác nhận, 0 lỗi. Server p50 1036 ms, p95 4520 ms. Tin có gọi LLM p50 1135 ms. Skill tất định (`hoi-so-du`, `tim-giao-dich`, `ngoai-pham-vi`) 4–15 ms. Các skill có câu do LLM viết (`tong-ket-thang`, `goi-y-ngan-sach`, `meo-tiet-kiem`, `kiem-tra-ngan-sach`, `tong-quan-he-thong`, `phat-hien-bat-thuong`) 0,9–1,4 s. `soan-thong-bao` 4,5 s (soạn + kiểm tra + thử lại). Lần kNN đầu tiên trong scope (nhúng câu mẫu) 4,1 s.
- 2026-10-12 (đợt 1): 12 tin, p50 990 ms, p95 1489 ms; `ghi-giao-dich` p50 1050 ms (~650 token vào / 20–40 token ra); xác nhận nháp 150–180 ms.

### Giới hạn hiện tại
- Hàng đợi Ollama là trong tiến trình; nhiều instance API cần hàng đợi chung.
- Skill Track A (`ghi-giao-dich` bản mới trên `feat/ai-quality`) chưa merge; backend dùng bản riêng dựa trên parser/prompt của `ai/`.

## Cấu hình hệ thống

Lưu ở bảng `SystemSetting` (khóa `mục.trường` → JSON; chưa có dòng = giá trị mặc định, tức hành vi/env cũ) và `SystemConfigChange` (lịch sử: ai, lúc nào, mục, trường, cũ → mới; actor rỗng = Hệ thống). Đọc qua cache trong tiến trình 15 giây, lưu xong xóa cache ngay ở instance đó (instance khác thấy trong ≤ 15 giây, app thấy trong 1 phút như trang admin ghi).

| Mục | Trường | Mặc định | Có hiệu lực ở đâu |
|---|---|---|---|
| general | `appName`, `supportEmail`, `hotline`, `termsUrl`, `privacyUrl` | "TrackerX", trống | `/config/public`; tên app vào tiêu đề email OTP / email thử. Link phải `https://` |
| access | `registrationEnabled` | true | Tắt → `POST /auth/register` 403 `{code:'REGISTRATION_DISABLED'}` |
| | `sessionDays` (1–365) | theo `JWT_EXPIRES_IN` (30) | Hạn JWT khi đăng nhập / đăng ký / đổi mật khẩu. Chưa sửa thì dùng nguyên `JWT_EXPIRES_IN` |
| | `loginMaxAttempts` / `loginWindowMinutes` | `THROTTLE_AUTH_LIMIT` (10, test 200) / 1 | Giới hạn đăng nhập **theo email** (thêm vào giới hạn theo IP), quá → 429 + `Retry-After` |
| | `maintenanceMessage`, `maintenanceEndsAt` | câu mặc định, không hẹn | Nội dung + giờ tự tắt của bảo trì |
| smtp | `host`, `port`, `security` (`starttls`/`ssl`/`none`), `user`, `password`, `from` | `SMTP_*` | Gửi OTP + email thử. Host trống → OTP ghi log. Mật khẩu mã hóa AES-256-GCM (`CONFIG_SECRET`), không API nào trả về (chỉ `hasPassword`, `passwordSavedAt/By`) |
| password | `minLength` (6–64) | 6 | Đăng ký, đổi mật khẩu, đặt lại mật khẩu → 400 "Mật khẩu phải có ít nhất N ký tự" |
| | `otpExpiryMinutes` (1–60), `otpMaxAttempts` (1–10), `otpResendSeconds` (30–600, < hạn mã) | 10 / 5 / 60 | Quên / đặt lại mật khẩu |
| business | `budgetWarningPercent` (10–100) < `budgetExceededPercent` (50–200) | 80 / 100 | Thông báo BUDGET_WARNING/EXCEEDED, `status` của ngân sách; `GET /budgets` trả `thresholds` |
| | `defaultWalletName` | "Tiền mặt" | Ví tạo sẵn khi đăng ký |
| | `featureSavingGoals`, `featureRecurring`, `featureTransfers`, `featureCsvExport`, `featureQuickTemplates`, `featureAi` | true | Tắt → route **ghi** (khác GET) của tính năng trả 403 `{code:'FEATURE_DISABLED'}`, đọc vẫn được, dữ liệu giữ nguyên. Riêng xuất CSV chặn cả GET (chính nó là tính năng). Áp cho mọi tài khoản |
| ai | xem mục Trợ lý AI | | |
| mobile | `android/iosLatestVersion`, `android/iosMinVersion` (x.y.z, tối thiểu ≤ mới nhất), `android/iosStoreUrl`, `releaseNotes` (≤ 300) | 1.0.0, trống | `/config/public` cho app hiện hộp "Cần cập nhật" |

- **Bảo trì** (`POST /admin/config/maintenance`, không qua thanh Lưu): mọi request có token của user không phải ADMIN → 503 `{code:'MAINTENANCE', message, endsAt}`; đăng nhập và đăng ký của user thường cũng 503. ADMIN không bị chặn; `/health`, `/config/public`, quên / đặt lại mật khẩu vẫn chạy. Có `endsAt` thì tới giờ tự tắt: kiểm tra ngay khi đọc (request đầu tiên sau giờ đó đã qua được) và cron mỗi phút; lịch sử ghi "Hệ thống", giờ dự kiến được xóa. Tắt tay cũng xóa giờ dự kiến.
- **Giao dịch định kỳ tắt**: ngoài chặn route ghi, cron (và `POST /admin/recurring/run-due`) tạm ngưng sinh kỳ (`skipped: true, reason: 'FEATURE_DISABLED'`), `nextRunAt` giữ nguyên. Bật lại thì lượt chạy kế tiếp sinh bù các kỳ đã qua, giống khi server tắt (lương, tiền nhà… vẫn được ghi đúng ngày).
- **Kiểm tra hợp lệ**: từng trường (kiểu, khoảng, https, email, số điện thoại, phiên bản, độ dài) và ràng buộc chéo trên trạng thái sau khi gộp; một trường sai thì không lưu gì. Gửi giá trị trùng hiện tại thì không ghi lịch sử.
- `GET /config/public` → `{appName, supportEmail, hotline, termsUrl, privacyUrl, currency, registrationEnabled, maintenance:{enabled, message, endsAt}, features:{savingGoals, recurring, transfers, csvExport, quickTemplates}, ai:{enabled, dailyMessageLimitPerUser, maxConversationsPerUser}, budget:{warningPercent, exceededPercent}, password:{minLength}, otp:{expiryMinutes, resendSeconds}, mobile:{android:{latestVersion, minVersion, storeUrl}, ios:{…}, releaseNotes}}`. Không chứa SMTP.
