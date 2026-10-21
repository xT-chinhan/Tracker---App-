abstract final class AppEnvironment {
  /// Mặc định: API dev public qua Cloudflare Tunnel (máy chủ của nhóm, có AI).
  /// Chạy backend riêng thì ghi đè: --dart-define=API_URL=http://<IP>:3000/api
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://trackerx-api.freepro.online/api',
  );

  static Uri requireApiUri() {
    final value = apiUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(value);
    if (value.isEmpty || uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw const FormatException(
        'Thiếu API_URL hợp lệ. Chạy app với '
        '--dart-define=API_URL=http://10.0.2.2:3000/api',
      );
    }
    return uri;
  }
}
