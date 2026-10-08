# Thu Chi Admin

Trang quản trị cho nền tảng thu/chi: Vite + React + TypeScript, Tailwind CSS, shadcn/ui, TanStack Query, React Router, Recharts.

Chức năng: đăng nhập (chỉ tài khoản ADMIN), tổng quan hệ thống, người dùng (tìm/lọc/phân trang, khóa/mở khóa, cấp/hạ quyền, trang chi tiết), giao dịch (lọc theo người dùng/loại/tháng/từ khóa), danh mục hệ thống (thêm/sửa/xóa/lưu trữ/khôi phục), tài khoản (đổi tên, đổi mật khẩu).

## Cài đặt

```bash
cd admin
npm install
cp .env.example .env   # sửa VITE_API_URL nếu backend không chạy ở :3000
npm run dev            # http://localhost:5173
```

Backend phải cho phép origin của trang admin qua `CORS_ORIGINS` (vd: `http://localhost:5173`).

## Biến môi trường

| Biến | Mặc định | Ý nghĩa |
|---|---|---|
| `VITE_API_URL` | `http://localhost:3000/api` | URL gốc của API (có `/api`) |

## Scripts

| Lệnh | Việc |
|---|---|
| `npm run dev` | Chạy dev server |
| `npm run build` | Typecheck + build ra `dist/` |
| `npm run preview` | Xem bản build |
| `npm run typecheck` | Chỉ kiểm tra kiểu (cả `src/` và `e2e/`) |
| `npm run test:e2e` | Chạy Playwright E2E (xem dưới) |

## Kiểm thử E2E (Playwright)

Test tự seed dữ liệu qua API (mỗi lần chạy dùng hậu tố riêng nên chạy lại được), tự bật dev server ở `:5174`, chụp màn hình vào `/tmp/admin-shots/`. Cần một backend riêng đang chạy, ví dụ DB `tracker_admin_e2e` ở cổng 3001:

```bash
# 1 lần: tạo DB + migrate + seed (tạo admin@tracker.local / admin123)
docker compose exec db createdb -U tracker tracker_admin_e2e
cd backend
export DATABASE_URL='postgresql://tracker:tracker@localhost:5433/tracker_admin_e2e?schema=public'
ADMIN_EMAIL=admin@tracker.local ADMIN_PASSWORD=admin123 npx prisma migrate deploy && npx prisma db seed
PORT=3001 CORS_ORIGINS=http://localhost:5174 node dist/main &

# chạy test
cd ../admin
npx playwright install chromium   # lần đầu
npm run test:e2e
```

Tùy chỉnh: `E2E_API_URL` (mặc định `http://localhost:3001/api`), `E2E_PORT` (5174), `E2E_ADMIN_EMAIL`, `E2E_ADMIN_PASSWORD`, `E2E_SHOTS`.
