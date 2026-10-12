---
name: tong-ket-thang
scope: USER
output: text
context: [] — gọi `monthSummary {month, limit}` (tháng hỏi + tháng trước) và `periodSummary {from,to}` (MỚI) qua context.get
llm: 1 câu nhận xét (llmSentence), không được chứa số
---
# tong-ket-thang — tổng kết thu chi theo tháng / khoảng thời gian

**Khi nào**: "tháng này tiêu bao nhiêu", "tổng kết tháng 9", "tuần này xài hết bao nhiêu", "so với tháng trước chi nhiều hơn không", "chi nhiều nhất vào khoản gì".

**Dữ liệu**: `parsePeriod` (lib/period.ts). Không có / là tháng → `monthSummary {month}` của tháng đó và tháng trước. Tuần, ngày, N ngày qua, khoảng → `periodSummary {from,to}` (MỚI, backend chưa có: lùi về tổng kết cả tháng chứa khoảng đó và nói rõ).

**Trả lời** (code template): thu, chi, chênh lệch; top 3 danh mục chi (số tiền + %); % danh mục và % so với tháng trước do code tính (±5% = ổn định như /stats/report; tháng hiện tại có ghi chú "chưa hết"; nằm trong `meta.computed`); khoản chi lớn nhất nếu provider có `largestExpense` (MỚI).
Model chỉ viết 1 câu nhận xét từ dữ kiện định tính (thu > chi, xu hướng, danh mục lớn nhất). Câu bị loại nếu có chữ số / số viết bằng chữ / không phải tiếng Việt / > 220 ký tự → dùng câu dự phòng của code.

**Guardrails**: `userGuard`; số chỉ từ context; tháng không có dữ liệu → nói chưa có giao dịch.
