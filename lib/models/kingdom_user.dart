import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/announce_controller.dart';
import 'package:rabbit_kingdom/controllers/prices_controller.dart';
import 'package:rabbit_kingdom/extensions/int.dart';
import 'package:rabbit_kingdom/helpers/dynamic.dart';
import 'package:rabbit_kingdom/models/trading_record.dart';
import 'package:rabbit_kingdom/values/kingdom_tasks.dart';

class KingdomUser {
  final String name;
  final String email;
  final KingdomUserGroup group;
  final KingdomUserExp exp;
  final KingdomUserBudget budget;
  final KingdomUserTaskRecords records;
  final KingdomUserDrinks drinks;
  final KingdomUserTradingsNote note;

  KingdomUser._({
    required this.name,
    required this.email,
    required this.group,
    required this.exp,
    required this.budget,
    required this.records,
    required this.drinks,
    required this.note
  });

  factory KingdomUser.fromJson(Map<String, dynamic> json) {
    return KingdomUser._(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      group: KingdomUserGroup.fromString(json['group']),
      exp: KingdomUserExp.fromInt(json['exp']),
      budget: KingdomUserBudget.fromJson(json['budget']),
      records: KingdomUserTaskRecords.fromJson(json['records']),
      drinks: KingdomUserDrinks.fromJson(json['drinks']),
      note: KingdomUserTradingsNote.fromJson(json['note'])
    );
  }

  factory KingdomUser.newUser(String name, String email) {
    return KingdomUser._(
      name: name,
      email: email,
      group: KingdomUserGroup.unknown,
      exp: KingdomUserExp.fromInt(0),
      budget: KingdomUserBudget.fromJson(null),
      records: KingdomUserTaskRecords.create(),
      drinks: KingdomUserDrinks.create(),
      note: KingdomUserTradingsNote.create()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'group': group.name,
      'exp': exp.raw,
      'budget': budget.toJson(),
      'records': records.toJson(),
      'drinks': drinks.toJson(),
      'note': note.toJson()
    };
  }

  Map<KingdomTaskNames, ComputedTaskData> get taskData {
    final Map<KingdomTaskNames, ComputedTaskData> result = {};

    final now = DateTime.now().toUtc().add(const Duration(hours: 8)); // 台灣時間

    // 計算「今天的起始時間」，也就是最近的早上8點
    // 如果現在時間在當天早上8點之前，則起始時間是前一天的早上8點
    // 否則，起始時間是當天早上8點
    final DateTime todayEffectiveStart;
    if (now.hour < 8) {
      todayEffectiveStart = DateTime(now.year, now.month, now.day - 1, 8); // 前一天早上8點
    } else {
      todayEffectiveStart = DateTime(now.year, now.month, now.day, 8); // 當天早上8點
    }

    for (final entry in kingdomTasks.entries) {
      final name = entry.key;
      final task = entry.value;
      final recordList = records.record[name] ?? [];

      final completedToday = recordList.where((dt) {
        final localTime = dt.toUtc().add(const Duration(hours: 8)); // 轉為台灣時間
        return localTime.isAfter(todayEffectiveStart); // 判斷是否在有效起始時間之後
      }).length.clamp(0, task.limit);

      result[name] = ComputedTaskData(
        task.text,
        completed: completedToday,
        limit: task.limit,
        coinReward: task.coinReward,
        expReward: task.expReward,
        navigator: task.navigator
      );
    }

    return result;
  }
}

enum KingdomUserGroup {
  empire, girlfriend, dog, boss, friend, unknown;

  String toDisplay() {
    switch(this) {
      case KingdomUserGroup.empire:
        return "兔兔大帝";
      case KingdomUserGroup.girlfriend:
        return "可愛女友";
      case KingdomUserGroup.dog:
        return "貪吃狗狗";
      case KingdomUserGroup.boss:
        return "鄰國老大";
      case KingdomUserGroup.friend:
        return "要好朋朋";
      case KingdomUserGroup.unknown:
        return "迷途旅人";
    }
  }

  factory KingdomUserGroup.fromString(String? str) {
    return KingdomUserGroup.values.firstWhere(
          (e) => e.name == (str ?? 'unknown'),
      orElse: () => KingdomUserGroup.unknown,
    );
  }
}

class KingdomUserExp {
  int _raw;
  int get raw => _raw;
  int get level => _calculateLevel(raw);

  KingdomUserExp._(this._raw);

  KingdomUserExp add(int raw) {
    _raw += raw;
    return this;
  }

  int _calculateLevel(int exp) {
    int level = 0;
    int required = 100;
    int totalNeeded = 0;

    while (exp >= totalNeeded + required) {
      totalNeeded += required;
      required += 100; // 每級比前一級多 100
      level++;
    }

    return level + 1; // Lv.1 從 0 exp 開始
  }

  factory KingdomUserExp.fromInt(int? raw) {
    return KingdomUserExp._(raw ?? 0);
  }
}

class KingdomUserBudget {
  int coin;
  int poop;
  int get property {
    final controller = Get.find<PricesController>();
    final buyPrice = controller.prices?.buy ?? 0;
    return coin + poop * buyPrice;
  }
  String get propertyText => property.toRDisplayString();
  
  KingdomUserBudget._({ this.coin = 0, this.poop = 0 });
  
  factory KingdomUserBudget.fromJson(Map<String, dynamic>? json) {
    return KingdomUserBudget._(
      coin: json?['coin'] ?? 0,
      poop: json?['poop'] ?? 0
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'coin': coin,
      'poop': poop
    };
  }
}

class KingdomUserTaskRecords {
  final Map<KingdomTaskNames, List<DateTime>> record;

  KingdomUserTaskRecords._({ required this.record });

  factory KingdomUserTaskRecords.fromJson(Map<String, dynamic>? json) {
    final r = <KingdomTaskNames, List<DateTime>>{};
    for (var entry in kingdomTasks.entries) {
       final taskRecords = json?[entry.key.name];
       if (taskRecords != null && taskRecords is List<dynamic>) {
         r.putIfAbsent(entry.key, () => taskRecords.map((e) => toDateTime(e)).whereType<DateTime>().toList());
       } else {
         r.putIfAbsent(entry.key, () => []);
       }
    }

    return KingdomUserTaskRecords._(record: r);
  }

  factory KingdomUserTaskRecords.create() {
    final r = <KingdomTaskNames, List<DateTime>>{};
    for (var entry in kingdomTasks.entries) {
      r.putIfAbsent(entry.key, () => []);
    }
    return KingdomUserTaskRecords._(record: r);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> result = {};
    record.forEach((taskName, dateList) {
      result[taskName.name] = dateList;
    });
    return result;
  }
}

class ComputedTaskData extends KingdomTask {
  final int completed;
  ComputedTaskData(
    super.text,
    {
      required this.completed,
      required super.limit,
      required super.coinReward,
      required super.expReward,
      required super.navigator
    }
  );
}

class KingdomUserDrinks {
  final int count;
  final DateTime lastAt;

  KingdomUserDrinks._({
    required this.count,
    required this.lastAt
  });

  factory KingdomUserDrinks.fromJson(Map<String, dynamic>? json) {
    return KingdomUserDrinks._(
      count: json?['count'] ?? 0,
      lastAt: toDateTime(json?['lastAt']) ?? DateTime.fromMillisecondsSinceEpoch(0)
    );
  }

  factory KingdomUserDrinks.create() {
    return KingdomUserDrinks._(
      count: 0,
      lastAt: DateTime.fromMillisecondsSinceEpoch(0)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'lastAt': lastAt
    };
  }
}

class KingdomUserTradingsNote {
  final int buyAmount;
  final double? buyAverage;
  final int sellAmount;
  final double? sellAverage;

  const KingdomUserTradingsNote._({
    required this.buyAmount,
    required this.buyAverage,
    required this.sellAmount,
    required this.sellAverage,
  });

  /// 初次建立用（所有值歸零）
  factory KingdomUserTradingsNote.create() {
    return const KingdomUserTradingsNote._(
      buyAmount: 0,
      buyAverage: null,
      sellAmount: 0,
      sellAverage: null,
    );
  }

  /// 轉換為 JSON
  Map<String, dynamic> toJson() {
    return {
      'buyAmount': buyAmount,
      'buyAverage': buyAverage,
      'sellAmount': sellAmount,
      'sellAverage': sellAverage,
    };
  }

  /// 從 JSON 建立物件
  factory KingdomUserTradingsNote.fromJson(Map<String, dynamic>? json) {
    return KingdomUserTradingsNote._(
      buyAmount: json?['buyAmount'] ?? 0,
      buyAverage: json?['buyAverage'],
      sellAmount: json?['sellAmount'] ?? 0,
      sellAverage: json?['sellAverage'],
    );
  }

  /// 套用一筆交易紀錄，計算新的統計資訊（不會修改原物件）
  KingdomUserTradingsNote applyRecord(TradingRecord record) {
    switch (record.type) {
      case TradingType.buy:
      // 對使用者來說是「賣出」
        final newSellAmount = sellAmount + record.amount;
        final newSellAverage = _calcNewAverage(
          currentAmount: sellAmount,
          currentAverage: sellAverage,
          newAmount: record.amount,
          newPrice: record.price,
        );
        return KingdomUserTradingsNote._(
          buyAmount: buyAmount,
          buyAverage: buyAverage,
          sellAmount: newSellAmount,
          sellAverage: newSellAverage,
        );

      case TradingType.sell:
      // 對使用者來說是「買入」
        final newBuyAmount = buyAmount + record.amount;
        final newBuyAverage = _calcNewAverage(
          currentAmount: buyAmount,
          currentAverage: buyAverage,
          newAmount: record.amount,
          newPrice: record.price,
        );
        return KingdomUserTradingsNote._(
          buyAmount: newBuyAmount,
          buyAverage: newBuyAverage,
          sellAmount: sellAmount,
          sellAverage: sellAverage,
        );
    }
  }

  /// 計算新的加權平均價格
  double _calcNewAverage({
    required int currentAmount,
    required double? currentAverage,
    required int newAmount,
    required int newPrice,
  }) {
    if (currentAmount == 0 || currentAverage == null) {
      return newPrice.toDouble();
    }
    final totalAmount = currentAmount + newAmount;
    final totalValue = currentAmount * currentAverage + newAmount * newPrice;
    return totalValue / totalAmount;
  }
}
