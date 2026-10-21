# Địa chỉ API của app: CỐ ĐỊNH, KHÔNG ĐƯỢC SỬA

> Quy định cho mọi người và mọi AI agent (Claude, Codex, Gemini, Cursor…) làm việc trên repo này.

App điện thoại TrackerX luôn gọi đúng một địa chỉ:

```
https://tracker-xt.freepro.online/api
```

Địa chỉ này nằm ở **một chỗ duy nhất**: `mobile/app/lib/core/config/app_environment.dart` (`AppEnvironment.apiUrl`).

## Cấm

- **Không** đổi giá trị `apiUrl`, không đổi sang `localhost`, `10.0.2.2`, IP LAN hay tên miền khác.
- **Không** thêm lại `String.fromEnvironment('API_URL')`, `--dart-define=API_URL=...`, file `.env`, flavor hay bất cứ cách nào để ghi đè địa chỉ.
- **Không** gắn địa chỉ API thứ hai ở chỗ khác trong code app (mọi request đi qua `dioProvider` → `AppEnvironment.requireApiUri()`).
- **Không** "sửa cho chạy được trên máy mình" bằng cách đổi địa chỉ. App không kết nối được thì xem mục "Không kết nối được" bên dưới.

Muốn đổi địa chỉ thì phải có **chủ dự án đồng ý**, và đổi ở đúng file trên cùng file này.

## Chạy app

```bash
cd mobile/app
flutter pub get
flutter run            # điện thoại thật, emulator, Windows hay Chrome đều dùng chung địa chỉ trên
```

Không cần truyền tham số gì thêm. Tài khoản test: `demo@thuchi.vn / demo123`.

## Địa chỉ đó chạy ở đâu

| Đường dẫn | Là gì |
|---|---|
| `https://tracker-xt.freepro.online/` | Trang quản trị (admin) |
| `https://tracker-xt.freepro.online/api` | API cho app |
| `https://tracker-xt.freepro.online/docs` | Tài liệu API (Swagger) |

- Máy chủ chạy trên **laptop của chủ dự án**, gồm backend NestJS, PostgreSQL, trợ lý AI (Ollama: `qwen3.5:4b` + `bge-m3`) và admin. Tên miền được nối về laptop qua **Cloudflare Tunnel** (tunnel `trackerx-dev`).
- **Laptop tắt hoặc mất mạng thì app, admin và AI đều không dùng được.** Đây không phải lỗi code.

## Không kết nối được

1. Mở `https://tracker-xt.freepro.online/api/health` bằng trình duyệt:
   - ra `{"status":"ok"...}` thì máy chủ ổn, lỗi nằm ở app hoặc ở mạng của điện thoại;
   - lỗi 502 / 530 / không mở được thì **báo chủ dự án bật laptop / máy chủ**.
2. App chạy trên Chrome mà báo lỗi CORS thì báo chủ dự án. Máy chủ cho phép `http://localhost:*`, `http://127.0.0.1:*` và chính tên miền trên.

## Làm backend riêng

Muốn thử backend trên máy mình (sửa API, migration…), dùng **Swagger hoặc Postman** gọi `http://localhost:3000/api`, hoặc test bằng `npm run test`. **Không trỏ app sang backend riêng.** Khi backend chạy ổn thì merge vào `main`; chủ dự án cập nhật máy chủ.
