import 'dart:math';

import 'package:rabbit_kingdom/helpers/dynamic.dart';

class PoopPrices {
  final int buy;
  final int sell;
  final DateTime createAt;

  PoopPrices._({ required this.buy, required this.sell, required this.createAt });

  factory PoopPrices.fromJson(Map<String, dynamic>? json) {
    return PoopPrices._(
      buy: json?['buy'] ?? 0,
      sell: json?['sell'] ?? 99999,
      createAt: toDateTime(json?['createAt']) ?? DateTime.fromMillisecondsSinceEpoch(0)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buy': buy,
      'sell': sell,
      'createAt': createAt
    };
  }
}