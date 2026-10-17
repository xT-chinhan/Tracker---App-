# Kế hoạch thực thi app mobile Thu Chi

Ngày lập: 17/10/2026. Nhánh nền: `app-mobile`, commit `fc2e0a3`.

**Trạng thái: đã được xác nhận và bắt đầu thực thi ngày 17/10/2026.**

Người dùng đã xác nhận bộ mockup hiện có được duyệt, bao gồm phần AI. Không có bước duyệt lại mockup trong kế hoạch. Các form và trạng thái phụ thuộc phạm vi hiện tại kế thừa bố cục, component và token đã duyệt; chỉ trao đổi riêng nếu phát sinh thay đổi sản phẩm ngoài phạm vi.

## 1. Kết quả cần bàn giao

Xây dựng ứng dụng Flutter Android/iOS trong `mobile/app/`, bám sát thiết kế Thu Chi đã duyệt, sử dụng API thật của dự án và hoàn thành các gói M1–M10 trong `mobile/README.md`.

Các sản phẩm bàn giao:

- Mã nguồn Flutter theo tính năng, cấu hình môi trường và hướng dẫn chạy.
- Bộ theme và widget dùng chung tương ứng design token.
- Các luồng xác thực, ghi chép thu chi, quản lý tiền, báo cáo, cài đặt và trợ lý AI.
- Bản Android cài thử; kết quả kiểm thử Android emulator và thiết bị thật nếu có.
- Cấu hình iOS trong mã nguồn; kết quả build/test iOS khi có macOS + Xcode. Không coi iOS đã đạt chỉ vì Android chạy được.
- Ảnh đối chiếu các màn với mockup, danh sách kiểm thử, giới hạn còn tồn tại.
- Các nhánh thay đổi theo gói việc để review và đưa vào `app-mobile` theo quy trình dự án.

Đích của kế hoạch là ứng dụng hoạt động đầy đủ trong phạm vi bên dưới. Phát hành Play Store/App Store, ký bằng tài khoản thật và đưa lên production là bước riêng.

## 2. Hiện trạng đã kiểm tra

| Hạng mục | Bằng chứng/hiện trạng | Ý nghĩa với kế hoạch |
|---|---|---|
| Git | Đang ở `app-mobile`, theo dõi `origin/app-mobile`; sạch trước khi tạo tài liệu này | Dùng làm nền, tạo nhánh con khi bắt đầu code |
| Mobile | `mobile/` có `README.md`, `openapi.json`; chưa có `app/` | Khởi tạo Flutter từ M1 |
| Yêu cầu | `mobile/README.md` quy định stack, màn/API, lỗi, DoD, M1–M10 | Là tài liệu phạm vi chính |
| Thiết kế cơ bản | 25 ảnh màn/trạng thái `01…23`, gồm `05b`, `20b` | Dựng theo ảnh và HTML/CSS hiện có |
| Thiết kế AI | `docs/AI-DECISIONS.md` ngày 14/10 và commit `5d1da31` xác nhận duyệt | README mockup ghi “chờ duyệt” đã lỗi thời; dùng quyết định đã duyệt |
| Flutter/Dart | Có lệnh trong PATH tại `C:\flutter\bin` | Chưa kiểm chứng phiên bản, doctor, khả năng build |
| Android | Java 17 có trong PATH; chưa tìm thấy `adb` qua PATH | Kiểm tra Android SDK/emulator ở bước chuẩn bị; chưa kết luận chưa cài |
| Backend local | Chưa kiểm tra dịch vụ; không thấy lệnh Docker qua PATH | Cần xác định API sẵn có hoặc cấu hình môi trường phát triển |
| OpenAPI | Nhiều response chỉ có `description`, thiếu schema dữ liệu | Không trông chờ sinh client sẽ tạo model đầy đủ |
| AI SSE | Controller đợi `answer()` xong rồi phát các `delta` của nội dung | Không cam kết số liệu hiện sau 0,3 giây hoặc token từ model chạy trực tiếp |

Nguồn tra cứu: `mobile/README.md`, `design/DESIGN.md`, `design/tokens.md`, `design/mockup/index.html`, `design/mockup/styles.css`, `design/mockup/shots/`, `backend/README.md`, mã nguồn `backend/src/`, `docs/AI-DECISIONS.md`.

Không sử dụng bản Flutter/Firestore cũ làm nguồn triển khai.

## 3. Phạm vi và nguyên tắc chốt khi duyệt kế hoạch

### 3.1. Trong phạm vi

1. Khung ứng dụng, thiết kế chung, cấu hình công khai, điều hướng.
2. Đăng nhập, đăng ký, quên/đặt lại mật khẩu, quản lý phiên.
3. Trang chủ và thông báo trong ứng dụng.
4. Tạo/sửa/xóa thu chi; chọn danh mục/ví; mẫu nhập nhanh; chuyển tiền.
5. Lịch sử, tìm kiếm, lọc, phân trang, chi tiết.
6. Báo cáo tháng, cơ cấu, xu hướng, xuất CSV.
7. Ngân sách tổng/theo danh mục và mục tiêu tiết kiệm.
8. Ví và quy tắc giao dịch định kỳ.
9. Hồ sơ, mật khẩu, hỗ trợ/pháp lý, đăng xuất, xóa tài khoản.
10. Trợ lý AI theo mockup đã duyệt: hội thoại, nháp, xác nhận, phản hồi, trí nhớ và đồng ý góp ví dụ.
11. Hoàn thiện các form/trạng thái phụ cần thiết bằng component và quy tắc từ bộ mockup đã duyệt, bảo đảm các hành trình trong phạm vi hoạt động đầy đủ.

### 3.2. Ngoài phạm vi đợt này

- QR thanh toán, deeplink ngân hàng.
- Push FCM, vay/nợ.
- Giọng nói thành chữ: theo mục 7 của yêu cầu mobile mới hơn, để bản sau dù quyết định AI cũ có nhắc làm cùng mobile.
- Đồng bộ ghi giao dịch offline, hàng đợi tự gửi lại, đăng nhập sinh trắc học.
- Dark mode, đa ngôn ngữ ngoài tiếng Việt, giao diện tablet riêng.
- Tính năng quản trị trong app người dùng.
- Tự thay đổi luật backend, cơ sở dữ liệu hoặc AI model để khớp giao diện.

### 3.3. Các quy tắc xuyên suốt

- Dữ liệu tài chính, số dư, trạng thái mục tiêu, phần trăm và trạng thái ngân sách do API quyết định.
- Số tiền là số nguyên VND; không lưu tiền dưới dạng số thực.
- Hiển thị và chọn ngày theo giờ Việt Nam, không lệ thuộc timezone điện thoại.
- Mọi màn dữ liệu có loading, data, empty, error phù hợp; lỗi có đường thử lại.
- Ghi dữ liệu phải có trạng thái đang gửi, chặn bấm lặp và xử lý kết quả không rõ khi mất mạng.
- Không tự gửi lại thao tác ghi chỉ vì timeout; có thể server đã lưu thành công.
- Không hard-code dữ liệu demo trong ứng dụng. Fixture chỉ dành cho test/golden.
- Xử lý lỗi theo mã nghiệp vụ; không coi mọi 403 là hết phiên.
- Thao tác nguy hiểm dùng xác nhận theo thiết kế; AI chỉ ghi khi người dùng xác nhận nháp.
- Các tác vụ nặng chạy tuần tự; tối đa một emulator/headless browser khi kiểm tra giao diện trên máy này.

## 4. Cách tổ chức mã nguồn và quyết định kỹ thuật

### 4.1. Stack

| Phần | Lựa chọn |
|---|---|
| UI/runtime | Flutter stable, Dart 3; xác minh phiên bản đang cài trước khi chốt |
| State | Riverpod |
| Routing | go_router, điều hướng theo phiên và cấu hình hệ thống |
| HTTP | Dio, interceptor token/lỗi, hủy request khi phù hợp |
| Model | Freezed + json_serializable, viết model dựa trên DTO/service/response thực tế |
| Token | flutter_secure_storage |
| Chart | fl_chart, dùng đúng bảng màu và nhãn từ thiết kế |
| Font | Be Vietnam Pro nhúng asset để hiển thị ổn định khi không có mạng |
| Ngày/số | intl + helper timezone Việt Nam có test |
| Tích hợp hệ điều hành | Chọn package mở URL, metadata phiên bản, chia sẻ/lưu file phù hợp sau khi kiểm tra tương thích SDK |

Lý do chọn model viết tay: OpenAPI hiện chưa mô tả đầy đủ response. Vẫn dùng OpenAPI làm danh sách route/request, nhưng không để `dynamic` lan tới UI. Chỉ chọn một cách tạo model cho toàn ứng dụng.

Khi triển khai, kiểm tra tài liệu chính thức và tương thích dependency, khóa phiên bản bằng lockfile. Không nâng Flutter đang cài một cách mặc định nếu bản đó đáp ứng dự án.

### 4.2. Cấu trúc dự kiến

```text
mobile/
  README.md
  IMPLEMENTATION-PLAN.md
  openapi.json
  docs/
    api-contracts.md
    screen-matrix.md
    test-report.md
    known-limitations.md
  app/
    lib/
      main.dart
      app/                 # bootstrap, router, root app
      core/
        config/
        network/
        storage/
        theme/
        formatting/
        widgets/
      features/
        auth/
        home/
        transactions/
        categories/
        wallets/
        transfers/
        quick_templates/
        reports/
        budgets/
        saving_goals/
        recurring/
        notifications/
        settings/
        assistant/
    assets/fonts/
    test/
    integration_test/
    android/
    ios/
```

Mỗi tính năng có `data/` cho model/repository và `presentation/` cho màn, widget, controller. Chỉ thêm lớp domain khi có logic phía client cần tái sử dụng; không sao chép luật tính tiền của backend.

### 4.3. Hợp đồng dữ liệu

- Tạo bảng endpoint → request → response → lỗi → màn tiêu thụ.
- Kiểm tra nullable, enum, timestamp, ID và response phân trang.
- Đối chiếu `mobile/openapi.json` với controller/DTO/service và response của API dev.
- Tách base URL kết thúc `/api` khỏi path tương đối để không sinh `/api/api/...`.
- API URL truyền qua `--dart-define`; không gắn IP cá nhân vào code.
- Dùng model dùng chung cho pagination, lỗi API, public config và session.
- Có fixture đã loại dữ liệu nhạy cảm để kiểm tra parse/serialize và null handling.

### 4.4. Vòng đời dữ liệu

- Provider dữ liệu có khóa theo user, tháng, bộ lọc và ID phù hợp.
- Sau mutation thành công: vô hiệu cache liên quan và đọc lại API.
- Đổi tháng/tìm kiếm nhanh: response cũ không được ghi đè lựa chọn mới.
- Đăng xuất: xóa token, hủy request đang chạy, xóa state/cache gắn với user.
- Đăng nhập tài khoản khác không nhìn thấy dữ liệu tài khoản trước dù chỉ thoáng qua.
- Khi trở lại foreground: đọc lại public config, làm mới dữ liệu có khả năng thay đổi.
- Với config khi app luôn foreground: kiểm tra theo chu kỳ có giới hạn, đề xuất 60 giây; dừng timer khi background, gộp các request trùng.
- Mất mạng: giữ nội dung đã tải trong phiên nếu có, thể hiện dữ liệu chưa được làm mới; không nhận ghi offline.

## 5. Bước P0 — kiểm tra môi trường, hợp đồng và ánh xạ thiết kế

### P0.1. Môi trường

- Kiểm tra `flutter --version`, `dart --version`, `flutter doctor -v`, thiết bị hiện có.
- Kiểm tra Android SDK, command-line tools, licenses, emulator, dung lượng và JDK phù hợp với toolchain thực tế.
- Xác định API dev đang chạy ở đâu, PostgreSQL/Docker hoặc server được cung cấp.
- Kiểm tra read-only `/api/health`, `/api/config/public`; đăng nhập tài khoản demo khi có API.
- Nếu cần setup/seed, xác nhận target là DB phát triển riêng; script setup có thể nạp lại tài khoản demo nên không chạy mù trên DB dùng chung.
- Ghi nhận hạn chế iOS do môi trường Windows.
- Đầu ra: checklist môi trường và lệnh chạy chính xác cho máy hiện tại.

### P0.2. Ma trận thiết kế

Với từng màn lập: mã màn, ảnh nguồn, điểm vào, điểm ra, API, quyền/cờ tính năng, trạng thái, keyboard, xác nhận nguy hiểm, tiêu chí nghiệm thu.

Các giao diện cần rà soát để ánh xạ vào component/luồng đã duyệt:

| Nhóm | Nội dung cần xác định |
|---|---|
| Khởi động | Bảo trì toàn app, bắt cập nhật, gợi ý cập nhật, lỗi tải cấu hình |
| Auth | Đăng ký, nhập mật khẩu mới sau OTP, các lỗi và cooldown |
| Thu chi | Ô tiêu đề bắt buộc trong API so với dòng “Ghi chú” của mockup, chọn ví/ngày, chỉnh sửa, xác nhận xóa |
| Danh mục | Quản lý danh mục riêng: danh sách, thêm, sửa, lưu trữ/xóa; phân biệt danh mục hệ thống |
| Mẫu nhập nhanh | Quản lý mẫu, tạo mẫu từ form, sửa/xóa, xác nhận khi thao tác tạo giao dịch thật |
| Ví | Tạo/sửa, lưu trữ/xóa, khôi phục |
| Ngân sách | Tạo/sửa/xóa, sao chép tháng |
| Tiết kiệm | Tạo/sửa mục tiêu, rút, xóa |
| Hồ sơ | Đổi tên/mật khẩu, xác nhận đăng xuất mọi nơi |
| AI | Đồng ý góp ví dụ lần đầu, hết số hội thoại khi tất cả đã ghim, lỗi/timeout và trường hợp hoàn tác một phần |

Mục tiêu bước này là không để các mục trong Cài đặt trở thành nút không hoạt động. Bộ mockup hiện có là chuẩn triển khai đã được người dùng duyệt. Các form/trạng thái phụ sử dụng cùng component, token và quy tắc tương tác; ghi lại ánh xạ để đối chiếu khi nghiệm thu, không mở thêm một vòng duyệt mockup.

### P0.3. Sai khác thiết kế–backend cần ghi nhận

1. Ngưỡng ngân sách mặc định 80/100 có thể được admin đổi: lấy `status`/`thresholds` thực tế, không cố định logic ở 80/100.
2. Mockup AI bảo trì cho đọc/xác nhận nháp; bảo trì toàn hệ thống hiện chặn request USER bằng 503. Phân biệt bảo trì hệ thống, AI bị tắt và lỗi dịch vụ AI; không hứa quyền thao tác khi API chặn.
3. SSE hiện không cung cấp cam kết thẻ số liệu có trước nội dung. Hiển thị theo dữ liệu/event thật và ghi rõ khác biệt nếu cần điều chỉnh UX.
4. Nút Dừng có thể chỉ dừng nhận/hiển thị phía client: không có bằng chứng backend hủy xử lý model khi ngắt kết nối. Khi quay lại phải tải hội thoại để đối soát.
5. Hoàn tác nháp nhiều giao dịch cần đối chiếu ID kết quả và API DELETE; chưa có bằng chứng endpoint hoàn tác nhóm nguyên tử. Phải xử lý được việc một số lệnh xóa thất bại.

**Điều kiện hoàn thành P0:** có đường chạy Android/API rõ ràng, bảng hợp đồng sơ bộ, ma trận ánh xạ giao diện và cách xử lý các sai khác. Các điểm chưa giải quyết được ghi thành phụ thuộc cụ thể, không giả lập thành tính năng hoàn chỉnh.

## 6. M1 — khung dự án và design system

### Việc thực hiện

1. Tạo nhánh `mobile/M1-foundation` từ `app-mobile` sau khi kiểm tra worktree.
2. Tạo `mobile/app/` bằng Flutter, tổ chức `vn.thuchi`, Android/iOS; chốt app ID trước các tích hợp phát hành.
3. Cấu hình lints, dependency, asset font, API_URL và entrypoint.
4. Ánh xạ màu sang ColorScheme/AppColors; spacing/radius/shadow/motion sang ThemeExtension; typography sang TextTheme.
5. Xây các widget nền: AppScaffold, card, row, icon bubble, amount text, input, button, chip, segmented, progress, badge, sheet, skeleton, empty/error state.
6. Xây keypad 0–9/000/xóa, đọc số tiền bằng chữ và giới hạn nhập.
7. Dựng tab bar 5 vị trí: Trang chủ · Lịch sử · ＋ · Báo cáo · Cài đặt. ＋ là hành động, không là tab dữ liệu.
8. Tap ＋ mở form chi; long press mở menu; dismiss bằng chạm ngoài, nút đóng, back.
9. Dựng router giữ trạng thái các tab, back stack, điều hướng chi tiết từ nhiều điểm vào; chat ẩn tab bar.
10. Dựng Dio/token storage/error mapping và formatter VN; log dev che token/mật khẩu/OTP.
11. Tạo màn kiểm tra component chỉ trong môi trường dev/test để rà hình trước khi nhân rộng.

### Chi tiết thị giác bắt buộc

- Nền `#F7F6F3`, card trắng, chữ `#111111`; tiền thu xanh `#1F8A4C`.
- Be Vietnam Pro, số tabular, dấu trừ U+2212, hậu tố `đ`.
- Lề 20; card radius 18; sheet radius 28; input radius 14; nút cao 52.
- Thiết kế tham chiếu 390×844 logical pixels; co giãn theo thiết bị, không khóa toàn app vào chiều rộng 390.
- Safe area thật từ OS; không vẽ Dynamic Island/status bar của ảnh mockup vào app.
- Hit target ít nhất 44×44; chip nhìn cao 34 vẫn có vùng chạm đủ.
- Tab bar thêm bottom inset thực tế, không cố định 34 trên mọi máy.
- Skeleton thay spinner; reduce-motion tắt shimmer và giảm chuyển động.
- Không gradient/emoji trang trí; icon cùng bộ, độ dày nhất quán.

### Nghiệm thu

- Android chạy được app shell, tab/back/＋ đúng hành vi.
- UI mẫu ở 390×844 khớp token; không tràn trên màn hẹp hơn và khi mở bàn phím.
- Formatter tiền, ngày chuyển múi giờ, keypad, parse lỗi có test hành vi.
- Lint/analyze sạch; test chạy được; không có token/API URL cá nhân trong source.

## 7. M2 — khởi động, xác thực và phiên

### Luồng khởi động

1. Đọc config công khai, có skeleton/lỗi thử lại.
2. Nếu bảo trì: màn bảo trì; nếu không, so sánh phiên bản nền tảng với min/latest theo từng thành phần số.
3. Bắt cập nhật chặn vào app; storeUrl trống/hỏng phải có thông báo phù hợp và thử lại, không nút chết.
4. Nếu được vào app: đọc token; có token thì gọi `/me`; không có token thì về login.
5. Phân biệt lỗi mạng khi kiểm tra phiên với 401: lỗi mạng không tự xóa token.
6. Đọc lại config khi foreground và xử lý thay đổi tính năng ngay trong phiên.

### Các luồng xác thực

- Login: validation, ẩn/hiện mật khẩu, lỗi inline, trạng thái đang gửi.
- Register: tên/email/mật khẩu, minLength từ config, cờ registrationEnabled, phiên đăng nhập sau thành công.
- Forgot: phản hồi trung tính khi server trả 204, không kết luận email có tồn tại.
- OTP/reset: 6 số, nhập/dán, resend countdown từ cấu hình/Retry-After; hỗ trợ background/foreground mà không kéo dài sai bộ đếm.
- Đổi mật khẩu: lưu token mới và cập nhật session theo response.
- Logout hiện tại: xóa token/cache cục bộ; logout-all gọi endpoint rồi kết thúc phiên.
- 401 và tài khoản khóa: chỉ thông báo/redirect một lần dù nhiều request đồng thời lỗi.

### Nghiệm thu

- Luồng đăng nhập → đóng/mở app → khôi phục phiên hoạt động.
- Có kiểm thử đăng ký tắt, bảo trì, bắt cập nhật, token hết hiệu lực, khóa user, 429, OTP sai/hết hạn và mất mạng.
- Không vòng lặp redirect; không màn private nháy lên trước login.
- Không coi FEATURE_DISABLED là lý do đăng xuất.

## 8. M3 — Trang chủ và thông báo

### Trang chủ

- Ghép `/stats/balance`, `/stats/summary`, `/budgets`, `/transactions?limit=5`, unread count và mẫu nhập nhanh khi bật tính năng.
- Chốt query riêng cho “Hôm nay” và “Tháng này”; không suy ra chi hôm nay từ 5 giao dịch gần nhất.
- Hiển thị tổng số dư/số ví, trạng thái ngân sách, chi hôm nay/tháng này, gần đây.
- Nút che số dư là trạng thái hiển thị cục bộ; không làm thay đổi dữ liệu.
- Có pull-to-refresh, lỗi từng khối phù hợp và trạng thái chưa có ngân sách/ví/giao dịch.
- Điểm vào Ví, Ngân sách, Lịch sử, Thông báo; chuẩn bị vị trí AI theo mockup duyệt ở M10.
- Sau ghi/chuyển tiền/nạp tiết kiệm, nội dung liên quan cập nhật từ API.

### Thông báo

- Danh sách phân trang, đọc/chưa đọc, đọc từng thông báo, đọc tất cả.
- Badge đồng bộ giữa chuông và Cài đặt.
- Chỉ điều hướng sâu khi payload có đủ thông tin; dữ liệu đích đã xóa có thông báo phù hợp.

### Nghiệm thu

- Số liệu khớp API, không phải hằng số từ mockup.
- Có bốn trạng thái; trang chủ còn dùng được khi một request thành phần lỗi.
- Đọc thông báo cập nhật badge đúng, không tải trùng trang.

## 9. M4 — ghi giao dịch, danh mục, mẫu và chuyển tiền

### Form thu/chi

- Mặc định chi khi mở từ ＋; thu khi mở từ menu Thu nhập.
- Số tiền, tiêu đề, danh mục, ví, thời điểm, ghi chú theo body thực tế; chốt cách ánh xạ tiêu đề/ghi chú ở P0.
- Đổi Thu/Chi phải kiểm tra lại danh mục đang chọn; không gửi danh mục sai loại.
- Chọn danh mục đúng loại, chọn ví đang hoạt động, chọn ngày/giờ VN.
- Validate tiền nguyên, lớn hơn 0, giới hạn backend; bảo toàn dữ liệu form nếu request lỗi.
- Đang lưu khóa submit; thành công đóng/điều hướng theo luồng thiết kế và refresh nguồn dữ liệu.
- Thu/chi có thể làm ví âm theo nghiệp vụ: UI không tự chặn vì số dư không đủ.

### Danh mục và mẫu nhập nhanh

- Xây chọn danh mục trước, quản lý danh mục riêng kế thừa list/form/sheet trong thiết kế đã duyệt.
- Danh mục hệ thống không hiện thao tác chỉnh sửa của user.
- Dùng mẫu gọi `/quick-templates/:id/use`; đây là ghi thật, xử lý feedback/chống bấm lặp rõ ràng.
- Tạo/sửa/xóa mẫu và lưu mẫu từ form khi hợp đồng/thiết kế cho phép.
- Mẫu tham chiếu ví/danh mục đã lưu trữ: hiện 409, làm mới danh sách, không tự thay ví.

### Chuyển tiền

- Chọn ví nguồn/đích khác nhau; nhập số tiền/thời gian/nội dung theo DTO.
- Gọi API để kiểm tra số dư đủ; cập nhật hai ví và tổng quan sau thành công.
- Phân biệt chuyển tiền với thu/chi trong lịch sử và báo cáo.
- Chi tiết/sửa/xóa chuyển tiền dùng bố cục chi tiết và form đã duyệt, ánh xạ đúng trường của chuyển tiền để hoàn thiện hành trình lịch sử.

### Nghiệm thu

- Tạo thu/chi, dùng mẫu, chuyển tiền hoạt động với dữ liệu thật.
- Không gửi field `type` thay cho category; không tự tính số dư sau lưu.
- Mạng ngắt trong lúc gửi không dẫn đến tự retry và tạo trùng.
- Test keypad, thay loại giao dịch, validation, lỗi 400/409 và đồng bộ sau lưu.

## 10. M5 — lịch sử, chi tiết, sửa/xóa

- Danh sách phân trang, nhóm theo ngày VN, tổng nhóm chỉ tính khi đủ dữ liệu tương ứng.
- Trường hợp một ngày vắt qua hai trang: gộp cùng nhóm và không gọi tổng trang đầu là tổng cả ngày.
- Nếu API không có tổng ngày đủ dùng, lấy đủ phần ngày đó hoặc điều chỉnh nhãn đã duyệt; không trình bày subtotal như total.
- Bộ lọc tháng, loại, danh mục, ví, từ khóa; debounce tìm kiếm và hủy/bỏ response lỗi thời.
- Duy trì vị trí cuộn/bộ lọc khi quay từ chi tiết; thay bộ lọc phải reset phân trang.
- Chi tiết gọi endpoint theo ID; hiển thị 404 khi bản ghi đã bị xóa.
- Sửa dùng lại form M4; xóa có xác nhận; cập nhật cả tháng/ví/danh mục cũ và mới.
- Giao dịch từ ví lưu trữ: hiển thị giới hạn sửa/xóa và phản hồi server.
- Nếu thiết kế lịch sử có chuyển tiền, ghép hai nguồn bằng bộ phân trang/sắp xếp rõ ràng; không ghép trang 1 rồi kết luận đã tải đủ. Chốt phạm vi này trong ma trận P0.

Nghiệm thu: tìm/lọc/phân trang không trùng hoặc mất bản ghi; nhóm ngày đúng sát 00:00 VN; sửa/xóa phản ánh trên Trang chủ, Ví, Báo cáo và Ngân sách.

## 11. M6 — báo cáo, xu hướng, CSV

- Dựng Báo cáo tháng và Xu hướng theo ảnh 09–10.
- Nguồn: report, by-category, trend, daily với bộ lọc tháng/ví đồng bộ.
- Thu, chi, chênh lệch, so sánh và dự báo lấy từ API; không viết lại công thức dự báo.
- Donut/cột/đường theo thiết kế; category-color ổn định, legend có tên/số, nội dung đọc được khi không phân biệt màu.
- Dữ liệu 0, chỉ một danh mục, nhiều danh mục, thiếu lịch sử dự báo đều có cách trình bày.
- Xuất CSV tôn trọng cờ csvExport và bộ lọc được API hỗ trợ; giữ UTF-8 BOM/tiếng Việt.
- Dùng cơ chế chia sẻ/lưu file của nền tảng; xử lý download lỗi, tên file, cleanup file tạm và người dùng hủy share.
- Không xin quyền truy cập bộ nhớ rộng nếu cơ chế lưu/chia sẻ không cần.

Nghiệm thu: số/chart khớp API cùng bộ lọc; CSV mở đúng tiếng Việt; không hiện nút xuất khi tính năng bị tắt.

## 12. M7 — ngân sách và tiết kiệm

### Ngân sách

- Ngân sách tổng và theo danh mục; tháng, đã dùng, còn lại, phần trăm/status từ API.
- Thanh fill kẹp ở 100% nhưng nhãn giữ phần trăm thực tế >100%.
- Màu/badge theo trạng thái thực; mặc định 80/100 nhưng hỗ trợ cấu hình admin khác.
- Thêm/sửa/xóa; sao chép từ tháng sang tháng; xử lý bản ghi đã tồn tại/danh mục lưu trữ theo response.
- Chưa có ngân sách có CTA tạo; không chia cho 0 trong widget.

### Tiết kiệm

- Danh sách theo trạng thái, chi tiết mục tiêu, lịch sử nạp/rút.
- Tạo/sửa kế thừa form/sheet đã duyệt; nạp chọn ví/tiền/ngày.
- Backend có thể cắt số nạp về phần còn thiếu: UI báo số thực tế server đã ghi.
- Rút trả toàn bộ về ví chọn theo nghiệp vụ hiện có; không dựng rút một phần nếu API không hỗ trợ.
- Hiển thị ACTIVE/COMPLETED/WITHDRAWN/EARLY_WITHDRAWN đúng enum thực tế sau khi kiểm tra model.
- Mục tiêu đã rút không nạp nữa; còn tiền thì không xóa được.

Nghiệm thu: nạp/rút cập nhật ví và mục tiêu, không được tính thành thu/chi; ca thiếu tiền, quá số còn thiếu, hoàn thành và rút sớm đều đúng.

## 13. M8 — ví và giao dịch định kỳ

### Ví

- Danh sách CASH/BANK/EWALLET, số dư và tổng số dư từ API.
- Tạo/sửa ví; số dư ban đầu theo giới hạn backend.
- Xóa chưa phát sinh, lưu trữ khi có phát sinh và balance=0, khôi phục.
- Thông báo 409 khi ví còn tiền; không tự chuyển hết tiền hay xóa dữ liệu để vượt điều kiện.
- Làm mới picker/mẫu nhập nhanh sau khi ví thay đổi.

### Định kỳ

- Danh sách active/paused/expired theo dữ liệu API; form tạo/sửa có tần suất, interval, ngày bắt đầu/kết thúc và ví/danh mục.
- Preview các lần chạy bằng `/recurring/:id/preview`, không dùng client làm bộ máy sinh lịch.
- Tạm dừng/tiếp tục/xóa với phản hồi rõ; giữ giao dịch đã phát sinh khi xóa quy tắc.
- Hiển thị lịch ngày 31, năm nhuận theo kết quả API; test chỉ xác nhận app hiển thị đúng.
- Tạo lịch quá khứ có thể sinh bù: thể hiện hệ quả trước lưu theo thiết kế được duyệt.
- Không gọi endpoint chạy cron dev/test từ app sản phẩm.

Nghiệm thu: vòng đời ví và pause/resume chạy đúng; không tự sinh giao dịch định kỳ trên điện thoại.

## 14. M9 — Cài đặt và tài khoản

- Danh sách nhóm theo ảnh 20/20b, tất cả điểm vào có đích và phản ánh feature flags.
- Hiển thị user, đổi tên, phiên bản app thật.
- Đổi mật khẩu với minLength cấu hình, lưu token mới, xử lý phiên cũ bị vô hiệu.
- Đăng xuất máy hiện tại và mọi nơi đúng khác biệt.
- Link hỗ trợ/điều khoản/quyền riêng tư lấy từ config; field trống không tạo nút bấm hỏng.
- Xóa tài khoản theo màn 21: yêu cầu mật khẩu, mô tả hệ quả, chặn bấm lặp, xóa state sau thành công.
- Kiểm thử xóa trên tài khoản test riêng có thể bỏ; không xóa tài khoản demo dùng chung để thử luồng.
- Danh mục/mẫu nhập nhanh nối tới quản lý đã hoàn thiện ở M4.

Nghiệm thu: không có mục “để sau” trong phạm vi đã cam kết; đổi mật khẩu vẫn giữ phiên hiện tại; đăng xuất/xóa không để dữ liệu cũ trên back stack.

## 15. M10 — Trợ lý AI

### M10.1. Điểm vào và hội thoại

- Ba điểm vào theo mockup: cạnh chuông, đầu menu long press ＋, Cài đặt.
- Ẩn cả ba khi `ai.enabled=false`; mở route cũ vẫn xử lý được tính năng tắt.
- List hội thoại: tìm kiếm theo khả năng API, nhóm, ghim, rename, archive/unarchive nếu API cho phép, xóa.
- Kiểm tra API có phân trang/tìm kiếm không; nếu lọc phía client chỉ áp dụng trên tập đã tải và không trình bày như kết quả toàn bộ khi chưa đủ.
- Tạo cuộc mới xử lý `autoArchived`; mọi cuộc đều ghim xử lý 409.
- Chat là màn con ẩn tab bar, có ghi chú riêng tư theo thiết kế.

### M10.2. Gửi tin và SSE

- Xây đường JSON làm mốc kiểm chứng contract, sau đó tích hợp POST SSE.
- Parse UTF-8/event đúng khi chunk bị cắt giữa ký tự/dòng; hỗ trợ nhiều event trong một chunk.
- Xử lý lỗi HTTP trước stream và event `error` sau khi stream đã mở.
- Hỗ trợ `user`, `route`, `delta`, `done` theo payload thực tế; deduplicate theo ID khi reconcile.
- Hiển thị trạng thái thật, skeleton đúng thẻ; không bịa tiến độ/thời gian hoặc lời giải thích đã sẵn sàng.
- Nút Dừng hủy nhận phía client theo khả năng hiện tại; tải lại hội thoại để nhận kết quả server có thể đã hoàn tất.
- Mất stream: không tự gửi lại câu hỏi, vì tin user có thể đã lưu và lượt đã tính.

### M10.3. Thẻ số liệu và nháp

- Thẻ số liệu lấy từ response/meta được xác minh; có nguồn và link màn gốc khi đủ dữ liệu.
- Nháp transaction/budget tách riêng; viền nét đứt, badge chưa lưu.
- Sửa nháp chỉ thay dữ liệu local cho đến lúc confirm; kiểm tra danh mục/ví/tiền/ngày giống form thường.
- Hiện `possibleDuplicate`; người dùng vẫn là bên quyết định xác nhận.
- Confirm gửi payload đã sửa khi cần; khóa nút trong khi gửi; lấy trạng thái/result thật sau response.
- Nháp CONFIRMED/EDITED/CANCELLED/EXECUTING hiển thị đúng, kể cả tải lại app hoặc thao tác từ thiết bị khác.
- Xác nhận lặp theo contract idempotent không tạo thêm giao dịch.
- Nháp tìm kiếm chỉ điều hướng bộ lọc được hỗ trợ; không chạy chức năng admin từ app USER.

### M10.4. Hoàn tác và đồng bộ

- Với nháp giao dịch đã lưu: dùng đúng ID giao dịch trong result để hoàn tác, không tìm/xóa theo số tiền hay tiêu đề.
- Nếu API chỉ hỗ trợ DELETE từng giao dịch, theo dõi kết quả từng ID và thông báo rõ phần thành công/thất bại.
- Không gắn nhãn “đã hoàn tác tất cả” khi có lệnh xóa lỗi; không áp dụng hoàn tác xóa giao dịch cho nháp ngân sách.
- Hết thời gian toast chỉ đóng thao tác nhanh; người dùng vẫn có thể quản lý giao dịch ở lịch sử theo quyền API.
- Làm rõ trạng thái thẻ chat sau hoàn tác vì draft server có thể vẫn CONFIRMED; nếu cần trạng thái bền vững mới mà API chưa có thì ghi gap và xin quyết định, không tự sửa backend.

### M10.5. Phản hồi, giới hạn, riêng tư

- Hữu ích/Chưa đúng, chọn cách hiểu khác qua skills/reroute, xử lý lỗi mà không mất nội dung chat.
- Usage lấy từ `/ai/usage`; giới hạn theo config, không hard-code 30/50 trong logic.
- Hết lượt: Retry-After/giờ mở lại theo response, còn đường ghi thủ công.
- AI tắt, lỗi provider, timeout, bảo trì toàn app là các trường hợp khác nhau.
- Cài đặt: trí nhớ, xóa từng/toàn bộ, danh sách lưu trữ, shareExamples.
- Hỏi đồng ý một lần theo `asked`; không tự bật chia sẻ, có thể tắt.
- Không lưu token hoặc nội dung tài chính/chat đầy đủ trong log.

### Nghiệm thu

- Hỏi số dư/tổng kết/tìm giao dịch tạo đúng loại trả lời và link.
- Nháp 1/nhiều giao dịch: sửa/hủy/xác nhận/xác nhận lại không tạo sai hoặc trùng.
- Stream lỗi/dừng/đổi màn không làm gửi lại tin ngầm.
- Mọi giới hạn backend và sai khác UX ở P0 được giải quyết hoặc ghi rõ trước khi chấp nhận M10.
- Fake provider dùng cho test xác định; nếu chưa chạy được provider thật thì ghi giới hạn nghiệm thu AI thật.

## 16. Ma trận làm mới dữ liệu sau thao tác

| Thao tác thành công | Dữ liệu cần đọc lại |
|---|---|
| Tạo/sửa/xóa thu chi, dùng mẫu, confirm nháp giao dịch | Lịch sử/chi tiết, số dư/ví, Trang chủ, báo cáo, ngân sách, thông báo |
| Đổi tháng/ví/danh mục của giao dịch | Dữ liệu của cả phạm vi cũ và mới |
| Chuyển tiền | Ví nguồn/đích, tổng quan số dư, danh sách/chi tiết chuyển tiền |
| Nạp/rút tiết kiệm | Mục tiêu/ledger, ví, số dư Trang chủ |
| Đổi ngân sách/confirm nháp ngân sách | Ngân sách, Trang chủ và thông báo liên quan nếu API thay đổi |
| Đổi ví/danh mục/mẫu | Danh sách quản lý, picker, form đang dùng tham chiếu và quick actions |
| Đổi định kỳ | Danh sách, chi tiết, preview; giao dịch/overview nếu API sinh bù |
| Đọc thông báo | Danh sách, unread count, badge |
| Đổi tên/mật khẩu | Session/me; thay token khi backend trả token mới |
| Đăng xuất/xóa tài khoản | Xóa toàn bộ state theo user và hủy request |

Không refresh tất cả ứng dụng sau mỗi thao tác nếu chỉ ảnh hưởng một nhóm; cũng không cập nhật số dư bằng phép cộng/trừ local để thay response server.

## 17. Kế hoạch kiểm thử và kiểm tra thị giác

### 17.1. Kiểm thử tự động có mục tiêu

- Unit: tiền nguyên, định dạng âm/dương, đọc tiền, ngày VN, version compare, error mapping, config gates, serialization.
- Controller/repository: race khi đổi bộ lọc, pagination, invalidation, session cleanup, chống submit trùng.
- Widget: ít nhất luồng chính của từng màn theo DoD; keyboard, validation, skeleton/empty/error và điều hướng.
- AI: parser SSE chia chunk, lỗi trước/sau stream, reconcile tin, confirm/cancel state và duplicate warning.
- Golden cho component và màn trọng yếu với font/viewport/fixture cố định; không dùng golden thay test nghiệp vụ.
- Integration với API test: một hành trình hoàn chỉnh tạo/sửa/xóa và kiểm tra các màn liên quan cập nhật.

### 17.2. Hành trình bắt buộc

| Mã | Hành trình |
|---|---|
| E01 | Login → Trang chủ → tạo khoản chi → Lịch sử → chi tiết → sửa → xóa |
| E02 | Tạo thu → dùng mẫu → đổi ví/danh mục → đối chiếu số dư/ngân sách |
| E03 | Chuyển tiền đủ tiền và thiếu tiền → kiểm tra hai ví |
| E04 | Ngân sách chưa có → tạo → chạm ngưỡng → thông báo → sửa hạn mức |
| E05 | Tạo mục tiêu → nạp → hoàn thành → rút → kiểm tra số dư |
| E06 | Tạo định kỳ → preview → pause → resume → xóa quy tắc |
| E07 | Đổi mật khẩu → token mới → logout-all → login lại |
| E08 | Forgot → OTP → resend → reset → token cũ hết hiệu lực |
| E09 | Báo cáo đổi tháng/ví → CSV → mở file tiếng Việt |
| E10 | Config tắt tính năng / bảo trì / minVersion thay đổi trong phiên |
| E11 | AI tạo nháp nhiều khoản → sửa → confirm → kiểm tra lịch sử → hoàn tác khả dụng |
| E12 | AI hết lượt / mất stream / provider lỗi / tắt AI / từ chối góp ví dụ |
| E13 | Logout user A → login user B → không xuất hiện dữ liệu A |
| E14 | Xóa tài khoản test → token/state/cache sạch |

### 17.3. Kiểm tra giao diện

- So sánh ảnh app với mockup trên viewport tham chiếu, loại khung máy/status bar giả khỏi đánh giá UI ứng dụng.
- Kiểm tra ít nhất màn hẹp khoảng 360 logical pixels, chuẩn 390 và màn rộng hơn.
- Chữ hệ thống lớn hơn, tên/ghi chú dài, số tiền lớn, không dữ liệu và nhiều dữ liệu.
- Safe area, Android back, bàn phím, bottom sheet, long press và cuộn.
- Screenshot dùng dữ liệu demo thật; sai khác con số/ngày do seed hiện tại được ghi rõ, không sửa app để ép khớp số cũ trong ảnh.
- Mọi màn có ảnh đối chiếu; mọi khác biệt có lý do/được duyệt, không bỏ qua lệch font/spacing bằng một ngưỡng ảnh quá rộng.

### 17.4. Lệnh kiểm tra dự kiến

Trong `mobile/app/`:

```text
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter test integration_test -d <android-device-id> --dart-define=API_URL=<test-api>
flutter build apk --debug --dart-define=API_URL=<dev-api>
```

Điều chỉnh path test theo thư mục thực tế đã tạo. Build iOS và test simulator chạy trên macOS. Release ký thật chỉ thực hiện trong bước phát hành riêng.

Không chạy toàn bộ test backend/admin sau mỗi sửa UI. Dùng kiểm thử mobile phù hợp và smoke API; chạy hồi quy toàn repo khi có thay đổi liên quan hoặc trước tích hợp nếu quy trình dự án yêu cầu. Các test thay đổi config/seed dùng môi trường riêng.

## 18. Thứ tự thực hiện và mốc bàn giao

| Mốc | Công việc | Đầu ra xem được | Điều kiện đi tiếp |
|---|---|---|---|
| G0 | P0 | Checklist môi trường, hợp đồng, ma trận màn/component | Có đường chạy và các phụ thuộc đã rõ |
| G1 | M1 | App shell Android + bộ component | Theme/routing/network nền ổn, analyze/test đạt |
| G2 | M2 → M3 → M4 → M5 | Bản dùng được: login, Trang chủ, ghi thu chi, lịch sử | Hành trình E01/E02/E07/E08 cơ bản đạt |
| G3 | M6 → M7 → M8 → M9 | Đủ nghiệp vụ tài chính và Cài đặt | Mọi điểm vào trong phạm vi hoạt động |
| G4 | M10 | Trợ lý AI nối dữ liệu thật | Confirm an toàn, stream/giới hạn/consent đúng |
| G5 | Hồi quy, sửa lỗi, polish | APK thử, ảnh đối chiếu, báo cáo, hướng dẫn | Không còn lỗi chặn hành trình; giới hạn công khai |

Thực thi mặc định tuần tự với một agent. Bảng M2/M3/M4 trong yêu cầu cho phép nhóm chia việc, nhưng kế hoạch này không tự dùng sub-agent. Nếu người dùng yêu cầu nhiều agent sau này, chia theo ownership file và worktree riêng; các tác vụ nặng vẫn tuần tự.

Sau mỗi mốc báo: phần xong, ảnh/bản chạy được, test đã chạy, lỗi/phụ thuộc còn lại và bước tiếp theo. Việc duyệt kế hoạch cho phép thực thi phạm vi đã chốt. Không yêu cầu duyệt lại bộ mockup hoặc các quyết định triển khai thông thường; chỉ cần trao đổi khi phát sinh thay đổi sản phẩm ngoài phạm vi hoặc trở ngại cần thông tin từ người dùng.

## 19. Quy trình Git và tài liệu

- Nhánh con `mobile/M1-foundation`, `mobile/M2-auth`… hoặc tên tương ứng gói việc.
- Giữ thay đổi người dùng; kiểm tra status trước đổi nhánh/chạy generator.
- Có thể thực hiện các gói phụ thuộc trên chuỗi nhánh đã có nền tương ứng, rồi tích hợp theo thứ tự; không giả định M2 build được trên nhánh nền chưa có M1.
- Mỗi gói có diff tập trung, danh sách màn, screenshot và kết quả test.
- Target review/PR là `app-mobile`; không push thẳng `app-mobile`/`main`.
- Push, mở PR hoặc merge thực hiện khi thuộc phạm vi người dùng đã cho phép; việc duyệt kế hoạch triển khai không mặc nhiên là yêu cầu phát hành production.
- Nếu API thiếu/sai: ghi request/response đã che dữ liệu nhạy cảm trong tài liệu issue để trao đổi; không tự sửa backend trong nhánh mobile.
- Cập nhật hướng dẫn chạy, API_URL Android emulator `http://10.0.2.2:3000/api`, điện thoại thật dùng IP LAN, iOS simulator dùng localhost trên máy chạy API tương ứng.
- HTTP cleartext chỉ cấu hình dev/debug theo nhu cầu; cấu hình phát hành dùng endpoint HTTPS thực tế khi có.

## 20. Rủi ro, phụ thuộc và cách xử lý

| Rủi ro/phụ thuộc | Cách xử lý |
|---|---|
| Flutter có trong PATH nhưng SDK Android/build chưa sẵn | Doctor trước scaffold lớn; xử lý toolchain, ghi rõ nếu cần cài thêm |
| Docker/API local chưa chạy | Tìm môi trường hiện có; thiết lập dev riêng hoặc dùng API được cung cấp |
| OpenAPI response thiếu schema | Model viết tay có fixture và đối chiếu response thực |
| Form/trạng thái phụ chưa có ảnh riêng | Kế thừa component, token và luồng đã duyệt; ghi rõ ánh xạ trong ma trận màn để kiểm tra |
| AI mockup vượt khả năng API | Lập gap có bằng chứng, đề xuất UX phù hợp; không mô phỏng thành cam kết backend |
| Mất mạng sau thao tác ghi | Không auto-retry; đối soát dữ liệu/nháp và báo trạng thái phù hợp |
| Số liệu demo thay đổi theo thời gian | So sánh giao diện riêng với tính đúng của dữ liệu API |
| Chưa có Mac/thiết bị thật | Kiểm chứng Android trước, ghi rõ iOS/thiết bị thật chưa được xác minh |
| Máy hạn chế tài nguyên | Một tác vụ nặng mỗi lúc, tránh browser/emulator/Docker build chạy chồng |
| Tài liệu cũ mâu thuẫn nhau | Ưu tiên quyết định sản phẩm đã chốt, yêu cầu mobile mới và contract backend đang chạy; ghi khác biệt |

Không đưa thời hạn cứng trước G0 vì toolchain, màn bổ sung và sai khác AI chưa được xác minh hết. Sau G0 chia mỗi gói thành đầu việc nhỏ có đầu ra kiểm tra được và cập nhật dự toán dựa trên thực tế.

## 21. Checklist hoàn tất toàn bộ

- [ ] P0 và các phụ thuộc thiết kế/API đã được giải quyết hoặc có quyết định rõ.
- [ ] M1–M10 đạt tiêu chí riêng và mọi đường đi trong phạm vi có màn hoạt động.
- [ ] Không còn UI dữ liệu mẫu cố định trong bản ứng dụng.
- [ ] Bốn trạng thái dữ liệu được xử lý ở từng màn phù hợp.
- [ ] Config, phiên, timezone, tiền và feature flags đúng hợp đồng.
- [ ] Không tạo giao dịch trùng do bấm lặp hoặc retry ngầm.
- [ ] Các dữ liệu liên quan cập nhật nhất quán sau mutation.
- [ ] AI không tự ghi; consent mặc định không được tự bật.
- [ ] Analyze/test/build Android đạt; kết quả iOS được phân biệt rõ đã kiểm chứng/chưa kiểm chứng.
- [ ] Ảnh đối chiếu, báo cáo test, hướng dẫn và giới hạn đã cập nhật.
- [ ] Bản cài thử và diff sẵn sàng review; không tự phát hành store/production.

## 22. Trạng thái thực thi

Người dùng đã xác nhận thực thi kế hoạch. P0 bắt đầu ngày 17/10/2026; tiếp theo triển khai M1–M10 theo thứ tự và phạm vi đã mô tả. Các lựa chọn đi cùng kế hoạch là: Riverpod/go_router/Dio theo yêu cầu dự án, model Freezed + json_serializable, font nhúng asset, Android kiểm chứng trước, AI ở giai đoạn cuối, thực hiện tuần tự và giữ backend ngoài phạm vi thay đổi.

Bộ mockup đã được duyệt và không cần xác nhận lại. Tiến độ và bằng chứng kiểm tra được cập nhật trong `mobile/docs/` khi từng mốc hoàn tất.

Tiến độ hiện tại:

- [x] P0: Flutter/Android SDK/license/emulator, ma trận màn và quy ước API.
- [x] M1: scaffold Android/iOS, theme/token/font, router/tab bar/nút ＋, widget nền, Dio/token storage, formatter và APK debug chạy trên AVD API 36.
- [x] M2: cấu hình công khai, khởi động app, luồng xác thực (Login, Register, Forgot/Reset password), quản lý phiên và điều hướng router guard.
- [x] M3: Trang chủ (số dư, ngân sách, chi tiêu hôm nay/tháng, giao dịch gần đây, mẫu nhanh) và Thông báo (danh sách phân nhóm, đánh dấu đọc, badge).
- [x] M4: Ghi giao dịch (chi/thu), danh mục (sheet 4-cột, thêm mới), chọn ví, bàn phím số numeric keypad, mẫu nhập nhanh và chuyển tiền giữa các ví.
- [ ] M5–M10: đang tiếp tục triển khai theo thứ tự của kế hoạch (tiếp theo: M5 Lịch sử, chi tiết giao dịch, sửa/xóa).

