# Ma trận màn hình mobile

Bộ mockup `design/mockup/shots/` đã được người dùng duyệt. Các trạng thái/form phụ kế thừa cùng token, card, list row, form và bottom sheet.

| Gói | Màn/luồng | Điểm vào | API chính | Điều kiện/cờ |
|---|---|---|---|---|
| M2 | Login, đăng ký, quên mật khẩu, OTP/reset | Khởi động/chưa có phiên | auth, me, config/public | registrationEnabled, maintenance, mobile version |
| M3 | Trang chủ, thông báo | Tab Trang chủ, chuông | stats, budgets, transactions, notifications | unread count; AI entry ở M10 |
| M4 | Ghi thu/chi, chọn/quản lý danh mục, mẫu, chuyển tiền | Nút ＋, long press, Cài đặt | transactions, categories, wallets, quick-templates, transfers | featureTransfers, featureQuickTemplates |
| M5 | Lịch sử, lọc, chi tiết/sửa/xóa | Tab Lịch sử, Trang chủ | transactions, transfers | 404 khi dữ liệu đã xóa; ví lưu trữ |
| M6 | Báo cáo, xu hướng, CSV | Tab Báo cáo, Cài đặt | stats/report, by-category, daily, trend, export | featureCsvExport |
| M7 | Ngân sách, tiết kiệm | Trang chủ/Cài đặt | budgets, saving-goals | featureSavingGoals; thresholds từ API |
| M8 | Ví, định kỳ | Trang chủ/Cài đặt | wallets, recurring | featureRecurring |
| M9 | Hồ sơ, mật khẩu, đăng xuất, xóa tài khoản | Tab Cài đặt | me, me/password, auth/logout-all | link hỗ trợ/pháp lý từ config |
| M10 | Danh sách chat, chat, nháp, phản hồi, AI settings | Trang chủ, long press ＋, Cài đặt | ai/* | ai.enabled, usage/limit, shareExamples |

Mọi màn dữ liệu có bốn trạng thái: skeleton theo đúng bố cục, dữ liệu, trống có CTA và lỗi có Thử lại. Mọi thao tác ghi khóa submit trong lúc chờ và không tự gửi lại khi timeout.

Sai khác đã biết cần giữ đúng contract:

- Ngưỡng ngân sách lấy từ response/config, không hard-code 80/100.
- AI SSE hiện phát nội dung sau khi backend hoàn tất câu trả lời; nút Dừng chỉ có thể ngừng nhận phía client cho đến khi backend hỗ trợ hủy.
- Hoàn tác nhiều giao dịch AI dùng từng ID kết quả; API hiện không chứng minh thao tác nhóm nguyên tử.
- Bảo trì toàn hệ thống chặn route USER khác với trạng thái chỉ tắt/bảo trì AI.
