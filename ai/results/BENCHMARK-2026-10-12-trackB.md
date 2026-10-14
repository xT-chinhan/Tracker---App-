# Track B — 17 skill USER/ADMIN + router theo scope (gemma2:2b) — 2026-10-12 → 14

Nhánh `feat/ai-skills`, worktree `app-tracker-ai-b`. Thiết kế theo [DE-XUAT.md](../research/DE-XUAT.md): skill là pipeline code, model chỉ điền JSON nhỏ hoặc viết 1 câu, số luôn do code tính, nháp phải được người dùng xác nhận.
Số liệu thô: `trackB-skills.json` (LLM thật), `trackB-skills-fake-llm.json` (model hỏng → đường lùi), `trackB-skills-fake-llm-asis.json` (backend như hiện tại, chưa có provider MỚI), `trackB-router.json`.

## 1. Thiết lập

| Mục | Giá trị |
|---|---|
| Máy | RTX 3050 6 GB, `OLLAMA_NUM_PARALLEL=1`. Mọi lệnh gọi Ollama chạy qua `flock /tmp/app-tracker-gpu.lock`, tuần tự |
| LLM / embedding | `gemma2:2b` (temperature 0, `format` = JSON schema) / `bge-m3` |
| "now" | 2026-10-08 20:00 +07:00 (dữ liệu demo kết thúc ngày 08/10) |
| Fixture | Đọc DB dev `tracker` ở chế độ `BEGIN TRANSACTION READ ONLY` (`eval/fixtures/build.ts`): `demo@thuchi.vn` (4 ví, 575 giao dịch trong 6 tháng, 19 ngân sách, 3 mục tiêu), `minhthu.do@demo.thuchi.vn` (ví ACB, danh mục riêng Thú cưng, mục tiêu đã hoàn thành / rút sớm), user rỗng (tự sinh), admin (42 user, 3 broadcast). **Tự viết**: 10 dòng lịch sử cấu hình (bảng `SystemConfigChange` của DB dev đang trống) và `admin-anomaly` (cài thêm 1 user bị dò mật khẩu, 1 user có khoản chi 45 triệu, 1 user có 480 giao dịch) |
| Provider giả | `eval/fixtures/providers.ts` dựng `SkillContext` đúng như backend Track C (`data` + `get`, provider admin bị chặn khi role USER) và tính số theo công thức backend (`stats.report`, `budgets.withProgress`, `savingGoals.withProgress`) |

## 2. Kết quả theo skill (LLM thật)

Kiểm tra bằng code cho **mọi** ca:
- Mọi số trong reply phải có nguồn: dữ liệu provider đã đưa cho skill, câu hỏi, `meta.computed` (số do code tính), dữ liệu tĩnh của skill, hoặc hằng template 30/24.
- Mọi ngày/giờ phải có trong dữ liệu (đổi sang giờ VN), là hôm nay, hoặc là mốc của bộ lọc.
- Câu do model viết không được chứa chữ số. Reply phải là tiếng Việt, dài không quá 1500 ký tự.
- Phiên USER không được lộ tên hoặc email của 41 user khác. Draft phải đúng schema của loại nháp backend.

Ngoài ra mỗi ca có kiểm tra riêng: chuỗi số phải khớp **chính xác** (vd "Mỗi ngày còn chi được khoảng 233.166đ (còn 24 ngày)"), draft đúng từng trường, từ chối đúng lý do, `askBack`, id FAQ, user bị gắn cờ.

| Skill | Scope | Số ca | Pass % | Ca gọi model | Câu model đạt kiểm tra % | p50 ms | p95 ms |
|---|---|---|---|---|---|---|---|
| hoi-so-du | USER | 23 | 100 | 0 | – | 0 | 3 |
| tong-ket-thang | USER | 22 | 100 | 20 | 100 | 1377 | 1709 |
| kiem-tra-ngan-sach | USER | 21 | 100 | 18 | 100 | 1416 | 1687 |
| tim-giao-dich | USER | 22 | 100 | 6 | 100 | 1 | 486 |
| tien-do-tiet-kiem | USER | 21 | 100 | 19 | 100 ¹ | 930 | 1190 |
| goi-y-ngan-sach | USER | 13 | 100 | 11 | 100 | 796 | 887 |
| meo-tiet-kiem | USER | 12 | 100 | 11 | 100 | 696 | 775 |
| huong-dan | USER | 24 | 100 | 0 ² | – | 0 | 1 |
| ngoai-pham-vi | ANY | 16 | 100 | 0 | – | 0 | 0 |
| hoi-lai | ANY | 11 | 100 | 0 | – | 0 | 0 |
| tong-quan-he-thong | ADMIN | 11 | 100 | 9 | 100 | 1041 | 1262 |
| tra-cuu-nguoi-dung | ADMIN | 12 | 100 | 1 | 100 | 0 | 483 |
| phat-hien-bat-thuong | ADMIN | 11 | 100 | 10 | 100 | 1083 | 1538 |
| soan-thong-bao | ADMIN | 13 | 100 | 10 | 70 ³ | 1557 | 3884 |
| de-xuat-khoa | ADMIN | 12 | 100 | 0 | – | 0 | 1 |
| tom-tat-cau-hinh | ADMIN | 11 | 100 | 9 | 100 | 904 | 1360 |
| huong-dan-quan-tri | ADMIN | 14 | 100 | 0 ² | – | 0 | 0 |
| **Tổng** | | **269** | **100** | 124 | | 1 (mọi ca) / **1081** (ca có gọi model) | 1557 |

1. Lượt chạy đầy đủ cho 47,4%. Nguyên nhân: bộ lọc "số viết bằng chữ" coi "chúc mừng" là "chục" và loại câu. Đã sửa (bỏ "chục"; trước đó cũng bỏ "ngân/năm/sau/tám…" vì trùng "ngân sách", "tháng sau", "tầm"). Sau khi sửa, chạy lại riêng skill này được 100%. `trackB-skills.json` vẫn là lượt đầy đủ trước khi sửa.
2. FAQ chỉ hỏi model khi 2 mục đầu sát điểm nhau. Trong bộ đề không ca nào rơi vào trường hợp này.
3. 3 trên 10 nháp hỏng cả 2 lần thử nên lùi về template ghép từ chính câu yêu cầu. Lý do hỏng: mất mốc "20/10", "12/10"; với câu tiếng Anh thì template cũng giữ nguyên tiếng Anh. Các nháp model viết đều qua được kiểm tra bằng code, nhưng văn phong chưa ổn ở vài chỗ: "Khao khát ngân sách tháng 11!", "khi có update". **Cần người đọc duyệt.** Bộ kiểm tra không chấm văn phong.

**Thận trọng khi đọc số 100%.** Cùng một người viết cả bộ đề lẫn skill (269 ca), và đã sửa skill hoặc checker sau lượt dry-run. Con số này chứng minh **đúng số liệu**, đường lùi và chặn dữ liệu chứ không chứng minh khả năng tổng quát hóa. Phần ngôn ngữ do model tạo ra chỉ chiếm 1 câu mỗi reply.

### Model hỏng (`--fake`, model luôn trả `{}`)
Pass **269/269**. Mọi skill đều có đường lùi bằng code: câu dự phòng, mẹo đầu tiên của danh mục, cụm từ khóa lấy từ câu gốc, template thông báo.

### Backend hiện tại chưa có provider MỚI (`--fake --asis`)
Pass **234/269 (87%)**. Skill không lỗi mà lùi về mức thấp hơn:

| Skill | Pass % | Thiếu gì |
|---|---|---|
| tong-ket-thang | 54,5 | `periodSummary` (tuần, hôm nay, 7 ngày đành tổng kết cả tháng), `largestExpense` |
| goi-y-ngan-sach | 53,8 | `monthSummary` chỉ trả top 5 danh mục nên gợi ý thiếu mục thứ 6 trở đi |
| meo-tiet-kiem | 75 | top 5 nên danh mục nhỏ không có số TB |
| phat-hien-bat-thuong | 9,1 | `adminUserActivity`. Chỉ còn dùng được `adminAnomalies` (số tài khoản khóa, user ghi ≥ 50 giao dịch/24h) |
| de-xuat-khoa | 58,3 | `adminUserActivity`. Vẫn tìm được tài khoản qua `adminUsersSearch` và chặn được tự khóa / admin / đã khóa, nhưng không có lý do nên **không tạo nháp** |
| soan-thong-bao | 92,3 | `adminBroadcasts` nên không cảnh báo được thông báo trùng |
| 11 skill còn lại | 100 | – |

## 3. Router theo scope

Pipeline: chặn chung (injection; phiên USER hỏi dữ liệu người khác hoặc việc admin; phiên ADMIN làm việc tài chính cá nhân) → chủ đề ngoài phạm vi → luật theo scope → kNN bge-m3 **chỉ trên câu mẫu của scope đó** → điểm thấp thì hỏi lại. Bất biến cuối cùng: skill ngoài scope bị đổi thành `ngoai-pham-vi`.

Dữ liệu (không câu nào trùng nhau, có script kiểm tra):
- 199 câu mẫu (`router/bank.ts`).
- DEV 107 câu, dùng để chọn k và ngưỡng.
- TEST 263 câu (`eval/data/router-v2.ts`): 83 câu cũ cộng 180 câu mới, USER 176 / ADMIN 87, trong đó 25 câu đối kháng, 30 câu tiếng Anh, 32 câu không dấu.
- **Đề mù 161 câu** (`router-blind.json`): một agent khác viết mà không xem code hay luật. USER 102 / ADMIN 59, 26 câu đối kháng, 16 câu tiếng Anh, 19 câu không dấu, 11 câu teencode.

Tổng cộng 424 câu được chấm.

| Phương pháp | TEST % | USER | ADMIN | đối kháng | EN | không dấu | **Mù %** | mù USER | mù ADMIN | mù đối kháng | Sai scope |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Luật (không khớp → hỏi lại) | 92,4 | 93,8 | 89,7 | 96 | 86,7 | 96,9 | 80,7 | 83,3 | 76,3 | 69,2 | 0 |
| kNN bge-m3 theo scope | 81,4 | 77,8 | 88,5 | 72 | 93,3 | 56,3 | 80,7 | 77,5 | 86,4 | 69,2 | 0 |
| **Luật + kNN (k=1, ngưỡng 0,30)** | **98,1** | 97,7 | 98,9 | **100** | 100 | 100 | **88,8** | 89,2 | 88,1 | 84,6 | **0** |

- **Sai scope = 0 trên 424 câu**: phiên USER chưa lần nào ra skill ADMIN, và ngược lại.
- **Mọi câu đối kháng về dữ liệu người khác và prompt injection đều về `ngoai-pham-vi`, cả trong TEST lẫn đề mù.** 4 câu đối kháng sai trên đề mù đều là bẫy chủ đề: "quận 1 có quán nào ngon mà rẻ", "1 đô bằng bao nhiêu tiền Việt", "vay 50 triệu ngân hàng nào lãi thấp", "lương 12 triệu chia ngân sách thế nào" (đáp án là goi-y, router ra kiem-tra). Ngoài router, mỗi skill USER còn tự chặn lần nữa bằng `userGuard`.
- **Con số công bằng là đề mù: 88,8%.** TEST 98,1% là lạc quan: luật và câu mẫu được chỉnh sau khi xem lỗi trên TEST/DEV. Đề mù được chấm nhiều lần, lần đầu cũng ra 88,8%, và **không chỉnh luật nào theo đề mù**.
- Lỗi còn lại trên đề mù chủ yếu là câu hỏi lại có ngữ cảnh ("ok vậy tháng trước", "cái user lúc nãy" — cần lịch sử hội thoại), các cặp gần nghĩa (tổng quan ↔ bất thường, tiến độ tiết kiệm ↔ tổng kết), và ghi giao dịch bằng tiếng Anh.
- Ngưỡng chọn trên DEV vẫn là 0,30, nghĩa là gần như không bao giờ hỏi lại; với DEV 107 câu, k=1 tốt hơn vote 5 láng giềng. Độ trễ: luật < 1 ms; khi phải dùng kNN thì embed bge-m3 p50 205 ms, p95 262 ms. Câu mẫu được nhúng sẵn một lần.

## 4. Độ trễ

p50 trên các ca có gọi model là **1081 ms** (124 ca), p95 khoảng 1,7 s. soan-thong-bao tối đa 3,9 s vì có retry. 9 skill không gọi model chạy dưới 3 ms. Router cộng thêm tối đa khoảng 0,2 s khi phải dùng kNN.

## 5. Hợp đồng với backend (`ai/lib/contracts.ts`), đã khớp với Track C

- Skill export `{ name, scope: 'USER'|'ADMIN'|'ANY', description, context: ProviderName[], run }`, với `run({ input, context: { principal{id,name,role}, now, history, data, get }, llm: LlmClient, now })`, trả về `{ reply, draft?: {kind, payload}, followUps?, askBack?: boolean, meta }`.
- `ai/skills/index.ts` gom 17 skill (đè built-in cùng tên). Thêm 6 **bí danh** `admin-tong-quan / admin-tim-user / admin-bat-thuong / admin-gui-thong-bao / admin-khoa-user / admin-lich-su-cau-hinh` trỏ sang skill Track B, để router hiện tại của backend dùng được ngay. Đã kiểm tra nạp bằng chính `tsx/esm/api` của backend: 23 skill, gồm 17 skill và 6 bí danh.
- Router: `routeRules(text, ctx)` giữ nguyên chữ ký. API mới `routeRulesScoped(text, scope)` và `routeScoped(text, scope, knn, threshold)` export từ `router/index.ts`.
- Loại nháp dùng đúng loại backend đã có: `search_filter` (target transactions | users), `budgets`, `broadcast`, `lock_user`.

### Cần backend (Track C) bổ sung

| # | Việc | Dùng cho |
|---|---|---|
| 1 | Provider **`periodSummary`** `{from, to}` (thêm from/to vào `sanitizeArgs`): thu, chi, số khoản, top chi | tong-ket-thang theo tuần / ngày / N ngày |
| 2 | `monthSummary`: `topExpenses` theo `limit` (hiện cố định 5) + trường `largestExpense {title, amount, categoryName, date}` | goi-y-ngan-sach, meo-tiet-kiem, tong-ket-thang |
| 3 | Provider **`adminUserActivity`**: mỗi user `{id, email, name, role, status, createdAt, lastLoginAt, txCount30d, expenseThisMonth, expenseAvgPrev3, largestExpense30d, failedLogins24h?}`. Hệ thống **chưa ghi nhận đăng nhập sai**: muốn có `failedLogins24h` phải đếm ở auth | phat-hien-bat-thuong, de-xuat-khoa |
| 4 | Provider **`adminBroadcasts`** `{limit}`, **`publicConfig`** `{appName, supportEmail, hotline}` | soan-thong-bao (kiểm tra trùng, tên app) |
| 5 | `search_filter` target transactions: map `from/to/type/categoryName/walletName` sang filter `/transactions` (tên → id của chính user). `minAmount/maxAmount` API chưa có | tim-giao-dich |
| 6 | `search_filter` target users: `status`, `role` (API `/admin/users` đã hỗ trợ) | tra-cuu-nguoi-dung |
| 7 | `lock_user`: lưu/hiện thêm `reasons[]` | de-xuat-khoa |
| 8 | Nháp `budgets` có dòng `categoryName: null` (ngân sách tổng). Tháng đã có ngân sách thì `POST /budgets` trả 409, cần upsert nếu muốn "cập nhật theo gợi ý" | goi-y-ngan-sach |
| 9 | `SkillRegistry.allowed` hiện cho skill USER chạy trong hội thoại ADMIN. Yêu cầu là chặn cả 2 chiều: nên đổi thành `scope === 'USER'` ⇒ chỉ chạy khi convScope USER | an toàn scope |
| 10 | Chuyển router admin sang `routeRulesScoped` / tên skill Track B rồi bỏ bí danh `admin-*` | gọn tên |

Skill đã tự xử lý `createdAt` / `targetDate` khi chúng là `Date` (truyền thẳng trong tiến trình) hoặc chuỗi ISO.

### Báo cho Track A
`parser/money.ts`: chữ "trả **bằng** momo" bị đọc thành "ba ng" = 3.000đ. tim-giao-dich đã che chữ "bang" trước khi gọi parser; ghi-giao-dich chưa được che.

## 6. Thay đổi ở file dùng chung

Chỉ thêm file mới, không sửa file cũ:
- `ai/lib/contracts.ts`, `ai/lib/skillkit.ts`, `ai/lib/period.ts`, `ai/lib/faq.ts`
- `ai/router/index.ts`: chỉ thêm dòng export ở cuối

Không đụng `lib/ollama.ts`, `lib/text.ts`, `lib/types.ts`, `eval/common.ts`, `parser/`, `learn/`, `skills/ghi-giao-dich/`.

## 7. Tái lập

```bash
cd ai && npm install
npx tsx eval/fixtures/build.ts                                    # fixture từ DB dev (chỉ đọc)
npx tsx eval/skills.ts --fake                                     # không GPU: đường lùi
npx tsx eval/skills.ts --fake --asis                              # không GPU: backend hiện tại
flock /tmp/app-tracker-gpu.lock npx tsx eval/skills.ts            # gemma2:2b thật (~5 phút)
flock /tmp/app-tracker-gpu.lock npx tsx eval/router-scoped.ts     # router (embed có cache)
```
