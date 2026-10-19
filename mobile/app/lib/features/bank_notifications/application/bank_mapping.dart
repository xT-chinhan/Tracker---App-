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

  /// Danh mục gợi ý theo tên danh mục Thu Chi.
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

/// Danh mục của module → danh mục Thu Chi (mobile/BANK-NOTIFICATIONS.md mục 3).
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
