---
name: huong-dan
scope: USER
output: text
providers: [] (FAQ tĩnh faq.json, viết từ backend/README.md + design/mockup)
llm: chỉ chọn 1 id trong 2–3 ứng viên khi điểm từ khóa sát nhau
---
# huong-dan — cách dùng ứng dụng

**Khi nào**: "làm sao thêm ví", "cách đặt ngân sách", "xuất excel thế nào", "quên mật khẩu", "tạo giao dịch định kỳ".

**Pipeline**: chấm điểm từ khóa (bỏ dấu) trên 23 mục FAQ (`faq.json`) → top 3. Hai mục đầu sát điểm → model chọn id (enum); còn lại code chọn top 1. Câu trả lời là **nguyên văn** mục FAQ (đường dẫn màn hình đúng mockup: Cài đặt › Ví / Ngân sách / Tiết kiệm / Định kỳ / Danh mục / Mẫu nhập nhanh / Xuất CSV / Đổi mật khẩu; nút ＋ chạm / nhấn giữ). Không khớp mục nào → nói chưa có hướng dẫn + liệt kê chủ đề.

**Guardrails**: không bịa tính năng (chỉ nội dung FAQ); `userGuard`.
