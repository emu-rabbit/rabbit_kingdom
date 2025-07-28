import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/models/kingdom_user.dart';
import 'package:rabbit_kingdom/models/poop_prices.dart';

import '../helpers/collection_names.dart';
import '../models/kingdom_announcement.dart';

class EmpireService {
  EmpireService._();


  static Future<List<UnknownUserData>> getUnknownUsers() async {
    final userController = Get.find<UserController>();
    if (userController.user?.group != KingdomUserGroup.empire) return [];

    final querySnapshot = await FirebaseFirestore.instance
        .collection(CollectionNames.user)
        .where('group', isEqualTo: 'unknown')
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return UnknownUserData(
        uid: doc.id,
        name: data['name'] ?? '<blank>',
        email: data['email'] ?? '<blank>',
      );
    }).toList();
  }

  static Future<void> authUnknownUser(UnknownUserData user, KingdomUserGroup group) async {
    final userController = Get.find<UserController>();
    if (userController.user?.group != KingdomUserGroup.empire) return;

    final docRef = FirebaseFirestore.instance
        .collection(CollectionNames.user)
        .doc(user.uid);

    final snapshot = await docRef.get();
    if (!snapshot.exists) {
      throw Exception("找不到使用者 ${user.uid}");
    }

    await docRef.update({
      'group': group.name,
    });
  }

  static Future<void> publishNewAnnounce(KingdomAnnouncement announce) async {
    final userController = Get.find<UserController>();
    if (userController.user?.group != KingdomUserGroup.empire) return;

    final data = announce.toJson();
    await FirebaseFirestore.instance
        .collection(CollectionNames.announce)
        .add(data);
  }

  // static Future<void> publishNewPrices(PoopPrices prices) async {
  //   final userController = Get.find<UserController>();
  //   if (userController.user?.group != KingdomUserGroup.empire) return;
  //
  //   final data = prices.toJson();
  //   await FirebaseFirestore.instance
  //     .collection(CollectionNames.prices)
  //     .add(data);
  // }
}

class UnknownUserData {
  final String email;
  final String name;
  final String uid;

  const UnknownUserData({ required this.email, required this.name, required this.uid });
}