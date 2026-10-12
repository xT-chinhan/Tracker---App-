/** Đề mù ghi-giao-dich: viết từ spec, không xem code. now = 2026-10-08 (Thứ Năm). Item: "title|amount|categoryName|date|wallet" */
export const BLIND: [string, ...string[]][] = [
  // ===== Ăn uống cơ bản =====
  ['ca phe 45k', 'Cà phê/Cafe|45000|Ăn uống'],
  ['sáng nay ăn phở 50', 'Phở/Ăn phở|50000|Ăn uống'],
  ['tra sua 35k', 'Trà sữa|35000|Ăn uống'],
  ['mua bánh mì 2 ổ 30,000 đ', 'Bánh mì|30000|Ăn uống'],
  ['mua bánh sinh nhật 350k', 'Bánh sinh nhật|350000|Ăn uống'],
  ['nhậu với tụi bạn 1 xị', 'Nhậu|100000|Ăn uống'],
  ['tối qua nhậu hết 2 lít ck mb', 'Nhậu|200000|Ăn uống|-1|mb'],

  // ===== Đi chợ / siêu thị (Ăn uống) =====
  ['đi chợ mua rau thịt hết 150k', 'Đi chợ/Rau thịt|150000|Ăn uống'],
  ['mua 2kg thit heo 240k', 'Thịt heo/Thịt|240000|Ăn uống'],
  ['tiền chợ hôm qua 230 ngàn tiền mặt', 'Tiền chợ/Đi chợ|230000|Ăn uống|-1|c'],
  ['mua 1 chục trứng 35k với bó rau 10k', 'Trứng|35000|Ăn uống', 'Rau|10000|Ăn uống'],
  ['bách hóa xanh 312k thẻ tcb', 'Bách hóa xanh/Đi siêu thị|312000|Ăn uống||t'],
  ['mua bao gạo 25kg 450k', 'Gạo|450000|Ăn uống'],
  ['ra chợ mua cá 120k, mua thêm lốc sữa chua 30k', 'Cá|120000|Ăn uống', 'Sữa chua|30000|Ăn uống'],
  ['đi siêu thị winmart hết 1tr1 quẹt tcb', 'Đi siêu thị/Winmart|1100000|Ăn uống||t'],

  // ===== Vùng miền =====
  ['hồi sáng ăn hủ tiếu 45 ngàn', 'Hủ tiếu|45000|Ăn uống'],
  ['bữa qua ăn mì quảng 40k', 'Mì Quảng|40000|Ăn uống|-1'],
  ['bánh bèo 25k', 'Bánh bèo|25000|Ăn uống'],
  ['trưa nay bún chả 55k, xôi sáng 20k', 'Bún chả|55000|Ăn uống', 'Xôi|20000|Ăn uống'],
  ['xe ôm ra bến xe 30 ngàn', 'Xe ôm|30000|Di chuyển'],
  ['gửi tía 2tr tiền mặt', 'Gửi tía/Gửi ba/Cho tía|2000000|Gia đình||c'],

  // ===== Di chuyển =====
  ['hôm qua đổ xăng 80k trả momo', 'Đổ xăng/Xăng|80000|Di chuyển|-1|m'],
  ['grab di lam 62k tra bang momo', 'Grab/Đi Grab|62000|Di chuyển||m'],
  ['đổ xăng 70k, gửi xe 5k', 'Đổ xăng/Xăng|70000|Di chuyển', 'Gửi xe|5000|Di chuyển'],
  ['rửa xe 40k tiền mặt', 'Rửa xe|40000|Di chuyển||c'],
  ['vé xe về quê 250k', 'Vé xe về quê/Vé xe|250000|Di chuyển'],

  // ===== Mua sắm =====
  ['mua áo khoác 450k', 'Áo khoác|450000|Mua sắm'],
  ['mua tai nghe bluetooth 890k trên lazada', 'Tai nghe/Tai nghe bluetooth|890000|Mua sắm'],
  ['đơn shopee 230k', 'Đơn Shopee/Shopee|230000|Mua sắm'],
  ['mua kem chống nắng 320k với sữa rửa mặt 150k', 'Kem chống nắng|320000|Mua sắm', 'Sữa rửa mặt|150000|Mua sắm'],
  ['22/9 mua giày 1tr350', 'Giày|1350000|Mua sắm|09-22'],

  // ===== Gia đình =====
  ['mua bỉm cho bé 380k', 'Bỉm/Tã|380000|Gia đình'],
  ['hộp sữa bột cho con 650k', 'Sữa bột|650000|Gia đình'],
  ['mua do choi cho con 250k', 'Đồ chơi|250000|Gia đình'],
  ['ck cho bố mẹ 5tr qua mb', 'Gửi bố mẹ/Cho bố mẹ|5000000|Gia đình||mb'],
  ['biếu ông bà nội 1 triệu', 'Biếu ông bà/Biếu ông bà nội|1000000|Gia đình'],
  ['gửi má 3tr', 'Gửi má/Cho má|3000000|Gia đình'],

  // ===== Hóa đơn =====
  ['tien dien thang 9 het 1tr250', 'Tiền điện|1250000|Hóa đơn'],
  ['nap dt 100k', 'Nạp điện thoại/Nạp tiền điện thoại|100000|Hóa đơn'],
  ['tiền nước 180k, tiền wifi 220k', 'Tiền nước|180000|Hóa đơn', 'Tiền wifi/Wifi/Internet|220000|Hóa đơn'],
  ['cuoc dien thoai thang nay 150k tru tcb', 'Cước điện thoại|150000|Hóa đơn||t'],

  // ===== Nhà ở =====
  ['đóng tiền nhà tháng 10 4 triệu rưỡi ck mb', 'Tiền nhà/Tiền thuê nhà|4500000|Nhà ở||mb'],
  ['phí quản lý chung cư 650k', 'Phí chung cư/Phí quản lý|650000|Nhà ở'],

  // ===== Sức khỏe =====
  ['mua thuốc cảm 85k', 'Thuốc/Thuốc cảm|85000|Sức khỏe'],
  ['20/9 nhổ răng khôn hết 700k', 'Nhổ răng/Nha khoa|700000|Sức khỏe|09-20'],
  ['dong tien gym thang 10 500k', 'Gym/Tiền gym|500000|Sức khỏe'],
  ['xét nghiệm máu 450k thanh toán momo', 'Xét nghiệm/Xét nghiệm máu|450000|Sức khỏe||m'],
  ['mua vitamin c 120k', 'Vitamin/Vitamin C|120000|Sức khỏe'],
  ['đóng bảo hiểm y tế 3 trăm', 'Bảo hiểm y tế/BHYT|300000|Sức khỏe'],

  // ===== Giáo dục =====
  ['15/9 đóng học phí 2tr5', 'Học phí|2500000|Giáo dục|09-15'],
  ['đóng học phí cho con 3tr2', 'Học phí|3200000|Giáo dục'],
  ['dang ky khoa hoc tieng anh 2tr', 'Khóa học tiếng Anh/Khóa học|2000000|Giáo dục'],

  // ===== Giải trí =====
  ['xem phim cgv 2 vé 180k, bắp nước 95k', 'Xem phim/Vé phim|180000|Giải trí', 'Bắp nước|95000|Ăn uống'],
  ['gia hạn netflix 260k', 'Netflix|260000|Giải trí'],
  ['tối qua đi karaoke 400k', 'Karaoke|400000|Giải trí|-1'],
  ['trăm rưỡi tiền bida', 'Bida|150000|Giải trí'],

  // ===== Chi khác =====
  ['cat toc 60k, goi dau 30k', 'Cắt tóc|60000|Chi khác', 'Gội đầu|30000|Chi khác'],
  ['5 chục tiền gội đầu', 'Gội đầu|50000|Chi khác'],
  ['lì xì cho cháu 200k', 'Lì xì cháu/Lì xì|200000|Chi khác'],
  ['ủng hộ từ thiện 200k', 'Từ thiện/Ủng hộ|200000|Chi khác'],
  ['photo tài liệu 15 nghìn', 'Photo tài liệu/Photo|15000|Chi khác'],
  ['nộp phạt nguội 800k', 'Phạt nguội|800000|Chi khác'],

  // ===== Hiếu hỉ =====
  ['đi đám cưới bạn thân 1tr', 'Đám cưới|1000000|Hiếu hỉ'],
  ['phúng viếng 500k', 'Phúng viếng/Đám tang|500000|Hiếu hỉ'],
  ['mung tan gia dong nghiep 300k', 'Tân gia/Mừng tân gia|300000|Hiếu hỉ'],
  ['thôi nôi con chị Hai nửa củ', 'Thôi nôi|500000|Hiếu hỉ'],
  ['ngày 3 đi đám giỗ 500k', 'Đám giỗ|500000|Hiếu hỉ|10-03'],

  // ===== Du lịch =====
  ['đặt homestay đà lạt 1tr8', 'Homestay/Homestay Đà Lạt|1800000|Du lịch'],
  ['ve may bay di phu quoc 2 nguoi 3tr6 the tcb', 'Vé máy bay|3600000|Du lịch||t'],
  ['đặt tour hạ long 4.5tr', 'Tour Hạ Long/Tour|4500000|Du lịch'],

  // ===== Thu nhập =====
  ['nhan luong 18tr vao tcb', 'Lương|18000000|Lương||t'],
  ['thứ 6 tuần trước nhận lương 22 triệu', 'Lương|22000000|Lương|10-02'],
  ['hôm qua lương về 16tr, được thưởng thêm 2tr', 'Lương|16000000|Lương|-1', 'Thưởng|2000000|Thưởng|-1'],
  ['nhận thưởng KPI quý 3 5tr về tcb', 'Thưởng KPI|5000000|Thưởng||t'],
  ['lai tiet kiem thang nay 320k', 'Lãi tiết kiệm|320000|Đầu tư'],
  ['co tuc vnm 1tr2 ve tcb', 'Cổ tức/Cổ tức VNM|1200000|Đầu tư||t'],
  ['chốt lời coin được 2tr3', 'Lãi coin/Chốt lời coin|2300000|Đầu tư'],
  ['má cho 2 triệu', 'Má cho/Được má cho|2000000|Được tặng'],
  ['ba gửi cho 1tr xài', 'Ba cho/Được ba cho|1000000|Được tặng'],
  ['được lì xì 500k', 'Được lì xì/Lì xì|500000|Được tặng'],
  ['bán xe cũ được 8tr', 'Bán xe/Bán xe cũ|8000000|Thu khác'],
  ['bán đồ cũ trên chợ tốt được 650k', 'Bán đồ cũ|650000|Thu khác'],
  ['ngày 25 bán điện thoại cũ được 3tr5', 'Bán điện thoại cũ/Bán điện thoại|3500000|Thu khác|09-25'],
  ['shopee hoan tien 45.000đ', 'Hoàn tiền/Shopee hoàn tiền|45000|Thu khác'],
  ['cashback momo 15k', 'Hoàn tiền/Cashback|15000|Thu khác||m'],
  ['day kem dc 1tr5', 'Dạy kèm|1500000|Thu khác'],
  ['làm freelance thiết kế logo được 3 củ', 'Freelance/Thiết kế logo|3000000|Thu khác'],
  ['làm thêm cuối tuần được 800 nghìn tiền mặt', 'Làm thêm|800000|Thu khác||c'],
  ['trúng thưởng bốc thăm 1 triệu', 'Trúng thưởng|1000000|Thu khác'],

  // ===== Nhiều món + ngày =====
  ['hôm kia ăn sáng 30k, cf 25k, ăn trưa 45k', 'Ăn sáng|30000|Ăn uống|-2', 'Cà phê/Cafe|25000|Ăn uống|-2', 'Ăn trưa|45000|Ăn uống|-2'],
  ['thứ 2 đổ xăng 80k, thay nhớt 150k, rửa xe 30k, gửi xe 5k', 'Đổ xăng/Xăng|80000|Di chuyển|10-05', 'Thay nhớt|150000|Di chuyển|10-05', 'Rửa xe|30000|Di chuyển|10-05', 'Gửi xe|5000|Di chuyển|10-05'],
  ['cn vua roi di sieu thi 650k, xem phim 200k tra momo', 'Đi siêu thị/Siêu thị|650000|Ăn uống|10-04|m', 'Xem phim|200000|Giải trí|10-04|m'],
  ['t7 tuan truoc an lau 450k', 'Ăn lẩu/Lẩu|450000|Ăn uống|10-03'],
  ['thứ 3 tuần rồi khám bệnh 300k', 'Khám bệnh|300000|Sức khỏe|09-29'],
  ['mùng 5 đóng tiền điện 820k, tiền nước 150k, internet 220k ck mb', 'Tiền điện|820000|Hóa đơn|10-05|mb', 'Tiền nước|150000|Hóa đơn|10-05|mb', 'Internet/Wifi|220000|Hóa đơn|10-05|mb'],

  // ===== ASK (không có item) =====
  ['300k'],
  ['hết 200k hôm qua'],
  ['hôm nay ăn phở'],
  ['di grab di lam ko nho bao nhieu'],
  ['chuyển 2tr từ mb sang momo'],
  ['rút 500k tiền mặt từ tcb'],
  ['nạp 1tr vào momo từ mb'],
  ['ck tu tcb qua mb 3tr'],
  ['cho Nam vay 2tr'],
  ['vay chị 5tr'],
  ['trả nợ 1tr'],
  ['thằng Tuấn trả lại 500k hôm bữa mượn'],
  ['đưa nó 200k'],
];
