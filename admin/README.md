# TrackerX Admin

Trang quản trị cho nền tảng thu/chi: Vite + React + TypeScript, Tailwind CSS, shadcn/ui, TanStack Query, React Router, Recharts.

Chức năng (giao diện theo mockup đã duyệt `design/admin-mockup/`):

| Màn | Nội dung |
|---|---|
| A1 Đăng nhập | Chỉ tài khoản ADMIN; báo lỗi sai mật khẩu / bị khóa / hết phiên / 429 (thử quá nhiều lần) |
| A2 Tổng quan | 3 thẻ KPI (người dùng, giao dịch, tổng thu/chi/chênh lệch), biểu đồ thu chi 6 tháng (tooltip, "Xem dạng bảng"), mục tiêu tiết kiệm theo trạng thái, đăng ký gần đây, skeleton khi tải |
| A3 Người dùng | Tìm kiếm, select vai trò, chip trạng thái có số đếm, menu "…" trên dòng, hộp xác nhận, toast có Hoàn tác |
| A4 Chi tiết người dùng | Số dư/thu/chi/tiết kiệm, ví + số dư từng ví, xu hướng 6 tháng, hồ sơ, 4 giao dịch gần đây (link sang Giao dịch đã lọc) |
| A5 Giao dịch | Lọc người dùng, ví (chỉ bật khi đã chọn người dùng), tháng, Tất cả/Chi/Thu, tìm kiếm; cột Ví; xuất CSV theo bộ lọc; empty state |
| A6 Danh mục | Tab Chi/Thu (thứ tự tiếng Việt từ backend), số lượt dùng, panel sửa bên phải (tên, icon, màu), lưu trữ có Hoàn tác, mục đã lưu trữ có Khôi phục |
| A7 Thông báo | Soạn (bản nháp tự lưu), xem trước trên điện thoại (trong app / đẩy), gửi tới mọi user đang hoạt động, lịch sử kèm số người nhận |
| A8 Tài khoản | Đổi tên, đổi mật khẩu (lỗi hiện dưới ô; lưu token mới backend trả về) |
| A9 Cấu hình | `/settings/:mục` — sub-nav Chung, Đăng ký & truy cập, Email (SMTP), Mật khẩu & OTP, Nghiệp vụ, Ứng dụng di động, Lịch sử thay đổi. Thanh "N thay đổi chưa lưu · Hủy · Lưu thay đổi" dính đáy (khóa khi còn lỗi, nêu lỗi ở đâu), hàng đã sửa có chấm + "Trước: …", số thay đổi trên sub-nav, lỗi kiểm tra ngay dưới ô (giống backend), rời trang khi chưa lưu phải xác nhận. Bảo trì bật ngay sau hộp xác nhận (banner/viền/switch vàng, tự tắt theo giờ dự kiến). SMTP: mật khẩu không hiện lại ("Thay mật khẩu"), chip trạng thái, gửi thử (kết quả inline + toast). Thanh xem trước ngưỡng ngân sách, xem trước hộp "Cần cập nhật" trên điện thoại, lịch sử lọc theo mục + phân trang |

Dưới 1280px sidebar thu thành rail icon 72px.

## Hệ thống giao diện

- Token nằm duy nhất trong `src/index.css` (`@theme static`): màu, font Be Vietnam Pro, bo góc, bóng, thang chữ (`text-headline`, `text-title-m`…). Tên màu theo quy ước shadcn (`background`, `primary`, `muted`…) nên mọi component dùng thẳng utility Tailwind; `var(--color-…)` dùng cho Recharts.
- `src/components/ui/*` là component shadcn đã chỉnh lại theo mockup (nút viên thuốc, select viên thuốc, bảng hairline 56px, segmented control, dialog 460px, toast có Hoàn tác).
- `src/lib/utils.ts` cấu hình `tailwind-merge` biết thang chữ riêng để `cn()` không gộp nhầm.

## Cài đặt

Cách nhanh: ở thư mục gốc `npm run setup` rồi `npm run dev` (chạy cả backend). Chạy riêng admin:

```bash
cd admin
npm install
cp .env.example .env   # sửa VITE_API_URL nếu backend không chạy ở :3000
npm run dev            # http://localhost:5173  — đăng nhập admin@thuchi.vn / admin123
```

Backend phải cho phép origin của trang admin qua `CORS_ORIGINS` (vd: `http://localhost:5173`).

Production: `docker compose --profile app up -d --build` ở thư mục gốc => `admin/Dockerfile` build với `VITE_API_URL=/api`, nginx (`nginx.conf`) phục vụ bản tĩnh ở http://localhost:8080 (SPA fallback, cache `/assets`) và proxy `/api`, `/docs` sang container api, nên không cần CORS.

## Biến môi trường

| Biến | Mặc định | Ý nghĩa |
|---|---|---|
| `VITE_API_URL` | `http://localhost:3000/api` | URL gốc của API (có `/api`); có thể là đường dẫn tương đối `/api` khi chạy sau reverse proxy |

## Scripts

| Lệnh | Việc |
|---|---|
| `npm run dev` | Chạy dev server |
| `npm run build` | Typecheck + build ra `dist/` |
| `npm run preview` | Xem bản build |
| `npm run typecheck` | Chỉ kiểm tra kiểu (cả `src/` và `e2e/`) |
| `npm run test:e2e` | Chạy Playwright E2E (xem dưới) |

## Kiểm thử E2E (Playwright)

Test tự seed dữ liệu qua API (người dùng, ví, giao dịch, mục tiêu; mỗi lần chạy dùng hậu tố riêng nên chạy lại được), tự bật dev server ở `:5174`, chụp màn hình vào `/tmp/admin-shots/`. `e2e/10-visual.spec.ts` chụp từng màn 1440×900 vào `/tmp/admin-real-shots/` để so với `design/admin-mockup/shots/`. Số liệu kỳ vọng tính theo "nền + phần seed" nên chạy được trên DB đã có dữ liệu demo.

Cách nhanh: ở thư mục gốc `npm run test` (tự tạo DB test có dữ liệu demo, bật API `:3001`, chạy cả backend e2e lẫn admin e2e, dọn dẹp). Chạy tay cần một backend riêng đang chạy với `NODE_ENV=test` (nới rate limit đăng nhập), ví dụ DB `tracker_admin_e2e` ở cổng 3001:

```bash
# 1 lần: tạo DB + migrate + seed (tạo admin@thuchi.vn / admin123)
docker compose exec -T db createdb -U tracker tracker_admin_e2e
cd backend
npm run build
export DATABASE_URL='postgresql://tracker:tracker@localhost:5433/tracker_admin_e2e?schema=public'
npx prisma migrate deploy && ADMIN_EMAIL=admin@thuchi.vn ADMIN_PASSWORD=admin123 npx prisma db seed
PORT=3001 CORS_ORIGINS=http://localhost:5174 NODE_ENV=test node dist/main &

# chạy test
cd ../admin
npx playwright install chromium   # lần đầu
npm run test:e2e
```

Tùy chỉnh: `E2E_API_URL` (mặc định `http://localhost:3001/api`), `E2E_PORT` (5174), `E2E_ADMIN_EMAIL` (admin@thuchi.vn), `E2E_ADMIN_PASSWORD` (admin123), `E2E_SHOTS`, `E2E_REAL_SHOTS`.

Bộ test (44): đăng nhập/phiên/429, tổng quan (đối chiếu số học + bảng + skeleton), người dùng (tìm, phân trang, lọc, khóa → token 403 → mở khóa → token cũ 401, Hoàn tác, cấp/hạ quyền, tự khóa bị chặn, tablet), chi tiết (ví và số dư từng ví), giao dịch (lọc người dùng/ví/loại/tháng/từ khóa, CSV, empty state), danh mục (thứ tự tiếng Việt, CRUD, lưu trữ/Hoàn tác/khôi phục), tài khoản (đổi mật khẩu vẫn giữ phiên), bố cục 1440/1024 không tràn ngang (hàng KPI tổng quan xuống dòng dưới 1280px), thông báo (người nhận = user đang hoạt động, user bị khóa không nhận, lịch sử), ảnh so sánh, cấu hình hệ thống (7: sửa + lưu từng mục kiểm tra lại qua API, lỗi chặn lưu, Hủy, bảo trì → token user 503 → tắt, gửi email thử lỗi rõ khi không có máy chủ và thành công với máy chủ SMTP giả trong test, lịch sử lọc / phân trang / bí mật ẩn, chặn rời trang, ảnh 14a–14j). Spec cấu hình khôi phục mọi giá trị ban đầu khi xong.
