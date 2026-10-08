# Research: GitHub + papers + OSS cho "skill tự cải thiện, không fine-tune"

Ngày: 2026-10-08. Phạm vi: GitHub, paper, OSS phổ biến. (skills.sh và mcpmarket.com do agent khác lo.)
Ràng buộc: NestJS (TS) + Postgres, Ollama `gemma2:2b` + `nomic-embed-text` trên RTX 3050 6GB, không fine-tune, AI tách biệt từng user, AI admin ở mức quản lý, draft có HITL (xác nhận / sửa / huỷ).

Độ tin cậy: các mục ghi **[verified]** đã được đối chiếu với README/paper/docs trong phiên này (nội dung web coi là dữ liệu chưa tin cậy). Các mục ghi **[known]** lấy từ kiến thức sẵn có, phiên này chưa kiểm lại.

---

## 0. TL;DR

1. **Không có thư viện nào giải quyết trọn bài toán này với model 2B.** Các framework memory/agent lớn (Letta, Graphiti, LangMem, Cognee, MemoryOS) đều dựa vào LLM mạnh để trích xuất, gọi tool hoặc tự phản tư. Chính docs của chúng cảnh báo model nhỏ dễ lỗi (Graphiti, Letta) **[verified]**.
2. Paper cho thấy model yếu tự phản tư thì bộ nhớ bị nhiễm nội dung sai. GPT-4o-mini dùng Dynamic Cheatsheet còn **tụt điểm** **[verified]**. ACE cũng nói thẳng: Reflector yếu thì context "noisy or even harmful", không có feedback tin cậy thì "both ACE and DC may degrade" **[verified]**.
3. Vì vậy cần **dời phần "học" ra khỏi model 2B**: dùng nhãn từ con người (xác nhận/sửa/huỷ) + luật/lexicon tất định + truy xuất few-shot từ ví dụ đã được xác nhận. Model 2B chỉ làm phần hẹp: điền JSON theo schema, có ví dụ đúng của chính user đó trong prompt.
4. Phản tư/curation kiểu ACE chạy **offline, theo lô, tuần tự, ban đêm**, có cổng chặn bằng bộ eval hồi quy. Admin duyệt trước khi áp dụng.
5. Toàn bộ runtime nên nằm trong NestJS + pgvector. Không cần Python sidecar khi chạy thật. Python/DSPy chỉ tuỳ chọn cho tối ưu offline; nếu muốn ở trong TS thì có Ax.

---

## 1. Xếp hạng đề xuất (tối đa 10)

| # | Thứ dùng | Dùng thế nào | Lý do |
|---|---|---|---|
| 1 | **Ollama structured outputs** (`format` = JSON Schema) + Zod | Thư viện/pattern trong Node | Ràng buộc output ở tầng sampling nên hợp với model 2B. Có ví dụ chính thức cho JS + `zodToJsonSchema`, khuyên đặt temperature 0 **[verified]** |
| 2 | **Dynamic few-shot retrieval** (kNN-ICL: Liu et al. 2021 "What Makes Good In-Context Examples for GPT-3?", arXiv 2101.06804) + **DSPy BootstrapFewShot** | Pattern tự viết trên pgvector | Theo paper DSPy, pipeline compiled vượt few-shot thường "over 65% for llama2-13b-chat", và T5-770M/llama2-13b đạt mức "competitive" với prompt chuyên gia viết cho GPT-3.5 **[verified]**. Đây là cơ chế "giỏi lên khi dùng" rẻ và chắc nhất |
| 3 | **ACE – Agentic Context Engineering** (arXiv 2510.04618, ICLR 2026) | Pattern: playbook dạng bullet có id + bộ đếm helpful/harmful, cập nhật delta, dedup bằng embedding **[verified]** | Định dạng tốt nhất cho "luật học được". Bộ đếm cập nhật tất định từ nhãn HITL, không cần LLM |
| 4 | **promptfoo** (MIT, Node) | CLI/lib Node, provider `ollama:chat:gemma2:2b`, `ollama:embeddings:*` **[verified]** | Bộ eval hồi quy làm cổng chặn mọi thay đổi prompt/playbook/lexicon. Đã về OpenAI (công bố 9/3/2026) nhưng README nói vẫn MIT **[verified]** |
| 5 | **chrono-node** (locale `vi` có trong `src/locales/vi`) **[verified]** + parser tiền VN tự viết | Thư viện Node | Bóc ngày/số tiền tất định trước khi gọi LLM. Không có lib nào parse "50k", "1tr2", "2 củ" **[verified: tìm không thấy]**, nên phải tự viết, khoảng 100 dòng |
| 6 | **Intent routing bằng embedding** (pattern của `aurelio-labs/semantic-router`, MIT, chỉ có Python, không có pgvector) **[verified]** | Chỉ lấy pattern, tự cài trong TS + pgvector | Route = tập câu mẫu, kNN + ngưỡng, có thể tối ưu ngưỡng. Câu mẫu lớn dần từ log đã xác nhận nên router tự tốt lên |
| 7 | **mem0** (Apache-2.0, ~67k★). Node OSS `mem0ai/oss` hỗ trợ **pgvector + Ollama** (LLM và embedder), history mặc định là SQLite **[verified]** | Lib Node, hoặc chỉ lấy pattern | Scope `userId`/session sẵn có. Nhưng bước trích xuất fact cần LLM ra JSON, mà model 3–4B hay lỗi JSON. Có `infer=false` để lưu thẳng **[verified]**. Nên dùng ở chế độ ghi tất định hoặc chỉ mượn thiết kế |
| 8 | **Anthropic Agent Skills format + skill-creator** (`anthropics/skills`, Apache-2.0 với phần lớn skill) **[verified]** | Pattern | `SKILL.md` (frontmatter `name`/`description`) để đóng gói skill. Vòng lặp của skill-creator đáng chép: `evals.json` → chạy có skill vs baseline → `grading.json` → benchmark → lặp; trigger-eval tách train/test 60/40 **[verified]** |
| 9 | **Ax** (`@ax-llm/ax`, Apache-2.0, "DSPy cho TypeScript") có `AxBootstrapFewShot`, `AxGEPA` **[verified]** | Lib Node, chỉ dùng offline | Tự động chọn demo/tối ưu instruction theo eval set mà không rời TS. GEPA (arXiv 2507.19457): hơn GRPO ~6% trung bình, tới 20%, dùng ít rollout hơn tới 35x **[verified]** |
| 10 | **ReasoningBank** (arXiv 2509.25140, ICLR 2026) / **Training-Free GRPO** (arXiv 2510.08191) / **ExpeL** (2308.10144) **[known]** | Pattern cho reflector offline | Học cả từ **thất bại**: với app này là các draft bị huỷ/sửa. Training-Free GRPO: "experiential knowledge as a token prior", chỉ cần vài chục mẫu **[verified]** |

Không đề xuất làm lõi (lý do ở mục 4): Letta/MemGPT, Graphiti/Zep, LangMem, Cognee, MemoryOS, A-MEM (lib), Reflexion online, Voyager, TextGrad, Outlines.

---

## 2. Kiến trúc đề xuất: "Self-improving skills without fine-tuning"

Mọi thứ chạy trong NestJS + Postgres (pgvector). Mỗi request chỉ một lần gọi model 2B. Phần học nằm trong dữ liệu.

```
User msg ──► [A] Pre-parse tất định (tiền VN, chrono vi, lexicon user)
          ──► [B] Router embedding (kNN trên utterance bank: user ∪ global, có ngưỡng)
                 └─ dưới ngưỡng → LLM phân loại với format enum → vẫn mơ hồ → hỏi lại user
          ──► [C] Dựng prompt cho skill:
                 skill.instructions (SKILL.md, có version)
               + top playbook bullets (helpful-harmful cao, cùng skill, user ∪ global)
               + memory user (fact đã xác nhận, top-k)
               + 3–5 few-shot từ example bank (của user trước, MMR, ưu tiên ví dụ "edited")
               + slot đã pre-parse (LLM không được ghi đè)
          ──► [D] gemma2:2b, format=JSONSchema(zod), temp 0 → zod.parse → 1 lần retry kèm lỗi
          ──► [E] Post-process: áp luật/lexicon (merchant→category…) đè lên output LLM
          ──► Draft → user: XÁC NHẬN / SỬA / HUỶ
          ──► [F] Ghi feedback (tất định, ngay lập tức):
                 confirm → example(label=gold), +1 helpful cho các bullet đã dùng
                 edit    → example(label=gold, input, output=bản sửa), lưu diff; +1 harmful;
                           field diff lặp lại ≥N lần → đề xuất luật lexicon (ví dụ "cf" → Cà phê)
                 cancel  → negative example, +1 harmful, ghi vào failure log
          ──► [G] Batch đêm (tuần tự, 1 job nặng mỗi lúc):
                 Reflector/Curator kiểu ACE trên failure log (có thể dùng model 7–9B lượng tử
                 hoá nếu VRAM cho phép, nếu không thì gemma2:2b + luật chặt) → đề xuất delta bullet
                 → dedup bằng embedding → chạy promptfoo regression → chỉ promote nếu
                 pass-rate ≥ baseline → admin duyệt (với bullet global)
```

### Bảng Postgres (tối thiểu)
- `ai_skill(id, name, description, version, instructions, json_schema, status)`: định dạng giống SKILL.md, có version để rollback.
- `ai_example(id, user_id NULL=global, skill, input_text, output_json, label[gold|negative], source[confirm|edit|cancel|seed], embedding vector, used_count, created_at)`.
- `ai_utterance(id, user_id NULL, intent, text, embedding)`: dữ liệu cho router.
- `ai_playbook_bullet(id, user_id NULL, skill, content, helpful, harmful, status[proposed|active|retired], embedding)`: format ACE.
- `ai_lexicon(user_id, kind[merchant_category|alias|account], key_norm, value, hits, confidence)`: luật tất định, không qua LLM.
- `ai_memory(id, user_id, session_id NULL, fact, embedding, source_draft_id, valid_from, valid_to)`: chỉ ghi fact đã được user xác nhận.
- `ai_feedback(draft_id, user_id, skill, action, before_json, after_json, bullets_used[], examples_used[])`: nguồn cho mọi lần học và eval.
- `ai_eval_case(id, skill, input, expected_json, origin_feedback_id, scope)`: eval set hồi quy lớn dần tự động từ các lần edit.

**Cách ly user:** bật Postgres RLS trên mọi bảng `ai_*` (`user_id = current_setting('app.user_id')` hoặc `user_id IS NULL` cho dữ liệu global đã được admin promote). Mọi truy vấn vector phải qua repository có `WHERE user_id = $1 OR user_id IS NULL`. Session là cột lọc phụ: memory thì theo user, hội thoại thì theo session.

**AI admin:** chỉ thấy view tổng hợp (pass-rate theo skill, tỉ lệ confirm/edit/cancel, bullet đang chờ duyệt, intent hay rơi). Truy vấn dữ liệu dùng tool SQL whitelist/tham số hoá. Không đọc memory thô của user. Promote example/bullet từ user lên global phải qua bước ẩn danh hoá và admin duyệt.

### Chi tiết quan trọng với gemma2:2b
- Ollama gemma2 có context **8K**, trang model không có badge "tools" **[verified]**. Vì vậy không dùng framework cần native tool-calling (Letta). Định tuyến bằng code, không để model tự chọn tool.
- Gemma không có system role riêng (template ghép system vào lượt user) **[known]**. Nên đặt chỉ dẫn ngắn, schema nhỏ, phẳng, dùng enum thay cho chuỗi tự do.
- Giữ prompt ≤ ~2–3K token. Bằng chứng gián tiếp: mem0 kể model 4B local lỗi JSON 3/3 lần với 407 token history thô, nhưng ổn khi chỉ đưa 247 token memory chắt lọc. Đây là bài vendor, chỉ coi là giả thuyết **[verified-as-claim]**.
- **Embedding:** `nomic-embed-text` (v1.5) tối ưu cho tiếng Anh. Cho tiếng Việt nên A/B với `nomic-embed-text-v2-moe` (đa ngữ ~100 ngôn ngữ, có listing ghi có `vi`, nhưng **chỉ 512 token**) hoặc `bge-m3` (567M, 1.2GB, >100 ngôn ngữ, 8K ctx) **[verified]**. Chuẩn hoá văn bản trước khi embed: lowercase, chuẩn Unicode NFC, có thể lưu thêm bản bỏ dấu. Đổi model embed thì phải re-embed toàn bộ.
- **VRAM 6GB:** gemma2:2b (1.6GB) + bge-m3 (1.2GB) chạy cùng lúc được. Reflector 7–9B (gemma2:9b là 5.4GB) **[verified size]** chỉ nên chạy riêng trong batch đêm, không chạy song song với gì khác.

### Parser tiền/ngày tiếng Việt (tự viết, tất định)
- Tiền: `(\d+(?:[.,]\d+)?)\s*(k|nghìn|ngàn|tr|triệu|củ|m|tỷ|tỉ|lít|xị)?(\d+)?`. Quy ước: `1tr2` = 1.200.000, `2m5` = 2.500.000, `50k` = 50.000, `lít`/`xị` = 100k (tiếng lóng, nên để thành lexicon user có thể sửa). Có thể dùng `read-vietnamese-number` / `@hckhanh/vn-number` để hiển thị/đọc số thành chữ (chiều ngược lại) **[verified: không parse shorthand]**.
- Ngày: `chrono-node` có locale `vi` **[verified]**, nhưng chưa xác nhận nó hiểu "hôm qua", "hôm kia", "thứ 2 tuần trước", "đầu tháng". Phải viết test và bổ sung bằng refiner/regex riêng.
- `underthesea` (Python, Apache-2.0) có tách từ, NER, `text_normalize` **[verified]**. Chỉ cần nếu sau này phải xử lý NLP nặng. Không nên thêm sidecar chỉ vì nó.

### Thứ tự triển khai
1. [D]+[A]+[E]: structured output + parser + lexicon. Riêng bước này đã giải quyết phần lớn lỗi.
2. [F] feedback → example bank + eval set tự sinh.
3. [C] dynamic few-shot + [B] router kNN.
4. promptfoo regression trong CI/batch.
5. [G] playbook ACE (bộ đếm tất định trước, reflector LLM sau).
6. (Tuỳ chọn) Ax/DSPy chọn demo hoặc instruction offline.

---

## 3. Bảng đầy đủ

| Tên | Loại | Link | Dùng ra sao ở đây | Self-host / Postgres | Cách ly user | Ollama / model nhỏ (bằng chứng) | License | Độ chín |
|---|---|---|---|---|---|---|---|---|
| Ollama structured outputs | Tính năng runtime | https://ollama.com/blog/structured-outputs | `format: zodToJsonSchema(schema)` | Local | N/A | Chính chủ, ra 06/12/2024 **[verified]** | MIT **[known]** | Production |
| mem0 | Memory layer | https://github.com/mem0ai/mem0 | Node `mem0ai/oss` hoặc chỉ mượn pattern | pgvector, history SQLite (Node) **[verified]**. Graph memory không có trong OSS **[verified]** | `userId` (+ agent/run) | Ollama LLM+embedder có trong Node **[verified]**. Trích xuất JSON với model nhỏ dễ lỗi; ví dụ chính thức dùng llama3.1 **[verified]** | Apache-2.0 | Rất phổ biến (~67k★). Benchmark LoCoMo 92.5 là số của managed platform, không phải OSS **[verified]** |
| Letta (MemGPT) | Agent runtime có memory blocks | https://github.com/letta-ai/letta | Không dùng làm lõi | Server riêng. Repo cho biết code hiện tại chuyển sang `letta-ai/letta-code`, V1 server đã vào nhánh archive **[verified]** | Theo agent | Docs: "weaker models can cause the agent to behave in unexpected ways", khuyên dùng frontier model; endpoint cần tool calling **[verified]** | Apache-2.0 | ~25k★, đang đổi kiến trúc |
| Graphiti / Zep | Temporal knowledge graph | https://github.com/getzep/graphiti | Không | Cần Neo4j/FalkorDB/Neptune (Kuzu deprecated), **không có Postgres** **[verified]** | group (docs OSS mơ hồ) | README cảnh báo có thể "fail to ingest" với model nhỏ **[verified]** | Apache-2.0 | Trưởng thành, nhưng sai stack |
| LangMem | Memory + prompt refinement | https://github.com/langchain-ai/langmem | Chỉ lấy ý: procedural memory = tối ưu prompt từ feedback | LangGraph store, `AsyncPostgresStore` **[verified]** | namespace | Không có bằng chứng với model nhỏ | MIT | ~1.7k★, chỉ Python |
| Cognee | KG memory (remember/recall/improve/forget) | https://github.com/topoteretes/cognee | Không cho lõi | Postgres + PGVector (graph-on-Postgres còn là demo) **[verified]** | Multi-tenant mặc định, theo dataset **[verified]** | Có guide Ollama; không có LLM thì dùng GLiNER (demo) **[verified]** | Apache-2.0 | ~31k★, có TS SDK **[verified]** |
| MemoryOS | Memory phân tầng ngắn/trung/dài hạn, có "heat" | https://github.com/BAI-LAB/MemoryOS · arXiv 2506.06326 | Pattern: hợp nhất session → profile user | File / ChromaDB **[verified]** | `user_id` + `assistant_id` **[verified]** | API OpenAI-compatible; không nhắc Ollama **[verified]** | Apache-2.0 | ~1.6k★, research |
| A-MEM | Memory kiểu Zettelkasten (note + link + evolve) | https://github.com/agiresearch/A-mem · arXiv 2502.12110 | Pattern: note có tag/context, link láng giềng | ChromaDB **[verified]** | Tự làm | **Có bằng chứng model nhỏ**: Qwen2.5 1.5B/3B, Llama3.2 1B/3B qua Ollama; A-MEM thắng LoCoMo/MemGPT mọi hạng mục với ~1.1–1.4k token so với ~16.9k **[verified]** | MIT | ~1.2k★, research |
| ACE | Playbook tiến hoá (Generator/Reflector/Curator) | arXiv 2510.04618 | **Pattern lõi cho playbook** | Tự làm trên PG | Tự làm | Mặc định DeepSeek-V3.1; Llama-3.3-70B tăng ít hơn vì "noisier feedback" **[verified]** | Paper | ICLR 2026 |
| Dynamic Cheatsheet | Memory test-time (DC-Cu, DC-RS) | arXiv 2504.07952 | Pattern; DC-RS = truy xuất top-3 cặp I/O cũ **[verified]** | Tự làm | Tự làm | **Bằng chứng âm**: GPT-4o-mini AIME24 16.7→13.3, "struggled to leverage stored information" **[verified]** | Paper | 2025 |
| ReasoningBank | Memory chiến lược từ cả thành công lẫn thất bại | arXiv 2509.25140 (code ở google-research) | Pattern reflector offline | Tự làm | Tự làm | Không thấy số liệu model nhỏ | Paper (ICLR 2026) | 2025–26 |
| Training-Free GRPO | "Experiential knowledge as token prior" | arXiv 2510.08191 | Pattern: so sánh nhóm draft (đúng vs bị sửa) để chắt "kinh nghiệm" | Tự làm | Tự làm | Dùng DeepSeek-V3.1; vài chục mẫu là đủ **[verified]** | Paper | 2025 |
| ExpeL | Rút insight + truy xuất trải nghiệm | arXiv 2308.10144 | Pattern | Tự làm | Tự làm | Thí nghiệm gốc dùng GPT-3.5/4 **[known]** | Code Apache-2.0 **[known]** | 2023 |
| Reflexion | Tự phản tư bằng lời sau khi thất bại | arXiv 2303.11366 | Chỉ offline; online với model 2B thì tốn latency và nhiễu | — | — | Nhóm tác giả ghi nhận model yếu phản tư kém **[known]** | MIT **[known]** | 2023, kinh điển |
| Voyager | Thư viện skill dạng code, truy xuất theo embedding | arXiv 2305.16291 | Pattern: skill = hàm có mô tả + embedding | — | — | GPT-4 **[known]** | MIT **[known]** | 2023 |
| Agent Workflow Memory | Rút workflow tái dùng | arXiv 2409.07429 **[known]** | Pattern cho skill nhiều bước | — | — | GPT-4 **[known]** | — | 2024 |
| DSPy | Lập trình/tối ưu prompt (BootstrapFewShot, MIPROv2, GEPA) | https://github.com/stanfordnlp/dspy · arXiv 2310.03714 | Offline, Python, qua LiteLLM → Ollama | — | — | T5-770M & llama2-13b "competitive" với prompt chuyên gia viết cho GPT-3.5 **[verified]** | MIT **[known]** | Rất trưởng thành |
| GEPA | Tối ưu prompt bằng phản tư + Pareto | arXiv 2507.19457 | Qua Ax hoặc DSPy, offline | — | — | Hơn GRPO ~6% TB, hơn MIPROv2 >10%, ít rollout hơn tới 35x **[verified]** | — | 2025 |
| Ax | DSPy cho TS | https://github.com/ax-llm/ax | **Lib Node** offline: `AxBootstrapFewShot`, `AxGEPA`; signature + Zod | — | — | Có topic "ollama"; README không có hướng dẫn **[verified]** | Apache-2.0 | ~3k★ |
| TextGrad | "Autograd bằng lời" cho prompt | arXiv 2406.07496 **[known]** | Không cần. GEPA/ACE hợp hơn | — | — | Cần LLM mạnh làm backward **[known]** | MIT **[known]** | Research |
| semantic-router | Intent routing bằng embedding | https://github.com/aurelio-labs/semantic-router | Chỉ pattern (route = utterances, threshold, dynamic route) | Pinecone/Qdrant, không có pgvector **[verified]** | — | Encoder local qua HF; không có Ollama **[verified]** | MIT | ~3.9k★, nhánh 1.x đang dev |
| promptfoo | Eval/regression/red-team | https://www.promptfoo.dev/docs/providers/ollama/ | **Lib/CLI Node**: `ollama:chat:gemma2:2b`, assert `is-json`, `javascript`, `similar` | Local | — | Provider Ollama chính thức, có embedding + llm-rubric grader **[verified]** | MIT (sau thương vụ OpenAI 03/2026) **[verified]** | Rất trưởng thành |
| Anthropic skills / skill-creator | Định dạng skill + vòng lặp eval | https://github.com/anthropics/skills | Pattern: `SKILL.md`, `evals.json`, benchmark with/without, trigger eval 60/40 | — | — | Thiết kế cho Claude; định dạng thì trung lập | Apache-2.0 (phần lớn); skill tài liệu thì source-available **[verified]** | ~180k★ |
| instructor-js | Structured output + Zod | https://github.com/567-labs/instructor-js | Tuỳ chọn; native `format` của Ollama đã đủ | — | — | OpenAI-compatible qua `baseURL`; modes JSON/JSON_SCHEMA/MD_JSON **[verified]** | MIT | ~800★, ít hoạt động |
| BAML | DSL hàm LLM + parser chịu lỗi | https://github.com/BoundaryML/baml | Tuỳ chọn nếu JSON vẫn vỡ | — | — | README không nhắc Ollama **[verified]** | Apache-2.0 | ~9.4k★ |
| Outlines | Constrained decoding | https://github.com/dottxt-ai/outlines **[known]** | Không cần: Ollama đã ràng buộc bằng grammar | — | — | Python, chạy với transformers/llama.cpp/vLLM **[known]** | Apache-2.0 **[known]** | Trưởng thành |
| Memori | Memory "SQL-native" | https://github.com/GibsonAI/Memori | Tham khảo | BYODB; README không nêu PG/SQLite **[verified]** | entity/process/session **[verified]** | README không có Ollama **[verified]** | Apache-2.0 | ~17k★, có TS SDK |
| chrono-node | Parse ngày ngôn ngữ tự nhiên | https://github.com/wanasit/chrono | **Lib Node**, locale `vi` | — | — | — | MIT **[known]** | Trưởng thành |
| vn-number / read-vietnamese-number | Số → chữ, định dạng VND | https://vn-number.khanh.id/ · npm `read-vietnamese-number` | Hiển thị; **không** parse "1tr2" **[verified]** | — | — | — | MIT **[verified for read-vietnamese-number]** | Nhỏ |
| underthesea | NLP tiếng Việt | https://github.com/undertheseanlp/underthesea | Tuỳ chọn, Python | — | — | — | Apache-2.0 **[verified]** | ~1.8k★ |
| bge-m3 / nomic-embed-text-v2-moe | Embedding đa ngữ | https://ollama.com/library/bge-m3 · https://huggingface.co/nomic-ai/nomic-embed-text-v2-moe | Thay `nomic-embed-text` cho tiếng Việt (A/B trước) | Ollama | — | bge-m3 567M, 8K ctx; v2-moe chỉ 512 token **[verified]** | MIT / Apache-2.0 **[known]** | Trưởng thành |

---

## 4. Bằng chứng về hiệu năng với model nhỏ (tóm tắt)

**Tích cực**
- **A-MEM** (Qwen2.5 1.5B/3B, Llama3.2 1B/3B qua Ollama): ví dụ Qwen2.5-3B Temporal F1 3.11 (LoCoMo) → 27.59, dùng ~1.1k token so với ~16.9k. Model nhỏ hưởng lợi khi memory **ngắn và có cấu trúc**, thay vì nhồi lịch sử thô **[verified]**.
- **DSPy**: llama2-13b-chat có compiled demos vượt few-shot thường >65% **[verified]**. Lựa chọn demo tốt là đòn bẩy lớn với model nhỏ.
- **Ollama structured outputs**: ràng buộc ở tầng decoding nên JSON luôn parse được. Đúng nội dung thì không đảm bảo, nên vẫn phải validate bằng Zod và đối chiếu với pre-parser.

**Tiêu cực / cảnh báo**
- **Dynamic Cheatsheet**: GPT-4o-mini "struggled to leverage stored information effectively", có chỗ tụt điểm. Nguyên nhân: model yếu tự sinh ra memory sai **[verified]**.
- **ACE**: Reflector yếu thì playbook "noisy or even harmful". Không có feedback tin cậy thì cả ACE lẫn DC đều có thể giảm (FiNER không nhãn bị tụt) **[verified]**. Ứng dụng này thì có nhãn người thật từ HITL, đây là lợi thế lớn nhất.
- **Graphiti, Letta**: chính docs cảnh báo model nhỏ hoặc yếu **[verified]**.
- **mem0 + model local nhỏ**: lỗi JSON khi context dài **[verified-as-claim, nguồn vendor]**.
- **Tiếng Việt + gemma2:2b**: không tìm thấy điểm VMLU công bố cho gemma-2-2b **[verified: không có]**. Phải tự đo bằng eval set nội bộ.

**Kết luận thực dụng:** với 2B, "học" phải nằm ở (a) nhãn người, (b) luật tất định, (c) truy xuất ví dụ đúng. Phản tư bằng LLM chỉ chạy offline, có eval làm cổng chặn, có người duyệt.

---

## 5. Rủi ro

1. **Nhiễm độc bộ nhớ hoặc example bank:** user bấm xác nhận cho nhanh, nên "confirm" không đồng nghĩa với "đúng". Giảm thiểu: cho bản sửa (edit) trọng số cao hơn; hết hạn hoặc giảm điểm theo thời gian; nếu một ví dụ lúc được dùng sau đó lại bị sửa thì hạ cấp nó.
2. **Rò rỉ giữa các user** qua bank/playbook global hoặc qua lỗi lọc vector. Giảm thiểu: RLS bắt buộc; dữ liệu global chỉ đến từ seed hoặc bản promote đã ẩn danh và admin duyệt; viết test cách ly tự động (user A không bao giờ truy xuất được id của user B).
3. **Phình context**: cửa sổ 8K, model 2B suy giảm khi prompt dài. Giảm thiểu: ngân sách token cố định cho từng phần (bullet ≤ 8, example ≤ 5, memory ≤ 5).
4. **Embedding tiếng Việt yếu** khiến router và truy xuất sai. Giảm thiểu: A/B bge-m3 với nomic v2-moe trên dữ liệu thật; chuẩn hoá dấu; lấy lexicon làm đường tắt trước khi dùng vector.
5. **Trôi chất lượng khi playbook tự sửa** (context collapse/brevity bias theo ACE). Giảm thiểu: cập nhật delta, không bao giờ viết lại toàn bộ; version + rollback; cổng promptfoo.
6. **Tài nguyên máy:** chạy song song embed + LLM + batch reflector có thể làm sập máy 6GB. Mọi job nặng chạy tuần tự qua một hàng đợi duy nhất.
7. **Phụ thuộc thư viện:** Letta đang đổi kiến trúc; promptfoo đã về OpenAI, hiện vẫn MIT; semantic-router có nhánh 1.x đang dev; instructor-js ít hoạt động. Vì vậy giữ lõi tự viết, mỏng, trong NestJS.
8. **Gemma2 không có tool calling native và không có system role:** tránh framework kiểu agent. Định tuyến và gọi skill do code quyết định.
9. **Chất lượng nhãn cho AI admin:** số liệu tổng hợp có thể bị thiên lệch bởi vài user hoạt động nhiều. Nên chuẩn hoá chỉ số theo user.

---

## Nguồn chính
- mem0: https://github.com/mem0ai/mem0 · https://docs.mem0.ai/open-source/configuration · https://docs.mem0.ai/open-source/node-quickstart · https://mem0.ai/library/coding-agents/build-a-local-coding-agent-with-mem0-and-ollama
- ACE: https://arxiv.org/abs/2510.04618
- Dynamic Cheatsheet: https://arxiv.org/abs/2504.07952
- A-MEM: https://arxiv.org/abs/2502.12110 · https://github.com/agiresearch/A-mem
- MemoryOS: https://github.com/BAI-LAB/MemoryOS
- ReasoningBank: https://arxiv.org/abs/2509.25140
- Training-Free GRPO: https://arxiv.org/abs/2510.08191
- GEPA: https://arxiv.org/abs/2507.19457
- DSPy: https://arxiv.org/abs/2310.03714
- Ax: https://github.com/ax-llm/ax
- Letta: https://github.com/letta-ai/letta · https://docs.letta.com/guides/server/providers/ollama
- Graphiti: https://github.com/getzep/graphiti
- LangMem: https://github.com/langchain-ai/langmem
- Cognee: https://github.com/topoteretes/cognee
- Memori: https://github.com/GibsonAI/Memori
- semantic-router: https://github.com/aurelio-labs/semantic-router
- promptfoo: https://www.promptfoo.dev/docs/providers/ollama/ · https://qaskills.sh/blog/openai-promptfoo-acquisition-explained-2026
- Anthropic skills: https://github.com/anthropics/skills · https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md
- Ollama: https://ollama.com/blog/structured-outputs · https://ollama.com/library/gemma2 · https://ollama.com/library/bge-m3 · https://registry.ollama.ai/library/nomic-embed-text-v2-moe
- instructor-js: https://github.com/567-labs/instructor-js · BAML: https://github.com/BoundaryML/baml
- chrono: https://github.com/wanasit/chrono/tree/master/src/locales · vn-number: https://vn-number.khanh.id/ · underthesea: https://github.com/undertheseanlp/underthesea
