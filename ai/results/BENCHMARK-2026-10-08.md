# Đợt đo thử: skill tự học trên gemma2:2b — 2026-10-08

Làm theo thiết kế ở [`ai/research/DE-XUAT.md`](../research/DE-XUAT.md). Số liệu thô nằm trong `ai/results/*.json`.

## 1. Thiết lập

| Mục | Giá trị |
|---|---|
| Máy | RTX 3050 6 GB, RAM 15 GB. Ollama 0.30.10 chạy backend **Vulkan** (`OLLAMA_LLM_LIBRARY=vulkan`), `OLLAMA_NUM_PARALLEL=1` (đọc từ log service, giữ nguyên cấu hình) |
| LLM | `gemma2:2b` Q4_0, temperature 0, seed 7, `num_ctx` 4096, `format` = JSON schema |
| Embedding | `nomic-embed-text` (tiền tố `classification: `), `bge-m3` |
| "now" | 2026-10-08 09:00 +07:00 (Thứ Năm) |
| User | `demo@thuchi.vn` (Nguyễn Minh Anh): 17 danh mục (14 hệ thống + Hiếu hỉ, Du lịch, Gia đình), 4 ví (MB Bank, Techcombank, Tiền mặt, MoMo). Đọc từ DB bằng `npm run context` |
| Chạy | Mọi lần gọi model đều chạy tuần tự, trừ phép đo đồng thời. GPU dùng tối đa 3,1 GB |

### Bộ đề (viết tay, nằm trong `ai/eval/data/`)

| Tập | Số câu | Dùng để |
|---|---|---|
| `ghi.test.json` | 120 câu, 123 khoản, 8 câu cần hỏi lại | Chấm điểm. Không dùng để chỉnh prompt |
| `ghi.dev.json` | 25 câu | Chỉnh prompt (2 vòng) |
| `ghi.blind.json` | 50 câu | Đề "mù" cho parser: một agent khác viết, không xem code parser. Chỉ chấm tiền, ngày, ví và số khoản |
| `bank.seed.json` | 40 ví dụ | Kho kNN của V3. 5 ví dụ đầu là few-shot cố định của V2, 10 ví dụ đầu là kho nhỏ ban đầu của V4 |
| `ghi.sim.json` | 200 lượt | Mô phỏng người dùng cho V4. Sinh từ từ vựng thói quen (`SIM_VOCAB`, lấy từ tiêu đề giao dịch thật của user demo), seed cố định. Không trùng câu nào với test hay dev; script kiểm tra điều này |
| `router-source.ts` | 78 câu mẫu, 25 dev, 83 test | Router: 9 skill |

Cách chấm: `title` khớp lỏng (bỏ dấu, chứa nhau hoặc trùng ≥ 50% token; một khoản có thể có nhiều đáp án, ngăn bởi `/`). Các trường còn lại phải khớp tuyệt đối. **item%** = khoản đúng hết `amount + categoryName + type + date + walletName` (không tính title). **case%** = cả câu đúng, gồm số khoản và quyết định hỏi lại.

## 2. ghi-giao-dich — các biến thể (TEST, 120 câu)

| Biến thể | case% | item% | title | amount | category | type | date | wallet | hỏi lại đúng | hỏi lại thừa | p50 ms |
|---|---|---|---|---|---|---|---|---|---|---|---|
| V0 chỉ model + schema | 41.7 | 44.7 | 94.6 | 91.3 | 73.9 | 94.6 | 92.4 | 92.4 | 4/8 | **31**/112 | 2428 |
| V1 + parser + hậu kiểm | 73.3 | 70.7 | 91.1 | **100** | 70.7 | 95.1 | **100** | **100** | 8/8 | 0 | 1365 |
| V2 V1 + 5-shot cố định | 78.3 | 76.4 | 96.7 | 100 | 76.4 | 94.3 | 100 | 100 | 8/8 | 0 | 1028 |
| V3 V1 + kNN 5-shot (nomic, kho 40) | **80.8** | **79.7** | 98.4 | 100 | 79.7 | 95.9 | 100 | 100 | 8/8 | 0 | 1030 |
| V3 với bge-m3 | 79.2 | 78.0 | 98.4 | 100 | 78.0 | 95.1 | 100 | 100 | 8/8 | 0 | 998 |
| V4@200 lượt (kho + luật, nomic) | **87.5** | **86.2** | 87.0 | 100 | 86.2 | – | 100 | 100 | 8/8 | 0 | – |

- Từ V1 trở đi, tiền, ngày và ví đều do code parser xử lý. Item% vì thế chỉ còn phụ thuộc vào danh mục.
- **Parser trên đề mù 50 câu: tiền 100%, ngày 100%, ví 100%, số khoản 100%, hỏi lại 6/6** (`ghi-blind-parser.json`). Đề mù có: 1 xị, 5 chục, 3 trăm, 45,000 đ, 1 triệu 2, "quý 3 … 1tr8", "5kg gạo 120k", thứ X tuần trước, mùng/ngày N, 3 khoản trong một câu.
- Có JSON schema thì lần nào JSON cũng hợp lệ: 0 lần retry, 0 lần lùi về danh mục mặc định. Lỗi còn lại đều là lỗi về nghĩa.
- Trường `type` của V1–V3 đúng ~95% vì nó lấy theo danh mục (hậu kiểm). Sai type luôn đi kèm sai danh mục.

## 3. Tự học (V4) — đường cong trên TEST

Bắt đầu như V3 nhưng kho chỉ có 10 ví dụ, chưa có luật. "User" dùng 200 lượt trên `ghi.sim.json`: nháp đúng thì xác nhận, nháp sai thì sửa. Cả hai trường hợp đều ghi ví dụ vào kho và tăng bộ đếm luật. Luật bật khi đạt support ≥ 3 và precision ≥ 0.85, tắt khi số lần có hại ≥ 2 và nhiều hơn số lần có ích.

| Lượt | Kho | Luật bật | item% | category% | title% | case% | Luật áp trên test (sai) |
|---|---|---|---|---|---|---|---|
| 0 | 10 | 0 | 82.1 | 82.1 | 98.4 | 84.2 | 0 |
| 50 | 55 | 4 | 82.9 | 82.9 | 91.1 | 84.2 | 4 (0) |
| 100 | 88 | 11 | 85.4 | 85.4 | 87.8 | 86.7 | 10 (1) |
| 200 | 123 | 38 | **86.2** | **86.2** | 87.0 | **87.5** | 27 (1) |

| Ablation tại 200 lượt | item% | title% |
|---|---|---|
| Cả kho lẫn luật (V4) | 86.2 | 87.0 |
| Chỉ kho kNN đã lớn (không luật) | 84.6 | 87.0 |
| **Chỉ luật + kho 10 ban đầu** | 85.4 | **98.4** |

- Tỉ lệ nháp được chấp nhận ngay trong lúc mô phỏng (cùng phân bố với dữ liệu học), theo khối 50 lượt: **52% → 58% → 64% → 76%**. Luật được áp 35 lần, đúng 35.
- **Lần đầu cách tách từ khóa còn hỏng, và tôi giữ lại kết quả đó** (`simulate-nomic_embed_text-keys-syllable.json`). Khi đó lấy cả unigram theo âm tiết, sinh ra luật rác kiểu `may → Du lịch` (từ "máy bay"), `gia → Hiếu hỉ` (từ "tân gia"), `com → Ăn uống`, `the → Ăn uống`, `tuan → Giải trí`. Đường cong là 82.1 → 83.7 → 86.2 → **82.9**, tức tụt ở 200 lượt với 80 luật bật. Bản sửa chỉ lấy bigram; unigram chỉ dùng khi cả khoản có đúng 1 âm tiết. Tôi sửa sau khi đọc danh sách luật học được (dữ liệu train), nhưng cũng đã thấy điểm test của bản đầu. Vì vậy con số 86.2 hơi lạc quan.
- Lỗi luật duy nhất trên test: `cuoi tuan → Giải trí` (học từ "cà phê cuối tuần") bắt nhầm "đám **cưới Tuấn**", vì bỏ dấu thì "cưới Tuấn" thành "cuoi tuan". Cần khóa luật theo chuỗi **còn dấu**.
- **Title tụt từ 98.4 xuống 87**, và đây là nhược điểm thật của kho kNN. Title chuẩn trong tập mô phỏng là nhãn chung chung ("Xe công nghệ", "Mua online", "Đăng ký giải trí"), nên model chép theo ví dụ. Bản "chỉ luật" giữ title ở 98.4.
- Mức tăng +4.1 điểm, tức 5 khoản trên 123, là nhỏ so với độ nhiễu của tập test cỡ này (khoảng ±6 điểm ở mức tin cậy 95%). Hướng đi đúng, nhưng cần tập lớn hơn mới chốt được con số.

## 4. Router (TEST 83 câu, 9 skill)

| Phương pháp | dev% | test% | Ngưỡng (chọn trên dev) | Nhầm lẫn chính |
|---|---|---|---|---|
| Luật từ khóa (không khớp thì hỏi lại) | 80 | 88.0 | – | ngoài phạm vi → hỏi lại ×6; ghi (câu thiếu tiền) → hỏi lại ×3 |
| kNN nomic-embed-text | 60 | 61.4 | – | ghi → tổng kết ×3; ngoài phạm vi → hỏi số dư ×3 |
| kNN bge-m3 | 84 | 71.1 | – | ghi → tổng kết ×4; tìm GD → tổng kết ×2 |
| Luật + kNN nomic | 88 | 84.3 | 0.75 | ngoài phạm vi rơi vào skill tài chính ×5 |
| **Luật + kNN bge-m3** | 88 | **91.6** | 0.30 | ngoài phạm vi → hỏi lại ×2; "300k" → ghi |

- Luật bắt được 68/83 câu. **Luật được viết sau khi đã viết TEST**, nên 88% là con số lạc quan. Số của kNN thì công bằng hơn.
- nomic-embed-text phân tách tiếng Việt kém: điểm cosine của câu đúng và câu sai đều dồn trong khoảng 0.75–0.97. Ví dụ "kể cho mình nghe chuyện vui" bị xếp vào kiem-tra-ngan-sach với điểm 0.94. bge-m3 trải điểm rộng hơn (0.46–0.97) và đúng hơn 10 điểm khi chạy kNN một mình.
- Ngưỡng của bge-m3 chọn trên dev là 0.30, tức gần như không bao giờ hỏi lại. Tập dev 25 câu quá nhỏ để chọn ngưỡng đáng tin.
- Lỗi đáng chú ý: "gợi ý quán ăn ngon ở **quận 1**" thành ghi-giao-dich, vì parser coi "1" là 1.000đ. Cần thêm "quận/phường/số nhà" vào danh sách từ đứng trước số không phải tiền. Tôi chưa sửa vì đây là lỗi thấy trên test.

## 5. Độ trễ (ấm, câu lấy từ DEV)

| Lời gọi | n | p50 ms | p95 ms |
|---|---|---|---|
| gemma2:2b, V1 (1 lần gọi) | 30 | 1339 | 1961 |
| gemma2:2b, V3 (kNN 5-shot, gồm cả embed) | 30 | 993 | 1272 |
| gemma2:2b, V0 (model tự làm hết) | 15 | 2390 | 3882 |
| V1 bỏ `stop: "\n\n"` | 15 | 1319 | 1413 |
| embed nomic-embed-text (1 câu) | 50 | 22 | 28 |
| embed bge-m3 (1 câu) | 50 | 182 | 200 |

| Đồng thời (12 request V3) | wall s | req/s | p50 ms | p95 ms |
|---|---|---|---|---|
| 1 | 12.7 | 0.95 | 1046 | 1288 |
| 2 | 12.7 | 0.95 | 1982 | 2430 |
| 3 | 11.4 | 1.06 | 2061 | 3012 |

- `OLLAMA_NUM_PARALLEL=1`, nên request đồng thời chỉ xếp hàng: thông lượng giữ ~1 req/s, còn độ trễ của mỗi người tăng gấp 2–3 lần. Muốn phục vụ nhiều người cùng lúc thì phải có hàng đợi ở backend và chấp nhận chờ, hoặc thử `NUM_PARALLEL` > 1 sau này. Đợt này không đổi cấu hình service.
- V3 nhanh hơn V1 dù prompt dài hơn: có ví dụ thì model sinh title ngắn hơn. Prompt eval rẻ, sinh token mới là đắt.
- VRAM: gemma2:2b 1835 MiB, bge-m3 633 MiB, nomic 308 MiB. Nạp cả 3 thì đỉnh 3152 MiB / 6144 MiB, vẫn dư chỗ.
- Thêm `stop "\n\n"` không đổi độ trễ đáng kể.

## 6. Lỗi hay gặp (V3 trên TEST)

1. **Thiên về "Mua sắm" khi câu có động từ "mua" / "chợ"**: 15/25 lỗi danh mục. Ví dụ: "mua rau 20k, thịt 85k, cá 60k ở chợ" thành Mua sắm (đúng là Ăn uống), "mua gạo", "đi chợ 230k", "mua bỉm cho con" (đúng là Gia đình), "mua sữa cho bé", "khám bệnh …, mua thuốc".
2. **Khoản thu bị đọc thành chi**: "dạy kèm được 1tr5" và "freelance thiết kế logo được 2tr" thành Giáo dục; "hoàn tiền shopee", "bán xe cũ được 8tr" thành Mua sắm; "ck cho mẹ 1tr" thì ngược lại, thành Được tặng. Bước hậu kiểm theo danh mục không cứu được, vì chính danh mục đã sai.
3. **Danh mục riêng hoặc mơ hồ của user**: "lì xì cháu" thành Hiếu hỉ (user ghi là Chi khác), "mừng tân gia" thành Gia đình, "cắt tóc", "tiền rác". Đây là loại lỗi mà luật học được sửa tốt.
4. **Title của câu không dấu**: "toi qua an oc" thành "Toi qua ăn uống", "cafe muoi" thành "Cafe Muối".
5. **V0**: hỏi lại thừa ở 31/112 câu, tiền sai 8 khoản ("lương về 15tr" thành 1.500.000), ngày và ví sai khoảng 8%. Đây là lý do mạnh nhất để dùng parser bằng code.

## 7. Bước nào giúp nhiều nhất

| Bước | item% thay đổi |
|---|---|
| Parser code + hậu kiểm (V0 → V1) | **+26.0** (44.7 → 70.7). Tiền, ngày, ví lên 100% và hết hỏi lại thừa |
| Few-shot cố định (V1 → V2) | +5.7 |
| kNN few-shot (V2 → V3) | +3.3 |
| Tự học 200 lượt (V4@0 → V4@200) | +4.1, chủ yếu nhờ luật. Luật một mình được +3.3 và giữ nguyên title |

Kho kNN 10 ví dụ (V4@0: 82.1) lại cao hơn kho 40 ví dụ (V3: 79.7). Kho to hơn không chắc tốt hơn; ví dụ gần nghĩa mới là thứ quan trọng.

## 8. Đề xuất cho thiết kế cuối

- **Pipeline ghi-giao-dich = V3 + luật học được** (V4 với khóa bigram):
  - parser bằng code, model chỉ điền `title` + `categoryName` theo enum;
  - luật chạy trước model;
  - kNN 5-shot lấy từ kho của chính user (ưu tiên) ∪ kho seed đã duyệt.
- **Mức chính xác nên kỳ vọng**:
  - tiền, ngày, ví gần 100% với những cách viết đã hỗ trợ;
  - danh mục khoảng 80% lúc mới, 85–87% sau vài trăm lần xác nhận;
  - do đó luôn cần bước xác nhận nháp (HITL).
- **Embedding: chọn `bge-m3`** cho router (luật + kNN được 91.6% so với 84.3% của nomic). Với kNN few-shot thì hai model ngang nhau (78.0 so với 79.7, chênh trong mức nhiễu). Nên dùng một model cho gọn. bge-m3 tốn ~180 ms mỗi câu và 633 MiB VRAM, chấp nhận được. Nếu cần nhanh thì nomic chỉ 22 ms nhưng router kém hơn.
- **Title**: không cho title trong ví dụ kNN đè lên. Hướng thử: ví dụ chỉ mang danh mục, còn title lấy từ model hoặc từ chuỗi đã làm sạch; hoặc chỉ đưa vào kho các ví dụ có title do user tự gõ.
- **Luật**: khóa theo chuỗi còn dấu (tránh vụ cưới Tuấn / cuối tuần), chỉ dùng bigram, giữ bộ đếm có ích / có hại. Luật lên mức chung toàn hệ thống thì cần admin duyệt, như DE-XUAT đã nêu.
- **Router**: luật → kNN bge-m3 → hỏi lại. Cần thêm câu mẫu cho `ngoai-pham-vi`, và chọn ngưỡng trên tập dev lớn hơn (≥ 100 câu).

## 9. Cách dữ liệu được tách theo user (isolation)

- Pipeline chỉ nhận `UserContext` của **một** user (`lib/types.ts`). `eval/load-context.ts` dựng object này bằng các truy vấn **đều lọc theo `userId`**:
  - danh mục: `"userId" IS NULL OR "userId" = $1`;
  - ví: `"userId" = $1`.

  Không có dữ liệu của user khác (DB demo có hàng chục danh mục "Lãi tiết kiệm" của các user khác, và chúng không lọt vào).
- `runGhi(text, ctx, { bank, rules })`: kho ví dụ và sổ luật là object riêng, truyền vào cho từng user. Module không giữ trạng thái dùng chung giữa các user. Thứ dùng chung duy nhất là cache embedding trên đĩa, khóa bằng sha1 của văn bản và chỉ chứa vector.
- Khi đưa vào backend: kho ví dụ và luật lưu trong Postgres theo `user_id` (RLS). Kho seed chung chỉ chứa ví dụ ẩn danh đã duyệt. Đợt đo này không sửa gì trong `backend/` hay `admin/`.

## 10. Việc còn mở

- Tập test còn nhỏ (123 khoản), nên chênh lệch dưới ~5 điểm chưa có ý nghĩa thống kê. Cần ≥ 500 câu, tốt nhất lấy từ log thật (đã ẩn danh).
- Parser được viết cùng lúc với test, nên con số 100% trên test là lạc quan. Đề mù 50 câu cũng đạt 100%, nhưng người viết đề dùng cùng quy ước. Chưa hỗ trợ: "chai" (1 triệu), "cành", "tr" viết rời kiểu "1 tr 2", số viết bằng chữ như "hai mươi lăm nghìn", ngày dạng "đầu tháng" / "cuối tuần trước", khoản chuyển tiền giữa hai ví, vay/nợ.
- Lỗi thiên về "Mua sắm": thử bỏ động từ "mua" khỏi đoạn trước khi đưa vào model, hoặc thêm luật seed cho đồ ăn. Chỉ được chỉnh trên dev, không chỉnh trên test.
- Ollama: JSON schema có `pattern` sẽ **làm grammar bị bỏ qua mà không báo lỗi** (0.30.10 / Vulkan), và model trả về markdown. Đừng dùng `pattern`.
- Chưa đo lớp trí nhớ user (biệt danh, ví hay dùng), chưa đo ngưỡng hỏi lại theo độ tự tin của danh mục, chưa so với `nomic-embed-text-v2-moe`.
- Mô phỏng dùng "user" hoàn hảo, luôn sửa đúng. User thật sẽ có nhiễu, nên ngưỡng precision ≥ 0.85 và bộ đếm có hại là cần thiết.

## Tái lập

```bash
cd ai && npm install
npm run context                                   # UserContext của demo@thuchi.vn từ DB
npx tsx eval/data/build.ts                        # sinh lại JSON bộ đề từ nguồn viết tay
npm run eval                                      # TEST, V0..V3 (~10 phút)
npm run eval -- --split test --variants V3 --embed bge-m3
npm run eval -- --split blind --variants P        # parser trên đề mù
npm run eval:router                               # luật / kNN nomic / kNN bge-m3 / kết hợp
npm run simulate                                  # V4: 200 lượt + đường cong + ablation (~20 phút)
npm run simulate -- --keys syllable               # bản tách khóa đầu tiên (để so)
npm run latency
```
