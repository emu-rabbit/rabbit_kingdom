import 'package:cloud_firestore/cloud_firestore.dart';

DateTime? toDateTime(dynamic data) {
  if (data is Timestamp) {
    return data.toDate();
  } else if (data is DateTime) {
    return data;
  } else if (data is String) {
    return DateTime.tryParse(data) ?? DateTime.fromMillisecondsSinceEpoch(0);
  } else if (data is int) {
    return DateTime.fromMillisecondsSinceEpoch(data);
  }
  return null;
}

double? safeToDouble(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value);
  }
  return null; // 如果是其他類型，返回 null
}