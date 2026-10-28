# Đóng góp cho TrackerX

Cảm ơn bạn quan tâm tới dự án! Một vài quy ước để mọi thay đổi vào `main` đều chạy ổn.

## Báo lỗi / đề xuất
Mở [issue](https://github.com/xT-chinhan/Tracker---App-/issues) kèm: các bước tái hiện, kết quả mong đợi, kết quả thực tế, ảnh chụp (nếu có) và nền tảng (app Android / admin web / API).

## Quy trình gửi thay đổi
1. Fork, tạo nhánh từ `main`: `feat/<tên>`, `fix/<tên>`.
2. Chạy kiểm thử trước khi gửi:
   ```bash
   npm run test                     # backend e2e + admin Playwright
   cd mobile/app && flutter test    # nếu sửa app
   ```
3. Commit ngắn gọn, mô tả *vì sao* (`feat(ai): …`, `fix(phone): …`, `docs: …`).
4. Mở pull request vào `main`, mô tả thay đổi và cách đã kiểm tra.

## Quy tắc dự án
- **Giao diện mới cần mockup được duyệt trước** (đặt trong `design/`, cùng phong cách: nền ngà, gần đơn sắc).
- **Địa chỉ API của app là cố định** — không đổi `mobile/app/lib/core/config/app_environment.dart` (xem [API-URL.md](API-URL.md)).
- Nghiệp vụ nằm ở `backend/` và được e2e bảo vệ: thêm / sửa endpoint thì thêm kiểm thử tương ứng trong `backend/scripts/e2e.mjs`.
- Không commit bí mật (`.env`, khóa ký APK, token).
