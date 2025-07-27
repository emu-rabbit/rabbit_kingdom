import 'package:flutter/foundation.dart';

class CollectionNames {
  CollectionNames._();

  static String get prefix => kDebugMode ? "dev_" : "";
  static String get user => "${prefix}user";
  static String get fcm => "${prefix}fcm";
  static String get announce => "${prefix}announce";
  static String get prices => "${prefix}prices";
  static String get records => "${prefix}records";
}