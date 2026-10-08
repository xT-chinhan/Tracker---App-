/** Nguồn viết tay cho router. BANK = câu mẫu cho kNN (dùng lúc chạy); DEV = chỉnh ngưỡng; TEST = chấm điểm. Ba tập không trùng câu. */
export const SKILLS = ['ghi-giao-dich', 'hoi-so-du', 'tong-ket-thang', 'kiem-tra-ngan-sach', 'tim-giao-dich', 'tien-do-tiet-kiem', 'huong-dan', 'ngoai-pham-vi', 'hoi-lai'] as const;
export type Skill = (typeof SKILLS)[number];

export const BANK: Record<Skill, string[]> = {
  'ghi-giao-dich': ['bánh mì 20k', 'ăn trưa 45k', 'đổ xăng 70k hôm qua', 'grab đi làm 40k trả momo', 'nhận lương 14tr', 'tiền điện 800k',
    'mua giày 1tr2', 'ghi giúp mình cà phê 30k', 'trà sữa 40k với bánh 20k', 'được mẹ cho 500k', 'thêm khoản chi ăn tối 150k'],
  'hoi-so-du': ['ví momo còn bao nhiêu', 'số dư hiện tại', 'tài khoản mb còn bao nhiêu tiền', 'tổng tiền tất cả các ví', 'tiền mặt còn bao nhiêu',
    'techcombank còn nhiêu', 'mình còn bao nhiêu tiền', 'xem số dư các ví'],
  'tong-ket-thang': ['tháng này tiêu bao nhiêu rồi', 'tổng kết tháng 9', 'tháng trước chi những gì nhiều nhất', 'báo cáo thu chi tháng này',
    'tháng này thu nhập bao nhiêu', 'so sánh chi tiêu tháng này với tháng trước', 'tuần này tiêu hết bao nhiêu', 'tháng này dư được bao nhiêu'],
  'kiem-tra-ngan-sach': ['ngân sách ăn uống còn bao nhiêu', 'tháng này có vượt ngân sách không', 'hạn mức mua sắm còn lại', 'còn được tiêu bao nhiêu cho giải trí',
    'ngân sách tháng này thế nào', 'mình sắp vượt hạn mức chưa', 'kiểm tra ngân sách di chuyển', 'đặt ngân sách ăn uống 3tr có ổn không'],
  'tim-giao-dich': ['tìm các khoản grab tuần trước', 'hôm qua mình chi những gì', 'liệt kê giao dịch shopee tháng này', 'lần cuối đổ xăng là khi nào',
    'khoản 500k hôm thứ 2 là gì', 'xem lại giao dịch tiền điện', 'mấy khoản trả bằng momo gần đây', 'tìm giao dịch trên 1 triệu'],
  'tien-do-tiet-kiem': ['mục tiêu mua xe được bao nhiêu phần trăm rồi', 'tiết kiệm đi du lịch tới đâu rồi', 'còn bao lâu nữa đủ tiền mua laptop',
    'quỹ khẩn cấp được bao nhiêu rồi', 'tiến độ các mục tiêu tiết kiệm', 'tháng này góp tiết kiệm chưa', 'mục tiêu tiết kiệm của mình thế nào'],
  'huong-dan': ['làm sao thêm ví mới', 'cách tạo ngân sách', 'xuất báo cáo ra excel thế nào', 'đổi mật khẩu ở đâu', 'hướng dẫn tạo mục tiêu tiết kiệm',
    'làm thế nào để sửa giao dịch', 'app này dùng sao', 'cách xóa một khoản đã ghi', 'tạo giao dịch định kỳ như nào'],
  'ngoai-pham-vi': ['thời tiết hôm nay thế nào', 'kể chuyện cười đi', 'giá vàng hôm nay', 'viết giúp mình đoạn code python', 'nên mua cổ phiếu nào',
    'bạn là ai', 'dịch câu này sang tiếng anh', 'tỉ số trận MU tối qua', 'công thức nấu phở bò'],
  'hoi-lai': ['ừ', 'hả', 'cái đó', 'làm đi', 'sao', 'còn cái kia thì sao', '50k', 'ok', 'cái lúc nãy ấy', 'ờ thế à'],
};

export const DEV: [string, Skill][] = [
  ['cơm gà 45k', 'ghi-giao-dich'], ['hôm qua taxi 120k', 'ghi-giao-dich'], ['nhan thuong 2tr', 'ghi-giao-dich'], ['mua sách 90k trả tiền mặt', 'ghi-giao-dich'],
  ['ví mb bank còn nhiêu tiền', 'hoi-so-du'], ['cho xem số dư', 'hoi-so-du'],
  ['tháng 8 tiêu hết bao nhiêu', 'tong-ket-thang'], ['tổng thu nhập tháng này', 'tong-ket-thang'],
  ['ngân sách mua sắm còn không', 'kiem-tra-ngan-sach'], ['tiêu ăn uống vượt mức chưa', 'kiem-tra-ngan-sach'],
  ['tìm khoản tiền nhà tháng trước', 'tim-giao-dich'], ['tuần rồi đi grab mấy lần', 'tim-giao-dich'],
  ['mục tiêu mua nhà được bao nhiêu rồi', 'tien-do-tiet-kiem'], ['tiết kiệm cưới vợ tới đâu', 'tien-do-tiet-kiem'],
  ['làm sao đổi tên danh mục', 'huong-dan'], ['cách chuyển tiền giữa hai ví', 'huong-dan'],
  ['hôm nay ăn gì ngon', 'ngoai-pham-vi'], ['tỷ giá đô hôm nay', 'ngoai-pham-vi'], ['hát một bài đi', 'ngoai-pham-vi'],
  ['ừm', 'hoi-lai'], ['vậy hả', 'hoi-lai'], ['cái kia', 'hoi-lai'], ['200k', 'hoi-lai'],
  ['ăn sáng', 'ghi-giao-dich'], ['tiền điện tháng này bao nhiêu', 'tim-giao-dich'],
];

export const TEST: [string, Skill][] = [
  // ghi-giao-dich (25)
  ['ca phe 45k', 'ghi-giao-dich'], ['mua áo sơ mi 1tr2 trả bằng momo', 'ghi-giao-dich'], ['hôm qua ăn lẩu với bạn 2 lít', 'ghi-giao-dich'],
  ['sáng nay bánh mì 25k, cà phê 30k', 'ghi-giao-dich'], ['lương về 15tr', 'ghi-giao-dich'], ['mẹ cho 500k', 'ghi-giao-dich'],
  ['tiền nhà tháng 10 4tr5 ck mb', 'ghi-giao-dich'], ['nap dt 100k', 'ghi-giao-dich'], ['đi đám cưới Tuấn mừng 500k', 'ghi-giao-dich'],
  ['xăng xe 70k, rửa xe 40k bằng tiền mặt', 'ghi-giao-dich'], ['phở 50', 'ghi-giao-dich'], ['thứ 4 nhậu với đồng nghiệp hết nửa củ', 'ghi-giao-dich'],
  ['ghi cho mình khoản tiền nước 120k', 'ghi-giao-dich'], ['thêm chi tiêu: cắt tóc 60k', 'ghi-giao-dich'], ['vừa đóng học phí 2tr5', 'ghi-giao-dich'],
  ['an sang 30k, an trua 45k', 'ghi-giao-dich'], ['bán đồ cũ được 350k', 'ghi-giao-dich'], ['netflix 260k', 'ghi-giao-dich'],
  ['ăn trưa', 'ghi-giao-dich'], ['mua đồ hết nhiều tiền quá', 'ghi-giao-dich'], ['hôm qua đổ xăng', 'ghi-giao-dich'],
  ['1 trăm rưỡi tiền ăn tối', 'ghi-giao-dich'], ['lì xì cháu 200k', 'ghi-giao-dich'], ['tối qua đi karaoke hết 400k', 'ghi-giao-dich'],
  ['được thưởng tết 10 củ', 'ghi-giao-dich'],
  // hoi-so-du (7)
  ['momo còn bao nhiêu tiền', 'hoi-so-du'], ['số dư techcombank', 'hoi-so-du'], ['trong ví còn nhiêu', 'hoi-so-du'], ['tổng số dư các tài khoản là bao nhiêu', 'hoi-so-du'],
  ['so du vi tien mat', 'hoi-so-du'], ['mình đang có tổng cộng bao nhiêu tiền', 'hoi-so-du'], ['check số dư giúp mình', 'hoi-so-du'],
  // tong-ket-thang (8)
  ['tháng này mình tiêu bao nhiêu rồi', 'tong-ket-thang'], ['tổng kết chi tiêu tháng trước', 'tong-ket-thang'], ['tháng 9 thu chi thế nào', 'tong-ket-thang'],
  ['chi nhiều nhất vào khoản gì tháng này', 'tong-ket-thang'], ['báo cáo tháng này', 'tong-ket-thang'], ['tuần này xài hết bao nhiêu', 'tong-ket-thang'],
  ['thang nay tieu het bao nhieu', 'tong-ket-thang'], ['so với tháng trước tháng này chi nhiều hơn không', 'tong-ket-thang'],
  // kiem-tra-ngan-sach (8)
  ['ngân sách ăn uống tháng này còn bao nhiêu', 'kiem-tra-ngan-sach'], ['mình có vượt hạn mức không', 'kiem-tra-ngan-sach'], ['budget giải trí còn không', 'kiem-tra-ngan-sach'],
  ['còn được tiêu bao nhiêu cho mua sắm', 'kiem-tra-ngan-sach'], ['ngân sách tháng này sao rồi', 'kiem-tra-ngan-sach'], ['khoản di chuyển sắp hết hạn mức chưa', 'kiem-tra-ngan-sach'],
  ['ngan sach an uong con nhieu khong', 'kiem-tra-ngan-sach'], ['tháng này lố ngân sách chưa', 'kiem-tra-ngan-sach'],
  // tim-giao-dich (8)
  ['tìm khoản shopee tuần trước', 'tim-giao-dich'], ['hôm qua mình đã chi những khoản nào', 'tim-giao-dich'], ['lần gần nhất trả tiền điện là bao giờ', 'tim-giao-dich'],
  ['liệt kê các khoản trên 500k', 'tim-giao-dich'], ['khoản 1tr2 hôm thứ 3 là gì vậy', 'tim-giao-dich'], ['xem các giao dịch momo', 'tim-giao-dich'],
  ['tháng này đi grab bao nhiêu lần', 'tim-giao-dich'], ['tim giao dich ca phe', 'tim-giao-dich'],
  // tien-do-tiet-kiem (7)
  ['mục tiêu mua xe tới đâu rồi', 'tien-do-tiet-kiem'], ['tiết kiệm du lịch Nhật được bao nhiêu phần trăm', 'tien-do-tiet-kiem'], ['bao giờ thì đủ tiền mua iphone', 'tien-do-tiet-kiem'],
  ['quỹ khẩn cấp hiện có bao nhiêu', 'tien-do-tiet-kiem'], ['các mục tiêu tiết kiệm của mình', 'tien-do-tiet-kiem'], ['muc tieu tiet kiem mua laptop', 'tien-do-tiet-kiem'],
  ['tháng này đã bỏ ống heo chưa', 'tien-do-tiet-kiem'],
  // huong-dan (7)
  ['làm sao để thêm danh mục mới', 'huong-dan'], ['cách đặt ngân sách cho ăn uống', 'huong-dan'], ['hướng dẫn xuất file excel', 'huong-dan'],
  ['quên mật khẩu thì làm thế nào', 'huong-dan'], ['muốn xóa giao dịch thì bấm vào đâu', 'huong-dan'], ['lam sao tao muc tieu tiet kiem', 'huong-dan'],
  ['app có chế độ tối không', 'huong-dan'],
  // ngoai-pham-vi (7)
  ['mai trời có mưa không', 'ngoai-pham-vi'], ['kể cho mình nghe chuyện vui', 'ngoai-pham-vi'], ['giá bitcoin bây giờ', 'ngoai-pham-vi'],
  ['viết bài thơ về mùa thu', 'ngoai-pham-vi'], ['có nên vay ngân hàng mua nhà không', 'ngoai-pham-vi'], ['ai là tổng thống mỹ', 'ngoai-pham-vi'],
  ['gợi ý quán ăn ngon ở quận 1', 'ngoai-pham-vi'],
  // hoi-lai (6)
  ['ừ đúng rồi', 'hoi-lai'], ['cái hồi nãy', 'hoi-lai'], ['thế còn', 'hoi-lai'], ['300k', 'hoi-lai'], ['làm luôn đi', 'hoi-lai'], ['hmm', 'hoi-lai'],
];
