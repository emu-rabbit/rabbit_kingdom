import 'package:get/get.dart';
import 'package:rabbit_kingdom/helpers/ad.dart';
import 'package:rabbit_kingdom/pages/newest_announce_page.dart';

enum KingdomTaskNames {
  login, heart, comment, ad
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

Map<KingdomTaskNames, KingdomTask> kingdomTasks = {
  KingdomTaskNames.login: KingdomTask(
    "入境兔兔王國",
    limit: 1,
    coinReward: 150,
    expReward: 150,
    navigator: (){}
  ),
  KingdomTaskNames.heart: KingdomTask(
    "點擊公告愛心",
    limit: 1,
    coinReward: 100,
    expReward: 100,
    navigator: (){ Get.to(() => NewestAnnouncePage()); }
  ),
  KingdomTaskNames.comment: KingdomTask(
      "在公告上留言",
      limit: 1,
      coinReward: 200,
      expReward: 200,
      navigator: (){ Get.to(() => NewestAnnouncePage()); }
  ),
  KingdomTaskNames.ad: KingdomTask(
      "觀看廣告",
      limit: 3,
      coinReward: 100,
      expReward: 100,
      navigator: (){ showRewardedAd(); }
  ),
};