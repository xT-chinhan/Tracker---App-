---
name: meo-tiet-kiem
scope: USER
output: text
providers: [user.categoryHistory (params months = 3 tháng đủ gần nhất)]
llm: chọn 2–3 id mẹo từ enum (JSON {ids})
---
# meo-tiet-kiem — mẹo tiết kiệm bám theo chi tiêu thật

**Khi nào**: "cho mình vài mẹo tiết kiệm", "làm sao bớt tiền ăn uống", "tiêu nhiều quá phải làm sao".

**Pipeline**:
1. Code xếp danh mục chi theo TB 3 tháng. Người dùng nhắc danh mục (ăn uống, cà phê, grab, shopee…) → trọng tâm là danh mục đó; không thì top 3.
2. Kho mẹo tĩnh `tips.json` (không chứa số). Model chỉ CHỌN 2–3 id trong enum = mẹo của danh mục trọng tâm + mẹo chung.
3. Hậu kiểm: luôn có ≥ 1 mẹo của danh mục trọng tâm đầu tiên; model hỏng → lấy mẹo đầu của từng danh mục.
4. Reply = câu số liệu (TB/tháng từ context, `meta.computed`) + các mẹo nguyên văn.

**Guardrails**: `userGuard`; không khuyên đầu tư/vay; số chỉ từ code.
