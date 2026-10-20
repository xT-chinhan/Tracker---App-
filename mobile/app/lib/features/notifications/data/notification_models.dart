import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/network/paging.dart';

part 'notification_models.freezed.dart';
part 'notification_models.g.dart';

@freezed
abstract class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    DateTime? readAt,
    required DateTime createdAt,
  }) = _NotificationItem;

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      _$NotificationItemFromJson(json);
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
