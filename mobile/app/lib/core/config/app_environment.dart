abstract final class AppEnvironment {
  /// Địa chỉ API CỐ ĐỊNH của app (máy chủ của nhóm qua Cloudflare Tunnel, có AI).
  /// KHÔNG đổi, KHÔNG thêm --dart-define để ghi đè — xem API-URL.md ở gốc repo.
  static const apiUrl = 'https://tracker-xt.freepro.online/api';

  static Uri requireApiUri() => Uri.parse(apiUrl);
}
