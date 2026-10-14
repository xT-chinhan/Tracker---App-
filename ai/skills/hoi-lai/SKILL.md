---
name: hoi-lai
scope: ANY
output: text (askBack)
context: []
llm: không gọi model
---
# hoi-lai — hỏi lại khi chưa rõ

**Khi nào**: router không chắc (điểm kNN dưới ngưỡng) hoặc câu cụt: "ừ", "cái đó", "300k", "thế còn tháng kia".

**Trả lời**: `askBack` + 3 gợi ý theo phiên. Chỉ có số tiền ("300k") → hỏi khoản chi hay thu, cho việc gì (số do parser tính, nằm trong `meta.computed`). Nhắc tới ngữ cảnh trước ("cái đó", "tháng kia") → nói chưa có ngữ cảnh, xin nói rõ. Không gọi model.
