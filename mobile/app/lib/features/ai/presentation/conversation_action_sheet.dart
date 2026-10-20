import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/ai_service.dart';
import '../data/ai_models.dart';
import '../data/ai_repository.dart';

class ConversationActionSheet extends ConsumerStatefulWidget {
  const ConversationActionSheet({required this.conversation, super.key});

  final AiConversationItem conversation;

  static Future<void> show(
    BuildContext context, {
    required AiConversationItem conversation,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ConversationActionSheet(conversation: conversation),
    );
  }

  @override
  ConsumerState<ConversationActionSheet> createState() =>
      _ConversationActionSheetState();
}

class _ConversationActionSheetState
    extends ConsumerState<ConversationActionSheet> {
  late final TextEditingController _titleController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.conversation.title ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveTitle() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(aiRepositoryProvider);
      await repo.updateConversation(widget.conversation.id, title: title);
      ref.invalidate(aiConversationsProvider(false));
      ref.invalidate(aiConversationsProvider(true));
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể đổi tên hội thoại')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleTogglePin() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(aiRepositoryProvider);
      await repo.updateConversation(
        widget.conversation.id,
        pinned: !widget.conversation.pinned,
      );
      ref.invalidate(aiConversationsProvider(false));
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Không thể ghim/bỏ ghim')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleToggleArchive() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(aiRepositoryProvider);
      await repo.updateConversation(
        widget.conversation.id,
        archived: !widget.conversation.archived,
      );
      ref.invalidate(aiConversationsProvider(false));
      ref.invalidate(aiConversationsProvider(true));
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lưu trữ/khôi phục')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(aiRepositoryProvider);
      await repo.deleteConversation(widget.conversation.id);
      ref.invalidate(aiConversationsProvider(false));
      ref.invalidate(aiConversationsProvider(true));
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể xóa cuộc trò chuyện')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: bottomInset + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header: Cuộc trò chuyện & Close button
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Cuộc trò chuyện',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(LucideIcons.x, size: 20),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Label: Tên
            Text(
              'Tên',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),

            // Title input
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFFBFBF9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFEAEAEA)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFEAEAEA)),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(
                    LucideIcons.circle_x,
                    size: 18,
                    color: Color(0xFF787774),
                  ),
                  onPressed: () => _titleController.clear(),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tên tự đặt theo câu hỏi đầu tiên. Bạn đổi được bất cứ lúc nào.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF787774),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),

            // Button: Lưu tên
            FilledButton(
              onPressed: _isLoading ? null : _handleSaveTitle,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF111111),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Lưu tên',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // Actions group card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEAEAEA)),
              ),
              child: Column(
                children: [
                  // Pin / Unpin
                  InkWell(
                    onTap: _isLoading ? null : _handleTogglePin,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                            child: Icon(
                              widget.conversation.pinned
                                  ? LucideIcons.pin_off
                                  : LucideIcons.pin,
                              size: 18,
                              color: const Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              widget.conversation.pinned
                                  ? 'Bỏ ghim'
                                  : 'Ghim lên đầu',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    indent: 66,
                    color: Color(0xFFF0EFEC),
                  ),

                  // Archive / Unarchive
                  InkWell(
                    onTap: _isLoading ? null : _handleToggleArchive,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                            child: Icon(
                              widget.conversation.archived
                                  ? LucideIcons.archive_restore
                                  : LucideIcons.archive,
                              size: 18,
                              color: const Color(0xFF111111),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              widget.conversation.archived
                                  ? 'Khôi phục'
                                  : 'Lưu trữ',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111111),
                              ),
                            ),
                          ),
                          Text(
                            widget.conversation.archived
                                ? 'Hiện lại danh sách'
                                : 'Ẩn khỏi danh sách',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF787774),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(
                    height: 1,
                    indent: 66,
                    color: Color(0xFFF0EFEC),
                  ),

                  // Delete
                  InkWell(
                    onTap: _isLoading ? null : _handleDelete,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(18),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFDE8E8),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              LucideIcons.trash,
                              size: 18,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Xóa cuộc trò chuyện',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Xóa thì không khôi phục được. Giao dịch đã ghi từ cuộc trò chuyện này vẫn giữ nguyên.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF787774),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
