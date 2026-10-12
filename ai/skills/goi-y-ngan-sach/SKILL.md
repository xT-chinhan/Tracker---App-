---
name: goi-y-ngan-sach
scope: USER
output: draft (BudgetPlanDraft)
providers: [user.categoryHistory (params months = 3 tháng đủ gần nhất), user.budgets (params month)]
llm: 1 câu lời khuyên (llmSentence), không được chứa số
---
# goi-y-ngan-sach — gợi ý ngân sách từ 3 tháng gần nhất

**Khi nào**: "gợi ý ngân sách tháng sau", "nên đặt ngân sách bao nhiêu", "lập ngân sách giúp mình".

**Tính bằng code**:
- Tháng đích: nói rõ ("tháng sau", "tháng 11") → tháng đó; không nói → tháng này nếu chưa có ngân sách, ngược lại tháng sau.
- Mỗi danh mục chi: **trung vị** chi 3 tháng (tháng không chi tính 0) — bền với khoản mua lớn một lần (user demo: máy giặt + tủ lạnh 27,8 triệu tháng 8 làm TB Mua sắm thành 9,3 triệu, trung vị chỉ 78 nghìn). Chỉ lấy danh mục có chi ≥ 2/3 tháng và trung vị ≥ 200.000đ, tối đa 6 mục, xếp giảm dần.
- Hạn mức = trung vị làm tròn LÊN bội 50.000đ (tối thiểu 100.000đ). Ngân sách tổng = trung vị tổng chi tháng làm tròn lên bội 100.000đ. Reply hiện cả trung vị và TB.
- Chưa đủ 2 tháng có chi → không gợi ý.

**Đầu ra**: `draft = { kind: 'budget-plan', month, overall, items[{categoryName, limitAmount, avg3m, median3m, monthsSeen}] }`. Người dùng xác nhận/sửa → backend gọi `POST /budgets` (tên danh mục → id của chính user). Tháng đích đã có ngân sách thì reply cảnh báo sẽ cập nhật.

**Guardrails**: `userGuard`; mọi số tính từ context, nằm trong `meta.computed`.
