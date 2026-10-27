/**
 * Làm đẹp tài liệu Swagger (/docs) cho demo: tiêu đề, hướng dẫn lấy token, nhóm tiếng Việt có thứ tự,
 * mô tả ngắn từng endpoint. Chỉ đổi phần mô tả của OpenAPI, không đổi route hay dữ liệu.
 */
import type { OpenAPIObject } from '@nestjs/swagger';

const PUBLIC_URL = 'https://tracker-xt.freepro.online';

export const DOC_DESCRIPTION = `
API của **TrackerX** — quản lý thu chi cá nhân tích hợp trợ lý AI chạy nội bộ (Ollama), đọc ảnh hóa đơn (OCR) và lắng nghe thông báo ngân hàng.

**Gọi thử trong trang này**
1. Mở **Xác thực & tài khoản → POST /api/auth/login**, bấm *Try it out*, nhập \`{"email":"demo@thuchi.vn","password":"demo123"}\` (quản trị: \`admin@thuchi.vn\` / \`admin123\`), bấm *Execute*.
2. Copy giá trị \`accessToken\` trong kết quả.
3. Bấm nút **Authorize** (góc phải trên), dán token, *Authorize*. Token được giữ khi tải lại trang.

Mọi endpoint (trừ đăng ký/đăng nhập/quên mật khẩu, cấu hình công khai, health) cần token. Endpoint nhóm *Quản trị* cần tài khoản ADMIN. Dữ liệu của mỗi người dùng tách biệt: id thuộc người khác trả 404.

Trang quản trị: [${PUBLIC_URL}](${PUBLIC_URL}) · OpenAPI JSON: [/docs/openapi.json](${PUBLIC_URL}/docs/openapi.json)
`;

/** tag gốc trong code → [tên hiển thị, mô tả]; thứ tự mảng = thứ tự hiển thị */
const TAGS: [string, string, string][] = [
  ['auth', 'Xác thực & tài khoản', 'Đăng ký, đăng nhập (JWT), quên/đặt lại mật khẩu bằng mã OTP email, hồ sơ, đổi mật khẩu, đăng xuất mọi thiết bị.'],
  ['wallets', 'Ví', 'Ví tiền mặt / ngân hàng / ví điện tử; số dư tính từ giao dịch và chuyển tiền.'],
  ['categories', 'Danh mục', 'Danh mục thu/chi hệ thống + danh mục riêng của người dùng.'],
  ['transactions', 'Giao dịch', 'Ghi, sửa, xóa, lọc giao dịch; ghi hàng loạt (dùng cho giao dịch tự ghi từ thông báo ngân hàng, chống trùng theo externalRef).'],
  ['transfers', 'Chuyển tiền', 'Chuyển tiền giữa các ví của chính mình.'],
  ['budgets', 'Ngân sách', 'Ngân sách theo tháng (tổng hoặc theo danh mục), cảnh báo 80% và vượt 100%.'],
  ['saving-goals', 'Tiết kiệm', 'Mục tiêu tiết kiệm, nạp / rút.'],
  ['recurring', 'Định kỳ', 'Giao dịch định kỳ (hằng ngày/tuần/tháng/năm), tạm dừng, xem trước lịch.'],
  ['quick-templates', 'Mẫu nhập nhanh', 'Mẫu một chạm như "Cà phê 45k".'],
  ['stats', 'Thống kê & báo cáo', 'Số dư, tổng thu chi, theo danh mục, theo ngày, xu hướng, báo cáo tháng.'],
  ['notifications', 'Thông báo', 'Thông báo theo loại: số dư, ngân sách, hệ thống, bảo mật.'],
  ['export', 'Xuất dữ liệu', 'Xuất giao dịch ra CSV.'],
  ['ai', 'Trợ lý AI', 'Hội thoại với trợ lý AI nội bộ: ghi giao dịch bằng câu nói, đọc ảnh hóa đơn, hỏi số dư/ngân sách; nháp chỉ được lưu khi người dùng xác nhận. AI học từ xác nhận / sửa / "ý tôi là…".'],
  ['config', 'Cấu hình công khai', 'Cấu hình app đọc khi khởi động (tên app, tính năng đang bật, giới hạn).'],
  ['admin', 'Quản trị · người dùng & dữ liệu', 'Tổng quan hệ thống, quản lý người dùng (khóa/mở), giao dịch toàn hệ thống, thông báo toàn hệ thống, danh mục hệ thống.'],
  ['admin ai', 'Quản trị · Trung tâm học AI', 'Thống kê AI, luật / ví dụ học chung chờ duyệt, chạy chu trình học, kiểm tra Ollama, mức dùng AI.'],
  ['admin config', 'Quản trị · cấu hình hệ thống', 'Cấu hình runtime (AI, OCR, giới hạn, SMTP…), lịch sử thay đổi, chế độ bảo trì.'],
  ['health', 'Hệ thống', 'Kiểm tra máy chủ còn sống.'],
];

const SUMMARY: Record<string, string> = {
  PublicConfigController_publicConfig: 'Cấu hình công khai cho app',
  AdminConfigController_get: 'Xem cấu hình hệ thống',
  AdminConfigController_update: 'Cập nhật cấu hình hệ thống',
  AdminConfigController_history: 'Lịch sử thay đổi cấu hình',
  AdminConfigController_maintenance: 'Bật / tắt chế độ bảo trì',
  AdminConfigController_emailTemplates: 'Xem mẫu email (OTP, đặt lại mật khẩu…)',
  AdminConfigController_testSmtp: 'Gửi email thử qua SMTP',
  AuthController_register: 'Đăng ký tài khoản',
  AuthController_login: 'Đăng nhập → accessToken (JWT)',
  AuthController_forgotPassword: 'Quên mật khẩu: gửi mã OTP 6 số qua email',
  AuthController_resetPassword: 'Đặt lại mật khẩu bằng mã OTP',
  AuthController_logoutAll: 'Đăng xuất mọi thiết bị (thu hồi mọi token)',
  AuthController_me: 'Thông tin tài khoản đang đăng nhập',
  AuthController_updateProfile: 'Cập nhật hồ sơ',
  AuthController_deleteAccount: 'Xóa tài khoản và toàn bộ dữ liệu',
  AuthController_changePassword: 'Đổi mật khẩu',
  PhoneController_startLink: '(Phụ) Bắt đầu gắn số điện thoại',
  PhoneController_linkStatus: '(Phụ) Trạng thái gắn số điện thoại',
  PhoneController_remove: '(Phụ) Gỡ số điện thoại',
  PhoneController_startReset: '(Phụ) Quên mật khẩu bằng số điện thoại',
  PhoneController_resetStatus: '(Phụ) Trạng thái xác nhận qua số điện thoại',
  PhoneController_reset: '(Phụ) Đặt lại mật khẩu sau khi xác nhận số',
  PhoneController_inbound: '(Nội bộ) Máy cổng SMS báo tin nhắn đến',
  WalletsController_list: 'Danh sách ví + tổng số dư',
  WalletsController_create: 'Tạo ví',
  WalletsController_get: 'Chi tiết ví',
  WalletsController_update: 'Sửa ví',
  WalletsController_remove: 'Lưu trữ / xóa ví',
  WalletsController_restore: 'Khôi phục ví đã lưu trữ',
  CategoriesController_list: 'Danh sách danh mục (hệ thống + của tôi)',
  CategoriesController_create: 'Tạo danh mục riêng',
  CategoriesController_update: 'Sửa danh mục riêng',
  CategoriesController_remove: 'Lưu trữ danh mục riêng',
  TransactionsController_list: 'Lọc / tìm giao dịch (tháng, ví, danh mục, số tiền, từ khóa)',
  TransactionsController_create: 'Ghi một giao dịch',
  TransactionsController_get: 'Chi tiết giao dịch',
  TransactionsController_update: 'Sửa giao dịch',
  TransactionsController_remove: 'Xóa giao dịch',
  TransactionsController_createMany: 'Ghi hàng loạt (tự ghi từ thông báo ngân hàng, bỏ qua trùng)',
  BudgetsController_list: 'Ngân sách của tháng + mức đã dùng',
  BudgetsController_create: 'Tạo ngân sách',
  BudgetsController_copy: 'Chép ngân sách từ tháng trước',
  BudgetsController_update: 'Sửa hạn mức',
  BudgetsController_remove: 'Xóa ngân sách',
  SavingGoalsController_list: 'Danh sách mục tiêu tiết kiệm',
  SavingGoalsController_create: 'Tạo mục tiêu',
  SavingGoalsController_get: 'Chi tiết mục tiêu + lịch sử nạp/rút',
  SavingGoalsController_update: 'Sửa mục tiêu',
  SavingGoalsController_remove: 'Xóa mục tiêu',
  SavingGoalsController_deposit: 'Nạp tiền vào mục tiêu',
  SavingGoalsController_withdraw: 'Rút tiền khỏi mục tiêu',
  StatsController_balance: 'Tổng số dư các ví',
  StatsController_summary: 'Tổng thu / chi theo khoảng thời gian',
  StatsController_byCategory: 'Chi tiêu theo danh mục',
  StatsController_daily: 'Thu chi theo từng ngày',
  StatsController_trend: 'Xu hướng thu chi nhiều tháng',
  StatsController_report: 'Báo cáo tháng',
  TransfersController_list: 'Lịch sử chuyển tiền',
  TransfersController_create: 'Chuyển tiền giữa hai ví',
  TransfersController_get: 'Chi tiết lần chuyển',
  TransfersController_update: 'Sửa lần chuyển',
  TransfersController_remove: 'Xóa lần chuyển',
  NotificationsController_list: 'Danh sách thông báo (lọc theo loại)',
  NotificationsController_unreadCount: 'Số thông báo chưa đọc (theo loại)',
  NotificationsController_readAll: 'Đánh dấu đã đọc tất cả',
  NotificationsController_read: 'Đánh dấu đã đọc một thông báo',
  QuickTemplatesController_list: 'Danh sách mẫu nhập nhanh',
  QuickTemplatesController_create: 'Tạo mẫu',
  QuickTemplatesController_update: 'Sửa mẫu',
  QuickTemplatesController_remove: 'Xóa mẫu',
  QuickTemplatesController_use: 'Dùng mẫu → tạo giao dịch',
  RecurringController_list: 'Danh sách giao dịch định kỳ',
  RecurringController_create: 'Tạo giao dịch định kỳ',
  RecurringController_runDue: 'Chạy các khoản định kỳ đến hạn của tôi',
  RecurringController_get: 'Chi tiết khoản định kỳ',
  RecurringController_update: 'Sửa khoản định kỳ',
  RecurringController_remove: 'Xóa khoản định kỳ',
  RecurringController_preview: 'Xem trước các lần chạy sắp tới',
  RecurringController_pause: 'Tạm dừng',
  RecurringController_resume: 'Chạy lại',
  ExportController_transactions: 'Tải giao dịch dạng CSV',
  AdminController_overview: 'Tổng quan hệ thống (người dùng, giao dịch, tăng trưởng)',
  AdminController_users: 'Danh sách / tìm người dùng',
  AdminController_user: 'Chi tiết một người dùng',
  AdminController_updateUser: 'Khóa / mở khóa, đổi vai trò người dùng',
  AdminController_transactions: 'Giao dịch toàn hệ thống',
  AdminController_broadcast: 'Gửi thông báo cho toàn bộ người dùng',
  AdminController_broadcasts: 'Lịch sử thông báo toàn hệ thống',
  AdminController_runRecurring: 'Chạy định kỳ đến hạn cho mọi người dùng',
  AdminController_listCategories: 'Danh mục hệ thống',
  AdminController_createCategory: 'Tạo danh mục hệ thống',
  AdminController_updateCategory: 'Sửa danh mục hệ thống',
  AdminController_removeCategory: 'Lưu trữ danh mục hệ thống',
  AdminController_restoreCategory: 'Khôi phục danh mục hệ thống',
  AiController_list: 'Danh sách hội thoại với trợ lý',
  AiController_create: 'Tạo hội thoại mới',
  AiController_get: 'Xem hội thoại (tin nhắn + nháp)',
  AiController_update: 'Đổi tên / ghim / lưu trữ hội thoại',
  AiController_remove: 'Xóa hội thoại',
  AiController_postImage: 'Gửi ảnh hóa đơn / ảnh chuyển khoản → AI đọc và tạo nháp (OCR, ảnh không lưu)',
  AiController_post: 'Gửi một câu → trả lời + nháp giao dịch (vd "cf 45k hôm qua")',
  AiController_stream: 'Như trên nhưng trả lời dạng luồng (SSE)',
  AiController_confirm: 'Xác nhận nháp (có thể kèm bản sửa) → lưu thật + AI học',
  AiController_cancel: 'Hủy nháp',
  AiController_feedback: 'Đánh giá câu trả lời 👍 / 👎',
  AiController_reroute: '"Ý tôi là…": trả lời lại bằng kỹ năng khác + AI học định tuyến',
  AiController_skills: 'Các kỹ năng AI dùng được',
  AiController_memory: 'Trí nhớ AI về tôi (ví hay dùng…)',
  AiController_deleteMemory: 'Xóa một mục trí nhớ',
  AiController_settings: 'Cài đặt AI của tôi (đồng ý góp ví dụ ẩn danh)',
  AiController_setSettings: 'Đổi cài đặt AI',
  AiController_usage: 'Mức dùng AI hôm nay của tôi',
  AiAdminController_stats: 'Thống kê trợ lý AI (kỹ năng, độ trễ, phản hồi)',
  AiAdminController_ocrStats: 'Thống kê đọc ảnh OCR',
  AiAdminController_rules: 'Luật học chung (chờ duyệt / đang dùng)',
  AiAdminController_approveRule: 'Duyệt luật học chung',
  AiAdminController_rejectRule: 'Từ chối luật học chung',
  AiAdminController_examples: 'Ví dụ học chung (ẩn danh)',
  AiAdminController_approveExample: 'Duyệt ví dụ chung',
  AiAdminController_rejectExample: 'Từ chối ví dụ chung',
  AiAdminController_run: 'Chạy chu trình học ngay (bình thường 02:30 hằng đêm)',
  AiAdminController_retention: 'Dọn lịch sử chat quá hạn',
  AiAdminController_ollamaTest: 'Kiểm tra kết nối Ollama',
  AiAdminController_runs: 'Lịch sử các lần chạy học',
  AiAdminController_usage: 'Mức dùng AI toàn hệ thống',
  AiAdminController_usageOf: 'Mức dùng AI của một người dùng',
  AiAdminController_integrity: 'Kiểm tra toàn vẹn dữ liệu AI (cô lập theo người dùng)',
  HealthController_check: 'Máy chủ còn sống',
};

export function decorateDocument(doc: OpenAPIObject): OpenAPIObject {
  doc.info.title = 'TrackerX API';
  doc.info.description = DOC_DESCRIPTION;
  const name = new Map(TAGS.map(([k, n]) => [k, n]));
  for (const ops of Object.values(doc.paths)) {
    for (const op of Object.values(ops) as any[]) {
      if (!op || typeof op !== 'object' || !op.operationId) continue;
      op.summary ??= SUMMARY[op.operationId];
      if (Array.isArray(op.tags)) op.tags = op.tags.map((t: string) => name.get(t) ?? t);
    }
  }
  doc.tags = TAGS.map(([, n, d]) => ({ name: n, description: d }));
  return doc;
}

export const SWAGGER_UI_OPTIONS = {
  customSiteTitle: 'TrackerX API',
  swaggerOptions: { persistAuthorization: true, filter: true, docExpansion: 'none', defaultModelsExpandDepth: -1, displayRequestDuration: true, tryItOutEnabled: false },
};
