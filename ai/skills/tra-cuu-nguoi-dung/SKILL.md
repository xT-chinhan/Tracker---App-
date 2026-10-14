---
name: tra-cuu-nguoi-dung
scope: ADMIN
output: draft (UserFilterDraft)
providers: [] (backend chạy GET /admin/users?q=&status=&role= với filter trả về)
llm: chỉ trích tên (JSON {name}), có kiểm tra
---
# tra-cuu-nguoi-dung — câu hỏi → bộ lọc người dùng

**Khi nào**: "tìm user tên Hùng", "liệt kê tài khoản bị khóa", "có admin nào", "tra cứu hung.vu89@demo.thuchi.vn".

**Pipeline**: code bắt email (→ `q`), trạng thái (bị khóa → LOCKED, đang hoạt động → ACTIVE), vai trò (admin/quản trị → ADMIN). Không có email mà còn từ lạ → model trích tên (4 ví dụ); tên phải là chuỗi con của câu (bỏ dấu) và không chỉ gồm từ dừng.

**Đầu ra**: `draft = { kind: 'user-filter', q?, status?, role? }`. Skill không truy vấn hay trả danh sách người dùng.

**Guardrails**: `adminGuard`.
