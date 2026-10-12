---
name: tim-giao-dich
scope: USER
output: draft search_filter (target transactions)
context: [categories, balance (lấy tên ví)]
llm: chỉ trích từ khóa (JSON {keyword}), có kiểm tra
---
# tim-giao-dich — câu hỏi → bộ lọc giao dịch

**Khi nào**: "tìm khoản grab tuần trước", "hôm qua mình chi những gì", "liệt kê các khoản trên 500k", "lần cuối trả tiền điện là bao giờ", "xem các giao dịch momo".

**Đầu ra**: `draft = { kind: 'search_filter', payload: { target: 'transactions', q?, month?, from?, to?, type?, categoryName?, walletName?, minAmount?, maxAmount? } }`. Backend hiện chỉ dùng `q` + `month`; from/to/type/categoryName/walletName/min/max là trường MỚI cần backend map (tên → id của chính user) sang `GET /transactions`; min/max API chưa có. Skill **không** trả danh sách giao dịch.

**Pipeline**:
1. Code: thời gian (`parsePeriod`: hôm nay/qua/kia, thứ X (tuần trước), tuần này/trước, tháng N, N ngày qua, từ dd/mm đến dd/mm, gần đây = 30 ngày); loại thu/chi theo từ khóa; ví (tên + bí danh); danh mục (đúng tên danh mục của user, lấy luôn loại theo danh mục); số tiền (`parser/money.ts` của Track A, chỉ import) + "trên/dưới/từ…đến".
2. Còn từ chưa giải thích được → model trích `keyword` (5 ví dụ few-shot). Hậu kiểm: phải là chuỗi con của câu (bỏ dấu), ≤ 30 ký tự, không số, không phải từ dừng / tên ví / tên danh mục. Không đạt → bỏ.
3. Không có tiêu chí nào → mặc định tháng hiện tại.

**Guardrails**: `userGuard` (từ chối "giao dịch của user B"); filter luôn do backend chạy với userId trong JWT.
