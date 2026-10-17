# bank_notification_listener trong Thu Chi

- **Nguồn**: https://github.com/xT-chinhan/bank_notification_listener, commit `af7287a` (17/10/2026). Mã nguồn chép nguyên, **không sửa**.
- **Không chép**: `.git`, `build/`, bộ slide / ảnh thuyết trình (`images/`, `presentation.html`, `docs/presentation/`, thư mục `Notification_Listener_Nhom_Ngong_LN/` là bản trùng). Xem ở repo gốc nếu cần.
- **Vai trò**: app Flutter độc lập (Android) để thử module; app Thu Chi **không** phụ thuộc trực tiếp vào thư mục này mà chép phần cần dùng sang `mobile/app/` theo hướng dẫn tích hợp.
- **Hướng dẫn tích hợp vào app Thu Chi**: `mobile/BANK-NOTIFICATIONS.md` trên nhánh `app-mobile`.
- **Công tắc quản trị**: admin › Cấu hình › Nghiệp vụ › "Ghi từ thông báo ngân hàng" (`business.featureBankNotifications`). App đọc qua `GET /api/config/public` → `features.bankNotifications`.
- **Chỉ Android.** iOS không cho app đọc thông báo của app khác.

Chạy thử riêng module (cần Flutter SDK + máy Android):

```bash
cd mobile/modules/bank_notification_listener
flutter pub get
flutter test        # bộ test parser / model / giao diện
flutter run         # nút "Test giả lập" bắn thử mẫu thông báo VCB, MB, Techcombank, MoMo…
```
