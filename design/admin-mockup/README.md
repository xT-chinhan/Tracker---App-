# Thu Chi Admin · Mockup

Mở `index.html` trực tiếp (không cần server). Ảnh 1x trong `shots/`, toàn bộ gallery ở `shots/overview.png`.

## Màn hình
| # | File | Màn |
|---|---|---|
| 01 | `shots/01-dang-nhap.png` | A1 Đăng nhập admin |
| 02 | `shots/02-tong-quan.png` | A2 Tổng quan: 3 thẻ KPI, biểu đồ thu chi 6 tháng (đang hover T8), mục tiêu tiết kiệm theo trạng thái, đăng ký gần đây |
| 03 | `shots/03-nguoi-dung.png` | A3 Người dùng: tìm kiếm, lọc vai trò/trạng thái, phân trang, menu thao tác của một dòng |
| 04 | `shots/04-xac-nhan-khoa.png` | A3 Hộp xác nhận khóa tài khoản |
| 05 | `shots/05-chi-tiet-nguoi-dung.png` | A4 Chi tiết người dùng: số dư/thu/chi/tiết kiệm, xu hướng 6 tháng, ví, hồ sơ, giao dịch gần đây |
| 06 | `shots/06-giao-dich.png` | A5 Giao dịch toàn hệ thống: lọc người dùng, ví, tháng, Thu/Chi, tìm kiếm, chip danh mục |
| 07 | `shots/07-danh-muc.png` | A6 Danh mục hệ thống: tab Chi/Thu, số lượt dùng, panel sửa (tên, icon, màu), mục đã lưu trữ có Khôi phục |
| 08 | `shots/08-thong-bao.png` | A7 Thông báo hệ thống: soạn, xem trước trên điện thoại, lịch sử kèm số người nhận |
| 09 | `shots/09-tai-khoan.png` | A8 Tài khoản admin: đổi tên, đổi mật khẩu (có lỗi inline) |
| 10 | `shots/10-trang-thai-trong.png` | Empty state: lọc giao dịch không có kết quả |
| 11 | `shots/11-dang-tai.png` | Loading: skeleton đúng bố cục Tổng quan, không dùng spinner |
| 12 | `shots/12-toast-loi.png` | Toast thành công (có Hoàn tác) và toast lỗi (thông báo lỗi thật của backend) |
| 13 | `shots/13-nguoi-dung-1024.png` | A3 ở 1024×768: sidebar thu thành rail icon, ẩn cột Mục tiêu và Ngày tham gia (ngày chuyển xuống dòng email) |
| 14a | `shots/14-cau-hinh-a-chung.png` | A9 Cấu hình · Chung: tên app, email hỗ trợ, hotline, link điều khoản và chính sách bảo mật, tiền tệ VND (chỉ đọc) |
| 14b | `shots/14-cau-hinh-b-truy-cap-bao-tri.png` | A9 Đăng ký & truy cập khi đang bảo trì: banner vàng, card bảo trì viền vàng, switch vàng, thông báo cho người dùng, giờ dự kiến xong; cho phép đăng ký mới; thời hạn phiên; giới hạn đăng nhập sai |
| 14c | `shots/14-cau-hinh-c-email-smtp.png` | A9 Email (SMTP) đã cấu hình: chip "Đã cấu hình", gửi email thử (kết quả inline + toast), host/cổng, bảo mật, mật khẩu đã lưu (ẩn, nút Thay mật khẩu), địa chỉ gửi |
| 14d | `shots/14-cau-hinh-d-mat-khau-otp.png` | A9 Mật khẩu & OTP: độ dài mật khẩu tối thiểu, OTP hết hạn, số lần nhập sai, chờ gửi lại; tóm tắt trải nghiệm người dùng theo đúng số đang đặt |
| 14e | `shots/14-cau-hinh-e-nghiep-vu.png` | A9 Nghiệp vụ: ngưỡng cảnh báo 80% / vượt 100% kèm thanh xem trước, tên ví mặc định "Tiền mặt", bật/tắt 5 tính năng app |
| 14f | `shots/14-cau-hinh-f-ung-dung.png` | A9 Ứng dụng di động: bản mới nhất và tối thiểu cho Android/iOS, link CH Play/App Store, ghi chú cập nhật, xem trước hộp "Cần cập nhật" trên điện thoại |
| 14g | `shots/14-cau-hinh-g-lich-su.png` | A9 Lịch sử thay đổi: lọc theo mục, bảng thời gian / người / mục / cũ → mới, giá trị bí mật hiện •••• |
| 14h | `shots/14-cau-hinh-h-chua-luu.png` | A9 Có thay đổi chưa lưu: chấm đen cạnh nhãn đã sửa, "Trước: …", số thay đổi trên sub-nav, lỗi inline, thanh Lưu dính đáy (Lưu bị khóa khi còn lỗi) |
| 14i | `shots/14-cau-hinh-i-xac-nhan-bao-tri.png` | A9 Hộp xác nhận bật bảo trì: số người bị ảnh hưởng, giờ dự kiến xong, nội dung người dùng sẽ thấy |
| 14j | `shots/14-cau-hinh-j-email-1024.png` | A9 Email (SMTP) ở 1024×768, trạng thái chưa cấu hình (OTP chỉ ghi log): sub-nav thành hàng chip cuộn ngang |

## Quyết định bố cục
- **Sidebar trái 248px**, cùng nền ngà với trang, chỉ có một đường hairline bên phải. Mục đang chọn là nền trắng + viền mảnh, giống "thumb" của segmented control trên mobile. Mục đang chọn không tô đen, để màu đen chỉ dành cho nút chính và chip đang chọn.
- Không có top bar. Tiêu đề trang 30/700 (cùng cỡ `headline` của mobile), hành động chính đặt bên phải tiêu đề.
- Nội dung nằm trong card trắng, bo 18, viền `#EAEAEA`. Bảng không có nền header, chỉ có hairline. Dòng cao 56px (2 dòng chữ) hoặc 52px (1 dòng), số tiền canh phải, dùng chữ số tabular.
- Bộ lọc nằm trên một hàng phía trên bảng: ô tìm kiếm, select dạng viên thuốc, chip đen khi chọn (như mobile), segmented cho Tất cả/Chi/Thu.
- Màu chỉ mang nghĩa: thu xanh `#1F8A4C`, chi mực `#111`, khóa/lỗi đỏ, thành công xanh nhạt. Bong bóng icon danh mục luôn xám. Màu của danh mục chỉ hiện dạng ô màu nhỏ, vì nó chỉ dùng để tô biểu đồ.
- Biểu đồ: cột nhóm Thu/Chi, chỉ một trục, cột tối đa 22px, bo 4px ở đầu, cách nhau 2px. Có legend, tooltip khi hover, nhãn "đến 22/09" chỉ cho tháng chưa hết, và link "Xem dạng bảng".
- Mục tiêu tiết kiệm dùng thanh ngang một màu (một chuỗi dữ liệu nên không cần legend), kèm số và %.
- Lọc theo ví chỉ bật khi đã chọn người dùng, vì ví thuộc về từng người.
- Dữ liệu nhất quán: 1.284 = 1.247 hoạt động + 37 khóa. Tổng lượt dùng danh mục (gồm cả mục đã lưu trữ) = 186.420 giao dịch. Biểu đồ T9 khớp con số thu/chi ở trang Giao dịch. Người nhận thông báo là 1.247. Nguyễn Minh Anh có cùng ví và giao dịch như mockup mobile.

## Cấu hình hệ thống (A9)
- Sidebar thêm mục **Cấu hình** (`settings-2`) trong nhóm Quản lý, sau Thông báo. Mục này được thêm vào mảng `NAV` nên mọi khung cũ cũng đã có, toàn bộ ảnh đã chụp lại.
- Bố cục: sub-nav dọc 216px bên trái (mục chọn tô xám `surface-container-high` như hàng được chọn trong menu, để không lẫn với sidebar nền trắng), cột nội dung cuộn riêng. Mỗi mục gồm tiêu đề `title-l` + mô tả, rồi các card. Trong card, mỗi hàng là **nhãn + mô tả bên trái, control 420px canh phải**. Ô số có đơn vị ngay trong ô, khoảng hợp lệ ghi bên cạnh.
- **Lưu**: mọi mục dùng chung một thanh "N thay đổi chưa lưu · Hủy · Lưu thay đổi", dính đáy cột nội dung, chỉ hiện khi có thay đổi. Hàng đã sửa có chấm đen cạnh nhãn và dòng "Trước: …". Sub-nav hiện số thay đổi của từng mục. Còn lỗi thì nút Lưu bị khóa và thanh ghi rõ lỗi ở mục nào. Lỗi hiện ngay dưới ô.
- **Bảo trì** là ngoại lệ duy nhất: switch có hiệu lực ngay sau hộp xác nhận, không đi qua thanh Lưu, vì đây là thao tác vận hành, cần tác dụng tức thì. Khi đang bật: banner vàng đầu mục, card viền vàng, switch vàng, chấm vàng trên sub-nav. Tài khoản quản trị không bị chặn. Giờ "dự kiến xong" không bắt buộc: tới giờ đó bảo trì **tự tắt** (lịch sử ghi người thay đổi là Hệ thống); để trống thì chỉ tắt bằng tay.
- **SMTP**: mật khẩu không bao giờ hiển thị lại. Ô ở trạng thái "Đã lưu" kèm nút Thay mật khẩu. Gửi thử dùng cấu hình **đã lưu**, gửi tới email của admin đang đăng nhập, nên khối gửi thử nằm ngay dưới tiêu đề cùng chip trạng thái. Kết quả gửi thử hiện inline (giữ lại) và qua toast (tự ẩn). Khi chưa cấu hình: chip vàng, banner "OTP chỉ ghi log", nút gửi thử bị khóa.
- **Độ dài mật khẩu tối thiểu** chuyển từ "Đăng ký & truy cập" sang "Mật khẩu & OTP" cho khớp tên mục.
- **Tính năng app**: tắt thì ẩn khỏi app, dữ liệu cũ vẫn giữ. Mỗi dòng có mô tả ngắn và số liệu đang dùng nếu có.
- **Lịch sử**: mỗi trường đổi là một dòng. Giá trị cũ gạch ngang màu nhạt, giá trị mới đậm. Trường bí mật luôn hiện `••••` kèm nhãn "Bí mật, không hiển thị".
- Dữ liệu nhất quán: bảo trì 23:00–23:30 ngày 25/09 khớp thông báo đã soạn ở A7. Bật Xuất CSV lúc 09:55 20/09 khớp thông báo "Mới: xuất báo cáo ra CSV" gửi 10:00 cùng ngày. 1.247 người bị ảnh hưởng = số người dùng đang hoạt động. 687 mục tiêu khớp Tổng quan.

## Token
Khối `:root` trong `styles.css` sao chép 1:1 từ `../mockup/styles.css` / `../tokens.md`: màu, Be Vietnam Pro, spacing 4pt, radius (8/12/14/18/28/pill), shadow, motion. Phần thêm cho desktop (cuối `:root`):

| Token | Giá trị | Ghi chú |
|---|---|---|
| `--sidebar-w` | 248px | rail 72px ở tablet |
| `--content-pad-x` / `--content-pad-top` | 40px / 36px | 32px ở tablet |
| `--control-h` | 40px | input, select, nút trong trang (mobile là 52) |
| `--control-h-lg` | 52px | form đăng nhập, ô trong Tài khoản, bằng mobile |
| `--row-h` / `--row-h-compact` | 56px / 52px | dòng bảng |
| `--shadow-pop` | 0 1 2 /.04 + 0 12 32 /.08 | menu, toast, dialog |
| `--skeleton-a` / `--skeleton-b` | `#ECEBE7` / `#F4F3F0` | giống spec skeleton mobile |

Card desktop có padding 24 (mobile là 18). Dialog bo 24.

Icon dùng Lucide nét 1.75 (`vendor/lucide.min.js`, chép từ mockup mobile).
