# App Tracker — Quản lý thu/chi cá nhân

## Kiến trúc

| Thành phần | Thư mục | Công nghệ | Trạng thái |
|---|---|---|---|
| Backend API | `backend/` | NestJS 11 + Prisma 6 + PostgreSQL 16 | v1 |
| Admin web | `admin/` | — | Đang làm |
| Mobile | — | Flutter | Dự kiến |

Backend: mỗi module một file `src/<module>/<module>.module.ts` (DTO + service + controller). Dùng chung: `src/common/` (auth guard JWT, DTO, giờ VN, filter lỗi Prisma), `src/prisma/`. Tiền lưu `BigInt` (VND), trả ra JSON dạng number. Cron (`@nestjs/schedule`) sinh giao dịch định kỳ.

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
- Gửi OTP quên mật khẩu qua SMTP (`SMTP_*` trong `.env`). Bỏ trống `SMTP_HOST` thì OTP được in ra log server.
- E2E (server phải đang chạy, `NODE_ENV` khác `production`, log server ghi ra file):
  ```bash
  npm run build && node dist/main > /tmp/tracker-api.log 2>&1 &
  npm run test:e2e              # API_URL=http://host:port/api  API_LOG=/đường/dẫn/log
  ```
  Script dùng email ngẫu nhiên nên chạy lặp được không cần reset DB. Mất khoảng 70 giây vì có 1 lần chờ hết giới hạn gửi lại OTP.

## Endpoint (prefix `/api`; trừ register / login / forgot / reset, còn lại đều cần `Authorization: Bearer <token>`)

| Module | Method | Path | Mô tả |
|---|---|---|---|
| auth | POST | `/auth/register` | Đăng ký, tự tạo ví "Tiền mặt" |
| | POST | `/auth/login` | Đăng nhập (tài khoản khóa → 403) |
| | POST | `/auth/forgot-password` | Luôn 204; gửi OTP 6 số nếu email tồn tại |
| | POST | `/auth/reset-password` | `{email, otp, newPassword}` |
| | GET / PATCH | `/me` | Xem / đổi tên |
| | DELETE | `/me` | `{password}`: xóa tài khoản và toàn bộ dữ liệu |
| | POST | `/me/password` | Đổi mật khẩu |
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
| export | GET | `/export/transactions.csv?month=\|from=&to=&walletId=` | CSV UTF-8 BOM |
| admin (role ADMIN) | GET | `/admin/overview` | |
| | GET | `/admin/users?q=&status=&role=&page=&limit=` | |
| | GET / PATCH | `/admin/users/:id` | Chi tiết + tài chính + ví; khóa/mở, đổi quyền |
| | GET | `/admin/transactions?userId=&walletId=&...` | Kèm user + ví |
| | GET / POST | `/admin/broadcasts` | Lịch sử (số người nhận / đã đọc) / gửi cho mọi user ACTIVE |
| | GET / POST / PATCH / DELETE | `/admin/categories[/:id]` | Danh mục hệ thống |
| | POST | `/admin/categories/:id/restore` | |

## Nghiệp vụ v1

- **Múi giờ**: mọi nhóm theo ngày/tháng dùng Asia/Ho_Chi_Minh (UTC+7). `month=YYYY-MM`; `from` tính bao gồm, `to` không bao gồm.
- **Ví**: loại CASH / BANK / EWALLET, `initialBalance` ≥ 0. Số dư ví = ban đầu + thu − chi + chuyển vào − chuyển ra − nạp tiết kiệm + rút tiết kiệm, luôn tính từ dữ liệu, không lưu cộng dồn. Số dư tổng = tổng các ví.
  - Phát sinh gồm giao dịch, chuyển tiền, sổ tiết kiệm và giao dịch định kỳ. Xóa ví chưa có phát sinh thì xóa hẳn, mẫu nhập nhanh dùng ví đó bị xóa theo. Ví có phát sinh chỉ lưu trữ được khi số dư = 0, ngược lại trả 409.
  - Ví lưu trữ không dùng được cho phát sinh mới, và phát sinh cũ của nó không sửa/xóa được cho tới khi khôi phục ví.
- **Giao dịch**: bắt buộc ví và danh mục của user, chưa lưu trữ. Loại INCOME/EXPENSE lấy theo danh mục. Mọi đường tạo giao dịch (API, bulk, mẫu nhập nhanh, định kỳ) đều chạy cùng logic, kể cả cảnh báo ngân sách.
- **Chuyển tiền**: 2 ví khác nhau của cùng user. Ví nguồn phải đủ số dư lúc tạo/sửa; khi sửa, số dư được tính sau khi trừ tác động của chính giao dịch cũ. Chuyển tiền không tính vào thu/chi, thống kê hay ngân sách.
- **Danh mục**: `userId = null` là danh mục hệ thống. Tên không trùng (không phân biệt hoa thường) trong phạm vi hệ thống + của user, theo từng loại. Danh mục đã dùng (giao dịch hoặc định kỳ) khi xóa sẽ bị lưu trữ. Danh sách xếp theo tiếng Việt.
- **Ngân sách**: theo danh mục chi tiêu, hoặc ngân sách tổng (`categoryId = null`, mỗi user/tháng 1, spent = tổng chi của tháng). `status`: `ok`, `warning` (≥ 80%), `exceeded` (≥ 100%).
  - Tạo/sửa giao dịch chi làm ngân sách vượt 80% / 100% thì sinh 1 thông báo. Mỗi ngưỡng báo 1 lần, dấu đã báo lưu ở `warnedAt` / `exceededAt`.
  - Đổi hạn mức làm tỷ lệ tụt dưới ngưỡng thì dấu được xóa, để lần vượt sau báo lại.
- **Mục tiêu tiết kiệm**: nạp từ một ví, bị cắt về số còn thiếu; số dư của ví đó phải đủ. Nạp/rút khóa theo user nên các lần nạp đồng thời không làm âm ví.
  - Đủ mục tiêu thì chuyển `COMPLETED`. Rút trả toàn bộ về ví được chọn: `WITHDRAWN` nếu đã hoàn thành, ngược lại `EARLY_WITHDRAWN`.
  - Mục tiêu đã rút không nạp thêm được; mục tiêu còn tiền không xóa được. Xóa mục tiêu vẫn giữ sổ nạp/rút (`goalId = null`) nên số dư từng ví không đổi.
- **Mẫu nhập nhanh**: `use` tạo giao dịch thật, có thể ghi đè ngày và số tiền. Danh mục hoặc ví của mẫu bị lưu trữ thì `use` trả 409 kèm thông báo rõ ràng.
- **Giao dịch định kỳ**: DAILY / WEEKLY / MONTHLY / YEARLY × `interval`. Ngày và giờ theo giờ VN, lấy từ `startDate`.
  - MONTHLY/YEARLY giữ `anchorDay`: ngày 31 rơi vào ngày cuối của tháng thiếu ngày, tháng sau quay lại 31 (31/1 → 28 hoặc 29/2 → 31/3).
  - Cron chạy 15 phút/lần và chạy bù ngay khi khởi động. Mọi kỳ ≤ hiện tại đều được sinh, kể cả kỳ lỡ lúc server tắt; `startDate` ở quá khứ cũng được sinh bù. Mỗi lần chạy sinh tối đa 500 kỳ cho mỗi quy tắc.
  - Idempotent nhờ `unique(recurringRuleId, scheduledFor)` cùng việc đẩy `nextRunAt` có điều kiện, nên chạy lặp hay nhiều instance cũng không sinh trùng.
  - Ví hoặc danh mục bị lưu trữ, hay user bị khóa: kỳ đó bị bỏ qua, quy tắc tự tạm dừng và user nhận thông báo `RECURRING_PAUSED`.
  - Quá `endDate` (tính đến cuối ngày VN) thì `isActive = false`. Resume không sinh bù: `nextRunAt` nhảy tới kỳ đầu tiên sau hiện tại.
  - Sửa quy tắc chỉ ảnh hưởng các kỳ tương lai. Xóa quy tắc vẫn giữ giao dịch đã sinh (`recurringRuleId = null`, cờ `recurring` vẫn true).
- **Thông báo**: BUDGET_WARNING, BUDGET_EXCEEDED, BROADCAST, RECURRING_PAUSED. Admin broadcast gửi cho mọi user ACTIVE và lưu lịch sử cùng số người nhận.
- **Tài khoản**:
  - Quên mật khẩu luôn trả 204 và xử lý nền, nên không dò được email nào tồn tại. OTP 6 số được lưu dạng hash, hạn 10 phút; mã mới thay mã cũ; gửi lại tối thiểu sau 60 giây; sai 5 lần thì mã bị hủy. Tài khoản bị khóa không nhận OTP.
  - Xóa tài khoản cần mật khẩu và xóa cascade toàn bộ dữ liệu. Admin cuối cùng không tự xóa được.
- **Báo cáo**: so với tháng trước (|thay đổi| ≤ 5% = `stable`), cơ cấu theo danh mục, giao dịch lớn/nhỏ nhất, dự báo tháng sau bằng trung bình có trọng số (≥ 3 tháng quan sát, ngược lại trung bình cộng). Mọi thống kê đều lọc được theo ví.
- **Xuất CSV**: UTF-8 có BOM, cột Ngày (giờ VN), Loại, Danh mục, Ví, Tiêu đề, Ghi chú, Số tiền. Escape theo RFC 4180 (dấu phẩy, ngoặc kép, xuống dòng).
- **Admin**: user bị khóa thì token đang có bị 403 và không đăng nhập được. Admin không tự khóa hay tự hạ quyền được.
- **Để sau**: vay/nợ, push FCM.
