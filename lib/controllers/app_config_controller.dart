import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/models/app_config.dart';

import '../helpers/collection_names.dart';

class AppConfigController extends GetxController {
  final _config = Rxn<AppConfig>();
  AppConfig? get config => _config.value;

  final _configDocRef = Rxn<DocumentReference<Map<String, dynamic>>>();
  StreamSubscription<DocumentSnapshot>? _configListener;

  Future<void> initConfig() async {
    final docRef = FirebaseFirestore.instance.collection(CollectionNames.config).doc("main");
    _configDocRef.value = docRef;

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      final configFromFirestore = AppConfig.fromJson(data);
      _config.value = configFromFirestore;
    }

    // 監聽 Firestore
    _configListener = docRef.snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final newConfig = AppConfig.fromJson(snapshot.data()!);
        _config.value = newConfig;
        update();
      }
    });
  }

  @override
  void onClose() {
    if (_configListener != null) {
      _configListener!.cancel();
    }
    super.onClose();
  }
}
