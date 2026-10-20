# Thu Chi · Mockup mobile

Mở `index.html` trực tiếp. Ảnh 2x trong `shots/`, toàn bộ gallery ở `shots/overview.png`. Token ở `../tokens.md`, nguyên tắc ở `../DESIGN.md`. Mục A–I (25 màn, `shots/01…23`) đã duyệt. Mục **J · Trợ lý AI** (`shots/30-ai-*.png`) mục **K · Đọc hóa đơn** (`shots/40-ocr-*.png`) và mục **L · Số điện thoại** (`shots/50-sdt-*.png`) đang **chờ duyệt**.

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

## K · Đọc hóa đơn (OCR) (chờ duyệt)
Admin tương ứng: `../admin-mockup/` mục J, ảnh `../admin-mockup/shots/40-ocr-a*.png`.

| # | File | Màn |
|---|---|---|
| 40a | `shots/40-ocr-01-loi-vao.png` | Lối vào: nhấn giữ ＋, dòng “Quét hóa đơn” (`scan-line`, nhãn Mới) ngay dưới “Hỏi trợ lý” |
| 40b | `shots/40-ocr-02-chon-anh.png` | Sheet chọn nguồn: Chụp ảnh / Chọn từ thư viện (kể cả ảnh chụp màn hình), gợi ý chụp rõ Tổng tiền, dòng riêng tư, còn 17/20 ảnh hôm nay |
| 40c | `shots/40-ocr-03-dang-doc.png` | Đang đọc (~3 giây): ảnh thu nhỏ, dòng trạng thái “Đang đọc hóa đơn…” (shimmer chữ), skeleton đúng hình thẻ nháp, nút Hủy. Không spinner |
| 40d | `shots/40-ocr-04-ket-qua-hoa-don.png` | Hóa đơn Highlands Coffee −113.000đ: thẻ nháp nét đứt, Khoản chi, nơi bán, Ăn uống, ví MoMo (đoán theo thói quen), ngày giờ, “3 món” thu gọn, ảnh nhỏ bấm xem lại, dòng nguồn “Đọc từ ảnh · 2,6 giây”; Hủy · Sửa · Lưu khoản chi |
| 40e | `shots/40-ocr-05-ket-qua-chuyen-khoan.png` | Ảnh chuyển khoản VietinBank −16.900đ tới KHUONG BA SON: khoản chi vì bạn là người chuyển; VietinBank không có trong 4 ví nên chip vàng “Chọn ví”, danh mục chưa đoán được để trống “Chọn danh mục”, nút Lưu khóa tới khi chọn đủ |
| 40e | `shots/40-ocr-05b-ket-qua-nhan-tien.png` | Biến thể: NGUYEN MINH ANH ở phía người nhận → khoản thu +250.000đ (xanh), ví MB Bank chọn theo ngân hàng nhận, Lưu khoản thu |
| 40f | `shots/40-ocr-06-khong-doc-duoc.png` | Không đọc được (ảnh mờ / không phải hóa đơn): thông báo trung tính, phần đã đọc được, gợi ý chụp lại; Chụp lại · Nhập tay (mở Ghi giao dịch điền sẵn nơi bán, ngày) |
| 40g | `shots/40-ocr-07-het-luot.png` | Hết 20 ảnh hôm nay: thẻ giờ mở lại (00:00, còn 4 giờ 9 phút) + Ghi giao dịch thủ công, hai nguồn ảnh mờ đi |

### Quyết định
- **Lối vào chỉ thêm một dòng vào menu nhấn giữ ＋**, đặt cạnh “Hỏi trợ lý” vì cùng là cách ghi nhanh có AI. Không đụng Trang chủ, tab bar hay màn Ghi giao dịch đã duyệt. Menu mọc lên từ đáy nên dài thêm 50px vẫn vừa. Quản trị tắt Đọc ảnh thì dòng này ẩn.
- Màn kết quả là màn con “Quét hóa đơn” đẩy từ Trang chủ, **ẩn tab bar**, thanh trên dùng `.ai-bar` với dòng “Ảnh không lưu trên máy chủ”. Không nhét vào cuộc trò chuyện của trợ lý để không tốn lượt hỏi và không trộn lịch sử chat.
- **Nháp giống mục J**: viền nét đứt + badge “Nháp · chưa lưu” = chưa ghi gì. Mỗi dòng chạm để sửa ngay trong nháp, “Sửa” mở Ghi giao dịch điền sẵn. Chỉ nút đen “Lưu khoản chi / Lưu khoản thu” mới ghi. Hủy thì bỏ nháp và ảnh trên máy.
- **Thu hay chi**: tên người dùng ở phía người nhận → khoản thu (số xanh, `+`), còn lại là khoản chi (số mực, `−`). Thẻ luôn ghi lý do một dòng (“Bạn là người chuyển…”, “Người nhận là NGUYEN MINH ANH (bạn)…”) và tag Khoản chi / Khoản thu sửa được.
- **Ví**: khớp ngân hàng trên ảnh với ví của người dùng; hóa đơn giấy thì đoán theo thói quen (luật “cà phê → Ăn uống · MoMo” ở M14). Không khớp thì chip vàng “Chọn ví”, không đoán bừa.
- **Quyền riêng tư**: ảnh được thu nhỏ trên máy (768px), máy chủ đọc xong xóa ngay. Ảnh nhỏ trong thẻ là bản trên điện thoại, mất khi lưu hoặc hủy. Câu riêng tư xuất hiện ở sheet chọn ảnh và thanh trên mọi màn kết quả.
- Loading không spinner: dòng trạng thái thật + skeleton đúng hình thẻ nháp. Không đọc được thì dùng thẻ trung tính, không đỏ (không phải lỗi của người dùng), luôn có đường Nhập tay.
- Danh sách món chỉ hiện khi model đọc được (đo spike: món đọc được 0/N ở cấu hình nhanh), mặc định thu gọn thành một dòng “3 món”. 3 món cộng đúng 39.000 + 45.000 + 29.000 = 113.000đ.
- Thêm CSS ở cuối `styles.css`: `.tag.warn`, `.ocr-thumb`, `.receipt`, `.bankshot` (ảnh vẽ bằng HTML, không dùng ảnh ngoài).

## L · Số điện thoại (chờ duyệt)
Admin tương ứng: `../admin-mockup/` mục K, ảnh `../admin-mockup/shots/50-sdt-a*.png`. Email thật ở `../email/`.

| # | File | Màn |
|---|---|---|
| 50a | `shots/50-sdt-01-cai-dat.png` | Cài đặt: nhóm mới **Tài khoản** (Đổi mật khẩu, Số điện thoại “Chưa gắn”), dòng gợi ý “Dùng để lấy lại mật khẩu khi quên” |
| 50b | `shots/50-sdt-02-nhap-so.png` | Gắn số điện thoại: ô số + mật khẩu hiện tại, báo trước bước sau sẽ gửi yêu cầu xác nhận từ số của bạn (1 tin, phí tin thường), Thu Chi không nhắn/gọi; Tiếp tục |
| 50c | `shots/50-sdt-03-gui-tin.png` | Gửi yêu cầu xác nhận: mã 6 ô 4 8 2 9 1 0, hết hạn sau 4:32, cảnh báo vàng phải gửi từ SIM 0912 345 678; nút **Gửi yêu cầu xác nhận** (mở Tin nhắn soạn sẵn) · Sao chép mã 6 số (dự phòng), phí 1 tin thường. Không hiện số máy cổng |
| 50d | `shots/50-sdt-04-dang-cho.png` | Quay lại từ Tin nhắn: “Đang chờ xác nhận…” (shimmer chữ + thanh chạy mảnh), tóm tắt mã / gửi từ, gợi ý khi chưa gửi được; Gửi lại yêu cầu · Đổi số khác |
| 50e | `shots/50-sdt-05-thanh-cong.png` | Đã gắn số 0912 ••• 678, đã gửi email xác nhận; Xong |
| 50f | `shots/50-sdt-06-loi.png` | Mã đã hết hạn: mã mờ, thẻ trung tính (không đỏ), còn 2 lần lấy mã trong 10 phút; Lấy mã mới · Đổi số khác |
| 50f | `shots/50-sdt-06b-loi-so-da-dung.png` | Biến thể: số đã gắn với tài khoản khác, lỗi đỏ ngay dưới ô số |
| 50g | `shots/50-sdt-07-quen-mk-chon.png` | Quên mật khẩu: hai thẻ Qua email (mã 6 số trong email) / Qua số điện thoại (gửi yêu cầu xác nhận từ số đã gắn) |
| 50h | `shots/50-sdt-08-quen-mk-sdt.png` | Quên mật khẩu qua SĐT, bước cuối: banner xanh nhạt “Đã xác nhận số 0912 ••• 678”, hai ô mật khẩu mới, báo sẽ có email |
| 50i | `shots/50-sdt-09-go-so.png` | Cài đặt đã gắn “0912 ••• 678 · Đã xác thực” + sheet Gỡ số điện thoại? cần mật khẩu, nút Gỡ số (đỏ nhạt) giống sheet Xóa tài khoản |

### Quyết định
- **Người dùng gửi yêu cầu, Thu Chi không nhắn**: khái niệm trong app là “Gửi yêu cầu xác nhận”, không nói “nhắn tới Thu Chi”. Màn 50c chỉ có một việc là bấm nút này (mở Tin nhắn soạn sẵn người nhận + 6 số). Không có ô nhập mã. **App không bao giờ hiện số máy cổng**, số này chỉ dùng để điền sẵn người nhận. “Sao chép mã 6 số” là dự phòng khi tin chưa có sẵn mã. Câu “phí 1 tin nhắn thường” và “Thu Chi không nhắn/gọi” xuất hiện ở 50b và 50c.
- **Số gửi phải khớp**: cảnh báo vàng ở 50c (không phải lỗi, là điều kiện) nhắc cả trường hợp máy 2 SIM. 50d nhắc lại “Gửi từ 0912 345 678”.
- **Chờ không spinner**: dòng trạng thái shimmer (tắt khi reduce-motion) + thanh chạy mảnh, app tự hỏi trạng thái và tự sang 50e.
- **Lỗi**: hết hạn dùng thẻ trung tính như OCR 40f (không phải lỗi của người dùng); số đã dùng là lỗi nhập nên hiện đỏ ngay dưới ô, giống lỗi inline ở admin. Hai biến thể tách thành 2 ảnh (50f, 50f-b) thay vì ghép một màn, cho đúng ngữ cảnh mỗi lỗi.
- **Cài đặt thêm nhóm “Tài khoản”** ngay dưới thẻ hồ sơ, chuyển “Đổi mật khẩu” từ nhóm Ứng dụng vào đây. Quản trị tắt tính năng thì dòng Số điện thoại và thẻ “Qua số điện thoại” ở 50g ẩn.
- **Quên mật khẩu** giữ đúng bố cục màn 02: app không biết người dùng đã gắn số hay chưa (không lộ thông tin tài khoản), nên luôn hiện cả hai cách kèm ghi chú. Bước nhập số và gửi yêu cầu xác nhận dùng lại màn 50b/50c (không có ô mật khẩu).
- Dữ liệu: số người dùng 0912 345 678 (hiện che 0912 ••• 678), mã 482910 (số máy cổng 0901 234 567 chỉ có ở admin), email minhanh.nguyen@gmail.com / minh•••@gmail.com như các màn đã duyệt.
- Thêm CSS ở cuối `styles.css`: `.otp.show`, `.input.error`, `.err-t`, `.ok-banner`, `.kv`, `.indet`, `.opt`. Ảnh chụp bằng `../shoot.mjs` (`cd admin && node ../design/shoot.mjs mockup 50-sdt`).
