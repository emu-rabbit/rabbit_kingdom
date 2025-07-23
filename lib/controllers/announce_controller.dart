import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

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
    if (_announcementRef == null) return;

    final newHeart = AnnounceHeart.create();
    final heartJson = newHeart.toJson();

    await _announcementRef!.update({
      'hearts': FieldValue.arrayUnion([heartJson]),
    }).then((_) {
      update();
    });
  }

  /// 💬 發表一則留言
  Future<void> publishComment(String message) async {
    if (_announcementRef == null) return;

    // 建立新的留言
    final newComment = AnnounceComment.create(message);
    final commentJson = newComment.toJson();

    // 寫入 Firestore 的 comments 陣列
    await _announcementRef!.update({
      'comments': FieldValue.arrayUnion([commentJson]),
    }).then((_) {
      update();
    });
  }

  @override
  void onClose() {
    _collectionListener?.cancel();
    _documentListener?.cancel();
    super.onClose();
  }
}
