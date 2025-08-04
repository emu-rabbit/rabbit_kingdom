extension RIntExtension on int {
  String toRDisplayString() {
    if (this == 0) return '0';

    bool isNegative = this < 0;
    num absNum = isNegative ? -this : this;

    if (absNum < 1000) return toString();

    const units = ['K', 'M', 'B', 'T'];
    int unitIndex = -1;

    while (absNum >= 1000 && unitIndex < units.length - 1) {
      absNum /= 1000;
      unitIndex++;
    }

    String formatted;
    if (absNum < 10) {
      formatted = absNum.toStringAsFixed(2);
    } else if (absNum < 100) {
      formatted = absNum.toStringAsFixed(1);
    } else {
      formatted = absNum.toStringAsFixed(0);
    }

    String prefix = isNegative ? '-' : '';
    return '$prefix$formatted${units[unitIndex]}';
  }

  String toSignedRDisplayString() {
    if (this > 0) {
      return "+${toRDisplayString()}";
    } else {
      return toRDisplayString();
    }
  }

  String toSignedString() {
    if (this > 0) return '+$this';
    if (this < 0) return '$this'; // 自帶負號
    return '0';
  }

  int get orZero => this ?? 0;
}
