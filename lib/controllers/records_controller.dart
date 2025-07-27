import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/models/kingdom_records.dart';

import '../helpers/collection_names.dart';

class RecordsController extends GetxController {
  final _records = Rxn<KingdomRecords>();
  KingdomRecords? get record => _records.value;

  StreamSubscription<DocumentSnapshot>? _recordsListener;

  Future<void> initRecords(User firebaseUser) async {
    final uid = firebaseUser.uid;
    final docRef = FirebaseFirestore.instance.collection(CollectionNames.records).doc(uid);
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      _records.value = kingdomRecordsFromJson(data);
    } else {
      await docRef.set({});
      _records.value = {};
    }
    update();

    // 監聽 Firestore
    _recordsListener = docRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final newRecords = kingdomRecordsFromJson(snapshot.data());
        _records.value = newRecords;
        update();
      }
    });
  }

  void onLogout() {
    _recordsListener?.cancel();
    _recordsListener = null;
    update();
  }

  @override
  void onClose() {
    onLogout();
    super.onClose();
  }
}