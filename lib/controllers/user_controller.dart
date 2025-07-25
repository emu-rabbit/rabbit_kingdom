import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/widgets/r_task_compelete.dart';

import '../helpers/collection_names.dart';
import '../models/kingdom_user.dart';
import '../values/consts.dart';
import '../values/kingdom_tasks.dart';
import '../values/prices.dart';

class UserController extends GetxController {
  final _user = Rxn<KingdomUser>();
  KingdomUser? get user => _user.value;

  final _userDocRef = Rxn<DocumentReference<Map<String, dynamic>>>();
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;

  Future<void> initUser(User firebaseUser) async {
    final uid = firebaseUser.uid;
    final displayName = firebaseUser.displayName == null || firebaseUser.displayName!.isEmpty
        ? Consts.defaultUserName
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
      bool needsUpdate = false;

      expectedData.forEach((key, value) {
        if (!data.containsKey(key)) {
          data[key] = value;
          needsUpdate = true;
        }
      });

      if (needsUpdate) {
        await docRef.update(data);
      }
    } else {
      final newUser = KingdomUser.newUser(displayName, email);
      await docRef.set(newUser.toJson());
      _user.value = newUser;
    }

    // 監聽 Firestore
    _userStream = docRef.snapshots();
    _userStream!.listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final newUser = KingdomUser.fromJson(snapshot.data()!);
        _user.value = newUser;
        update();
      }
    });
  }

  /// 🪙 扣金幣
  Future<void> deductCoin(int amount) async {
    final currentUser = _user.value;
    final docRef = _userDocRef.value;

    if (currentUser == null || docRef == null) {
      throw Exception('尚未載入使用者資訊');
    }

    final currentCoin = currentUser.budget.coin;

    if (currentCoin < amount) {
      throw Exception('金幣不足，無法扣除 $amount');
    }

    await docRef.update({
      'budget.coin': FieldValue.increment(-amount),
    });
  }

  /// 修改名字（可收費）
  Future<void> changeName(String newName, bool isFirstTime) async {
    final docRef = _userDocRef.value;
    if (docRef == null) {
      throw Exception('尚未載入使用者資訊');
    }

    if (isFirstTime) {
      try {
        await deductCoin(Prices.modifyName);
      } catch (_) {
        throw Exception('修改名稱失敗，金幣不足');
      }
    }

    await docRef.update({
      'name': newName,
    });
  }

  Future<void> triggerTaskComplete(KingdomTaskNames name) async {
    final user = this.user;
    final docRef = _userDocRef.value;

    if (user == null || docRef == null) return;

    // 1. 取得任務資料 (這裡的 taskData.completed 會是根據 get taskData 的新邏輯計算出來的)
    final taskData = user.taskData[name];
    if (taskData == null) return;

    // 檢查是否已達上限 (此檢查現在會基於 get taskData 的正確計算)
    if (taskData.completed >= taskData.limit) return;

    // 2. 清理舊紀錄 - 調整清理的起始點
    final nowTaiwanTime = DateTime.now().toUtc().add(const Duration(hours: 8)); // 當前台灣時間

    // 計算「今天的有效起始時間」，也就是最近的早上8點
    // 這個邏輯必須與 get taskData 中的 todayEffectiveStart 完全一致
    final DateTime todayEffectiveStartForCleanup;
    if (nowTaiwanTime.hour < 8) {
      todayEffectiveStartForCleanup = DateTime(nowTaiwanTime.year, nowTaiwanTime.month, nowTaiwanTime.day - 1, 8); // 前一天早上8點
    } else {
      todayEffectiveStartForCleanup = DateTime(nowTaiwanTime.year, nowTaiwanTime.month, nowTaiwanTime.day, 8); // 當天早上8點
    }

    final oldList = List<DateTime>.from(user.records.record[name] ?? []);
    final newList = oldList
      ..removeWhere((dt) => dt.toUtc().add(const Duration(hours: 8)).isBefore(todayEffectiveStartForCleanup))
      ..add(DateTime.now()); // 使用 UTC 儲存新的完成紀錄

    // 3. 計算新經驗值與兔兔幣
    final newExp = user.exp.raw + taskData.expReward;
    final newCoin = user.budget.coin + taskData.coinReward;

    // 4. 一次更新 Firestore
    await docRef.update({
      'records.${name.name}': newList,
      'exp': newExp,
      'budget.coin': newCoin,
    });

    RTaskComplete.show(name);
  }
}
