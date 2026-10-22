# Thu Chi · Mockup mobile

Mở `index.html` trực tiếp. Ảnh 2x trong `shots/`, toàn bộ gallery ở `shots/overview.png`. Token ở `../tokens.md`, nguyên tắc ở `../DESIGN.md`. Mục A–I (25 màn, `shots/01…23`) đã duyệt. Mục **J · Trợ lý AI** (`shots/30-ai-*.png`) mục **K · Đọc hóa đơn** (`shots/40-ocr-*.png`) mục **L · Số điện thoại** (`shots/50-sdt-*.png`) và mục **M · Thông báo theo nhóm & tự ghi** (`shots/60-tb-*.png`) đang **chờ duyệt**.

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
| 50c | `shots/50-sdt-03-gui-tin.png` | **iOS**: hiện khung soạn tin trong app, bấm Gửi. Gửi yêu cầu xác nhận: một dòng giải thích (Tin nhắn mở với yêu cầu soạn sẵn, bấm Gửi từ chính số vừa nhập), **Nội dung xác nhận** 6 ô 4 8 2 9 1 0, hết hạn sau 4:32, nút Gửi yêu cầu xác nhận, phí 1 tin thường. Không hiện số điện thoại nào |
| 50d | `shots/50-sdt-04-dang-cho.png` | Quay lại từ Tin nhắn: “Đang chờ xác nhận…” (shimmer chữ + thanh chạy mảnh), mã + thời gian còn lại, gợi ý khi chưa gửi được (không kèm số); Gửi lại yêu cầu · Đổi số khác |
| 50e | `shots/50-sdt-05-thanh-cong.png` | Đã xác thực số điện thoại (không hiện số), đã gửi email xác nhận; Xong |
| 50f | `shots/50-sdt-06-loi.png` | Mã đã hết hạn: mã mờ, thẻ trung tính (không đỏ, không kèm số), còn 2 lần lấy mã trong 10 phút; Lấy mã mới · Đổi số khác |
| 50f | `shots/50-sdt-06b-loi-so-da-dung.png` | Biến thể: số đã gắn với tài khoản khác, lỗi đỏ ngay dưới ô số |
| 50g | `shots/50-sdt-07-quen-mk-chon.png` | Quên mật khẩu: hai thẻ Qua email (mã 6 số trong email) / Qua số điện thoại (gửi yêu cầu xác nhận từ số đã gắn) |
| 50h | `shots/50-sdt-08-quen-mk-sdt.png` | Quên mật khẩu qua SĐT, bước cuối: banner xanh nhạt “Đã xác nhận số điện thoại”, hai ô mật khẩu mới, báo sẽ có email |
| 50i | `shots/50-sdt-09-go-so.png` | Cài đặt đã gắn “0912 ••• 678 · Đã xác thực” + sheet Gỡ số điện thoại? (nói “số này”, không lặp số) cần mật khẩu, nút Gỡ số (đỏ nhạt) giống sheet Xóa tài khoản |
| 50j | `shots/50-sdt-10-android-quyen.png` | **Android** lần đầu bấm Gửi yêu cầu xác nhận: hộp quyền hệ thống “Cho phép Thu Chi gửi và xem tin nhắn SMS?” (Material 3, Cho phép / Không cho phép) trên màn 03, thẻ lý do của app phía trên (chỉ 1 tin chứa 6 số, một lần, phí tin thường) |
| 50k | `shots/50-sdt-11-android-chon-sim.png` | Android máy 2 SIM: sheet “Gửi từ SIM nào?” (SIM 1 · Viettel / SIM 2 · Vinaphone, radio), gợi ý chọn SIM của số vừa nhập, không hiện số; Gửi yêu cầu xác nhận |
| 50l | `shots/50-sdt-12-android-dang-gui.png` | Android sau khi app tự gửi: “Đã gửi yêu cầu” (tự gửi từ SIM 1 · Viettel, không mở Tin nhắn) → “Đang chờ xác nhận…”, mã + thời gian còn lại; Gửi lại yêu cầu · Đổi số khác |
| 50m | `shots/50-sdt-13-android-tu-choi.png` | Android từ chối quyền: ghi chú trung tính “Không có quyền gửi SMS…”, nút Mở Tin nhắn để gửi (về luồng iOS/soạn sẵn), link Cấp quyền trong Cài đặt |

### Quyết định
- **Người dùng gửi yêu cầu, Thu Chi không nhắn**: khái niệm trong app là “Gửi yêu cầu xác nhận”, không nói “nhắn tới Thu Chi”. Màn 50c chỉ có một việc là bấm nút này (mở Tin nhắn soạn sẵn người nhận + 6 số). Không có ô nhập mã. **App không bao giờ hiện số máy cổng**, số này chỉ dùng để điền sẵn người nhận. Câu “phí 1 tin nhắn thường” và “Thu Chi không nhắn/gọi” xuất hiện ở 50b và 50c.
- **Không hiện số điện thoại nào trong luồng xác nhận** (50c–50h), kể cả số của chính người dùng: chỉ nhắc “gửi từ chính số điện thoại bạn vừa nhập”. Số (đã che) chỉ hiện ở dòng Cài đặt (50a/50i) và trong ô nhập ở 50b/50f-b. Bỏ cảnh báo SIM và nút Sao chép mã để màn 50c chỉ còn một việc.
- **Phát hành APK, không lên Google Play → Android tự gửi SMS** (quyền `SEND_SMS`): bấm Gửi yêu cầu xác nhận là gửi luôn, không mở Tin nhắn (50j–50l). Máy 2 SIM thì hỏi SIM bằng tên nhà mạng + khe, không hiện số. Từ chối quyền thì quay về cách mở Tin nhắn soạn sẵn (50m). **iOS** giữ khung soạn tin của hệ thống (50c).
- **Chờ không spinner**: dòng trạng thái shimmer (tắt khi reduce-motion) + thanh chạy mảnh, app tự hỏi trạng thái và tự sang 50e.
- **Lỗi**: hết hạn dùng thẻ trung tính như OCR 40f (không phải lỗi của người dùng); số đã dùng là lỗi nhập nên hiện đỏ ngay dưới ô, giống lỗi inline ở admin. Hai biến thể tách thành 2 ảnh (50f, 50f-b) thay vì ghép một màn, cho đúng ngữ cảnh mỗi lỗi.
- **Cài đặt thêm nhóm “Tài khoản”** ngay dưới thẻ hồ sơ, chuyển “Đổi mật khẩu” từ nhóm Ứng dụng vào đây. Quản trị tắt tính năng thì dòng Số điện thoại và thẻ “Qua số điện thoại” ở 50g ẩn.
- **Quên mật khẩu** giữ đúng bố cục màn 02: app không biết người dùng đã gắn số hay chưa (không lộ thông tin tài khoản), nên luôn hiện cả hai cách kèm ghi chú. Bước nhập số và gửi yêu cầu xác nhận dùng lại màn 50b/50c (không có ô mật khẩu).
- Dữ liệu: số người dùng 0912 345 678 (chỉ trong ô nhập; Cài đặt hiện che 0912 ••• 678), mã 482910 (số máy cổng 0901 234 567 chỉ có ở admin), email minhanh.nguyen@gmail.com / minh•••@gmail.com như các màn đã duyệt.
- Thêm CSS ở cuối `styles.css`: `.otp.show`, `.input.error`, `.err-t`, `.ok-banner`, `.kv`, `.indet`, `.opt`, `.adlg` (hộp quyền Android), `.why`. Ảnh chụp bằng `../shoot.mjs` (`cd admin && node ../design/shoot.mjs mockup 50-sdt`).

## M · Thông báo theo nhóm & tự ghi (chờ duyệt)
Backend đã có nhóm thông báo và số chưa đọc theo nhóm; app hiện 4 nhóm `balance · budget · system · security` (định kỳ tạm dừng backend gộp vào `system`). Màn gốc: 19 Thông báo (mục H) và màn thật `bank_settings_screen.dart` / `bank_pending_screen.dart` (chưa có mockup riêng, nên M dựng lại đúng component của app: card công tắc, bubble, thẻ nét đứt, chip Chọn ví vàng).

| # | File | Màn |
|---|---|---|
| 60a | `shots/60-tb-01-thong-bao-nhom.png` | Thông báo: menu tab gọn “Tất cả · Số dư · Ngân sách · Hệ thống · Bảo mật” vừa khít chiều ngang, không cuộn (chữ 14/500, tab đang chọn chữ mực + gạch dưới 2px, tab khác xám, đường kẻ mảnh dưới menu, chấm nhỏ cạnh tên tab = có tin chưa đọc, không hiện số). Nhóm Hôm nay / Hôm qua, mỗi dòng có bubble theo nhóm (Số dư `landmark`, Ngân sách `target` vàng/đỏ theo 80%/100%, Bảo mật `shield-check`, Hệ thống = logo TrackerX vuông bo; định kỳ tạm dừng giữ `circle-pause` nhưng nhãn “· Hệ thống”), dòng giờ kèm tên nhóm, chấm chưa đọc, “Đánh dấu đã đọc” ở thanh trên (áp dụng cho tab đang chọn) |
| 60b | `shots/60-tb-02-loc-bien-dong.png` | Tab Số dư: dòng gợi ý + link Cài đặt; mỗi khoản có số tiền có dấu (thu xanh), ví, nguồn (thông báo / SMS), danh mục; khoản vừa chạm mở rộng Hoàn tác · Xem giao dịch; khoản đã hoàn tác mờ + badge “Đã hoàn tác” |
| 60c | `shots/60-tb-03-hoan-tac.png` | Sheet “Hoàn tác khoản tự ghi?”: số tiền, nội dung, ví, giờ; giao dịch bị xóa, ví cộng lại 45.000đ; Hoàn tác (đỏ nhạt) · Giữ lại |
| 60c-b | `shots/60-tb-03b-da-hoan-tac.png` | Sau khi hoàn tác: dòng chuyển “Đã hoàn tác”, toast “Đã hoàn tác: Cà phê · 45.000đ đã trả lại ví MB Bank” + Xem ví |
| 60d | `shots/60-tb-04-cai-dat-tu-ghi.png` | Ghi từ thông báo ngân hàng: công tắc Bật tính năng (giữ nguyên) + công tắc mới **Tự động ghi vào sổ** (“Đang bật trên máy này”), 3 quy tắc gọn, dòng đề xuất “Khoản lớn chờ xác nhận · Từ 5.000.000đ”, link Xem các khoản đã tự ghi / Chờ xác nhận, Ngân hàng đã ghép ví (VPBank chip vàng Chọn ví) |
| 60e | `shots/60-tb-05-dong-y-tu-ghi.png` | Sheet đồng ý riêng khi bật: lưu ngay vào tài khoản như khi bấm Xác nhận, mỗi khoản có thông báo Biến động số dư + Hoàn tác, khoản chưa rõ vẫn chờ, ghi khi app chạy / lần mở tiếp theo, chỉ máy này, tắt lúc nào cũng được; Bật tự động ghi · Để sau |
| 60f | `shots/60-tb-06-danh-sach-cho.png` | Màn “Từ thông báo ngân hàng” (thay màn Chờ xác nhận): **Đã tự ghi** hôm nay (mỗi dòng có Hoàn tác) và **Chờ xác nhận** (thẻ nét đứt như cũ + chip lý do vàng “Chưa chọn ví cho VPBank” / “Chưa rõ danh mục”, Bỏ qua · Xác nhận) |

### Quyết định
- Thông báo tự ghi dùng đúng mẫu backend: tiêu đề “−45.000đ · Cà phê”, thân “Đã tự ghi vào ví … · Từ thông báo …. Sai thì chạm để hoàn tác.”. Ví trong mockup đổi theo 4 ví mẫu (MB Bank, Techcombank, MoMo) để khớp dữ liệu các màn đã duyệt; VPBank là ngân hàng chưa ghép ví.
- **Menu tab chữ, không phải chip**: 5 tab dàn đều hết chiều ngang 390, không cuộn (đúng luật “không cuộn ngang” của `../DESIGN.md`). Chưa đọc chỉ là chấm 4px cạnh tên tab, không badge số. Tab không có tin chưa đọc thì không có chấm.
- Bubble theo nhóm vẫn gần đơn sắc: chỉ Ngân sách giữ màu vàng / đỏ như màn 19 (màu mang nghĩa 80% / vượt). Hệ thống dùng logo TrackerX để người dùng nhận ra tin chính thức. Số tiền trong tiêu đề: thu xanh, chi mực.
- **Hoàn tác có bước xác nhận** vì nó xóa giao dịch thật; nút đỏ nhạt giống sheet Xóa tài khoản / Gỡ số. Xong thì không xóa thông báo mà chuyển sang “Đã hoàn tác” để còn dấu vết. Không có “làm lại”: muốn ghi lại thì nhập tay.
- Màn danh sách đổi tên “Chờ xác nhận” → **“Từ thông báo ngân hàng”** vì giờ có hai phần. Lý do không tự ghi hiện bằng chip vàng ngay trên thẻ; nút Xác nhận khi chưa có ví vẫn mở chọn ví như app hiện tại.
- Thêm CSS ở cuối `styles.css`: `.tb-tabs`, `.tb-tab`, `.tb-dot`, `.bubble.brand`, `.tb-hint`, `.tb-acts`, `.tb-undone`, `.tb-rule`, `.tb-cap`, `.tb-points`, `.tb-undo`, `.tb-amt`, `.tb-why`, `.pchip`. Ảnh chụp bằng `../shoot.mjs` (`cd admin && node ../design/shoot.mjs mockup 60-tb`). Không chụp lại `overview.png`.

### Quyết định cần chốt (đề xuất)
1. **5 tab**: Tất cả · Số dư · Ngân sách · Hệ thống · Bảo mật. **Nhắc nhở gộp vào Hệ thống** (backend map định kỳ tạm dừng vào `system`). Số dư đứng đầu vì nhiều nhất và cần hành động (hoàn tác); Ngân sách thứ hai vì là cảnh báo tiền; Hệ thống / Bảo mật ít, để sau. Bảo mật không bao giờ ẩn khỏi Tất cả.
2. **Tự động ghi mặc định TẮT**, theo từng máy, bật phải qua sheet 60e. Lý do: thay đổi lời hứa cũ “chỉ khoản bạn Xác nhận mới được lưu”, nên cần đồng ý riêng; sheet đồng ý chung (bank_disclosure_sheet) cần thêm một câu “hoặc khoản app tự ghi khi bạn bật Tự động ghi”.
3. **Ngưỡng số tiền: nên có, tùy chọn, mặc định bật ở 5.000.000đ** (khoản ≥ 5.000.000đ vẫn chờ xác nhận; chọn Tắt / 1.000.000đ / 5.000.000đ / 10.000.000đ). Một khoản lớn ghi sai làm lệch báo cáo và ngân sách cả tháng, trong khi khoản lớn ít nên bấm Xác nhận không phiền. Nếu muốn gọn cho bản đầu thì bỏ dòng này ở 60d và cố định 5.000.000đ trong code.
4. **Chưa cho tắt tiếng từng nhóm** ở bản này. Chip lọc đã đủ để tìm; tắt nhóm dễ làm người dùng bỏ lỡ Biến động số dư (đường hoàn tác) và Bảo mật. Xem lại khi có thông báo đẩy (FCM).
5. Khoản trùng app ngân hàng + SMS trong 3 phút: ghi 1 lần, không hiện gì thêm (không làm người dùng phải hiểu cơ chế). Nếu trùng nhưng số tiền khác nhau thì coi là 2 khoản.
6. “Đánh dấu đã đọc” chỉ áp dụng cho tab đang chọn (ở Tất cả là toàn bộ); ẩn khi nhóm không còn tin chưa đọc.
