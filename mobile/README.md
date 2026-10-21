# App mobile TrackerX (Flutter) — yêu cầu cho nhóm làm app

Nhánh này (`app-mobile`) là nơi dựng app di động cho người dùng cuối. Backend, admin web và thiết kế đã xong trên `main`. App **chỉ gọi API có sẵn**: không cần sửa backend để làm hết các màn ở Giai đoạn 1–3.

Đọc theo thứ tự: mục 1 → 4 để chạy được, mục 5 → 7 để biết làm gì, mục 8 để biết chia việc.

---

## 1. Tài liệu nguồn (bắt buộc đọc trước khi code)

| Nội dung | File | Ghi chú |
|---|---|---|
| Mockup 25 màn (đã duyệt) | `design/mockup/index.html`, ảnh `design/mockup/shots/01…23-*.png` | Mở `index.html` bằng trình duyệt, không cần server. **Dựng đúng mockup, không tự thiết kế lại** |
| Mockup Trợ lý AI (mục J) | `design/mockup/shots/30-ai-*.png`, `docs/AI-DECISIONS.md` | Giai đoạn 4 |
| Design token → Flutter | `design/tokens.md` | Màu, chữ, khoảng cách, bo góc, bóng, motion map 1:1 sang `ThemeData` + `ThemeExtension` |
| Nguyên tắc thiết kế | `design/DESIGN.md` | |
| Danh sách API + luật nghiệp vụ | `backend/README.md` (mục "Endpoint", "Nghiệp vụ v1", "Trợ lý AI", "Cấu hình hệ thống") | Luật nghiệp vụ nằm ở backend, app không tự tính lại |
| Đặc tả OpenAPI (88 endpoint) | `mobile/openapi.json` | Dùng để sinh client Dart. Bản sống: `http://<máy-chạy-API>:3000/docs` (Swagger UI) và `/docs/openapi.json` |

---

## 2. Công nghệ chốt

| Hạng mục | Chọn | Lý do |
|---|---|---|
| Framework | Flutter (stable mới nhất), Dart 3 | Một code cho Android + iOS |
| Thư mục | `mobile/app/` (tạo bằng `flutter create --org vn.thuchi --platforms android,ios app`) | Giữ `mobile/` cho tài liệu + openapi |
| State | Riverpod | |
| Điều hướng | go_router | Có redirect theo trạng thái đăng nhập / bảo trì / bắt cập nhật |
| HTTP | dio (+ interceptor gắn token, xử lý 401/403/429/503) | |
| Model API | sinh từ `openapi.json` (`openapi-generator` dart-dio) **hoặc** viết tay bằng `freezed` + `json_serializable` — nhóm chọn 1, cả nhóm dùng chung | |
| Lưu token | flutter_secure_storage | Không lưu token vào SharedPreferences |
| Biểu đồ | fl_chart | Màu lấy từ `AppColors.viz1..5` |
| Font | Be Vietnam Pro (google_fonts hoặc nhúng asset) | |
| Định dạng số/ngày | intl, locale `vi_VN`, múi giờ `Asia/Ho_Chi_Minh` | |

---

## 3. Chạy backend để làm app

Cần Node 22+, Docker. Ở gốc repo:

```bash
npm run setup     # cài, tạo .env, bật Postgres (Docker :5433), migrate, seed, nạp dữ liệu demo
npm run dev       # API http://localhost:3000/api  (Swagger: http://localhost:3000/docs)
```

Tài khoản để dựng màn (dữ liệu khớp mockup): **`demo@thuchi.vn` / `demo123`** — 4 ví tổng 26.022.000đ, ngân sách tháng 14 triệu, 3 mục tiêu tiết kiệm, 5 định kỳ, mẫu Cà phê 45k / Cơm trưa 55k / Grab 38k.

Địa chỉ API của app **cố định** `https://tracker-xt.freepro.online/api` (máy chủ của nhóm, có AI; laptop chủ dự án phải bật). Không đổi, không dùng `--dart-define=API_URL`. Xem [`../API-URL.md`](../API-URL.md). Chạy app: `flutter run`.

---|---|
| Android emulator | `http://10.0.2.2:3000/api` |
| iOS simulator | `http://localhost:3000/api` |
| Điện thoại thật cùng Wi-Fi | `http://<IP-LAN-máy-chạy-API>:3000/api` (Android cần cho phép cleartext HTTP ở bản debug) |

---

## 4. Quy ước gọi API (áp dụng cho mọi màn)

- Prefix `/api`. Mọi route trừ `auth/register`, `auth/login`, `auth/forgot-password`, `auth/reset-password`, `health`, `config/public` cần header `Authorization: Bearer <accessToken>`.
- **Số tiền là số nguyên đồng** (không có phần lẻ). Hiển thị `1.250.000đ`; khoản chi `−45.000đ` (dấu trừ U+2212), khoản thu `+45.000đ` màu `income`.
- **Ngày giờ theo giờ Việt Nam.** `month=YYYY-MM`. Gửi ngày không kèm múi giờ (`2026-09-01T08:00`) được hiểu là giờ VN. Hiển thị luôn đổi về giờ VN, không phụ thuộc múi giờ máy.
- Phân trang: `page` (từ 1), `limit` ≤ 200 → trả `{items, total, page, limit}`.
- Loại thu/chi của giao dịch lấy theo danh mục (app không gửi `type`).
- Số dư ví, % ngân sách, trạng thái mục tiêu… **luôn lấy từ API**, không tự cộng trừ ở app.
- Lỗi trả `{statusCode, message, code?}` (`message` là chuỗi hoặc mảng chuỗi, đã viết tiếng Việt → hiện thẳng cho người dùng):

| Mã | Xử lý ở app |
|---|---|
| 400 | Hiện `message` cạnh ô nhập / toast |
| 401 | Token hết hiệu lực (đổi mật khẩu, đăng xuất mọi nơi…) → xóa token, về Đăng nhập, báo "Phiên đăng nhập đã hết hạn" |
| 403 `Tài khoản đã bị khóa` | Xóa token, về Đăng nhập, báo bị khóa |
| 403 `code: FEATURE_DISABLED` | Tính năng bị admin tắt → **không** đăng xuất; ẩn tính năng, đọc lại `config/public` |
| 403 `code: REGISTRATION_DISABLED` | Màn Đăng ký báo "Tạm ngưng nhận đăng ký" |
| 404 | "Không tìm thấy" (dữ liệu đã bị xóa ở thiết bị khác) |
| 409 | Hiện `message` (vd xóa ví còn tiền, mẫu nhập nhanh dùng ví đã lưu trữ) |
| 429 | Hiện `message`; nếu có header `Retry-After` thì nói rõ chờ bao nhiêu giây. `code: AI_DAILY_LIMIT` → thẻ "hết lượt hỏi" (màn 30-ai-11) |
| 503 `code: MAINTENANCE` | Màn bảo trì toàn màn hình với `message` + `endsAt` |

### Khởi động app
1. Gọi `GET /config/public` (công khai, chạy cả khi bảo trì). Dùng các trường:
   - `maintenance.enabled/message/endsAt` → màn bảo trì.
   - `mobile.android|ios.minVersion` > bản app → màn bắt buộc cập nhật (link `storeUrl`); `latestVersion` > bản app → gợi ý cập nhật.
   - `features.{savingGoals, recurring, transfers, csvExport, quickTemplates}` = `false` → ẩn mục đó khỏi app.
   - `ai.enabled` = `false` → ẩn cả 3 lối vào Trợ lý AI.
   - `registrationEnabled`, `password.minLength`, `otp.expiryMinutes/resendSeconds`, `budget.warningPercent/exceededPercent`, `supportEmail`, `hotline`, `termsUrl`, `privacyUrl`.
2. Có token trong secure storage → `GET /me`; 401/403 → về Đăng nhập. Không có token → Đăng nhập.
3. Đọc lại `config/public` khi app quay lại foreground (admin đổi cấu hình có hiệu lực trong ~1 phút).

---

## 5. Danh sách màn hình ↔ API

Tab bar: **Trang chủ · Lịch sử · [＋] · Báo cáo · Cài đặt**. Chạm ＋ = Ghi giao dịch; nhấn giữ ＋ = menu Thu nhập / Chuyển tiền / các mẫu nhập nhanh (+ "Hỏi trợ lý" ở Giai đoạn 4).

| # | Màn (ảnh trong `design/mockup/shots/`) | API |
|---|---|---|
| 01 | Đăng nhập `01-dang-nhap` | `POST /auth/login` `{email, password}` → `{accessToken, user}` |
| — | Đăng ký (cùng style màn 01) | `POST /auth/register` `{email, password, name}` → `{accessToken, user}` (tự tạo ví mặc định) |
| 02–03 | Quên mật khẩu, nhập OTP `02-quen-mat-khau`, `03-nhap-otp` | `POST /auth/forgot-password` `{email}` (luôn 204) → `POST /auth/reset-password` `{email, otp, newPassword}`. Đếm ngược gửi lại theo `otp.resendSeconds` |
| 04 | Trang chủ `04-trang-chu` | `GET /stats/balance`, `GET /stats/summary?month=`, `GET /budgets?month=`, `GET /transactions?limit=5`, `GET /notifications/unread-count` |
| 05, 05b | Ghi giao dịch, menu nút ＋ `05-ghi-giao-dich`, `05b-menu-nut-cong` | `GET /wallets`, `GET /categories?type=EXPENSE\|INCOME`, `POST /transactions` `{categoryId, walletId, amount, title, note?, occurredAt}`; mẫu: `GET /quick-templates`, `POST /quick-templates/:id/use` |
| 06 | Chọn danh mục `06-chon-danh-muc` | `GET /categories?type=`, tạo riêng `POST /categories` |
| 07, 22 | Lịch sử + trạng thái trống `07-lich-su`, `22-lich-su-trong` | `GET /transactions?month=&type=&categoryId=&walletId=&q=&page=&limit=`; gộp `GET /transfers?month=` nếu hiển thị chuyển tiền |
| 08 | Chi tiết giao dịch `08-chi-tiet-giao-dich` | `GET/PATCH/DELETE /transactions/:id` |
| 09–10 | Báo cáo, xu hướng `09-bao-cao`, `10-bao-cao-xu-huong` | `GET /stats/report?month=&walletId=`, `GET /stats/by-category`, `GET /stats/trend?months=6`, `GET /stats/daily`; xuất CSV `GET /export/transactions.csv?month=` (chỉ khi `features.csvExport`) |
| 11 | Ngân sách `11-ngan-sach` | `GET /budgets?month=` (`overall` + `items`, `status` ok/warning/exceeded), `POST/PATCH/DELETE /budgets`, `POST /budgets/copy` `{fromMonth, toMonth}` |
| 12–14 | Tiết kiệm, chi tiết mục tiêu, nạp tiền `12-tiet-kiem`, `13-chi-tiet-muc-tieu`, `14-nap-tien-muc-tieu` | `GET /saving-goals?status=`, `GET /saving-goals/:id`, `POST /saving-goals`, `POST /saving-goals/:id/deposit` `{amount, walletId, date?}`, `POST /saving-goals/:id/withdraw` `{walletId}` |
| 15 | Ví `15-vi` | `GET /wallets` (kèm `balance`, `totalBalance`), `POST/PATCH/DELETE /wallets/:id`, `POST /wallets/:id/restore` |
| 16 | Chuyển tiền `16-chuyen-tien` | `POST /transfers` `{fromWalletId, toWalletId, amount, …}`; ví nguồn phải đủ tiền (400 nếu không) |
| 17–18 | Định kỳ, tạo định kỳ `17-dinh-ky`, `18-tao-dinh-ky` | `GET/POST/PATCH/DELETE /recurring`, `POST /recurring/:id/pause|resume`, `GET /recurring/:id/preview?count=5` |
| 19 | Thông báo `19-thong-bao` | `GET /notifications?page=`, `POST /notifications/:id/read`, `POST /notifications/read-all` |
| 20, 20b | Cài đặt `20-cai-dat`, `20b-cai-dat-cuoi` | `GET/PATCH /me` (đổi tên), `POST /me/password` (trả token mới → lưu lại), `POST /auth/logout-all`, link hỗ trợ / điều khoản từ `config/public` |
| 21 | Xóa tài khoản `21-xoa-tai-khoan` | `DELETE /me` `{password}` |
| 23 | Đang tải `23-dang-tai` | Skeleton đúng bố cục, **không dùng spinner** (áp dụng mọi màn) |

Trường chính xác của từng body / response: xem Swagger (`/docs`) hoặc `mobile/openapi.json`.

### Trợ lý AI (Giai đoạn 4, ảnh `30-ai-*`)
| Màn | API |
|---|---|
| Danh sách cuộc trò chuyện, đổi tên / ghim / lưu trữ / xóa | `GET /ai/conversations[?archived=true]`, `POST /ai/conversations` (đạt giới hạn → tự lưu trữ cuộc cũ, trả `autoArchived`), `PATCH /ai/conversations/:id` `{title?, pinned?, archived?}`, `DELETE /ai/conversations/:id` |
| Chat | `GET /ai/conversations/:id` (tin nhắn + nháp), `POST /ai/conversations/:id/messages` `{text}` → `{userMessage, message, draft}`; bản stream SSE: `/messages/stream` (sự kiện `user → route → delta… → done \| error`) |
| Nháp giao dịch / ngân sách (viền nét đứt) | `POST /ai/drafts/:id/confirm` `{payload?}` (gửi bản đã sửa nếu người dùng sửa), `POST /ai/drafts/:id/cancel`. `payload.items[].possibleDuplicate` ≠ null → hiện "Có thể đã ghi rồi" |
| Hữu ích / Chưa đúng / "Ý bạn là…" | `POST /ai/messages/:id/feedback` `{rating: 1\|-1}`, `GET /ai/skills`, `POST /ai/messages/:id/reroute` `{skill}` |
| Cài đặt › Trợ lý AI | `GET /ai/usage` (lượt hôm nay / hạn mức), `GET/DELETE /ai/memory[/:id]`, `GET/PUT /ai/settings` `{shareExamples}` (hỏi đồng ý **một lần**, tắt được) |

Luật: trợ lý chỉ tạo nháp, **không bao giờ tự ghi**; mọi thao tác có hậu quả phải qua nút Xác nhận của người dùng.

### Quét hóa đơn (ĐÃ LÀM, ảnh `40-ocr-*`, code `app/lib/features/ocr/ocr_scan.dart`)
| Màn | API |
|---|---|
| Lối vào: menu nhấn giữ ＋ ("Quét hóa đơn · Mới"), nút quét ở Ghi giao dịch | ẩn khi `GET /config/public` → `ai.ocr.enabled = false` |
| Sheet chọn ảnh / hết lượt | `GET /ai/usage` → `ocrToday`, `ocrDailyLimit`, `resetAt`. Ảnh thu nhỏ trên máy theo `ai.ocr.maxSide` (`image_picker`) |
| Đọc ảnh | `POST /ai/conversations/:id/images` multipart `image` (jpeg/png/webp ≤10MB) → `{userMessage, message, draft, ocr}`. `draft` = nháp giao dịch như chat; `ocr` = phần đọc được (`kind, amount, date, merchant, sender, recipient, note, bank, reason, ms`) để hiện cả khi không đọc ra số tiền (`reason`: `no_amount` / `not_document` / `error`) |
| Lưu / Sửa / Hủy | Lưu = `POST /ai/drafts/:id/confirm` (khóa nút khi `walletGuessed` hoặc chưa có danh mục); Sửa = mở Ghi giao dịch điền sẵn, lưu bằng confirm có `payload`; Hủy = `/cancel` |
| Lỗi | 403 `FEATURE_DISABLED` (`feature: "ocr"`), 429 `AI_OCR_DAILY_LIMIT` (`Retry-After`), 400 ảnh lỗi / sai định dạng |

Thu hay chi do máy chủ quyết: người nhận trùng tên tài khoản → khoản thu. Ảnh không lưu trên máy chủ; ảnh không tính vào hạn mức tin nhắn chat.

### Số điện thoại (ĐÃ LÀM, ảnh `50-sdt-*`, code `app/lib/features/phone/phone_verify.dart`, Android `android/app/src/main/kotlin/vn/thuchi/app/sms/SmsChannel.kt`)
| Màn | API |
|---|---|
| Lối vào: Cài đặt › nhóm **Tài khoản** (Đổi mật khẩu, Số điện thoại "Chưa gắn" / "0912 ••• 678 · Đã xác thực"); Quên mật khẩu › chọn Qua email / Qua số điện thoại | ẩn khi `GET /config/public` → `phoneOtp.enabled = false` (Quên mật khẩu giữ màn chỉ email). `GET /me` → `phone`, `phoneVerifiedAt` |
| Gắn số (nhập số + mật khẩu hiện tại) | `POST /me/phone/verifications {phone, password}` → `{verificationId, phone, code, expiresAt, smsLink:{android, ios}}`. 400 sai mật khẩu / số không hợp lệ, 409 `PHONE_TAKEN` (lỗi đỏ dưới ô số) / `PHONE_ALREADY_LINKED`, 429 `PHONE_RATE_LIMIT`, 403 `FEATURE_DISABLED` |
| Gửi yêu cầu xác nhận → Đang chờ → Đã xác thực / Mã đã hết hạn | `GET /me/phone/verifications/:id` mỗi 2 giây: `PENDING` · `VERIFIED` (tải lại `/me`) · `EXPIRED` (Lấy mã mới = xin phiên mới) · `FAILED` (số vừa bị tài khoản khác gắn → về ô số, lỗi đỏ). Quá 1 phút chưa xong: gợi ý kiểm tra SIM + Gửi lại yêu cầu |
| Gỡ số (sheet cần mật khẩu) | `DELETE /me/phone {password}` → 204 |
| Quên mật khẩu qua số điện thoại | `POST /auth/forgot-password/phone {phone}` (không cần đăng nhập, luôn trả phiên) → hỏi `GET /auth/forgot-password/phone/:id` → `VERIFIED` → `POST /auth/reset-password/phone {verificationId, newPassword}` → 204, về Đăng nhập kèm thông báo. 400 "Phiên xác thực không hợp lệ hoặc đã hết hạn" |

Luồng xác nhận **không hiện số điện thoại nào** (không số máy cổng, không số của người dùng): số chỉ có trong ô nhập và dòng Cài đặt (đã che). Nội dung tin là 6 số `code` ("Nội dung xác nhận"); số người nhận lấy từ `smsLink`, API cố ý không trả thành trường riêng.

- **App phát hành bằng APK, không lên Google Play** → Android được dùng quyền `SEND_SMS` và **tự gửi tin**: bấm Gửi yêu cầu xác nhận → (lần đầu) thẻ lý do của app + hộp quyền hệ thống `SEND_SMS` + `READ_PHONE_STATE` → máy 2 SIM thì sheet "Gửi từ SIM nào?" (khe + tên nhà mạng, không số) → `SmsManager` của SIM đã chọn (`createForSubscriptionId` từ API 31, `getSmsManagerForSubscriptionId` trước đó) → màn chờ "Đã gửi yêu cầu". Từ chối quyền → mở ứng dụng Tin nhắn soạn sẵn bằng `smsLink.android` (`url_launcher`) + link Cấp quyền trong Cài đặt. MethodChannel `vn.thuchi.app/sms/methods`: `hasPermission`, `requestPermission`, `listSims` → `[{subscriptionId, slot, carrierName}]`, `sendSms {subscriptionId|null, destination, body}` → bool (chờ báo "đã gửi" của nhà mạng tối đa 30 giây), `openAppSettings`.
- **iOS**: mở khung soạn tin của hệ thống bằng `smsLink.ios`, người dùng tự bấm Gửi. Web / nền khác: `url_launcher` như iOS.
- Thử khi chạy local: giả lập máy cổng nhận tin bằng `curl -X POST http://localhost:3000/api/sms-gateway/inbound -H 'content-type: application/json' -H 'x-gateway-key: dev-gw-key' -d '{"from":"<số>","text":"<mã>"}'`.

---

## 6. Yêu cầu chất lượng (Definition of Done cho mỗi màn)

- Khớp mockup: bố cục, chữ, màu, khoảng cách theo `design/tokens.md`. Chụp màn hình app đặt cạnh ảnh mockup trong PR.
- Đủ 4 trạng thái: đang tải (skeleton), có dữ liệu, trống, lỗi (có nút Thử lại).
- Dùng dữ liệu thật từ API với tài khoản `demo@thuchi.vn`, không dùng dữ liệu giả cứng trong code.
- Xử lý lỗi theo bảng mục 4; không crash khi mất mạng.
- Không lỗi `flutter analyze`; có widget test cho logic định dạng tiền/ngày và cho ít nhất luồng chính của màn.
- Chạy được trên Android emulator; iOS simulator nếu có máy Mac.

---

## 7. Ngoài phạm vi (chưa làm, đừng dựng)

- Quét QR thanh toán / mở app ngân hàng (`docs/research/qr-thanh-toan.md`) — cần mockup riêng được duyệt trước.
- Push notification (FCM) — backend chưa có endpoint đăng ký thiết bị.
- Vay / nợ.
- Giọng nói → chữ (màn `30-ai-13`, "bản sau").
- Mọi màn **không có mockup**: phải có mockup được duyệt trước khi dựng.

---

## 8. Chia việc gợi ý

Mỗi người nhận một nhánh con từ `app-mobile`, làm xong mở **Pull Request vào `app-mobile`** (không push thẳng vào `app-mobile` hay `main`). Tên nhánh: `mobile/<mã-việc>-<mô-tả>`, vd `mobile/M2-auth`.

| Mã | Việc | Phụ thuộc | Màn |
|---|---|---|---|
| **M1** | Khung dự án: `flutter create`, cấu trúc thư mục, theme từ `tokens.md` (ColorScheme + ThemeExtension AppColors/Spacing/Radius/Shadows/Motion, TextTheme Be Vietnam Pro), go_router + tab bar + nút ＋, dio client (interceptor token + bảng lỗi mục 4), formatter tiền/ngày VN, widget dùng chung (card, bong bóng icon, chip, skeleton, empty/error state, bottom sheet) | — (**làm trước, ~3–4 ngày**) | |
| **M2** | Xác thực + khởi động: `config/public`, màn bảo trì, bắt cập nhật, đăng nhập, đăng ký, quên mật khẩu + OTP, lưu token, đăng xuất | M1 | 01, 02, 03 |
| **M3** | Trang chủ + Thông báo | M1 | 04, 19 |
| **M4** | Ghi giao dịch: form, chọn danh mục, chọn ví, menu nhấn giữ ＋, mẫu nhập nhanh, chuyển tiền | M1 | 05, 05b, 06, 16 |
| **M5** | Lịch sử + chi tiết / sửa / xóa giao dịch, lọc, tìm kiếm | M1, M4 (dùng lại form) | 07, 08, 22 |
| **M6** | Báo cáo + xu hướng (fl_chart), xuất CSV | M1 | 09, 10 |
| **M7** | Ngân sách + Tiết kiệm (mục tiêu, nạp, rút) | M1 | 11, 12, 13, 14 |
| **M8** | Ví + Định kỳ | M1 | 15, 17, 18 |
| **M9** | Cài đặt, đổi tên / mật khẩu, đăng xuất mọi nơi, xóa tài khoản, link hỗ trợ / pháp lý | M1, M2 | 20, 20b, 21 |
| **M10** | Trợ lý AI (Giai đoạn 4): 3 lối vào, danh sách, chat, thẻ nháp + sheet sửa, phản hồi, hết lượt, bảo trì, Cài đặt › Trợ lý AI | M1–M5 | 30-ai-* |

Giai đoạn: **1** = M1 → **2** = M2, M3, M4 song song → **3** = M5–M9 song song → **4** = M10 → kiểm thử tổng trên máy thật, merge `app-mobile` vào `main`.

Thắc mắc về API: đọc `backend/README.md` trước; thiếu endpoint hoặc API trả sai so với tài liệu thì mở issue trên GitHub kèm request/response, **không tự sửa backend trong nhánh mobile**.
