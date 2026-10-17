import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/ai/data/ai_models.dart';
import 'package:app/features/ai/data/ai_repository.dart';
import 'package:app/features/ai/presentation/ai_chat_screen.dart';
import 'package:app/features/ai/presentation/ai_conversations_screen.dart';
import 'package:app/features/ai/presentation/ai_settings_screen.dart';
import 'package:app/features/ai/presentation/conversation_action_sheet.dart';
import 'package:app/features/auth/application/app_session.dart';
import 'package:app/features/transactions/data/transaction_repository.dart';
import 'package:app/features/wallets/data/wallet_models.dart';
import 'package:app/features/wallets/data/wallet_repository.dart';
import '../../helpers/fixtures.dart';

class FakeAiRepository extends AiRepository {
  FakeAiRepository() : super(Dio());

  List<AiConversationItem> conversations = [
    AiConversationItem(
      id: 'c-1',
      title: 'Ghi chi tiêu hằng ngày',
      pinned: true,
      archived: false,
      messageCount: 3,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AiConversationItem(
      id: 'c-2',
      title: 'Ngân sách còn lại',
      pinned: false,
      archived: false,
      messageCount: 4,
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    AiConversationItem(
      id: 'c-3',
      title: 'Tiết kiệm Đà Lạt',
      pinned: false,
      archived: false,
      messageCount: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  List<AiConversationItem> archivedConversations = [
    AiConversationItem(
      id: 'c-archived-1',
      title: 'Chuyến đi Vũng Tàu',
      pinned: false,
      archived: true,
      messageCount: 8,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    AiConversationItem(
      id: 'c-archived-2',
      title: 'Chi tiêu Tết 2026',
      pinned: false,
      archived: true,
      messageCount: 15,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 50)),
    ),
  ];

  List<AiMemoryItem> memories = [
    AiMemoryItem(
      id: 'mem-1',
      key: 'cà phê',
      value: 'Ăn uống · MoMo',
      source: 'Từ 23 lần bạn xác nhận',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    AiMemoryItem(
      id: 'mem-2',
      key: 'xăng',
      value: 'Di chuyển · Tiền mặt',
      source: 'Bạn sửa lúc 19:49 hôm nay',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  AiSettings settings = const AiSettings(shareExamples: false, asked: true);
  String? updatedTitle;
  bool? updatedPinned;
  bool? updatedArchived;
  String? deletedConversationId;
  String? deletedMemoryId;
  String? confirmedDraftId;
  String? cancelledDraftId;
  int feedbackRating = 0;
  String? reroutedSkill;
  bool shouldThrowDailyLimit = false;

  @override
  Future<AiConversationPage> listConversations({
    bool? archived,
    int page = 1,
    int limit = 20,
  }) async {
    final list = (archived == true) ? archivedConversations : conversations;
    return AiConversationPage(
      items: list,
      total: list.length,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<CreateConversationResponse> createConversation({String? title}) async {
    final conv = AiConversationItem(
      id: 'c-new-${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Cuộc trò chuyện mới',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    conversations.insert(0, conv);
    return CreateConversationResponse(
      id: conv.id,
      title: conv.title,
      createdAt: conv.createdAt,
      updatedAt: conv.updatedAt,
    );
  }

  @override
  Future<AiConversationDetail> getConversation(String id) async {
    return AiConversationDetail(
      id: id,
      title: 'Ghi chi tiêu hằng ngày',
      messages: [
        AiMessageItem(
          id: 'm-1',
          conversationId: id,
          role: 'USER',
          content: 'hôm qua sáng cà phê 45k, trưa cơm 55k, tối xăng 80k',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        AiMessageItem(
          id: 'm-2',
          conversationId: id,
          role: 'ASSISTANT',
          content: 'Mình tách được 3 khoản chi. Chưa có gì được lưu.',
          latencyMs: 1100,
          createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
          draft: AiDraftItem(
            id: 'd-1',
            messageId: 'm-2',
            skill: 'nhap-giao-dich',
            kind: 'transactions',
            status: 'PROPOSED',
            createdAt: DateTime(2026, 9, 21),
            payload: {
              'items': [
                {
                  'title': 'Cà phê sáng',
                  'amount': 45000,
                  'categoryName': 'Ăn uống',
                  'walletName': 'MoMo',
                  'date': '2026-09-21',
                },
                {
                  'title': 'Cơm trưa',
                  'amount': 55000,
                  'categoryName': 'Ăn uống',
                  'walletName': 'Tiền mặt',
                  'date': '2026-09-21',
                },
                {
                  'title': 'Đổ xăng',
                  'amount': 80000,
                  'categoryName': 'Di chuyển',
                  'walletName': 'Techcombank',
                  'date': '2026-09-21',
                },
              ],
            },
          ),
          followUps: ['So với tháng 8?', 'Ăn uống chi gì nhiều?'],
        ),
      ],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<AiConversationItem> updateConversation(
    String id, {
    String? title,
    bool? archived,
    bool? pinned,
  }) async {
    updatedTitle = title;
    updatedPinned = pinned;
    updatedArchived = archived;
    return conversations.firstWhere((c) => c.id == id);
  }

  @override
  Future<void> deleteConversation(String id) async {
    deletedConversationId = id;
    conversations.removeWhere((c) => c.id == id);
  }

  @override
  Stream<AiStreamEvent> streamMessage(
    String conversationId,
    String text, {
    CancelToken? cancelToken,
  }) async* {
    if (shouldThrowDailyLimit) {
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 429,
          data: {'code': 'AI_DAILY_LIMIT'},
        ),
      );
    }

    final userMsg = AiMessageItem(
      id: 'm-u-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      role: 'USER',
      content: text,
      createdAt: DateTime.now(),
    );
    yield AiStreamUserEvent(userMsg);
    yield const AiStreamRouteEvent(skill: 'tong-ket-thang');
    yield const AiStreamDeltaEvent('Tháng 9 ');
    yield const AiStreamDeltaEvent('bạn đã chi 8.680.000đ.');

    final asstMsg = AiMessageItem(
      id: 'm-a-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      role: 'ASSISTANT',
      content: 'Tháng 9 bạn đã chi 8.680.000đ.',
      latencyMs: 800,
      createdAt: DateTime.now(),
    );
    yield AiStreamDoneEvent(message: asstMsg);
  }

  @override
  Future<ConfirmDraftResponse> confirmDraft(
    String draftId, {
    Map<String, dynamic>? payload,
  }) async {
    confirmedDraftId = draftId;
    return ConfirmDraftResponse(
      draft: AiDraftItem(
        id: draftId,
        messageId: 'm-2',
        skill: 'nhap-giao-dich',
        kind: 'transactions',
        status: 'CONFIRMED',
        createdAt: DateTime.now(),
        resolvedAt: DateTime.now(),
      ),
      result: [
        {'id': 'tx-1', 'title': 'Cà phê sáng', 'amount': 45000},
        {'id': 'tx-2', 'title': 'Cơm trưa', 'amount': 55000},
        {'id': 'tx-3', 'title': 'Đổ xăng', 'amount': 80000},
      ],
    );
  }

  @override
  Future<void> cancelDraft(String draftId) async {
    cancelledDraftId = draftId;
  }

  @override
  Future<void> feedback(
    String messageId, {
    required int rating,
    String? comment,
  }) async {
    feedbackRating = rating;
  }

  @override
  Future<PostMessageResponse> reroute(
    String messageId, {
    required String skill,
  }) async {
    reroutedSkill = skill;
    return PostMessageResponse(
      userMessage: AiMessageItem(
        id: 'u-re',
        conversationId: 'c-1',
        role: 'USER',
        content: 'rerouted',
        createdAt: DateTime.now(),
      ),
      message: AiMessageItem(
        id: 'm-re',
        conversationId: 'c-1',
        role: 'ASSISTANT',
        content: 'Đã hiểu theo $skill',
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<AiUsage> getUsage() async {
    return const AiUsage(
      messagesToday: 20,
      dailyMessageLimit: 30,
      activeConversations: 3,
      maxConversations: 50,
    );
  }

  @override
  Future<List<AiMemoryItem>> getMemory() async => memories;

  @override
  Future<void> deleteMemory(String id) async {
    deletedMemoryId = id;
    memories.removeWhere((m) => m.id == id);
  }

  @override
  Future<AiSettings> getSettings() async => settings;

  @override
  Future<AiSettings> updateSettings({required bool shareExamples}) async {
    settings = settings.copyWith(shareExamples: shareExamples);
    return settings;
  }

  @override
  Future<List<AiSkillItem>> getSkills() async => [
    const AiSkillItem(name: 'ghi-nhanh', label: 'Ghi một khoản tiền mới'),
    const AiSkillItem(name: 'ngan-sach', label: 'Xem ngân sách'),
    const AiSkillItem(name: 'tim-kiem', label: 'Tìm giao dịch trước đó'),
  ];
}

class FakeTxRepository extends TransactionRepository {
  FakeTxRepository() : super(Dio());
  List<String> deletedIds = [];

  @override
  Future<void> deleteTransaction(String id) async {
    deletedIds.add(id);
  }
}

class FakeWalletRepo extends WalletRepository {
  FakeWalletRepo() : super(Dio());

  @override
  Future<WalletListResponse> getWallets() async => const WalletListResponse(
    totalBalance: 26022000,
    items: [
      WalletItem(id: 'w-1', name: 'MB Bank', type: 'BANK', balance: 18672000),
      WalletItem(id: 'w-2', name: 'MoMo', type: 'EWALLET', balance: 1500000),
      WalletItem(id: 'w-3', name: 'Tiền mặt', type: 'CASH', balance: 1850000),
    ],
  );
}

void main() {
  testWidgets(
    'AiConversationsScreen hiển thị danh sách hội thoại, tìm kiếm và điểm vào khớp mockup 30-ai-01a',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeAi = FakeAiRepository();
      final session = AppSessionController();
      session.authenticate(
        value: userFixture().copyWith(name: 'Minh Anh'),
        publicConfig: publicConfigFixture(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiRepositoryProvider.overrideWithValue(fakeAi),
            appSessionProvider.overrideWith((ref) => session),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const AiConversationsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tiêu đề & Ghi chú riêng tư
      expect(find.text('Trợ lý'), findsOneWidget);
      expect(
        find.text('Riêng tư · chỉ đọc dữ liệu trong tài khoản của bạn'),
        findsOneWidget,
      );
      expect(find.text('Tìm trong cuộc trò chuyện'), findsOneWidget);

      // Nhóm Đã ghim & Hôm nay
      expect(find.text('Đã ghim'), findsOneWidget);
      expect(find.text('Ghi chi tiêu hằng ngày'), findsOneWidget);
      expect(find.text('Hôm nay'), findsOneWidget);
      expect(find.text('Ngân sách còn lại'), findsOneWidget);

      // Thử tìm kiếm
      await tester.enterText(
        find.widgetWithText(TextField, 'Tìm trong cuộc trò chuyện'),
        'ngân sách',
      );
      await tester.pumpAndSettle();

      expect(find.text('Ngân sách còn lại'), findsOneWidget);
      expect(find.text('Ghi chi tiêu hằng ngày'), findsNothing);
    },
  );

  testWidgets(
    'ConversationActionSheet cho phép đổi tên, ghim, lưu trữ và xóa hội thoại khớp mockup 30-ai-01c',
    (tester) async {
      final fakeAi = FakeAiRepository();
      final conv = fakeAi.conversations.first;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [aiRepositoryProvider.overrideWithValue(fakeAi)],
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(body: ConversationActionSheet(conversation: conv)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cuộc trò chuyện'), findsOneWidget);
      expect(find.text('Ghi chi tiêu hằng ngày'), findsOneWidget);
      expect(find.text('Bỏ ghim'), findsOneWidget); // vì pinned = true
      expect(find.text('Lưu trữ'), findsOneWidget);
      expect(find.text('Xóa cuộc trò chuyện'), findsOneWidget);

      // Thay đổi tên và bấm Lưu tên
      await tester.enterText(find.byType(TextField).first, 'Chi tiêu tháng 9');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lưu tên'));
      await tester.pumpAndSettle();

      expect(fakeAi.updatedTitle, 'Chi tiêu tháng 9');
    },
  );

  testWidgets(
    'AiChatScreen hiển thị tin nhắn, draft card, xác nhận và hoàn tác khớp mockup 30-ai-04 & 30-ai-06',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeAi = FakeAiRepository();
      final fakeTx = FakeTxRepository();
      final session = AppSessionController();
      session.authenticate(
        value: userFixture().copyWith(name: 'Minh Anh'),
        publicConfig: publicConfigFixture(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiRepositoryProvider.overrideWithValue(fakeAi),
            transactionRepositoryProvider.overrideWithValue(fakeTx),
            appSessionProvider.overrideWith((ref) => session),
          ],
          child: const MaterialApp(home: AiChatScreen(conversationId: 'c-1')),
        ),
      );
      await tester.pumpAndSettle();

      // Hiển thị tin user và draft
      expect(
        find.text('hôm qua sáng cà phê 45k, trưa cơm 55k, tối xăng 80k'),
        findsOneWidget,
      );
      expect(find.text('Nháp · chưa lưu'), findsOneWidget);
      expect(find.text('-180.000đ'), findsOneWidget);
      expect(find.text('Cà phê sáng'), findsOneWidget);
      expect(find.text('Cơm trưa'), findsOneWidget);
      expect(find.text('Đổ xăng'), findsOneWidget);

      // Bấm Xác nhận cả 3
      await tester.tap(find.text('Xác nhận cả 3'));
      await tester.pumpAndSettle();

      expect(fakeAi.confirmedDraftId, 'd-1');
      // Banner Hoàn tác xuất hiện
      expect(find.text('Hoàn tác'), findsOneWidget);

      // Bấm Hoàn tác
      await tester.tap(find.text('Hoàn tác'));
      await tester.pumpAndSettle();

      expect(fakeTx.deletedIds, containsAll(['tx-1', 'tx-2', 'tx-3']));
    },
  );

  testWidgets(
    'AiSettingsScreen hiển thị hạn mức hôm nay, điều đã học và toggle góp ví dụ khớp mockup 30-ai-14',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeAi = FakeAiRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [aiRepositoryProvider.overrideWithValue(fakeAi)],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const AiSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Trợ lý AI'), findsOneWidget);
      expect(find.text('Lượt hỏi hôm nay'), findsOneWidget);
      expect(find.text('20 / 30'), findsOneWidget);

      // Điều đã học
      expect(find.text('Trợ lý đã học về bạn'), findsOneWidget);
      expect(find.text('“cà phê” → Ăn uống · MoMo'), findsOneWidget);
      expect(find.text('“xăng” → Di chuyển · Tiền mặt'), findsOneWidget);

      // Bấm xóa mục nhớ đầu tiên
      final closeIcons = find.byIcon(LucideIcons.x);
      await tester.tap(closeIcons.first);
      await tester.pumpAndSettle();

      expect(fakeAi.deletedMemoryId, 'mem-1');

      // Toggle Góp ví dụ ẩn danh
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(fakeAi.settings.shareExamples, isTrue);
    },
  );

  testWidgets(
    'AiChatScreen hiển thị empty state cuộc mới với hero chào và gợi ý khớp mockup 30-ai-02',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fakeAi = FakeAiRepository();
      final session = AppSessionController();
      session.authenticate(
        value: userFixture().copyWith(name: 'Minh Anh'),
        publicConfig: publicConfigFixture(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiRepositoryProvider.overrideWithValue(fakeAi),
            appSessionProvider.overrideWith((ref) => session),
          ],
          child: const MaterialApp(home: AiChatScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Chào Minh Anh'), findsOneWidget);
      expect(find.text('Gợi ý từ dữ liệu của bạn'), findsOneWidget);
      expect(find.text('Tháng này tôi chi bao nhiêu?'), findsOneWidget);
      expect(find.text('Ăn uống còn bao nhiêu ngân sách?'), findsOneWidget);
      expect(find.text('Mua sắm vượt bao nhiêu rồi?'), findsOneWidget);
      expect(find.text('Bao giờ đủ tiền đi Đà Lạt?'), findsOneWidget);
      expect(find.text('✏️ Ghi: cà phê 45k'), findsOneWidget);
    },
  );
}
