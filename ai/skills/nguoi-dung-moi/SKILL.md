---
name: nguoi-dung-moi
scope: ADMIN
---
# nguoi-dung-moi
Người dùng (role USER) đăng ký trong khoảng thời gian trong câu hỏi (mặc định 30 ngày) và ai chưa ghi giao dịch nào.
Chỉ đọc provider `adminUserActivity`, không gọi model. Trả bảng (tối đa 10 người, mở hồ sơ khi bấm) + dòng nguồn.
Ghi rõ thông báo hệ thống chưa gửi riêng được cho nhóm (backlog: thông báo theo nhóm user).
