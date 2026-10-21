# Môi trường phát triển mobile

Cập nhật: 17/10/2026, Windows.

| Thành phần | Trạng thái |
|---|---|
| Flutter | 3.44.7 stable, Dart 3.12.2 |
| Android SDK | 36.1, build-tools 36.1.0 |
| Java dùng bởi Flutter | JBR 21.0.9 từ Android Studio |
| Android licenses | Đã chấp nhận toàn bộ |
| Emulator | AVD `Small_Phone` có sẵn; chưa chạy ở lần kiểm tra đầu |
| iOS | Mã nguồn được tạo; Windows không build/test iOS |
| API/DB | Cố định `https://tracker-xt.freepro.online/api` (máy chủ của nhóm, xem `API-URL.md` ở gốc repo) |

Chạy Android emulator:

```powershell
flutter emulators --launch Small_Phone
flutter run -d emulator-5554
```

Điện thoại thật, emulator, Windows hay Chrome đều dùng chung địa chỉ API cố định (HTTPS); không truyền `--dart-define=API_URL`.

Kiểm tra tĩnh và test:

```powershell
cd mobile/app
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build apk --debug
```

Visual Studio thiếu workload C++ không ảnh hưởng bản Android/iOS. Không nâng Flutter trong P0 vì bản stable hiện tại đáp ứng Dart 3 và dự án đã resolve dependency thành công.
