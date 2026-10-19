# Đưa Thu Chi lên Google Play: khai báo cho tính năng "Ghi từ thông báo ngân hàng"

Tính năng đọc thông báo ngân hàng (`lib/features/bank_notifications`, `android/.../banknotif`) dùng quyền **Truy cập thông báo** (`BIND_NOTIFICATION_LISTENER_SERVICE`). Tài liệu này ghi cách viết và khai báo để người duyệt Google Play hiểu đúng mục đích, **không coi là thu thập dữ liệu trái phép**.

Nguyên tắc: nói thật, nói cụ thể, và ở mọi chỗ (trong app, chính sách quyền riêng tư, mục An toàn dữ liệu, ghi chú cho người duyệt) phải nói **giống nhau**. Người duyệt đối chiếu các chỗ này với nhau.

---

## 1. App dùng và KHÔNG dùng quyền gì

| Quyền / thành phần | Có dùng? | Lý do |
|---|---|---|
| `INTERNET` | Có | Gọi API Thu Chi |
| `BIND_NOTIFICATION_LISTENER_SERVICE` (service `BankNotificationListener`) | Có | Đọc thông báo biến động số dư. Người dùng tự bật trong Cài đặt Android, app không tự cấp được |
| `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_SPECIAL_USE` | **Không** | Bản module gốc có dùng. Đã bỏ vì loại `specialUse` phải khai báo kèm video trên Play Console và bị duyệt kỹ. NotificationListenerService do hệ thống tự gắn, không cần foreground service |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | **Không** | Quyền dễ bị gỡ app nếu không thuộc nhóm được phép. App chỉ mở trang danh sách tối ưu pin (`ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS`, không cần quyền) để người dùng tự chọn |
| `RECEIVE_BOOT_COMPLETED` (BootReceiver) | **Không** | Hệ thống tự gắn lại listener sau khi khởi động máy |
| `POST_NOTIFICATIONS`, `READ_SMS`, Accessibility | **Không** | Không cần |

**Đừng thêm lại** các quyền ở dòng "Không" khi gộp code: chúng là lý do phổ biến nhất khiến app bị từ chối.

### Trước khi build bản phát hành
- `android:usesCleartextTraffic="true"` trong `AndroidManifest.xml` chỉ để test với máy chủ HTTP nội bộ. **Bản đưa lên Play phải bỏ dòng này** và dùng `API_URL` HTTPS. Mục An toàn dữ liệu bên dưới khai "mã hóa khi truyền", nên phải đúng như vậy.
- Bản release: `flutter build appbundle --release --dart-define=API_URL=https://<máy-chủ>/api` (cần keystore ký app).

---

## 2. Thông báo trong app (prominent disclosure)

Chính sách Dữ liệu người dùng của Google Play yêu cầu: khi người dùng có thể không ngờ app đọc dữ liệu nhạy cảm, phải **hiện thông báo riêng trong app, trước khi xin quyền**, và người dùng phải **chủ động bấm đồng ý**.

Trong app: Cài đặt › Ghi từ thông báo ngân hàng › bật công tắc → `BankDisclosureSheet` hiện ra **trước** khi mở trang cấp quyền Android. Bấm "Không, cảm ơn" thì không có gì xảy ra.

Nội dung đang dùng (sửa trong `bank_disclosure_sheet.dart` thì sửa cả ở đây):

> **Cho phép Thu Chi đọc thông báo ngân hàng?**
> - Thu Chi đọc thông báo biến động số dư từ app ngân hàng và ví điện tử trên máy này để gợi ý ghi thu chi cho bạn.
> - Thông báo của app khác (tin nhắn, mạng xã hội, email…) bị bỏ qua ngay, không được lưu hay gửi đi.
> - Nội dung thông báo chỉ nằm trên máy. Chỉ khoản bạn bấm Xác nhận mới được lưu vào tài khoản Thu Chi của bạn: số tiền, danh mục, ví, thời gian và mô tả.
> - Tắt bất cứ lúc nào trong Cài đặt › Ghi từ thông báo ngân hàng, hoặc thu hồi quyền trong Cài đặt Android.
>
> [Đồng ý và tiếp tục] [Không, cảm ơn] · Xem chính sách quyền riêng tư

Các điều thông báo này cam kết đều có trong code thật:
- `BankNotificationListener.isFinancial`: chỉ giữ gói app ngân hàng / ví hoặc nội dung có dạng số tiền.
- Cờ `enabled` phía Android, mặc định tắt.
- Tắt tính năng hoặc đăng xuất thì xóa mọi dữ liệu chờ.
- Chỉ gửi giao dịch khi người dùng bấm Xác nhận (`POST /transactions`); không gửi nội dung thông báo gốc.

---

## 3. Mục An toàn dữ liệu (Play Console › App content › Data safety)

| Câu hỏi | Trả lời |
|---|---|
| App có thu thập hoặc chia sẻ dữ liệu người dùng không? | Có (thu thập) |
| Dữ liệu có được mã hóa khi truyền không? | Có (HTTPS, xem mục 1) |
| Người dùng có thể yêu cầu xóa dữ liệu không? | Có (Cài đặt › Xóa tài khoản xóa toàn bộ dữ liệu) |

Loại dữ liệu khai báo **thu thập**, không chia sẻ với bên thứ ba:

| Loại (theo Play) | Dữ liệu cụ thể | Mục đích | Bắt buộc? |
|---|---|---|---|
| Thông tin cá nhân › Tên, Địa chỉ email | Tài khoản Thu Chi | Chức năng app, quản lý tài khoản | Bắt buộc |
| Thông tin tài chính › Lịch sử mua hàng / Thông tin tài chính khác | Giao dịch thu chi người dùng ghi, kể cả khoản xác nhận từ thông báo ngân hàng | Chức năng app | Bắt buộc |
| Tin nhắn trong app › Tin nhắn khác (nếu bật Trợ lý AI) | Câu hỏi gửi trợ lý | Chức năng app | Không bắt buộc |

**Không** khai "đọc tin nhắn / SMS". Nội dung thông báo được **xử lý trên máy** và không rời khỏi thiết bị. Theo định nghĩa của Play, dữ liệu xử lý tạm thời trên máy và không truyền đi thì không tính là "thu thập". Chỉ giao dịch người dùng đã xác nhận mới được gửi đi, và đã khai ở dòng "Thông tin tài chính".

---

## 4. Chính sách quyền riêng tư: đoạn cần thêm

Link chính sách đặt ở Play Console và trong admin › Cấu hình › Chung › "Chính sách bảo mật" (app đọc qua `config/public` → `privacyUrl` và hiện trong màn thông báo). Thêm nguyên đoạn:

> **Ghi từ thông báo ngân hàng (chỉ Android, không bắt buộc).** Khi bạn bật tính năng này và cấp quyền Truy cập thông báo, ứng dụng Thu Chi đọc thông báo biến động số dư do ứng dụng ngân hàng và ví điện tử hiển thị trên thiết bị của bạn, để đề xuất các giao dịch thu chi. Thông báo của các ứng dụng khác bị bỏ qua và không được lưu. Nội dung thông báo chỉ được xử lý và lưu tạm trên thiết bị của bạn; Thu Chi không gửi nội dung thông báo lên máy chủ. Chỉ những giao dịch bạn chủ động xác nhận mới được lưu vào tài khoản Thu Chi của bạn, gồm số tiền, danh mục, ví, thời gian và mô tả. Chúng tôi không bán hay chia sẻ dữ liệu này với bên thứ ba. Bạn có thể tắt tính năng bất cứ lúc nào trong Cài đặt của ứng dụng (dữ liệu chờ trên thiết bị bị xóa ngay) hoặc thu hồi quyền trong Cài đặt Android, và có thể xóa toàn bộ dữ liệu bằng chức năng Xóa tài khoản.

---

## 5. Ghi chú cho người duyệt (Play Console › App access + phần ghi chú khi gửi duyệt)

Người duyệt cần vào được app và hiểu vì sao app xin quyền đọc thông báo. Điền:

- **Tài khoản thử:** `demo@thuchi.vn` / `demo123`. Dùng máy chủ thật, tạo riêng tài khoản cho người duyệt và không dùng dữ liệu thật của khách hàng.
- **Hướng dẫn ghi chú (dán nguyên văn):**

> Thu Chi is a personal finance app. The optional feature "Ghi từ thông báo ngân hàng" (Record from bank notifications) uses NotificationListenerService only to read balance-change notifications posted by Vietnamese banking and e-wallet apps, so the user does not have to type each transaction. Notifications from any other app are ignored immediately and never stored. Notification content stays on the device; a transaction is sent to the user's own Thu Chi account only after the user taps "Xác nhận" (Confirm) on it. Before the system permission screen is opened, an in-app disclosure explains this and requires the user to tap "Đồng ý và tiếp tục" (Agree and continue). The feature is off by default and can be turned off in Settings, which deletes all pending data. The app does not use foreground services, Accessibility, SMS permissions, or battery-optimization exemptions. To test: log in with the account above → Cài đặt (Settings) → Ghi từ thông báo ngân hàng → turn on → agree → enable notification access for Thu Chi → when a bank app posts a notification, it appears under "Chờ xác nhận" (Pending) for confirmation.

---

## 6. Mô tả trên cửa hàng

Nhắc tính năng đúng như cách nó chạy, không hứa "tự động ghi" (app không tự ghi):

- **Mô tả ngắn** (≤ 80 ký tự): `Ghi thu chi nhanh, ngân sách, tiết kiệm. Gợi ý giao dịch từ thông báo ngân hàng.`
- **Một dòng trong mô tả dài:** `Tùy chọn trên Android: Thu Chi gợi ý giao dịch từ thông báo biến động số dư của ngân hàng và ví điện tử; bạn xác nhận từng khoản trước khi lưu. Thông báo của ứng dụng khác bị bỏ qua.`

---

## 7. Video minh họa (khuyên làm)

Không bắt buộc (vì không dùng foreground service), nhưng nếu người duyệt hỏi lại thì nộp ngay được. Quay màn hình 30–60 giây:
1. Cài đặt → Ghi từ thông báo ngân hàng → bật → màn thông báo → Đồng ý.
2. Trang "Truy cập thông báo" của Android → bật Thu Chi.
3. Một app ngân hàng hiện thông báo → mở Thu Chi → Trang chủ hiện "1 giao dịch chờ xác nhận" → Xác nhận.
4. Tắt tính năng → danh sách chờ trống.

Tải lên YouTube để chế độ "Không công khai", dán link vào ghi chú duyệt.

---

## Nguồn

- [Google Play: Understanding foreground service and full-screen intent requirements](https://support.google.com/googleplay/android-developer/answer/13392821): khai báo mọi loại foreground service, kèm mô tả và video, cho app nhắm Android 14+.
- [Google Play: Prominent disclosure and consent (User Data policy)](https://support.google.com/googleplay/android-developer/answer/11150561): hiện thông báo trong app trước khi thu thập, cần người dùng chủ động đồng ý; không thay thế chính sách quyền riêng tư và mục An toàn dữ liệu.
- Android: [NotificationListenerService](https://developer.android.com/reference/android/service/notification/NotificationListenerService): người dùng phải cấp quyền Truy cập thông báo; hệ thống tự gắn service.
- Hạn chế với `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`: tài liệu Android ghi rằng chính sách Google Play cấm xin miễn Doze trừ khi chức năng cốt lõi bị ảnh hưởng. Danh sách trường hợp được phép xem trực tiếp trong Play Console khi khai báo, vì trang chính thức hay thay đổi.
