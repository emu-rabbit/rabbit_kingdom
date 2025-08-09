import 'dart:math';

import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/app_config_controller.dart';
import 'package:rabbit_kingdom/controllers/prices_controller.dart';
import 'package:rabbit_kingdom/extensions/int.dart';
import 'package:rabbit_kingdom/helpers/dynamic.dart';
import 'package:rabbit_kingdom/models/pray.dart';
import 'package:rabbit_kingdom/values/kingdom_tasks.dart';

class KingdomUser {
  final String name;
  final String email;
  final DateTime createAt;
  final KingdomUserGroup group;
  final KingdomUserExp exp;
  final KingdomUserBudget budget;
  final KingdomUserTaskRecords records;
  final KingdomUserDrinks drinks;
  final KingdomUserTradingsNote note;
  final KingdomUserAdInfo ad;
  final KingdomUserPray pray;

  KingdomUser._({
    required this.name,
    required this.email,
    required this.createAt,
    required this.group,
    required this.exp,
    required this.budget,
    required this.records,
    required this.drinks,
    required this.note,
    required this.ad,
    required this.pray
  });

  factory KingdomUser.fromJson(Map<String, dynamic> json) {
    return KingdomUser._(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      createAt: toDateTime(json['createAt']) ?? DateTime.now(),
      group: KingdomUserGroup.fromString(json['group']),
      exp: KingdomUserExp.fromInt(json['exp']),
      budget: KingdomUserBudget.fromJson(json['budget']),
      records: KingdomUserTaskRecords.fromJson(json['records']),
      drinks: KingdomUserDrinks.fromJson(json['drinks']),
      note: KingdomUserTradingsNote.fromJson(json['note']),
      ad: KingdomUserAdInfo.fromJson(json['ad']),
      pray: KingdomUserPray.fromJson(json['pray'])
    );
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

    for (final entry in Get.find<AppConfigController>().config?.tasks.entries ?? <KingdomTaskNames, KingdomTask>{}.entries) {
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
  empire, girlfriend, dog, boss, rabbit, friend, unknown;

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
      case KingdomUserGroup.rabbit:
        return "兔子夥伴";
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
  final int coin;
  final int poop;
  final int drink;
  int get property {
    final controller = Get.find<PricesController>();
    final buyPrice = controller.prices?.buy ?? 0;
    final config = Get.find<AppConfigController>().config;
    final drinkPrice = config.priceDrink;
    return coin + poop * buyPrice + drink * drinkPrice;
  }
  String get propertyText => property.toRDisplayString();
  
  KingdomUserBudget._({ required this.coin, required this.poop, required this.drink });
  
  factory KingdomUserBudget.fromJson(Map<String, dynamic>? json) {
    return KingdomUserBudget._(
      coin: json?['coin'] ?? 0,
      poop: json?['poop'] ?? 0,
      drink: json?['drink'] ?? 0
    );
  }
}

class KingdomUserTaskRecords {
  final Map<KingdomTaskNames, List<DateTime>> record;

  KingdomUserTaskRecords._({ required this.record });

  factory KingdomUserTaskRecords.fromJson(Map<String, dynamic>? json) {
    final r = <KingdomTaskNames, List<DateTime>>{};
    for (var entry in Get.find<AppConfigController>().config?.tasks.entries ?? <KingdomTaskNames, KingdomTask>{}.entries) {
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
    for (var entry in Get.find<AppConfigController>().config?.tasks.entries ?? {}.entries) {
      r.putIfAbsent(entry.key, () => []);
    }
    return KingdomUserTaskRecords._(record: r);
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
  final int total;
  final DateTime lastAt;

  KingdomUserDrinks._({
    required this.count,
    required this.total,
    required this.lastAt
  });

  factory KingdomUserDrinks.fromJson(Map<String, dynamic>? json) {
    return KingdomUserDrinks._(
      count: json?['count'] ?? 0,
      total: json?['total'] ?? 0,
      lastAt: toDateTime(json?['lastAt']) ?? DateTime.fromMillisecondsSinceEpoch(0)
    );
  }

  factory KingdomUserDrinks.create() {
    return KingdomUserDrinks._(
      count: 0,
      total: 0,
      lastAt: DateTime.fromMillisecondsSinceEpoch(0)
    );
  }

  static Duration getDrinkFullyDecay(int count) {
    // 處理邊界情況，如果沒有喝酒或輸入無效，則沒有酒醉時間。
    if (count <= 0) {
      return Duration.zero; // Dart 中表示零時間的標準方式
    } else if (count > 8) {
      return getDrinkFullyDecay(8);
    }

    // 應用我們的非線性方程式：f(x) = 10 * x^1.2
    // 使用 dart:math 中的 pow() 函數進行次方計算。
    final double minutes = 10.0 * pow(count, 1.2);

    // 將計算出的分鐘數（double類型）四捨五入後，創建 Duration 物件。
    // Dart 的 Duration 建構子可以直接接受分鐘數。
    return Duration(minutes: minutes.round());
  }
}

class KingdomUserTradingsNote {
  final int buyAmount;
  final double? buyAverage;
  final int sellAmount;
  final double? sellAverage;
  double? get averageDif {
    return buyAverage != null && sellAverage != null ? sellAverage! - buyAverage! : null;
  }

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

  /// 從 JSON 建立物件
  factory KingdomUserTradingsNote.fromJson(Map<String, dynamic>? json) {
    return KingdomUserTradingsNote._(
      buyAmount: json?['buyAmount'] ?? 0,
      buyAverage: safeToDouble(json?['buyAverage']),
      sellAmount: json?['sellAmount'] ?? 0,
      sellAverage: safeToDouble(json?['sellAverage']),
    );
  }
}

class KingdomUserAdInfo {
  final int count;
  const KingdomUserAdInfo._({
    required this.count
  });

  factory KingdomUserAdInfo.fromJson(Map<String, dynamic>? json) {
    return KingdomUserAdInfo._(
      count: json?['count'] ?? 0
    );
  }

  factory KingdomUserAdInfo.create() {
    return KingdomUserAdInfo._(
      count: 0,
    );
  }
}

class KingdomUserPray {
  final int count;
  final DateTime? simpleAt;
  final DateTime? advanceAt;
  final PendingPrayRewards? pending;

  KingdomUserPray._({
    required this.count,
    this.simpleAt,
    this.advanceAt,
    this.pending,
  });

  factory KingdomUserPray.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return KingdomUserPray._(
        count: 0,
        simpleAt: null,
        advanceAt: null,
        pending: null,
      );
    }

    return KingdomUserPray._(
      count: json['count'] is int
          ? json['count'] as int
          : int.tryParse(json['count'].toString()) ?? 0,
      simpleAt: toDateTime(json['simpleAt']),
      advanceAt: toDateTime(json['advanceAt']),
      pending: json['pending'] == null
          ? null
          : PendingPrayRewards.fromJson(
        json['pending'] as Map<String, dynamic>,
      ),
    );
  }
}

