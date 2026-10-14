# Trợ lý AI — quyết định sản phẩm đã chốt (2026-10-14)

Mockup đã duyệt: `design/mockup/` mục J (`shots/30-ai-*`), `design/admin-mockup/` mục I (`shots/20-ai-*`).

- Mỗi tài khoản có AI riêng, chỉ biết dữ liệu của mình; AI admin ở mức quản lý. Nhiều cuộc trò chuyện / tài khoản.
- Human-in-the-loop: AI chỉ tạo **nháp**; user xác nhận / sửa / hủy. Không tự thực thi.
- Không fine-tune: skill tự giỏi lên qua trí nhớ user, kho ví dụ, luật có bộ đếm, bộ đề hồi quy (`ai/research/DE-XUAT.md`).
- Lối vào mobile (giữ tab bar đã duyệt): nút ✨ cạnh chuông ở Trang chủ; "Hỏi trợ lý" đầu menu nhấn giữ ＋; Cài đặt › Trợ lý AI.

| # | Câu hỏi | Quyết định |
|---|---|---|
| 1 | Nhóm "Trợ lý" (Trợ lý AI, Trung tâm học) trong sidebar admin | Thêm vào sidebar chung |
| 2 | "Bật trợ lý" (mục AI) và cờ tính năng (Nghiệp vụ) | Là **cùng một** công tắc |
| 3 | Đạt giới hạn số cuộc trò chuyện | Tự lưu trữ cuộc cũ nhất **chưa ghim** |
| 4 | Góp ví dụ ẩn danh vào kho chung (≥5 người khác nhau xác nhận) | **Hỏi đồng ý một lần**, có thể tắt trong Cài đặt › Trợ lý AI |
| 5 | Admin xem "điều trợ lý đã học" của từng user | **Không** |
| 6 | Giữ lịch sử chat trên server | 12 tháng; user tự xóa bất cứ lúc nào |
| 7 | Thông báo theo nhóm user | Để sau (backlog) |
| 8 | Nháp trùng giao dịch đã ghi | Backend phát hiện, thẻ nháp hiện "Có thể đã ghi rồi" |
| 9 | Giọng nói → chữ | Trên máy người dùng, làm cùng app mobile |
| 10 | Mặc định: 30 tin/ngày, 50 cuộc, chờ tối đa 15 giây; luật chung tự áp dụng khi ≥50 người và đúng ≥97% | Đồng ý, admin chỉnh trong Cấu hình |
