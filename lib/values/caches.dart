import 'package:rabbit_kingdom/helpers/app_data_cache.dart';
import 'package:rabbit_kingdom/values/kingdom_ranks.dart';

class Caches {
  static final recentPrices = RecentPricesCache();
  static final recentAnnounces = RecentAnnouncesCache();
  static final userNames = <String, String>{}; // uid to name
  static final Map<RankName, Map<RankType, RankDataCache>> ranksData = {};

  static void initialize() {
    for (var name in RankName.values) {
      ranksData[name] = {
        RankType.all: RankDataCache(rankName: name, rankType: RankType.all),
        RankType.currentMonth: RankDataCache(rankName: name, rankType: RankType.currentMonth)
      };
    }
  }
}