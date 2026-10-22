import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notification_models.dart';
import '../data/notification_repository.dart';

final unreadCountProvider = AsyncNotifierProvider<UnreadCountNotifier, int>(
  UnreadCountNotifier.new,
);

class UnreadCountNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async {
    final repo = ref.watch(notificationRepositoryProvider);
    return repo.getUnreadCount();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(notificationRepositoryProvider);
      return repo.getUnreadCount();
    });
  }

  void decrement() {
    state = state.whenData((count) => count > 0 ? count - 1 : 0);
  }

  void clear() {
    state = const AsyncValue.data(0);
  }
}

class NotificationsState {
  const NotificationsState({
    this.items = const <NotificationItem>[],
    this.tab,
    this.summary = const UnreadSummary(),
    this.total = 0,
    this.page = 1,
    this.totalPages = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<NotificationItem> items;

  /// Tab đang chọn: `null` = Tất cả, còn lại là nhóm (`balance`…).
  final String? tab;
  final UnreadSummary summary;
  final int total;
  final int page;
  final int totalPages;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  /// "Đánh dấu đã đọc" chỉ hiện khi tab đang chọn còn tin chưa đọc.
  bool get canMarkAll =>
      summary.hasUnread(tab) || items.any((i) => i.readAt == null);

  NotificationsState copyWith({
    List<NotificationItem>? items,
    String? Function()? tab,
    UnreadSummary? summary,
    int? total,
    int? page,
    int? totalPages,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
  }) => NotificationsState(
    items: items ?? this.items,
    tab: tab != null ? tab() : this.tab,
    summary: summary ?? this.summary,
    total: total ?? this.total,
    page: page ?? this.page,
    totalPages: totalPages ?? this.totalPages,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    errorMessage: errorMessage,
  );
}

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
      NotificationsController.new,
    );

class NotificationsController extends Notifier<NotificationsState> {
  @override
  NotificationsState build() {
    Future.microtask(load);
    return const NotificationsState(isLoading: true);
  }

  Future<void> _loadSummary() async {
    try {
      final summary = await ref
          .read(notificationRepositoryProvider)
          .getUnreadSummary();
      state = state.copyWith(
        summary: summary,
        errorMessage: state.errorMessage,
      );
    } catch (_) {}
  }

  Future<void> load({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    final repo = ref.read(notificationRepositoryProvider);
    final tab = state.tab;
    final summary = _loadSummary();
    try {
      final result = await repo.list(page: 1, limit: 20, category: tab);
      if (state.tab != tab) return; // đã đổi tab trong lúc tải
      state = state.copyWith(
        items: result.items,
        total: result.total,
        page: result.page,
        totalPages: result.totalPages,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      if (state.tab != tab) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải thông báo. Vui lòng thử lại.',
      );
    }
    await summary;
  }

  Future<void> selectTab(String? tab) async {
    if (tab == state.tab) return;
    state = state.copyWith(
      tab: () => tab,
      items: const [],
      page: 1,
      totalPages: 1,
      isLoading: true,
    );
    await load();
  }

  Future<void> loadMore() async {
    if (state.isLoading ||
        state.isLoadingMore ||
        state.page >= state.totalPages) {
      return;
    }
    state = state.copyWith(isLoadingMore: true);
    final repo = ref.read(notificationRepositoryProvider);
    final tab = state.tab;
    try {
      final nextPage = state.page + 1;
      final result = await repo.list(page: nextPage, limit: 20, category: tab);
      if (state.tab != tab) return;
      state = state.copyWith(
        items: <NotificationItem>[...state.items, ...result.items],
        total: result.total,
        page: result.page,
        totalPages: result.totalPages,
        isLoadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> markRead(String id) async {
    final target = state.items.where((item) => item.id == id).firstOrNull;
    if (target == null || target.readAt != null) return;

    // Optimistic update
    final now = DateTime.now();
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(readAt: now);
        }
        return item;
      }).toList(),
      summary: state.summary.decremented(target.group),
    );
    ref.read(unreadCountProvider.notifier).decrement();

    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markRead(id);
    } catch (_) {
      // Revert if needed
    }
  }

  /// Đánh dấu đã đọc cho tab đang chọn (Tất cả = toàn bộ).
  Future<void> markReadAll() async {
    if (!state.canMarkAll) return;
    final tab = state.tab;

    final now = DateTime.now();
    state = state.copyWith(
      items: state.items
          .map(
            (item) => item.readAt == null && (tab == null || item.group == tab)
                ? item.copyWith(readAt: now)
                : item,
          )
          .toList(),
      summary: state.summary.cleared(tab),
    );
    if (tab == null) ref.read(unreadCountProvider.notifier).clear();

    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markReadAll(category: tab);
    } catch (_) {
      // Revert if error
    }
    await _loadSummary();
    if (tab != null) await ref.read(unreadCountProvider.notifier).refresh();
  }
}
