---
name: hoi-so-du
scope: USER
output: text
providers: [user.balance]
llm: không gọi model (câu trả lời là template thuần)
---
# hoi-so-du — hỏi số dư

**Khi nào**: "momo còn bao nhiêu", "tổng tiền các ví", "số dư techcombank", "check số dư".

**Dữ liệu**: `user.balance` (= `GET /stats/balance` của chính user): tổng, từng ví (tên, loại, số dư, lưu trữ), tiền đang nằm trong mục tiêu tiết kiệm.

**Cách trả lời** (code):
1. Chặn chung (`userGuard`): hỏi dữ liệu người khác / prompt injection / phiên không phải USER → từ chối.
2. Có nhắc tên ví của user (khớp bỏ dấu + bí danh: mb, tcb, vcb, tiền mặt…) → số dư ví đó + tổng.
3. Nhắc tên ví/ngân hàng phổ biến mà user KHÔNG có → nói rõ chưa có ví đó + liệt kê ví hiện có (không đoán).
4. Không nhắc ví → tổng + từng ví (đang dùng, giảm dần) + tiền trong mục tiêu tiết kiệm.

**Guardrails**: mọi số lấy từ context, định dạng `money()` (vd 18.672.000đ). Không gọi model nên không thể có số bịa.
