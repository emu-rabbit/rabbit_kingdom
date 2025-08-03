import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/extensions/double.dart';
import 'package:rabbit_kingdom/extensions/int.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/collection_names.dart';
import 'package:rabbit_kingdom/helpers/dynamic.dart';
import 'package:rabbit_kingdom/models/kingdom_user.dart';
import 'package:rabbit_kingdom/services/kingdom_user_service.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

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
  final String uid;
  final String name;
  final double value;
  final String formattedValue;
  const RankSingleData({
    required this.uid,
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
  final Widget Function() descriptionBuilder;
  KingdomRank(this.firestoreField, {
    required this.descriptionBuilder,
    this.descending = true,
    this.formatter
  });
  
  Future<RankData> getRank(RankType type) async {
    final queryField = "$firestoreField.${type.name}";
    final rawData = await FirebaseFirestore
      .instance
      .collection(CollectionNames.ranks)
      .where(queryField, isNotEqualTo: -999999) // Magic number means no data
      .orderBy(queryField, descending: descending)
      .limit(10)
      .get()
      .then((snapshot){
        return snapshot
          .docs
          .map((doc) => (
            uid: doc.id,
            value: doc.data()[firestoreField]?[type.name]
          ))
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
    final result = rawData.map(
      (data) => RankSingleData(
        uid: data.uid,
        name: nameMap[data.uid] ?? "未命名",
        value: data.value,
        formattedValue: formatter != null ? 
          formatter!(data.value):
          data.value.toInt().toRDisplayString()
      )
    ).toList();
    return result;
  }

  Future<RankSingleData?> getSelfData(RankType type) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final ref = await FirebaseFirestore
      .instance
      .collection(CollectionNames.ranks)
      .doc(uid)
      .get();
    if (ref.exists) {
      final data = ref.data();
      final rawValue = data?[firestoreField]?[type.name];
      final value = safeToDouble(rawValue);
      final uc = Get.find<UserController>();
      final name = uc.user?.name ?? "未命名";
      return RankSingleData(
        uid: uid,
        name: name,
        value: value ?? -999999,
        formattedValue: (value == null || value == -999999) ?
          "<無資料>" : formatter != null ? formatter!(value): value.toInt().toRDisplayString()
      );
    }
    return null;
  }
}
Widget descriptionTextBuilder(String text) =>
  RText.bodySmall(text, fontStyle: FontStyle.italic, color: AppColors.onSurface.withAlpha(220));

final Map<RankName, KingdomRank> kingdomRanks = {
  RankName.property: KingdomRank(
    RankName.property.name,
    descriptionBuilder: () {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          descriptionTextBuilder("全王國裡最有錢的是誰呀！"),
          descriptionTextBuilder("注意資產配置，小心明天精華大殺價！"),
        ],
      );
    }
  ),
  RankName.coin: KingdomRank(
    RankName.coin.name,
    descriptionBuilder: () {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          descriptionTextBuilder("閃亮亮的硬幣最有安全感！"),
          descriptionTextBuilder("不求升值順風車，大帝的心情與我錢無關！"),
        ],
      );
    }
  ),
  RankName.poop: KingdomRank(
    RankName.poop.name,
    formatter: (value) => "${value.toInt()}個",
    descriptionBuilder: () {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          descriptionTextBuilder("全家壓箱寶都在這了！"),
          descriptionTextBuilder("大帝明天心情會開心的，對吧！"),
        ],
      );
    }
  ),
  RankName.exp: KingdomRank(
    RankName.exp.name,
    formatter: (value) {
      final level = KingdomUserExp
        .fromInt(value.toInt())
        .level;
      return "Lv.$level";
    },
    descriptionBuilder: () {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          descriptionTextBuilder("準時解任務的乖寶寶是我！"),
          descriptionTextBuilder("兔兔王國最有經驗的居民非我不可！"),
        ],
      );
    }
  ),
  RankName.drink: KingdomRank(
    RankName.drink.name,
    formatter: (value) {
      final amount = value.toInt().toRDisplayString();
      return "$amount杯";
    },
    descriptionBuilder: () {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          descriptionTextBuilder("我沒醉我沒醉我沒醉！"),
          descriptionTextBuilder("酒再苦視線在糊，也沒有腦袋糊，再來一杯！"),
        ],
      );
    }
  ),
  RankName.tradingVolume: KingdomRank(
    RankName.tradingVolume.name,
    formatter: (value) => "${value.toInt()}個",
    descriptionBuilder: () {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          descriptionTextBuilder("我買了，我又賣了！"),
          descriptionTextBuilder("打我啊笨蛋！"),
        ],
      );
    }
  ),
  RankName.maxTradingDif: KingdomRank(
    "tradingAvgDif",
    formatter: (value) => value.toSignedString(fractionDigits: 2),
    descriptionBuilder: () {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          descriptionTextBuilder("買低殺高，我最狠心！"),
          descriptionTextBuilder("什麼都不是真的，賣出去的那瞬間才是真的！"),
        ],
      );
    }
  ),
  RankName.minTradingDif: KingdomRank(
    "tradingAvgDif",
    descending: false,
    formatter: (value) => value.toSignedString(fractionDigits: 2),
    descriptionBuilder: () {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          descriptionTextBuilder("我...我只是！"),
          descriptionTextBuilder("不小心看錯價格了咩！"),
        ],
      );
    }
  ),
};