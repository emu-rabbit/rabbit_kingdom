import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/auth_controller.dart';

enum TradingType { buy, sell }

class TradingRecord {
  late final String userID;
  final TradingType type;
  final int amount;
  final int price;
  final DateTime createAt;

  TradingRecord._({required this.type, required this.price, required this.amount, required this.createAt}) {
    final ac = Get.find<AuthController>();
    if (ac.firebaseUser.value == null) userID = "";
    userID = ac.firebaseUser.value!.uid;
  }

  factory TradingRecord.createBuy({
    required int amount,
    required int price
  }) => TradingRecord._(type: TradingType.buy, price: price, amount: amount, createAt: DateTime.now());

  factory TradingRecord.createSell({
    required int amount,
    required int price
  }) => TradingRecord._(type: TradingType.sell, price: price, amount: amount, createAt: DateTime.now());

  Map<String, dynamic> toJson() => {
    'userID': userID,
    'type': type.name,              // 例如 'buy' 或 'sell'
    'amount': amount,
    'price': price,
    'createAt': createAt, // 標準 ISO 格式時間字串
  };
}