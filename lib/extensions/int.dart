extension RIntExtension on int {
  String toRDisplayString() {
    if (this < 1000) return toString();

    const units = ['K', 'M', 'B', 'T'];
    double num = toDouble();
    int unitIndex = -1;

    while (num >= 1000 && unitIndex < units.length - 1) {
      num /= 1000;
      unitIndex++;
    }

    String formatted;
    if (num < 10) {
      formatted = num.toStringAsFixed(2);
    } else if (num < 100) {
      formatted = num.toStringAsFixed(1);
    } else {
      formatted = num.toStringAsFixed(0);
    }

    return '$formatted${units[unitIndex]}';
  }

  String toSignedString() {
    if (this > 0) return '+$this';
    if (this < 0) return '$this'; // 自帶負號
    return '0';
  }

  int get orZero => this ?? 0;
}
