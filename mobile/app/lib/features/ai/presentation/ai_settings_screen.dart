import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../application/ai_service.dart';
import '../data/ai_models.dart';
import '../data/ai_repository.dart';

class AiSettingsScreen extends ConsumerStatefulWidget {
  const AiSettingsScreen({super.key});

  @override
  ConsumerState<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends ConsumerState<AiSettingsScreen> {
  bool _showAllMemory = false;

  Future<void> _deleteMemoryItem(String id) async {
    try {
      final repo = ref.read(aiRepositoryProvider);
      await repo.deleteMemory(id);
      ref.invalidate(aiMemoryProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể xóa mục đã học')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final usageAsync = ref.watch(aiUsageProvider);
    final memoryAsync = ref.watch(aiMemoryProvider);
    final settingsAsync = ref.watch(aiSettingsControllerProvider);
    final archivedAsync = ref.watch(aiConversationsProvider(true));

    final archivedCount = archivedAsync.value?.items.length ?? 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Top back button: < Cài đặt
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: () => context.pop(),
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.chevron_left, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Cài đặt',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Page title: Trợ lý AI
            Text(
              'Trợ lý AI',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Card 1: Usage Card
            usageAsync.when(
              loading: () => Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFEAEAEA)),
                ),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (error, stack) => const SizedBox.shrink(),
              data: (usage) {
                final used = usage.messagesToday;
                final limit = usage.dailyMessageLimit;
                final isQuotaReached = used >= limit;
                final ratio = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
                final resetTimeStr = usage.resetAt != null
                    ? DateFormat('HH:mm').format(usage.resetAt!)
                    : '00:00';

                return Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFEAEAEA)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Lượt hỏi hôm nay',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF787774),
                            ),
                          ),
                          Text(
                            'Mở lại lúc $resetTimeStr',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF787774),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$used / $limit',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: Color(0xFF111111),
                            ),
                          ),
                          if (isQuotaReached) ...[
                            const SizedBox(width: 6),
                            const Text(
                              '· hết lượt',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFF1F0EC),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isQuotaReached
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF111111),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Xác nhận nháp và đọc lại cuộc trò chuyện không tính lượt.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF787774),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Section 2: Trợ lý đã học về bạn
            _buildSectionHeader(
              title: 'Trợ lý đã học về bạn',
              trailing: memoryAsync.maybeWhen(
                data: (items) => '${items.length} điều',
                orElse: () => '',
              ),
            ),

            memoryAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (error, stack) => const SizedBox.shrink(),
              data: (memories) {
                if (memories.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFEAEAEA)),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Trợ lý chưa ghi nhận thói quen nào.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF787774)),
                    ),
                  );
                }

                final displayItems = _showAllMemory
                    ? memories
                    : memories.take(3).toList();

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFEAEAEA)),
                  ),
                  child: Column(
                    children: [
                      for (int i = 0; i < displayItems.length; i++) ...[
                        if (i > 0)
                          const Divider(
                            height: 1,
                            indent: 64,
                            color: Color(0xFFF0EFEC),
                          ),
                        _buildMemoryRow(displayItems[i]),
                      ],
                      if (memories.length > 3 && !_showAllMemory) ...[
                        const Divider(height: 1, color: Color(0xFFF0EFEC)),
                        InkWell(
                          onTap: () => setState(() => _showAllMemory = true),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(18),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Xem tất cả',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF111111),
                                  ),
                                ),
                                Spacer(),
                                Icon(
                                  LucideIcons.chevron_right,
                                  size: 16,
                                  color: Color(0xFFA9A8A3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),

            // Section 3: Quyền riêng tư
            _buildSectionHeader(title: 'Quyền riêng tư'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              child: Column(
                children: [
                  // Toggle: Góp ví dụ ẩn danh
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F0EC),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            LucideIcons.user,
                            size: 18,
                            color: Color(0xFF111111),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text(
                            'Góp ví dụ ẩn danh',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111111),
                            ),
                          ),
                        ),
                        Switch(
                          value: settingsAsync.value?.shareExamples ?? false,
                          onChanged: (val) {
                            ref
                                .read(aiSettingsControllerProvider.notifier)
                                .updateShareExamples(val);
                          },
                          activeThumbColor: const Color(0xFF111111),
                        ),
                      ],
                    ),
                  ),
                  const Divider(
                    height: 1,
                    indent: 66,
                    color: Color(0xFFF0EFEC),
                  ),

                  // Cuộc trò chuyện đã lưu trữ
                  InkWell(
                    onTap: () => context.push('/ai/archived'),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1F0EC),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              LucideIcons.archive,
                              size: 18,
                              color: Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Cuộc trò chuyện đã lưu trữ',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ),
                          if (archivedCount > 0) ...[
                            Text(
                              '$archivedCount',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF787774),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          const Icon(
                            LucideIcons.chevron_right,
                            size: 16,
                            color: Color(0xFFA9A8A3),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, String? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8, left: 4, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF787774),
            ),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(fontSize: 13, color: Color(0xFF787774)),
            ),
        ],
      ),
    );
  }

  Widget _buildMemoryRow(AiMemoryItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F0EC),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              LucideIcons.sparkles,
              size: 18,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '“${item.key}” → ${item.value}',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.source ?? 'Từ thói quen của bạn',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF787774),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.x, size: 16, color: Color(0xFFA9A8A3)),
            onPressed: () => _deleteMemoryItem(item.id),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
