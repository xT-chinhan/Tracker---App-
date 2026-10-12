---
name: de-xuat-khoa
scope: ADMIN
output: draft (LockDraft)
providers: [admin.userActivity]
llm: không gọi model (lý do = luật của phat-hien-bat-thuong/rules.ts)
---
# de-xuat-khoa — đề xuất khóa tài khoản (nháp, admin xác nhận)

**Khi nào**: "đề xuất khóa hung.vu89@…", "có nên khóa user Tú Anh không", "khóa giúp tài khoản Nguyễn Văn A".

**Pipeline** (code):
1. Xác định tài khoản: email chính xác; không có email → mọi token tên người dùng nhắc phải có trong họ tên. 0 kết quả / nhiều kết quả → `askBack`.
2. Chặn: chính mình, đã bị khóa, là quản trị viên → không tạo nháp, giải thích.
3. Chạy luật bất thường cho tài khoản đó. Không có dấu hiệu → không đề xuất (admin vẫn có thể khóa thủ công).
4. Có dấu hiệu → `draft = { kind: 'lock-user', userId, email, reasons[] }` với lý do kèm số liệu từ dữ liệu. Backend chỉ gọi `PATCH /admin/users/:id {status: LOCKED}` sau khi admin bấm xác nhận.

**Guardrails**: `adminGuard`; không bao giờ tự khóa; không có lý do từ dữ liệu thì không có nháp.
