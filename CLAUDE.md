# App Tracker (Thu Chi) — ghi chú cho Claude

Dự án độc lập. Bản Flutter + Firestore cũ (App_Quan_ly_chi_tieu_ca_nhan) chỉ dùng làm bối cảnh lúc đầu, **không tham khảo lại**. Luật nghiệp vụ nằm trong `backend/` (code + `backend/README.md`) và được e2e bảo vệ.

## Trạng thái (2026-10-08)
- `backend/` (NestJS + Prisma + Postgres) và `admin/` (React, đúng mockup đã duyệt) xong trên `main`, gồm Cấu hình hệ thống.
- `npm run test` = verify-demo (564) + API e2e (708) + admin Playwright (44), tất cả pass.
- Tài khoản demo: `admin@thuchi.vn / admin123`, `demo@thuchi.vn / demo123` (khớp mockup mobile).
- Tiếp theo: app mobile Flutter (máy chưa cài Flutter SDK). Thiết kế đã duyệt ở `design/mockup/` (25 màn), token ở `design/tokens.md`, `design/DESIGN.md`. App đọc cấu hình qua `GET /api/config/public`.
- Tab bar mobile: Trang chủ · Lịch sử · [＋] · Báo cáo · Cài đặt. Chạm ＋ = Ghi giao dịch; nhấn giữ = menu Thu nhập / Chuyển tiền / mẫu nhập nhanh.
- Để sau: push FCM (làm cùng mobile), vay/nợ.

## Quy tắc làm việc
- **Giao diện phải có mockup và được duyệt trước khi dựng** (web, mobile, admin). Backend/API thì làm thẳng. Mockup đặt trong `design/`, cùng style ảnh mẫu `design/reference.png` (tối giản, nền trắng ngà, gần đơn sắc).
- Skill thiết kế có sẵn trên máy: `~/.agents/skills/` (minimalist-ui, ui-ux-pro-max, apple-design, emil-design-eng, high-end-visual-design, stitch-design-taste…) và `~/.gemini/antigravity/skills/` (mobile-design, design-md, kpi-dashboard-design…). Stitch MCP đã kết nối ở profile eduteam.
- Việc nặng (Playwright/headless browser, build Docker, render) chạy **tuần tự**, tối đa 1 trình duyệt headless cùng lúc — máy từng khởi động lại vì chạy song song.
- Agent làm song song thì dùng git worktree + DB/port riêng, merge vào `main` sau khi test pass.
- Ghi chú/tài liệu của dự án lưu trong repo này, không lưu vào memory profile.
