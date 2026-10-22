import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/network/paging.dart';

part 'notification_models.freezed.dart';
part 'notification_models.g.dart';

/// Nhóm hiển thị (khớp backend `src/notifications/categories.ts`).
const notificationCategories = <String>[
  'balance',
  'budget',
  'system',
  'security',
];

/// Suy nhóm từ `type` khi máy chủ cũ chưa trả `category`.
String categoryOfType(String type) => switch (type) {
  'BALANCE_CHANGE' => 'balance',
  'BUDGET_WARNING' || 'BUDGET_EXCEEDED' => 'budget',
  'SECURITY' => 'security',
  _ => 'system',
};

String categoryLabel(String category) => switch (category) {
  'balance' => 'Số dư',
  'budget' => 'Ngân sách',
  'security' => 'Bảo mật',
  _ => 'Hệ thống',
};

@freezed
abstract class NotificationItem with _$NotificationItem {
  const NotificationItem._();

  const factory NotificationItem({
    required String id,
    required String type,
    required String title,
    required String body,
    String? category,
    Map<String, dynamic>? data,
    DateTime? readAt,
    required DateTime createdAt,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);

  /// `balance` | `budget` | `system` | `security`.
  String get group => notificationCategories.contains(category)
      ? category!
      : categoryOfType(type);

  /// Id giao dịch app tự ghi (thông báo Biến động số dư), để Hoàn tác.
  String? get transactionId {
    final id = data?['transactionId'];
    return id is String && id.isNotEmpty ? id : null;
  }
}

/// Số chưa đọc: tổng và theo nhóm.
class UnreadSummary {
  const UnreadSummary({this.count = 0, this.byCategory = const {}});

  factory UnreadSummary.fromJson(Map<String, dynamic> json) {
    final by = json['byCategory'];
    return UnreadSummary(
      count: (json['count'] as num?)?.toInt() ?? 0,
      byCategory: by is Map
          ? {
              for (final e in by.entries)
                if (e.value is num) '${e.key}': (e.value as num).toInt(),
            }
          : const {},
    );
  }

  final int count;
  final Map<String, int> byCategory;

  /// Tab có tin chưa đọc không (`null` = Tất cả).
  bool hasUnread(String? tab) =>
      tab == null ? count > 0 : (byCategory[tab] ?? 0) > 0;

  /// Sau khi đánh dấu đã đọc một tab (`null` = tất cả).
  UnreadSummary cleared(String? tab) {
    if (tab == null) return const UnreadSummary();
    final n = byCategory[tab] ?? 0;
    return UnreadSummary(
      count: count - n < 0 ? 0 : count - n,
      byCategory: {...byCategory, tab: 0},
    );
  }

  /// Một tin của nhóm [tab] vừa được đọc.
  UnreadSummary decremented(String tab) {
    final n = byCategory[tab] ?? 0;
    return UnreadSummary(
      count: count > 0 ? count - 1 : 0,
      byCategory: {...byCategory, tab: n > 0 ? n - 1 : 0},
    );
  }
}

@freezed
abstract class NotificationPage with _$NotificationPage {
  const factory NotificationPage({
    @Default(<NotificationItem>[]) List<NotificationItem> items,
    required int total,
    required int page,
    required int limit,
    required int totalPages,
  }) = _NotificationPage;

  factory NotificationPage.fromJson(Map<String, dynamic> json) =>
      _$NotificationPageFromJson(withTotalPages(json));
}
