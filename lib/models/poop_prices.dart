import 'package:rabbit_kingdom/helpers/dynamic.dart';

enum PriceIssuer {
  timer,
  mood,
  news,
  unknown;

  factory PriceIssuer.fromString(String? raw) {
    if (raw == null) return PriceIssuer.unknown;
    return PriceIssuer.values.firstWhere(
          (e) => e.name == raw,
      orElse: () => PriceIssuer.unknown,
    );
  }
}

class PoopPrices {
  final int buy;
  final int sell;
  final DateTime createAt;
  final PriceIssuer issuer;

  PoopPrices._({
    required this.buy,
    required this.sell,
    required this.createAt,
    required this.issuer,
  });

  factory PoopPrices.fromJson(Map<String, dynamic>? json) {
    return PoopPrices._(
      buy: json?['buy'] ?? 0,
      sell: json?['sell'] ?? 99999,
      createAt: toDateTime(json?['createAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      issuer: PriceIssuer.fromString(json?['issuer']),
    );
  }

  factory PoopPrices.create(int buy) {
    return PoopPrices._(
      buy: buy,
      sell: buy + 6,
      createAt: DateTime.now(),
      issuer: PriceIssuer.news,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'buy': buy,
      'sell': sell,
      'createAt': createAt,
      'issuer': issuer.name
    };
  }
}