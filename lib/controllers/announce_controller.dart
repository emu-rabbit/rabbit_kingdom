import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../helpers/collection_names.dart';
import '../models/kingdom_announcement.dart';

class AnnounceController extends GetxController {
  final _announcement = Rxn<KingdomAnnouncement>();
  KingdomAnnouncement? get announcement => _announcement.value;

  StreamSubscription<QuerySnapshot>? _collectionListener;
  StreamSubscription<DocumentSnapshot>? _documentListener;

  Future<void> initAnnounce() async {
    // 先監聽集合中最新的一筆公告
    _collectionListener?.cancel();
    _collectionListener = FirebaseFirestore.instance
        .collection(CollectionNames.announce)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        final latestDoc = querySnapshot.docs.first;

        // 將最新資料設為目前狀態
        _announcement.value = KingdomAnnouncement.fromJson(latestDoc.data());

        // 🔄 若已有監聽文件，取消舊的
        _documentListener?.cancel();

        // 監聽這一份「最新公告」文件內容變更
        _documentListener = latestDoc.reference.snapshots().listen((docSnapshot) {
          if (docSnapshot.exists) {
            _announcement.value = KingdomAnnouncement.fromJson(docSnapshot.data() ?? {});
          }
        });
      }
    });
  }

  @override
  void onClose() {
    _collectionListener?.cancel();
    _documentListener?.cancel();
    super.onClose();
  }
}
