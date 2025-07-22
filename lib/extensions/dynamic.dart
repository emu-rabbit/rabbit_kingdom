import 'package:cloud_firestore/cloud_firestore.dart';

extension DateTimeParser on dynamic {
  DateTime? toDateTime() {
    if (this is Timestamp) {
      return (this as Timestamp).toDate();
    } else if (this is DateTime) {
      return this as DateTime;
    } else if (this is String) {
      return DateTime.tryParse(this as String) ?? DateTime.fromMillisecondsSinceEpoch(0);
    } else if (this is int) {
      return DateTime.fromMillisecondsSinceEpoch(this as int);
    }
    return null;
  }
}