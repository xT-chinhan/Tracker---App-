# Track A — chất lượng ghi-giao-dich trên gemma2:2b (2026-10-12)

Nối tiếp [`BENCHMARK-2026-10-08.md`](BENCHMARK-2026-10-08.md). Nhánh `feat/ai-quality`. Số liệu thô: `ai/results/*-trackA.json` (bản mới), `*-base.json` (code `main` @ e3619a4 chạy trên bộ đề mới).

## 1. Thiết lập

| Mục | Giá trị |
|---|---|
| Máy | RTX 3050 6 GB. Ollama `OLLAMA_NUM_PARALLEL=1`. Mọi lệnh gọi Ollama bọc `flock /tmp/app-tracker-gpu.lock` (chạy chung máy với Track B, C), tuần tự |
| LLM / embedding | `gemma2:2b` (temperature 0, seed 7), embedding **bge-m3** cho mọi biến thể kNN |
| "now" / user | 2026-10-08 09:00 +07 (Thứ Năm), `demo@thuchi.vn` (17 danh mục, 4 ví) — như đợt trước |
| "Trước" (base) | Code `main` @ e3619a4 (worktree riêng), cùng bộ đề mới, cùng harness chấm |
| "Sau" (trackA) | Nhánh `feat/ai-quality`: V0–V3 đo ở 1c00838; mô phỏng V4 ở 0372f1a (thêm bản sửa "bằng" ≠ 3.000đ) |

### Bộ đề (546 câu viết tay + 400 lượt mô phỏng)

| Tập | Câu | Khoản | Hỏi lại | Vai trò |
|---|---|---|---|---|
| `test` | 266 | 278 | 23 | **Held-out**. Viết và commit (fdc2487) **trước** khi sửa pipeline. Không dùng để chỉnh |
| `blind` | 100 | 107 | 10 | **Đề mù**: một agent khác viết từ spec (quy ước nhãn + danh mục + ví), không được mở file nào trong repo. Tôi chỉ kiểm nhãn (không sửa nhãn nào); bỏ 8 câu trùng nguyên văn với dev/test |
| `dev` | 180 | 176 | 17 | Dùng để chỉnh: DEV cũ 25 + DEV2 35 (mới: chuyển ví, vay nợ, tín hiệu thu, đồ ăn có "mua") + **test cũ 120** (lỗi của nó đã được đọc ở đợt trước nên không còn held-out) |
| `test0` | 120 | 123 | 8 | Test cũ, chỉ để đặt số mới cạnh số cũ. **Đã bị nhìn** → số "sau" trên tập này lạc quan |
| `sim` | 400 lượt | | | Mô phỏng user cho V4 (sinh từ `SIM_VOCAB`, seed cố định), không trùng câu nào với test/dev/blind |
| `blindp` | 50 | | | Đề mù cũ chỉ chấm tiền/ngày/ví (giữ nguyên) |

Phủ: không dấu/teencode (cf, ts, ck, dc, t2, cn…), từ địa phương (má, ba, tía, hủ tiếu, hồi sáng, bữa qua, xe ôm, mì quảng, bánh bèo…), 2–4 khoản/câu, đơn vị (k, nghìn, ngàn, tr, triệu, củ, lít, xị, chục, trăm rưỡi, triệu rưỡi, 1tr250, 45.000đ, 1,5tr), ngày tương đối và tuyệt đối, 4 ví và ví không thuộc user (ZaloPay), mọi loại thu, hoàn tiền, chuyển giữa ví / vay nợ (→ hỏi lại), câu mơ hồ. Quy ước nhãn ghi ở đầu `TEST` trong `eval/data/ghi-source.ts` (giống spec đưa cho người viết đề mù).

### Chỉ số

- **item%**: khoản đúng hết `amount + categoryName + type + date + walletName` (không tính title).
- **accept%** (mới): nháp được chấp nhận **không cần sửa** — quyết định hỏi lại đúng, và nếu có nháp thì đủ khoản, mọi trường **kể cả title** đều đúng. Tính trên mọi câu.
- **[a–b]**: khoảng tin cậy 95% Wilson. **p**: McNemar chính xác hai phía trên **cùng** câu/khoản (base vs mới), trong ngoặc = số chỉ base đúng / chỉ bản mới đúng. Hai khoảng Wilson chồng nhau chưa có nghĩa là không khác: so cặp McNemar mạnh hơn nhiều.

## 2. Đã sửa gì (4 lớp lỗi của đợt trước)

| Lớp lỗi | Cách sửa | File |
|---|---|---|
| a. "mua"/"chợ" bị đoán thành Mua sắm | Từ điển thực phẩm tiếng Việt: chỉ chốt **Ăn uống** khi **mọi** từ nội dung của khoản là thực phẩm/đi chợ (bỏ "mua", "ở chợ", từ chỉ lượng). Bỉm/tã/sữa bột/đồ chơi → Gia đình; thuốc/khám/nha khoa → Sức khỏe. Mô tả danh mục trong prompt rõ hơn ("mua" không có nghĩa là Mua sắm). Từ điển bỏ dấu chỉ gồm cụm không nhập nhằng ("ca" = cá/cà, "bo" = bò/bố, "cho" = chợ/cho bị loại) | `skills/ghi-giao-dich/lexicon.ts`, `prompt.ts` |
| b. Thu bị đọc thành chi | Parser phát hiện tín hiệu THU/CHI trên chuỗi còn dấu (`parser/cues.ts`): lương, thưởng, lãi/cổ tức/chốt lời, "được … cho/tặng/lì xì", "mẹ cho #", bán/thanh lý/pass, hoàn tiền/cashback, freelance/làm thêm/tiền công, "… được #". Câu bắt đầu bằng động từ chi (mua, trả, cho mẹ, ck cho, lì xì cháu) là CHI. Khoản THU được chốt danh mục thu bằng code. Thêm **enum riêng từng khoản** (`prefixItems`): khoản đã chốt → 1 danh mục; khoản có tín hiệu → chỉ danh mục loại đó | `parser/cues.ts`, `lexicon.ts`, `schema.ts`, `pipeline.ts` |
| c. Luật học được bắt nhầm sau khi bỏ dấu | Khóa luật = bigram trên chuỗi **còn dấu** (`seg.norm`, NFC + đặt dấu kiểu mới). Chỉ câu **không dấu** mới lùi về khớp bỏ dấu (khóa trả về có tiền tố `~`). Test: "cà phê cuối tuần" không bắt "đám cưới Tuấn"/"mừng cưới Tuấn" | `learn/store.ts`, `parser/norm.ts` |
| d. Ollama bỏ qua schema có `pattern` | `chat()` lọc từ khóa `pattern` trước khi gửi; V0 kiểm ngày/tiền bằng code (`validDate`, `validAmount`); test chặn `pattern` trong mọi schema | `lib/ollama.ts`, `pipeline.ts`, `test/ghi.test.ts` |

Thêm:
- **Hỏi lại thay vì ghi chi** khi: chuyển giữa các ví của chính user ("chuyển 3tr từ tcb qua momo", "rút 500k", "nạp 200k vào ví momo"), vay/cho vay/mượn/trả nợ, hoặc có tiền mà không có nội dung ("300k", "ck 500k", "tiêu hết 100k"). `meta.reason` = `transfer` / `loan` / `empty` để router/backend chuyển sang luồng khác.
- **Phát hiện thêm khi làm**: `prefixItems` đi kèm `items` thì grammar của Ollama dùng `items` và **lặng lẽ bỏ qua** enum từng khoản (cùng loại lỗi với `pattern`). Schema giờ chỉ dùng `prefixItems`; có test chặn. Sau sửa: 0 lần retry trên dev (trước 26 lần).
- Từ đệm so khớp trên chuỗi còn dấu: "trà sữa" không còn mất chữ "trà" (bản bỏ dấu coi "tra" = "trả"); "đã" là từ đệm, "đá" thì không (Track C báo).
- Hậu kiểm title: bỏ tiền/ví/ngày model chép vào title, dùng chính bộ tìm tiền/ngày/ví của parser nên "iPhone 15 Pro", "Lương tháng 9" giữ nguyên (`skills/ghi-giao-dich/title.ts`, Track C báo).
- "2 ký" là số lượng; số viết bằng chữ phải có khoảng trắng trước đơn vị ("bằng" ≠ "ba"+"ng" = 3.000đ, Track B báo); "45.000đ" không làm câu không dấu thành câu có dấu.
- `eval/gate.ts: evaluateRule()` — cổng kiểm định cho vòng học ban đêm (mục 7).

Chỉnh trên dev đúng 2 vòng (dev V3: 93.2 → 93.8 item%); sau đó đóng băng code rồi mới chạy test/blind.

## 3. Kết quả V0–V3: trước / sau (bge-m3)

### TEST (held-out, 266 câu / 278 khoản)

| Biến thể | item% trước | item% sau | p (item) | accept% trước | accept% sau | p (accept) | category% | type% | hỏi lại đúng | hỏi lại thừa |
|---|---|---|---|---|---|---|---|---|---|---|
| V0 chỉ model | 32.0 [26.8–37.7] | 25.9 [21.1–31.4] | 0.0095 (28/11) | 26.3 [21.4–31.9] | 21.8 [17.3–27.1] | 0.058 | 67.9 → 76.3 | 95.2 → 94.9 | 12/23 → 18/23 | 111 → 156 |
| V1 parser + hậu kiểm | 63.3 [57.5–68.8] | **82.4** [77.5–86.4] | <0.001 (6/59) | 51.1 [45.1–57.1] | **70.7** [64.9–75.8] | <0.001 | 63.3 → 82.4 | 89.2 → 98.2 | 8/23 → 22/23 | 0/0 → 0/0 |
| V2 + 5-shot cố định | 69.8 [64.1–74.9] | **88.1** [83.8–91.4] | <0.001 (5/56) | 60.2 [54.2–65.8] | **82.3** [77.3–86.4] | <0.001 | 69.8 → 88.1 | 88.8 → 98.9 | 8/23 → 22/23 | 0 → 0 |
| V3 + kNN 5-shot | 74.1 [68.6–78.9] | **91.4** [87.5–94.1] | <0.001 (5/53) | 66.9 [61.1–72.3] | **87.2** [82.7–90.7] | <0.001 | 74.1 → 91.4 | 89.2 → 98.6 | 8/23 → 22/23 | 0 → 0 |

### BLIND (đề mù, 100 câu / 107 khoản)

| Biến thể | item% trước | item% sau | p (item) | accept% trước | accept% sau | p (accept) | category% | type% | hỏi lại đúng | hỏi lại thừa |
|---|---|---|---|---|---|---|---|---|---|---|
| V0 | 27.1 [19.6–36.2] | 27.1 [19.6–36.2] | 1 (7/7) | 26 [18.4–35.4] | 28 [20.1–37.5] | 0.75 | 68.7 → 79.2 | 95.5 → 98.1 | 8/10 → 9/10 | 39 → 52 |
| V1 | 61.7 [52.2–70.3] | **83.2** [75.0–89.1] | <0.001 (4/27) | 43 [33.7–52.8] | **69** [59.4–77.2] | <0.001 | 61.7 → 83.2 | 92.5 → 99.1 | 2/10 → 9/10 | 0 → 0 |
| V2 | 72.0 [62.8–79.6] | **88.8** [81.4–93.5] | <0.001 (1/19) | 57 [47.2–66.3] | **82** [73.3–88.3] | <0.001 | 72 → 88.8 | 92.5 → 100 | 2/10 → 9/10 | 0 → 0 |
| V3 | 72.0 [62.8–79.6] | **85.0** [77.1–90.6] | 0.0013 (2/16) | 61 [51.2–70.0] | **79** [70.0–85.8] | <0.001 | 72 → 85 | 93.5 → 99.1 | 2/10 → 9/10 | 0 → 0 |

### TEST0 (test cũ 120 câu — để so với số cũ; đã bị nhìn nên số "sau" lạc quan)

| Biến thể | item% đợt 10-08 (báo cáo cũ) | item% trước (chạy lại) | item% sau | p | accept% trước → sau |
|---|---|---|---|---|---|
| V0 | 44.7 (nomic) | 43.1 | 38.2 | 0.18 | 38.3 → 33.3 |
| V1 | 70.7 | 73.2 | **91.9** | <0.001 | 68.3 → 80.0 |
| V2 | 76.4 | 75.6 | **91.1** | <0.001 | 74.2 → 90.0 |
| V3 | 78.0 (bge-m3) | 78.0 | **91.9** | <0.001 | 77.5 → 90.0 |

V3 bge-m3 chạy lại cho đúng 78.0 như báo cáo cũ (tái lập được). V1/V2 lệch 1–2,5 điểm so với số cũ dù cùng code; nguyên nhân chưa rõ (V3 khớp tuyệt đối), nhiều khả năng Ollama không hoàn toàn tất định giữa các lần nạp model. Mức lệch này nằm trong khoảng tin cậy.

### Các trường khác (test / blind)

| | V1 trước → sau | V3 trước → sau |
|---|---|---|
| amount, date, wallet | 100 / 100 / 100 → 100 / 100 / 100 (cả hai tập) | như V1 |
| số khoản đúng (count%) | test 97.9 → 98.8 · blind 97.8 → 97.8 | như V1 |
| title | test 87.1 → 87.1 · blind 86.9 → 81.3 | test 97.1 → 97.1 · blind 94.4 → 93.5 |
| p50 / p95 ms | test 1241/2158 → 1450/1812 | test 854/1338 → 950/1375 |

### Lớp lỗi: đếm lỗi trước → sau

| Lỗi | test V1 | test V3 | blind V1 | blind V3 |
|---|---|---|---|---|
| Đoán "Mua sắm" sai | 61 → 24 | 34 → **7** | 25 → 9 | 17 → 6 |
| Sai loại thu/chi (type) | 30 → 5 | 30 → **4** | 8 → 1 | 7 → 1 |
| Quyết định hỏi lại sai | 15 → 1 | 15 → **1** | 8 → 1 | 8 → 1 |
| Sai danh mục khác | 41 → 25 | 38 → 17 | 16 → 9 | 13 → 10 |

**Đọc kết quả**
- V1–V3 tăng **+17 đến +19 điểm item%** trên test và **+13 đến +21** trên đề mù, mọi chênh lệch đều có ý nghĩa thống kê (McNemar p ≤ 0.0013). Đề mù đi cùng chiều với test nên không phải do chỉnh theo test.
- Tỉ lệ nháp **dùng được ngay không cần sửa** (accept%) của V3: test 66.9 → **87.2**, đề mù 61 → **79**.
- Hỏi lại đúng: 8/23 → 22/23 (test) và 2/10 → 9/10 (blind), không có hỏi lại thừa. Bản cũ ghi "chuyển 3tr từ tcb qua momo" và "cho Hùng vay 2tr" thành khoản chi.
- Trên đề mù, V2 (88.8) và V3 (85.0) không khác nhau có ý nghĩa: khoảng tin cậy rộng ±7 điểm với 107 khoản.
- **V0 tệ đi** trên test (32.0 → 25.9, p = 0.0095; hỏi lại thừa 111 → 156). Prompt V0 dùng chung khối mô tả danh mục đã dài hơn, và model 2B tự làm hết thì hỏi lại nhiều hơn. V0 không phải đường chạy thật; ghi lại để biết mô tả dài có hại khi model phải tự làm mọi việc.

## 4. Tự học (V4) — đường cong 0/50/100/200/400 lượt

Bắt đầu với kho 10 ví dụ, chưa có luật. "User" mô phỏng xác nhận/sửa trên `sim` (400 lượt). Luật bật ở support ≥ 3, precision ≥ 0.85.

### TEST (266 câu)

| Lượt | Kho | Luật bật (sau) | item% trước | item% sau | accept% trước | accept% sau | title% sau | Luật áp trên test / sai: trước → sau |
|---|---|---|---|---|---|---|---|---|
| 0 | 10 | 0 | 71.2 [65.6–76.2] | **87.4** [83.0–90.8] | 63.2 | **83.1** | 96.4 | 0 → 0 |
| 50 | 55 | 4 | 72.3 [66.8–77.2] | 89.6 [85.4–92.6] | 59.0 | 75.9 | 85.6 | 5/0 → 5/0 |
| 100 | 88 | 11 | 77.3 [72.1–81.9] | 92.1 [88.3–94.7] | 62.0 | 75.6 | 83.5 | 14/3 → 11/0 |
| 200 | 123 | 42 | 77.3 [72.1–81.9] | 92.4 [88.7–95.0] | 59.4 | 77.1 | 84.9 | 40/3 → 43/1 |
| 400 | 150 | 116 | 81.3 [76.3–85.4] | **92.4** [88.7–95.0] | 63.5 | 75.2 | 82.4 | 103/8 → 104/6 |

### BLIND (100 câu)

| Lượt | item% trước | item% sau | accept% trước | accept% sau | title% sau |
|---|---|---|---|---|---|
| 0 | 72.9 [63.8–80.4] | **86.9** [79.2–92.0] | 61 | **82** | 95.3 |
| 50 | 72.9 | 86.0 | 59 | 73 | 85.0 |
| 100 | 74.8 | 92.5 | 57 | 72 | 81.3 |
| 200 | 74.8 | 90.7 | 61 | 77 | 85.0 |
| 400 | 83.2 [75.0–89.1] | **90.7** [83.6–94.8] | 64 | 75 | 84.1 |

### Ablation tại 400 lượt (bản sau)

| | test item% | test accept% | blind item% | blind accept% |
|---|---|---|---|---|
| Kho + luật (V4@400) | 92.4 [88.7–95.0] | 75.2 | 90.7 [83.6–94.8] | 75 |
| Chỉ kho kNN đã lớn (không luật) | 92.1 [88.3–94.7] | 74.8 | 90.7 | 75 |
| **Chỉ luật + kho 10 ban đầu** | 90.6 [86.6–93.5] | **86.5** [81.8–90.1] | 90.7 | **86** [77.9–91.5] |

So cặp (McNemar, bản sau):

| So sánh | test | blind |
|---|---|---|
| item%: V4@0 → V4@400 | +5.0 điểm, **p = 0.016** (8 tụt / 22 lên) | +3.8, p = 0.39 (4/8) — chưa đủ chứng cứ |
| accept%: V4@0 → V4@400 | **−7.9 điểm, p = 0.013** (43 tụt / 22 lên) | −7, p = 0.23 |
| accept%: chỉ luật vs V4@400 | chỉ luật hơn 11.3 điểm, **p < 0.001** | hơn 11, **p = 0.027** |
| item%: V4@0 → chỉ luật | +3.2, **p = 0.035** | +3.8, p = 0.22 |

Nháp được chấp nhận ngay trong lúc mô phỏng (cùng phân bố với dữ liệu học), theo khối 50 lượt: 56% → 62% → 74% → 80% → 92% → 82% → 86% → 78%. Luật được áp 154 lần khi mô phỏng, đúng cả 154.

**Đọc kết quả**
- Điểm xuất phát của bản sau (V4@0 = 87.4) đã cao hơn điểm **cuối** của bản trước sau 400 lượt (81.3). Phần lớn cái lợi đến từ code (parser + tín hiệu + từ điển), không phải từ học.
- Học vẫn giúp phần danh mục (+5 điểm item% trên test, có ý nghĩa), nhưng **kho kNN làm tụt title**: title chuẩn trong `sim` là nhãn chung chung ("Xe công nghệ", "Mua online", "Đăng ký giải trí") và model chép theo ví dụ. Vì thế accept% (cần title đúng) **giảm** 8 điểm, có ý nghĩa thống kê.
- **"Chỉ luật" là cấu hình tốt nhất cho người dùng**: item% gần bằng V4 đầy đủ (90.6 so với 92.4, chênh nằm trong nhiễu) và accept% cao hơn rõ (86.5 so với 75.2, p < 0.001).
- Khóa luật còn dấu và kiểm tra loại thu/chi hoạt động đúng như thiết kế. Bản trước, ở 100–400 lượt, áp nhầm `li xi → Chi khác` vào "được bà nội lì xì 500k" và "dc li xi 200k" (khoản thu), và `cuoi tuan` vào "làm thêm **cuối tuần** được 800 nghìn". Bản sau không còn các lỗi này.
- Luật sai còn lại của bản sau đều từ các bigram quá chung: `cho con` (học từ "đồ cho con → Gia đình", áp nhầm lên "học phí cho con", "khám bệnh cho con"), `về nhà`, `đi chợ` ("cho mẹ 500k đi chợ"). Hướng sửa: không học khóa mà cả hai âm tiết đều thuộc danh sách "từ chức năng mở rộng" (cho, con, về, nhà, đi), hoặc chạy `evaluateRule` trước khi bật luật.
- Bản trước: mô phỏng bị dừng ở bước ablation (giới hạn thời gian chạy nền 2 giờ). Đường cong đủ 5 mốc nằm trong `simulate-bge_m3-keys-bigram-base.log`; không có ablation và JSON cho bản trước. Bản sau: `simulate-bge_m3-keys-bigram-trackA.json`.

## 5. Lỗi còn lại (V3 sau sửa, test + blind)

1. **Model vẫn mặc định "Mua sắm" / chọn bừa khi không có tín hiệu** (khoảng 25 khoản): siêu thị/bách hóa xanh/winmart, thay nhớt, sách giáo khoa, game Steam, nạp điện thoại; vài khoản chi không có tín hiệu bị chọn danh mục THU ("winmart 250k" → Thu khác, "trả cash 50k tiền gửi xe" → Thu khác). Hướng sửa (chưa làm vì thấy trên test): **khoản không có tín hiệu thu thì enum chỉ gồm danh mục CHI** — thu hầu như luôn có tín hiệu; thêm siêu thị/bách hóa xanh/winmart vào từ điển Ăn uống. Cần kiểm trên dev mới.
2. **Danh mục riêng của user**: lì xì cho người khác → Chi khác (model chọn Giải trí), cắt tóc/gội đầu, ăn giỗ/thôi nôi → Hiếu hỉ (model chọn Gia đình). Đúng loại lỗi luật học được sẽ sửa.
3. **Từ chỉ lượng chưa có trong parser**: "1 thùng", "2 ổ", "1 chục trứng" bị đọc thành tiền → tách thừa khoản (4 câu). "chục" vừa là đơn vị tiền ("5 chục" = 50k) vừa là lượng, cần quy tắc theo ngữ cảnh.
4. **Thu không có từ khóa**: "nhận tiền viết bài", "được công ty hỗ trợ xăng 500k".
5. **Chưa hỏi lại**: "gửi tiết kiệm 10tr" (chưa coi là chuyển tiền), "cho Nam vay 2tr" (câu không dấu: mẫu bỏ dấu của "vay" bị siết để tránh nhầm "váy").
6. **Title kNN chép nhãn chung chung** (V4, mục 4).
7. Đã sửa sau khi đo, số trong báo cáo là **trước** khi sửa: "250k bằng zalopay" (1 câu test, tách thừa khoản 3.000đ) và "shopee hoan tien 45.000đ" (1 câu blind, ký hiệu đ làm câu bị coi là có dấu). Ảnh hưởng tối đa +1 câu mỗi tập.

## 6. Tái lập

```bash
cd ai && npm install
npm test                                              # 20 test, không cần Ollama
npx tsx eval/data/build.ts                            # sinh lại JSON bộ đề
L=/tmp/app-tracker-gpu.lock
flock $L npm run eval -- --split test,blind,test0 --variants V1 --tag trackA   # lần lượt V0..V3
flock $L npm run simulate -- --tag trackA             # V4: 0/50/100/200/400 lượt + ablation, test + blind
flock $L npm run eval -- --split dev --variants V1,V3 # chỉ chỉnh trên dev
npx tsx eval/report.ts --dirs <thư mục results của bản base>   # bảng trước/sau + McNemar
```
"Trước" = cùng lệnh chạy trong worktree của `main` @ e3619a4, sau khi chép `eval/{run,simulate,score,stats}.ts` và `eval/data/ghi.*.json` mới vào.

## 7. Cổng kiểm định cho vòng học ban đêm (`ai/eval/gate.ts`)

```ts
export type Proposal =
  | { kind: 'rule'; key: string; categoryName: string }   // key: bigram CÒN DẤU như RuleBook ("trà đá") hoặc 1 âm tiết ("grab")
  | { kind: 'example'; example: Example };                 // ví dụ mới cho kho kNN

export interface GateOptions {
  ctx: UserContext; cases: GhiCase[]; bank: ExampleBank; rules: RuleBook;
  maxRegressions?: number;   // số khoản được phép từ đúng → sai (mặc định 0)
  minGain?: number;          // số khoản tối thiểu phải từ sai → đúng (mặc định 0)
}
export interface GateScore { cases: number; items: number; itemsExact: number; accepted: number }
export interface GateResult {
  pass: boolean; reason: string; affected: string[];
  before: GateScore; after: GateScore;   // tính trên các câu bị ảnh hưởng
  regressions: string[]; fixes: string[];
}
export async function evaluateRule(p: Proposal, o: GateOptions): Promise<GateResult>
```
- Không sửa `bank`/`rules` gốc (dùng `clone()`); luật đề xuất được gắn bằng `RuleBook.pin(key, cat)`.
- Chỉ chạy model trên câu mà đề xuất **đổi được** (luật khớp khác đi, hoặc top-5 kNN đổi), nên rẻ. Ví dụ trên dev: luật "cắt tóc → Chi khác" chạm 1 câu, pass (+1/−0); luật sai "tiền điện → Mua sắm" chạm 5 câu, fail (5 khoản đúng → sai).
- Gọi Ollama → backend phải xếp hàng (cùng khóa GPU) khi chạy ban đêm.

## 8. File dùng chung đã đổi (đều chỉ thêm, tương thích ngược)

| File | Thay đổi |
|---|---|
| `ai/lib/ollama.ts` | Thêm `stripUnsupported()` + `UNSUPPORTED_SCHEMA_KEYS`; `chat()` lọc từ khóa `pattern` (giá trị chuỗi) trước khi gửi. Thuộc tính tên "pattern" trong `properties` vẫn giữ |
| `ai/eval/common.ts` | Không đổi |
| `ai/parser/*` (router của Track B dùng `parse()`) | `parse()` giữ nguyên chữ ký và các trường cũ; `Segment` thêm `norm`, `dia`, `dir`; thêm `analyze()`. Hành vi đổi: `clean` của câu có dấu không còn mất chữ "trà"; "vs" là dấu tách khoản; "2 ký" không còn là tiền; số viết bằng chữ cần khoảng trắng trước đơn vị |
| `ai/learn/store.ts` | `RuleBook.observe/match` nhận thêm `Segment` (chuỗi `clean` như cũ vẫn chạy); thêm `foldCounts`, `pinned`, `pin()`, `clone()`; `ExampleBank.clone()` |
| `ai/eval/{run,simulate,score}.ts` | Nhiều split, `--tag`, mặc định bge-m3, accept%, KTC Wilson, cờ từng câu/khoản; `summarize()` thêm `accept`, `counts`, `ci` (trường cũ giữ nguyên) |
| Mới | `eval/stats.ts`, `eval/report.ts`, `eval/gate.ts`, `test/ghi.test.ts`, `npm test` |
