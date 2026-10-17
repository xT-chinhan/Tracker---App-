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

## M6 — Báo cáo, Xu hướng & Xuất CSV (17/10/2026)

| Kiểm tra | Kết quả |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | Đạt |
| `flutter analyze` | Đạt, 0 lỗi/cảnh báo |
| `flutter test` | Đạt, 37 test (Bao gồm ReportsScreen, DonutChart, MonthlyBarChart, TrendBadge, ReportsService, ReportsModels, CSV Export) |
| Báo cáo tháng `09-bao-cao.png` | Đạt (Thanh chuyển tháng `< Tháng 9 >`, card Chênh lệch thu chi `+14.820.000đ` với 2 cột Thu nhập `23.500.000đ` và Chi tiêu `8.680.000đ`, card Chi theo danh mục với DonutChart 132x132, tổng chi, danh mục lớn nhất, danh sách từng nhóm kèm % và số tiền) |
| Xu hướng & So sánh `10-bao-cao-xu-huong.png` | Đạt (Biểu đồ cột thu chi 6 tháng với 2 cột xanh/đen mỗi tháng và nhãn T4-T9, Card So sánh tháng trước với badge tỷ lệ % tăng/giảm đổi màu xanh/đỏ chuẩn token, Card Dự báo cuối tháng và tháng tiếp theo) |
| Xuất CSV `GET /export/transactions.csv` | Đạt (Kiểm tra cờ `features.csvExport`, nút tải xuống trong appbar, hộp thoại thông báo thành công và sao chép nội dung CSV vào clipboard) |

## M7 — Ngân sách & Tiết kiệm (17/10/2026)

| Kiểm tra | Kết quả |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | Đạt |
| `flutter analyze` | Đạt, 0 lỗi/cảnh báo |
| `flutter test` | Đạt, 44 test (Bao gồm BudgetsScreen, BudgetFormSheet, SavingsScreen, SavingDetailScreen, DepositSheet, SavingFormSheet, ReportsScreen, HistoryScreen, Home, Notifications, Auth, Formatter) |
| Ngân sách `11-ngan-sach.png` | Đạt (Thanh chuyển tháng `< Tháng 9 >`, card Ngân sách tổng với số tiền còn lại lớn `32px`, nhãn ngày còn lại trong tháng, thanh tiến độ dày `8px` đổi màu theo ngưỡng 80% cảnh báo và 100% vượt hạn mức, nhãn gợi ý chi tiêu hàng ngày "Mỗi ngày còn chi được ... để không vượt", card danh sách ngân sách theo danh mục với icon tròn, tên, số tiền đã chi / hạn mức, badge cảnh báo vàng cam hoặc vượt hạn mức đỏ) |
| Thao tác Ngân sách | Đạt (Sheet tạo/sửa ngân sách tổng hoặc theo danh mục, chọn danh mục chi tiêu khả dụng, xóa ngân sách có xác nhận, sao chép nhanh ngân sách từ tháng trước) |
| Tiết kiệm `12-tiet-kiem.png` | Đạt (Card Tổng đã tiết kiệm trên tổng mục tiêu, danh sách thẻ mục tiêu với icon tròn, tên, ngày hạn và số ngày còn lại, thanh tiến độ % hoàn thành, số tiền đã tích lũy / mục tiêu, empty state) |
| Chi tiết mục tiêu `13-chi-tiet-muc-tieu.png` | Đạt (Header căn giữa với icon tròn 56px, tên mục tiêu, số tiền đã tiết kiệm lớn 40px, ngày hạn, card tiến độ chi tiết tính số tiền cần nạp trung bình mỗi tháng để kịp hạn, 2 nút hành động `+ Nạp tiền` và `Rút tiền`, card danh sách lịch sử nạp/rút từ ví) |
| Nạp tiền mục tiêu `14-nap-tien-muc-tieu.png` | Đạt (BottomSheet nạp tiền, ô nhập số tiền lớn kèm suffix `đ`, 3 chip số tiền nhanh `500k`, `1M`, số tiền còn lại, danh sách chọn ví trích tiền hiển thị số dư hiện tại và xem trước số dư sau khi nạp `balance → newBalance`, validation không cho nạp vượt số dư ví) |
| Rút tiền mục tiêu | Đạt (Hộp thoại xác nhận rút toàn bộ số tiền tiết kiệm về ví đã chọn, hoàn trả số dư ví và cập nhật lại tiến độ mục tiêu) |

## M8 — Ví & Giao dịch định kỳ (17/10/2026)

| Kiểm tra | Kết quả |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | Đạt |
| `flutter analyze` | Đạt, 0 lỗi/cảnh báo |
| `flutter test` | Đạt, 50 test (Bao gồm WalletsScreen, WalletFormSheet, RecurringScreen, RecurringFormSheet, BudgetsScreen, SavingsScreen, ReportsScreen, HistoryScreen, Home, Notifications, Auth, Formatter) |
| Màn hình Ví `15-vi.png` | Đạt (Tổng số dư 4 ví, thông điệp phân bổ '% nằm ở...', thanh phân bổ tài sản dạng phân đoạn màu, danh sách từng ví với icon/loại, nút 'Chuyển tiền giữa ví', lịch sử các giao dịch chuyển tiền gần đây giữa các ví) |
| Thao tác Ví (Tạo / Sửa / Lưu trữ / Khôi phục) | Đạt (Sheet tạo/sửa ví, chọn loại BANK / CASH / EWALLET, số dư ban đầu, hỗ trợ lưu trữ ví và khôi phục ví đã lưu trữ) |
| Màn hình Giao dịch định kỳ `17-dinh-ky.png` | Đạt (Tiêu đề, phân tách nhóm Quy tắc đang chạy và Tạm dừng, card quy tắc với icon tròn, tên quy tắc, danh mục, ví, tần suất 'Hàng tháng vào ngày 1', số tiền màu xanh/đen theo loại, badge trạng thái 'Đang chạy'/'Tạm dừng', menu hành động Tạm dừng/Tiếp tục/Sửa/Xóa quy tắc) |
## M9 — Cài đặt & Tài khoản (17/10/2026)

| Kiểm tra | Kết quả |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | Đạt |
| `flutter analyze` | Đạt, 0 lỗi/cảnh báo |
| `flutter test` | Đạt, 55 test (Bao gồm SettingsScreen, EditProfileSheet, ChangePasswordSheet, DeleteAccountSheet, LogoutSheet, Wallets, Recurring, Budgets, Savings, Reports, History, Home, Notifications, Auth, Formatter) |
| Màn hình Cài đặt `20-cai-dat.png` & `20b-cai-dat-cuoi.png` | Đạt (Thẻ profile người dùng với avatar viết tắt chữ cái initials, tên, email, nút 'Sửa >'; Nhóm Quản lý tiền với số dư ví động, % ngân sách đã dùng, số mục tiêu tiết kiệm, số quy tắc định kỳ; Nhóm Nhập liệu với số danh mục, số mẫu nhập nhanh; Nhóm Ứng dụng với badge thông báo chưa đọc, Xuất CSV, Đổi mật khẩu; Card Đăng xuất độc lập, Nút đỏ Xóa tài khoản, Phiên bản ứng dụng `Thu Chi · phiên bản 1.0.0 (42)`, liên kết Hỗ trợ / Điều khoản / Quyền riêng tư theo cấu hình) |
| Chỉnh sửa thông tin cá nhân `EditProfileSheet` | Đạt (Prefill tên hiện tại, email chỉ đọc, xác thực tên không trống, gọi API `PATCH /auth/profile`, cập nhật `AppSessionController` tức thì) |
| Đổi mật khẩu `ChangePasswordSheet` | Đạt (Nhập mật khẩu hiện tại, mật khẩu mới kiểm tra độ dài theo config `password.minLength`, xác nhận mật khẩu mới, gọi API `POST /auth/change-password`, cập nhật token mới vào store) |
| Đăng xuất thiết bị & mọi thiết bị `LogoutSheet` | Đạt (BottomSheet lựa chọn 'Đăng xuất thiết bị này' hoặc 'Đăng xuất mọi thiết bị' qua API `POST /auth/logout-all`, xóa token cục bộ và chuyển hướng về màn hình đăng nhập) |
| Xóa tài khoản `21-xoa-tai-khoan.png` (`DeleteAccountSheet`) | Đạt (Icon thùng rác đỏ nền `#FDE8E8`, cảnh báo mất toàn bộ dữ liệu giao dịch/ví/mục tiêu tiết kiệm, card gợi ý 'Muốn giữ lại dữ liệu? Xuất CSV', nhập mật khẩu xác nhận, nút đỏ 'Xóa vĩnh viễn' gọi API `DELETE /auth/account`, nút 'Hủy') |

## M10 — Trợ lý AI (17/10/2026)

| Kiểm tra | Kết quả |
|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | Đạt |
| `flutter analyze` | Đạt, 0 lỗi/cảnh báo |
| `flutter test` | Đạt, 60 test (Bao gồm AiConversationsScreen, ConversationActionSheet, AiChatScreen, TransactionDraftCard, DraftItemEditSheet, UndoToast, RerouteMenuCard, AiSettingsScreen, Settings, Wallets, Recurring, Budgets, Savings, Reports, History, Home, Notifications, Auth, Formatter) |
| Màn hình danh sách hội thoại `30-ai-01a` & `30-ai-01b` | Đạt (Thanh điều hướng tiêu đề Trợ lý AI, nút Cài đặt trợ lý, ô tìm kiếm cuộc trò chuyện, nhóm Ghim / Hôm nay / Tuần này / Trước đó, badge số tin nhắn, menu dấu 3 chấm hành động, nút nổi 'Cuộc trò chuyện mới' kèm icon Sparkles, empty state cuộc hội thoại và trạng thái bảo trì/vô hiệu hóa `30-ai-12b`) |
| Thao tác hội thoại `30-ai-01c` (`ConversationActionSheet`) | Đạt (Đổi tên cuộc trò chuyện với dialog prefill, ghim / bỏ ghim, lưu trữ / bỏ lưu trữ, xóa hội thoại có dialog cảnh báo) |
| Màn hình Chat rỗng & Hero khởi đầu `30-ai-02` | Đạt (Greeting "Chào bạn, hôm nay có khoản chi nào cần ghi không?", 4 gợi ý nhanh có icon: Ghi nhiều khoản, Hỏi ngân sách, Báo cáo tuần, Mẹo tiết kiệm; ô nhập tin nhắn lớn kèm nút gửi) |
| Streaming phản hồi & Reading skeleton `30-ai-03` | Đạt (Server-Sent Events streaming SSE `user`, `route`, `delta`, `done`, `error`; hiển thị skeleton đang xử lý kèm tên skill định tuyến, hiển thị text dồn thời gian thực) |
| Thẻ Draft giao dịch & Sửa từng khoản `30-ai-04` & `30-ai-05` | Đạt (Card viền nét đứt dashed border, badge Trợ lý đề xuất + Chưa lưu, danh sách từng khoản với danh mục, số tiền, ngày, ví; nút Sửa mở `DraftItemEditSheet` sửa số tiền, tên, danh mục, ví, ngày hoặc Xóa khỏi nháp; nút 'Lưu X khoản chi' và nút 'Hủy') |
| Xác nhận lưu & Hoàn tác giao dịch `30-ai-06` | Đạt (Cập nhật trạng thái draft thành ĐÃ LƯU, hiển thị banner nổi `UndoToast` "Đã lưu X khoản chi - Chạm để hoàn tác giao dịch vừa lưu", nút 'Hoàn tác' rollback xóa các giao dịch vừa tạo) |
| Đánh giá phản hồi & Đổi hướng kỹ năng `30-ai-08` | Đạt (Nút Thumbs up / Thumbs down; khi thumbs down mở card 'Ý tôi là...' liệt kê các skill khác: Ghi chi tiêu, Hỏi ngân sách, Tra cứu lịch sử, Đổi ví... gọi API reroute) |
| Hạn mức & Bảo trì `30-ai-11` & `30-ai-12a` | Đạt (Card cảnh báo vượt hạn mức ngày 30/30 tin kèm thời gian làm mới `resetAt`, banner vàng cảnh báo chế độ bảo trì tạm thời 503) |
| Màn hình Cài đặt trợ lý AI `30-ai-14` (`AiSettingsScreen`) | Đạt (Card hạn mức hôm nay với thanh tiến độ xanh/vàng/đỏ, số tin đã dùng / tổng hạn mức; danh sách 'Điều trợ lý đã học' với icon Sparkles và nút xóa bộ nhớ; toggle 'Đóng góp ví dụ ẩn danh'; liên kết đến màn hình Cuộc trò chuyện đã lưu trữ) |

