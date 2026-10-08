# Nghiên cứu skills.sh: skill/pattern cho trợ lý AI thu chi (gemma2:2b + nomic-embed-text)

- Ngày khảo sát: 2026-10-08
- Nguồn: https://www.skills.sh (leaderboard + public search endpoint `https://skills.sh/api/search?q=<term>&limit=N`; endpoint `/api/v1/skills/search` cần OIDC token nên không dùng được) và repo GitHub mà skill trỏ tới.
- Phạm vi: khoảng 100 truy vấn, gồm memory, context, remember, self-improving, self-improvement, continuous learning, feedback, reflection, eval, evals, regression, golden dataset, router, intent, intent classification, json, structured output, schema, finance, budget, expense, personal finance, transaction categorization, ollama, local llm, small model, gemma, prompt, few-shot, dynamic few-shot, rag, embedding, vector, agent, assistant, personalization, vietnamese, vietnam, tiếng việt, vnd, currency amount parsing, date parsing, human in the loop, learn from user corrections, llm judge, failure taxonomy…
- Đã tải và đọc 40 SKILL.md gốc từ GitHub (raw). Nội dung được coi là dữ liệu chưa kiểm chứng: không cài, không chạy script nào.
- Số "installs" lấy từ skills.sh. Stars, ngày push gần nhất và license lấy từ GitHub API ngày 2026-10-08.

## 0. Kết luận chính (đọc trước)

1. **Mọi skill trên skills.sh viết cho agent mạnh** (Claude Code/Codex/Copilot) đọc SKILL.md dài 2–20 KB. **gemma2:2b không thể "đọc skill" theo cách đó**: context ngắn và khả năng làm theo chỉ dẫn dài kém. Thứ mang sang được là **pattern**, không phải file. Với dự án này, "skill" nên là **pipeline trong code backend** gồm parser deterministic, retrieval, prompt template ngắn (≤ 300–500 token), JSON schema và validator. Model 2B chỉ làm phần hẹp nhất: điền slot hoặc chọn nhãn.
2. Pattern "tự cải thiện không cần fine-tune" lặp lại ở hầu hết skill tốt và hội tụ về **5 cơ chế**:
   - **(a)** Rule table học từ xác nhận của user (rule thắng LLM).
   - **(b)** Dynamic few-shot: lấy k ví dụ đã được user xác nhận gần nhất theo embedding.
   - **(c)** Playbook/"instinct" dạng mục nhỏ có id, confidence và counter helpful/harmful, cập nhật bằng delta deterministic, không để LLM viết lại toàn bộ.
   - **(d)** Regression/golden set chạy trước mỗi lần đổi prompt hoặc rule (cổng chấp nhận gồm held-in và held-out).
   - **(e)** Bộ chấm bằng code (schema, regex, so khớp số tiền/ngày) trước, LLM-judge sau. Với model 2B gần như chỉ nên dùng bộ chấm bằng code.
3. **Không có skill nào cho**: parse tiền/ngày tiếng Việt ("45k", "1tr2", "hôm qua"), prompt cho model 2B/local, bộ nhớ đa người dùng cô lập cho ứng dụng end-user, hay tài chính cá nhân Việt Nam. Phần này phải tự viết (xem mục 5).

## 1. Top picks (xếp hạng theo giá trị cho case của chúng ta)

| # | Skill | Vì sao đáng lấy | Mức tương thích 2B |
|---|---|---|---|
| 1 | **transaction-categorizer** (lyndonkl/claude) | Đúng bài toán phân loại giao dịch. Thứ tự xử lý: chuẩn hoá mô tả → **rule table theo priority (substring dài nhất thắng)** → LLM **bị khoá trong taxonomy** → chấm confidence theo nguồn → **đề xuất rule mới** khi ≥ 3 giao dịch confidence ≥ 0.85 cùng pattern. Rule do người thêm có priority 200, rule máy học có priority 100. Có output contract JSON, cảnh báo `taxonomy_gap`, và chặn PII trong rule. | **Cao.** Phần lớn logic là code. LLM chỉ chọn nhãn trong enum. |
| 2 | **regex-vs-llm-structured-text** (affaan-m/ecc) | Kiến trúc regex-first: parser → confidence scorer → chỉ ca có confidence < 0.95 mới gọi LLM. Đây là khung đúng cho "45k", "1tr2", "hôm qua": regex/parser bắt khoảng 95%, model 2B chỉ xử lý phần còn lại. | **Rất cao.** Giảm tải cho model 2B. |
| 3 | **dspy-knn-few-shot** (lebsral/dspy-programming-not-prompting-lms-skills) | Dynamic few-shot: embed input, lấy k demo gần nhất (k = 3–5), chèn vào prompt. Lưu ý quan trọng trong skill: **dưới khoảng 20 ví dụ thì KNN không đáng tin**, nên dùng bộ ví dụ tĩnh. Skill tự nhận KNN tăng 5–15% so với few-shot tĩnh khi input đa dạng. | **Cao về ý tưởng.** Không cần DSPy: dùng `nomic-embed-text` + bảng `examples(user_id, input, output_json, embedding)`. |
| 4 | **self-improvement-loops** + **memory-systems** (muratcankoylan/agent-skills-for-context-engineering) | Mô tả rõ "context evolution" (ACE): playbook gồm **mục có id ổn định + counter helpful/harmful**, cập nhật **delta, merge bằng logic deterministic, không để LLM viết lại cả playbook** (tránh "brevity bias" và "context collapse"), dedup bằng embedding. Có **cổng chấp nhận 2 tập (held-in/held-out, không regression)**. Gồm cả "Optimization Ladder": sửa lỗi ở bậc thấp nhất (prompt → context → workflow). memory-systems bổ sung phân tầng working/short/long-term/entity/temporal và nguyên tắc "invalidate, không xoá" với `valid_from/valid_until`. | **Cao.** Toàn bộ chạy ngoài model. Cảnh báo phù hợp với 2B: *"loop không phải trí thông minh"*, model yếu thì không để model tự sửa harness. |
| 5 | **memory-management** (anthropics/knowledge-work-plugins) | Bộ nhớ 2 tầng: **hot cache** nhỏ (~30 mục thường dùng, phủ khoảng 90% nhu cầu) và **glossary đầy đủ** chỉ tra khi trượt cache. Pattern này hợp để giải mã tiếng lóng của từng user ("cf" → Cà phê, "đổ xăng" → Đi lại/Xăng, "mẹ" → chuyển khoản gia đình). | **Cao.** Hot cache vừa context của 2B, glossary tra bằng code hoặc embedding. |
| 6 | **error-analysis** + **write-judge-prompt** (hamelsmu/evals-skills) | Quy trình eval chuẩn: đọc khoảng 100 trace → ghi lỗi **đầu tiên** → để nhóm lỗi tự hình thành (5–10 nhóm) → tính failure rate → **sửa prompt/code trước, chỉ làm evaluator cho lỗi còn sót**, ưu tiên bộ chấm bằng code. Judge chỉ dùng nhãn **binary Pass/Fail, mỗi judge một lỗi**, kèm ví dụ đã gán nhãn. | **Cao** cho quy trình. Judge nên chạy bằng model khác hoặc chấm offline; không dùng gemma2:2b tự chấm chính nó. |
| 7 | **continuous-learning-v2** (affaan-m/ecc) | "Instinct" nguyên tử: `trigger + action + confidence 0.3–0.9 + domain + evidence + scope (project/global)`. **Promote lên global khi xuất hiện ở ≥ 2 project**. Ánh xạ sang hệ của ta: scope = user; admin promote rule lên global khi nhiều user cùng xác nhận. | **Cao về mô hình dữ liệu.** Hook/agent Haiku trong skill không dùng được. |
| 8 | **self-improving-agent** (zhaono1/agent-playbook), 34k installs | Vòng đời bài học: `candidate → validated → applied → rejected / superseded / rolled_back / no-delta / open-question`. **Không áp dụng nếu chưa có eval chứng minh**. Mỗi bài học có một "owner" duy nhất, ghi lại phương án rollback, và lưu tối thiểu, đã redact. | **Cao.** Đúng khung "rule học được" + HITL. |
| 9 | **llm-structured-output** (shipshitdev/skills) | Schema nhỏ nhất có thể, enum thay cho text tự do, null phải có chủ đích, parse chặt, **retry kèm lỗi validation**, **fallback sang schema nhỏ hơn**, ghi log output hỏng. | **Rất cao.** Kết hợp tham số `format` (JSON schema) của Ollama. |
| 10 | **ai-sorting** (lebsral/dspy-…) | Phân loại/định tuyến intent bằng `Literal[...]` (khoá nhãn). Nêu rõ **khi nào KHÔNG dùng LLM**: rule/keyword đã phủ ≥ 95%, hoặc cần kết quả lặp lại y hệt. | **Cao.** Intent router = keyword/regex + embedding kNN + model 2B chọn trong enum ngắn. |

Đáng tham khảo thêm: **learn-rule** (rohitg00/pro-workflow), với định dạng rule 1 dòng `Category / Mistake / Correction` và yêu cầu **luôn chờ user duyệt rồi mới lưu**, khớp HITL. **remember + memory-merger** (github/awesome-copilot) gom bài học theo domain, rồi nhập bài học đã "chín" vào file instruction chính để chống phình. **langgraph-human-in-the-loop** (langchain-ai) mô tả interrupt với approve/edit/reject. **golden-dataset** (yonatangross/orchestkit) và **eval-harness** (affaan-m/ecc) cung cấp capability eval, regression eval và pass@k.

## 2. Bảng đầy đủ

Chú thích: Inst = installs trên skills.sh. ★ = GitHub stars của repo. "Đọc" = đã tải SKILL.md gốc và đọc. URL skills.sh có dạng `https://www.skills.sh/<owner>/<repo>/<skill>`.

### 2.1 Bộ nhớ / ngữ cảnh / cá nhân hoá

| Skill | skills.sh / repo | Làm gì | Giúp case ta thế nào | 2B? | License | Độ chín |
|---|---|---|---|---|---|---|
| memory-management | [skills.sh](https://www.skills.sh/anthropics/knowledge-work-plugins/memory-management) · [repo](https://github.com/anthropics/knowledge-work-plugins/tree/main/productivity/skills/memory-management) | Hot cache (CLAUDE.md) + glossary/people/projects; tra theo thứ tự cache → glossary → hỏi user | Mỗi user có `profile_hot` (≤ 30 alias/merchant/category hay dùng) nhét thẳng vào prompt, `glossary` tra khi trượt. Đã đọc. | Cao | Apache-2.0 | Inst 7.3k, ★27k, push 2026-10-07 |
| memory-systems | [skills.sh](https://www.skills.sh/muratcankoylan/agent-skills-for-context-engineering/memory-systems) · [repo](https://github.com/muratcankoylan/agent-skills-for-context-engineering/tree/main/skills/memory-systems) | So sánh Mem0/Zep/Letta/Cognee; phân tầng bộ nhớ; retrieval semantic/entity/temporal/hybrid; consolidation "invalidate not discard" | Bắt đầu bằng JSON/SQL có timestamp, chỉ lên vector khi cần; fact thay đổi (lương, ngân sách) dùng `valid_from/valid_until`; không chặn phản hồi khi ghi bộ nhớ lỗi. Đã đọc. | Cao | MIT | ★18k, push 2026-10-01 |
| deep-agents-memory | [skills.sh](https://www.skills.sh/langchain-ai/langchain-skills/deep-agents-memory) · [repo](https://github.com/langchain-ai/langchain-skills/tree/main/config/skills/deep-agents-memory) | Backend State (theo thread) / Store (xuyên thread) / Composite | Tách bộ nhớ **phiên chat** và bộ nhớ **user**. Khớp yêu cầu "nhiều session/user". Gắn chặt LangGraph. Đã đọc. | Trung bình | MIT | Inst 17.9k, ★1.3k |
| remember | [skills.sh](https://www.skills.sh/github/awesome-copilot/remember) · [repo](https://github.com/github/awesome-copilot/tree/main/skills/remember) | `/remember >domain lesson` → file memory theo domain, khái quát hoá, viết dạng tích cực ("làm X" thay vì "đừng Y") | Bài học theo domain: `amount_parsing`, `category`, `date`… mỗi domain là một khối nhỏ để nạp có chọn lọc. Đã đọc. | Cao (ý tưởng) | MIT | Inst 9.2k, ★39.8k |
| memory-merger | [skills.sh](https://www.skills.sh/github/awesome-copilot/memory-merger) · [repo](https://github.com/github/awesome-copilot/tree/main/skills/memory-merger) | Nhập bài học "chín" vào instruction chính, giảm trùng | Job định kỳ gộp rule/ví dụ trùng của từng user. Đã đọc. | Cao | MIT | Inst 12.8k |
| remembering-conversations | [skills.sh](https://www.skills.sh/obra/episodic-memory/remembering-conversations) · [repo](https://github.com/obra/episodic-memory) | Tìm lại hội thoại cũ (episodic) bằng semantic search | Tìm lại phiên chat cũ của chính user ("tháng trước tôi hỏi gì về tiền điện"). Đã đọc. | Trung bình | MIT | Inst 9.2k, ★487 |
| agentmemory-* | [skills.sh](https://www.skills.sh/rohitg00/agentmemory/agentmemory-architecture) · [repo](https://github.com/rohitg00/agentmemory) | Server bộ nhớ MCP/REST cho coding agent | Chỉ tham khảo kiến trúc. Dành cho dev agent, không đa tenant end-user. | Thấp | ? | Inst ~10k |
| elite-longterm-memory | [skills.sh](https://www.skills.sh/nextfrontierbuilds/elite-longterm-memory/elite-longterm-memory) | Long-term memory cho agent | Chưa đọc, trùng ý với các skill trên. | ? | ? | Inst 2.4k |

### 2.2 Tự cải thiện / học từ phản hồi

| Skill | skills.sh / repo | Làm gì | Giúp case ta thế nào | 2B? | License | Độ chín |
|---|---|---|---|---|---|---|
| self-improving-agent (zhaono1) | [skills.sh](https://www.skills.sh/zhaono1/agent-playbook/self-improving-agent) · [repo](https://github.com/zhaono1/agent-playbook/tree/main/skills/self-improving-agent) | Vòng đời candidate/validated/applied có eval artifact, rollback, owner duy nhất | Bảng `learned_rules.status`; rule chỉ "applied" khi qua regression set của user. Đã đọc. | Cao | MIT | **Inst 34.3k**, ★82, push 2026-09-15 |
| self-improvement (pskoett) | [skills.sh](https://www.skills.sh/pskoett/pskoett-ai-skills/self-improvement) · [repo](https://github.com/pskoett/pskoett-ai-skills) | Log `LEARNINGS/ERRORS/FEATURE_REQUESTS.md` có ID, priority, Pattern-Key, Recurrence-Count, promote khi tái diễn | Bảng `ai_feedback_log` (correction / error / feature_request) + `pattern_key` + đếm tái diễn → promote thành rule. Admin xem FEATURE_REQUESTS tổng hợp. Đã đọc. | Cao | không thấy LICENSE | Inst 1.9k, ★311, push 2026-10-05 |
| continuous-learning-v2 | [skills.sh](https://www.skills.sh/affaan-m/ecc/continuous-learning-v2) · [repo](https://github.com/affaan-m/ecc/tree/main/skills/continuous-learning-v2) | Instinct nguyên tử + confidence + scope project/global + promote | Mô hình dữ liệu cho rule cá nhân / rule toàn cục. Đã đọc. | Cao (data model) | MIT | ★275k (repo), push 2026-10-05 |
| continuous-learning (v1, deprecated) | [skills.sh](https://www.skills.sh/affaan-m/ecc/continuous-learning) | Stop-hook trích pattern cuối phiên | Ý tưởng "trích bài học cuối phiên chat". Có ghi chú: skill chỉ kích hoạt ~50–80%, hook thì 100%, nên **trigger học phải nằm trong code, không phụ thuộc model**. Đã đọc. | Cao (bài học) | MIT | Inst 10k |
| self-improvement-loops | [skills.sh](https://www.skills.sh/muratcankoylan/agent-skills-for-context-engineering/self-improvement-loops) · [repo](https://github.com/muratcankoylan/agent-skills-for-context-engineering/tree/main/skills/self-improvement-loops) | Optimization ladder, ACE playbook, cổng held-in/held-out, chống reward hacking | Thiết kế vòng cải thiện an toàn. Evaluator nằm ngoài vùng loop được sửa. Đã đọc. | Cao | MIT | ★18k |
| learn-rule | [skills.sh](https://www.skills.sh/rohitg00/pro-workflow/learn-rule) · [repo](https://github.com/rohitg00/pro-workflow/tree/main/skills/learn-rule) | `[LEARN] Category: rule / Mistake / Correction`, chờ duyệt | UI "AI đề xuất ghi nhớ: *'trà sữa' → Ăn uống/Đồ uống*. Lưu? (Có/Không)". Đã đọc. | Cao | không thấy LICENSE | Inst 143, ★2.9k |
| self-improving-agent (alirezarezvani) | [skills.sh](https://www.skills.sh/alirezarezvani/claude-skills/self-improving-agent) · [repo](https://github.com/alirezarezvani/claude-skills) | Biến thể tương tự (memory → rule) | Trùng ý. Đã đọc lướt. | Trung bình | MIT | ★27.8k |
| compound-learnings | [skills.sh](https://www.skills.sh/parcadei/continuous-claude-v3/compound-learnings) | Tích luỹ bài học thành rule | Chưa đọc, trùng ý. | ? | ? | Inst 504 |
| proactive-self-improving-agent, các bản mirror `skills.volces.com/*`, `clawhub.ai/*` | skills.sh | Nhiều fork/mirror tiếng Trung | Không thêm gì mới. Nguồn mirror khó kiểm chứng, nên bỏ qua. | — | — | — |

### 2.3 Few-shot / prompt / structured output / phân loại & định tuyến

| Skill | skills.sh / repo | Làm gì | Giúp case ta thế nào | 2B? | License | Độ chín |
|---|---|---|---|---|---|---|
| dspy-knn-few-shot | [skills.sh](https://www.skills.sh/lebsral/dspy-programming-not-prompting-lms-skills/dspy-knn-few-shot) · [repo](https://github.com/lebsral/dspy-programming-not-prompting-lms-skills/tree/main/skills/dspy-knn-few-shot) | KNN demo selection, chọn k, so sánh với static | Lõi của "ví dụ học được". Đã đọc. | Cao | không thấy LICENSE | Inst 5 (mới), ★11 |
| ai-sorting | [skills.sh](https://www.skills.sh/lebsral/dspy-programming-not-prompting-lms-skills/ai-sorting) | Phân loại với Literal, multi-label, eval, optimize | Intent router + category. Đã đọc. | Cao | không thấy LICENSE | Inst 22 |
| ai-stopping-hallucinations | [skills.sh](https://www.skills.sh/lebsral/dspy-programming-not-prompting-lms-skills/ai-stopping-hallucinations) | Bắt trích dẫn nguồn, `Refine(N=3, reward_fn)` | Câu trả lời thống kê **phải trích số từ query SQL**, rồi validator kiểm số trong câu trả lời có khớp dữ liệu không, sai thì retry. Đã đọc. | Cao (validator code) | không thấy LICENSE | Inst 87 |
| llm-structured-output | [skills.sh](https://www.skills.sh/shipshitdev/skills/llm-structured-output) · [repo](https://github.com/shipshitdev/skills) | Schema contract, validate, retry, fallback | Xem top #9. Đã đọc. | Rất cao | không thấy LICENSE | Inst 92 |
| few-shot-patterns | [skills.sh](https://www.skills.sh/owl-listener/ai-design-skills/few-shot-patterns) · [repo](https://github.com/owl-listener/ai-design-skills) | Nguyên tắc chọn/sắp xếp ví dụ: đa dạng, có edge case, ví dụ giống input nhất đặt **cuối** | Thứ tự chèn demo: phổ biến → edge → gần nhất ở cuối, hợp với model 2B (recency). Đã đọc. | Cao | MIT | Inst 279 |
| prompt-engineering-patterns | [skills.sh](https://www.skills.sh/wshobson/agents/prompt-engineering-patterns) · [repo](https://github.com/wshobson/agents) | Few-shot, CoT, template, system prompt | Kiến thức chung, viết cho model lớn. Đã đọc lướt. | Trung bình | MIT | Inst 22.5k, ★40k |
| instructor (firecrawl/ai-research-skills…) | [skills.sh](https://www.skills.sh/firecrawl/ai-research-skills/instructor) | Pydantic + retry cho structured extraction | Nếu backend dùng Python. Backend Node thì Zod + `format` của Ollama. Chưa đọc. | Cao | ? | Inst 27 |
| local-llm-router | [skills.sh](https://www.skills.sh/hoodini/ai-agents-skills/local-llm-router) · [repo](https://github.com/hoodini/ai-agents-skills/tree/master/skills/local-llm-router) | Router truy vấn code tới Ollama/LM Studio, phân loại bằng regex + keyword weight, fallback | Chỉ mượn ý "regex + trọng số keyword để phân loại trước khi gọi LLM". File 80 KB, phụ thuộc Serena MCP, hướng coding. Đã đọc mục lục. | Thấp | không thấy LICENSE | Inst 154, ★282 |
| cost-aware-llm-pipeline | [skills.sh](https://www.skills.sh/affaan-m/ecc/cost-aware-llm-pipeline) | Định tuyến model theo độ phức tạp, ngân sách, retry | Ý tưởng định tuyến: câu ngắn đi parser, câu phức tạp đi model 2B, ngoài khả năng thì trả lời "chưa hỗ trợ". Đã đọc. | Trung bình | MIT | Inst 9.5k |

### 2.4 Eval / regression / self-evaluation

| Skill | skills.sh / repo | Làm gì | Giúp case ta thế nào | 2B? | License | Độ chín |
|---|---|---|---|---|---|---|
| error-analysis | [skills.sh](https://www.skills.sh/hamelsmu/evals-skills/error-analysis) · [repo](https://github.com/hamelsmu/evals-skills/tree/main/skills/error-analysis) | Đọc trace, gom nhóm lỗi, tính tỉ lệ | Quy trình hàng tuần cho admin AI: xem các trace bị user sửa hoặc huỷ. Đã đọc. | Cao | MIT | Inst ~760 (judge), ★1.7k |
| write-judge-prompt | [skills.sh](https://www.skills.sh/hamelsmu/evals-skills/write-judge-prompt) | Judge binary, mỗi judge một lỗi, few-shot có nhãn | Chỉ cho tiêu chí chủ quan (giọng văn). Không dùng 2B làm judge. Đã đọc. | Thấp–TB | MIT | — |
| eval-harness | [skills.sh](https://www.skills.sh/affaan-m/ecc/eval-harness) · [repo](https://github.com/affaan-m/ecc/tree/main/skills/eval-harness) | Capability vs regression eval, grader code/model/human, pass@k | `npm run eval:ai`: chạy golden set và báo pass@k theo intent. Đã đọc. | Cao | MIT | Inst 10k |
| golden-dataset | [skills.sh](https://www.skills.sh/yonatangross/orchestkit/golden-dataset) · [repo](https://github.com/yonatangross/orchestkit) | Curation, versioning, validation, silver → gold | Câu user đã xác nhận (silver) được duyệt thành golden; lưu JSON có version, embedding tạo lại khi cần. Đã đọc. | Cao | MIT | Inst 171, ★289 |
| llm-evaluation | [skills.sh](https://www.skills.sh/wshobson/agents/llm-evaluation) | Metric tự động, human eval, A/B | Tổng quan. Đã đọc lướt. | TB | MIT | Inst 12k |
| agentic-eval | [skills.sh](https://www.skills.sh/github/awesome-copilot/agentic-eval) | Generate → critique → refine loop | **Không hợp 2B**: self-critique của model 2B kém, lại tốn lượt gọi. Thay bằng validator code + retry kèm lỗi. Đã đọc. | Thấp | MIT | Inst 10k |
| agent-self-evaluation | [skills.sh](https://www.skills.sh/affaan-m/ecc/agent-self-evaluation) | Tự chấm 5 trục kèm bằng chứng | Không dùng cho 2B. Ý "mỗi điểm < 5 phải có bằng chứng" hợp cho judge offline. Đã đọc. | Thấp | MIT | Inst 3.8k |
| failure-taxonomy | [skills.sh](https://www.skills.sh/owl-listener/ai-design-skills/failure-taxonomy) | Phân loại kiểu lỗi AI | Khởi tạo danh mục lỗi: sai số tiền, sai ngày, sai danh mục, bịa dữ liệu, sai intent. Đã đọc. | Cao | MIT | Inst 124 |
| promptfoo-evals | [skills.sh](https://www.skills.sh/promptfoo/promptfoo/promptfoo-evals) | Viết eval promptfoo (hỗ trợ provider Ollama) | Công cụ chạy regression prompt sẵn có. Chưa đọc. | Cao | MIT (promptfoo) | Inst 311 |

### 2.5 Tài chính / tiếng Việt / local model

| Skill | skills.sh / repo | Làm gì | Giúp case ta thế nào | 2B? | License | Độ chín |
|---|---|---|---|---|---|---|
| transaction-categorizer | [skills.sh](https://www.skills.sh/lyndonkl/claude/transaction-categorizer) · [repo](https://github.com/lyndonkl/claude/tree/main/skills/transaction-categorizer) | Xem top #1 | Xem top #1. Đã đọc. | Cao | không thấy LICENSE | Inst 52, ★164 |
| expense-categorization | [skills.sh](https://www.skills.sh/seb1n/awesome-ai-agent-skills/expense-categorization) | Phân loại chi phí doanh nghiệp, phòng ban, khấu trừ thuế (IRS) | Lệch case (B2B, Mỹ). Chỉ mượn bước "strip mã thẻ/địa điểm khỏi mô tả". Đã đọc. | TB | MIT | Inst 92 |
| personal-finance-coach | [skills.sh](https://www.skills.sh/curiositech/some_claude_skills/personal-finance-coach) | Tư vấn tài chính cá nhân (khung Mỹ) | Nội dung nhận xét/insight. Phải Việt hoá; không hợp để 2B lý luận. Đã đọc lướt. | Thấp | MIT | Inst 743 |
| finance-manager | [skills.sh](https://www.skills.sh/ailabs-393/ai-labs-claude-skills/finance-manager) | Quản lý tài chính | Chưa đọc, chung chung. | ? | ? | Inst 2.4k |
| vietnamese-finance-copy | [skills.sh](https://www.skills.sh/trussary/vietnamese-language-skill/vietnamese-finance-copy) · [repo](https://github.com/trussary/vietnamese-language-skill) | Văn phong tài chính tiếng Việt: số tách bằng dấu chấm `2.500.000`, `Đơn vị tính`, `Quý I`, tránh cam kết lợi nhuận | Quy tắc **định dạng output** (formatter bằng code, không giao cho model) và câu chữ cho insight. Đã đọc. | Cao (làm formatter) | MIT | Inst 144, ★82 |
| humanizer-vi / grammar-checker-vi | [skills.sh](https://www.skills.sh/longhang2004/vietnamese-humanizer/humanizer-vi) | Làm tiếng Việt tự nhiên | Tham khảo văn phong câu trả lời. Chưa đọc. | Thấp | ? | Inst ~50 |
| ollama-optimizer | [skills.sh](https://www.skills.sh/luongnv89/skills/ollama-optimizer) · [repo](https://github.com/luongnv89/skills/tree/main/skills/ollama-optimizer) | Tune Ollama theo phần cứng (tier VRAM, quant, env) | Tối ưu RTX 3050 6 GB: `OLLAMA_KEEP_ALIVE`, `num_ctx`, chạy song song model chat + embed. Phần đọc được chỉ là hướng dẫn; script `detect_system.py` **không chạy**. | Hạ tầng | MIT | Inst 229, ★131, push 2026-10-07 |
| local-llm-ops | [skills.sh](https://www.skills.sh/bobmatnyc/claude-mpm-skills/local-llm-ops) | Vận hành LLM local | Ngắn, chung chung. Đã đọc. | Hạ tầng | MIT | Inst 433 |
| gemma-dev | [skills.sh](https://www.skills.sh/google-gemma/gemma-skills/gemma-dev) · [repo](https://github.com/google-gemma/gemma-skills/tree/main/skills/gemma-dev) | Skill chính chủ Google về chọn/triển khai Gemma | SKILL.md liệt kê Gemma 4 E2B/E4B (128K ctx), Gemma 3 270M/1B, EmbeddingGemma 2, QAT q4_0 GGUF. Đây là gợi ý **nâng cấp model nhỏ cùng họ** nếu sau này cần (chưa kiểm chứng ngoài SKILL.md). Đã đọc. | — | Apache-2.0 | Inst 400, ★1k, push 2026-10-06 |
| langgraph-human-in-the-loop | [skills.sh](https://www.skills.sh/langchain-ai/langchain-skills/langgraph-human-in-the-loop) · [repo](https://github.com/langchain-ai/langchain-skills/tree/main/config/skills/langgraph-human-in-the-loop) | interrupt → approve/edit/reject → resume | Khớp luồng "AI đề xuất bản nháp, user xác nhận/sửa/huỷ". **Chênh lệch giữa bản nháp và bản user lưu chính là tín hiệu học.** Đã đọc. | Cao (luồng) | MIT | Inst 16k |

## 3. Pattern nên áp dụng (đã chuyển ngữ cho kiến trúc của ta)

### 3.1 Pipeline "skill" cho model 2B (từ regex-vs-llm, transaction-categorizer, ai-sorting, llm-structured-output)

```
tin nhắn user
  → [Intent router] keyword/regex → (nếu mơ hồ) kNN embedding trên ví dụ intent → (nếu vẫn mơ hồ) gemma2:2b chọn trong enum ≤ 6 nhãn
  → [Slot parser deterministic] số tiền ("45k", "1tr2", "2 triệu rưỡi", "500 nghìn"), ngày ("hôm qua", "thứ 2 tuần trước", "15/9"), loại thu/chi
  → [Category] rule table của user (priority, substring dài nhất) → rule global → kNN few-shot + gemma2:2b chọn trong taxonomy (enum)
  → [Validator] JSON schema (Ollama `format`) + kiểm tra nghiệp vụ (amount > 0, ngày không ở tương lai…) → retry 1 lần kèm lỗi → fallback: hỏi lại user
  → [Bản nháp] confidence + nguồn từng field (rule / parser / llm) → UI cho user xác nhận/sửa/huỷ
```
Nguyên tắc rút từ các skill: **chỉ field nào parser không xử lý được mới giao cho LLM**. LLM luôn chọn trong **enum**, không sinh text tự do cho field máy đọc. Mỗi field mang `source` và `confidence`.

### 3.2 Bộ nhớ theo user (memory-management, memory-systems, deep-agents-memory, continuous-learning-v2)
- **Hot profile** (≤ 30 mục, luôn nạp): alias → category, merchant hay dùng, ví mặc định, ngân sách tháng, các rule có confidence cao.
- **Glossary / ví dụ đầy đủ** (tra khi cần): bảng `examples` + embedding `nomic-embed-text`, luôn lọc `WHERE user_id = ?` trước khi tính similarity. Cô lập tuyệt đối, không dùng index chung chưa lọc.
- **Bộ nhớ phiên** riêng theo `session_id`, có tóm tắt ngắn. **Bộ nhớ user** dùng chung giữa các phiên.
- Fact thay đổi theo thời gian có `valid_from` / `valid_until`. Fact cũ được đánh dấu hết hiệu lực chứ không xoá.

### 3.3 Tự cải thiện không fine-tune (self-improving-agent, pskoett, continuous-learning-v2, learn-rule, self-improvement-loops)
- **Tín hiệu**: diff giữa bản nháp AI và bản user lưu (field nào bị sửa), huỷ, xác nhận không sửa. Tín hiệu được ghi **trong code** (đây là "hook 100%" theo bài học của ECC), không nhờ model nhớ.
- **Ví dụ học được**: mỗi bản nháp được xác nhận → thêm `(input, output_json)` vào `examples` của user (dedup bằng embedding, cosine > 0.95 thì bỏ).
- **Rule học được** (instinct): `{trigger: "trà sữa", action: category=Đồ uống, confidence, evidence_count, scope: user|global, status: candidate|applied|rejected}`. Lên `applied` khi ≥ 3 lần xác nhận nhất quán, hoặc khi user bấm "ghi nhớ". Rule bị user sửa ngược thì giảm confidence, rơi dưới ngưỡng thì `rejected`.
- **Promote global** (AI admin): rule giống nhau ở ≥ N user sẽ được đề xuất cho admin duyệt (theo mô hình project→global của continuous-learning-v2). Không tự áp dụng.
- **Playbook dạng mục có id + counter helpful/harmful**, cập nhật bằng delta. **Không bao giờ để LLM viết lại cả playbook** (cảnh báo "context collapse" trong self-improvement-loops).

### 3.4 Eval / regression (error-analysis, eval-harness, golden-dataset, self-improvement-loops)
- **Golden set toàn cục** (vài trăm câu tiếng Việt có nhãn: intent, amount, date, type, category) + **regression set theo user** (lấy từ các bản nháp đã xác nhận).
- **Cổng chấp nhận** khi đổi prompt/rule/model: không giảm trên held-in, không giảm trên held-out, tăng ít nhất một tập (code mẫu `accept()` trong self-improvement-loops).
- **Grader bằng code là chính**: so khớp chính xác amount/date/type, category trong taxonomy, JSON hợp lệ. LLM-judge (nếu dùng) phải binary, mỗi judge một lỗi, và chạy model khác hoặc offline.
- Hàng tuần đọc khoảng 100 trace bị sửa/huỷ, gom nhóm lỗi, sửa ở bậc thấp nhất (parser/rule trước, prompt sau).

## 4. Thứ không nên dùng / rủi ro
- **Reflection/self-critique loop** (agentic-eval, agent-self-evaluation): model 2B tự chấm kém và tốn gấp 2–3 lượt gọi trên GPU 6 GB.
- **Để model tự sửa prompt/harness** (RSI): self-improvement-loops nêu rõ loop làm model yếu tệ đi. Mọi thay đổi phải qua eval cổng + duyệt (HITL / admin).
- **SKILL.md dài nạp thẳng vào prompt 2B**: vượt context hiệu dụng và làm model bỏ qua chỉ dẫn. Chỉ trích 3–6 quy tắc ngắn cho mỗi tác vụ.
- Các skill có script cài đặt (ollama-optimizer `detect_system.py`, local-llm-router, agent-playbook CLI `apb`) **chưa được kiểm tra mã**. Chỉ dùng như tài liệu.
- Nhiều repo không có file LICENSE (lebsral, pskoett, lyndonkl, rohitg00, shipshitdev, hoodini): chỉ học ý tưởng, không copy nguyên văn code/text.

## 5. Khoảng trống (không tìm thấy trên skills.sh)
1. **Parse tiền tiếng Việt** ("45k", "45 nghìn", "1tr2", "1 triệu 2", "2 củ", "nửa triệu", "1.5tr", "200 ngàn", "3 lít" (tiếng lóng)…). Truy vấn `vnd`, `currency amount parsing`, `so tien` không ra gì. Gần nhất là `persian-tools/moneywordstonumber` (tiếng Ba Tư) và `kmp-money`. **Phải tự viết** parser + bộ test.
2. **Parse ngày tương đối tiếng Việt** ("hôm qua", "hôm kia", "thứ 2 tuần trước", "đầu tháng", "cuối tuần rồi", "mùng 5"). Truy vấn `natural language date parsing` chỉ ra skill task-manager tiếng Anh. **Phải tự viết**.
3. **Prompt/khung cho model 2B local**: không có skill "small model prompting". `local-llm-router` và `ollama-optimizer` chỉ lo hạ tầng.
4. **Bộ nhớ đa tenant cho end-user app**: mọi skill memory/self-improving đều phục vụ *một dev dùng coding agent*, không có cô lập theo user_id, quota hay quyền admin.
5. **Intent router cho chatbot tài chính**: không có. `ai-sorting` là khung gần nhất.
6. **Tài chính cá nhân Việt Nam** (danh mục chi tiêu VN, ví MoMo/ZaloPay, chuyển khoản, tiền điện EVN…): không có. `vietnamese-finance-copy` thiên về kế toán doanh nghiệp/quảng cáo.
7. **Structured output với Ollama `format`**: không có skill riêng. Dùng tài liệu Ollama + pattern của llm-structured-output.

## 6. Phụ lục: dữ liệu thô
- Endpoint public dùng được: `GET https://skills.sh/api/search?q=<term>&limit=<n>` trả `{query, searchType: fuzzy|semantic, skills:[{id, source, skillId, name, installs}]}`.
- Danh sách SKILL.md đã đọc (40 file): transaction-categorizer, regex-vs-llm-structured-text, dspy-knn-few-shot, ai-sorting, ai-stopping-hallucinations, self-improvement-loops, memory-systems, memory-management (anthropics), error-analysis, write-judge-prompt, continuous-learning (v1, v2), self-improving-agent (zhaono1, alirezarezvani), self-improvement (pskoett), learn-rule, llm-structured-output, few-shot-patterns, failure-taxonomy, remember, memory-merger, agentic-eval, agent-self-evaluation, eval-harness, cost-aware-llm-pipeline, golden-dataset, llm-evaluation, prompt-engineering-patterns, embedding-strategies, deep-agents-memory, langgraph-human-in-the-loop, remembering-conversations, expense-categorization, personal-finance-coach, vietnamese-finance-copy, ollama-optimizer, local-llm-ops, local-llm-router, gemma-dev.
