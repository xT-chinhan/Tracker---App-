# App Tracker — Quản lý thu/chi cá nhân

## Kiến trúc

| Thành phần | Thư mục | Công nghệ | Trạng thái |
|---|---|---|---|
| Backend API | `backend/` | NestJS 11 + Prisma 6 + PostgreSQL 16 | v1 |
| Admin web | `admin/` | — | Đang làm |
| Mobile | — | Flutter | Dự kiến |

Backend: mỗi module một file `src/<module>/<module>.module.ts` (DTO + service + controller). Dùng chung: `src/common/` (auth guard JWT, DTO, giờ VN, filter lỗi Prisma), `src/prisma/`. Tiền lưu `BigInt` (VND), trả ra JSON dạng number. Cron (`@nestjs/schedule`) sinh giao dịch định kỳ. Rate limit các route đăng nhập/đăng ký/OTP bằng `@nestjs/throttler`.

## Chạy

```bash
docker compose up -d            # Postgres ở localhost:5433
cd backend
npm i
cp .env.example .env
npx prisma migrate deploy
npm run db:seed                 # 14 danh mục hệ thống + admin (ADMIN_EMAIL / ADMIN_PASSWORD trong .env)
npm run dev                     # http://localhost:3000/api
```

- Swagger UI: http://localhost:3000/docs — OpenAPI JSON: http://localhost:3000/docs/openapi.json
- Health: `GET /api/health` (công khai) → `{status, db, version}`; DB không kết nối được → 503.
- Gửi OTP quên mật khẩu qua SMTP (`SMTP_*` trong `.env`). Bỏ trống `SMTP_HOST` thì OTP được in ra log server.

### Biến môi trường (`backend/.env`)

| Biến | Mặc định | Ý nghĩa |
|---|---|---|
| `DATABASE_URL` | — | PostgreSQL |
| `PORT` | 3000 | |
| `JWT_SECRET` | — | Bắt buộc; `NODE_ENV=production` thì phải ≥ 16 ký tự (không thì API không khởi động) |
| `JWT_EXPIRES_IN` | 30d | |
| `CORS_ORIGINS` | — | Danh sách origin, phân cách bằng dấu phẩy |
| `ADMIN_EMAIL` / `ADMIN_PASSWORD` | — | Seed tạo/nâng quyền admin này (bỏ trống = không tạo) |
| `NODE_ENV` | — | `production`: tắt các endpoint run-due (404). `test`: nới rate limit cho e2e |
| `SMTP_HOST` `SMTP_PORT` `SMTP_SECURE` `SMTP_USER` `SMTP_PASS` `SMTP_FROM` | | Gửi OTP; `SMTP_HOST` trống → OTP ra log |
| `THROTTLE_TTL_SEC` | 60 (test: 10) | Cửa sổ rate limit (giây) |
| `THROTTLE_AUTH_LIMIT` | 10 (test: 200) | Số request / cửa sổ / IP cho mỗi route login, register, reset-password |
| `THROTTLE_FORGOT_LIMIT` | 3 (test: 20) | Như trên cho forgot-password |
| `TRUST_PROXY` | — | Chạy sau reverse proxy: `1` (số hop), `true` hoặc danh sách IP, để rate limit đếm theo IP thật |

### Chạy bằng Docker (DB + API)

```bash
# .env ở thư mục gốc repo (cạnh docker-compose.yml), tối thiểu:
#   JWT_SECRET=<chuỗi ngẫu nhiên >= 16 ký tự>
#   ADMIN_EMAIL=admin@tracker.local
#   ADMIN_PASSWORD=...
# Tùy chọn: API_PORT (mặc định 3000), API_DB (tên DB, mặc định tracker), CORS_ORIGINS, SMTP_*, TRUST_PROXY
docker compose --profile api up -d --build      # http://localhost:3000/api/health
docker compose --profile api down               # dừng (giữ dữ liệu; thêm -v để xóa volume)
```

Image `backend/Dockerfile`: multi-stage node 22-alpine, `prisma generate` lúc build. Khi khởi động: chờ DB (tối đa ~30s) → `prisma migrate deploy` → seed (idempotent: 14 danh mục hệ thống + admin nếu có `ADMIN_*`) → `node dist/main`. Có `HEALTHCHECK` gọi `/api/health`. Không bật profile `api` thì `docker compose up -d` vẫn chỉ chạy DB như cũ.

### E2E

Server phải chạy với `NODE_ENV=test` (bật endpoint run-due và nới rate limit: cửa sổ 10s, 200 req/route, forgot 20), log ghi ra file để script đọc OTP:

```bash
npm run build && NODE_ENV=test node dist/main > /tmp/tracker-api.log 2>&1 &
npm run test:e2e              # API_URL=http://host:port/api  API_LOG=/đường/dẫn/log
```

- Email ngẫu nhiên nên chạy lặp được không cần reset DB. Mất khoảng 90 giây: 1 lần chờ 61s (giới hạn gửi lại OTP) và ~11s chờ hết khóa 429 ở cuối (nên 2 lần chạy liền nhau vẫn qua).
- Có thể chạy server với `TZ=UTC` để chắc chắn không phụ thuộc múi giờ máy chủ (e2e đã chạy như vậy).
- In ra ma trận test theo nhóm; exit code 1 nếu có lỗi.

## Endpoint (prefix `/api`; trừ register / login / forgot / reset / health, còn lại đều cần `Authorization: Bearer <token>`)

Quy ước lỗi: id trên **đường dẫn** thuộc user khác → 404 (không lộ sự tồn tại); id tham chiếu trong **body** (ví, danh mục) không thuộc user → 400; route admin với user thường → 403; token cũ/hết hiệu lực → 401; tài khoản bị khóa → 403; vượt rate limit → 429 (kèm `Retry-After`).

| Module | Method | Path | Mô tả |
|---|---|---|---|
| health | GET | `/health` | Công khai: `{status, db, version}`, DB lỗi → 503 |
| auth | POST | `/auth/register` | Đăng ký, tự tạo ví "Tiền mặt" (rate limit) |
| | POST | `/auth/login` | Đăng nhập (tài khoản khóa → 403; rate limit) |
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
| transactions | GET | `/transactions?month=&from=&to=&type=&categoryId=&walletId=&q=&page=&limit=` | Có cờ `recurring` |
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
- **Để sau**: vay/nợ, push FCM.
