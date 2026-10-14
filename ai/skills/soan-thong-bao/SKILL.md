---
name: soan-thong-bao
scope: ADMIN
output: draft (BroadcastDraft)
providers: [admin.publicConfig (tên app, hotline), admin.broadcasts (5 tin gần nhất, kiểm trùng), admin.overview (số người nhận)]
llm: viết {title, body} (JSON schema), kiểm tra + retry 1 lần, lùi về template
---
# soan-thong-bao — soạn nháp broadcast

**Khi nào**: "soạn thông báo bảo trì tối nay từ 23h", "viết thông báo giới thiệu tính năng mẫu nhập nhanh", "nhắc mọi người đặt ngân sách tháng mới".

**Pipeline**:
1. Chặn: yêu cầu người dùng cung cấp mật khẩu / OTP / thông tin thẻ → từ chối (mẫu lừa đảo). Nội dung trống → `askBack`.
2. Model (2 ví dụ few-shot) viết `{title, body}`.
3. Kiểm tra (`checkBroadcast`): title 5–120 ký tự, body 20–2000 (giới hạn của `POST /admin/broadcasts`), tiếng Việt có dấu, không placeholder, **mọi chữ số phải có trong yêu cầu** (hoặc hotline cấu hình), không link/email lạ, không đòi mật khẩu/OTP. Hỏng → retry 1 lần kèm lỗi → vẫn hỏng thì template từ chính câu yêu cầu.
4. Reply = nháp + số người nhận (users.active) + cảnh báo nếu trùng tiêu đề tin gần đây.

**Đầu ra**: `draft = { kind: 'broadcast', title, body }`. Chỉ gửi khi admin bấm xác nhận.
