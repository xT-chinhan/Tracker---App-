# Cài trợ lý AI cho máy dev (plan cho Agent)

Mục tiêu: máy dev đã chạy được backend + admin + app, nay bật **trợ lý AI** (chat ghi giao dịch, hỏi số liệu, đọc ảnh hóa đơn). AI chạy **nội bộ** bằng Ollama, không gọi dịch vụ ngoài, không cần API key.

Agent làm lần lượt từng bước. Mỗi bước có lệnh kiểm tra: kiểm tra không đạt thì dừng lại sửa, không làm bước sau.

## 0. Cần gì

| Thứ | Giá trị |
|---|---|
| Model trả lời + đọc ảnh | `qwen3.5:4b` (~3,3 GB tải về, chiếm ~3 GB VRAM). Bắt buộc gửi `think: false`, backend đã làm sẵn |
| Model embedding | `bge-m3` (~1,2 GB tải về, ~0,7 GB VRAM). Bắt buộc, dùng để định tuyến câu hỏi |
| Ollama | bản ≥ 0.30 (máy gốc chạy 0.30.10) |
| Phần cứng nên có | GPU NVIDIA ≥ 6 GB VRAM (máy gốc: RTX 3050 6 GB), RAM ≥ 16 GB, trống ≥ 6 GB ổ đĩa |
| Không có GPU | Vẫn chạy được bằng CPU nhưng chậm: 10–40 giây mỗi câu, đọc ảnh 30–90 giây. Xem bước 6 |

Không cần tải model nào khác (gemma, nomic-embed-text… đều đã bỏ).

## 1. Cài Ollama

- **Windows / macOS:** tải bộ cài ở https://ollama.com/download, cài xong Ollama tự chạy nền (biểu tượng ở khay hệ thống).
- **Linux:** `curl -fsSL https://ollama.com/install.sh | sh` (cài thành service `ollama`).

Kiểm tra:
```bash
ollama --version                          # ≥ 0.30
curl -s http://localhost:11434/api/tags   # trả JSON {"models":[...]}
```

## 2. Tải 2 model

```bash
ollama pull qwen3.5:4b
ollama pull bge-m3
ollama list        # phải thấy cả qwen3.5:4b và bge-m3:latest
```

Kiểm tra model trả lời được (tắt chế độ suy nghĩ):
```bash
curl -s http://localhost:11434/api/chat -d '{"model":"qwen3.5:4b","stream":false,"think":false,"messages":[{"role":"user","content":"Trả lời đúng 1 từ: xin chào"}]}'
curl -s http://localhost:11434/api/embed -d '{"model":"bge-m3","input":["cà phê 45k"]}' | head -c 120
```
Lệnh 1 phải có `"message":{"role":"assistant","content":"..."}`, lệnh 2 phải có `"embeddings":[[...`.

Có GPU thì kiểm tra model nằm trên GPU: `ollama ps` → cột PROCESSOR là `100% GPU`.

## 3. Cấu hình Ollama (khuyên dùng)

Đặt biến môi trường cho **Ollama** rồi khởi động lại Ollama:

| Biến | Giá trị | Vì sao |
|---|---|---|
| `OLLAMA_NUM_PARALLEL` | `1` | GPU 1 luồng; backend đã xếp hàng tuần tự |
| `OLLAMA_MAX_LOADED_MODELS` | `2` | Giữ cả 2 model trong VRAM, không nạp đi nạp lại |
| `OLLAMA_HOST` | `0.0.0.0` | **Chỉ khi** backend chạy trong Docker (bước 4B) |

- **Linux:** `sudo systemctl edit ollama`, thêm `[Service]` rồi `Environment="OLLAMA_NUM_PARALLEL=1"`, … sau đó `sudo systemctl restart ollama`.
- **Windows:** Cài đặt hệ thống → Biến môi trường → thêm cho user, rồi thoát Ollama ở khay hệ thống và mở lại.
- **macOS:** `launchctl setenv OLLAMA_NUM_PARALLEL 1` (tương tự cho các biến khác), rồi mở lại app Ollama.

## 4. Nối backend với Ollama

### 4A. Backend chạy trực tiếp (`npm run dev`)

Trong `backend/.env`, hoặc `.env` ở gốc repo nếu dự án dùng file đó:
```env
OLLAMA_URL="http://localhost:11434"
AI_CHAT_MODEL="qwen3.5:4b"
AI_EMBED_MODEL="bge-m3"
# KHÔNG đặt AI_PROVIDER=fake (fake = trả lời giả cho test)
```

### 4B. Backend chạy bằng Docker (`docker compose --profile app up -d --build`)

`docker-compose.yml` đã trỏ API tới `http://host.docker.internal:11434`. Chỉ cần:
1. Đặt `OLLAMA_HOST=0.0.0.0` cho Ollama như bước 3, rồi khởi động lại Ollama.
2. Chạy lại `docker compose --profile app up -d --build`.

Kiểm tra từ trong container:
```bash
docker compose exec api node -e "fetch('http://host.docker.internal:11434/api/tags').then(r=>r.text()).then(t=>console.log(t.slice(0,100)))"
```

## 5. Bật AI trong trang quản trị

Cấu hình trong admin được lưu trong DB và **ưu tiên hơn file `.env`**. Đăng nhập admin (`admin@thuchi.vn / admin123`), vào **Cấu hình › Trợ lý AI**:

1. **Bật trợ lý**: bật.
2. **Nhà cung cấp**: chọn **Ollama · nội bộ**, không chọn "Giả lập (kiểm thử)".
3. **Địa chỉ Ollama**: `http://localhost:11434`, hoặc `http://host.docker.internal:11434` nếu backend chạy Docker.
4. **Model trả lời**: `qwen3.5:4b` · **Model embedding**: `bge-m3`.
5. Bấm **Kiểm tra kết nối**: phải hiện "Kết nối được … qwen3.5:4b, bge-m3".
6. Bấm **Lưu**.
7. Kiểm tra thêm **Cấu hình › Nghiệp vụ › Tính năng trong app**: mục Trợ lý AI đang bật.

Khởi động lại backend. Log phải có dòng:
```
[AiWarmup] Đã nạp qwen3.5:4b + bge-m3 (… ms)
```

## 6. Máy không có GPU (hoặc GPU < 4 GB)

- **Cấu hình › Trợ lý AI › Chờ tối đa mỗi câu trả lời**: tăng lên `60` giây.
- **Thời gian chờ đọc ảnh tối đa**: tăng lên `120` giây.
- **Kích thước ảnh tối đa gửi lên**: giảm xuống `512` px để đọc ảnh nhanh hơn.
- RAM ≤ 8 GB: có thể chỉ chạy được trợ lý chat, đọc ảnh sẽ rất chậm hoặc hết bộ nhớ. Khi đó tắt **Đọc ảnh** trong cấu hình.

## 7. Kiểm tra cuối (end-to-end)

1. **Admin › Trợ lý AI**: gõ `tổng quan hệ thống` → có trả lời kèm số liệu.
2. **App (`demo@thuchi.vn / demo123`) › Trợ lý**:
   - `cà phê 45k` → hiện **nháp** khoản chi 45.000đ, danh mục Ăn uống.
   - Bấm **Xác nhận** → giao dịch xuất hiện trong Lịch sử.
   - `tháng này tiêu bao nhiêu` → trả lời số liệu.
3. **App › menu nhấn giữ ＋ › Quét hóa đơn**: chọn một ảnh chụp màn hình chuyển khoản → hiện nháp số tiền, ngày, người nhận.
4. Thời gian trên GPU 6 GB: chat khoảng 1–5 giây, đọc ảnh khoảng 5–20 giây. Câu đầu tiên sau khi bật máy chậm hơn vì phải nạp model.

Kiểm tra nhanh bằng API (thay `<TOKEN>` bằng token đăng nhập của `demo@thuchi.vn`):
```bash
curl -s -X POST localhost:3000/api/ai/conversations -H "authorization: Bearer <TOKEN>" -H 'content-type: application/json' -d '{}'
curl -s -X POST localhost:3000/api/ai/conversations/<ID>/messages -H "authorization: Bearer <TOKEN>" -H 'content-type: application/json' -d '{"text":"cà phê 45k"}'
```
Kết quả đúng: `message.status` là `"ok"`, `message.skill` là `"ghi-giao-dich"`, và `draft.payload.items[0].amount` là `45000`.

## 8. Lỗi hay gặp

| Triệu chứng | Nguyên nhân / cách sửa |
|---|---|
| Trợ lý trả "Xin lỗi, trợ lý đang bận hoặc gặp lỗi" | Ollama chưa chạy, sai địa chỉ hoặc sai tên model → làm lại bước 2 và 5, bấm Kiểm tra kết nối |
| Trả lời kiểu mẫu cố định, không hiểu câu | Nhà cung cấp đang là "Giả lập" (fake), hoặc `.env` có `AI_PROVIDER=fake` → đổi sang Ollama |
| "Máy chủ chưa hỗ trợ đọc ảnh" | Đang dùng model không đọc được ảnh → model trả lời phải là `qwen3.5:4b` |
| Rất chậm (> 30 giây) dù có GPU | Model chạy trên CPU (`ollama ps` không phải 100% GPU), VRAM bị app khác chiếm, hoặc máy đang dùng swap → đóng bớt app, chạy `ollama stop qwen3.5:4b` rồi hỏi lại |
| Trả lời dài, lan man, có `<think>` | Ollama quá cũ, không hiểu `think:false` → nâng Ollama ≥ 0.30 |
| Docker: "fetch failed" tới Ollama | Thiếu `OLLAMA_HOST=0.0.0.0`, hoặc tường lửa chặn cổng 11434 từ mạng Docker |
| Hết RAM, máy treo | Model giữ trong RAM 1 giờ (`AI_KEEP_ALIVE`, mặc định `1h`). Đặt `AI_KEEP_ALIVE=10m` trong `.env` backend, hoặc `ollama stop qwen3.5:4b` khi không dùng |

## 9. Biến môi trường backend liên quan (tham khảo)

| Biến | Mặc định | Ý nghĩa |
|---|---|---|
| `OLLAMA_URL` | `http://localhost:11434` | Địa chỉ Ollama (giá trị khởi tạo; admin sửa được) |
| `AI_CHAT_MODEL` | `qwen3.5:4b` | Model trả lời + đọc ảnh |
| `AI_EMBED_MODEL` | `bge-m3` | Model embedding |
| `AI_PROVIDER` | (trống = ollama) | `fake` = trả lời giả cho test, không dùng cho demo |
| `AI_KEEP_ALIVE` | `1h` | Giữ model trong bộ nhớ bao lâu sau câu cuối |
| `AI_WARMUP` | (bật) | `0` = không nạp sẵn model khi backend khởi động |
| `AI_EXTERNAL_SKILLS` | `1` | `0` = chỉ dùng skill có sẵn trong backend, không nạp thư mục `ai/skills` |
