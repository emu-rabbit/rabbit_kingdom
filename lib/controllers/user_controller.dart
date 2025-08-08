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
    final docRef = FirebaseFirestore.instance.collection(CollectionNames.user).doc(uid);
    _userDocRef.value = docRef;

    // 1. 創建一個 Completer 來等待第一筆有效資料
    final Completer<void> userLoadedCompleter = Completer();

    // 2. 建立監聽器，這是唯一的資料來源
    _userListener = docRef.snapshots().listen((snapshot) async {
      if (snapshot.exists && snapshot.data() != null) {
        // 🌟 情況 A: 文件存在，解析資料
        final newUser = KingdomUser.fromJson(snapshot.data()!);
        _user.value = newUser;
        update();

        // 首次載入完成，完成 Completer
        if (!userLoadedCompleter.isCompleted) {
          userLoadedCompleter.complete();
        }
      } else {
        // 🌟 情況 B: 文件不存在，呼叫 Cloud Function 創建
        // 這裡只在第一次監聽到文件不存在時執行
        if (!userLoadedCompleter.isCompleted) {
          try {
            await CloudFunctions.createUser();
          } catch (e) {
            // 如果創建失敗，讓 Completer 拋出錯誤
            if (!userLoadedCompleter.isCompleted) {
              userLoadedCompleter.completeError(Exception("Create user failed"));
            }
          }
        }
      }
    });

    // 3. 等待第一筆資料載入，避免後續程式碼抓不到資料
    await userLoadedCompleter.future;
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
