import '../../categories/data/category_models.dart';
import '../../wallets/data/wallet_models.dart';
import '../data/parsed_transaction.dart';

/// Một giao dịch phát hiện từ thông báo, chờ người dùng xác nhận (chỉ lưu trên máy).
class PendingBankTransaction {
  const PendingBankTransaction({
    required this.key,
    required this.bank,
    required this.packageName,
    required this.amount,
    required this.type,
    required this.occurredAt,
    required this.title,
    required this.categoryName,
    this.rawText = '',
  });

  /// Khóa chống trùng: gói app + số tiền + phút nhận thông báo.
  final String key;
  final String bank;
  final String packageName;
  final int amount;

  /// `INCOME` | `EXPENSE`
  final String type;
  final DateTime occurredAt;
  final String title;

  /// Danh mục gợi ý theo tên danh mục TrackerX.
  final String categoryName;

  /// Nội dung thông báo gốc, chỉ để hiển thị trên máy, không gửi lên máy chủ.
  final String rawText;

  bool get isIncome => type == 'INCOME';

  Map<String, dynamic> toJson() => {
    'key': key,
    'bank': bank,
    'packageName': packageName,
    'amount': amount,
    'type': type,
    'occurredAt': occurredAt.toUtc().toIso8601String(),
    'title': title,
    'categoryName': categoryName,
    'rawText': rawText,
  };

  factory PendingBankTransaction.fromJson(Map<String, dynamic> j) =>
      PendingBankTransaction(
        key: j['key'] as String,
        bank: j['bank'] as String? ?? '',
        packageName: j['packageName'] as String? ?? '',
        amount: (j['amount'] as num).toInt(),
        type: j['type'] as String? ?? 'EXPENSE',
        occurredAt: DateTime.parse(j['occurredAt'] as String),
        title: j['title'] as String? ?? '',
        categoryName: j['categoryName'] as String? ?? '',
        rawText: j['rawText'] as String? ?? '',
      );
}

/// Danh mục của module → danh mục TrackerX (mobile/BANK-NOTIFICATIONS.md mục 3).
const _expenseCategory = {
  'Ăn uống': 'Ăn uống',
  'Mua sắm': 'Mua sắm',
  'Di chuyển': 'Di chuyển',
  'Hóa đơn & Tiện ích': 'Hóa đơn',
};
const _incomeCategory = {'Lương': 'Lương'};

String dedupeKey(String packageName, int amount, int timestampMs) =>
    '${packageName.toLowerCase()}|$amount|${timestampMs ~/ 60000}';

/// `null` nếu không dùng được (số tiền 0, độ tin cậy thấp).
PendingBankTransaction? toPending(
  ParsedTransaction p, {
  required String packageName,
  double minConfidence = 0.6,
}) {
  if (p.amount <= 0 || p.confidence < minConfidence) return null;
  final income = p.isCredit;
  final category =
      (income ? _incomeCategory[p.category] : _expenseCategory[p.category]) ??
      (income ? 'Thu khác' : 'Chi khác');
  final note = p.note.trim();
  final title = note.isNotEmpty ? note : 'Giao dịch ${p.title}';
  return PendingBankTransaction(
    key: dedupeKey(packageName, p.amount, p.timestamp),
    bank: p.title,
    packageName: packageName,
    amount: p.amount,
    type: income ? 'INCOME' : 'EXPENSE',
    occurredAt: DateTime.fromMillisecondsSinceEpoch(p.timestamp, isUtc: true),
    title: title.length > 120 ? title.substring(0, 120) : title,
    categoryName: category,
    rawText: p.rawContent,
  );
}

String _fold(String s) => s.toLowerCase().replaceAll(RegExp(r'\s+'), '');

/// Danh mục đúng loại theo tên; không có thì danh mục "… khác" rồi danh mục đầu tiên cùng loại.
CategoryItem? pickCategory(
  List<CategoryItem> categories,
  PendingBankTransaction t,
) {
  final usable = categories
      .where((c) => !c.isArchived && c.type == t.type)
      .toList();
  final fallback = t.isIncome ? 'thukhác' : 'chikhác';
  for (final want in [_fold(t.categoryName), fallback]) {
    for (final c in usable) {
      if (_fold(c.name) == want) return c;
    }
  }
  return usable.isEmpty ? null : usable.first;
}

/// Ví đã ghép cho ngân hàng này, hoặc ví có tên khớp ("MBBank" ↔ "MB Bank", "MoMo"), hoặc null để hỏi người dùng.
WalletItem? pickWallet(
  List<WalletItem> wallets,
  PendingBankTransaction t,
  Map<String, String> remembered,
) {
  final usable = wallets.where((w) => !w.isArchived).toList();
  final id = remembered[t.bank];
  if (id != null) {
    for (final w in usable) {
      if (w.id == id) return w;
    }
  }
  final bank = _fold(t.bank);
  for (final w in usable) {
    final name = _fold(w.name);
    if (bank.isNotEmpty && (name.contains(bank) || bank.contains(name))) {
      return w;
    }
  }
  return null;
}

/// Khoản app đã tự ghi vào sổ (lưu trên máy 30 ngày, để xem lại / hoàn tác).
class AutoRecordedTransaction {
  const AutoRecordedTransaction({
    required this.key,
    required this.transactionId,
    required this.amount,
    required this.type,
    required this.title,
    required this.bank,
    required this.walletName,
    required this.categoryName,
    required this.occurredAt,
    required this.recordedAt,
    this.categoryIcon,
  });

  factory AutoRecordedTransaction.of(
    PendingBankTransaction t, {
    required String transactionId,
    required CategoryItem category,
    required WalletItem wallet,
    DateTime? recordedAt,
  }) => AutoRecordedTransaction(
    key: t.key,
    transactionId: transactionId,
    amount: t.amount,
    type: t.type,
    title: t.title,
    bank: t.bank,
    walletName: wallet.name,
    categoryName: category.name,
    categoryIcon: category.icon,
    occurredAt: t.occurredAt,
    recordedAt: recordedAt ?? DateTime.now().toUtc(),
  );

  /// Khóa của khoản chờ gốc (= externalRef gửi máy chủ).
  final String key;
  final String transactionId;
  final int amount;

  /// `INCOME` | `EXPENSE`
  final String type;
  final String title;
  final String bank;
  final String walletName;
  final String categoryName;
  final String? categoryIcon;
  final DateTime occurredAt;
  final DateTime recordedAt;

  bool get isIncome => type == 'INCOME';

  Map<String, dynamic> toJson() => {
    'key': key,
    'transactionId': transactionId,
    'amount': amount,
    'type': type,
    'title': title,
    'bank': bank,
    'walletName': walletName,
    'categoryName': categoryName,
    'categoryIcon': categoryIcon,
    'occurredAt': occurredAt.toUtc().toIso8601String(),
    'recordedAt': recordedAt.toUtc().toIso8601String(),
  };

  factory AutoRecordedTransaction.fromJson(Map<String, dynamic> j) =>
      AutoRecordedTransaction(
        key: j['key'] as String? ?? '',
        transactionId: j['transactionId'] as String,
        amount: (j['amount'] as num).toInt(),
        type: j['type'] as String? ?? 'EXPENSE',
        title: j['title'] as String? ?? '',
        bank: j['bank'] as String? ?? '',
        walletName: j['walletName'] as String? ?? '',
        categoryName: j['categoryName'] as String? ?? '',
        categoryIcon: j['categoryIcon'] as String?,
        occurredAt: DateTime.parse(j['occurredAt'] as String),
        recordedAt: DateTime.parse(j['recordedAt'] as String),
      );
}

/// Cùng một giao dịch báo qua hai nguồn (app ngân hàng + SMS): cùng số tiền, cùng loại, cách nhau ≤ 3 phút.
bool isSameTx(
  ({int amount, String type, DateTime occurredAt}) a,
  ({int amount, String type, DateTime occurredAt}) b,
) =>
    a.amount == b.amount &&
    a.type == b.type &&
    a.occurredAt.difference(b.occurredAt).abs() <= const Duration(minutes: 3);

extension PendingTxShape on PendingBankTransaction {
  ({int amount, String type, DateTime occurredAt}) get shape =>
      (amount: amount, type: type, occurredAt: occurredAt);
}

extension AutoTxShape on AutoRecordedTransaction {
  ({int amount, String type, DateTime occurredAt}) get shape =>
      (amount: amount, type: type, occurredAt: occurredAt);
}

/// Ngưỡng "Khoản lớn chờ xác nhận": 0 = Tắt.
const autoRecordThresholds = <int>[0, 1000000, 5000000, 10000000];
const defaultAutoRecordThreshold = 5000000;

/// `null` = được tự ghi; ngược lại là lý do vẫn chờ xác nhận.
String? autoRecordBlock(
  PendingBankTransaction t, {
  required CategoryItem? category,
  required WalletItem? wallet,
  required int threshold,
}) {
  if (wallet == null) return 'Chưa chọn ví cho ${t.bank}';
  if (category == null) return 'Chưa rõ danh mục';
  if (threshold > 0 && t.amount >= threshold) {
    return 'Khoản lớn, chờ bạn xác nhận';
  }
  return null;
}

/// [item] trùng (khác nguồn) với một khoản đang chờ hoặc đã tự ghi.
bool isDuplicateOfKnown(
  PendingBankTransaction item, {
  required Iterable<PendingBankTransaction> pending,
  required Iterable<AutoRecordedTransaction> autoRecorded,
}) =>
    pending.any((p) => p.key != item.key && isSameTx(p.shape, item.shape)) ||
    autoRecorded.any((a) => isSameTx(a.shape, item.shape));
