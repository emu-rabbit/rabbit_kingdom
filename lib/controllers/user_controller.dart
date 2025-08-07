import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/app_config_controller.dart';
import 'package:rabbit_kingdom/helpers/cloud_functions.dart';
import 'package:rabbit_kingdom/helpers/firestore_updater.dart';
import 'package:rabbit_kingdom/models/app_config.dart';
import 'package:rabbit_kingdom/models/trading_record.dart';
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

  late final _userUpdater = FirestoreUpdater(docRef: _userDocRef);

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

  /// 🪙 直接設定金幣
  Future<void> setCoin(int newCoin) {
    final currentUser = _user.value;
    final docRef = _userDocRef.value;

    if (currentUser == null || docRef == null) {
      throw Exception('尚未載入使用者資訊');
    }

    return _userUpdater.update('budget.coin', newCoin);
  }

  /// 🪙 增加（或扣除）金幣
  Future<void> increaseCoin(int amount) {
    final currentUser = _user.value;
    if (currentUser == null) {
      throw Exception('尚未載入使用者資訊');
    }

    final currentCoin = currentUser.budget.coin;
    final newCoin = currentCoin + amount;

    if (newCoin < 0) {
      throw Exception('金幣不足，無法扣除 ${amount.abs()}');
    }

    return setCoin(newCoin);
  }

  /// 🪙 扣金幣
  Future<void> deductCoin(int amount) async {
    return increaseCoin(-amount);
  }

  /// 💩 直接設定便便數量
  Future<void> setPoop(int newPoop) {
    final currentUser = _user.value;
    final docRef = _userDocRef.value;

    if (currentUser == null || docRef == null) {
      throw Exception('尚未載入使用者資訊');
    }

    return _userUpdater.update('budget.poop', newPoop);
  }

  /// 💩 增加（或扣除）便便
  Future<void> increasePoop(int amount) {
    final currentUser = _user.value;
    if (currentUser == null) {
      throw Exception('尚未載入使用者資訊');
    }

    final currentPoop = currentUser.budget.poop;
    final newPoop = currentPoop + amount;

    if (newPoop < 0) {
      throw Exception('精華數量不足，無法扣除 ${amount.abs()} ');
    }

    return setPoop(newPoop);
  }

  /// 💩 扣便便
  Future<void> deductPoop(int amount) async {
    return increasePoop(-amount);
  }

  /// 🪙 直接設定經驗值
  Future<void> setExp(int newExp) async {
    final currentUser = _user.value;
    final docRef = _userDocRef.value;

    if (currentUser == null || docRef == null) {
      throw Exception('尚未載入使用者資訊');
    }

    return _userUpdater.update('exp', newExp);
  }

  /// 🪙 增加（或扣除）經驗值
  Future<void> increaseExp(int amount) async {
    final currentUser = _user.value;
    if (currentUser == null) {
      throw Exception('尚未載入使用者資訊');
    }

    final currentExp = currentUser.exp.raw;
    int newExp = currentExp + amount;

    if (newExp < 0) {
      newExp = 0;
    }

    return setExp(newExp);
  }

  Future<void> applyTradingRecord(TradingRecord record) async {
    final currentUser = _user.value;
    if (currentUser == null) {
      throw Exception('尚未載入使用者資訊');
    }
    final newNote = currentUser.note.applyRecord(record);
    if (_userDocRef.value == null) {
      throw Exception('尚未載入使用者資訊');
    }
    return _userDocRef.value!.update({
      'note': newNote.toJson()
    });
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

  Future<void> makeTrade(TradingRecord record) async {
    if (record.type == TradingType.buy) {
      await deductPoop(record.amount);
      await increaseCoin(record.price * record.amount);
    } else {
      await deductCoin(record.price * record.amount);
      await increasePoop(record.amount);
    }
    await applyTradingRecord(record);
    await FirebaseFirestore
      .instance
      .collection(CollectionNames.tradings)
      .add(record.toJson());
    return triggerTaskComplete(KingdomTaskNames.trade);
  }

  Future<void> increaseAdCount() async {
    final user = _user.value;
    final docRef = _userDocRef.value;

    if (user == null || docRef == null) return;

    return docRef.update({
      'ad.count': user.ad.count + 1
    });
  }
}
