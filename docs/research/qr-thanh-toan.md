# Nghiên cứu khả thi: Quét QR → mở app ngân hàng điền sẵn → ghi khoản chi

Ngày nghiên cứu: **2026-10-08**. Ký hiệu độ tin cậy:
- **[V]** = đã tự kiểm chứng (gọi HTTP thật / đọc tài liệu gốc) ngày 2026-10-08.
- **[D]** = theo tài liệu/changelog chính thức của bên thứ ba, chưa thử trên thiết bị.
- **[I]** = suy luận, cần test trên máy thật.

> Lưu ý quan trọng: chưa test nào được chạy trên điện thoại thật có cài app ngân hàng. "Autofill" bên dưới nghĩa là **deeplink có mang dữ liệu QR đã ký** — việc app ngân hàng hiển thị màn hình chuyển tiền điền sẵn là theo changelog của VietQR.io/Casso **[D]**, phải xác minh bằng thiết bị trước khi release.

---

## TL;DR

| Hạng mục | Kết luận |
|---|---|
| Quét + parse VietQR (NAPAS) | **100% làm được**, offline, có thư viện MIT (Dart + JS). |
| Mã merchant VNPAY-QR / ví (mã chỉ dành cho ví) | **Không** đổi được thành số tài khoản → không điền sẵn; chỉ fallback "mở app + quét lại / chọn ảnh". |
| Mở app ngân hàng (chỉ mở) | **Làm được** với ~37 app (bảng scheme/package bên dưới) **[V]**. |
| Mở app **điền sẵn** (TK + tiền + nội dung) | **Chỉ 5 app**: MB Bank, VietinBank iPay, BIDV SmartBanking, ACB ONE, OCB OMNI — **qua `dl.vietqr.io` (Casso) ký số**. Mình **không tự ký được** → phụ thuộc dịch vụ Casso miễn phí (Public tier). **[V]** ở mức HTTP, **[D]** ở mức hành vi app. |
| Vietcombank, Techcombank, VPBank, TPBank, Agribank, Sacombank… | **Chỉ mở app** (hoặc không có deeplink public). Cách gần nhất: lưu **ảnh VietQR động** (có số tiền + nội dung) → user "Quét QR → chọn ảnh" trong app ngân hàng → màn xác nhận điền đủ (+~3 chạm). |
| Theo tiêu chí user chốt ("điền đủ, chỉ bấm xác nhận") | Mức A: **5 app** (MB, VietinBank, BIDV, ACB, OCB). Mức B (điền thiếu): **không có**. Mức C: còn lại. Độ phủ ước lượng **~38–41%** theo lượt cài app (proxy, số liệu cũ) — chi tiết §2.3e. |
| Biết giao dịch thành công? | **Không có callback** cho chuyển khoản cá nhân. Dùng trạng thái `pending` + người dùng xác nhận khi quay lại. Tuỳ chọn nâng cao: đọc notification (Android) hoặc webhook SePay/Casso (phải liên kết TK người dùng). |
| Pháp lý | Mình chỉ "chuyển giao" sang app ngân hàng, không giữ/chuyển tiền → **[I]** không thuộc diện dịch vụ trung gian thanh toán (NĐ 52/2024). Không dùng logo VietQR (thương hiệu của NAPAS) khi chưa xin phép. |

Design tham chiếu ("Mở BIDV — BIDV sẽ điền sẵn thông tin") **khớp đúng** với khả năng hiện có: BIDV là 1 trong 5 app autofill.

---

## 1. Định dạng QR thanh toán ở VN

### 1.1 VietQR (NAPAS, EMVCo MPM) — parse được thành tài khoản

Chuẩn kỹ thuật: EMVCo Merchant-Presented QR + Tiêu chuẩn cơ sở NHNN về QR (QĐ 1928/QĐ-NHNN, TCCS 03:2018/NHNN). Tài liệu gốc NAPAS không public; cấu trúc dưới đây **[V]** được kiểm chứng bằng cách giải mã payload thật do `dl.vietqr.io` sinh ra (xem §2):

```
00020101021238560010A0000007270126000697041501121133666688880208QRIBFTTA5303704540420005802VN62060802ck63047CE1
```

| Tag | Giá trị ví dụ | Ý nghĩa |
|---|---|---|
| `00` | `01` | Payload format indicator |
| `01` | `11` / `12` | **11 = QR tĩnh** (không có số tiền), **12 = QR động** (có số tiền/đơn hàng) |
| `38` | (template) | Merchant Account Info – NAPAS |
| `38.00` | `A000000727` | GUID NAPAS → nhận diện VietQR |
| `38.01` | (template) | Beneficiary organization |
| `38.01.00` | `970415` | **BIN ngân hàng** (6 số; ví dụ MoMo mới `971025`, BVBank `970454`, CAKE `546034`, Timo `963388`) |
| `38.01.01` | `113366668888` | **Số tài khoản** (hoặc số thẻ 9704… nếu dịch vụ QRIBFTTC) |
| `38.02` | `QRIBFTTA` / `QRIBFTTC` | Chuyển nhanh Napas247 **đến tài khoản** / **đến thẻ** |
| `53` | `704` | VND |
| `54` | `2000` | **Số tiền** (tuỳ chọn) |
| `58` | `VN` | Quốc gia |
| `59`, `60` | | Tên/thành phố merchant — **thường không có** trong QR cá nhân → QR thường **không chứa tên chủ TK** |
| `62.08` | `ck` | **Nội dung chuyển khoản** (purpose). Giới hạn thực tế ~25–50 ký tự tuỳ bank, không dấu (VietQR.io: 40 ký tự từ v1.1) |
| `63` | `7CE1` | CRC-16/CCITT-FALSE (poly 0x1021, init 0xFFFF) tính trên toàn chuỗi kể cả `6304` |

Thuật toán parse: TLV đệ quy (2 ký tự ID + 2 ký tự độ dài + value), validate CRC, nếu `38.00 == A000000727` → lấy `38.01.00` (BIN) và `38.01.01` (TK). Map BIN → ngân hàng bằng `https://api.vietqr.io/v2/banks` (65 ngân hàng, có `bin`, `code`, `shortName`, `logo`, `transferSupported`, `lookupSupported`) **[V]**.

### 1.2 Các loại QR khác

| Loại QR | Nhận diện | Parse ra STK chuyển được? | Ghi chú |
|---|---|---|---|
| VietQR của app ngân hàng (cá nhân/hộ KD) | tag 38, GUID `A000000727` | **Có** | Trường hợp phổ biến nhất ở quán cà phê. |
| MoMo / ZaloPay "QR đa năng" / QR nhận tiền | tag 38 VietQR, BIN `970454` (BVBank) hoặc `971025` (MoMo) | **Có** (là TK định danh trỏ về ví) | Nguồn: README `vietnam-qr-pay` **[D]**. |
| Loa/QR POS động của ngân hàng (VietQR động) | tag 38, `01=12`, có tag 54 | **Có**, nhưng là QR theo đơn → số tiền cố định | Không nên cho user sửa số tiền khi QR động có tag 54. |
| VNPAY-QR (merchant) | tag 26, GUID `A000000775` + merchant ID | **Không** | Chỉ app có tích hợp quét VNPAY-QR thanh toán được; không có STK. **[D]** |
| QR merchant riêng của ví (MoMo/ShopeePay/ZaloPay cửa hàng, không phải VietQR) | GUID khác / URL | **Không** | **[I]** Fallback: "Mở app ví/ngân hàng để quét". |
| QR chứa URL (link thanh toán web) | bắt đầu `http` | Không | Mở trình duyệt hoặc báo không hỗ trợ. |

### 1.3 Thư viện mã nguồn mở

| Thư viện | Ngôn ngữ | License | Ghi chú |
|---|---|---|---|
| [`vietqr_core`](https://pub.dev/packages/vietqr_core) 0.2.5+1 | Dart | MIT | `VietQr.decode()`, publisher verified v4g.space, ít người dùng, cập nhật ~12 tháng trước. |
| [`vietqr_gen`](https://pub.dev/packages/vietqr_gen) 1.2.0 | Dart | MIT | `VietQR.parse()` trả bank/account/amount/message/isDynamic, zero-dependency, ~13 tháng chưa cập nhật. |
| [`vietnam-qr-pay`](https://github.com/xuannghia/vietnam-qr-pay) | TS/JS | MIT | Decode/encode VietQR + VNPayQR + MoMo/ZaloPay; dùng tốt ở NestJS. 173★. |
| [`vn-qr-pay`](https://github.com/hunghg255/vn-qr-pay) | TS | (kiểm tra repo) | Fork/biến thể tương tự. |
| [`vietqr-parser`](https://github.com/thanhtinhpas1/vietqr-parser) | Go | (kiểm tra repo) | Tham khảo. |

Khuyến nghị: **tự viết parser TLV ~100 dòng Dart** (đơn giản, không phụ thuộc lib ít maintain), dùng `vietnam-qr-pay` làm test oracle phía backend.

---

## 2. Mở app ngân hàng với dữ liệu điền sẵn

### 2.1 Không có chuẩn deeplink công khai

- NAPAS **không** công bố chuẩn deeplink app-to-app. VietQR.io mô tả `vietqr://pay?ba=&am=&tn=&bn=&url=` chỉ là **"kỳ vọng"**, chưa ngân hàng nào hỗ trợ ([VietQR deeplink docs](https://www.vietqr.io/danh-sach-api/deeplink-app-ngan-hang/)) **[D]**.
- Autofill hiện có đều là **hợp tác riêng** giữa ngân hàng và một trung gian (Casso/payOS, ZaloPay, Tingee…) với **chữ ký số** của trung gian. Ví dụ ZaloPay API "Get List Bank Deeplinks" trả `deep_link` + `is_auto_fill` (MSB `msbmbank://applink` true, BIDV `bidv.smartbanking.partner://payment` true, VIB `myvib2://` false), cần `app_id`/`mac`/`order_token` merchant ([ZaloPay docs](https://docs.zalopay.vn/docs/guides/payment-acceptance/zalopay-emvco-qr/intro/)) **[D]**.
- Thread voz kết luận tương tự: không có cách public, phải hợp tác ngân hàng ([voz](https://voz.vn/t/lam-the-nao-de-mo-app-ngan-hang-bang-link-va-dien-du-cac-thong-tin-can-chuyen-khoan.1060532/)).

### 2.2 `dl.vietqr.io` (Casso) — con đường khả thi duy nhất không cần hợp đồng

API danh sách app: `https://api.vietqr.io/v2/android-app-deeplinks`, `https://api.vietqr.io/v2/ios-app-deeplinks` → 37 app, có trường **`autofill`** (1 = hỗ trợ) **[V]**. App `autofill=1`: `icb`, `bidv`, `ocb`, `acb`, `mb`.

Changelog VietQR.io ([link](https://vietqr.io/en/changelog/)) **[D]**: OCB autofill (v2.12, 2024-05-28), thêm `bn` + `url` và ACB autofill (v2.15, 2025-10-31), BIDV (v2.16, 2026-01-09), VietinBank (v2.17, 2026-02-13), MB (v2.18, 2026-07-31).

**Phát hiện then chốt [V] (curl 2026-10-08, User-Agent Android/iOS):**

```
https://dl.vietqr.io/pay?app={appId}&ba={STK}@{bankCode|BIN}&am={số tiền}&tn={nội dung}&bn={tên}&url={https callback}
```

- **Bắt buộc có `url` là `https://…`** thì server mới sinh deeplink autofill. Thiếu `url` hoặc `url=myapp://…` → chỉ trả deeplink mở app trơn.
- `ba` nhận mã ngân hàng **chữ thường** (`@bidv`, `@vcb`, `@icb`, `@momo`) hoặc BIN (`@970418`). Chữ hoa (`@BIDV`) → lỗi `{"message":"invalid acqId! mb"}`.
- Không có `am` → server sinh QR tĩnh (`01=11`) vẫn ký được.
- Android: HTTP `301` → `Location: intent://…#Intent;scheme=…;package=…;end`.
- iOS: HTTP 200 HTML, JS đặt `window.location.href = DEEPLINK` rồi fallback App Store sau ~2.6s.
- Người nhận có thể khác ngân hàng với app nguồn (VD mở MB để chuyển tới TK VCB) — server vẫn ký.

Deeplink thực tế server trả về (rút gọn, chữ ký là của Casso):

| App | Deeplink autofill (Android `intent://` host/path; iOS dùng cùng path với scheme) |
|---|---|
| MB Bank | `mbbank://applink?targetPage=QRPay&source=Casso&qrContent=<VietQR>&callbackurl=<url>&timestamp=…&signature=…` |
| VietinBank iPay | `vietinbankipay://host.qrTransfer?targetPage=QRPay&source=VietQR_Payment&qrContent=<VietQR>&callbackurl=<url>&timestamp=…&signature=…` |
| BIDV SmartBanking | `bidv.smartbanking.partner://payment?source=CASVIETQR&data=<mã hoá>&signature=…` |
| ACB ONE | `acbone://CASSO/external/transactions/v1/qrcode?redirectUrl=<url>&timeStamp=…&signature=…&qrCode=<VietQR>` |
| OCB OMNI | `newomni-app://CASSO/<VietQR>?redirect_url=<url>&timestamp=…&signature=…` |

Hệ quả:
- **Không thể tự sinh** các link này (cần private key của Casso, ký theo timestamp) → phải gọi `dl.vietqr.io` mỗi lần, ngay trước khi mở app (chữ ký có timestamp, có thể hết hạn **[I]**).
- `url` (callback https) được truyền cho ngân hàng → có thể dùng **App Link/Universal Link của app mình** để ngân hàng mở lại app sau khi chuyển xong **[I]** — ngân hàng có gọi lại hay không, có kèm trạng thái hay không: chưa rõ.
- Dữ liệu (STK người nhận, số tiền, nội dung) đi qua server Casso → ghi vào chính sách quyền riêng tư.
- Dịch vụ Public tier miễn phí, không đăng ký, SLA 99.5% ([vietqr.io](https://www.vietqr.io/en/)); **không có hợp đồng/điều khoản riêng** cho dùng thương mại → rủi ro thay đổi/chặn bất cứ lúc nào. Nên liên hệ Casso nếu đưa vào production quy mô lớn.
- Phản hồi iOS là HTML (không phải API) → nếu backend parse `const DEEPLINK = '…'` thì dễ vỡ; phương án an toàn: mở URL `dl.vietqr.io` trực tiếp trong trình duyệt ngoài.

Một số cổng (VTC Pay, Tingee "Pay by Bank", MoMo payment) cũng có deeplink mở app nhưng gắn với **đơn hàng merchant** (cần hợp đồng, tiền vào TK merchant) → **không áp dụng** cho chuyển khoản tới quán bất kỳ. ([Tingee](https://developers.tingee.vn/docs/deeplink/), [MoMo onetime](https://developers.momo.vn/v3/docs/payment/api/wallet/onetime/)).

### 2.3 Bảng ngân hàng theo tiêu chí "app mở ra đã điền đủ, user chỉ bấm xác nhận"

Tiêu chí (user chốt): app ngân hàng mở ra phải có sẵn **ngân hàng + số TK người nhận (tên do bank tự tra), số tiền, nội dung**; user chỉ xác nhận + xác thực.

3 mức:
- **A — Điền đủ, chỉ cần xác nhận**
- **B — Điền thiếu** (vd mở đúng màn chuyển tiền nhưng thiếu số tiền/nội dung)
- **C — Chỉ mở app** (user tự nhập hoặc tự quét)

Cột "Kiểm chứng": **HTTP [V]** = đã gọi `dl.vietqr.io` ngày 2026-10-08 và thấy deeplink chứa đủ BIN + STK + số tiền + nội dung (chuỗi VietQR `qrContent`/`qrCode` hoặc `data` mã hoá); **App [D]** = hành vi trong app theo changelog/tài liệu, **chưa test trên máy thật**; **[V-API]** = trường `autofill` trong `api.vietqr.io/v2/*-app-deeplinks`. Lượt cài/tháng là số liệu SensorTower do VietQR.io cung cấp (cũ, ghi T8/2022 trên trang docs) — chỉ dùng làm proxy thị phần.

| Ngân hàng | App (appId) | Android scheme / package | iOS scheme | Mức | Kiểm chứng (nguồn) | Cài/tháng Android · iOS |
|---|---|---|---|---|---|---|
| MB | MB Bank (`mb`) | `mbbank://` / `com.mbmobile` | `mbbank://` | **A** (qua dl.vietqr.io) | HTTP [V] payload `qrContent` đủ 4 trường; [V-API] autofill=1; App [D] [changelog v2.18 2026-07-31](https://vietqr.io/en/changelog/) | 500k · 400k |
| VietinBank | iPay (`icb`) | `vietinbankipay://` / `com.vietinbank.ipay` | `vietinbankipay://` | **A** | HTTP [V]; [V-API]; App [D] changelog v2.17 2026-02-13 | 200k · 200k |
| BIDV | SmartBanking (`bidv`) | `bidv.smartbanking.partner://payment` / `com.vnpay.bidv` | `bidv.smartbanking.partner://` | **A** | HTTP [V] (`data` mã hoá — không đọc được nội dung, suy ra đủ trường **[I]**); [V-API]; App [D] changelog v2.16 + [ZaloPay is_auto_fill=true](https://docs.zalopay.vn/docs/guides/payment-acceptance/zalopay-emvco-qr/intro/) | 200k · 100k |
| ACB | ACB ONE (`acb`) | `acbone://` / `mobile.acb.com.vn` | `acbone://` | **A** | HTTP [V] `qrCode` đủ 4 trường; [V-API]; App [D] changelog v2.15 2025-10-31 | 70k · 60k |
| OCB | OCB OMNI (`ocb`) | `newomni-app://` / `vn.com.ocb.awe` | `newomni-app://` | **A** | HTTP [V] VietQR trong path; [V-API]; App [D] changelog v2.12 2024-05-28 | 80k · 60k |
| MSB | MSB mBank | `msbmbank://applink` | — | A **chỉ với merchant ZaloPay**; với mình: **C/Unknown** | [ZaloPay docs](https://docs.zalopay.vn/docs/guides/payment-acceptance/zalopay-emvco-qr/intro/) [D] | — |
| Techcombank | TCB Mobile (`tcb`) | `tcb://applink` / `vn.com.techcombank.bb.app` | `tcb://` | **C** (A riêng với Zalo theo [voz](https://voz.vn/t/lam-the-nao-de-mo-app-ngan-hang-bang-link-va-dien-du-cac-thong-tin-can-chuyen-khoan.1060532/), không public **[I]**) | HTTP [V] redirect không mang dữ liệu dù có `url`; [V-API] autofill=0 | 200k · 300k |
| Vietcombank | VCB Digibank (`vcb`) | `vietcombankmobile://` / `com.VCB` | `vietcombankmobile://` | **C** | HTTP [V]; [V-API] autofill=0; [VietQR docs](https://www.vietqr.io/danh-sach-api/deeplink-app-ngan-hang/) ghi rõ VCB "chưa thể tự động điền" | 300k · 200k |
| VPBank | NEO (`vpb`) | `vpbankneo://` / `com.vnpay.vpbankonline` | `vpbankneo://` | **C** | HTTP [V]; [V-API] | 200k · 200k |
| Agribank | E-Mobile (`vba`) | `agribankmobile://` / `com.vnpay.Agribank3g` | `agribankmobile://` | **C** | HTTP [V]; [V-API] | 300k · 100k |
| TPBank | TPBank Mobile (`tpb`) | `hydro://onboarding` / `com.tpb.mb.gprsandroid` | `hydro://` | **C** | HTTP [V]; [V-API] | 80k · 90k |
| CAKE | CAKE (`cake`) | `cake.vn://` / `xyz.be.cake` | — | **C** | HTTP [V]; [V-API] | 100k · 90k |
| VIB | MyVIB 2.0 (`vib-2`) | `myvib2://myvib2.com.vn/data` / `com.vib.myvib2` | `myvib2://` | **C** | [V-API]; ZaloPay is_auto_fill=false | 30k · 40k |
| LPBank | Liên Việt 24h (`lpb`) | `lv24h://` / `vn.com.lpb.lienviet24h` | — | **C** | [V-API] | 70k · 60k |
| Timo | Timo (`timo`) | `plus://` / `io.lifestyle.plus` | — | **C** | [V-API] | 70k · 60k |
| HDBank | (`hdb`) | `hdbankmobile://` / `com.vnpay.hdbank` | — | **C** | [V-API] | 30k · 30k |
| VIB (cũ) | MyVIB (`vib`) | `myvib://vib.com.vn/data` / `com.vn.vib.mobileapp` | — | **C** | [V-API] | 30k · 40k |
| SHB | SAHA (`shb`) | `shbmobile://` / `vn.shb.saha.mbanking` | — | **C** | [V-API] | 20k · 20k |
| SeABank | SeAMobile (`seab`) | `seamobile://app` / `vn.com.seabank.mb1` | — | **C** | [V-API] | 20k · 20k |
| Shinhan | SOL (`shbvn`) | `shinhanglbvnbank://` / `com.shinhan.global.vn.bank` | — | **C** | [V-API] | 20k · 20k |
| SCB | (`scb`) | `scbmobilebanking://` / `com.vnpay.SCB` | — | **C** | [V-API] | 10k · 20k |
| Nam A | (`nab`) | `deeplinkapp://nab/softotp` / `ops.namabank.com.vn` | — | **C** | [V-API] | 9k · 0 |
| ABBank | (`abb`) | `abbankmobile://` / `vn.abbank.retail` | — | **C** | [V-API] | 9k · 10k |
| Eximbank | EDigi (`eib`) | `eximbankmobile://` / `com.vnpay.EximBankOmni` | — | **C** | [V-API] | 7k · 9k |
| Co-opBank | (`coopbank`) | `coopbankmobile://` / `com.vnpay.coopbank` | — | **C** | [V-API] | 6k · 0 |
| PVcomBank | (`pvcb`) | `pvcombankapp://` / `com.pvcombank.retail` | — | **C** | [V-API] | 5k · 9k |
| Woori, KienlongBank, BaoViet, VietBank, VietABank, NCB, ACB Biz, MBV, Public Bank, Saigonbank, CIMB, TPBank QuickPay | xem §2.3b | xem §2.3b | — | **C** | [V-API] | ~0 |
| Sacombank | Sacombank Pay | — | — | **C/Unknown** (không có trong danh sách VietQR.io) | — | — |
| MoMo / ZaloPay (P2P) | — | `momo://` chỉ cho payment merchant | — | **C/Unknown** | [MoMo docs](https://developers.momo.vn/v3/docs/payment/api/wallet/onetime/) [D] | — |

**Mức B (điền thiếu): không tìm thấy ngân hàng nào** có deeplink public mở màn chuyển tiền với một phần dữ liệu. Thực tế chỉ có 2 trạng thái: A (5 bank, qua Casso) hoặc C (còn lại). Lưu ý cả 5 bank mức A đều chỉ đạt A **khi đi qua `dl.vietqr.io` với `url=https://…`**; tự gọi scheme trơn (`mbbank://`) chỉ là C.

#### 2.3b Scheme các app nhỏ (mức C) [V]
`wvbs://` `vn.com.woori.smart` · `ksbank://ksbank.co` `com.sunshine.ksbank` · `baovietmobile://` `com.vnpay.bvbank` · `vietbankmobilebanking://` `com.vnpay.vietbank` · `vabmobilebanking://` `com.vn.vietbankomni` · `ncbizimobile://` `com.ncb.bank` · `abaapp://` `com.acb.acbb.prod` · `oceanbankmobilebanking://` `com.aci.ocean.mobile` · `publicbankmobile://` `com.vnpay.publicbank` · `Sgbmobile://` `com.vnpay.sgbank` · `cimb://` `vn.cimbbank.octo` · `qpaymobile://` `com.tpbankquickpay`.

(iOS scheme "—" = chưa trích xuất; lấy bằng GET `dl.vietqr.io/pay?app=…` với UA iPhone, đọc `const DEEPLINK`.)

### 2.3c Ngân hàng đạt mức A — định dạng link cụ thể

Link mình tạo (giống nhau cho cả 5, chỉ đổi `app`):

```
https://dl.vietqr.io/pay?app={mb|icb|bidv|acb|ocb}
  &ba={STK}@{bankCode chữ thường hoặc BIN}     # vd 0123456789@vcb hoặc 0123456789@970436
  &am={số tiền, số nguyên VND}
  &tn={nội dung, không dấu, URL-encode}
  &bn={tên người nhận, tuỳ chọn}
  &url=https://{domain-của-mình}/r/{expenseId}   # BẮT BUỘC https, thiếu → chỉ mở app
```

Ví dụ đã test [V]: `https://dl.vietqr.io/pay?app=mb&ba=0123456789@bidv&am=1000&tn=An%20trua%20ca%20phe&url=https://example.com` → Android 301 tới
`intent://applink/?targetPage=QRPay&source=Casso&qrContent=00020101021238540010A00000072701240006970418011001234567890208QRIBFTTA5303704540410005802VN62180814An%20trua%20ca%20phe63044A87&callbackurl=https%3A%2F%2Fexample.com&timestamp=…&signature=…#Intent;scheme=mbbank;package=com.mbmobile;end`

Deeplink cuối cùng mà ngân hàng nhận (do Casso ký — mình không tự tạo được):

| App | Deeplink |
|---|---|
| MB Bank | `mbbank://applink?targetPage=QRPay&source=Casso&qrContent=<VietQR>&callbackurl=<url>&timestamp=<ms>&signature=<RSA b64>` |
| VietinBank iPay | `vietinbankipay://host.qrTransfer?targetPage=QRPay&source=VietQR_Payment&qrContent=<VietQR>&callbackurl=<url>&timestamp=<ms>&signature=<…>` |
| BIDV SmartBanking | `bidv.smartbanking.partner://payment?source=CASVIETQR&data=<payload mã hoá>&signature=<…>` |
| ACB ONE | `acbone://CASSO/external/transactions/v1/qrcode?redirectUrl=<url>&timeStamp=<ms>&signature=<…>&qrCode=<VietQR>` |
| OCB OMNI | `newomni-app://CASSO/<VietQR>?redirect_url=<url>&timestamp=<ms>&signature=<…>` |

Tên người nhận: không nằm trong VietQR; app ngân hàng tự tra tên qua Napas ở màn xác nhận (hành vi chuẩn khi quét VietQR **[I]**). Như vậy tiêu chí "điền tên/ngân hàng người nhận" được đáp ứng gián tiếp.

### 2.3d Ngân hàng mức C — cách đến gần mức A nhất

Xếp theo mức gần tiêu chí:

1. **Ảnh QR động (VietQR có tag 54 số tiền + 62.08 nội dung) → "Quét QR → chọn ảnh từ thư viện" trong app ngân hàng.** App mình sinh ảnh VietQR động từ STK + số tiền + nội dung user nhập (`qr_flutter`), lưu vào Photos/Gallery, rồi mở app ngân hàng (scheme mức C). User: mở mục Quét QR → chọn ảnh → **màn xác nhận đã điền đủ** (STK, tên do bank tra, số tiền, nội dung) → xác nhận. Thêm ~3 chạm so với mức A. Đây là cách chuẩn của VietQR, mọi app thành viên Napas đều quét được VietQR; khả năng "chọn ảnh từ thư viện" có ở hầu hết app lớn **[I — cần test từng app]**; đã được dùng thực tế ([PR #1038](https://github.com/henryvn2004-arch/app-tuvi/pull/1038)). Lưu ý: VietQR.io từng sửa lỗi VCB quét QR khoá số tiền (changelog v2.11) → QR phải sinh đúng chuẩn Napas (`01=12` khi có số tiền).
2. **Link VietQR có số tiền mở thẳng màn chuyển khoản**: **không tồn tại** cho các bank mức C — đã kiểm chứng `dl.vietqr.io` với đủ `ba/am/tn/url` vẫn chỉ trả scheme trơn (vd `intent://#Intent;scheme=vietcombankmobile;package=com.VCB;end`) [V]. Link ảnh `img.vietqr.io/image/...` chỉ là ảnh, không mở app.
3. **Chia sẻ ảnh QR (share sheet) vào app ngân hàng**: app ngân hàng thường không nhận ảnh share **[I]**; không đáng tin.
4. **Mở app + copy sẵn STK** (clipboard) và hiển thị số tiền/nội dung để user dán: luôn làm được nhưng xa tiêu chí nhất.

→ Với mức C, khuyến nghị UX: bottom sheet "VCB chưa hỗ trợ điền sẵn — Đã lưu mã QR có số tiền vào ảnh. Mở VCB → Quét QR → chọn ảnh" + nút "Mở Vietcombank".

### 2.3e Độ phủ theo tiêu chí "điền đủ"

Proxy duy nhất có số liệu: **lượt cài/tháng** trong API VietQR.io (SensorTower, cũ) [V-API, tính ngày 2026-10-08]:

| Nền tảng | Tổng 37 app | 5 app mức A | Tỷ lệ |
|---|---|---|---|
| Android | 2.566.000 | 1.050.000 | **~41%** |
| iOS | 2.138.000 | 820.000 | **~38%** |

Ước lượng: **~35–40% người dùng** (theo app ngân hàng chính) đạt mức A; MB Bank một mình chiếm ~20% (lớn nhất). **~60% còn lại** (Vietcombank, Techcombank, VPBank, Agribank, Sacombank, TPBank, CAKE, Timo…) chỉ đạt mức C, phải dùng cách "ảnh QR động → chọn ảnh". Không tìm được số liệu chính thức 2025–2026 về số người dùng app theo ngân hàng (chỉ có số cũ như MB 26,5 triệu KH năm 2023 — [vnbusiness](https://vnbusiness.vn/quy-mo-khach-hang-cua-nha-bang-tang-truong-than-toc.html)); con số trên là ước lượng, không phải thị phần chính thức. Mỗi người thường có nhiều app ngân hàng → tỷ lệ người dùng **có ít nhất 1** app mức A thực tế cao hơn **[I]**, nên cho user chọn app mặc định và gợi ý app mức A nếu máy có cài.

### 2.4 Fallback khi không autofill

1. **Mở app + copy sẵn**: copy STK vào clipboard, hiện sheet "Đã copy STK, số tiền 35.000đ — dán trong app ngân hàng". Làm được 100%.
2. **"Lưu ảnh QR" → chọn ảnh trong app ngân hàng**: app tự sinh VietQR động (tag 54 + 62.08) từ STK + số tiền user nhập, lưu vào thư viện ảnh, rồi mở app ngân hàng; user vào "Quét QR → chọn ảnh". Hầu hết app ngân hàng hỗ trợ chọn ảnh từ thư viện **[I]**. Cách này đã được dùng thực tế ([PR app-tuvi #1038](https://github.com/henryvn2004-arch/app-tuvi/pull/1038)).
3. Android share intent ảnh QR vào app ngân hàng: app ngân hàng **thường không đăng ký** nhận ảnh share **[I]** → không khuyến nghị.
4. QR merchant không phải VietQR (VNPAY-QR…): chỉ ghi nhận khoản chi + "Mở app ngân hàng để quét" (Open-only).

---

## 3. Chi tiết nền tảng

### iOS
- `openURL` / `url_launcher.launchUrl` **không cần** khai báo `LSApplicationQueriesSchemes`; chỉ `canOpenURL` cần. Giới hạn **50 scheme** (SDK iOS 15+), Apple đã deprecate `canOpenURL` và đề xuất "thử mở rồi xử lý lỗi" ([Apple canOpenURL](https://developer.apple.com/documentation/uikit/uiapplication/canopenurl(_:)), [bài phân tích iOS 27: 25 entries](https://blakecrosley.com/blog/canopenurl-deprecated-ios-27)).
- Khuyến nghị: không detect hàng loạt; khai báo ≤ 20 scheme phổ biến nếu muốn đánh dấu "đã cài", còn lại cứ thử mở, `launchUrl` trả `false` → fallback App Store.
- Callback `url` cho ngân hàng phải là **https** → cần cấu hình **Universal Links** (apple-app-site-association trên domain của mình).

### Android
- Android 11+ package visibility: muốn biết app nào đã cài phải khai báo `<queries><package android:name="com.vnpay.bidv"/>…</queries>` (không cần `QUERY_ALL_PACKAGES`, quyền này bị Play hạn chế) ([Android docs](https://developer.android.com/training/package-visibility)).
- `dl.vietqr.io` trả `intent://…#Intent;scheme=X;package=Y;end`. `url_launcher` (ACTION_VIEW với Uri) **không xử lý chuẩn `intent://`** **[I]** → 2 cách:
  - (a) Mở URL `https://dl.vietqr.io/...` bằng `LaunchMode.externalApplication` → Chrome tự xử lý redirect intent (cần test trên Samsung Internet/Chrome).
  - (b) App gọi HTTP (không follow redirect, UA Android) lấy `Location`, chuyển `intent://host/path?q#Intent;scheme=X;package=Y;end` → `X://host/path?q` và mở bằng `android_intent_plus` với `package=Y`. Nhanh hơn, không nháy trình duyệt.
- Callback: cấu hình **App Links** (`assetlinks.json`) cho domain https.

### Flutter packages
| Package | Trạng thái | Dùng cho |
|---|---|---|
| [`mobile_scanner`](https://pub.dev/packages/mobile_scanner) 7.4.2 | BSD-3, verified publisher, cập nhật ~1 tháng trước | Quét camera + `analyzeImage` (quét QR từ ảnh gallery với `image_picker`) |
| `url_launcher` (flutter.dev) | first-party | Mở scheme/https |
| `android_intent_plus` (fluttercommunity) | maintained | Mở intent có `package` |
| `qr_flutter` | maintained | Sinh ảnh QR cho fallback "Lưu ảnh" |
| `vietqr_core` / `vietqr_gen` | MIT, ít maintain | Parse (hoặc tự viết) |

---

## 4. Xác nhận kết quả giao dịch

| Cách | Khả thi | Ưu | Nhược |
|---|---|---|---|
| **User xác nhận khi quay lại app** (pending → confirmed/huỷ) | 100% | Đơn giản, không phụ thuộc | Phụ thuộc người dùng |
| Callback `url` qua dl.vietqr.io (5 bank autofill) | **[I]** | Quay về app tự động | Không chắc ngân hàng gọi, không chắc có trạng thái; không phải bằng chứng thành công |
| Android `NotificationListenerService` đọc thông báo biến động số dư | Kỹ thuật làm được (Android only) | Tự động, offline | Quyền nhạy cảm, mỗi bank format khác, nhiều bank chỉ đẩy OTT trong app; iOS không làm được; cần policy rõ trên Play |
| Webhook SePay/Casso (user liên kết TK ngân hàng của họ) | Làm được | Tự động khớp giao dịch đi | User phải đưa CCCD/OTP cho bên thứ ba; chi phí (SePay FREE 50 GD/tháng, STARTUP 120k/tháng — [bảng giá](https://sepay.vn/bang-gia.html)); thiết kế cho **tiền vào** của merchant, khớp tiền ra **[I]**; [Casso webhook](https://developer.casso.vn/webhook) |

Khuyến nghị: v1 dùng **pending + xác nhận khi quay lại** (khi app resume sau khi mở bank, hiện sheet "Đã chuyển 35.000đ cho X?" Có / Chưa). Callback URL là bonus để tự resume.

---

## 5. Pháp lý, rủi ro

- **Có phải "xử lý thanh toán"?** NĐ 52/2024/NĐ-CP (hiệu lực 01/7/2024) liệt kê dịch vụ trung gian thanh toán: chuyển mạch tài chính, bù trừ điện tử, ví điện tử, hỗ trợ thu hộ/chi hộ, cổng thanh toán điện tử ([thuvienphapluat](https://thuvienphapluat.vn/van-ban/Tien-te-Ngan-hang/Decree-52-2024-ND-CP-regulations-on-cashless-payments-613117.aspx), [tapchicongthuong](https://tapchicongthuong.vn/ap-quy-dinh-moi-ve-thanh-toan-khong-dung-tien-mat-tu-1-7-2024-121536.htm)). App chỉ parse QR và mở app ngân hàng, không nhận/giữ/chuyển tiền, không kết nối hệ thống ngân hàng → **[I]** không thuộc diện cần giấy phép. Có dự thảo sửa NĐ 52 (06/2026) — theo dõi. Nếu sau này thu phí/nhận tiền hộ: hỏi luật sư.
- **Thương hiệu VietQR**: VietQR™ thuộc NAPAS (vietqr.io ghi rõ). Không tìm thấy hướng dẫn public cho bên ngoài ngân hàng → **không dùng logo VietQR/NAPAS**; dùng text "QR chuyển khoản" và logo ngân hàng lấy từ CDN vietqr.io chỉ để nhận diện (rủi ro thấp, **[I]**).
- **Lừa đảo dán đè QR**: thủ đoạn phổ biến, tiền vào TK kẻ gian ([thitruongtaichinhtiente](https://thitruongtaichinhtiente.vn/dan-de-ma-qr-gia-mao-tai-cac-cua-hang-dang-la-chieu-thuc-lua-dao-moi-48628.html)). QR thường **không chứa tên chủ TK** → app không tự so khớp được. Biện pháp:
  - Hiển thị rõ ngân hàng + STK (che giữa) + tên nếu có (tag 59 hoặc lookup).
  - Tuỳ chọn: tra tên qua **VietQR.io Account Lookup** (tier Registered, miễn phí, cần đăng ký) → hiện tên và cảnh báo nếu user đã đặt tên quán khác.
  - Nhắc: "Kiểm tra tên người nhận trong app ngân hàng trước khi xác nhận" — app ngân hàng luôn hiện tên thật ở bước xác nhận, đây là lớp bảo vệ chính.
  - Lưu "người nhận quen" (STK → tên quán, danh mục) để phát hiện STK lạ ở địa điểm quen.
- **Quyền riêng tư**: STK người nhận, số tiền, nội dung gửi qua Casso (dl.vietqr.io) và (nếu dùng) lookup API → khai báo trong Privacy Policy (bên thứ ba xử lý), tuân thủ quy định bảo vệ dữ liệu cá nhân (NĐ 13/2023 và Luật BVDLCN 2025 — **cần kiểm tra hiệu lực/điều khoản cụ thể**). Không gửi thông tin người dùng (ID, email) kèm.

---

## 6. Kết luận khả thi & kế hoạch

### Chắc chắn làm được (100%)
- Quét camera + chọn ảnh từ gallery, parse VietQR, map BIN → ngân hàng, nhập số tiền/danh mục/ghi chú, tạo khoản chi `pending`.
- Mở ~37 app ngân hàng (open-only) + copy STK/số tiền + "Lưu ảnh QR" fallback.
- Xác nhận khi quay lại app.

### Phụ thuộc từng ngân hàng / bên thứ ba
- Điền sẵn chỉ với **MB, VietinBank, BIDV, ACB, OCB** — qua `dl.vietqr.io` của Casso, miễn phí nhưng không có cam kết. Các bank còn lại (đặc biệt **VCB, TCB, VPB, Agribank, Sacombank**) chỉ mở app.
- Callback tự quay về app: phải test thiết bị.

### Kế hoạch triển khai

**Backend (NestJS)** — ~2–3 ngày
- `GET /payment-apps?platform=android|ios`: bảng app do admin quản lý (appId, tên, logo, androidScheme, androidPackage, iosScheme, storeUrl, `autofill`, `enabled`, thứ tự), seed + job đồng bộ hằng ngày từ `api.vietqr.io/v2/{android,ios}-app-deeplinks`.
- `GET /banks`: cache `api.vietqr.io/v2/banks` (BIN → tên/logo).
- (Tuỳ chọn) `POST /qr/lookup-name`: proxy VietQR.io lookup, rate-limit, cache.
- Trường expense: `status: pending|confirmed|cancelled`, `payee: {bin, account, name}`, `paymentApp`, `qrRaw` (cân nhắc không lưu).
- Admin UI: bật/tắt app, sửa scheme, đánh dấu autofill.

**Mobile (Flutter)** — ~6–9 ngày
1. Màn quét (`mobile_scanner`) + nút chọn ảnh (`image_picker` + `analyzeImage`).
2. Parser TLV + CRC + phân loại (VietQR tĩnh/động, VNPAY-QR, khác) + unit test với payload mẫu.
3. Màn "Kiểm tra khoản chi": người nhận, bàn phím số tiền (khoá nếu QR động có tag 54), danh mục, ghi chú (→ `tn`, bỏ dấu, ≤ 25 ký tự an toàn).
4. Bottom sheet chọn app (nhớ app mặc định; badge "Điền sẵn" cho app autofill).
5. Launcher:
   - autofill: build `https://dl.vietqr.io/pay?app=…&ba={acc}@{bin}&am=…&tn=…&url=https://<domain>/r/{expenseId}` → Android: lấy `Location` rồi mở bằng scheme + package (fallback mở URL ngoài); iOS: mở URL bằng Safari ngoài.
   - open-only: copy STK + mở scheme (fallback store) + nút "Lưu ảnh QR".
6. App/Universal Links cho `https://<domain>/r/{id}` + lifecycle resume → sheet xác nhận.
7. Cảnh báo an toàn (tên người nhận, STK lạ).

**Test bắt buộc trước release**: thiết bị thật Android + iPhone, 5 app autofill (kiểm tra có điền đủ TK/tiền/nội dung, callback có gọi không), VCB/TCB (open-only), app chưa cài (fallback store).

Tổng: **~2 tuần 1 dev** cho v1 (chưa gồm notification listener / webhook).

---

## Nguồn
- VietQR.io deeplink docs: https://www.vietqr.io/danh-sach-api/deeplink-app-ngan-hang/
- API app deeplinks: https://api.vietqr.io/v2/android-app-deeplinks , https://api.vietqr.io/v2/ios-app-deeplinks
- API banks: https://api.vietqr.io/v2/banks
- VietQR.io changelog: https://vietqr.io/en/changelog/
- VietQR.io tiers: https://www.vietqr.io/en/
- ZaloPay bank deeplinks: https://docs.zalopay.vn/docs/guides/payment-acceptance/zalopay-emvco-qr/intro/
- Tingee deeplink: https://developers.tingee.vn/docs/deeplink/
- MoMo one-time payment: https://developers.momo.vn/v3/docs/payment/api/wallet/onetime/
- voz thảo luận: https://voz.vn/t/lam-the-nao-de-mo-app-ngan-hang-bang-link-va-dien-du-cac-thong-tin-can-chuyen-khoan.1060532/
- PR "Lưu ảnh QR": https://github.com/henryvn2004-arch/app-tuvi/pull/1038
- vietnam-qr-pay: https://github.com/xuannghia/vietnam-qr-pay
- vietqr_core: https://pub.dev/packages/vietqr_core ; vietqr_gen: https://pub.dev/packages/vietqr_gen
- mobile_scanner: https://pub.dev/packages/mobile_scanner
- Apple canOpenURL: https://developer.apple.com/documentation/uikit/uiapplication/canopenurl(_:)
- Android package visibility: https://developer.android.com/training/package-visibility
- SePay pricing: https://sepay.vn/bang-gia.html ; Casso webhook: https://developer.casso.vn/webhook
- NĐ 52/2024: https://thuvienphapluat.vn/van-ban/Tien-te-Ngan-hang/Decree-52-2024-ND-CP-regulations-on-cashless-payments-613117.aspx
- Lừa đảo dán đè QR: https://thitruongtaichinhtiente.vn/dan-de-ma-qr-gia-mao-tai-cac-cua-hang-dang-la-chieu-thuc-lua-dao-moi-48628.html
