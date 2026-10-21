# Hướng dẫn test TrackerX (cho thành viên nhóm)

Dữ liệu chạy trên máy dev của nhóm trưởng. Mọi tài khoản dưới đây là dữ liệu mẫu, test thoải mái (thêm, sửa, xóa được). Thấy lỗi thì ghi theo mẫu ở cuối file.

## 1. Vào đâu để test

| Phần | Địa chỉ | Ghi chú |
|---|---|---|
| Trang quản trị (admin) | https://trackerx-admin.freepro.online | Mở bằng Chrome ở bất kỳ mạng nào |
| API + tài liệu API | https://trackerx-api.freepro.online/docs | Swagger, bấm "Try it out" để gọi thử |
| App điện thoại | APK hoặc `flutter run` từ `mobile/app` | Mặc định đã trỏ tới `https://trackerx-api.freepro.online/api`, dùng 4G hay Wi-Fi nào cũng được |

Máy chủ, dữ liệu và AI chạy trên laptop của nhóm trưởng qua Cloudflare Tunnel: **laptop phải bật** thì mới truy cập được. Không vào được thì báo nhóm trưởng.

## 2. Tài khoản

Mật khẩu chung của mọi tài khoản `@demo.thuchi.vn` là **demo123**.

| Vai trò | Email | Mật khẩu | Dùng để test |
|---|---|---|---|
| Admin chính | admin@thuchi.vn | admin123 | Toàn bộ trang quản trị |
| Admin phụ | bao.tran91@demo.thuchi.vn | demo123 | Admin thứ 2 (test phân quyền, lịch sử ai sửa gì) |
| User mẫu đầy đủ | demo@thuchi.vn | demo123 | App điện thoại: nhiều giao dịch, ví, ngân sách, mục tiêu tiết kiệm |
| User thường | nam.tran@demo.thuchi.vn | demo123 | User có nhiều dữ liệu |
| User thường | thuha.le@demo.thuchi.vn | demo123 | User có nhiều ví (có ví đã lưu trữ) |
| User thường | huong.ho@demo.thuchi.vn | demo123 | |
| User thường | phuoc.vo@demo.thuchi.vn | demo123 | |
| User **bị khóa** | tung.bui93@demo.thuchi.vn | demo123 | Phải báo "Tài khoản đã bị khóa", không vào được |
| User **bị khóa** | nghia.pham@demo.thuchi.vn | demo123 | |
| User test đọc ảnh | chinhan.ocr@test.local | ocrtest123 | Tên "Nguyễn Chí Nhân", dùng test quét ảnh chuyển khoản |

Muốn tài khoản mới tinh thì bấm **Tạo tài khoản mới** trong app (email bất kỳ, không cần email thật).
Muốn test **quên mật khẩu** thì phải đăng ký bằng **email thật của bạn**, vì mã OTP gửi về email thật.

> Admin không đăng nhập được app user và ngược lại: tài khoản user đăng nhập trang admin sẽ bị từ chối.

## 3. App điện thoại: các màn hình và chức năng

Thanh dưới: **Trang chủ · Lịch sử · [＋] · Báo cáo · Cài đặt**.

| # | Màn hình | Chức năng cần test |
|---|---|---|
| 1 | Đăng nhập / Đăng ký | Đăng nhập, đăng ký mới, sai mật khẩu báo lỗi, tài khoản bị khóa báo lỗi |
| 2 | Quên mật khẩu | Nhập email → nhận mã 6 số qua email → đặt mật khẩu mới. Nhập sai mã nhiều lần thì mã bị hủy |
| 3 | Trang chủ | Tổng số dư, ngân sách tháng đã dùng bao nhiêu %, chi hôm nay / tháng này, giao dịch gần đây, mẫu nhập nhanh |
| 4 | Ghi giao dịch (chạm ＋) | Nhập số tiền, chọn khoản chi / thu nhập, danh mục, ví, ngày, ghi chú. Lưu xong số dư ví đổi đúng |
| 5 | Menu nhấn giữ ＋ | Hỏi trợ lý, Quét hóa đơn, Thu nhập, Chuyển tiền, các mẫu nhập nhanh (chạm 1 lần là ghi luôn) |
| 6 | Chuyển tiền | Chuyển giữa 2 ví của mình, số dư 2 ví đổi đúng, không chuyển quá số dư |
| 7 | Lịch sử | Danh sách giao dịch theo ngày, tìm kiếm, lọc; chạm vào để xem / sửa / xóa |
| 8 | Báo cáo | Biểu đồ thu chi theo tháng, theo danh mục |
| 9 | Ví | Thêm ví (tiền mặt, ngân hàng, ví điện tử), sửa, lưu trữ ví |
| 10 | Ngân sách | Đặt hạn mức tháng (tổng hoặc theo danh mục), cảnh báo khi gần / vượt hạn mức |
| 11 | Tiết kiệm | Tạo mục tiêu, nạp / rút tiền vào mục tiêu, xem tiến độ |
| 12 | Giao dịch định kỳ | Tạo khoản lặp (vd tiền nhà mỗi tháng), tạm dừng, tiếp tục |
| 13 | Thông báo | Cảnh báo ngân sách, thông báo từ admin, đánh dấu đã đọc |
| 14 | Trợ lý AI | Chat tiếng Việt: "cà phê 45k", "ăn trưa 50k hôm qua" → hiện **nháp** → bấm Xác nhận mới lưu. Hỏi "tháng này tiêu bao nhiêu", "ngân sách còn bao nhiêu", "gợi ý tiết kiệm". Bấm Hữu ích / Chưa đúng |
| 15 | Quét hóa đơn | Chụp / chọn ảnh hóa đơn hoặc ảnh chụp màn hình chuyển khoản → đọc số tiền, ngày, người nhận → nháp → Lưu / Sửa / Hủy. Giới hạn 20 ảnh/ngày. Ảnh mờ thì báo "chưa đọc được" |
| 16 | Ghi từ thông báo ngân hàng (Android) | Bật trong Cài đặt, cấp quyền đọc thông báo; khi app ngân hàng báo biến động số dư thì TrackerX tự tạo giao dịch chờ duyệt |
| 17 | Cài đặt | Đổi tên, đổi mật khẩu, đăng xuất / đăng xuất mọi thiết bị, xóa tài khoản, cài đặt trợ lý AI (xóa trí nhớ, góp ví dụ ẩn danh) |
| 18 | Số điện thoại | **Đang tắt** (chưa có máy cổng nhận SMS). Khi bật: gắn số, gỡ số, quên mật khẩu qua số điện thoại |
| 19 | Bảo trì / cập nhật bắt buộc | Khi admin bật bảo trì thì app hiện màn bảo trì; phiên bản quá cũ thì bắt cập nhật |

Lưu ý khi test:
- Trợ lý AI chạy model trên máy dev nên mỗi câu trả lời mất khoảng 1–5 giây, đọc ảnh khoảng 5–20 giây.
- Trợ lý **không bao giờ tự ghi**, luôn phải bấm Xác nhận.

## 4. Trang quản trị: các màn hình và chức năng

Đăng nhập bằng `admin@thuchi.vn / admin123`.

| # | Màn hình | Chức năng cần test |
|---|---|---|
| 1 | Tổng quan | Số user, giao dịch, biểu đồ theo thời gian, cảnh báo bất thường |
| 2 | Người dùng | Tìm, lọc, khóa / mở khóa user (user bị khóa bị đá ra khỏi app ngay), xem chi tiết |
| 3 | Chi tiết người dùng | Thông tin, ví, thống kê, mức dùng trợ lý AI (chỉ số đếm, không xem nội dung chat) |
| 4 | Giao dịch | Xem toàn bộ giao dịch, lọc theo user / danh mục / thời gian, xuất file |
| 5 | Danh mục | Danh mục hệ thống dùng chung: thêm, sửa, ẩn, đổi icon / màu |
| 6 | Thông báo | Soạn thông báo gửi tới user (xem trước trên khung điện thoại), lịch sử đã gửi |
| 7 | Cấu hình | Từng mục: **Chung** (tên app, email hỗ trợ); **Đăng ký & truy cập** (bảo trì, cho phép đăng ký, giới hạn đăng nhập sai, xác thực số điện thoại); **Email (SMTP)** (gửi email thử, xem trước 5 mẫu email); **Mật khẩu & OTP**; **Nghiệp vụ** (bật / tắt tính năng app); **Ứng dụng di động** (phiên bản tối thiểu); **Trợ lý AI** (model, giới hạn, đọc ảnh) |
| 8 | Lịch sử thay đổi | Ai sửa cấu hình gì, lúc nào (mật khẩu luôn bị ẩn) |
| 9 | Trợ lý AI (admin) | Chat hỏi về hệ thống: "tổng quan hệ thống", "soạn thông báo bảo trì tối nay" → nháp → mở trình soạn |
| 10 | Trung tâm học | Tỉ lệ nháp được chấp nhận, đề xuất luật chờ duyệt, lượt chạy học ban đêm, tab **Đọc ảnh** (thống kê quét hóa đơn) |
| 11 | Tài khoản | Đổi tên, đổi mật khẩu admin |

Việc nên thử chéo admin ↔ app:
- Bật **bảo trì** → app user hiện màn bảo trì → tắt thì app dùng lại được.
- Tắt **Cho phép đăng ký** → app báo tạm ngưng đăng ký.
- **Khóa** một user đang đăng nhập app → app tự đăng xuất.
- Gửi **thông báo** → user nhận trong màn Thông báo.
- Tắt **Đọc ảnh** trong Cấu hình › Trợ lý AI → app ẩn mục Quét hóa đơn.

## 5. Mẫu báo lỗi

```
Màn hình: (vd Ghi giao dịch)
Tài khoản: (vd demo@thuchi.vn)
Các bước: 1) ... 2) ... 3) ...
Kết quả thấy: ...
Kết quả mong muốn: ...
Ảnh / video: (đính kèm)
Thiết bị: (vd Samsung A52, Android 13 / Chrome trên Windows)
```
