extension RListExtension<T> on List<T> {
  T? get(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }
}