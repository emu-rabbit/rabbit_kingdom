import 'package:flutter/foundation.dart';

class CollectionNames {
  CollectionNames._();

  static String get prefix => kDebugMode ? "dev_" : "";
  static String get user => "${prefix}user";
}