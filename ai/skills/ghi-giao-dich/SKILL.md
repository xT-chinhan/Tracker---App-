---
name: ghi-giao-dich
description: Biến câu tiếng Việt tự do ("ca phe 45k, grab 30k hôm qua trả momo") thành nháp giao dịch thu/chi để người dùng xác nhận / sửa / hủy.
model: gemma2:2b (Ollama, format = JSON schema, temperature 0)
---

# ghi-giao-dich

## Đầu vào
- `text`: câu người dùng.
- `ctx: UserContext` — chỉ dữ liệu của chính user: danh mục (hệ thống ∪ của user), ví, `now`.
- (V3/V4) kho ví dụ đã xác nhận + sổ luật đã học **của user đó**.

## Pipeline (biến thể V1–V4; V0 = chỉ model)
1. `parser/` (code, không LLM): tách khoản, số tiền (`45k`, `1tr2`, `2 củ`, `2 lít`, `nửa củ`, `890.000đ`), ngày (`hôm qua`, `thứ 2 tuần trước`, `15/9`, `mùng 2`), ví (`trả momo`, `ck mb`, `tcb`).
   Không có số tiền → **hỏi lại**, không gọi model.
2. Luật đã học (V4): `từ khóa → danh mục` đủ ≥ 3 lần xác nhận, độ chính xác ≥ 0.85 → chốt danh mục, model không được ghi đè.
3. Prompt ngắn (`prompt.ts`) + ví dụ: V2 = 5 ví dụ cố định, V3/V4 = 5 ví dụ gần nhất (kNN embedding).
4. gemma2:2b chỉ điền `title` + `categoryName` (enum khóa) cho từng khoản đã tách (`schema.ts`).
5. Sửa JSON không cần LLM → validate → retry 1 lần kèm lỗi → lùi về "Chi khác"/"Thu khác".
6. Hậu kiểm: `type` lấy theo danh mục; tiền/ngày/ví lấy từ parser (model không được đụng).
7. Trả nháp → người dùng xác nhận / sửa / hủy → `learn/` ghi ví dụ + đếm luật.

## Đầu ra
`Draft { ask: boolean, items: { title, amount, categoryName, type, date (YYYY-MM-DD), walletName | null }[] }`
