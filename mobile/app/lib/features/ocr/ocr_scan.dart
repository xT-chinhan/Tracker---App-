import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/formatting/money_formatter.dart';
import '../../core/formatting/vietnam_time.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/widgets/dashed_box.dart';
import '../ai/data/ai_models.dart';
import '../ai/data/ai_repository.dart';
import '../auth/application/app_session.dart';
import '../categories/presentation/category_picker_sheet.dart';
import '../home/application/home_service.dart';
import '../transactions/presentation/transaction_entry_screen.dart';
import '../wallets/presentation/wallet_picker_sheet.dart';

/// Nháp đọc từ ảnh chuyển sang màn Ghi giao dịch ("Sửa"). [draftId] rỗng = nhập tay, chỉ điền sẵn.
class OcrDraftEdit {
  const OcrDraftEdit({required this.draftId, required this.item});
  final String draftId;
  final Map<String, dynamic> item;
}

const _ink = Color(0xFF111111);
const _chipBg = Color(0xFFF3F2EE);
const _line = Color(0xFFECEBE7);

/// Cuộc trò chuyện dùng để gửi ảnh (tạo 1 lần mỗi phiên, tạo lại nếu bị xóa).
String? _ocrConversationId;

Future<String> _conversationId(AiRepository repo, {bool fresh = false}) async {
  if (_ocrConversationId != null && !fresh) return _ocrConversationId!;
  final created = await repo.createConversation(title: 'Quét hóa đơn');
  return _ocrConversationId = created.id;
}

ApiException _apiError(Object e) {
  if (e is ApiException) return e;
  if (e is DioException) {
    return e.error is ApiException ? e.error! as ApiException : ApiException.fromDio(e);
  }
  return ApiException(statusCode: null, message: 'Có lỗi xảy ra. Vui lòng thử lại.', cause: e);
}

/// Lối vào chung (menu ＋, nút camera ở Ghi giao dịch, "Chụp lại"): sheet chọn nguồn ảnh → màn đọc.
/// [replace] = thay màn hiện tại (đang ở Ghi giao dịch hoặc màn Quét).
Future<void> startOcrScan(BuildContext context, {bool replace = false}) async {
  final source = await OcrScanSheet.show(context);
  if (source == null || !context.mounted) return;
  if (source == OcrChoice.manual) {
    final route = MaterialPageRoute<bool>(builder: (_) => const TransactionEntryScreen());
    replace ? Navigator.of(context).pushReplacement(route) : Navigator.of(context).push(route);
    return;
  }
  final container = ProviderScope.containerOf(context, listen: false);
  final maxSide = (container.read(appSessionProvider).config?.ai.ocr.maxSide ?? 768).toDouble();
  final XFile? file;
  try {
    file = await ImagePicker().pickImage(
      source: source == OcrChoice.camera ? ImageSource.camera : ImageSource.gallery,
      // thu nhỏ trên máy trước khi gửi (máy chủ cũng thu nhỏ lần nữa theo cùng cấu hình)
      maxWidth: maxSide,
      maxHeight: maxSide,
      imageQuality: 85,
    );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được máy ảnh / thư viện. Kiểm tra quyền truy cập ảnh của app.')),
      );
    }
    return;
  }
  if (file == null || !context.mounted) return;
  final bytes = await file.readAsBytes();
  if (!context.mounted) return;
  final route = MaterialPageRoute<void>(builder: (_) => OcrScanScreen(bytes: bytes, filename: file!.name));
  replace ? Navigator.of(context).pushReplacement(route) : Navigator.of(context).push(route);
}

enum OcrChoice { camera, gallery, manual }

/* ============================== Sheet chọn ảnh / hết lượt ============================== */

class OcrScanSheet extends ConsumerStatefulWidget {
  const OcrScanSheet({super.key});

  static Future<OcrChoice?> show(BuildContext context) {
    return showModalBottomSheet<OcrChoice>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const OcrScanSheet(),
    );
  }

  @override
  ConsumerState<OcrScanSheet> createState() => _OcrScanSheetState();
}

class _OcrScanSheetState extends ConsumerState<OcrScanSheet> {
  AiUsage? _usage;

  @override
  void initState() {
    super.initState();
    ref.read(aiRepositoryProvider).getUsage().then((u) {
      if (mounted) setState(() => _usage = u);
    }).catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final u = _usage;
    final limit = u?.ocrDailyLimit ?? ref.watch(appSessionProvider).config?.ai.ocr.dailyLimitPerUser ?? 20;
    final used = u?.ocrToday ?? 0;
    final out = u != null && used >= limit;
    final muted = colors.onSurfaceVariant;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFDAD9D4), borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: Text('Quét hóa đơn', style: text.titleLarge)),
              IconButton(tooltip: 'Đóng', onPressed: () => Navigator.of(context).pop(), icon: const Icon(LucideIcons.x)),
            ],
          ),
          if (!out) ...[
            const SizedBox(height: 4),
            Text(
              'Hóa đơn giấy hoặc ảnh chụp màn hình chuyển khoản. Thu Chi đọc số tiền, ngày, nơi bán rồi tạo nháp để bạn xem lại.',
              style: text.bodyLarge?.copyWith(color: muted, fontWeight: FontWeight.w400),
            ),
          ] else ...[
            const SizedBox(height: 12),
            _LimitCard(limit: limit, resetAt: u.resetAt, onManual: () => Navigator.of(context).pop(OcrChoice.manual)),
          ],
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE6E5E0)), borderRadius: BorderRadius.circular(18)),
            child: Column(
              children: [
                _SourceRow(
                  icon: LucideIcons.camera,
                  title: 'Chụp ảnh',
                  enabled: !out,
                  onTap: () => Navigator.of(context).pop(OcrChoice.camera),
                ),
                const Divider(height: 1, indent: 76, endIndent: 16, color: _line),
                _SourceRow(
                  icon: LucideIcons.images,
                  title: 'Chọn từ thư viện',
                  subtitle: out ? null : 'Kể cả ảnh chụp màn hình',
                  enabled: !out,
                  onTap: () => Navigator.of(context).pop(OcrChoice.gallery),
                ),
              ],
            ),
          ),
          if (!out) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: _chipBg, borderRadius: BorderRadius.circular(14)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.lightbulb, size: 18, color: muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: text.bodyMedium?.copyWith(color: const Color(0xFF55544F)),
                        children: const [
                          TextSpan(text: 'Chụp thẳng, đủ sáng, thấy rõ dòng '),
                          TextSpan(text: 'Tổng tiền', style: TextStyle(fontWeight: FontWeight.w700, color: _ink)),
                          TextSpan(text: ' hoặc số tiền chuyển. Mỗi ảnh một hóa đơn.'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _FootNote(icon: LucideIcons.lock, text: 'Ảnh chỉ dùng để đọc rồi xóa ngay, không lưu trên máy chủ.'),
          ],
          const SizedBox(height: 8),
          if (u != null)
            _FootNote(
              icon: LucideIcons.hourglass,
              text: out ? 'Đã dùng $limit/$limit ảnh hôm nay' : 'Còn ${limit - used}/$limit ảnh hôm nay',
            ),
        ],
      ),
    );
  }
}

class _LimitCard extends StatelessWidget {
  const _LimitCard({required this.limit, required this.resetAt, required this.onManual});
  final int limit;
  final DateTime? resetAt;
  final VoidCallback onManual;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final left = resetAt?.difference(DateTime.now());
    final wait = left == null || left.isNegative
        ? ''
        : ', còn ${left.inHours > 0 ? '${left.inHours} giờ ' : ''}${left.inMinutes % 60} phút';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE6E5E0)), borderRadius: BorderRadius.circular(18)),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _IconDot(icon: LucideIcons.hourglass, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hết $limit ảnh hôm nay', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      'Lượt mới mở lúc 00:00$wait. Nháp đang chờ vẫn lưu được.',
                      style: text.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          AppButton(label: 'Ghi giao dịch thủ công', icon: LucideIcons.plus, style: AppButtonStyle.secondary, onPressed: onManual),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({required this.icon, required this.title, this.subtitle, required this.enabled, required this.onTap});
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final faint = context.appColors.faint;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            _IconDot(icon: icon, color: enabled ? _ink : faint),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: text.titleMedium?.copyWith(fontWeight: FontWeight.w500, color: enabled ? _ink : faint)),
                  if (subtitle != null) Text(subtitle!, style: text.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (enabled) Icon(LucideIcons.chevron_right, size: 20, color: faint),
          ],
        ),
      ),
    );
  }
}

class _IconDot extends StatelessWidget {
  const _IconDot({required this.icon, this.color = _ink, this.size = 40});
  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: _chipBg),
      alignment: Alignment.center,
      child: Icon(icon, size: size * 0.45, color: color),
    );
  }
}

class _FootNote extends StatelessWidget {
  const _FootNote({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final faint = context.appColors.faint;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, size: 16, color: faint)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF8A8984)))),
        ],
      ),
    );
  }
}

/* ============================== Màn đọc ảnh ============================== */

enum _Phase { reading, result, unreadable, limit, error }

class OcrScanScreen extends ConsumerStatefulWidget {
  const OcrScanScreen({required this.bytes, required this.filename, super.key});
  final Uint8List bytes;
  final String filename;

  @override
  ConsumerState<OcrScanScreen> createState() => _OcrScanScreenState();
}

class _OcrScanScreenState extends ConsumerState<OcrScanScreen> {
  final _cancel = CancelToken();
  _Phase _phase = _Phase.reading;
  String? _draftId;
  Map<String, dynamic> _item = {};
  Map<String, dynamic> _ocr = {};
  bool _edited = false;
  bool _saving = false;
  String? _error;
  DateTime? _resetAt;

  @override
  void initState() {
    super.initState();
    _read();
  }

  @override
  void dispose() {
    _cancel.cancel();
    super.dispose();
  }

  Future<void> _read() async {
    final repo = ref.read(aiRepositoryProvider);
    try {
      Map<String, dynamic> res;
      try {
        res = await repo.postImage(await _conversationId(repo), widget.bytes, widget.filename);
      } catch (e) {
        // cuộc trò chuyện đã bị xóa / đổi tài khoản → tạo mới rồi gửi lại
        if (_apiError(e).statusCode != 404) rethrow;
        res = await repo.postImage(await _conversationId(repo, fresh: true), widget.bytes, widget.filename);
      }
      if (!mounted) return;
      final draft = res['draft'] as Map<String, dynamic>?;
      final items = (draft?['payload'] as Map<String, dynamic>?)?['items'] as List?;
      setState(() {
        _ocr = Map<String, dynamic>.from((res['ocr'] as Map?) ?? const {});
        if (draft != null && items != null && items.isNotEmpty) {
          _draftId = draft['id'] as String;
          _item = Map<String, dynamic>.from(items.first as Map);
          _phase = _Phase.result;
        } else {
          _phase = _Phase.unreadable;
        }
      });
    } catch (e) {
      if (!mounted) return;
      final err = _apiError(e);
      setState(() {
        if (err.statusCode == 429 && err.code == 'AI_OCR_DAILY_LIMIT') {
          _phase = _Phase.limit;
          _resetAt = err.retryAfter != null ? DateTime.now().add(err.retryAfter!) : null;
        } else {
          _phase = _Phase.error;
        }
        _error = err.message;
      });
    }
  }

  bool get _income => _item['type'] == 'INCOME';
  bool get _transfer => _ocr['kind'] == 'transfer';
  bool get _walletMissing => _item['walletId'] == null || _item['walletGuessed'] == true;
  bool get _categoryMissing => _item['categoryId'] == null;

  Future<void> _cancelDraft() async {
    if (_draftId != null) {
      try {
        await ref.read(aiRepositoryProvider).cancelDraft(_draftId!);
      } catch (_) {}
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(aiRepositoryProvider).confirmDraft(
        _draftId!,
        payload: _edited ? {'items': [_item]} : null,
      );
      ref.read(homeControllerProvider.notifier).load(refresh: true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_income ? 'Đã ghi khoản thu ${MoneyFormatter.format(_amount)}' : 'Đã ghi khoản chi ${MoneyFormatter.format(_amount)}')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_apiError(e).message)));
    }
  }

  Future<void> _openEntry() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => TransactionEntryScreen(ocrDraft: OcrDraftEdit(draftId: _draftId!, item: _item))),
    );
    if (saved == true && mounted) Navigator.of(context).pop();
  }

  void _manual() {
    final item = {
      'title': _str(_ocr['merchant']).isNotEmpty ? _ocr['merchant'] : _str(_ocr['recipient']),
      'amount': 0,
      'type': 'EXPENSE',
      'date': _ocr['date'],
    };
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<bool>(builder: (_) => TransactionEntryScreen(ocrDraft: OcrDraftEdit(draftId: '', item: item))),
    );
  }

  Future<void> _pickCategory() async {
    final c = await CategoryPickerSheet.show(
      context,
      initialType: _income ? TransactionType.income : TransactionType.expense,
      selectedCategoryId: _item['categoryId'] as String?,
    );
    if (c != null) setState(() => (_edited = true, _item = {..._item, 'categoryId': c.id, 'categoryName': c.name}));
  }

  Future<void> _pickWallet() async {
    final w = await WalletPickerSheet.show(context, selectedWalletId: _walletMissing ? null : _item['walletId'] as String?);
    if (w != null) setState(() => (_edited = true, _item = {..._item, 'walletId': w.id, 'walletName': w.name, 'walletGuessed': false}));
  }

  Future<void> _pickDate() async {
    final now = VietnamTime.now();
    final cur = DateTime.tryParse('${_item['date'] ?? ''}') ?? now;
    final d = await showDatePicker(context: context, initialDate: cur, firstDate: DateTime(now.year - 5), lastDate: DateTime(now.year, now.month, now.day));
    if (d != null) setState(() => (_edited = true, _item = {..._item, 'date': _ymd(d)}));
  }

  int get _amount => (_item['amount'] as num?)?.toInt() ?? 0;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 136,
        leading: TextButton.icon(
          onPressed: _phase == _Phase.result ? _cancelDraft : () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(padding: const EdgeInsets.only(left: 8)),
          icon: const Icon(LucideIcons.chevron_left, color: _ink),
          label: Text('Trang chủ', maxLines: 1, softWrap: false, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: _ink)),
        ),
        centerTitle: true,
        title: Column(
          children: [
            const Text('Quét hóa đơn'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.lock, size: 12, color: context.appColors.faint),
                const SizedBox(width: 4),
                Text('Ảnh không lưu trên máy chủ', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: context.appColors.faint)),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: switch (_phase) {
          _Phase.reading => _reading(muted),
          _Phase.result => _result(muted),
          _Phase.unreadable => _unreadable(muted),
          _Phase.limit => _message(
              LucideIcons.hourglass,
              'Hết lượt đọc ảnh hôm nay',
              '${_error ?? ''}${_resetAt != null ? ' Lượt mới mở lúc 00:00.' : ''} Nháp đang chờ vẫn lưu được.',
              muted,
            ),
          _Phase.error => _message(LucideIcons.circle_alert, 'Chưa đọc được ảnh', _error ?? 'Có lỗi xảy ra. Vui lòng thử lại.', muted),
        },
      ),
    );
  }

  Widget _thumb({double w = 64, double h = 82}) => GestureDetector(
        onTap: _showImage,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: w,
            height: h,
            color: const Color(0xFFE9E8E3),
            child: Image.memory(widget.bytes, fit: BoxFit.cover),
          ),
        ),
      );

  void _showImage() {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        child: InteractiveViewer(child: Image.memory(widget.bytes)),
      ),
    );
  }

  Widget _reading(Color muted) {
    Widget bar(double w, double h) => AppSkeleton(width: w, height: h, borderRadius: BorderRadius.circular(h / 2));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              _thumb(),
              const SizedBox(width: 16),
              Icon(LucideIcons.scan_line, size: 20, color: muted),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Đang đọc ảnh…', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: muted)),
                    Text('Thường mất vài giây', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.appColors.faint)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: DashedBox(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [bar(130, 26), const Spacer(), bar(84, 26)]),
                  const SizedBox(height: 18),
                  bar(96, 12),
                  const SizedBox(height: 10),
                  bar(190, 34),
                  const SizedBox(height: 10),
                  bar(150, 12),
                  for (var i = 0; i < 4; i++) ...[
                    const SizedBox(height: 26),
                    Row(children: [AppSkeleton(width: 22, height: 22, shape: BoxShape.circle), const SizedBox(width: 14), bar(70 + i * 12, 12), const Spacer(), bar(90, 12)]),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppButton(label: 'Hủy', style: AppButtonStyle.secondary, onPressed: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }

  Widget _result(Color muted) {
    final text = Theme.of(context).textTheme;
    final appColors = context.appColors;
    final counterpart = _income ? _str(_ocr['sender']) : (_transfer ? _str(_ocr['recipient']) : _str(_ocr['merchant']));
    final heading = _income
        ? 'Nhận từ ${counterpart.isNotEmpty ? counterpart : 'chuyển khoản'}'
        : _transfer
            ? 'Chuyển tới ${counterpart.isNotEmpty ? counterpart : '…'}'
            : (counterpart.isNotEmpty ? counterpart : (_item['title'] as String? ?? ''));
    final bank = _str(_ocr['bank']);
    final sub = _transfer ? [if (bank.isNotEmpty) '${_income ? 'Vào' : 'Từ'} $bank'].join() : MoneyFormatter.inWords(_amount);
    final canSave = !_walletMissing && !_categoryMissing && !_saving;
    final note = _str(_ocr['note']);
    final hint = _income
        ? 'Bạn là người nhận nên đây là khoản thu.'
        : _transfer
            ? 'Bạn là người chuyển nên đây là khoản chi.'
            : 'Danh mục và ví đoán theo thói quen của bạn. Chạm một dòng để sửa.';
    final missing = [
      if (_walletMissing) bank.isNotEmpty ? '$bank chưa khớp ví nào của bạn. Chọn ví' : 'Chọn ví',
      if (_categoryMissing) 'chọn danh mục',
    ];
    final ms = (_ocr['ms'] as num?)?.toDouble();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        Text(
          '${_transfer ? 'Đọc xong ảnh chuyển khoản' : 'Đọc xong hóa đơn'}. Chưa có gì được lưu.',
          style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 14),
        DashedBox(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: _chipBg, borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(LucideIcons.circle_dashed, size: 14, color: muted),
                      const SizedBox(width: 6),
                      Text('Nháp · chưa lưu', style: text.labelMedium?.copyWith(color: muted, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE0DFDA)), borderRadius: BorderRadius.circular(20)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(_income ? LucideIcons.arrow_down_left : LucideIcons.arrow_up_right, size: 14, color: _income ? appColors.income : _ink),
                      const SizedBox(width: 6),
                      Text(_income ? 'Khoản thu' : 'Khoản chi', style: text.labelMedium?.copyWith(color: _income ? appColors.income : _ink, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(heading, style: text.bodyLarge?.copyWith(color: muted), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            MoneyFormatter.format(_income ? _amount : -_amount, signed: true),
                            style: text.displaySmall?.copyWith(fontSize: 38, color: _income ? appColors.income : _ink, fontFeatures: MoneyFormatter.tabularFeatures),
                          ),
                        ),
                        if (sub.isNotEmpty) Text(sub, style: text.bodyMedium?.copyWith(color: muted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _thumb(w: 64, h: 84),
                ],
              ),
              const SizedBox(height: 8),
              if (_transfer)
                _Row(icon: LucideIcons.user, label: _income ? 'Người chuyển' : 'Người nhận', value: counterpart.isNotEmpty ? counterpart : '—', onTap: _openEntry)
              else
                _Row(icon: LucideIcons.store, label: 'Nơi bán', value: counterpart.isNotEmpty ? counterpart : '—', onTap: _openEntry),
              if (_transfer && note.isNotEmpty) _Row(icon: LucideIcons.notebook_pen, label: 'Nội dung', value: note, onTap: _openEntry),
              _Row(
                icon: LucideIcons.shapes,
                label: 'Danh mục',
                value: _categoryMissing ? 'Chọn danh mục' : (_item['categoryName'] as String? ?? ''),
                placeholder: _categoryMissing,
                onTap: _pickCategory,
              ),
              _Row(
                icon: LucideIcons.wallet,
                label: 'Ví',
                value: _walletMissing ? 'Chọn ví' : (_item['walletName'] as String? ?? ''),
                warn: _walletMissing,
                onTap: _pickWallet,
              ),
              _Row(icon: LucideIcons.calendar, label: 'Ngày', value: _dateLabel('${_item['date'] ?? ''}'), onTap: _pickDate, last: true),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(padding: const EdgeInsets.only(top: 2), child: Icon(LucideIcons.info, size: 16, color: appColors.faint)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      [hint, if (missing.isNotEmpty) '${missing.join(' và ')} trước khi lưu.'].join(' '),
                      style: text.bodyMedium?.copyWith(color: appColors.faint),
                    ),
                  ),
                ],
              ),
              const Divider(height: 26, color: _line),
              Row(
                children: [
                  Icon(LucideIcons.scan_line, size: 16, color: muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đọc từ ảnh${ms != null ? ' · ${(ms / 1000).toStringAsFixed(1).replaceAll('.', ',')} giây' : ''}',
                      style: text.bodyMedium?.copyWith(color: muted),
                    ),
                  ),
                  InkWell(
                    onTap: _showImage,
                    child: Row(children: [
                      Text('Xem ảnh', style: text.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: _ink)),
                      const Icon(LucideIcons.chevron_right, size: 16, color: _ink),
                    ]),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  TextButton(
                    onPressed: _saving ? null : _cancelDraft,
                    child: Text('Hủy', style: text.labelLarge?.copyWith(color: muted)),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton(
                    onPressed: _saving ? null : _openEntry,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      shape: const StadiumBorder(),
                      side: const BorderSide(color: Color(0xFFE0DFDA)),
                    ),
                    child: Text('Sửa', style: text.labelLarge?.copyWith(color: _ink)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppButton(
                      label: _income ? 'Lưu khoản thu' : 'Lưu khoản chi',
                      loading: _saving,
                      onPressed: canSave ? _save : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _unreadable(Color muted) {
    final text = Theme.of(context).textTheme;
    final noDoc = _ocr['reason'] == 'not_document' || _ocr['reason'] == 'error';
    final merchant = _str(_ocr['merchant']).isNotEmpty ? _str(_ocr['merchant']) : _str(_ocr['recipient']);
    final date = _str(_ocr['date']);
    final hasPartial = !noDoc && (merchant.isNotEmpty || date.isNotEmpty);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _thumb(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(noDoc ? 'Chưa nhận ra hóa đơn' : 'Chưa đọc được số tiền', style: text.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      noDoc
                          ? 'Ảnh không giống hóa đơn hay màn hình chuyển khoản, hoặc quá mờ. Không có gì được lưu.'
                          : 'Ảnh hơi mờ nên chưa đọc được dòng tổng tiền. Không có gì được lưu.',
                      style: text.bodyMedium?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (hasPartial)
            Container(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE6E5E0))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Đọc được trong ảnh', style: text.bodyMedium?.copyWith(color: muted)),
                  if (merchant.isNotEmpty) _Row(icon: LucideIcons.store, label: 'Nơi bán', value: merchant, dense: true),
                  if (date.isNotEmpty) _Row(icon: LucideIcons.calendar, label: 'Ngày', value: _dateLabel(date), dense: true),
                  const _Row(icon: LucideIcons.banknote, label: 'Số tiền', value: 'Chưa đọc được', placeholder: true, dense: true, last: true),
                ],
              ),
            ),
          if (hasPartial) const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _chipBg, borderRadius: BorderRadius.circular(16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(LucideIcons.lightbulb, size: 18, color: muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Đặt hóa đơn trên mặt phẳng, chụp thẳng, đủ sáng và thấy rõ dòng Tổng tiền. Ảnh chụp màn hình chuyển khoản thường đọc tốt hơn ảnh chụp giấy.',
                    style: text.bodyMedium?.copyWith(color: const Color(0xFF55544F)),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          AppButton(label: 'Chụp lại', icon: LucideIcons.camera, onPressed: () => startOcrScan(context, replace: true)),
          const SizedBox(height: 10),
          AppButton(label: 'Nhập tay', icon: LucideIcons.keyboard, style: AppButtonStyle.secondary, onPressed: _manual),
          const SizedBox(height: 10),
          Text(
            hasPartial ? 'Nhập tay mở Ghi giao dịch, điền sẵn nơi bán và ngày.' : 'Nhập tay mở Ghi giao dịch.',
            textAlign: TextAlign.center,
            style: text.bodySmall?.copyWith(color: context.appColors.faint),
          ),
        ],
      ),
    );
  }

  Widget _message(IconData icon, String title, String body, Color muted) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconDot(icon: icon, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleLarge),
                    const SizedBox(height: 4),
                    Text(body, style: text.bodyMedium?.copyWith(color: muted)),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          if (_phase == _Phase.error) ...[
            AppButton(label: 'Thử lại', icon: LucideIcons.rotate_ccw, onPressed: () {
              setState(() => _phase = _Phase.reading);
              _read();
            }),
            const SizedBox(height: 10),
          ],
          AppButton(label: 'Ghi giao dịch thủ công', icon: LucideIcons.plus, style: AppButtonStyle.secondary, onPressed: _manual),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.placeholder = false,
    this.warn = false,
    this.dense = false,
    this.last = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  final bool placeholder;
  final bool warn;
  final bool dense;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final appColors = context.appColors;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final valueWidget = warn
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: appColors.warningContainer, borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(LucideIcons.triangle_alert, size: 14, color: appColors.warning),
              const SizedBox(width: 6),
              Text(value, style: text.labelMedium?.copyWith(color: appColors.warning, fontWeight: FontWeight.w600)),
            ]),
          )
        : Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: (dense ? text.bodyLarge : text.titleMedium)?.copyWith(
              color: placeholder ? appColors.faint : _ink,
              fontWeight: placeholder ? FontWeight.w400 : FontWeight.w600,
            ),
          );
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: dense ? 10 : 14),
        decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: _line))),
        child: Row(
          children: [
            Icon(icon, size: 20, color: muted),
            const SizedBox(width: 14),
            Text(label, style: (dense ? text.bodyLarge : text.titleMedium)?.copyWith(color: dense ? _ink : muted, fontWeight: FontWeight.w400)),
            const SizedBox(width: 12),
            Expanded(child: Align(alignment: Alignment.centerRight, child: valueWidget)),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(LucideIcons.chevron_right, size: 18, color: appColors.faint),
            ],
          ],
        ),
      ),
    );
  }
}

String _str(Object? v) => v is String ? v.trim() : '';

String _ymd(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

String _dateLabel(String ymd) {
  final d = DateTime.tryParse(ymd);
  if (d == null) return '—';
  final now = VietnamTime.now();
  final dm = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  if (d.year == now.year && d.month == now.month && d.day == now.day) return 'Hôm nay, $dm';
  final y = now.subtract(const Duration(days: 1));
  if (d.year == y.year && d.month == y.month && d.day == y.day) return 'Hôm qua, $dm';
  return d.year == now.year ? dm : '$dm/${d.year}';
}
