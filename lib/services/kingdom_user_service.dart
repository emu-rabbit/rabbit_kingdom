import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rabbit_kingdom/helpers/collection_names.dart';
import 'package:rabbit_kingdom/models/kingdom_announcement.dart';
import 'package:rabbit_kingdom/models/poop_prices.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';

class KingdomUserService {
  static Future<List<KingdomAnnouncement>> getRecentAnnounce() async {
    try {
      final result = await FirebaseFirestore
        .instance
        .collection(CollectionNames.announce)
        .orderBy('createAt', descending: true)
        .limit(10)
        .get();
      return result
        .docs
        .map((doc) => KingdomAnnouncement.fromJson(doc.data()))
        .toList();
    } catch (e) {
      RSnackBar.error("抓取失敗", e.toString());
      return [];
    }
  }

  static Future<List<PoopPrices>> getRecentPrices() async {
    try {
      final result = await FirebaseFirestore
        .instance
        .collection(CollectionNames.prices)
        .orderBy('createAt', descending: true)
        .limit(20)
        .get();
      return result
        .docs
        .map((doc) => PoopPrices.fromJson(doc.data()))
        .toList();
    } catch (e) {
      RSnackBar.error("抓取失敗", e.toString());
      return [];
    }
  }
}