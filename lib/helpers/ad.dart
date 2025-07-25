import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/values/kingdom_tasks.dart';

Future<void> showRewardedAd({
  VoidCallback? onReward,
  VoidCallback? onFail,
}) async {
  bool isDev = kDebugMode; // or use your own env flag
  final unitID =  isDev ?
    'ca-app-pub-3940256099942544/5224354917' : // 測試 ID
    'ca-app-pub-3770234564897287/5813152110';

  RewardedAd.load(
    adUnitId: unitID, // 替換成你的 Rewarded Ad ID
    request: AdRequest(),
    rewardedAdLoadCallback: RewardedAdLoadCallback(
      onAdLoaded: (RewardedAd ad) {
        ad.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            if (onFail != null) onFail();
          },
        );

        ad.show(
          onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            final c = Get.find<UserController>();
            c.triggerTaskComplete(KingdomTaskNames.ad);
            if(onReward != null) onReward(); // ✅ 給予獎勵的地方
          },
        );
      },
      onAdFailedToLoad: (LoadAdError error) {
        log('RewardedAd failed to load: $error');
        if (onFail != null) onFail();
      },
    ),
  );
}
