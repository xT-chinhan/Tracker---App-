# App Tracker — Quản lý thu/chi cá nhân

## Kiến trúc

| Thành phần | Thư mục | Công nghệ | Trạng thái |
|---|---|---|---|
| Backend API | `backend/` | NestJS 11 + Prisma 6 + PostgreSQL 16 | Đã xong |
| Admin web | `admin/` | — | Dự kiến |
| Mobile | — | Flutter | Dự kiến (port từ app Flutter + Firestore cũ) |

Backend: mỗi module một file `src/<module>/<module>.module.ts` (DTO + service + controller). Dùng chung: `src/common/` (auth guard JWT, DTO, giờ VN, filter lỗi Prisma), `src/prisma/`. Tiền lưu `BigInt` (VND), trả ra JSON dạng number.

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
- E2E (server phải đang chạy): `npm run test:e2e` (đổi đích bằng `API_URL=http://host:port/api`). Dùng email ngẫu nhiên, chạy lặp được không cần reset DB.

## Endpoint (prefix `/api`, trừ register/login đều cần `Authorization: Bearer <token>`)

| Module | Method | Path | Mô tả |
|---|---|---|---|
| auth | POST | `/auth/register` | Đăng ký, trả `accessToken` + user |
| | POST | `/auth/login` | Đăng nhập (tài khoản khóa → 403) |
| | GET / PATCH | `/me` | Xem / đổi tên |
| | POST | `/me/password` | Đổi mật khẩu (204) |
| categories | GET | `/categories?type=` | Danh mục hệ thống + của mình (chưa lưu trữ) |
| | POST / PATCH / DELETE | `/categories[/:id]` | CRUD danh mục riêng; xóa danh mục đã dùng → lưu trữ |
| transactions | GET | `/transactions?month=&from=&to=&type=&categoryId=&q=&page=&limit=` | Lọc + phân trang |
| | GET / PATCH / DELETE | `/transactions/:id` | |
| | POST | `/transactions` | Tạo (loại thu/chi lấy theo danh mục) |
| | POST | `/transactions/bulk` | Tạo 1–100 giao dịch, tất cả hoặc không |
| budgets | GET | `/budgets?month=YYYY-MM` | Ngân sách tháng kèm spent/remaining/percentage/status |
| | POST / PATCH / DELETE | `/budgets[/:id]` | |
| | POST | `/budgets/copy` | Sao chép `fromMonth` → `toMonth` (bỏ qua danh mục đã có) |
| saving-goals | GET | `/saving-goals?status=` | |
| | GET / PATCH / DELETE | `/saving-goals/:id` | Chi tiết kèm lịch sử nạp/rút |
| | POST | `/saving-goals` | |
| | POST | `/saving-goals/:id/deposit` | Nạp |
| | POST | `/saving-goals/:id/withdraw` | Rút toàn bộ |
| stats | GET | `/stats/balance` | Số dư hiện tại |
| | GET | `/stats/summary?month=\|from=&to=` | Tổng thu/chi trong khoảng + số dư |
| | GET | `/stats/by-category?month=&type=` | Cơ cấu theo danh mục (mặc định EXPENSE) |
| | GET | `/stats/daily?month=` | Thu/chi theo ngày |
| | GET | `/stats/trend?month=&months=` | Thu/chi theo tháng (mặc định 6) |
| | GET | `/stats/report?month=&observationMonths=` | Báo cáo tháng |
| admin (role ADMIN) | GET | `/admin/overview` | Tổng quan hệ thống |
| | GET | `/admin/users?q=&status=&role=&page=&limit=` | Danh sách / tìm user |
| | GET / PATCH | `/admin/users/:id` | Chi tiết + tài chính; khóa/mở khóa, đổi quyền |
| | GET | `/admin/transactions?userId=&...` | Giao dịch toàn hệ thống |
| | GET / POST / PATCH / DELETE | `/admin/categories[/:id]` | Danh mục hệ thống |
| | POST | `/admin/categories/:id/restore` | Khôi phục danh mục đã lưu trữ |

## Luật nghiệp vụ chính

- **Giao dịch**: loại INCOME/EXPENSE lấy theo danh mục, số tiền nguyên dương (VND). Không dùng được danh mục đã lưu trữ hoặc của user khác.
- **Số dư** = tổng thu − tổng chi − (nạp tiết kiệm − rút tiết kiệm); luôn tính từ dữ liệu, không lưu.
- **Múi giờ**: mọi nhóm theo tháng/ngày dùng Asia/Ho_Chi_Minh (UTC+7). `month=YYYY-MM`; `from` tính bao gồm, `to` không bao gồm.
- **Danh mục**: `userId = null` là danh mục hệ thống (admin quản lý). Tên không trùng (không phân biệt hoa thường) trong phạm vi hệ thống + của user, theo từng loại. Xóa danh mục đã có giao dịch → lưu trữ (ẩn), chưa dùng → xóa hẳn.
- **Ngân sách**: chỉ cho danh mục chi tiêu, mỗi danh mục một ngân sách/tháng. `status`: `ok`, `warning` (≥ 80%), `exceeded` (≥ 100%).
- **Mục tiêu tiết kiệm**: nạp bị cắt về số còn thiếu, phải đủ số dư; đủ mục tiêu → `COMPLETED`. Rút trả toàn bộ về số dư: `WITHDRAWN` nếu đã hoàn thành, ngược lại `EARLY_WITHDRAWN`. Mục tiêu đã rút không nạp thêm được; mục tiêu còn tiền không xóa được.
- **Báo cáo**: so với tháng trước (|thay đổi| ≤ 5% = `stable`), cơ cấu theo danh mục, giao dịch lớn/nhỏ nhất, dự báo tháng sau bằng trung bình có trọng số (≥ 3 tháng quan sát, ngược lại trung bình cộng).
- **Admin**: user bị khóa → token hiện có bị 403, không đăng nhập được. Admin không tự khóa / tự hạ quyền.
