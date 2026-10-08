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
