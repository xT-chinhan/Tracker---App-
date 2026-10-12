---
name: tien-do-tiet-kiem
scope: USER
output: text
context: [savingGoals]
llm: 1 câu động viên (llmSentence), không được chứa số
---
# tien-do-tiet-kiem — tiến độ mục tiêu tiết kiệm

**Khi nào**: "mục tiêu mua xe tới đâu rồi", "quỹ khẩn cấp được bao nhiêu", "bao giờ đủ tiền mua macbook", "các mục tiêu tiết kiệm của mình".

**Dữ liệu**: `savingGoals` (= `GET /saving-goals`: target, saved, progress, dailyRequired do backend tính). Còn thiếu = target − saved và số ngày còn lại = ⌈(hạn − now)/ngày⌉ do code tính đúng công thức backend (`meta.computed`).

**Trả lời** (code): khớp tên mục tiêu theo token (bỏ dấu, bỏ từ chung). Có → chi tiết: đã có / mục tiêu (%), còn thiếu, hạn + số ngày, cần góp/ngày (`dailyRequired` của backend) và ~/tháng (= dailyRequired × 30, nằm trong `meta.computed`). Trạng thái COMPLETED / WITHDRAWN / EARLY_WITHDRAWN / quá hạn có câu riêng. Không khớp → tổng + danh sách; nếu người dùng nêu tên mục tiêu không có → nói rõ "không thấy mục tiêu khớp".

**Guardrails**: `userGuard`; không có mục tiêu → hướng dẫn tạo.
