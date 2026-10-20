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
    this.total = 0,
    this.page = 1,
    this.totalPages = 1,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<NotificationItem> items;
  final int total;
  final int page;
  final int totalPages;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;

  NotificationsState copyWith({
    List<NotificationItem>? items,
    int? total,
    int? page,
    int? totalPages,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
  }) => NotificationsState(
    items: items ?? this.items,
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
    load();
    return const NotificationsState(isLoading: true);
  }

  Future<void> load({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, errorMessage: null);
    }
    final repo = ref.read(notificationRepositoryProvider);
    try {
      final result = await repo.list(page: 1, limit: 20);
      state = state.copyWith(
        items: result.items,
        total: result.total,
        page: result.page,
        totalPages: result.totalPages,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải thông báo. Vui lòng thử lại.',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading ||
        state.isLoadingMore ||
        state.page >= state.totalPages) {
      return;
    }
    state = state.copyWith(isLoadingMore: true);
    final repo = ref.read(notificationRepositoryProvider);
    try {
      final nextPage = state.page + 1;
      final result = await repo.list(page: nextPage, limit: 20);
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
    final target = state.items.firstWhere(
      (item) => item.id == id,
      orElse: () => NotificationItem(
        id: '',
        type: '',
        title: '',
        body: '',
        createdAt: DateTime.now(),
      ),
    );
    if (target.id.isEmpty || target.readAt != null) return;

    // Optimistic update
    final now = DateTime.now();
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == id) {
          return item.copyWith(readAt: now);
        }
        return item;
      }).toList(),
    );
    ref.read(unreadCountProvider.notifier).decrement();

    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markRead(id);
    } catch (_) {
      // Revert if needed
    }
  }

  Future<void> markReadAll() async {
    final hasUnread = state.items.any((item) => item.readAt == null);
    if (!hasUnread) return;

    final now = DateTime.now();
    state = state.copyWith(
      items: state.items.map((item) => item.copyWith(readAt: now)).toList(),
    );
    ref.read(unreadCountProvider.notifier).clear();

    try {
      final repo = ref.read(notificationRepositoryProvider);
      await repo.markReadAll();
    } catch (_) {
      // Revert if error
    }
  }
}
