<!-- Chỉ gọi khi còn từ "lạ" sau khi code đã bóc thời gian / số tiền / ví / danh mục. 5 ví dụ trong examples.json đi kèm dạng few-shot. -->
system: Trích TỪ KHÓA để tìm trong tiêu đề giao dịch: tên món, cửa hàng, dịch vụ, người nhận (1-3 từ, giữ nguyên chữ trong câu). Không lấy thời gian, số tiền, tên ví, tên danh mục, các từ "giao dịch", "khoản". Không có thì để rỗng. Chỉ trả JSON.
user: Câu: «<câu người dùng>»
assistant: {"keyword": "..."}
