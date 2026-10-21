# Quy định cho AI agent (Codex, Gemini, Cursor, Claude…)

Đọc `CLAUDE.md` (bối cảnh + quy tắc làm việc) trước khi sửa code. Hai quy định bắt buộc:

1. **Địa chỉ API của app là CỐ ĐỊNH:** `https://tracker-xt.freepro.online/api`, nằm ở `mobile/app/lib/core/config/app_environment.dart`. Không đổi, không thêm `--dart-define=API_URL`, không trỏ app sang localhost / IP LAN. Chi tiết và cách xử lý khi không kết nối được: [`API-URL.md`](API-URL.md).
2. **Giao diện phải có mockup được duyệt** (thư mục `design/`) trước khi dựng.
