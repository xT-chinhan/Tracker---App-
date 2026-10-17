---
name: ghi-giao-dich
description: Biến câu tiếng Việt tự do ("ca phe 45k, grab 30k hôm qua trả momo") thành nháp giao dịch thu/chi để người dùng xác nhận / sửa / hủy.
model: gemma2:2b (Ollama, format = JSON schema, temperature 0)
---

# ghi-giao-dich

## Đầu vào
- `text`: câu người dùng.
- `ctx: UserContext` — chỉ dữ liệu của chính user: danh mục (hệ thống ∪ của user), ví, `now`.
- (V3/V4) kho ví dụ đã xác nhận + sổ luật đã học **của user đó**.

## Pipeline (biến thể V1–V4; V0 = chỉ model)
1. `parser/` (code, không LLM): `analyze(text, ctx)`
   - tách khoản, số tiền (`45k`, `1tr2`, `2 củ`, `2 lít`, `1 xị rưỡi`, `nửa củ`, `890.000đ`, `40 ngàn`), ngày (`hôm qua`, `bữa qua`, `thứ 2 tuần trước`, `15/9`, `mùng 2`), ví (`trả momo`, `ck mb`, `tcb`). "2 ký", "3 ly", "tháng 9" là số lượng, không phải tiền.
   - mỗi khoản có `clean` (bỏ dấu, cho kNN), `norm` (**còn dấu**, cho luật), `dia` (câu có dấu không), `dir` (tín hiệu THU/CHI, `parser/cues.ts`).
   - **Hỏi lại, không gọi model** khi: không có số tiền; có tiền nhưng không có nội dung ("300k", "tiêu hết 100k"); chuyển giữa các ví của chính user ("chuyển 1tr từ momo về mb", "rút 500k", "nạp 200k vào ví momo"); vay / cho vay / mượn / trả nợ. `meta.reason` = `transfer` | `loan` | `empty`.
2. Chốt danh mục bằng code (`decide()` trong `pipeline.ts`), theo thứ tự:
   1. luật đã học của user (V4): `từ khóa → danh mục` đủ ≥ 3 lần, độ chính xác ≥ 0.85, và cùng loại thu/chi với tín hiệu parser;
   2. tín hiệu THU (`lương`, `thưởng`, `lãi`/`cổ tức`, `được … cho/tặng/lì xì`, `mẹ cho`, `bán`, `hoàn tiền`, `cashback`, `freelance`, `… được 2tr`) → Lương / Thưởng / Đầu tư / Được tặng / Thu khác (`lexicon.ts: incomeCategory`). Câu bắt đầu bằng động từ chi (`mua`, `trả`, `cho mẹ`, `ck cho`, `lì xì cháu`) là CHI;
   3. từ điển (`lexicon.ts: lexiconCategory`): mọi từ nội dung là thực phẩm/đi chợ hoặc món ăn / đồ uống làm sẵn → Ăn uống ("mua rau 20k", "mua thịt gà ở chợ", "cf 45k", "cơm trưa 55k", "an sang 30k"; "nồi cơm điện", "cà phê hạt" thì không); bỉm/tã/sữa bột/đồ chơi → Gia đình; thuốc/khám/nha khoa → Sức khỏe.
3. Prompt ngắn (`prompt.ts`) + ví dụ: V2 = 5 ví dụ cố định, V3/V4 = 5 ví dụ gần nhất (kNN embedding bge-m3). Khoản có tín hiệu thu được đánh dấu `(THU)`.
4. gemma2:2b chỉ điền `title` + `categoryName` cho từng khoản đã tách (`schema.ts`). Enum **riêng từng khoản** qua `prefixItems`: khoản đã chốt → đúng 1 danh mục; khoản có tín hiệu thu/chi → chỉ danh mục loại đó; còn lại → mọi danh mục.
5. Sửa JSON không cần LLM → validate (kể cả enum từng khoản) → retry 1 lần kèm lỗi → lùi về "Chi khác"/"Thu khác".
6. Hậu kiểm: `type` lấy theo danh mục; tiền/ngày/ví lấy từ parser (model không được đụng).
7. Trả nháp → người dùng xác nhận / sửa / hủy → `learn/` ghi ví dụ + đếm luật.

## Luật học được (`learn/store.ts`)
- Khóa = bigram trên chuỗi **còn dấu** (`seg.norm`): luật "cuối tuần → Giải trí" (từ "cà phê cuối tuần") **không** khớp "đám cưới Tuấn".
- Chỉ khi câu người dùng **không dấu** mới lùi về so khớp bỏ dấu (gộp mọi khóa cùng dạng bỏ dấu; khóa trả về có tiền tố `~`).
- Bộ đếm có ích / có hại: luật tắt khi có hại ≥ 2 và nhiều hơn có ích.

## Ràng buộc với Ollama
- **Không dùng `pattern`** trong JSON schema: Ollama 0.30 (Vulkan) bỏ qua cả grammar mà không báo lỗi. `lib/ollama.ts: chat()` tự lọc `pattern`; ngày/tiền kiểm bằng code (`validDate`, `validAmount`). Test chặn: `npm test`.
- Mọi lệnh gọi Ollama khi đo chạy tuần tự qua `flock /tmp/app-tracker-gpu.lock …`.

## Đầu ra
`Draft { ask: boolean, items: { title, amount, categoryName, type, date (YYYY-MM-DD), walletName | null }[], meta: { reason?, decidedBy[], rules[], … } }`

## Backend
Backend (`backend/src/ai/ai.skills.ts`) chạy đúng các bước trên với dữ liệu học trong DB (luật `AiRule`, kNN `AiExample`) và LLM do backend tiêm vào; nạp `analyze`, `incomeCategory`, `lexiconCategory`, `cleanTitle`, `schemaV1`, `userV1` qua `ai.external.ts`. Sửa code trong `ai/` phải khởi động lại API.

## Đo
Bộ đề và cách chạy: `ai/results/BENCHMARK-2026-10-12-trackA.md`. Tập `test` là held-out; chỉ chỉnh trên `dev`.
