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

## M2 — Auth & Session Restore (17/10/2026)

| Kiểm tra | Kết quả |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | Đạt |
| `flutter analyze` | Đạt, 0 lỗi/cảnh báo |
| `flutter test` | Đạt, 13 test (Auth models, bootstrap service, version compare, navigation guard, money formatter) |
| Chạy trên AVD API 36 với mock API `node mobile/app/.dart_tool/mock_m2_api.mjs` | Đạt |
| Luồng kiểm tra public config, chặn bảo trì & bắt buộc cập nhật app | Đạt |
| Luồng đăng nhập bằng tài khoản và khôi phục phiên (`/api/me`) | Đạt |
| Luồng điều hướng guard Router theo trạng thái phiên | Đạt |

## M3 — Trang chủ và Thông báo (17/10/2026)

| Kiểm tra | Kết quả |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | Đạt |
| `flutter analyze` | Đạt, 0 lỗi/cảnh báo |
| `flutter test` | Đạt, 22 test (Bao gồm Home models, Notifications models, HomeScreen widget, NotificationsScreen widget, Auth, Formatter, Version compare) |
| Đọc số dư ví `/stats/balance`, tổng quan chi `/stats/summary` | Đạt (Freezed models, service, UI presentation) |
| Ngân sách `/budgets` và tiến độ cảnh báo/vượt ngưỡng | Đạt |
| Giao dịch gần đây `/transactions?limit=5` và mẫu nhập nhanh `/quick-templates` | Đạt |
| Danh sách thông báo `/notifications`, số chưa đọc `/notifications/unread-count`, đọc hết `/notifications/read-all` | Đạt |
| Ẩn/hiện số dư cục bộ không đổi dữ liệu gốc | Đạt |
| Xử lý timezone Việt Nam độc lập locale | Đạt |

## M4 — Ghi giao dịch, Danh mục, Mẫu nhanh & Chuyển tiền (17/10/2026)

| Kiểm tra | Kết quả |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | Đạt |
| `flutter analyze` | Đạt, 0 lỗi/cảnh báo |
| `flutter test` | Đạt, 28 test (Bao gồm TransactionEntryScreen, CategoryPickerSheet, TransferScreen, Home, Notifications, Auth, Formatter) |
| Đọc và tạo danh mục `/categories` (loại EXPENSE, INCOME) | Đạt (Freezed models, sheet UI, 4-cột tròn, chọn & thêm mới) |
| Đọc danh sách ví `/wallets` cho giao dịch và chuyển tiền | Đạt (Freezed models, sheet chọn ví kèm số dư) |
| Bàn phím số numeric keypad `05-ghi-giao-dich.png` | Đạt (nhập số tiền, đọc thành chữ tiếng Việt, tự động định dạng) |
| Tạo giao dịch `/transactions` (chi/thu) | Đạt (validation, lưu khoản chi/thu nhập, refresh home) |
| Menu nút cộng nổi `05b-menu-nut-cong.png` | Đạt (Thu nhập, Chuyển tiền, Mẫu nhập nhanh, xoay `+` thành `×`) |

## M5 — Lịch sử, Chi tiết giao dịch, Sửa / Xóa (17/10/2026)

| Kiểm tra | Kết quả |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | Đạt |
| `flutter analyze` | Đạt, 0 lỗi/cảnh báo |
| `flutter test` | Đạt, 34 test (Bao gồm HistoryScreen, HistoryService, TransactionDetailScreen, TransactionEntryScreen, CategoryPickerSheet, TransferScreen, Home, Notifications, Auth, Formatter) |
| Màn hình lịch sử `07-lich-su.png` | Đạt (điều hướng tháng `< Tháng 9 >`, tổng quan tháng chi/thu, ô tìm kiếm debounce, bộ lọc Tất cả / Khoản chi / Thu nhập) |
| Sheet lọc nâng cao `HistoryFilterSheet` | Đạt (lọc theo ví và danh mục thực tế từ API, đặt lại, áp dụng) |
| Nhóm giao dịch theo ngày | Đạt (nhóm calendar date VN, nhãn Hôm nay / Hôm qua / 2 ngày trước, tổng net ngày tự động định dạng và màu xanh khi dương) |
| Trạng thái lịch sử trống `22-lich-su-trong.png` | Đạt (icon hoá đơn, tiêu đề "Chưa có giao dịch nào", nút "+ Ghi giao dịch đầu tiên") |
| Chi tiết giao dịch `08-chi-tiet-giao-dich.png` | Đạt (icon tròn, số tiền lớn, nhãn định kỳ nếu có, loại, danh mục, ví, thời gian chuẩn VN, ghi chú) |
| Xóa giao dịch `DELETE /transactions/:id` | Đạt (hộp thoại xác nhận, hoàn tác cập nhật số dư ví, tự động refresh lịch sử & trang chủ) |
| Sửa giao dịch `PATCH /transactions/:id` | Đạt (tái sử dụng form ghi giao dịch với dữ liệu prefill, cập nhật và refresh) |

