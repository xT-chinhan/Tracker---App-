---
name: phat-hien-bat-thuong
scope: ADMIN
output: text
providers: [admin.userActivity]
llm: 1 câu tóm tắt (llmSentence), không được chứa số; model KHÔNG quyết định ai bất thường
---
# phat-hien-bat-thuong — phát hiện bất thường (code tính, model chỉ tóm tắt)

**Dữ liệu**: `admin.userActivity` (MỚI, Track C cần thêm truy vấn): mỗi user: trạng thái, vai trò, đăng nhập cuối, số giao dịch 30 ngày, chi tháng này, TB chi 3 tháng trước, khoản chi lớn nhất 30 ngày, `failedLogins24h` (chưa có trong hệ thống → bỏ trống).

**Luật** (`rules.ts`, chỉ xét role USER):
| Loại | Điều kiện |
|---|---|
| chi tiêu tăng vọt | chi tháng này ngoại suy cả tháng (chi / số ngày đã qua × số ngày của tháng) ≥ 2 × TB 3 tháng, TB ≥ 1.000.000đ |
| khoản chi lớn | khoản lớn nhất 30 ngày ≥ 5.000.000đ và ≥ 50% TB chi/tháng |
| giao dịch dồn dập | số giao dịch 30 ngày ≥ 150 và ≥ 3 × trung vị toàn hệ thống |
| đăng nhập sai | `failedLogins24h` ≥ 10 (khi backend có dữ liệu) |

**Trả lời**: số tài khoản có dấu hiệu, top 6 theo mức độ kèm lý do có số liệu, danh sách đang bị khóa, ghi chú khi chưa có dữ liệu đăng nhập sai, 1 câu tóm tắt của model. Số tính thêm (ngoại suy, tỉ lệ, trung vị) nằm trong `meta.computed`.

**Guardrails**: `adminGuard`; chỉ đề xuất, không tự khóa (khóa đi qua `de-xuat-khoa` → nháp → admin xác nhận).
