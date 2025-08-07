import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/helpers/cloud_functions.dart';
import 'package:rabbit_kingdom/values/kingdom_tasks.dart';

import '../helpers/collection_names.dart';
import '../models/kingdom_announcement.dart';

class AnnounceController extends GetxController {
  final _announcement = Rxn<KingdomAnnouncement>();
  KingdomAnnouncement? get announcement => _announcement.value;

  DocumentReference? _announcementRef;

  StreamSubscription<QuerySnapshot>? _collectionListener;
  StreamSubscription<DocumentSnapshot>? _documentListener;

  Future<void> initAnnounce() async {
    _collectionListener?.cancel();
    _collectionListener = FirebaseFirestore.instance
        .collection(CollectionNames.announce)
        .orderBy('createAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final latestDoc = querySnapshot.docs.first;

        // ✅ 儲存該筆文件的 reference
        _announcementRef = latestDoc.reference;

        _announcement.value = KingdomAnnouncement.fromJson(latestDoc.data());
        update();

        _documentListener?.cancel();
        _documentListener = latestDoc.reference.snapshots().listen((docSnapshot) {
          if (docSnapshot.exists) {
            _announcement.value = KingdomAnnouncement.fromJson(docSnapshot.data() ?? {});
            update();
          }
        });
      }
    });
  }

  /// 💖 在目前公告中標記一個愛心
  Future<void> markHeart() async {
    if (_announcementRef == null) throw Exception("Announce not exist");

    await CloudFunctions.heartAnnounce(_announcementRef!.id)
      .then((_) async {
        final c = Get.find<UserController>();
        await c.triggerTaskComplete(KingdomTaskNames.heart);
      }).then((_) {
        update();
      });
  }

  /// 💬 發表一則留言
  Future<void> publishComment(String message) async {
    if (_announcementRef == null) throw Exception("Announce not exist");

    await CloudFunctions.commentAnnounce(_announcementRef!.id, message)
      .then((_) async {
        final c = Get.find<UserController>();
        await c.triggerTaskComplete(KingdomTaskNames.comment);
      }).then((_) {
        update();
      });
  }

  void onLogout() {
    _collectionListener?.cancel();
    _documentListener?.cancel();
    _collectionListener = null;
    _documentListener = null;
    update();
  }

  @override
  void onClose() {
    onLogout();
    super.onClose();
  }
}
