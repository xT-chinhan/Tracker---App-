# Design System: Thu Chi
**Project ID:** local-mockup (chưa có dự án Stitch, nguồn là `design/mockup/`)

## Configuration
| Dial | Level | Ghi chú |
|------|-------|---------|
| **Creativity** | `2` | Yên tĩnh, đơn sắc ấm, kiểu Swiss. Không thử nghiệm chữ |
| **Density** | `4` | Ứng dụng hằng ngày, cân bằng. Một ý chính cho mỗi card |
| **Variance** | `2` | Đối xứng, dễ đoán. Mọi màn dùng cùng một khung |
| **Motion Intent** | `3` | Tinh tế: nhấn thì scale 0.97, sheet trượt lên, skeleton shimmer |

## 1. Visual Theme & Atmosphere
App ghi chép thu chi cá nhân cho người Việt, cảm giác như một cuốn sổ giấy được giữ gọn gàng. Nền màu ngà ấm, các card trắng nổi rất nhẹ, mỗi màn chỉ có một con số đậm làm trọng tâm. Gần như không có màu: màu chỉ xuất hiện khi mang ý nghĩa (tiền vào xanh, cảnh báo vàng, vượt ngưỡng đỏ). Mật độ thoáng, không có gì phải tranh nhau sự chú ý. Ngôn ngữ thị giác giống một ví điện tử iOS cao cấp, không giống app ngân hàng nhiều banner.

## 2. Color Palette & Roles
- **Warm Bone Canvas** (#F7F6F3): nền của mọi màn hình
- **Pure Paper White** (#FFFFFF): card, bottom sheet, ô nhập, chip chưa chọn
- **Pebble Grey Fill** (#F1F0EC): bong bóng icon danh mục, nền segmented control, rãnh thanh tiến độ
- **Whisper Hairline** (#EAEAEA): viền 1px của card, chip và nút phụ
- **Ink Charcoal** (#111111): chữ chính, số tiền khoản chi, nút chính, chip đang chọn, nút ＋ giữa tab bar. Không bao giờ dùng #000000
- **Muted Stone** (#787774): nhãn phụ, subtitle như "Ăn uống · MB Bank"
- **Faint Ash** (#A9A8A3): placeholder, giờ giao dịch, tick biểu đồ
- **Ledger Green** (#1F8A4C): chỉ dùng cho tiền vào (+22.000.000đ) và cột Thu
- **Amber Caution** (#956400 chữ / #FBF3DB nền / #D99A1E thanh): ngân sách từ 80%
- **Brick Alert** (#B3261E chữ / #FDEBEC nền / #D9483B thanh): ngân sách từ 100%, xóa
- **Chart set** (#2a78d6, #eb6834, #1baf7a, #eda100, #e87ba4): chỉ dùng trong donut danh mục, thứ tự cố định, đã kiểm tra an toàn cho người mù màu

## 3. Typography Rules
- **Font:** Be Vietnam Pro (dấu tiếng Việt chuẩn), dự phòng SF Pro Display / system-ui. Toàn app chỉ dùng một họ sans. Không dùng serif, không dùng Inter.
- **Số tiền:** đậm 700, tracking hơi chặt (−0.03em), dùng chữ số tabular. Có 4 bậc: 46 (đang nhập), 40 (số dư), 32 (số chính trên card), 15/600 (trong list). Định dạng `26.022.000đ`, dấu trừ thật "−".
- **Tiêu đề màn hình:** 30/700, viết hoa đầu câu, ví dụ "Thứ Ba, 22 tháng 9", "Lịch sử".
- **Thân chữ:** 14–15, màu Ink. Nhãn phụ 12–12.5 màu Muted Stone. Line-height ≥ 1.2 cho số và ≥ 1.4 cho chữ để dấu không bị cắt.
- Không viết hoa toàn bộ (chữ Việt in hoa có dấu trông nặng nề).

## 4. Component Stylings
* **Buttons:** dạng viên thuốc, cao 52. Nút chính nền Ink, chữ trắng. Nút phụ nền trắng, viền hairline. Nút nguy hiểm dùng nền Brick nhạt, chữ đỏ, chỉ xuất hiện trong sheet xác nhận. Khi nhấn thì thu nhỏ 0.97 trong 160ms, không có glow.
* **Cards/Containers:** góc bo rộng 18px, nền trắng, viền 1px Whisper Hairline, bóng rất loãng (alpha < 0.04). Card dạng list có đường chia mảnh, thụt vào sau icon.
* **List rows:** bong bóng icon xám 40px, bên cạnh là tiêu đề và subtitle "Danh mục · Ví", số tiền canh phải với giờ ở dưới. Gom nhóm theo ngày ("Hôm nay", "Hôm qua", "2 ngày trước") kèm tổng ròng của ngày.
* **Chips & Segmented:** chip lọc dạng viên thuốc. Khi chọn thì nền Ink, chữ trắng. Segmented control (Chi/Thu, tần suất) có nền Pebble và "thumb" trắng nổi nhẹ, kiểu iOS.
* **Inputs/Forms:** nhãn đặt trên ô, ô cao 52, bo 14. Khi focus thì viền Ink kèm quầng 3px. Form chọn (Danh mục, Ví, Ngày) là các dòng trong card: nhãn bên trái, giá trị đậm và chevron bên phải.
* **Keypad:** bàn phím số lớn, không viền, có phím `000`, đặt ở đáy màn hình (vùng ngón cái), nút lưu ngay bên dưới.
* **Bottom sheets:** góc trên bo 28, có grabber, scrim tối 32%.
* **Tab bar:** 5 ô trên nền trắng mờ: Trang chủ · Lịch sử · [＋] · Báo cáo · Cài đặt (icon `settings`). Nút ＋ tròn màu Ink nhô lên ở giữa: chạm 1 lần mở màn Ghi giao dịch (mặc định Khoản chi, con trỏ đặt sẵn ở ô số tiền); nhấn giữ thì phủ lớp mờ 38% và bung từ nút ＋ lên một menu nhanh (card trắng bo 18, rộng 264): Thu nhập (bong bóng xanh), Chuyển tiền, đường kẻ mảnh, rồi 3 mẫu nhập nhanh kèm số tiền. Khi menu mở, nút ＋ đổi thành ✕ để đóng. Menu hiện ra bằng scale 0.95 → 1 cộng fade, origin ở nút ＋, 200ms ease-out. Cài đặt là danh sách nhóm kiểu iOS: hồ sơ; Quản lý tiền (Ví, Ngân sách, Mục tiêu tiết kiệm, Giao dịch định kỳ); Nhập liệu (Danh mục, Mẫu nhập nhanh); Ứng dụng (Thông báo có số chưa đọc, Xuất CSV, Đổi mật khẩu); Đăng xuất; link đỏ nhỏ Xóa tài khoản; phiên bản app. Màn con giữ tab Cài đặt active, nút back "‹ Cài đặt". Ví và Ngân sách còn mở từ thẻ số dư ở Trang chủ.
* **Progress:** thanh mảnh 6px. Fill Ink khi bình thường, Amber khi ≥ 80%, Brick khi ≥ 100%, luôn kèm badge % có icon.
* **Loaders:** skeleton shimmer đúng bố cục thật, không dùng spinner. **Empty states:** hình ghép từ card mờ, một câu hướng dẫn và một nút hành động.

## 5. Layout Principles
- Khung 390pt, lề 20, lưới 4pt. Các card cách nhau 12, các khối cách nhau 20–24.
- Mỗi màn có đúng một con số hero. Phần còn lại là nhãn nhỏ và muted.
- Hành động chính nằm ở nửa dưới (keypad, nút lưu, ＋ giữa tab bar). Hành động xóa đặt xa và phải xác nhận.
- Vùng chạm tối thiểu 44×44, khoảng cách giữa các vùng chạm ≥ 8.
- Không có cuộn ngang, trừ dải chip "Nhập nhanh" (cố ý tràn mép để gợi ý còn nội dung).

## 6. Motion
- Nhấn: scale 0.97, 160ms, `cubic-bezier(0.23,1,0.32,1)`. Sheet: 360ms, `cubic-bezier(0.32,0.72,0,1)`, kéo được và ngắt được giữa chừng.
- Chỉ animate transform và opacity. Khi bật reduce-motion thì thay bằng cross-fade.

## 7. Anti-Patterns (Banned)
- Không gradient, không neon, không glassmorphism nặng, không glow.
- Không #000000. Không dùng màu cho trang trí: màu phải mang ý nghĩa.
- Không emoji, không icon nét dày lẫn nét mảnh (Lucide, nét 1.75, thống nhất).
- Không spinner tròn. Không viết hoa toàn bộ tiếng Việt.
- Không tô màu chữ theo màu series biểu đồ. Không dùng biểu đồ hai trục.
- Không dữ liệu giả kiểu "John Doe" hay số tròn vô nghĩa. Dữ liệu mẫu phải khớp nhau giữa các màn.
