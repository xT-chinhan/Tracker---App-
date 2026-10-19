/// API phân trang của backend trả `{items, total, page, limit}` (không có `totalPages`).
/// Bổ sung `totalPages = ceil(total / limit)` trước khi parse để model không lỗi.
Map<String, dynamic> withTotalPages(Map<String, dynamic> json) {
  if (json['totalPages'] is num) return json;
  final total = (json['total'] as num?)?.toInt() ?? 0;
  final limit = (json['limit'] as num?)?.toInt() ?? 0;
  final pages = limit > 0 ? (total + limit - 1) ~/ limit : 1;
  return {...json, 'totalPages': pages < 1 ? 1 : pages};
}
