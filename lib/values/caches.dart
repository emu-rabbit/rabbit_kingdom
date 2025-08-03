import 'package:rabbit_kingdom/helpers/app_data_cache.dart';

class Caches {
  static final recentPrices = RecentPricesCache();
  static final recentAnnounces = RecentAnnouncesCache();
  static final userNames = <String, String>{}; // uid to name
}