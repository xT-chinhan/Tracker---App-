# Đề xuất: Skill tự giỏi lên cho trợ lý AI (gemma2:2b, không fine-tune)

Tổng hợp từ 3 khảo sát: [skills-sh.md](skills-sh.md), [mcpmarket.md](mcpmarket.md), [github-papers.md](github-papers.md) (2026-10-08).

## Kết luận chung (cả 3 nguồn trùng nhau)
- Không có skill / MCP / framework nào cắm thẳng vào gemma2:2b được: chúng viết cho model mạnh, SKILL.md 2–80 KB, cần tool-calling (gemma2 trên Ollama không có).
- Không để model 2B tự chấm, tự phản tư, tự sửa prompt: paper Dynamic Cheatsheet / ACE cho thấy model yếu làm hỏng bộ nhớ.
- "Học" đến từ **nhãn người dùng** (xác nhận / sửa / hủy) + **luật cứng** + **chọn đúng ví dụ**. Model chỉ điền JSON trong khuôn.
- Kiến trúc: tự viết trong NestJS + Postgres/pgvector, **lấy pattern** từ các dự án dưới. Repo không có LICENSE thì chỉ học ý tưởng.

## Một "skill" = pipeline trong backend
```
câu người dùng
 → 1. Router: từ khóa → kNN embedding trên câu mẫu (pattern semantic-router / ai-sorting); không chắc → hỏi lại
 → 2. Parser bằng code: tiền "45k / 1tr2 / 2 củ", ngày "hôm qua / thứ 2 tuần trước" (chrono-node locale vi + parser tự viết)
       (pattern regex-vs-llm-structured-text: code xử lý trước, chỉ ca khó mới gọi LLM)
 → 3. Luật học được chạy trước model (pattern transaction-categorizer: luật thắng LLM)
 → 4. Ngữ cảnh: trí nhớ của chính user (≤ ~30 mục hay dùng luôn có, phần còn lại tra khi cần — memory-management)
       + 3–5 ví dụ đã xác nhận giống nhất (kNN few-shot — dspy-knn-few-shot; < 20 ví dụ thì dùng bộ cố định)
 → 5. gemma2:2b với prompt ngắn + `format` JSON schema nhỏ, enum khóa (llm-structured-output)
 → 6. Sửa JSON hỏng không cần LLM → validate (Zod) → retry 1 lần kèm lỗi → lùi schema nhỏ hơn
 → 7. Hậu kiểm bằng luật (vd. loại thu/chi lấy theo danh mục, không tin model)
 → 8. Nháp → người dùng xác nhận / sửa / hủy  ⇒ ghi tín hiệu học
```

## 4 lớp tự học
| Lớp | Pattern lấy từ | Phạm vi |
|---|---|---|
| Trí nhớ user (biệt danh, thói quen, ví hay dùng) | Mem0 (trích fact → thêm/sửa/xóa/bỏ qua), Hippo (tốt thì giữ lâu, xấu thì phai) | Riêng user, RLS theo `user_id` (MemClaw) |
| Kho ví dụ đã xác nhận (ẩn danh) | dspy-knn-few-shot, DSPy (chọn demo tốt +65% trên model nhỏ) | Chung cho skill |
| Luật / playbook có bộ đếm có ích–có hại | transaction-categorizer (≥3 lần khớp, conf ≥0.85 → đề xuất luật), ACE / self-improvement-loops (cập nhật từng mục, không viết lại cả sổ), AgentRecall, ThumbGate | Riêng user trước; admin duyệt mới thành luật chung (continuous-learning-v2) |
| Bộ đề hồi quy tự dày lên | promptfoo (provider Ollama), error-analysis (gom lỗi), self-improving-agent (đề xuất → kiểm chứng → áp dụng / loại, có rollback) | Chung; mọi thay đổi lớp 2–3 phải không tụt điểm |

Chu trình ban đêm chạy tuần tự: gom phản hồi → đề xuất ví dụ/luật → chạy bộ đề → tự áp dụng nếu an toàn, còn lại chờ admin duyệt.

## Phải tự viết (không ai có)
- Parser tiền + ngày tiếng Việt, teencode, ví VN (MoMo, ZaloPay), danh mục chi tiêu VN.
- Prompt / schema tối ưu cho model 2B local.
- Bộ nhớ cô lập từng user cho app end-user.
- Router intent cho trợ lý tài chính.

## Cần đo trước khi chốt
- Embedding tiếng Việt: `nomic-embed-text` vs `bge-m3` vs `nomic-embed-text-v2-moe` (512 token).
- Điểm gốc của gemma2:2b trên bộ đề tiếng Việt nội bộ (chưa có benchmark công khai).
- Thử nghiệm nhanh đã thấy: tách câu + tiền + danh mục đúng, nhưng sai loại thu/chi → cần bước 7.
