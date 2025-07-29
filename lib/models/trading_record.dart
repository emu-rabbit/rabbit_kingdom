enum TradingType { buy, sell }

class TradingRecord {
  final TradingType type;
  final int amount;
  final int price;
  final DateTime createAt;

  const TradingRecord._({required this.type, required this.price, required this.amount, required this.createAt});

  factory TradingRecord.createBuy({
    required int amount,
    required int price
  }) => TradingRecord._(type: TradingType.buy, price: price, amount: amount, createAt: DateTime.now());

  factory TradingRecord.createSell({
    required int amount,
    required int price
  }) => TradingRecord._(type: TradingType.sell, price: price, amount: amount, createAt: DateTime.now());

  Map<String, dynamic> toJson() => {
    'type': type.name,              // 例如 'buy' 或 'sell'
    'amount': amount,
    'price': price,
    'createAt': createAt, // 標準 ISO 格式時間字串
  };
}