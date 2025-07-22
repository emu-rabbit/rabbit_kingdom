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