---
name: tong-ket-thang
scope: USER
output: text
providers: [user.monthReport (params month), user.periodSummary (params from,to)]
llm: 1 câu nhận xét (llmSentence), không được chứa số
---
# tong-ket-thang — tổng kết thu chi theo tháng / khoảng thời gian

**Khi nào**: "tháng này tiêu bao nhiêu", "tổng kết tháng 9", "tuần này xài hết bao nhiêu", "so với tháng trước chi nhiều hơn không", "chi nhiều nhất vào khoản gì".

**plan**: `parsePeriod` (lib/period.ts). Không có / là tháng → `user.monthReport {month}` (= `GET /stats/report?month=`). Tuần, ngày, N ngày qua, khoảng → `user.periodSummary {from,to}` (= `/stats/summary` + `/stats/by-category`).

**Trả lời** (code template): thu, chi, chênh lệch; top 3 danh mục chi (số tiền + %); so với tháng trước (theo `comparison` của backend, ±5% = ổn định, tháng hiện tại có ghi chú "chưa hết"); khoản chi lớn nhất; hỏi về thu nhập thì thêm nguồn thu.
Model chỉ viết 1 câu nhận xét từ dữ kiện định tính (thu > chi, xu hướng, danh mục lớn nhất). Câu bị loại nếu có chữ số / số viết bằng chữ / không phải tiếng Việt / > 220 ký tự → dùng câu dự phòng của code.

**Guardrails**: `userGuard`; số chỉ từ context; tháng không có dữ liệu → nói chưa có giao dịch.
