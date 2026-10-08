# Thu Chi — Quản lý thu chi cá nhân

Nền tảng giúp người Việt ghi chép thu chi hằng ngày: nhiều ví (tiền mặt, ngân hàng, ví điện tử), chuyển tiền giữa ví, ngân sách tháng có cảnh báo 80% / 100%, mục tiêu tiết kiệm, giao dịch định kỳ, mẫu nhập nhanh, báo cáo và dự báo. Người dùng dùng app di động; quản trị viên dùng trang admin web.

## Kiến trúc

```
                ┌──────────────────────────┐
  App mobile    │  Flutter (dự kiến)       │──┐
  (người dùng)  │  design/mockup, tokens.md│  │
                └──────────────────────────┘  │  HTTPS / JSON, JWT
                ┌──────────────────────────┐  │
  Admin web     │  admin/  Vite + React    │──┤
  (quản trị)    │  shadcn/ui, TanStack     │  │   (Docker: nginx phục vụ tĩnh,
                └──────────────────────────┘  │    /api proxy => cùng origin)
                                              ▼
                ┌───────────────────────────────────────────┐
                │ backend/  NestJS 11 + Prisma 6 (/api)     │
                │ auth · ví · giao dịch · chuyển tiền ·      │
                │ ngân sách · tiết kiệm · định kỳ (cron) ·   │
                │ thông báo · thống kê · CSV · admin         │
                └───────────────────────┬───────────────────┘
                                        ▼
                               PostgreSQL 16 (Docker)
```

| Thành phần | Thư mục | Công nghệ | Trạng thái | Tài liệu |
|---|---|---|---|---|
| Backend API | `backend/` | NestJS 11, Prisma 6, PostgreSQL 16 | v1 | [backend/README.md](backend/README.md) |
| Admin web | `admin/` | Vite, React 19, Tailwind 4, shadcn/ui, Recharts | v1 | [admin/README.md](admin/README.md) |
| Thiết kế | `design/` | Mockup HTML đã duyệt (mobile 25 màn, admin), `tokens.md`, `DESIGN.md` | Đã duyệt | [design/DESIGN.md](design/DESIGN.md) |
| App mobile | — | Flutter | Dự kiến | xem Lộ trình |

## Chạy nhanh (3 lệnh)

Cần Node 22+, npm, Docker (compose v2).

```bash
npm run setup     # cài dependency, tạo .env, bật PostgreSQL (Docker :5433), migrate, seed, nạp dữ liệu demo (~30s)
npm run dev       # API http://localhost:3000/api (Swagger /docs) + Admin http://localhost:5173
npm run test      # toàn bộ kiểm thử (backend e2e + admin e2e) trên DB test riêng có dữ liệu demo
```

`npm run setup` chạy lại được (không ghi đè `.env` đã có, seed idempotent). Lần đầu muốn đổi cổng / tên DB: `DB_PORT=5543 API_DB=tracker2 API_PORT=3100 npm run setup`.

| Lệnh gốc | Việc |
|---|---|
| `npm run setup` | Như trên |
| `npm run dev` | Bật DB nếu chưa chạy, chạy backend (watch) + admin (Vite) cùng lúc |
| `npm run test` | Xem [Kiểm thử](#kiểm-thử) |
| `npm run build` | Build backend (`backend/dist`) + admin (`admin/dist`) |
| `npm run db:seed:demo` | Nạp lại dữ liệu demo (chỉ user demo) |
| `npm run demo:verify` | Kiểm tra bất biến dữ liệu demo qua API đang chạy |
| `npm run docker:app` / `docker:down` | Bật / tắt stack Docker đầy đủ |

## Tài khoản demo

| Tài khoản | Mật khẩu | Ghi chú |
|---|---|---|
| `admin@thuchi.vn` | `admin123` | Admin web (đổi trong `.env`: `ADMIN_EMAIL` / `ADMIN_PASSWORD`) |
| `demo@thuchi.vn` | `demo123` | Nguyễn Minh Anh — dữ liệu khớp mockup mobile: 4 ví tổng 26.022.000đ, chi tháng này ~60% ngân sách 14 triệu, 3 mục tiêu tiết kiệm, 5 định kỳ, mẫu Cà phê 45k / Cơm trưa 55k / Grab 38k |
| `<tên>@demo.thuchi.vn` | `demo123` | ~39 user khác (vd `hung.vu89@demo.thuchi.vn`), 3 bị khóa, 1 là admin (`bao.tran91@demo.thuchi.vn`) |

Dữ liệu demo: 12 tháng, ~41.000 giao dịch, ~3.000 lần chuyển tiền, 76 mục tiêu đủ 4 trạng thái, 116 quy tắc định kỳ, ~340 ngân sách, 3 broadcast. Mọi bất biến nghiệp vụ được giữ (xem [backend/README.md](backend/README.md#dữ-liệu-demo-prismaseed-demots)). `npm run db:seed:demo` chỉ xóa/tạo lại user demo, không đụng user thật.

## Triển khai bằng Docker

```bash
cp .env.example .env              # đặt JWT_SECRET >= 16 ký tự (npm run setup tự sinh)
docker compose --profile app up -d --build
#   Admin: http://localhost:8080   (nginx phục vụ bản build tĩnh, /api và /docs proxy sang container api)
#   API:   http://localhost:3000/api   (truy cập trực tiếp, vd cho app mobile)
docker compose exec api npm run db:seed:demo    # (tùy chọn) nạp dữ liệu demo; hoặc SEED_DEMO=true trong .env
docker compose --profile app down               # dừng, giữ dữ liệu (thêm -v để xóa volume)
```

- `docker compose up -d` (không profile): chỉ PostgreSQL cho dev. `--profile api`: DB + API (không có admin).
- Container api: chờ DB → `prisma migrate deploy` → seed (danh mục + admin từ `ADMIN_*`) → `SEED_DEMO=true` thì nạp lại demo → chạy API. Có healthcheck cho cả 3 service.
- Admin gọi API qua `/api` cùng origin nên không cần CORS; nginx ghi đè `X-Forwarded-For` bằng IP thật và API đặt `TRUST_PROXY=1` để rate limit đếm đúng IP.

### Biến môi trường (`.env` gốc, dùng cho Docker + `npm run setup`)

| Biến | Mặc định | Ý nghĩa |
|---|---|---|
| `DB_PORT` | 5433 | Cổng PostgreSQL trên máy host |
| `API_PORT` | 3000 | Cổng API |
| `ADMIN_PORT` | 8080 | Cổng admin (nginx, profile `app`) |
| `API_DB` | tracker | Tên database (dev và container dùng chung) |
| `JWT_SECRET` | — | Bắt buộc với container, ≥ 16 ký tự |
| `JWT_EXPIRES_IN` | 30d | Hạn token |
| `ADMIN_EMAIL` / `ADMIN_PASSWORD` | admin@thuchi.vn / admin123 | Admin được seed tạo / nâng quyền |
| `SEED_DEMO` | false | `true`: mỗi lần container api khởi động nạp lại dữ liệu demo |
| `CORS_ORIGINS` | — | Origin gọi API trực tiếp (admin qua nginx không cần) |
| `TRUST_PROXY` | 1 | API đứng sau nginx; để trống nếu API ra Internet trực tiếp |
| `SMTP_HOST` `SMTP_PORT` `SMTP_SECURE` `SMTP_USER` `SMTP_PASS` `SMTP_FROM` | | Gửi OTP quên mật khẩu; `SMTP_HOST` trống → OTP in ra log. Admin có thể cấu hình SMTP ngay trên trang Cấu hình (ưu tiên hơn env) |
| `CONFIG_SECRET` | dẫn xuất từ `JWT_SECRET` | Khóa mã hóa mật khẩu SMTP lưu trong Cấu hình hệ thống |

Biến riêng khi dev: `backend/.env` (xem [backend/README.md](backend/README.md#biến-môi-trường-backendenv)), `admin/.env` (`VITE_API_URL`).

## Kiểm thử

`npm run test` chạy tuần tự, tự lo server và DB rồi dọn dẹp:

1. Tạo lại DB `tracker_test` (cổng `DB_PORT`) → migrate → seed → **nạp dữ liệu demo** (để chứng minh test không cần DB rỗng).
2. Bật API `NODE_ENV=test TZ=UTC` ở `:3001` → `verify-demo` (bất biến dữ liệu demo qua API, ~560 kiểm tra) → **backend e2e: 708 kiểm tra**.
3. Khởi động lại API → **admin e2e Playwright: 44 test** (tự bật Vite ở `:5174`).
4. Dừng API, xóa DB test (`KEEP_TEST_DB=1` để giữ). Tùy chọn: `TEST_DB`, `TEST_API_PORT`, `E2E_PORT`, `SKIP_BACKEND=1`, `SKIP_ADMIN=1`.

Kết quả gần nhất: verify-demo 0 lỗi, backend e2e 549/549, admin e2e 37/37 (~4 phút).

## Cấu trúc thư mục

```
.
├── package.json            # script gốc: setup / dev / test / build (concurrently)
├── scripts/                # setup.mjs, test.mjs, lib.mjs (chỉ dùng Node có sẵn)
├── docker-compose.yml      # db | profile api | profile app (db + api + admin nginx)
├── .env.example            # biến cho Docker + setup
├── backend/
│   ├── src/<module>/<module>.module.ts   # auth, wallets, transactions, transfers, budgets, saving-goals,
│   │                                     # recurring, quick-templates, notifications, stats, export, admin, health
│   ├── src/common/         # JWT guard, DTO, giờ VN, filter lỗi Prisma
│   ├── prisma/             # schema, migrations, seed.ts, seed-demo.ts
│   ├── scripts/            # e2e.mjs (708 kiểm tra), verify-demo.mjs
│   └── Dockerfile
├── admin/
│   ├── src/pages/          # Đăng nhập, Tổng quan, Người dùng, Chi tiết, Giao dịch, Danh mục, Thông báo, Tài khoản
│   ├── src/components/     # layout, biểu đồ, shadcn/ui đã chỉnh theo mockup
│   ├── e2e/                # Playwright (44 test)
│   ├── Dockerfile, nginx.conf
└── design/
    ├── mockup/             # mockup mobile 25 màn (390×844) + ảnh chụp
    ├── admin-mockup/       # mockup admin + ảnh chụp
    ├── tokens.md           # design token (màu, chữ, bo góc, khoảng cách)
    └── DESIGN.md
```

## Nghiệp vụ chính

Chi tiết đầy đủ + danh sách endpoint: [backend/README.md](backend/README.md#nghiệp-vụ-v1).

- **Giờ Việt Nam** cho mọi nhóm theo ngày/tháng; tiền là số nguyên VND (BigInt).
- **Ví**: số dư luôn tính từ dữ liệu = ban đầu + thu − chi ± chuyển tiền ∓ tiết kiệm. Ví có phát sinh chỉ lưu trữ được khi số dư 0.
- **Chuyển tiền / nạp tiết kiệm** không bao giờ làm ví âm (kiểm tra cả khi sửa/xóa); thu/chi thì ghi nhận thực tế, không chặn. Chuyển tiền không tính vào thu/chi.
- **Ngân sách** theo danh mục + ngân sách tổng mỗi tháng; vượt 80% / 100% sinh 1 thông báo mỗi ngưỡng, tụt dưới ngưỡng thì reset.
- **Tiết kiệm**: nạp bị cắt về số còn thiếu, đủ thì `COMPLETED`; rút trả hết về ví → `WITHDRAWN` / `EARLY_WITHDRAWN`.
- **Định kỳ**: ngày/tuần/tháng/năm × interval, giữ ngày neo (31 → cuối tháng), cron 15 phút, sinh bù, idempotent; ví/danh mục lưu trữ hoặc user bị khóa → tự tạm dừng + thông báo.
- **Tài khoản**: JWT có `tokenVersion` (đổi mật khẩu / khóa / đăng xuất mọi nơi → token cũ hết hạn), OTP quên mật khẩu, rate limit đăng nhập.
- **Admin**: tổng quan, khóa/mở + phân quyền user, giao dịch toàn hệ thống + CSV, danh mục hệ thống, broadcast tới mọi user đang hoạt động.
- **Cấu hình hệ thống** (trang "Cấu hình"): thông tin app, đăng ký, bảo trì (tự tắt theo giờ), SMTP, mật khẩu & OTP, ngưỡng ngân sách, bật/tắt tính năng, phiên bản app di động, lịch sử thay đổi. App đọc qua `GET /api/config/public`. Chi tiết: [backend/README.md](backend/README.md#cấu-hình-hệ-thống).

## Lộ trình

1. **App mobile Flutter** (tiếp theo): thiết kế đã sẵn trong `design/mockup/` (25 màn, có ảnh chụp từng màn), `design/tokens.md` ánh xạ thẳng sang `ThemeData` (ColorScheme, TextTheme, bo góc, khoảng cách); API đã đủ cho mọi màn (Swagger `/docs`). Tài khoản `demo@thuchi.vn` có dữ liệu khớp mockup để dựng màn hình.
2. **Push FCM**: thông báo ngân sách, định kỳ, broadcast đang lưu trong app → thêm đẩy qua Firebase Cloud Messaging.
3. **Vay / nợ**: ghi khoản cho vay / đi vay, nhắc hạn, tất toán.
