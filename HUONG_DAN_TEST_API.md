# HƯỚNG DẪN CHẠY & KIỂM THỬ API QUA SWAGGER UI

Tài liệu này hướng dẫn chi tiết từng bước cách thiết lập môi trường, khởi động server và thực hiện kiểm thử API trực quan qua **Swagger UI** (tương tự như màn hình minh họa bạn mong muốn).

---

## 1. Các địa chỉ dịch vụ chính

Khi server hoạt động, hệ thống cung cấp các cổng dịch vụ sau:

| Dịch vụ | Địa chỉ truy cập | Ghi chú |
|---|---|---|
| **Swagger UI** | [http://localhost:3000/docs](http://localhost:3000/docs) | **Giao diện trực quan để test mọi API trực tiếp trên trình duyệt** |
| **OpenAPI Spec** | [http://localhost:3000/docs/openapi.json](http://localhost:3000/docs/openapi.json) | File JSON mô tả toàn bộ 86 API (dùng import Postman/Bruno) |
| **Backend API** | [http://localhost:3000/api](http://localhost:3000/api) | Đường dẫn gốc gọi API |
| **Admin Web** | [http://localhost:5173](http://localhost:5173) | Giao diện quản trị web React |
| **PostgreSQL DB**| `localhost:5433` | Cơ sở dữ liệu Docker (user: `tracker`, pass: `tracker`, db: `tracker`) |

---

## 2. Chuẩn bị môi trường & Khởi động (Dành cho Windows)

### Bước 2.1: Mở quyền thực thi script trong PowerShell (Chỉ làm 1 lần)
Mở cửa sổ PowerShell trong thư mục dự án và chạy:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```
*(Nếu hiện bảng hỏi xác nhận, nhấn **`Y`** hoặc **`A`** rồi Enter)*.

---

### Bước 2.2: Thiết lập hệ thống ban đầu (Setup)
Lệnh này sẽ tự động: cài đặt thư viện (`node_modules`), bật container PostgreSQL qua Docker, áp dụng migrations, cấu hình `.env` và nạp toàn bộ dữ liệu mẫu demo:
- Dùng `npm.cmd run setup` (Dùng lệnh npm.cmd để khắc phục sự cố "Bị chặn do chính sách thực thi")

> Khi màn hình hiện thông báo xanh: `✔ Xong sau ...s. Chạy: npm run dev` nghĩa là cài đặt đã thành công.

---

### Bước 2.3: Khởi động Server (Dev Mode)
Chạy lệnh sau để khởi động đồng thời cả Backend API và Admin Web:
- Dùng `npm.cmd run dev` (Dùng lệnh npm.cmd để khắc phục sự cố "Bị chặn do chính sách thực thi")

---

## 3. Hướng dẫn từng bước kiểm thử API qua Swagger UI

### Bước 3.1: Mở giao diện Swagger UI
Mở trình duyệt (Google Chrome, Microsoft Edge,...) và truy cập vào:
👉 **[http://localhost:3000/docs](http://localhost:3000/docs)**

---

### Bước 3.2: Thử gọi API công khai (Không cần đăng nhập)
1. Trong danh sách endpoint, kéo đến nhóm **`health`**.
2. Nhấp vào dòng **`GET /api/health`**.
3. Bấm nút **Try it out** ở góc trên bên phải.
4. Bấm nút **Execute** (màu xanh dương).
5. Kéo xuống phần **Server response**:
   - **Code**: `200`
   - **Response body**:
     ```json
     {
       "status": "ok",
       "db": "up",
       "version": "0.1.0"
     }
     ```

---

### Bước 3.3: Lấy Token xác thực (JWT Bearer Token)
Hầu hết các API quản lý thu chi yêu cầu phải đăng nhập. Bạn lấy token như sau:

1. Tìm nhóm **`auth`** trên Swagger UI.
2. Nhấp vào dòng **`POST /api/auth/login`**.
3. Bấm **Try it out**.
4. Trong ô **Request body**, điền thông tin tài khoản demo:
   ```json
   {
     "email": "demo@thuchi.vn",
     "password": "demo123"
   }
   ```
5. Bấm nút **Execute**.
6. Tại phần **Response body**, bôi đen và sao chép toàn bộ chuỗi token trong `"accessToken": "..."` *(không lấy dấu ngoặc kép)*:
   ```
   eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

---

### Bước 3.4: Kích hoạt Token trên Swagger UI (Authorize)
1. Cuộn lên đầu trang Swagger UI, nhấp vào nút **Authorize 🔓** (màu xanh lá cây bên phải).
2. Trong cửa sổ hiện ra, dán chuỗi token vừa copy vào ô **Value**.
3. Nhấp nút **Authorize** bên dưới, sau đó nhấp **Close**.
4. Biểu tượng ổ khóa sẽ chuyển sang trạng thái đã khóa 🔒, báo hiệu mọi request tiếp theo sẽ tự động đính kèm token.

---

### Bước 3.5: Kiểm thử các API nghiệp vụ chính

Sau khi đã Authorize, bạn có thể thử bất kỳ API nào bằng cách bấm **Try it out** ➔ **Execute**:

#### A. Danh sách Ví tiền (`wallets`)
- Endpoint: `GET /api/wallets`
- Bấm **Try it out** ➔ **Execute**
- **Kết quả trả về**: Object gồm `totalBalance` (tổng số dư các ví) và mảng `items` chứa từng ví:
  ```json
  {
    "totalBalance": 26022000,
    "items": [
      {
        "id": "...",
        "name": "MB Bank",
        "type": "BANK",
        "initialBalance": 15000000,
        "balance": 18672000,
        "color": "#1E3A8A"
      },
      {
        "id": "...",
        "name": "Techcombank",
        "type": "BANK",
        "initialBalance": 2000000,
        "balance": 4000000,
        "color": "#DC2626"
      },
      {
        "id": "...",
        "name": "Tiền mặt",
        "type": "CASH",
        "initialBalance": 1200000,
        "balance": 1850000,
        "color": "#16A34A"
      },
      {
        "id": "...",
        "name": "MoMo",
        "type": "EWALLET",
        "initialBalance": 300000,
        "balance": 1500000,
        "color": "#A50064"
      }
    ]
  }
  ```
  *(Lưu ý: Nếu đăng nhập bằng `admin@thuchi.vn`, bạn sẽ chỉ thấy 1 ví "Tiền mặt" ban đầu với `totalBalance: 0` vì Admin là tài khoản quản trị, không có phát sinh dữ liệu chi tiêu mẫu).*

#### B. Danh mục Thu & Chi (`categories`)
- Endpoint: `GET /api/categories`
- Bấm **Try it out** ➔ **Execute**
- **Kết quả trả về**: Danh sách các danh mục hệ thống và danh mục cá nhân (Ăn uống, Di chuyển, Mua sắm, Tiền lương,...).

#### C. Lịch sử Giao dịch (`transactions`)
- Endpoint: `GET /api/transactions`
- Có thể truyền tham số lọc như `month=2026-10` hoặc để trống.
- Bấm **Try it out** ➔ **Execute**
- **Kết quả trả về**: Danh sách các khoản chi tiêu / thu nhập kèm số tiền, ngày giờ và ví thanh toán.

#### D. Tạo một giao dịch mới
- Endpoint: `POST /api/transactions`
- Bấm **Try it out**, điền body:
  ```json
  {
    "type": "EXPENSE",
    "amount": 45000,
    "title": "Cà phê sáng",
    "walletId": "<id-ví-lấy-từ-get-wallets>",
    "categoryId": "<id-danh-mục-lấy-từ-get-categories>",
    "occurredAt": "2026-10-17T08:00:00.000Z"
  }
  ```
- Bấm **Execute** ➔ Trả về `201 Created` kèm thông tin khoản chi vừa ghi.

---

## 4. Danh sách tài khoản thử nghiệm có sẵn

Dữ liệu demo đã nạp sẵn các tài khoản sau để bạn test:

| Tài khoản (Email) | Mật khẩu | Quyền | Mô tả dữ liệu |
|---|---|---|---|
| **`admin@thuchi.vn`** | `admin123` | **ADMIN** | Quản trị viên hệ thống (truy cập các route `/admin/*`, cấu hình hệ thống, phát thông báo broadcast) |
| **`demo@thuchi.vn`** | `demo123` | **USER** | Người dùng chính (Nguyễn Minh Anh): có 12 tháng lịch sử, 4 ví, 3 mục tiêu tiết kiệm, giao dịch định kỳ |
| **`hung.vu89@demo.thuchi.vn`** | `demo123` | **USER** | Một trong ~39 người dùng mẫu khác để test đa người dùng |

---

## 5. Các lệnh thường dùng & Xử lý lỗi (FAQ)

### Nạp lại dữ liệu demo khi bị xáo trộn:
Nếu bạn thực hiện nhiều thao tác thêm/xóa và muốn đưa dữ liệu demo về trạng thái ban đầu:
```powershell
npm run db:seed:demo
```
*(Lệnh này chỉ xóa và tạo lại dữ liệu của các tài khoản demo, hoàn toàn không ảnh hưởng tài khoản thật)*.

### Kiểm tra sức khỏe container PostgreSQL:
```powershell
npm run db:up
```

### Lỗi `EPERM` hoặc file bị khóa trên Windows:
- **Nguyên nhân**: Trên Windows, khi server `backend` đang chạy, thư viện Prisma native engine (`query_engine-windows.dll.node`) sẽ bị giữ khóa bởi hệ thống.
- **Cách xử lý**: Nhấn `Ctrl + C` ở terminal đang chạy `npm run dev` trước khi chạy các lệnh `setup` hoặc `prisma generate`.

---

> [!NOTE]
> **Quy tắc làm việc trên nhánh `api-test`:**  
> Tuyệt đối **không tự ý `git push`** bất kỳ thay đổi nào lên remote repository trừ khi có yêu cầu cụ thể.
