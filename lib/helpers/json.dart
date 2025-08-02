bool mergeMissingFields(Map<String, dynamic> source, Map<String, dynamic> expected) {
  bool updated = false;

  expected.forEach((key, value) {
    if (!source.containsKey(key)) {
      source[key] = value;
      updated = true;
    } else if (value is Map<String, dynamic> && source[key] is Map<String, dynamic>) {
      updated |= mergeMissingFields(source[key], value);
    }
  });

  return updated;
}
