---
name: huong-dan-quan-tri
scope: ADMIN
output: text
providers: [] (FAQ tĩnh faq.json, viết từ backend/README.md mục Admin + Cấu hình hệ thống và trang admin/)
llm: chỉ chọn 1 id trong 2–3 ứng viên khi điểm từ khóa sát nhau
---
# huong-dan-quan-tri — cách dùng trang quản trị

**Khi nào**: "bật bảo trì ở đâu", "gửi email thử SMTP", "khóa user thế nào", "tắt đăng ký mới", "đổi ngưỡng cảnh báo ngân sách".

**Pipeline**: như `huong-dan` (lib/faq.ts) trên 15 mục FAQ quản trị. Câu trả lời nguyên văn FAQ.

**Guardrails**: `adminGuard`; không bịa tính năng.
