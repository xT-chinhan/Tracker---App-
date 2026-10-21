# Kiểm thử API Thu Chi — yêu cầu cho nhóm test

Nhánh này (`api-test`) dùng để **kiểm thử backend API** (`backend/`, NestJS + Prisma + PostgreSQL) độc lập với app mobile và admin web. Mục tiêu:

1. Kiểm tra lại toàn bộ API theo tài liệu và luật nghiệp vụ, tìm lỗi mà bộ test tự động chưa bắt được.
2. Viết bộ request dùng lại được (Postman/Bruno) cho nhóm mobile tham khảo.
3. Ghi lỗi thành issue trên GitHub, đủ thông tin để tái hiện.

**Không sửa code backend trong nhánh này.** Tìm ra lỗi thì mở issue; ai sửa backend sẽ làm ở nhánh riêng.

---

## 1. Tài liệu nguồn

| Nội dung | File |
|---|---|
| Danh sách endpoint, quy ước lỗi, luật nghiệp vụ | `backend/README.md` (mục "Endpoint", "Nghiệp vụ v1", "Trợ lý AI", "Cấu hình hệ thống") |
| Đặc tả OpenAPI (86 endpoint, kèm schema body) | `tests/api/openapi.json`, bản sống: `http://localhost:3000/docs/openapi.json` |
| Swagger UI (thử trực tiếp trên trình duyệt) | `http://localhost:3000/docs` |
| Bộ test tự động có sẵn | `backend/scripts/e2e.mjs` (~700 kiểm tra), `backend/scripts/e2e-ai.mjs` (nhóm `ai:`), `backend/scripts/verify-demo.mjs` (bất biến dữ liệu demo) |
| Quyết định sản phẩm của Trợ lý AI | `docs/AI-DECISIONS.md` |

---

## 2. Chạy API để test

Cần Node 22+, npm, Docker (compose v2). Ở gốc repo:

```bash
npm run setup     # cài, tạo .env, bật PostgreSQL (Docker :5433), migrate, seed, nạp dữ liệu demo (~30s)
npm run dev       # API http://localhost:3000/api   (kèm admin web http://localhost:5173)
```

Muốn chỉ chạy API: `npm --prefix backend run dev`. Làm hỏng dữ liệu thì nạp lại: `npm run db:seed:demo` (chỉ xóa/tạo lại user demo).

### Tài khoản

| Tài khoản | Mật khẩu | Dùng để |
|---|---|---|
| `admin@thuchi.vn` | `admin123` | Route `/admin/*`, `/admin/ai/*`, `/admin/config` |
| `demo@thuchi.vn` | `demo123` | User có dữ liệu đầy đủ (4 ví tổng 26.022.000đ, ngân sách 14 triệu, 3 mục tiêu, 5 định kỳ) |
| `<tên>@demo.thuchi.vn` | `demo123` | ~39 user khác (vd `hung.vu89@demo.thuchi.vn`), 3 bị khóa, 1 là admin (`bao.tran91@demo.thuchi.vn`) |
| Tự đăng ký | — | `POST /api/auth/register` để có user sạch khi test cách ly dữ liệu |

### Trợ lý AI
- Mặc định dùng **Ollama thật** (`gemma2:2b` + `bge-m3` ở `http://localhost:11434`; đổi trong admin › Cấu hình › Trợ lý AI). Máy không có Ollama thì đặt `AI_PROVIDER=fake` trong `backend/.env`: trả lời tất định, đủ để test luồng nháp / xác nhận / phân quyền.
- Ollama chạy 1 request/lúc: **không bắn song song** vào `/ai/*` khi test với model thật.

---

## 3. Bộ test tự động có sẵn — chạy trước tiên

```bash
npm run test
```

Lệnh tự tạo DB `tracker_test`, nạp demo, bật API `NODE_ENV=test` ở `:3001`, chạy:

| Bước | Kết quả gần nhất (17/10/2026) |
|---|---|
| verify-demo (bất biến dữ liệu demo) | 553 đạt, **1 lỗi đã biết**: "chi tháng này 50–70% ngân sách" phụ thuộc ngày chạy (17/10 đã 73,6%) |
| Backend e2e (`e2e.mjs` + `e2e-ai.mjs`) | **943/943** đạt |
| Admin e2e (Playwright) | 52/52 đạt |

Chỉ chạy phần API: `SKIP_ADMIN=1 npm run test`. Giữ lại DB test để soi: `KEEP_TEST_DB=1`. Đổi cổng: `TEST_API_PORT=3101`.

Việc của nhóm test **không phải viết lại** những gì bộ này đã kiểm (xem danh sách nhóm ở mục 6), mà tìm chỗ nó bỏ sót: tổ hợp tham số lạ, thứ tự thao tác, dữ liệu biên, đa thiết bị, đồng thời, AI với model thật.

---

## 4. Công cụ và cách lấy token

- **Postman** hoặc **Bruno**: Import → OpenAPI → chọn `tests/api/openapi.json` → có sẵn toàn bộ request.
- Tạo environment: `baseUrl = http://localhost:3000/api`, `token`, `adminToken`.
- Lấy token: `POST {{baseUrl}}/auth/login` body `{"email":"demo@thuchi.vn","password":"demo123"}` → copy `accessToken` → header `Authorization: Bearer {{token}}`. Có thể thêm script Post-response tự gán biến.
- curl nhanh:

```bash
A=http://localhost:3000/api
T=$(curl -s $A/auth/login -H 'content-type: application/json' \
  -d '{"email":"demo@thuchi.vn","password":"demo123"}' | jq -r .accessToken)
curl -s $A/wallets -H "authorization: Bearer $T" | jq
```

Lưu collection đã làm vào `tests/api/collection/` (Bruno: thư mục `.bru`; Postman: file export `.json`). **Không commit token** hay file environment có token thật.

---

## 5. Quy ước cần kiểm (áp dụng mọi endpoint)

| Quy ước | Kỳ vọng |
|---|---|
| Xác thực | Thiếu / sai token → 401. Route admin với user thường → 403. Tài khoản bị khóa → 403 "Tài khoản đã bị khóa" |
| Cách ly dữ liệu | id trên **đường dẫn** thuộc user khác → **404** (không lộ là có tồn tại). id trong **body** (ví, danh mục) không thuộc mình → **400** |
| Phiên | Đổi mật khẩu, đặt lại bằng OTP, bị khóa, `POST /auth/logout-all` → mọi token cũ → 401. Đổi mật khẩu trả token mới |
| Validation | Body sai kiểu, thiếu trường, trường lạ → 400 kèm `message` tiếng Việt. Không bao giờ 500 |
| Số tiền | Số nguyên 1 – 10.000.000.000.000. Số thập phân, âm, 0, chuỗi → 400 |
| Ngày giờ | Giờ Việt Nam. `month=YYYY-MM`; `from` gồm, `to` không gồm, `from` < `to`. Ngày ngoài 2000–2099 → 400. Giao dịch 23:30 ngày cuối tháng (giờ VN) phải thuộc tháng đó |
| Phân trang | `page` 1–10000, `limit` 1–200, trả `{items, total, page, limit}` |
| Rate limit | login / register / reset-password 10 lần/phút/IP; forgot-password 3 lần/phút → 429 + header `Retry-After` |
| Tính năng tắt | Admin tắt tính năng (Cấu hình › Nghiệp vụ) → route **ghi** trả 403 `FEATURE_DISABLED`, route **đọc** vẫn chạy |
| Bảo trì | Bật bảo trì → user thường 503 `MAINTENANCE`; admin không bị chặn; `GET /config/public` vẫn chạy |
| Lỗi | Dạng `{statusCode, message, code?}`; `message` là chuỗi hoặc mảng chuỗi |

---

## 6. Phạm vi test theo module

Bộ tự động đã phủ các nhóm dưới đây. Mỗi module cần một file `tests/api/cases/<module>.md` gồm bảng ca test (mẫu ở mục 8). Cột "Gợi ý thêm" là chỗ nên đào sâu.

| Module | Endpoint chính | Đã có tự động | Gợi ý thêm |
|---|---|---|---|
| **auth** | `/auth/*`, `/me`, `/me/password` | đăng ký/đăng nhập/hồ sơ, tokenVersion, OTP quên mật khẩu, xóa tài khoản, rate limit | Email hoa/thường, khoảng trắng; OTP sai 5 lần rồi xin mã mới; đăng nhập 2 thiết bị rồi đổi mật khẩu ở một máy; xóa admin cuối cùng |
| **wallets** | `/wallets` | CRUD, số dư, lưu trữ khi có phát sinh | Lưu trữ ví còn số dư ≠ 0 (409); ghi giao dịch vào ví đã lưu trữ; khôi phục rồi sửa phát sinh cũ; đổi `initialBalance` ví đã lưu trữ (409) |
| **categories** | `/categories` | CRUD, trùng tên, lưu trữ khi đã dùng | Trùng tên khác hoa thường / có dấu; trùng với danh mục hệ thống; sửa danh mục hệ thống bằng tài khoản user (phải bị chặn) |
| **transactions** | `/transactions`, `/transactions/bulk` | CRUD, lọc, bulk, cách ly | Bulk 100 / 101 khoản; bulk có 1 khoản lỗi → không khoản nào được ghi; tổ hợp lọc `month` + `from/to`; `q` có ký tự đặc biệt / tiếng Việt không dấu |
| **transfers** | `/transfers` | CRUD, đủ số dư, không vào thu chi | Sửa chuyển tiền làm ví âm; xóa A→B khi B đã chuyển tiếp đi; 2 ví giống nhau |
| **budgets** | `/budgets`, `/budgets/copy` | danh mục / tổng / copy, cảnh báo 80% / 100%, báo lại sau khi chi giảm | Copy sang tháng đã có ngân sách; danh mục đã lưu trữ; đổi ngưỡng ở Cấu hình rồi ghi chi |
| **saving-goals** | `/saving-goals`, `/deposit`, `/withdraw` | nạp theo ví, rút, trạng thái, nạp đồng thời | Nạp vượt số còn thiếu (bị cắt); nạp vào mục tiêu đã rút; xóa mục tiêu còn tiền |
| **quick-templates** | `/quick-templates`, `/:id/use` | CRUD, use, lưu trữ | `use` ghi đè ngày/số tiền; ví/danh mục của mẫu bị lưu trữ → 409 |
| **recurring** | `/recurring`, `/pause`, `/resume`, `/preview`, `/run-due` | 31 → tháng 2 → 31/3, bù kỳ lỡ, idempotent, pause/resume, endDate, ví lưu trữ tự dừng | YEARLY ngày 29/2; WEEKLY interval 2; `startDate` quá khứ xa (giới hạn 500 kỳ); `run-due?now=` nhiều lần liên tiếp |
| **notifications** | `/notifications`, `/unread-count`, `/read-all` | cảnh báo ngân sách, đọc/đếm/cách ly | Đánh dấu đọc thông báo của user khác (404); broadcast tới user bị khóa |
| **stats** | `/stats/balance|summary|by-category|daily|trend|report` | số dư, tổng hợp, theo ví, mốc nửa đêm | Đối chiếu tay: tổng `by-category` = `summary`; `report` với < 3 tháng dữ liệu; lọc ví đã lưu trữ |
| **export** | `/export/transactions.csv` | CSV, khoảng lớn stream theo lô | Mở bằng Excel: tiếng Việt không lỗi font (UTF-8 BOM); tiêu đề có dấu phẩy, ngoặc kép, xuống dòng |
| **admin** | `/admin/users|transactions|broadcasts|categories|overview` | phân quyền, khóa, broadcast, danh mục hệ thống, chạy định kỳ | Admin tự khóa / tự hạ quyền (phải bị chặn); hạ quyền admin đang đăng nhập → request admin kế tiếp 403 |
| **config** | `/config/public`, `/admin/config`, `/history`, `/maintenance`, `/smtp/test` | quyền, validation, lưu, lịch sử, SMTP, OTP, bảo trì tự tắt, tính năng tắt | Bảo trì có `endsAt` 2 phút → tự tắt; tắt đăng ký → register 403; `ai.enabled` và `business.featureAi` luôn cùng giá trị |
| **ai** (user) | `/ai/conversations`, `/messages`, `/drafts/:id/confirm|cancel`, `/feedback`, `/reroute`, `/usage`, `/settings`, `/memory` | CRUD hội thoại, nháp → API thật, sửa/hủy nháp, cô lập A ↔ B, SSE, hạn mức, tắt tính năng, chu trình học, xóa dây chuyền, giữ lịch sử 12 tháng | **Chất lượng với Ollama thật** (mục 7); xác nhận nháp 2 lần (idempotent); hủy nháp đã xác nhận (409); gửi tin thứ 31 trong ngày (429 `AI_DAILY_LIMIT`); tạo cuộc thứ 51 (tự lưu trữ cuộc cũ chưa ghim) |
| **ai** (admin) | `/admin/ai/stats|rules|examples|learning/*|usage|integrity|ollama/test` | thống kê, duyệt luật/ví dụ, mức dùng chỉ số đếm, kiểm tra Ollama | `/admin/ai/usage` **không bao giờ** chứa nội dung tin nhắn; `integrity` luôn 0; `ollama/test` với địa chỉ sai / model chưa tải |
| **health / swagger** | `/health`, `/docs` | | Tắt DB → `/health` 503 (chưa có test tự động) |

---

## 7. Trợ lý AI với model thật — cần đo

Bộ tự động chỉ chạy với provider giả. Với Ollama thật, ghi kết quả vào `tests/api/cases/ai-quality.md` (câu gửi, skill được chọn, nháp nhận được, đúng/sai, thời gian `latencyMs`).

Lỗi đã thấy khi thử ngày 17/10/2026 (cần xác nhận lại và mở issue):

| Câu gửi (`demo@thuchi.vn`) | Kết quả | Kỳ vọng |
|---|---|---|
| `cf 45k với cơm trưa 55k ví momo` | "CF" → **Thu khác / INCOME**; khoản 2 tên "Cơm trưa **Ví**" | Cà phê → Ăn uống / EXPENSE; tên "Cơm trưa" |
| (câu ghi giao dịch đầu tiên sau khi bật API) | 15,7 giây | Dưới thời gian chờ mặc định 15 giây |
| `người mới đăng ký chưa ghi giao dịch nào` (admin) | Chuyển sang skill `phat-hien-bat-thuong` | `tra-cuu-nguoi-dung` |

Nguyên nhân đã biết: backend còn dùng bản `ghi-giao-dich` dự phòng, chưa nối bản mới trong `ai/skills/ghi-giao-dich` (xem `docs/BACKLOG.md` mục 0).

Bộ câu nên thử thêm: không dấu / teencode (`ck 2tr cho me`, `an sang 30k`), đơn vị (`1tr250`, `trăm rưỡi`, `2 củ`), ngày tương đối (`hôm qua`, `thứ 2 tuần trước`), nhiều khoản một câu, khoản thu (`lương về 15tr`), câu hỏi ngoài phạm vi, câu hỏi về dữ liệu của người khác (phải từ chối).

---

## 8. Mẫu ca test và báo lỗi

Mẫu `tests/api/cases/<module>.md`:

```markdown
| Mã | Mô tả | Request | Kỳ vọng | Thực tế | Kết quả |
|---|---|---|---|---|---|
| TX-01 | Ghi chi vào ví đã lưu trữ | POST /transactions {walletId: <ví lưu trữ>, ...} | 4xx, message nói rõ ví đã lưu trữ | <status + message nhận được> | Đạt / Lỗi → #<số issue> |
```

Issue trên GitHub (label `bug`, `api`):

```markdown
**Endpoint**: POST /api/transactions
**Tài khoản**: demo@thuchi.vn
**Request** (curl hoặc body JSON):
**Kỳ vọng**: (trích dòng trong backend/README.md nếu có)
**Thực tế**: status + response body
**Tái hiện**: các bước từ dữ liệu demo vừa nạp (`npm run db:seed:demo`)
**Commit**: `git rev-parse --short HEAD`
```

---

## 9. Quy trình làm việc

- Mỗi người nhận một hoặc vài module ở mục 6, tạo nhánh từ `api-test`: `api-test/<module>` (vd `api-test/transactions`).
- Commit vào nhánh đó: `tests/api/cases/<module>.md` và request trong `tests/api/collection/`.
- Mở **Pull Request vào `api-test`**. Không push thẳng vào `api-test` hay `main`.
- Lỗi tìm được → issue GitHub, ghi số issue vào cột "Kết quả" của ca test.
- Muốn biến ca test thành kiểm tra tự động: thêm `check(...)` vào đúng `group(...)` trong `backend/scripts/e2e.mjs` theo cùng kiểu đang có, rồi chạy `SKIP_ADMIN=1 npm run test` phải xanh trước khi mở PR.
- Chạy test nặng (Playwright, nhiều request AI) **tuần tự**, không chạy nhiều bộ cùng lúc trên một máy.

### Chia việc gợi ý

| Mã | Phạm vi |
|---|---|
| T1 | auth + config + admin (phân quyền, phiên, bảo trì, rate limit) |
| T2 | wallets + transactions + transfers + categories |
| T3 | budgets + saving-goals + quick-templates + recurring + notifications |
| T4 | stats + export (đối chiếu số liệu tay với dữ liệu demo) |
| T5 | ai user + ai admin, chất lượng với Ollama thật (mục 7) |
| Chung | Viết collection Postman/Bruno đủ 86 endpoint, có environment mẫu không chứa token |
