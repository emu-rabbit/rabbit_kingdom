import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rabbit_kingdom/extensions/double.dart';
import 'package:rabbit_kingdom/extensions/int.dart';
import 'package:rabbit_kingdom/helpers/collection_names.dart';
import 'package:rabbit_kingdom/helpers/dynamic.dart';
import 'package:rabbit_kingdom/models/kingdom_user.dart';
import 'package:rabbit_kingdom/services/kingdom_user_service.dart';

enum RankName {
  property, coin, poop, exp, drink, tradingVolume, maxTradingDif, minTradingDif;
  String toDisplayString() {
    switch(this) {
      case RankName.property:
        return "王國富豪";
      case RankName.coin:
        return "兔幣至上";
      case RankName.poop:
        return "精華之巔";
      case RankName.exp:
        return "老謀深算";
      case RankName.drink:
        return "不醉不歸";
      case RankName.tradingVolume:
        return "交易大戶";
      case RankName.maxTradingDif:
        return "操盤高手";
      case RankName.minTradingDif:
        return "韭菜盒子";
    }
  }
}
enum RankType {
  all, currentMonth
}
class RankSingleData {
  final String name;
  final double value;
  final String formattedValue;
  const RankSingleData({ 
    required this.name, 
    required this.value,
    required this.formattedValue
  });
}
class RawRankSingleData {
  final String uid;
  final double value;
  const RawRankSingleData({ required this.uid, required this.value });
}
typedef RankData = List<RankSingleData>;
class KingdomRank {
  final String firestoreField;
  final bool descending;
  final String Function(double)? formatter;
  KingdomRank(this.firestoreField, { 
    this.descending = true,
    this.formatter
  });
  
  Future<RankData> getRank(RankType type) async {
    final queryField = "$firestoreField.${type.name}";
    final rawData = await FirebaseFirestore
      .instance
      .collection(CollectionNames.ranks)
      .where(queryField, isNotEqualTo: null)
      .orderBy(queryField, descending: descending)
      .limit(10)
      .get()
      .then((snapshot){
        return snapshot
          .docs
          .map((doc) => (
            uid: doc.id,
            value: doc.data()[firestoreField]?[type.name])
          )
          .map((data) {
            final value = safeToDouble(data.value);
            return value != null ?
              RawRankSingleData(uid: data.uid, value: value):
              null;
          })
          .whereType<RawRankSingleData>()
          .toList();
      });

    final nameMap = await KingdomUserService.getNameByUID(
      rawData.map((data) => data.uid).toList()
    );
    return rawData.map(
      (data) => RankSingleData(
        name: nameMap[data.uid] ?? "未命名",
        value: data.value,
        formattedValue: formatter != null ? 
          formatter!(data.value):
          data.value.toInt().toRDisplayString()
      )
    ).toList();
  }
}
final Map<RankName, KingdomRank> kingdomRanks = {
  RankName.property: KingdomRank(
    RankName.property.name
  ),
  RankName.coin: KingdomRank(
    RankName.coin.name
  ),
  RankName.poop: KingdomRank(
    RankName.poop.name
  ),
  RankName.exp: KingdomRank(
    RankName.exp.name,
    formatter: (value) {
      final level = KingdomUserExp
        .fromInt(value.toInt())
        .level;
      return "Lv.$level";
    }
  ),
  RankName.drink: KingdomRank(
    RankName.drink.name,
    formatter: (value) {
      final amount = value.toInt().toRDisplayString();
      return "$amount杯";
    }
  ),
  RankName.tradingVolume: KingdomRank(
    RankName.tradingVolume.name
  ),
  RankName.maxTradingDif: KingdomRank(
    "tradingAvgDif",
    formatter: (value) => value.toSignedString(fractionDigits: 2)
  ),
  RankName.minTradingDif: KingdomRank(
    "tradingAvgDif",
    descending: false,
    formatter: (value) => value.toSignedString(fractionDigits: 2)
  ),
};