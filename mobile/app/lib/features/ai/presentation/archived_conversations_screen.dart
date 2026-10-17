import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../application/ai_service.dart';
import 'conversation_action_sheet.dart';

class ArchivedConversationsScreen extends ConsumerWidget {
  const ArchivedConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final archivedAsync = ref.watch(aiConversationsProvider(true));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevron_left, size: 22),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Cuộc trò chuyện đã lưu trữ',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111111),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: archivedAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (err, _) => Center(child: Text('Lỗi tải danh sách: $err')),
          data: (page) {
            if (page.items.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.archive,
                      size: 40,
                      color: Color(0xFFA9A8A3),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Không có cuộc trò chuyện đã lưu trữ',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF787774),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: page.items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final item = page.items[i];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEAEAEA)),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF1F0EC),
                      child: Icon(
                        LucideIcons.archive,
                        size: 18,
                        color: Color(0xFF787774),
                      ),
                    ),
                    title: Text(
                      item.title ?? 'Cuộc trò chuyện',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Lưu trữ lúc ${DateFormat('dd/MM/yyyy').format(item.updatedAt)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: const Icon(LucideIcons.ellipsis, size: 18),
                    onTap: () {
                      ConversationActionSheet.show(context, conversation: item);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
