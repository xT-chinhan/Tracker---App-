---
name: tom-tat-cau-hinh
scope: ADMIN
output: text
providers: [admin.configHistory (params limit 50)]
llm: 1 câu tóm tắt (llmSentence), không được chứa số
---
# tom-tat-cau-hinh — tóm tắt lịch sử cấu hình

**Khi nào**: "ai đã đổi cấu hình tuần này", "tóm tắt thay đổi cấu hình", "lần cuối sửa SMTP là khi nào".

**Dữ liệu**: `admin.configHistory` (= `GET /admin/config/history`, mỗi trường một dòng, bí mật đã che `••••`).

**Trả lời** (code): lọc theo khoảng thời gian (`parsePeriod`) và mục (smtp/bảo trì/mật khẩu/nghiệp vụ/mobile/chung) nếu câu có nhắc; đếm theo người sửa; liệt kê 12 thay đổi mới nhất dạng "giờ · người · mục › trường: cũ → mới" (tên trường tiếng Việt, bật/tắt, giờ VN). Trường bí mật chỉ ghi "đã đổi (giá trị ẩn)". Model viết 1 câu tóm tắt thay đổi đáng chú ý (tính năng bật/tắt, bảo trì, đăng nhập, mật khẩu).

**Guardrails**: `adminGuard`; không bao giờ hiện giá trị bí mật.

Ghi chú eval: DB dev chưa có dòng `SystemConfigChange` nào nên fixture dùng 10 thay đổi tự viết (`eval/fixtures/build.ts`).
