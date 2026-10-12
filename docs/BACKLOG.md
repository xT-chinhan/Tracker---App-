# Backlog — việc để làm sau

Cập nhật: 2026-10-08. Ưu tiên hiện tại: **trợ lý AI** (`ai/`). Các mục dưới đây tạm hoãn.

## 0. Trợ lý AI — việc còn lại phía backend
- **pgvector**: embedding đang lưu `Bytes` (Float32) trong `AiExample`, kNN chạy trong tiến trình (`AiRepo.knnRows` → provider `similarExamples`), đủ nhanh vì kho mỗi user nhỏ. Khi kho chung lớn (> vài chục nghìn dòng) chuyển sang pgvector: đổi image `postgres:16-alpine` → image có pgvector (vd `pgvector/pgvector:pg16`, bản Debian) — **phải dump/restore volume `db-data`**, không đổi image tại chỗ; thêm cột `vector(1024)` + index HNSW, thay phần thân `knnRows`/`similar` bằng `ORDER BY embedding <=> $q LIMIT k` (giao diện provider giữ nguyên).
- Image Docker của API chưa chứa `ai/` (build context chỉ `backend/`) → cần đưa `ai/` vào image (đổi context sang gốc repo hoặc copy) và cài `tsx`; hiện thiếu `ai/` thì ghi-giao-dich báo chưa sẵn sàng.
- Hàng đợi gọi Ollama đang trong tiến trình: chạy nhiều instance API cần hàng đợi chung (Redis / bảng job).
- Giao diện chat (app + admin "Trung tâm học AI") chờ mockup được duyệt; API đã đủ (`/ai/*`, `/admin/ai/*`).

## 1. App mobile Flutter
- Thiết kế đã duyệt: `design/mockup/` (25 màn), `design/tokens.md` (map 1:1 sang `ThemeData`), `design/DESIGN.md`.
- Tab bar: Trang chủ · Lịch sử · [＋] · Báo cáo · Cài đặt. Chạm ＋ = Ghi giao dịch; nhấn giữ = menu Thu nhập / Chuyển tiền / mẫu nhập nhanh.
- API đã đủ cho mọi màn (Swagger `/docs`, sinh client từ `openapi.json`). App đọc cấu hình qua `GET /api/config/public` (bảo trì, tính năng bật/tắt, phiên bản bắt buộc cập nhật).
- Tài khoản dựng màn: `demo@thuchi.vn / demo123` (khớp mockup).
- Cần trước: cài Flutter SDK (`~/flutter`).

## 2. Quét QR → mở app ngân hàng điền sẵn
- Nghiên cứu: [research/qr-thanh-toan.md](research/qr-thanh-toan.md).
- Tiêu chí user chốt: app ngân hàng mở ra đã điền đủ STK + người nhận + số tiền + nội dung, user chỉ bấm xác nhận.
- Đạt tiêu chí (qua link ký của Casso `dl.vietqr.io`, cần tham số `url=https://…`): MB Bank, VietinBank iPay, BIDV, ACB ONE, OCB OMNI (~40% người dùng, số liệu 2022).
- Ngân hàng khác: chỉ mở app → phương án sinh ảnh VietQR động có số tiền + nội dung để app ngân hàng quét.
- Rủi ro: phụ thuộc dịch vụ miễn phí của Casso (không SLA, dữ liệu đi qua server họ → ghi vào chính sách quyền riêng tư); chỉ đọc được mã VietQR (QR ví/VNPay merchant không chuyển qua ngân hàng được); không có callback → khoản chi ở trạng thái "chờ", user xác nhận khi quay lại; không dùng logo VietQR khi chưa xin NAPAS.
- **Bước tiếp:** test link mẫu trên điện thoại thật có cài MB/BIDV trước khi làm. Ước tính ~2 tuần (backend 2–3 ngày: bảng ngân hàng + deeplink admin sửa được; mobile 6–9 ngày).
- Làm cùng app mobile; cần mockup màn "Quét QR thanh toán" / "Kiểm tra khoản chi" / sheet "Mở <ngân hàng>" được duyệt trước.

## 3. Push thông báo (FCM)
- Hiện thông báo chỉ trong app (cảnh báo ngân sách, định kỳ tạm dừng, broadcast). Thêm endpoint đăng ký token thiết bị + gửi push. Làm cùng app mobile.

## 4. Vay / nợ
- Ghi khoản cho vay / đi vay, nhắc hạn, tất toán. Cần thiết kế nghiệp vụ + mockup.

## 5. Vận hành / production
- SMTP thật: cấu hình trên trang Cấu hình hệ thống (hoặc `SMTP_*`) để OTP gửi email thật.
- Rate limit đang đếm trong RAM → nếu chạy nhiều instance API cần Redis.
- Tổng số dư > ~9 triệu tỷ (2^53) mất chính xác JSON — hiện không thực tế, ghi nhận.
- Health 503 khi DB rớt chưa test tự động.

## 6. Dọn dẹp nhỏ
- Tài khoản cũ `admin@tracker.local` (từ `backend/.env`) vẫn trong DB dev, hiện trong "Đăng ký gần đây" — xóa hoặc đổi `ADMIN_EMAIL` trong `backend/.env` sang `admin@thuchi.vn`.
- `design/stitch/` (3 màn Stitch dở, đã gitignore) — xóa nếu không cần.
