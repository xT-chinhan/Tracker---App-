---
name: goi-y-ngan-sach
scope: USER
output: draft budgets
context: [] — gọi `monthSummary {month, limit: 20}` cho 3 tháng đủ gần nhất, `budgets {month}`
llm: 1 câu lời khuyên (llmSentence), không được chứa số
---
# goi-y-ngan-sach — gợi ý ngân sách từ 3 tháng gần nhất

**Khi nào**: "gợi ý ngân sách tháng sau", "nên đặt ngân sách bao nhiêu", "lập ngân sách giúp mình".

**Tính bằng code**:
- Tháng đích: nói rõ ("tháng sau", "tháng 11") → tháng đó; không nói → tháng này nếu chưa có ngân sách, ngược lại tháng sau.
- Mỗi danh mục chi: **trung vị** chi 3 tháng (tháng không chi tính 0) — bền với khoản mua lớn một lần (user demo: máy giặt + tủ lạnh 27,8 triệu tháng 8 làm TB Mua sắm thành 9,3 triệu, trung vị chỉ 78 nghìn). Chỉ lấy danh mục có chi ≥ 2/3 tháng và trung vị ≥ 200.000đ, tối đa 6 mục, xếp giảm dần.
- Hạn mức = trung vị làm tròn LÊN bội 50.000đ (tối thiểu 100.000đ). Ngân sách tổng = trung vị tổng chi tháng làm tròn lên bội 100.000đ. Reply hiện cả trung vị và TB.
- Chưa đủ 2 tháng có chi → không gợi ý.

**Đầu ra**: `draft = { kind: 'budgets', payload: { items: [{categoryName: null (= tổng), month, limitAmount}, {categoryName, month, limitAmount, median3m, avg3m, monthsSeen}…] } }` đúng loại nháp `budgets` của backend (POST /budgets từng dòng sau khi xác nhận). Tháng đích đã có ngân sách thì reply cảnh báo (backend sẽ báo trùng 409 cho dòng đã có — cần upsert nếu muốn "cập nhật").

**Giới hạn hiện tại**: `monthSummary.topExpenses` ở backend chỉ 5 danh mục → gợi ý tối đa 5 mục/tháng; xin backend tôn trọng `limit`.

**Guardrails**: `userGuard`; mọi số tính từ context, nằm trong `meta.computed`.
