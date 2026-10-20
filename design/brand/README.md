# Thương hiệu · 4 phương án tên và logo

Xem `index.html` (ảnh: `overview.png`, từng phương án: `<slug>/preview.png`).
Mỗi thư mục có `icon.svg` (nền đen, dấu trắng, bo 22%), `icon-dark.svg` (nền ngà, dấu đen, dùng trên nền tối),
`mark.svg` (chỉ dấu, nền trong), `lockup.svg` / `lockup-dark.svg` (icon + wordmark Be Vietnam Pro Bold, dạng `<text>`).
Tất cả tên đều **cần kiểm tra nhãn hiệu** (Cục SHTT, App Store/Play, tên miền) trước khi chốt.

| # | Tên | Đọc | Ý nghĩa | Tagline | Dấu |
|---|---|---|---|---|---|
| 1 | **Vun** (gốc Việt) | /vun/ | "Vun vén": góp nhặt, chăm chút từng đồng | Vun từng đồng, vững từng ngày | Chữ V như bàn tay khum, giữ hạt tiền ở giữa |
| 2 | **Lộc** / Loc (gốc Việt) | /lốc/ | Chồi non đầu năm và tài lộc | Mỗi ngày thêm một chút lộc | Mầm hai lá trên một thân |
| 3 | **Neto** (quốc tế) | /nê-tô/ | "Net": số ròng, thu trừ chi còn lại | Biết rõ mình còn bao nhiêu | Chữ N một nét, đi xuống rồi vươn cao hơn điểm đầu |
| 4 | **Sumi** (quốc tế, chơi chữ Việt) | /xu-mi/ | Sum (tổng) + xu (đồng tiền); sumi = mực tàu | Mọi đồng tiền, một nơi | Giọt mực có lỗ tròn như đồng xu |

Tên miền / app id: `vun.app` · `loc.app` · `neto.app` · `sumi.app`; `vn.<tên>.app`.

## Đề xuất: Vun
- Gốc Việt, một âm, không dấu vẫn đúng chữ (khác "Lộc" phải bỏ dấu), người nước ngoài đọc được "voon".
- "Vun vén" nói đúng hành vi app khuyến khích (ghi chép, ngân sách, tiết kiệm), ấm áp nhưng không sến, không trùng nghĩa chung chung như "Thu Chi".
- Dấu V + hạt đọc rõ ở 16–24px, khác biệt với các app tài chính VN, hợp phong cách đơn sắc hiện tại. Phương án dự phòng: Neto.

## Khi chốt tên, cần đổi
- Cấu hình hệ thống `general.appName` (admin Cấu hình → `GET /api/config/public`) và giá trị seed/mặc định trong backend.
- Email template (`design/email/*.html` và template thật trong backend): khối logo 40px "đ" → icon mới, tên ở header, chữ ký footer "© 2026 …", câu "nhân viên Thu Chi", tiêu đề/subject có tên app.
- Icon app: Android (`mipmap-*` ic_launcher, adaptive icon foreground/background + monochrome themed icon, splash), iOS (`AppIcon.appiconset` 1024 + bản dark/tinted iOS 18, LaunchScreen), tên hiển thị (`android:label`, `CFBundleDisplayName`), app id nếu đổi (`vn.<tên>.app`).
- Admin: logo + tên ở sidebar, trang đăng nhập (`.logo lg`), `<title>`, favicon, footer "© 2026 … · Bảng quản trị".
- Mobile: màn chào/đăng nhập, Giới thiệu/Cài đặt, thông báo đẩy, chuỗi văn bản có "Thu Chi" (gồm lời chào của trợ lý AI).
- Tài liệu thiết kế: `design/tokens.md`, `design/DESIGN.md` (tiêu đề), `design/mockup/`, `design/admin-mockup/` (logo `.logo`, tiêu đề trang) và chụp lại shots bằng `design/shoot.mjs`.
- Tên miền email/tài khoản demo (`@thuchi.vn`) nếu đổi domain.

---

# Đã chốt: TrackerX · monogram xT

Xem `trackerx/index.html` (ảnh `trackerx/overview.png`, từng hướng `trackerx/<slug>/preview.png`).
Mỗi hướng có `icon.svg`, `icon-dark.svg` (nền ngà, dấu đen), `mark.svg`, `lockup.svg`, `lockup-dark.svg`.

**Wordmark:** "TrackerX", Be Vietnam Pro Bold 700, một độ đậm, tracking −0.02em. Chữ X hoa đã là điểm nhấn. Trộn 400 + 700 bị vỡ ở cỡ 16px (sidebar, email). Viết in hoa toàn bộ thì khó đọc và mất chữ x thường của monogram.

| Hướng | Thư mục | Ý tưởng |
|---|---|---|
| A · Chữ ghép | `trackerx/a-lettered/` | x thường nét mảnh + T hoa nét đậm, thanh ngang của T vươn trái phủ lên x (kerning tay) |
| B · Đan xen | `trackerx/b-interlocked/` | x vắt ngang thân T, khe hở mảnh tách hai lớp, thành một ký tự |
| C · Lưới ô | `trackerx/c-grid/` | Lưới 3×3: 5 ô trắng ghép thành T, 2 ô góc mờ hoàn thiện đường chéo x, gợi ô dữ liệu và việc theo dõi |

**Đề xuất: A.** Đọc ra đúng "xT" ngay ở 16–24px, B và C ở cỡ nhỏ chỉ còn thấy chữ T.
Hình hoàn toàn từ chữ, khớp wordmark và phong cách đơn sắc, dễ dựng icon adaptive/themed (Android) và tinted (iOS).
B dày chi tiết, khe hở biến mất ở 16px. C đẹp ở cỡ lớn nhưng chữ x chỉ hiện ngầm.

**Tagline cho đầu email:** "Tiền rõ ràng, sống nhẹ nhàng" (đã đặt thử trong preview đầu email).
