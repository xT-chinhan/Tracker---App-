# Tích hợp "Ghi từ thông báo ngân hàng" vào app TrackerX (Android)

> **Trạng thái (19/10/2026): đã tích hợp vào `mobile/app`.** Phần dưới là thiết kế ban đầu; code thật nằm ở:
> - Android: `android/app/src/main/kotlin/vn/thuchi/app/banknotif/` (`BankNotificationListener.kt`, `BankNotificationChannels.kt`), service khai báo trong `AndroidManifest.xml`.
> - Dart: `lib/features/bank_notifications/` (data: parser + model chép từ module, bridge, lưu trên máy; application: ánh xạ + controller; presentation: Cài đặt, thông báo dữ liệu, Chờ xác nhận). Lối vào: Cài đặt › Ghi từ thông báo ngân hàng, và thẻ trên Trang chủ khi có khoản chờ.
> - Test: `test/features/bank_notifications/` (ánh xạ, chống trùng, nhiều thông báo cùng lúc, admin tắt, đăng xuất, thông báo dữ liệu).
> - Khác thiết kế ban đầu: **bỏ hẳn foreground service, BootReceiver và quyền xin miễn tối ưu pin** (lý do ở `mobile/GOOGLE-PLAY.md` mục 1); ánh xạ ví dùng tên ngân hàng; xác nhận hàng loạt chỉ ghi các khoản đã đủ ví.
> - Đưa lên Google Play: `mobile/GOOGLE-PLAY.md`. Hướng dẫn người dùng cấp quyền: `mobile/docs/huong-dan-cap-quyen-thong-bao.md`.
> - Thử trên web không cần Android: build với `--dart-define=BANK_DEMO=true`, trong Cài đặt có nút "Thử với thông báo mẫu".

Việc mới **M11**, bổ sung cho bảng chia việc M1–M10 ở `mobile/README.md` mục 8. Làm **sau M1 (khung), M2 (config/public) và M4 (form ghi giao dịch)**. Nhánh: `mobile/M11-bank-notifications`, mở Pull Request vào `app-mobile`.

App đọc thông báo biến động số dư của app ngân hàng / ví trên máy (Vietcombank, MB, Techcombank, VPBank, ACB, TPBank, BIDV, MoMo, ZaloPay…). Từ đó app tạo **giao dịch chờ xác nhận**; người dùng bấm Xác nhận thì app mới ghi qua API.
- **Chỉ Android.** iOS không cho app đọc thông báo của app khác, nên trên iOS ẩn hẳn tính năng.
- **Không tự ghi.** Giống Trợ lý AI: mọi khoản đều là nháp, người dùng xác nhận / sửa / bỏ qua.
- **Backend không cần sửa.** Dùng các API có sẵn: `GET /config/public`, `GET /categories`, `GET /wallets`, `POST /transactions`, `POST /transactions/bulk`, `POST /transfers`.

---

## 1. Mã nguồn module

Module đã nằm trên `main` tại `mobile/modules/bank_notification_listener/` (đọc `TRACKER.md` trong đó). Đây là app Flutter độc lập, đã chạy tốt trên Android. Lấy về nhánh làm việc **mà không cần merge cả `main`**:

```bash
git fetch origin
git checkout origin/main -- mobile/modules/bank_notification_listener
```

Thư mục module chỉ để tham khảo và chạy thử (`flutter test`, `flutter run`). **Không import trực tiếp** từ `mobile/modules/...`; chép phần cần dùng sang `mobile/app/` như dưới đây, và **không sửa** thư mục module.

| Phần | File gốc trong module | Chép sang `mobile/app/` |
|---|---|---|
| Service Android | `android/app/src/main/kotlin/com/chinhan/xt_manager/NotificationMonitorService.kt`, `BootReceiver.kt` | `android/app/src/main/kotlin/vn/thuchi/app/banknotif/` (đổi `package`) |
| Kênh Flutter ↔ Android | khối `MethodChannel` / `EventChannel` trong `MainActivity.kt` | **thêm vào** `MainActivity.kt` của app (không ghi đè file) |
| Khai báo | `AndroidManifest.xml` (quyền, `<service>`, `<receiver>`) | gộp vào manifest của app |
| Dart | `lib/models/*.dart`, `lib/services/bank_notification_parser.dart`, `lib/services/notification_bridge.dart` | `lib/features/bank_notifications/` |
| Dữ liệu test | `lib/services/mock_bank_samples.dart` | chỉ dùng ở bản debug |
| Test | `test/services/bank_notification_parser_test.dart`, `test/models/*` | `test/features/bank_notifications/` |

Thêm `uuid` vào `pubspec.yaml` của app (`intl` đã có).

### Đổi tên khi chép (bắt buộc)
- Package Kotlin `com.chinhan.xt_manager` → `vn.thuchi.app.banknotif`. Lấy applicationId thật của app trong `android/app/build.gradle.kts`.
- Tên kênh `com.chinhan.xt_manager/methods` / `/events` → `vn.thuchi.app/bank_notifications/methods` / `/events`. Sửa ở **cả** Kotlin lẫn `notification_bridge.dart`.
- `android:label` của service → `TrackerX`.
- Chuỗi foreground, `PROPERTY_SPECIAL_USE_FGS_SUBTYPE` → nói rõ "TrackerX đọc thông báo ngân hàng để gợi ý ghi giao dịch".

### Sửa bắt buộc vì quyền riêng tư
Module gốc là bản thử nghiệm: nó **lưu mọi thông báo của mọi app** (tin nhắn, mạng xã hội…) vào SharedPreferences, tối đa 300 mục. Đồng thời service chạy 24/7, kể cả sau khi khởi động lại máy. Khi đưa vào TrackerX phải sửa trong `NotificationMonitorService.kt`:

1. **Chỉ giữ thông báo tài chính.** Trong `onNotificationPosted`, trước khi lưu hay gửi lên Flutter:
   - giữ nếu `packageName` thuộc danh sách app ngân hàng / ví (chép từ `_bankPackageNames` trong `bank_notification_parser.dart`);
   - hoặc nội dung có dạng số tiền (`[+-]? số … (VND|VNĐ|đ)`).
   Mọi thông báo khác bỏ qua: không lưu, không gửi.
2. **Cờ bật/tắt ở phía Android.** Lưu `enabled` trong SharedPreferences. Thêm method `setEnabled(bool)` vào MethodChannel.
   - `enabled = false` thì `onNotificationPosted` return ngay, `stopForeground` + `stopSelf`.
   - `BootReceiver` không khởi động service khi cờ đang tắt.
3. **Xóa bộ đệm** (`clearSavedNotifications`) khi: người dùng tắt tính năng, admin tắt tính năng, đăng xuất, xóa tài khoản.
4. **Không gửi `rawContent` lên server.** Chỉ dùng nó để hiển thị và kiểm tra trên máy.

---

## 2. Ba lớp công tắc

| Lớp | Ở đâu | Mặc định | Khi tắt |
|---|---|---|---|
| Quản trị | admin › Cấu hình › Nghiệp vụ › "Ghi từ thông báo ngân hàng". App đọc `GET /config/public` → `features.bankNotifications` | bật | App ẩn mọi lối vào, gọi `setEnabled(false)`, xóa bộ đệm. Báo một lần: "Tính năng đã tạm tắt; bạn có thể thu hồi quyền đọc thông báo trong Cài đặt Android" |
| Người dùng | Cài đặt › "Ghi từ thông báo ngân hàng", lưu trên máy | **tắt** | Như trên, trừ thông báo |
| Hệ thống | Quyền "Truy cập thông báo" của Android | chưa cấp | Dòng Cài đặt hiện "Chưa cấp quyền" + nút cấp quyền |

Tính năng chỉ chạy khi **cả ba** đều bật và `Platform.isAndroid`. Đọc lại `config/public` mỗi lần app quay lại foreground, giống quy tắc chung trong `mobile/README.md` mục 4.

---

## 3. Luồng xử lý

1. **Lấy thông báo.** Khi app mở / quay lại foreground: gọi `NotificationBridge.getSavedNotifications()` (thông báo đến lúc app đóng), rồi nghe tiếp `notificationStream`.
2. **Bóc tách.** `BankNotificationParser.parse(raw)` → `ParsedTransaction?`. Bỏ qua nếu `null`, `amount <= 0`, hoặc `confidence < 0.6`.
3. **Chống trùng.** Khóa = `packageName + amount + timestamp (làm tròn phút)`. Lưu các khóa đã xử lý (đã xác nhận hoặc đã bỏ qua) trong 30 ngày. Sau khi đưa vào danh sách chờ thì gọi `clearSavedNotifications()`.
4. **Ánh xạ sang dữ liệu TrackerX:**

| `ParsedTransaction` | TrackerX |
|---|---|
| `type`: `credit` / `debit` | danh mục loại `INCOME` / `EXPENSE` |
| `amount` | `amount` (số nguyên đồng) |
| `timestamp` (ms) | `occurredAt` (ISO, giờ VN) |
| `note` (rỗng thì `"Giao dịch " + title`) | `title`, tối đa 120 ký tự |
| `title` (tên ngân hàng / ví) | `walletId`: xem dòng "Ví" bên dưới |
| — | `note`: `"Từ thông báo " + title` |

**Danh mục.** Tra theo tên trong `GET /categories?type=`; không thấy thì lùi về Chi khác / Thu khác.

| Danh mục module | TrackerX (`debit`) | TrackerX (`credit`) |
|---|---|---|
| Ăn uống | Ăn uống | Thu khác |
| Mua sắm | Mua sắm | Thu khác |
| Di chuyển | Di chuyển | Thu khác |
| Hóa đơn & Tiện ích | Hóa đơn | Thu khác |
| Lương | Chi khác | Lương |
| Chuyển tiền | Chi khác | Thu khác |
| Khác | Chi khác | Thu khác |

**Ví.** Lần đầu gặp một ngân hàng / ví, hỏi người dùng chọn ví và nhớ lựa chọn trên máy. Gợi ý sẵn ví có tên khớp, không phân biệt hoa thường và bỏ khoảng trắng (MBBank ↔ "MB Bank", MoMo ↔ "MoMo"). Sửa được trong Cài đặt › Ghi từ thông báo ngân hàng.

**Chuyển tiền giữa ví của chính mình** (vd rút từ MB nạp MoMo sẽ sinh 2 thông báo): trên thẻ chờ, cho chọn "Ghi là chuyển tiền giữa ví" → `POST /transfers` `{fromWalletId, toWalletId, amount, occurredAt}`. Ẩn lựa chọn này khi `features.transfers = false`.

5. **Xác nhận.**
   - Một khoản: `POST /transactions` `{categoryId, walletId, amount, title, note, occurredAt}`.
   - "Xác nhận tất cả": `POST /transactions/bulk` `{items: [...]}` (1–100 khoản, tất cả hoặc không).
   - Xử lý lỗi theo bảng mục 4 của `mobile/README.md`. Riêng 400 do ví đã lưu trữ: hỏi lại người dùng chọn ví khác.

---

## 4. Giao diện cần mockup trước khi dựng

Theo quy tắc của dự án (`CLAUDE.md`), giao diện phải có mockup được duyệt trước khi code. Ba màn dưới đây **chưa có trong `design/mockup/`**; cần mockup cùng phong cách (`design/reference.png`, `design/tokens.md`) và được duyệt:

1. **Cài đặt › Ghi từ thông báo ngân hàng**: công tắc, trạng thái quyền, danh sách ngân hàng ↔ ví đã ghép, nút xóa dữ liệu chờ.
2. **Hướng dẫn cấp quyền**:
   - Bật "Truy cập thông báo" cho TrackerX.
   - Android 13+ với app không cài từ CH Play: mở "Cài đặt bị hạn chế" bằng dấu ⋮ trong thông tin ứng dụng (`openAppDetails`).
   - Tắt tối ưu pin (`requestIgnoreBatteryOptimizations`) và bật tự khởi chạy trên Xiaomi / Oppo / Vivo (`openAutostartSettings`).
   - Trước khi xin quyền, nói rõ app chỉ giữ thông báo ngân hàng / ví và không gửi nội dung thông báo lên máy chủ.
3. **Giao dịch chờ xác nhận**:
   - Mỗi khoản là một thẻ nháp (viền nét đứt, giống thẻ nháp Trợ lý AI ở `30-ai-04`): ngân hàng, số tiền, danh mục, ví, giờ, các nút Xác nhận / Sửa / Bỏ qua.
   - Có nút "Xác nhận tất cả".
   - Lối vào: chấm đếm số khoản chờ trên Trang chủ (cạnh chuông) và trong Lịch sử.

Trong lúc chờ mockup, làm trước phần không có giao diện: chép module, các sửa ở mục 1, ánh xạ ở mục 3, và test.

---

## 5. Kiểm thử

- Unit test: chép test parser của module, thêm test ánh xạ danh mục / ví và chống trùng.
- Bản debug có màn ẩn để bắn mẫu từ `MockBankSamples` qua `injectSimulatedNotification`, nên không cần chuyển tiền thật.
- Trên máy Android thật, kiểm tra:
  - [ ] Thông báo khi app đang mở, đang chạy nền, đã bị vuốt tắt, và sau khi khởi động lại máy.
  - [ ] Thông báo từ app không phải ngân hàng (Zalo, Messenger) **không** được lưu: đọc SharedPreferences bằng `adb shell run-as vn.thuchi.app`.
  - [ ] Tắt ở Cài đặt app hoặc ở admin → không lưu thêm, bộ đệm bị xóa, service dừng.
  - [ ] Cùng một thông báo không sinh 2 khoản chờ.
  - [ ] Xác nhận → giao dịch xuất hiện trong Lịch sử với đúng ví, danh mục, giờ.
  - [ ] iOS: không thấy lối vào nào.

---

## 6. Phối hợp trong nhóm

- Chỉ người nhận M11 sửa các file của tính năng này (`lib/features/bank_notifications/`, `android/.../banknotif/`).
- Điểm chạm vào file chung (`MainActivity.kt`, `AndroidManifest.xml`, `pubspec.yaml`, màn Cài đặt, Trang chủ) chỉ **thêm**, không sắp xếp lại hay định dạng lại code của người khác. Báo người đang giữ màn đó trước khi sửa.
- Không merge thẳng vào `app-mobile`: mở Pull Request, kèm ảnh chụp trên máy thật.
