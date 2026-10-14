---
name: tong-quan-he-thong
scope: ADMIN
output: text
providers: [admin.overview]
llm: 1 câu nhận xét (llmSentence), không được chứa số
---
# tong-quan-he-thong — tổng quan hệ thống

**Khi nào**: "tổng quan hệ thống", "có bao nhiêu user", "tháng này hệ thống ghi bao nhiêu giao dịch".

**Dữ liệu**: `admin.overview` (= `GET /admin/overview`): users total/active/locked/new30d, transactions total/new30d/tổng thu/chi, mục tiêu theo trạng thái, trend 6 tháng toàn hệ thống.

**Trả lời** (code): người dùng; giao dịch; mục tiêu tiết kiệm theo trạng thái; chi toàn hệ thống tháng đủ gần nhất so với tháng trước (% thay đổi do code tính, `meta.computed`); tháng hiện tại đến nay. Model viết 1 câu nhận xét định tính.

**Guardrails**: `adminGuard` (phiên USER không bao giờ chạy được); chỉ số tổng hợp, không nêu tên user.
