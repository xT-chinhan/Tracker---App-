import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.code,
    this.retryAfter,
    this.cause,
  });

  final int? statusCode;
  final String message;
  final String? code;
  final Duration? retryAfter;
  final Object? cause;

  bool get isUnauthorized => statusCode == 401;
  bool get isAccountLocked =>
      statusCode == 403 && message == 'Tài khoản đã bị khóa';
  bool get isFeatureDisabled => statusCode == 403 && code == 'FEATURE_DISABLED';
  bool get isMaintenance => statusCode == 503 && code == 'MAINTENANCE';

  factory ApiException.fromDio(DioException error) {
    final response = error.response;
    final data = response?.data;
    String? code;
    String? serverMessage;
    if (data is Map) {
      code = data['code']?.toString();
      final raw = data['message'];
      if (raw is List) {
        serverMessage = raw.map((item) => item.toString()).join('\n');
      } else if (raw != null) {
        serverMessage = raw.toString();
      }
    }
    final retrySeconds = int.tryParse(
      response?.headers.value('retry-after') ?? '',
    );
    return ApiException(
      statusCode: response?.statusCode,
      code: code,
      retryAfter: retrySeconds == null ? null : Duration(seconds: retrySeconds),
      message: serverMessage ?? _fallback(error),
      cause: error,
    );
  }

  static String _fallback(DioException error) => switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout => 'Kết nối quá lâu. Vui lòng thử lại.',
    DioExceptionType.connectionError =>
      'Không thể kết nối máy chủ. Kiểm tra mạng rồi thử lại.',
    DioExceptionType.cancel => 'Yêu cầu đã được hủy.',
    _ => 'Đã có lỗi xảy ra. Vui lòng thử lại.',
  };

  @override
  String toString() => message;
}
