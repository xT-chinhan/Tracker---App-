# Quy ước tích hợp API mobile

Nguồn: `mobile/openapi.json`, `backend/README.md` và controller/service backend. OpenAPI hiện thiếu schema cho nhiều response, vì vậy model Dart được viết có kiểu và kiểm tra bằng fixture/response thật.

## Nền tảng

- Base URL **cố định** `https://tracker-xt.freepro.online/api` (`AppEnvironment.apiUrl`); không đổi, không ghi đè (xem `API-URL.md`).
- Bearer token lưu trong secure storage. 401 hoặc thông báo tài khoản bị khóa xóa phiên; `FEATURE_DISABLED` không xóa phiên.
- Tiền là số nguyên VND. Ngày giờ hiển thị theo `Asia/Ho_Chi_Minh`; `month` dùng `yyyy-MM`.
- Phân trang chuẩn `{items,total,page,limit}`, page bắt đầu từ 1, limit tối đa 200.
- Không tự retry request ghi khi timeout/mất kết nối.

## Ánh xạ lỗi

| HTTP/code | Ứng xử mobile |
|---|---|
| 400 | Hiện message server tại form/toast phù hợp |
| 401 | Xóa token/cache user, về login, báo hết phiên một lần |
| 403 khóa | Xóa phiên và báo tài khoản bị khóa |
| 403 FEATURE_DISABLED | Giữ phiên, refresh config và ẩn điểm vào |
| 403 REGISTRATION_DISABLED | Giữ ở đăng ký, báo tạm ngưng |
| 404 | Báo dữ liệu không còn và làm mới màn nguồn |
| 409 | Hiện message nghiệp vụ, giữ dữ liệu form |
| 429 | Dùng message và Retry-After; AI_DAILY_LIMIT hiển thị thẻ hết lượt |
| 503 MAINTENANCE | Điều hướng màn bảo trì toàn app |
| lỗi mạng/timeout | Giữ phiên và nội dung form, cho thử lại thủ công |

## Ưu tiên kiểm tra model

1. `config/public`, auth response và `/me` cho bootstrap.
2. wallets/categories/transactions cho hành trình ghi đầu tiên.
3. stats/budgets/notifications cho Trang chủ.
4. Các model quản lý tiền/báo cáo.
5. AI event/payload cuối cùng; parser SSE phải chịu được chunk cắt giữa dòng và UTF-8.
