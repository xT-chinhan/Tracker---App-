abstract final class AppEnvironment {
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:3000/api',
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
