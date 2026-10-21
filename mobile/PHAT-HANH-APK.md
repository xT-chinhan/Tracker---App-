# Phát hành APK TrackerX (không qua Google Play)

App trỏ cố định tới `https://tracker-xt.freepro.online/api` (xem `../API-URL.md`). Mỗi APK chứa đủ 3 kiến trúc CPU (`arm64-v8a`, `armeabi-v7a`, `x86_64`), chạy được trên **Android 7.0 (API 24) trở lên**, target API 36.

## Hai bản APK

| File | Có gì | Cài bằng cách nào |
|---|---|---|
| **`TrackerX.apk`** (bản thường) | Đủ mọi tính năng, **trừ** "Ghi từ thông báo ngân hàng" | Gửi qua Zalo / Drive / web, mở file là cài. **Dùng bản này cho người test** |
| **`TrackerX-full.apk`** (bản đầy đủ) | Thêm "Ghi từ thông báo ngân hàng" | Cài qua cáp USB: `adb install TrackerX-full.apk`. Cài từ file sẽ bị Play Protect chặn (xem dưới) |

Hai bản cùng mã gói `vn.thuchi.app`, cùng khóa ký → cài đè lên nhau được, dữ liệu giữ nguyên.

### Vì sao phải tách 2 bản

Google Play Protect đang chạy **"chống lừa đảo nâng cao"** ở Việt Nam. Khi APK được cài từ **trình duyệt, ứng dụng nhắn tin (Zalo…) hoặc trình quản lý tệp**, Play Protect **chặn cài** nếu app khai báo một trong các quyền hay bị kẻ gian lạm dụng:

- đọc / nhận SMS (`READ_SMS`, `RECEIVE_SMS`);
- **đọc thông báo** (`BIND_NOTIFICATION_LISTENER_SERVICE`);
- trợ năng (`BIND_ACCESSIBILITY_SERVICE`).

Việc chặn dựa vào **quyền khai báo**, không dựa vào câu chữ hay mô tả, nên viết lại lời giải thích không qua được. Tính năng "Ghi từ thông báo ngân hàng" cần quyền đọc thông báo → chỉ có ở bản đầy đủ. Bản thường gỡ hẳn dịch vụ này (`android/app/src/lite/AndroidManifest.xml`).

`SEND_SMS` (tự gửi tin xác thực số điện thoại) và `READ_PHONE_STATE` (liệt kê SIM) **không** thuộc nhóm bị chặn này, cả hai bản đều có.

Cài qua **USB (adb)** không thuộc diện kiểm tra trên.

### Đã làm để Android / Play Protect tin app hơn

- Ký bằng **khóa phát hành riêng** (không dùng khóa debug), cùng một khóa cho mọi bản sau → cập nhật đè được.
- Bản phát hành **không cho HTTP không mã hóa** (chỉ HTTPS), không bật chế độ gỡ lỗi.
- Target API 36 (mới nhất): Android 14+ chặn hẳn app target quá cũ.
- Màn **hỏi đồng ý rõ ràng** trước khi xin quyền: đọc thông báo (nói rõ đọc gì, bỏ qua gì, lưu ở đâu, tắt ở đâu) và gửi SMS (chỉ 1 tin chứa 6 số, khi bấm Gửi).
- Không xin các quyền không dùng (không đọc SMS, không danh bạ, không vị trí, không chạy cùng máy khởi động).

### Nếu Play Protect vẫn cảnh báo "ứng dụng không xác định"

Với bản thường, có thể hiện cảnh báo chung "Ứng dụng chưa được Play Protect quét". Bấm **Chi tiết khác › Vẫn cài đặt**. Cảnh báo này áp dụng cho mọi APK mới chưa phổ biến, không phải bị chặn.

## Sắp tới: xác minh nhà phát triển (Google)

Google bắt buộc **xác minh danh tính nhà phát triển** mới cho cài APK trên máy Android có chứng nhận. Từ 30/09/2026 áp dụng ở Brazil, Indonesia, Singapore, Thái Lan; **mở rộng toàn cầu năm 2027**. Việt Nam chưa có trong đợt đầu. Trước khi tới lượt Việt Nam: đăng ký tài khoản trên **Android Developer Console** và đăng ký mã gói `vn.thuchi.app` cùng chứng chỉ ký bên dưới.

## Khóa ký (QUAN TRỌNG)

- File khóa: `~/.trackerx-keys/trackerx-release.jks` và mật khẩu trong `~/.trackerx-keys/key.properties`, **trên laptop chủ dự án, KHÔNG nằm trong git**.
- Chứng chỉ SHA-256: `8a:04:82:4f:a6:0c:38:33:03:6c:d8:38:3a:a9:b0:fb:45:2f:8c:03:73:40:86:1d:81:0f:82:1f:3d:c7:06:1b`
- **Sao lưu thư mục `~/.trackerx-keys/` ra chỗ an toàn.** Mất khóa thì bản sau không cài đè được bản đang dùng (người dùng phải gỡ ra cài lại).
- Máy dev khác không có `key.properties` → bản release tự ký bằng khóa debug (chạy được, nhưng không cài đè lên bản chính thức).

## Build (trên laptop chủ dự án)

Máy này build Flutter trong Docker; `key.properties` trỏ `storeFile=/keys/trackerx-release.jks` (thư mục khóa mount vào `/keys`).

```bash
cd mobile/app
cp ~/.trackerx-keys/key.properties android/key.properties     # một lần (file bị git bỏ qua)
docker run --rm -e PUB_CACHE=/pub -v flutter-pub:/pub -v flutter-gradle:/root/.gradle \
  -v ~/.trackerx-keys:/keys -v "$PWD":/app -w /app ghcr.io/cirruslabs/flutter:stable bash -c '
    flutter pub get
    flutter build apk --release && cp build/app/outputs/flutter-apk/app-release.apk /keys/out/TrackerX-full.apk
    TRACKERX_LITE=1 flutter build apk --release --dart-define=BANK_NOTIFICATIONS=false \
      && cp build/app/outputs/flutter-apk/app-release.apk /keys/out/TrackerX.apk'
```

(Ảnh Docker có Dart 3.12.0 trong khi `pubspec.yaml` đòi `^3.12.2`: tạm hạ `sdk:` xuống `^3.12.0` lúc build rồi trả lại.)

Tăng `version:` trong `pubspec.yaml` (vd `1.0.1+2`) trước mỗi lần phát hành để máy nhận là bản mới.
