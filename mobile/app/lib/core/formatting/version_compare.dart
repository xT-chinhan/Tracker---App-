abstract final class VersionCompare {
  static int compare(String left, String right) {
    final a = _parts(left);
    final b = _parts(right);
    final length = a.length > b.length ? a.length : b.length;
    for (var index = 0; index < length; index++) {
      final av = index < a.length ? a[index] : 0;
      final bv = index < b.length ? b[index] : 0;
      if (av != bv) return av.compareTo(bv);
    }
    return 0;
  }

  static List<int> _parts(String version) {
    final core = version.trim().split(RegExp(r'[+-]')).first;
    final parts = core.split('.');
    if (parts.isEmpty || parts.any((part) => int.tryParse(part) == null)) {
      throw FormatException('Phiên bản không hợp lệ: $version');
    }
    return parts.map(int.parse).toList(growable: false);
  }
}
