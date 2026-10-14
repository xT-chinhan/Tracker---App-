# Thu Chi · Mockup mobile

Mở `index.html` trực tiếp. Ảnh 2x trong `shots/`, toàn bộ gallery ở `shots/overview.png`. Token ở `../tokens.md`, nguyên tắc ở `../DESIGN.md`. Mục A–I (25 màn, `shots/01…23`) đã duyệt. Mục **J · Trợ lý AI** (`shots/30-ai-*.png`) đang **chờ duyệt**.

## J · Trợ lý AI (chờ duyệt)
| # | File | Màn |
|---|---|---|
| 30a | `shots/30-ai-00a-loi-vao-trang-chu.png` | Lối vào 1: nút Trợ lý (`sparkles`) cạnh chuông ở Trang chủ, gợi ý lần đầu |
| 30b | `shots/30-ai-00b-loi-vao-nut-cong.png` | Lối vào 2: nhấn giữ ＋, dòng đầu “Hỏi trợ lý” |
| M1 | `shots/30-ai-01a-danh-sach.png` | Danh sách cuộc trò chuyện: tìm, Đã ghim / Hôm nay / 7 ngày qua, vuốt trái = Ghim · Lưu trữ · Xóa, ô nhập ở đáy mở cuộc mới |
| M1 | `shots/30-ai-01b-danh-sach-trong.png` | Chưa có cuộc trò chuyện |
| M1 | `shots/30-ai-01c-doi-ten-luu-tru.png` | Nhấn giữ: đổi tên, ghim, lưu trữ, xóa (xóa không đụng giao dịch đã ghi) |
| M2 | `shots/30-ai-02-cuoc-moi.png` | Cuộc mới: lời chào, nói rõ phạm vi riêng tư, gợi ý lấy từ dữ liệu thật (badge 89% / 115% / 70%), chip ghi nhanh |
| M3 | `shots/30-ai-03-tong-ket-thang.png` | Trả lời kèm thẻ số liệu tháng 9 + dòng nguồn + link Báo cáo, phản hồi, gợi ý hỏi tiếp |
| M4 | `shots/30-ai-04-nhap-giao-dich.png` | Nháp 3 khoản (viền nét đứt): danh mục, ví, ngày; Hủy · Sửa · Xác nhận cả 3 |
| M5 | `shots/30-ai-05-sua-mot-khoan.png` | Sheet sửa một khoản (Khoản 3/3, vuốt qua lại), báo trợ lý sẽ học lựa chọn này; Bỏ khoản khỏi nháp |
| M6 | `shots/30-ai-06-da-luu-hoan-tac.png` | Đã lưu: thẻ chuyển nét liền + “Xem trong Lịch sử”, nhắc ngân sách Ăn uống 92%, toast Hoàn tác có thanh đếm ngược |
| M7 | `shots/30-ai-07-ngan-sach.png` | Kiểm tra ngân sách bằng progress bar đúng quy tắc 80%/100%; báo “Còn 3 lượt hỏi hôm nay” trên ô nhập |
| M8 | `shots/30-ai-08-y-toi-la.png` | “Hữu ích” đã chọn; “Chưa đúng” mở thẻ “Ý bạn là…” (3 cách hiểu khác + gõ lại) |
| M9 | `shots/30-ai-09-tu-choi.png` | Từ chối dữ liệu người khác và câu ngoài phạm vi: thẻ xám trung tính, không đỏ, kèm việc làm được |
| M10 | `shots/30-ai-10a-dang-doc-du-lieu.png` | Đang trả lời 0–0,3 giây: dòng trạng thái thật + khung số liệu skeleton, nút Dừng |
| M10 | `shots/30-ai-10b-dang-viet.png` | 0,3–2 giây: thẻ số liệu đã có, lời giải thích đang chạy (con trỏ) |
| M11 | `shots/30-ai-11-het-luot.png` | Hết 30 lượt: ô nhập thay bằng thẻ giờ mở lại + Ghi giao dịch thủ công |
| M12 | `shots/30-ai-12a-bao-tri.png` | Bảo trì: banner vàng, đọc lại được, ô nhập khóa, vẫn ghi thủ công được |
| M12 | `shots/30-ai-12b-da-tat.png` | Quản trị tắt trợ lý (chỉ gặp khi mở link cũ; bình thường lối vào bị ẩn) |
| M13 | `shots/30-ai-13-giong-noi.png` | Nói để ghi (**bản sau**): đang nghe, chữ chạy, sóng âm, sửa chữ rồi gửi |
| M14 | `shots/30-ai-14-cai-dat-tro-ly.png` | Cài đặt › Trợ lý AI: lượt hôm nay, điều trợ lý đã học (xóa từng điều), Góp ví dụ ẩn danh, đã lưu trữ, xóa toàn bộ |

### Quyết định
- **Lối vào không đụng tab bar**: (1) nút tròn `sparkles` cạnh chuông ở Trang chủ, luôn thấy, không đẩy nội dung xuống; (2) “Hỏi trợ lý” đầu menu nhấn giữ ＋, vì việc chính của trợ lý là ghi nhanh, đặt cạnh các cách ghi khác; (3) Cài đặt › Ứng dụng › Trợ lý AI để quản lý. Không thêm ô hỏi lên Trang chủ để giữ bố cục đã duyệt. Quản trị tắt tính năng thì cả 3 lối vào ẩn.
- Màn chat là màn con đẩy từ Trang chủ nên **ẩn tab bar**; thanh trên có tên cuộc + dòng “Chỉ dữ liệu của bạn”.
- Tin người dùng: bong bóng xám `surface-container-high`. Câu trả lời: chữ thường, không bong bóng, không avatar. Màu đen chỉ cho nút chính (Xác nhận) và nút gửi.
- **Số liệu trước, lời sau**: thẻ số liệu lấy thẳng từ dữ liệu (~0,3 giây) rồi lời giải thích chạy bên dưới, nên chữ chạy không đẩy thẻ nhảy. Mỗi thẻ có dòng nguồn (“Tính từ 41 khoản chi tháng 9”) và link sang màn gốc. Thời gian trả lời hiện nhỏ cạnh nút phản hồi.
- **Nháp**: viền nét đứt + badge “Nháp · chưa lưu” = chưa có gì được ghi. Chạm một dòng (hoặc Sửa) mở sheet sửa; sửa chỉ đổi nháp. “Xác nhận cả 3” ghi một lần, thẻ chuyển nét liền, toast Hoàn tác ~10 giây (xóa đúng các giao dịch vừa tạo). Hủy thì thẻ mờ, giữ trong lịch sử chat.
- Loading không dùng spinner: dòng trạng thái nói thật đang làm gì (shimmer chữ, tắt khi reduce-motion) + skeleton đúng hình thẻ. Nút gửi đổi thành Dừng.
- Từ chối không dùng màu đỏ (không phải lỗi), luôn kèm việc trợ lý làm được.
- Hết lượt / bảo trì: luôn chừa đường ghi thủ công. Xác nhận nháp và đọc lại không tính lượt.
- Dữ liệu khớp các màn đã duyệt: tháng 9 chi 8.680.000đ / 14.000.000đ (62%), Ăn uống 3.120.000 (89%), Mua sắm 115%, MoMo 1.500.000đ, Tiền nhà 2.500.000đ định kỳ ngày 1 từ MB Bank, Đà Lạt 70%. Sau khi xác nhận nháp 180.000đ, Ăn uống thành 3.220.000đ (92%).
