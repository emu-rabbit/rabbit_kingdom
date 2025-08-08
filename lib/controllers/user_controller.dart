import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/app_config_controller.dart';
import 'package:rabbit_kingdom/helpers/cloud_functions.dart';
import 'package:rabbit_kingdom/helpers/firestore_updater.dart';
import 'package:rabbit_kingdom/widgets/r_task_compelete.dart';

import '../helpers/collection_names.dart';
import '../helpers/json.dart';
import '../models/kingdom_user.dart';
import '../values/kingdom_tasks.dart';

class UserController extends GetxController {
  final _user = Rxn<KingdomUser>();
  Rxn<KingdomUser> get userRx => _user;
  KingdomUser? get user => _user.value;

  final _userDocRef = Rxn<DocumentReference<Map<String, dynamic>>>();
  StreamSubscription<DocumentSnapshot>? _userListener;

  Future<void> initUser(User firebaseUser) async {
    final uid = firebaseUser.uid;
    final config = Get.find<AppConfigController>().config;
    final displayName = firebaseUser.displayName == null || firebaseUser.displayName!.isEmpty
        ? (config?.defaultName ?? "未命名")
        : firebaseUser.displayName!;
    final email = firebaseUser.email ?? '';
    final docRef = FirebaseFirestore.instance.collection(CollectionNames.user).doc(uid);
    _userDocRef.value = docRef;

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data()!;
      final userFromFirestore = KingdomUser.fromJson(data);
      _user.value = userFromFirestore;

      final expectedData = userFromFirestore.toJson();
      final bool needsUpdate = mergeMissingFields(data, expectedData);

      if (needsUpdate) {
        await docRef.update(data);
      }
    } else {
      final newUser = KingdomUser.newUser(displayName, email);
      await docRef.set(newUser.toJson());
      _user.value = newUser;
    }

    // 監聽 Firestore
    _userListener = docRef.snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final newUser = KingdomUser.fromJson(snapshot.data()!);
        _user.value = newUser;
        update();
      }
    });
  }

  void onLogout() {
    if (_user.value != null) {
      _user.value = null;
    }
    if (_userDocRef.value != null) {
      _userDocRef.value = null;
    }
    if (_userListener != null) {
      _userListener!.cancel();
      _userListener = null;
    }
    update();
  }

  @override
  void onClose() {
    onLogout();
    super.onClose();
  }


  Future<void> triggerTaskComplete(KingdomTaskNames name) async {
    final user = this.user;
    final docRef = _userDocRef.value;

    if (user == null || docRef == null) return;
    if (user.group == KingdomUserGroup.unknown) return;

    // 1. 取得任務資料 (這裡的 taskData.completed 會是根據 get taskData 的新邏輯計算出來的)
    final taskData = user.taskData[name];
    if (taskData == null) return;

    // 檢查是否已達上限 (此檢查現在會基於 get taskData 的正確計算)
    if (taskData.completed >= taskData.limit) return;

    await CloudFunctions.completeTask(name);

    RTaskComplete.show(name);
  }
}
