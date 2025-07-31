extension RDoubleExtension on double {
  String toSignedString({int fractionDigits = 2}) {
    if (this > 0) return '+${toStringAsFixed(fractionDigits)}';
    if (this < 0) return toStringAsFixed(fractionDigits); // 自帶負號
    return '0';
  }
}