import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rabbit_kingdom/helpers/app_data_cache.dart';
import 'package:rabbit_kingdom/helpers/collection_names.dart';
import 'package:rabbit_kingdom/models/kingdom_announcement.dart';
import 'package:rabbit_kingdom/models/poop_prices.dart';
import 'package:rabbit_kingdom/values/caches.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';

class KingdomUserService {
  static Future<List<KingdomAnnouncement>> getRecentAnnounce() async {
    try {
      return await Caches.recentAnnounces.getData();
    } catch (e) {
      RSnackBar.error("抓取失敗", e.toString());
      return [];
    }
  }

  static Future<List<PoopPrices>> getRecentPrices() async {
    try {
      return await Caches.recentPrices.getData();
    } catch (e) {
      RSnackBar.error("抓取失敗", e.toString());
      return [];
    }
  }

  static Future<Map<String, String>> getNameByUID(List<String> uids) async {
    final Map<String, String> result = {};
    final List<String> uidsToFetch = [];

    // 1. 先從 Caches.userNames 尋找已有的使用者名稱
    for (final uid in uids) {
      if (Caches.userNames.containsKey(uid)) {
        result[uid] = Caches.userNames[uid]!;
      } else {
        uidsToFetch.add(uid);
      }
    }

    // 2. 處理需要從 Firestore 獲取的 uids
    if (uidsToFetch.isNotEmpty) {
      // Firestore 的 'whereIn' 限制最多支援 10 個元素，所以需要分批處理
      const int batchSize = 10;
      for (int i = 0; i < uidsToFetch.length; i += batchSize) {
        final int end = (i + batchSize < uidsToFetch.length) ? i + batchSize : uidsToFetch.length;
        final List<String> batchUids = uidsToFetch.sublist(i, end);

        try {
          final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection(CollectionNames.user)
              .where(FieldPath.documentId, whereIn: batchUids)
              .get();

          for (final doc in querySnapshot.docs) {
            final String uid = doc.id;
            final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            final String? name = data['name'] as String?;

            if (name != null) {
              result[uid] = name;
              // 3. 將新的使用者名稱存入快取
              Caches.userNames[uid] = name;
            }
          }
        } catch (e) {
          // 處理錯誤，例如記錄日誌
          print('Error fetching users with uids: $batchUids, error: $e');
        }
      }
    }

    return result;
  }
}