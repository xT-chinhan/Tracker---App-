# Thu Chi Admin · Mockup

Mở `index.html` trực tiếp (không cần server). Ảnh 1x trong `shots/`, toàn bộ gallery ở `shots/overview.png`. Mục **I · Trợ lý AI** (ảnh `shots/20-ai-*.png`) mục **J · Đọc ảnh** (ảnh `shots/40-ocr-a*.png`) và mục **K · Xác thực số điện thoại** (ảnh `shots/50-sdt-a*.png`) đang **chờ duyệt**, xem cuối file.

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

## Trợ lý AI (A10–A13) · chờ duyệt
Mockup mobile tương ứng: `../mockup/` mục J, ảnh `../mockup/shots/30-ai-*.png`.

| # | File | Màn |
|---|---|---|
| 20a | `shots/20-ai-a10a-thong-ke.png` | A10 Trợ lý quản trị: danh sách cuộc trò chuyện trái, chat giữa. Câu trả lời “tình hình 7 ngày” = thẻ 4 số liệu + 3 điểm cần xem + nguồn số liệu + gợi ý hỏi tiếp |
| 20b | `shots/20-ai-a10b-tim-nguoi-dung.png` | A10 Kết quả tìm người dùng: bảng gọn trong chat, “Mở trong Người dùng, đã lọc sẵn”, Xuất CSV; nói rõ thông báo chưa gửi riêng theo nhóm được |
| 20c | `shots/20-ai-a10c-nhap-thong-bao.png` | A10 Nháp thông báo (viền nét đứt = chưa có hiệu lực): tiêu đề, nội dung, số ký tự, số người nhận; Mở trong trình soạn / Viết lại / Bỏ nháp. Trợ lý không tự gửi |
| 20d | `shots/20-ai-a10d-soan-thong-bao.png` | A7 Thông báo đã điền sẵn từ nháp, dải ghi chú “do Trợ lý AI soạn · Về cuộc trò chuyện”. Gửi vẫn bằng nút Gửi của A7 |
| 20e | `shots/20-ai-a10e-de-xuat-khoa.png` | A10 Đề xuất khóa kèm 3 lý do có số liệu → hộp xác nhận khóa giống A3, thêm “Đề xuất bởi Trợ lý AI” và lý do điền sẵn (ghi nhật ký, sửa được) |
| 20f | `shots/20-ai-a11a-trung-tam-hoc.png` | A11 Trung tâm học: ghi chú riêng tư, 4 KPI, biểu đồ đường “chấp nhận không sửa” theo 4 skill (8 tuần, 1 trục, nhãn cuối đường + legend), bảng đề xuất luật/ví dụ chung chờ duyệt (Duyệt / Từ chối; mục bị bộ đề chặn chỉ còn trạng thái) |
| 20g | `shots/20-ai-a11b-luot-chay-dem.png` | A11 Lượt chạy đêm: cổng bộ đề v42 → v43 theo từng bộ, phiên bản kho học đang chạy + Hoàn tác về v42, nhật ký từng bước 02:00–02:31 |
| 20h | `shots/20-ai-a12a-cau-hinh-tro-ly.png` | A12 Cấu hình › Trợ lý AI (đầu trang): Bật trợ lý, Tạm dừng để bảo trì; Mô hình: nhà cung cấp, địa chỉ Ollama + kiểm tra kết nối, model trả lời, model embedding |
| 20i | `shots/20-ai-a12b-cau-hinh-gioi-han-tu-hoc.png` | A12 (cuộn xuống): giới hạn tin/ngày, số cuộc tối đa, thời gian chờ; ngưỡng tự học (luật riêng, tự áp dụng luật chung, tắt luật, số người tối thiểu cho mẫu câu chung) |
| 20j | `shots/20-ai-a12c-nghiep-vu-co-tro-ly.png` | A9 Nghiệp vụ: thêm dòng “Trợ lý AI” vào Tính năng trong app |
| 20k | `shots/20-ai-a13-chi-tiet-nguoi-dung.png` | A13 Chi tiết người dùng (đã cuộn): thẻ Trợ lý AI tháng 9, chỉ số đếm (tin nhắn, cuộc trò chuyện, nháp đề xuất / xác nhận không sửa / sửa / hủy, hữu ích / chưa đúng, ngày chạm giới hạn) |

### Quyết định
- Sidebar thêm nhóm **Trợ lý**: *Trợ lý AI* (`sparkles`) và *Trung tâm học* (`book-open-check`, số đề xuất chờ duyệt). Nhóm này **chỉ vẽ ở khung mục I** (thuộc tính `data-ai` trên `aside.side`) để khung đã duyệt và ảnh cũ không đổi. Khi duyệt: thêm vào sidebar chung và chụp lại toàn bộ. Sub-nav Cấu hình và dòng Nghiệp vụ cũng chỉ thêm ở các khung mục I.
- Bố cục chat: danh sách 296px (tìm, nhóm Hôm nay / Tuần trước, mục chọn tô xám như sub-nav, Đã lưu trữ ở đáy) + khung chat. Nội dung chat rộng tối đa 780px, neo đáy như app chat. Tin của admin là bong bóng xám `surface-container-high`, câu trả lời là chữ thường không bong bóng. Màu đen chỉ còn cho nút chính.
- Ngôn ngữ thẻ dùng chung với mobile: **nét đứt = nháp / đề xuất, chưa có hiệu lực**; nét liền = dữ liệu thật. Mọi thao tác có hậu quả (gửi thông báo, khóa) đều chuyển sang màn/hộp xác nhận sẵn có, không có nút làm thẳng trong chat.
- Trợ lý quản trị đọc được đúng những gì bảng quản trị đọc được, **không đọc tin nhắn trợ lý của người dùng** (ghi ở dòng nhắc dưới ô nhập). Số liệu do hệ thống tính, câu trả lời luôn có dòng nguồn.
- Trung tâm học chỉ hiện số tổng hợp và mẫu câu đã bỏ tên/số tài khoản, có ≥ 5 người khác nhau xác nhận. Biểu đồ đường: 4 series `viz-1..4` theo thứ tự cố định, nét 2px, legend + nhãn giá trị cuối đường, có “Xem dạng bảng”. Ví dụ “cuối tuần → Giải trí” bị bộ đề chặn lấy đúng lỗi thật trong `ai/results/BENCHMARK-2026-10-08.md`.
- Tạm dừng trợ lý (bảo trì) làm giống Bảo trì ở A9: có hiệu lực ngay sau hộp xác nhận, không đi qua thanh Lưu. Các trường còn lại đi qua thanh Lưu như mọi mục cấu hình.
- Dữ liệu nhất quán: 1.284 / 1.247 / 37 người dùng; số người nhận thông báo 1.247; Nguyễn Minh Anh có 214 tin tháng 9, 96 nháp, 71 xác nhận không sửa (74%). Số trong A11 lấy theo đợt đo 08/10 (76% xác nhận không sửa, p50 ≈ 1,03 giây, router 9 skill, embedding bge-m3).

## Đọc ảnh (OCR) · chờ duyệt
Mockup mobile tương ứng: `../mockup/` mục K, ảnh `../mockup/shots/40-ocr-*.png`.

| # | File | Màn |
|---|---|---|
| 40a | `shots/40-ocr-a1-trung-tam-hoc.png` | A11 Trung tâm học › tab **Đọc ảnh**: dòng riêng tư, 4 KPI (8.768 ảnh 7 ngày, 71% nháp lưu không sửa, trung vị 2,6 giây, 6,2% không đọc được), cột chồng theo ngày 15/09–21/09 (Đọc được / Không đọc được, có legend, “Xem dạng bảng”), lý do không đọc được tổng hợp dạng thanh ngang một màu |
| 40b | `shots/40-ocr-a2-cau-hinh.png` | A12 Cấu hình › Trợ lý AI, card **Đọc ảnh**: Bật đọc ảnh, model qwen3.5:4b (chỉ đọc), 20 ảnh/người/ngày, ảnh tối đa 768px cạnh dài, chờ tối đa 30 giây, Lưu ảnh: không lưu (cố định) |

### Quyết định
- **Chỉ số liệu tổng hợp**: admin không xem được ảnh hay nội dung đọc được của người dùng, vì máy chủ không giữ ảnh. Lý do lỗi chỉ đếm theo loại, không có ảnh mẫu để mở. Ghi rõ ở dòng riêng tư đầu tab và ở hàng “Lưu ảnh” trong cấu hình.
- Tab “Đọc ảnh” nằm cuối seg Trung tâm học, card “Đọc ảnh” nằm trong Cấu hình › Trợ lý AI, **sau card Mô hình** (khung 40b bỏ qua card Trạng thái và Mô hình, coi như đã cuộn tới, nên card nằm ngay dưới tiêu đề). Cả hai **chỉ vẽ ở khung mục J** (`learnHead()` nhận thêm tham số, mặc định giữ nguyên nên 20f/20g không đổi). Khi duyệt: thêm tab vào mọi khung Trung tâm học và card vào A12, rồi chụp lại.
- Card dùng đúng hàng cấu hình A9/A12 (nhãn + mô tả trái, control 420px phải, ô số có đơn vị và khoảng hợp lệ). Model đọc ảnh và Lưu ảnh là ô khóa giống “Tiền tệ hiển thị” ở A9. Mọi trường đi qua thanh Lưu như các mục khác.
- Biểu đồ: một cột chồng mỗi ngày, xám đậm = đọc được, xám nhạt = không đọc được (không dùng đỏ vì không phải lỗi hệ thống), một trục, tổng ghi trên cột.
- Dữ liệu nhất quán: 7 cột cộng = 8.768; phần không đọc được cộng = 544 = 6,2%; 5 lý do cộng = 544; 8.224 nháp = 8.768 − 544, chia 71% / 21% / 8%. Trung vị 2,6 giây, model qwen3.5:4b, cạnh dài 768px lấy từ đợt đo spike (số tiền, ngày, thu/chi, nơi bán đúng 8/8).

## Xác thực số điện thoại · chờ duyệt
Mockup mobile tương ứng: `../mockup/` mục L, ảnh `../mockup/shots/50-sdt-*.png`. Email thật ở `../email/`.

| # | File | Màn |
|---|---|---|
| 50a | `shots/50-sdt-a1-cau-hinh.png` | A9 Đăng ký & truy cập, card **Xác thực số điện thoại**: trạng thái “Máy cổng nhận tin gần nhất 08:41 hôm nay” (chấm xanh), Bật xác thực, Số máy cổng 0901 234 567 (app không bao giờ hiện cho người dùng, chỉ dùng điền sẵn người nhận trong tin yêu cầu), Khóa máy cổng (chỉ ghi, “Đã lưu”, Tạo khóa mới), Địa chỉ nhận tin (webhook) chỉ đọc + sao chép, Mã hết hạn 5 phút (1–30), Số lần xin mã 3 lần / 10 phút (1–20) |
| 50b | `shots/50-sdt-a2-huong-dan.png` | Hộp **Cài máy cổng**: 4 bước (SIM trong máy Android luôn bật · cài app chuyển tiếp SMS · quy tắc chuyển mọi tin tới webhook kèm `x-gateway-key` · Gửi tin thử), kết quả “Đã nhận tin thử lúc 08:41” |
| 50c | `shots/50-sdt-a3-email.png` | A9 Email (SMTP) › card **Mẫu email**: xem trước 2 mẫu thật (Mã đặt lại mật khẩu, Đã gắn số điện thoại) bằng iframe tới `../email/`, liệt kê 3 mẫu cùng kiểu |

### Quyết định
- Card nằm trong **Đăng ký & truy cập**, sau card Đăng nhập (khung 50a coi như đã cuộn tới, nên card nằm ngay dưới tiêu đề, giống cách làm ở 40b). Sidebar và sub-nav giữ bản đã duyệt, không thêm mục mới.
- **Khóa máy cổng làm giống mật khẩu SMTP**: không bao giờ hiển thị lại; “Tạo khóa mới” sinh khóa, hiện **một lần** để chép sang máy cổng, khóa cũ hết hiệu lực ngay. Lịch sử thay đổi ghi `••••` như mọi giá trị bí mật.
- Địa chỉ webhook chỉ đọc (máy chủ tự sinh), có nút sao chép và link mở hộp hướng dẫn. Dòng trạng thái ở đầu card cho biết máy cổng còn sống: xanh khi có tin trong 24 giờ (đề xuất), quá lâu thì nên chuyển vàng.
- Hướng dẫn là hộp thoại (cùng kiểu hộp xác nhận bảo trì) để không chen vào card. Kết quả “Gửi tin thử” hiện inline trong hộp và cập nhật dòng trạng thái card.
- Mẫu email là **xem trước chỉ đọc**, nội dung sửa trong backend (`backend/src/auth/mail-templates.ts`), không có trình soạn trong admin. Đặt ở mục Email (SMTP) vì cùng nơi gửi.
- Mọi trường (trừ xem trước) đi qua thanh Lưu như các mục cấu hình khác. Ảnh chụp bằng `../shoot.mjs` (`cd admin && node ../design/shoot.mjs admin-mockup 50-sdt`).
