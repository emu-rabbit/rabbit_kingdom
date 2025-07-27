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

  factory PoopPrices.create(int mood) {
    int basePrice = (80 + (mood.clamp(0, 99) / 99.0) * 120).round(); // 80~200
    int fluctuation = [-5, -3, -2, -1, 0, 1, 2, 3, 5][Random().nextInt(9)];

    int mid = basePrice + fluctuation;
    int rBuy = mid - 3;
    int rSell = rBuy + 6;
    return PoopPrices._(
      buy: rBuy,
      sell: rSell,
      createAt: DateTime.now()
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