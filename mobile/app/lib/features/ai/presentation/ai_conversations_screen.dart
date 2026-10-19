import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth/application/app_session.dart';
import '../application/ai_service.dart';
import '../data/ai_models.dart';
import 'conversation_action_sheet.dart';
import '../../../core/formatting/vietnam_time.dart';

class AiConversationsScreen extends ConsumerStatefulWidget {
  const AiConversationsScreen({super.key});

  @override
  ConsumerState<AiConversationsScreen> createState() =>
      _AiConversationsScreenState();
}

class _AiConversationsScreenState extends ConsumerState<AiConversationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _handleSend([String? prompt]) {
    final text = prompt ?? _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    context.push('/ai/new', extra: text);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isPast7Days(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    return diff > 0 && diff <= 7;
  }

  String _formatTime(DateTime date) {
    if (_isToday(date)) {
      return DateFormat('HH:mm').format(VietnamTime.fromDateTime(date));
    }
    final diff = DateTime.now().difference(date).inDays;
    if (diff == 1) return 'Hôm qua';
    if (diff <= 7) {
      const weekdays = [
        '',
        'Thứ Hai',
        'Thứ Ba',
        'Thứ Tư',
        'Thứ Năm',
        'Thứ Sáu',
        'Thứ Bảy',
        'Chủ Nhật',
      ];
      return weekdays[date.weekday];
    }
    return DateFormat('dd/MM').format(VietnamTime.fromDateTime(date));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAiEnabled =
        ref.watch(appSessionProvider).config?.ai.enabled ?? true;

    if (!isAiEnabled) {
      return _buildDisabledState(context);
    }

    final conversationsAsync = ref.watch(aiConversationsProvider(false));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(999),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(LucideIcons.chevron_left, size: 20),
                          SizedBox(width: 2),
                          Text(
                            'Trang chủ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.push('/ai/new'),
                    icon: const Icon(LucideIcons.square_pen, size: 22),
                    tooltip: 'Cuộc trò chuyện mới',
                  ),
                ],
              ),
            ),

            // Header: Trợ lý & Privacy note
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trợ lý',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.lock,
                        size: 14,
                        color: Color(0xFF787774),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Riêng tư · chỉ đọc dữ liệu trong tài khoản của bạn',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF787774),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Search box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (v) =>
                    setState(() => _searchQuery = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFFBFBF9),
                  hintText: 'Tìm trong cuộc trò chuyện',
                  hintStyle: const TextStyle(
                    color: Color(0xFFA9A8A3),
                    fontSize: 15,
                  ),
                  prefixIcon: const Icon(
                    LucideIcons.search,
                    size: 18,
                    color: Color(0xFF787774),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFEAEAEA)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFEAEAEA)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Content List or Empty State
            Expanded(
              child: conversationsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (err, _) =>
                    Center(child: Text('Lỗi tải cuộc trò chuyện: $err')),
                data: (page) {
                  final allItems = page.items.where((c) {
                    if (_searchQuery.isEmpty) return true;
                    return (c.title ?? '').toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (allItems.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  final pinned = allItems.where((c) => c.pinned).toList();
                  final unpinned = allItems.where((c) => !c.pinned).toList();
                  final today = unpinned
                      .where((c) => _isToday(c.updatedAt))
                      .toList();
                  final past7 = unpinned
                      .where((c) => _isPast7Days(c.updatedAt))
                      .toList();
                  final older = unpinned
                      .where(
                        (c) =>
                            !_isToday(c.updatedAt) &&
                            !_isPast7Days(c.updatedAt),
                      )
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      if (pinned.isNotEmpty) ...[
                        _buildSectionLabel('Đã ghim'),
                        _buildGroup(pinned),
                      ],
                      if (today.isNotEmpty) ...[
                        _buildSectionLabel('Hôm nay'),
                        _buildGroup(today),
                      ],
                      if (past7.isNotEmpty) ...[
                        _buildSectionLabel('7 ngày qua'),
                        _buildGroup(past7),
                      ],
                      if (older.isNotEmpty) ...[
                        _buildSectionLabel('Trước đó'),
                        _buildGroup(older),
                      ],
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),

            // Bottom prompt input bar (matching 30-ai-01a)
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF787774),
        ),
      ),
    );
  }

  Widget _buildGroup(List<AiConversationItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              const Divider(height: 1, indent: 64, color: Color(0xFFF0EFEC)),
            _buildConversationRow(items[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildConversationRow(AiConversationItem item) {
    return InkWell(
      onTap: () => context.push('/ai/conversations/${item.id}'),
      onLongPress: () =>
          ConversationActionSheet.show(context, conversation: item),
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F2EE),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                LucideIcons.message_square,
                size: 18,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? 'Cuộc trò chuyện mới',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.messageCount > 0
                        ? '${item.messageCount} tin nhắn'
                        : 'Chưa có tin nhắn',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF787774),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatTime(item.updatedAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFA9A8A3),
                  ),
                ),
                if (item.pinned) ...[
                  const SizedBox(height: 4),
                  const Icon(
                    LucideIcons.pin,
                    size: 14,
                    color: Color(0xFF787774),
                  ),
                ],
              ],
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(
                LucideIcons.ellipsis,
                size: 18,
                color: Color(0xFFA9A8A3),
              ),
              onPressed: () =>
                  ConversationActionSheet.show(context, conversation: item),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          // Graphic container
          Container(
            width: 120,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F0EC),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 80,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F0EC),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(LucideIcons.sparkles, size: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E5E5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chưa có cuộc trò chuyện nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hỏi về chi tiêu của bạn hoặc ghi giao dịch bằng một câu. Trợ lý chỉ đọc dữ liệu trong tài khoản này.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF787774),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Suggestion chips
          _buildSuggestionChip(
            icon: LucideIcons.chart_no_axes_column,
            text: 'Tháng này tôi chi bao nhiêu?',
            onTap: () => _handleSend('Tháng này tôi chi bao nhiêu?'),
          ),
          const SizedBox(height: 10),
          _buildSuggestionChip(
            icon: LucideIcons.pencil,
            text: 'Ghi: cà phê 45k',
            onTap: () => _handleSend('cà phê 45k'),
          ),
          const SizedBox(height: 10),
          _buildSuggestionChip(
            icon: LucideIcons.target,
            text: 'Ngân sách còn bao nhiêu?',
            onTap: () => _handleSend('Ngân sách còn bao nhiêu?'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFFEAEAEA)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF787774)),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111111),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEAEAEA))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F7F4),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _inputController,
                onSubmitted: (v) => _handleSend(),
                decoration: const InputDecoration(
                  hintText: 'Hỏi hoặc ghi: “cà phê 45k”',
                  hintStyle: TextStyle(
                    color: Color(0xFFA9A8A3),
                    fontSize: 14.5,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => _handleSend(),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE8E7E3),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                LucideIcons.arrow_up,
                size: 20,
                color: Color(0xFF111111),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledState(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: () => context.pop(),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.chevron_left, size: 20),
                      Text('Trang chủ', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F0EC),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.sparkles,
                  size: 32,
                  color: Color(0xFF787774),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Trợ lý đang tắt',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Quản trị viên đã tắt trợ lý trên Thu Chi. Ghi giao dịch, báo cáo và ngân sách vẫn dùng bình thường.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF787774),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBFBF9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFEAEAEA)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      LucideIcons.archive,
                      size: 18,
                      color: Color(0xFF787774),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Cuộc trò chuyện cũ vẫn được giữ. Bạn xóa được trong Cài đặt > Trợ lý AI.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF787774),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: () => context.push('/transactions/new'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF111111),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text(
                  'Ghi giao dịch',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
