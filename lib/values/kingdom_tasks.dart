import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/app_config_controller.dart';
import 'package:rabbit_kingdom/helpers/cloud_functions.dart';
import 'package:rabbit_kingdom/helpers/collection_names.dart';

import '../controllers/user_controller.dart';
import '../helpers/ad.dart';
import '../pages/newest_announce_page.dart';
import '../pages/trading_page.dart';
import '../widgets/r_snack_bar.dart';

enum KingdomTaskNames {
  login, heart, comment, drink, trade, ad
}

class KingdomTask {
  final String text;
  final int limit;
  final int coinReward;
  final int expReward;
  final Function() navigator;

  const KingdomTask(
    this.text,
    { required this.limit, required this.coinReward, required this.expReward, required this.navigator }
  );
}

enum TaskNavigator {
  login,
  newestAnnounce,
  back,
  trading,
  adReward,
  none,
}
class KingdomTaskConfig {
  final String text;
  final int limit;
  final int coinReward;
  final int expReward;
  final String navigator;

  KingdomTaskConfig({
    required this.text,
    required this.limit,
    required this.coinReward,
    required this.expReward,
    required this.navigator,
  });

  factory KingdomTaskConfig.fromJson(Map<dynamic, dynamic> json) {
    // 安全地讀取 JSON 資料並給予預設值
    return KingdomTaskConfig(
      text: (json['text'] as String?) ?? '',
      limit: (json['limit'] as int?) ?? 1,
      coinReward: (json['coin_reward'] as int?) ?? 0,
      expReward: (json['exp_reward'] as int?) ?? 0,
      navigator: (json['navigator'] as String?) ?? 'none',
    );
  }
}

// 根據字串獲取對應的導航函式
Function() _getNavigatorFunction(String navigatorStr) {
  switch (navigatorStr) {
    case 'login':
      return () {
        final c = Get.find<UserController>();
        if (c.user != null) {
          c.triggerTaskComplete(KingdomTaskNames.login);
        }
      };
    case 'newest_announce':
      return () => Get.to(() => NewestAnnouncePage());
    case 'trading_page': // 注意這裡與您提供的 JSON 鍵值 trading_page 保持一致
    case 'trading': // 或使用更簡潔的 'trading'
      return () => Get.to(() => TradingPage());
    case 'back':
      return () => Get.back();
    case 'ad_reward':
      return () {
        showRewardedAd(
            onReward: () {
              CloudFunctions.adWatched().catchError((e, stack) {
                FirebaseCrashlytics.instance.recordError(e, stack);
              });
            },
            onFail: () {
              RSnackBar.error("抓取廣告失敗", "目前沒有廣告，請稍後再試");
            }
        );
      };
    default:
      return () {}; // 沒有導航時，回傳一個空函式
  }
}

Map<KingdomTaskNames, KingdomTask> buildKingdomTasksFromJson(Map<dynamic, dynamic> json) {
  final tasks = <KingdomTaskNames, KingdomTask>{};

  for (var name in KingdomTaskNames.values) {
    // 確保 key 是 String 且配置是 Map
    final key = name.name;
    final rawConfig = json[key];
    if (rawConfig is! Map) {
      continue; // 如果資料格式不對，直接跳過
    }

    try {
      final taskName = KingdomTaskNames.values.firstWhere(
            (e) => e.toString().split('.').last == key,
      );
      final config = KingdomTaskConfig.fromJson(rawConfig);

      tasks[taskName] = KingdomTask(
        config.text,
        limit: config.limit,
        coinReward: config.coinReward,
        expReward: config.expReward,
        navigator: _getNavigatorFunction(config.navigator),
      );
    } catch (e, stack) {
      // 處理找不到 Enum 或轉換失敗的錯誤
      FirebaseCrashlytics.instance.recordError(e, stack, reason: 'Failed to build task from JSON for key: $key');
      debugPrint('Failed to build task from JSON for key: $key, error: $e');
      continue; // 跳過有問題的任務
    }
  }

  return tasks;
}