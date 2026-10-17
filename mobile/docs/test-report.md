# Báo cáo kiểm tra mobile

## M1 — Foundation (17/10/2026)

| Kiểm tra | Kết quả |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | Đạt |
| `flutter analyze` | Đạt, 0 lỗi/cảnh báo |
| `flutter test` | Đạt, 6 test |
| Debug APK với `API_URL=http://10.0.2.2:3000/api` | Đạt |
| Cài APK trên AVD Android API 36 | Đạt |
| Khởi động app `vn.thuchi.app` | Đạt |
| Tab bar 4 đích + nút ＋ giữa | Đạt qua runtime/UI hierarchy |
| Tap ＋ → Ghi giao dịch | Đạt |
| Keypad `5` + `000` → `5.000đ`, “năm nghìn đồng” | Đạt |

APK debug: `mobile/app/build/app/outputs/flutter-apk/app-debug.apk` (build artifact, không đưa vào Git).

Ảnh bằng chứng:

- `mobile/docs/screenshots/m1-home.png`
- `mobile/docs/screenshots/m1-transaction-entry.png`

Ghi chú môi trường: AVD cũ dùng Android 17 preview bị ADB offline. Tạo AVD `ThuChi_API36` từ system image đã cài, boot với 1 GB RAM/GPU host và xác thực ADB; ứng dụng chạy thành công. iOS chưa thể build trên Windows.
