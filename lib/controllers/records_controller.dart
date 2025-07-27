import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/models/kingdom_records.dart';

import '../helpers/collection_names.dart';

class RecordsController extends GetxController {
  final _records = Rxn<KingdomRecords>();
  KingdomRecords? get record => _records.value;

  final _recordDocRef = Rxn<DocumentReference<Map<String, dynamic>>>();
  StreamSubscription<DocumentSnapshot>? _recordsListener;

  Future<void> initRecords(User firebaseUser) async {
    final uid = firebaseUser.uid;
    _recordDocRef.value = FirebaseFirestore.instance.collection(CollectionNames.records).doc(uid);
    final docSnapshot = await _recordDocRef.value!.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      _records.value = kingdomRecordsFromJson(data);
    } else {
      await _recordDocRef.value!.set({});
      _records.value = {};
    }
    update();

    // 監聽 Firestore
    _recordsListener = _recordDocRef.value!.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final newRecords = kingdomRecordsFromJson(snapshot.data());
        _records.value = newRecords;
        update();
      }
    });
  }

  void onLogout() {
    _recordDocRef.value = null;
    _recordsListener?.cancel();
    _recordsListener = null;
    update();
  }

  @override
  void onClose() {
    onLogout();
    super.onClose();
  }

  Future<void> setRecord({
    required RecordName name,
    required RecordRound round,
    required double value
  }) async {
    if (_recordDocRef.value == null) return;

    await _recordDocRef.value!.set({
      name.name: {
        round.toKey(): {'value': value}
      }
    }, SetOptions(merge: true));
  }

  Future<void> increaseRecord({
    required RecordName name,
    required RecordRound round,
    double value = 1
  }) async {
    final currentValue = _records.value?[name]?[round]?.value ?? 0;
    final newValue = currentValue + value;

    await setRecord(name: name, round: round, value: newValue);
  }
}