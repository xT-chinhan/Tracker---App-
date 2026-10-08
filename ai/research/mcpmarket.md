# Khảo sát mcpmarket.com — MCP server & Skills cho trợ lý AI thu chi (gemma2:2b local)

Ngày khảo sát: 2026-10-08. Nguồn: mcpmarket.com (`/search?q=...`, `/server/*`, `/tools/skills/*`) và README GitHub của các mục đứng đầu. Không cài và không chạy mã nào.

Từ khóa đã tìm: memory, mem0, letta, pgvector, ollama, knowledge graph, self-improving, feedback learning, multi-tenant memory, evaluation llm, router, few-shot, structured output json schema, vietnamese, budget expense, cùng các trang Skills (all, data-science-ml, slug đoán trước).

Lưu ý về độ tin cậy:
- Con số cạnh tên trên mcpmarket **không có nhãn** và nhiều khi lệch với số sao GitHub (ví dụ Graphiti hiển thị 32k nhưng phần feature ghi 7,402). Cột "Sao" bên dưới ưu tiên số đọc từ GitHub; số nào chỉ lấy từ mcpmarket thì có ghi chú (mm).
- Ô tìm kiếm của mục Skills chạy phía client và Google không index được, nên phần Skills chỉ khảo sát được một phần.
- **Ràng buộc quan trọng:** Ollama `gemma2:2b` **không hỗ trợ tool-calling native**. Mọi server hay thư viện yêu cầu "model must support tool calling" (mem0 dùng Ollama, Graphiti, Ollama MCP Bridge) đều không chạy thẳng được với gemma2:2b. Với model này, cách khả thi là **lấy pattern** và tự cài trong NestJS, dùng `format: json` hoặc JSON schema của Ollama, kèm validate và repair.

---

## 1. Top picks (xếp hạng cho đúng bài toán của mình)

| # | Mục | Vì sao chọn | Dùng thế nào |
|---|---|---|---|
| 1 | **Mem0 (OSS lib, `mem0ai/oss` TS)** | Apache-2.0, ~66.8k sao. Có SDK TypeScript, hỗ trợ **pgvector** (cả Python và TS) và **Ollama** LLM. Scope theo `user_id`. Đây là chuẩn de facto cho việc "trích fact → lưu → truy hồi" theo từng user | Phương án A: chạy mem0-ts trong NestJS với pgvector, scope bằng `user_id = userId`, embedder dùng nomic. Phương án B (khuyến nghị cho 2B): **chép pattern** trích fact rồi ADD/UPDATE/DELETE/NOOP, tự viết prompt JSON ngắn, vì bước extraction của mem0 cần model có tool-calling |
| 2 | **Caura / MemClaw** | Apache-2.0, 545 sao. **Postgres 16 + pgvector**, **row-level tenant isolation**, quét PII mỗi lần ghi, hybrid search (vector + keyword + graph), phát hiện mâu thuẫn, có embedder local. Self-host bằng Docker | Mẫu thiết kế multi-tenant gần nhất với hệ của mình: copy schema/RLS và luồng enrichment. Chạy như sidecar thì được, nhưng là Python/FastAPI và README chỉ ghi provider cloud. Chưa xác nhận có Ollama |
| 3 | **Hippo (hippo-memory)** | MIT, 773 sao, cập nhật 2026-10. Có **outcome learning**: `--good/--bad` trên kết quả recall làm thay đổi half-life và reward. Có supersede/invalidate fact cũ. BM25 mặc định, không cần model | Pattern cho **feedback loop**: user xác nhận, sửa hay hủy draft thì cập nhật trọng số memory hoặc ví dụ đã dùng. Lưu SQLite, multi-tenant qua API key, Node 22 không phụ thuộc gì |
| 4 | **AgentRecall (agentrecall-x)** | MIT, 371 sao. Có **corrections ledger**: mỗi lần user sửa thì ghi `severity / evidence / outcome`, đếm `retrieved_count`, đánh dấu `heeded`/`recurred` ở lần gặp sau | Pattern cho **learned rules**: khi user sửa draft (ví dụ đổi danh mục "Grab" từ Ăn uống sang Di chuyển) thì tạo correction. Lần sau inject vào prompt và đo được rule đó có hiệu quả hay không |
| 5 | **ThumbGate** | Feedback 👍/👎. 👎 lặp lại thì tự sinh **prevention rule**, rồi rule thành **pre-action gate** chặn hành động sai trước khi chạy | Pattern cho **gate hậu kiểm draft**: rule học được chạy deterministic trên JSON draft (sai dấu thu/chi, sai danh mục quen dùng…) trước khi hiển thị cho user. Repo nhỏ (7 sao), không rõ license |
| 6 | **Graphiti (getzep)** | Apache-2.0, 31.5k sao. Knowledge graph **bi-temporal** (fact có thời điểm hiệu lực), namespace `group_id` per user, chạy được với Ollama qua endpoint OpenAI-compatible | **Chỉ lấy pattern**. README tự cảnh báo model rất nhỏ hay xuất JSON sai schema, và nó cần Neo4j/FalkorDB. Ý tưởng nên lấy: fact có `valid_from/valid_to`, ví dụ "lương 15tr" về sau đổi thành "lương 18tr" |
| 7 | **MemForge** | Chạy trên một Postgres 17 duy nhất (pgvector + Apache AGE + JSONB). Có tool `reflect` sinh insight định kỳ (12h), decay `importance *= 0.95^days`, scope private/shared, context **giới hạn theo token budget** | Pattern cho **reflection định kỳ** (job đêm tóm tắt thói quen chi tiêu thành insight) và **context theo token budget**, rất cần với cửa sổ nhỏ của 2B. License **BSL 1.1**, repo mới (1 commit, 2 sao) |
| 8 | **Ollama MCP Bridge (patruff)** | MIT, 985 sao. Validate structured output cho tool call, **dò tool bằng keyword** trước khi gọi model | Pattern **intent routing lai**: rule/keyword/regex trước, model sau, rồi validate output. README dùng qwen2.5-coder 7B, không nói gì về model nhỏ |
| 9 | **GenPark JSON Schema Auto-Repair** | Python stdlib, sửa JSON hỏng (bị cắt, bọc trong markdown, sai kiểu) **mà không cần LLM** | Bắt buộc phải có lớp này với 2B. Port logic sang TS, hoặc dùng lib tương đương, đặt trước bước validate zod/class-validator. 7 sao, không rõ license |
| 10 | **Omegaprompt** | "Overfit gate": prompt hay few-shot thắng trên eval set phải pass thêm **held-out set** thì mới được ship | Pattern **self-eval/regression gate** khi tự động thêm few-shot hoặc rule mới: chạy bộ golden test tiếng Việt, tụt điểm thì không promote. 1 sao |

Đáng chú ý thêm, nằm ngay ngoài top 10: **AgentDB** (ruvnet) dùng Thompson Sampling trên feedback "kết quả nào được dùng" để tự cải thiện retrieval. Skill **Continuous Learning v2** có "instincts" với confidence 0.3–0.9 tiến hóa dần. **Expense / MyFinance** (mẫu tool schema cho thu chi).

---

## 2. Bảng đầy đủ

Chú thích: Local = chạy được hoàn toàn offline; PG = Postgres/pgvector; Iso = có cơ chế cô lập theo user/tenant. "?" = README hoặc trang không nêu.

### 2a. Memory / long-term memory

| Tên | mcpmarket | Repo | Chức năng | Giúp gì cho mình | Local | Lưu trữ | Iso | License | Sao / độ trưởng thành |
|---|---|---|---|---|---|---|---|---|---|
| Mem0 (official MCP) | [/server/mem0-1](https://mcpmarket.com/server/mem0-1) | [mem0ai/mem0](https://github.com/mem0ai/mem0) | Memory layer: trích, lưu, search | Lõi memory per-user (lib TS) | Có (Ollama + pgvector theo docs) | pgvector, Qdrant… | `user_id` | Apache-2.0 | 66.8k, rất active |
| Mem0 (coleam00) | [/server/mem0-4](https://mcpmarket.com/server/mem0-4) | coleam00/mcp-mem0 | MCP template bọc mem0 | Mẫu wrapper | Có | Postgres/Supabase | ? | ? | 685 (mm) |
| Better Mem0 MCP | [/server/mem0-11](https://mcpmarket.com/server/mem0-11) | [n24q02m/better-mem0-mcp](https://github.com/n24q02m/better-mem0-mcp) | mem0 self-host PG + graph bằng SQL | Mẫu "graph trong SQL" thay vì Neo4j | Không nêu Ollama | PG + pgvector | ? | ? | 1 sao |
| Mem0 (elvismdev) | [/server/mem0-12](https://mcpmarket.com/server/mem0-12) | elvismdev/mem0-mcp-selfhosted | mem0 + Qdrant + Neo4j + Ollama | Ví dụ cấu hình mem0 dùng Ollama | Có | Qdrant/Neo4j | ? | ? | 109 (mm) |
| Caura / MemClaw | [/server/caura](https://mcpmarket.com/server/caura), [/server/memclaw](https://mcpmarket.com/server/memclaw) | [caura-ai/caura-memclaw](https://github.com/caura-ai/caura-memclaw) | Memory multi-tenant, PII, trust tiers, contradiction | Mẫu isolation + governance | Một phần (embedder local; LLM cloud) | PG16 + pgvector | **Row-level per tenant** | Apache-2.0 | 545, v2.5.0 |
| Hippo | [/server/hippo-1](https://mcpmarket.com/server/hippo-1) | [kitfunso/hippo-memory](https://github.com/kitfunso/hippo-memory) | Memory học từ outcome, decay, supersede | Feedback loop, xử lý fact cũ | Có (BM25, embed tùy chọn) | SQLite + md | API-key tenant | MIT | 773, cập nhật 10/2026 |
| AgentRecall | [/server/agentrecall-2](https://mcpmarket.com/server/agentrecall-2) | [goldentrii/agentrecall-x](https://github.com/goldentrii/agentrecall-x) | 5 lớp memory, có lớp Correction | Learned rules từ sửa draft | Có | Markdown; tùy chọn Supabase pgvector | Per-user dir | MIT | 371 |
| MemForge | [/server/memforge](https://mcpmarket.com/server/memforge) | [memforgeai/memforge](https://github.com/memforgeai/memforge) | Hybrid vector + BM25 + graph, reflect, decay | Reflection, token-budget context | Có (MiniLM CPU) | PG17 + pgvector + AGE | `user_id`, scopes | BSL 1.1 | 2 sao, rất mới |
| Memory (sdimitrov) | [/server/memory-2](https://mcpmarket.com/server/memory-2) | [sdimitrov/mcp-memory](https://github.com/sdimitrov/mcp-memory) | Memory trên PG + pgvector, tag, confidence | Mẫu schema memory có confidence | Có (BERT) | PG + pgvector | ? | ? | 64 (mm) |
| Agent Memory (nateshs) | [/server/agent-memory-6](https://mcpmarket.com/server/agent-memory-6) | ? | Memory PG + pgvector | Tham khảo | ? | PG + pgvector | ? | ? | mới |
| Graphiti | [/server/graphiti](https://mcpmarket.com/server/graphiti) | [getzep/graphiti](https://github.com/getzep/graphiti) | Temporal KG, hybrid search | Pattern fact có thời hạn | Có (Ollama OpenAI-compat) nhưng 2B dễ fail | Neo4j / FalkorDB | `group_id` | Apache-2.0 | 31.5k |
| Knowledge Graph Memory | [/server/knowledge-graph-memory](https://mcpmarket.com/server/knowledge-graph-memory) | [shaneholloman/mcp-knowledge-graph](https://github.com/shaneholloman/mcp-knowledge-graph) | Entity / relation / observation | Mô hình dữ liệu "hồ sơ user" đơn giản | Có | File local | Không | ? | 890 (mm) |
| Basic Memory | [/server/basic-memory](https://mcpmarket.com/server/basic-memory) | [basicmachines-co/basic-memory](https://github.com/basicmachines-co/basic-memory) | KG từ Markdown | Ít liên quan (desktop) | Có | Markdown | Không | ? | 4.1k (mm) |
| Letta MCP | [/server/letta](https://mcpmarket.com/server/letta) | [oculairmedia/letta-mcp-server](https://github.com/oculairmedia/letta-mcp-server) | Quản lý agent và memory blocks của Letta | Pattern "core memory block" per user | Cần Letta server | Letta | Per agent | ? | 79 (mm) |
| Sediment | [/server/sediment](https://mcpmarket.com/server/sediment) | leonwangg1/sendiment | consolidate / sleep, mâu thuẫn thành boundary rule | Pattern job hợp nhất memory ban đêm | ? | ? | ? | ? | 0 |
| Cogvault / Muninn | [/server/cogvault](https://mcpmarket.com/server/cogvault), [/server/muninn-4](https://mcpmarket.com/server/muninn-4) | ? | Memory Markdown multi-tenant, namespace | Tham khảo namespace | Có | Markdown | Có | ? | mới |

### 2b. Self-improving / feedback / eval

| Tên | mcpmarket | Repo | Chức năng | Giúp gì | License | Sao |
|---|---|---|---|---|---|---|
| ThumbGate | [/server/thumbgate](https://mcpmarket.com/server/thumbgate) | [igorganapolsky/thumbgate](https://github.com/igorganapolsky/thumbgate) | 👎 → prevention rule → pre-action gate | Gate draft bằng rule học được | ? | 7 |
| Self-Improve | [/server/self-improve](https://mcpmarket.com/server/self-improve) | [feynman520/d06-p01-self-improve](https://github.com/feynman520/d06-p01-self-improve) | Gom correction thành pattern, đề xuất "Rules → Skills → Scripts → Tools" | Báo cáo định kỳ cho **admin AI** | ? | 0 |
| AgentDB | [/server/agentdb](https://mcpmarket.com/server/agentdb) | [ruvnet/agentdb](https://github.com/ruvnet/agentdb) | Vector memory tự học, Thompson Sampling trên kết quả được dùng | Rerank few-shot theo feedback | ? | 55 |
| Agent Reflexion | [/server/agent-reflexion](https://mcpmarket.com/server/agent-reflexion) | ? | Decision log + performance tracking | Log quyết định để eval | ? | mới |
| Cognitio | [/server/cognitio](https://mcpmarket.com/server/cognitio) | ? | Lỗi agent thành behavioral constraint | Như ThumbGate | ? | mới |
| Flux Memory / Aelfrice | [/server/flux-memory](https://mcpmarket.com/server/flux-memory), [/server/aelfrice](https://mcpmarket.com/server/aelfrice) | ? | Graph có trọng số / Bayesian học từ feedback | Ý tưởng trọng số Bayesian cho rule | ? | mới |
| Omegaprompt | [/server/omegaprompt](https://mcpmarket.com/server/omegaprompt) | [hibou04-ops/omegaprompt](https://github.com/hibou04-ops/omegaprompt) | Held-out gate cho prompt | Chặn few-shot hoặc rule làm tụt chất lượng | ? | 1 |
| Evalbench / Fastevals | [/server/evalbench](https://mcpmarket.com/server/evalbench), [/server/fastevals](https://mcpmarket.com/server/fastevals) | ? | Harness eval offline, regression gate, validate structured output | Golden test JSON output tiếng Việt | ? | mới |
| Mandoline | [/server/mandoline](https://mcpmarket.com/server/mandoline) | ? | Self-critique framework | Tham khảo (2B tự chấm kém) | ? | – |
| Phoenix (Arize) | [/server/phoenix](https://mcpmarket.com/server/phoenix) | Arize-ai/phoenix | Observability + eval LLM, self-host | Trace và eval prompt Ollama | ELv2 (theo hiểu biết, chưa đọc README) | 12k (mm) |
| Vibe Check | [/server/vibe-check](https://mcpmarket.com/server/vibe-check) | PV-Bhat | "Pattern interrupt" chống lỗi dây chuyền | Ít liên quan | ? | 502 (mm) |

### 2c. Ollama / structured output / routing

| Tên | mcpmarket | Repo | Chức năng | Giúp gì | License | Sao |
|---|---|---|---|---|---|---|
| Ollama MCP Bridge | [/server/ollama-mcp-bridge](https://mcpmarket.com/server/ollama-mcp-bridge) | [patruff/ollama-mcp-bridge](https://github.com/patruff/ollama-mcp-bridge) | Cho model Ollama dùng tool MCP, validate tool call | Pattern routing keyword + validate | MIT | 985 |
| Ollama MCP Client | [/server/ollama-mcp-client](https://mcpmarket.com/server/ollama-mcp-client) | jonigl/mcp-client-for-ollama | TUI client Ollama ↔ MCP | Chỉ để thử nghiệm | ? | 827 (mm) |
| Ollama (rawveg) | [/server/ollama](https://mcpmarket.com/server/ollama) | rawveg/ollama-mcp | Expose API Ollama (chat, embed) | Không cần; NestJS gọi thẳng Ollama | ? | 174 (mm) |
| Ollama Database Assistant | [/server/ollama-database-assistant](https://mcpmarket.com/server/ollama-database-assistant) | robdodson | NL → SQL Postgres bằng Ollama | **Không nên** cho 2B; nên dùng query template có tham số | ? | 62 (mm) |
| GenPark JSON Auto-Repair | [/server/genpark-agent-json-schema-auto-repair-skill](https://mcpmarket.com/server/genpark-agent-json-schema-auto-repair-skill) | [alpha-park/genpark-agent-json-schema-auto-repair-skill](https://github.com/alpha-park/genpark-agent-json-schema-auto-repair-skill) | Sửa JSON hỏng, không LLM | Lớp repair bắt buộc | ? | 7 |
| GenPark Structured Output Enforcer | [/server/genpark-structured-output-enforcer](https://mcpmarket.com/server/genpark-structured-output-enforcer) | alphaparkinc | Validate JSON Schema | Như trên | ? | – |
| JSON Contracts | [/server/json-contracts](https://mcpmarket.com/server/json-contracts) | json-contracts | Contract JSON có version (git) cho NL → JSON | Version schema draft | ? | – |
| M-Gate | [/server/m-gate](https://mcpmarket.com/server/m-gate) | ranfysvalle02 | Route tới tool bằng hybrid search | Pattern **embedding router** (nomic) chọn intent | ? | – |

### 2d. Tài chính cá nhân (domain)

| Tên | mcpmarket | Repo | Giúp gì | Sao |
|---|---|---|---|---|
| Expense | [/server/expense](https://mcpmarket.com/server/expense) | [justfsl50/expense-mcp](https://github.com/justfsl50/expense-mcp) | Bộ tool chuẩn: thu/chi/budget/goal/summary, để tham khảo bộ intent | 0 |
| MyFinance | [/server/myfinance](https://mcpmarket.com/server/myfinance) | [alex-odoo/myfinance-mcp](https://github.com/alex-odoo/myfinance-mcp) | **Tính số liệu bằng SQL, không bằng LLM**; import sao kê có dedupe / reconcile | 1 |
| Budget Manager / Manilo / Ledgy / Spendlog | [/server/budget-manager](https://mcpmarket.com/server/budget-manager) … | nhiều repo nhỏ | Mẫu tool schema NL → giao dịch | nhỏ |
| OpenWallet (VN) | [/server/openwallet](https://mcpmarket.com/server/openwallet) | openwalletvn | Xử lý dữ liệu thẻ ngân hàng VN; tham khảo nếu sau này import sao kê | – |
| DataCore A2A (VN) | [/server/datacore-a2a](https://mcpmarket.com/server/datacore-a2a) | DataCore-VietNam | Chuẩn hóa địa chỉ VN; tham khảo phần chuẩn hóa text | – |

### 2e. Skills (mục `/tools/skills`)

| Skill | URL | Repo | Nội dung | Giúp gì |
|---|---|---|---|---|
| Continuous Learning v2 | [/tools/skills/continuous-learning-v2](https://mcpmarket.com/tools/skills/continuous-learning-v2) | [x-cmd/skill](https://github.com/x-cmd/skill) | Quan sát hành vi và correction, sinh "instinct" có confidence 0.3–0.9, tiến hóa thành command/agent | Mô hình **rule có confidence**, tăng hay giảm theo feedback |
| Self-Improving Agent | [/tools/skills/self-improving-agent](https://mcpmarket.com/tools/skills/self-improving-agent) | [carmandale/agent-config](https://github.com/carmandale/agent-config) | Ghi `.learnings/` (lỗi, correction, knowledge gap), có ID và priority, promote lên memory | Format bản ghi learning |
| Candor Finance | [/tools/skills/candor-finance](https://mcpmarket.com/tools/skills/candor-finance) | [candorsystems/candor-finance](https://github.com/candorsystems/candor-finance) | Phân loại giao dịch + **rule phân loại tái sử dụng**, phát hiện subscription, chỉ cho điều chỉnh đảo ngược được, có guardrail | Mẫu persona/guardrail cho finance AI và HITL |
| Ai Output Verifier (premium) | [/tools/skills/mp-output-verifier-6d5c6b11](https://mcpmarket.com/tools/skills/mp-output-verifier-6d5c6b11) | – | Fact-check, confidence score, HITL gate cho output tài chính | Ý tưởng confidence trên draft |
| Strategic Context Compaction | [/tools/skills/strategic-context-compaction-1787987503518](https://mcpmarket.com/tools/skills/strategic-context-compaction-1787987503518) | – | Compaction ở ranh giới task | Ý tưởng tóm tắt session |

---

## 3. Pattern nên áp dụng (backend NestJS tự giữ logic)

1. **Cô lập cứng ở tầng DB, không dựa vào prompt** (MemClaw): mọi bảng `ai_memory`, `ai_example`, `ai_rule`, `ai_feedback` đều có `user_id NOT NULL`, bật Postgres **RLS** `USING (user_id = current_setting('app.user_id')::uuid)`. Mọi query vector đều lọc `user_id` trước. Admin AI dùng role riêng, chỉ đọc view tổng hợp hoặc ẩn danh.
2. **Trích fact theo kiểu mem0, rút gọn cho 2B**: sau khi user confirm thì chạy job async. Prompt rất ngắn kèm `format` JSON schema của Ollama, xuất `[{op: ADD|UPDATE|DELETE|NOOP, fact, id?}]`. So trùng bằng cosine nomic, đặt ngưỡng ví dụ ≥ 0.9 thì là UPDATE hoặc NOOP. Chỉ học từ **dữ liệu đã được user xác nhận**.
3. **Fact có thời hạn** (Graphiti): `valid_from`, `valid_to`, `superseded_by` (Hippo `supersede`). Không xóa fact cũ, chỉ đóng hiệu lực.
4. **Dynamic few-shot từ chính user**: mỗi draft được confirm hoặc sửa thì lưu cặp `(input_text, final_json)` kèm embedding. Lúc suy luận lấy top-k = 2–3 ví dụ gần nhất của user đó. Nếu thiếu thì fallback sang bộ ví dụ seed chung. Trọng số ví dụ tăng hay giảm theo outcome (Hippo half-life, AgentDB bandit).
5. **Correction ledger thành learned rules** (AgentRecall, ThumbGate, Continuous Learning v2): khi user sửa field X lặp lại N lần với cùng pattern (ví dụ merchant "highlands" thì category "Cà phê"), tạo rule deterministic có `confidence`. Rule chạy **sau** model như post-processor hoặc gate, không nhồi vào prompt. Theo dõi `heeded/recurred`, rule bị user override nhiều thì giảm confidence rồi tắt.
6. **Lớp JSON an toàn**: Ollama `format` schema, rồi repair deterministic (kiểu GenPark), rồi validate zod. Nếu fail thì retry 1 lần với lỗi cụ thể. Fail tiếp thì trả form trống cho user tự điền (HITL).
7. **Router lai** (Ollama MCP Bridge, M-Gate): regex/keyword tiếng Việt, rồi embedding similarity với câu mẫu từng intent, rồi mới đến LLM phân loại có enum cố định. Mỗi intent có prompt riêng ngắn.
8. **Số liệu tính bằng SQL, không bằng LLM** (MyFinance): LLM chỉ chọn query template và tham số. Backend tính tổng, so sánh, budget. LLM chỉ diễn đạt kết quả.
9. **Context theo token budget** (MemForge): ghép cố định `[system ngắn] + [profile facts ≤ N] + [rules liên quan] + [2–3 few-shot] + [tóm tắt session] + [k lượt gần nhất]`, có cắt theo budget token, vì 2B rất nhạy với context dài.
10. **Reflection/consolidation định kỳ** (MemForge `reflect`, Sediment `sleep`): job đêm gộp fact trùng, decay fact ít dùng, sinh insight chi tiêu. Insight cũng chỉ là **draft**.
11. **Regression gate trước khi promote** (Omegaprompt, Evalbench): bộ golden test tiếng Việt cố định (câu nhập thu chi lóng). Thêm rule hay few-shot seed toàn cục mà điểm tụt thì không promote. Admin AI đọc báo cáo kiểu Self-Improve "Rules → Skills → Scripts → Tools".

---

## 4. Khoảng trống (mcpmarket không có hoặc không phù hợp)

- **Không có gì cho tiếng Việt trong thu chi**: chuẩn hóa dấu, teencode, số tiền ("50k", "2tr5", "1 củ", "lít"), ngày tương đối ("hôm qua", "đầu tháng"). Phải tự viết parser deterministic trước LLM.
- **Không có router hay memory nào thiết kế cho model 2B không có tool-calling**. Các bộ dùng Ollama đều giả định model 7B+ có tool support. Graphiti nói thẳng model nhỏ hay fail JSON.
- **Multi-tenant per end-user trong app** chỉ có MemClaw/Caura làm nghiêm túc. Phần lớn server memory là single-user cho desktop Claude và chỉ đáng lấy làm pattern.
- **Không có server dynamic few-shot hay example store chuyên dụng** (chỉ thấy gián tiếp qua AgentDB, Hippo).
- Mục **Skills** của mcpmarket gần như toàn skill cho coding agent (Claude Code). Tìm kiếm chạy client-side nên không quét hết được, và không có skill nào về Ollama, RAG hay finance tiếng Việt.
- Số liệu sao trên mcpmarket không có nhãn và hay lệch. Nhiều repo tiềm năng có 0–7 sao, không có license, nên rủi ro bảo trì cao: chỉ đọc ý tưởng, không đưa thành dependency.
- License cần lưu ý: MemForge là **BSL 1.1**. Nhiều repo nhỏ không có license, về pháp lý không được copy code.
