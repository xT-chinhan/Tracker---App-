---
name: kiem-tra-ngan-sach
scope: USER
output: text
context: [] — gọi `budgets {month}` qua context.get
llm: 1 câu nhắc/động viên (llmSentence), không được chứa số
---
# kiem-tra-ngan-sach — tình trạng ngân sách

**Khi nào**: "ngân sách ăn uống còn bao nhiêu", "tháng này lố ngân sách chưa", "còn được tiêu bao nhiêu mỗi ngày".

**Dữ liệu**: `budgets {month}` (= `GET /budgets?month=`: limit, spent, percentage, `status` ok/warning/exceeded theo ngưỡng cấu hình). Còn lại = limit − spent (code). Tháng lấy từ câu ("tháng trước", "tháng 9"), mặc định tháng hiện tại.

**Trả lời** (code):
- Hỏi danh mục có ngân sách → dòng của danh mục đó (đã chi / hạn mức / %, còn lại hoặc vượt) + mỗi ngày còn chi được = `floor(còn lại / số ngày còn lại của tháng)` (chỉ tháng hiện tại; số này nằm trong `meta.computed`).
- Hỏi danh mục chưa có ngân sách → nói rõ chưa đặt + ngân sách tổng.
- Hỏi chung → ngân sách tổng + mỗi ngày còn chi + các mục cảnh báo/vượt + các mục trong hạn mức.
- Chưa có ngân sách → nói chưa đặt, gợi ý `goi-y-ngan-sach`.
Model viết 1 câu nhắc từ trạng thái (định tính); câu không đạt kiểm tra → câu dự phòng.

**Guardrails**: `userGuard`; số chỉ từ context hoặc `meta.computed`.
