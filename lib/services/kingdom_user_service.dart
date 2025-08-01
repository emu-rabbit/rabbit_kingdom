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

  static Future<void> reactToNews(String id, bool good) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not login");
    }

    final field = good ? 'goods' : 'bads';

    await FirebaseFirestore.instance
        .collection(CollectionNames.news)
        .doc(id)
        .update({
      field: FieldValue.arrayUnion([uid])
    });
  }
}