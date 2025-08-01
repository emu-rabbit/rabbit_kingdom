import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/records_controller.dart';
import 'package:rabbit_kingdom/helpers/firestore_updater.dart';
import 'package:rabbit_kingdom/models/kingdom_records.dart';
import 'package:rabbit_kingdom/models/trading_record.dart';
import 'package:rabbit_kingdom/widgets/r_task_compelete.dart';

import '../helpers/collection_names.dart';
import '../models/kingdom_user.dart';
import '../values/consts.dart';
import '../values/kingdom_tasks.dart';
import '../values/prices.dart';

class UserController extends GetxController {
  final _user = Rxn<KingdomUser>();
  Rxn<KingdomUser> get userRx => _user;
  KingdomUser? get user => _user.value;

  final _userDocRef = Rxn<DocumentReference<Map<String, dynamic>>>();
  StreamSubscription<DocumentSnapshot>? _userListener;

  late final _userUpdater = FirestoreUpdater(docRef: _userDocRef);

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

    final f1 = _userUpdater.update('budget.coin', newCoin);

    final recordsController = Get.find<RecordsController>();
    final f2 = recordsController.setRecord(
      name: RecordName.coin,
      round: AllRound(),
      value: newCoin.toDouble(),
    );
    return Future.wait([f1, f2]).then((_){});
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

    final f1 = setCoin(newCoin);
    final recordsController = Get.find<RecordsController>();
    final f2 = recordsController.increaseRecord(
      name: RecordName.coin,
      round: MonthlyRound.now(),
      value: amount.toDouble(),
    );
    return Future.wait([f1, f2]).then((_){});
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

    final f1 = _userUpdater.update('budget.poop', newPoop);

    final recordsController = Get.find<RecordsController>();
    final f2 = recordsController.setRecord(
      name: RecordName.poop,
      round: AllRound(),
      value: newPoop.toDouble(),
    );

    return Future.wait([f1, f2]).then((_) {});
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

    final f1 = setPoop(newPoop);
    final recordsController = Get.find<RecordsController>();
    final f2 = recordsController.increaseRecord(
      name: RecordName.poop,
      round: MonthlyRound.now(),
      value: amount.toDouble(),
    );

    return Future.wait([f1, f2]).then((_) {});
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

    final f1 = _userUpdater.update('exp', newExp);

    final recordsController = Get.find<RecordsController>();
    final f2 = recordsController.setRecord(
      name: RecordName.exp,
      round: AllRound(),
      value: newExp.toDouble(),
    );
    return Future.wait([f1, f2]).then((_){});
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

    final f1 = setExp(newExp);
    final recordsController = Get.find<RecordsController>();
    final f2 = recordsController.increaseRecord(
      name: RecordName.exp,
      round: MonthlyRound.now(),
      value: amount.toDouble(),
    );
    return Future.wait([f1, f2]).then((_){});
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
    await _userDocRef.value!.update({
      'note': newNote.toJson()
    });
    final recordsController = Get.find<RecordsController>();
    final f1 = recordsController.increaseRecord(
      name: RecordName.tradingVolume, round: AllRound(), value: record.amount.toDouble()
    );
    final f2 = recordsController.increaseRecord(
      name: RecordName.tradingVolume, round: MonthlyRound.now(), value: record.amount.toDouble()
    );
    final f3 = recordsController.setRecord(
        name: record.type == TradingType.buy ? RecordName.sellAvg : RecordName.buyAvg,
        round: AllRound(),
        value: record.type == TradingType.buy ? newNote.sellAverage! : newNote.buyAverage!
    );
    final f4 = recordsController.setRecord(
        name: record.type == TradingType.buy ? RecordName.sellAvg : RecordName.buyAvg,
        round: MonthlyRound.now(),
        value: record.type == TradingType.buy ? newNote.sellAverage! : newNote.buyAverage!
    );
    return Future.wait([f1, f2, f3, f4]).then((_){});
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

    return _userUpdater.update('name', newName);
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

    // 3. 更新 Firestore
    final f1 = _userUpdater.update('records.${name.name}', newList);
    final f2 = increaseExp(taskData.expReward);
    final f3 = increaseCoin(taskData.coinReward);
    await Future.wait([f1, f2, f3]);

    RTaskComplete.show(name);
  }

  Future<void> drink() async {
    final user = _user.value;
    final docRef = _userDocRef.value;

    if (user == null || docRef == null) return;

    await deductCoin(Prices.drink);

    final now = DateTime.now();
    final oldDrinks = user.drinks;

    final bool fullyDecayed =
        now.difference(oldDrinks.lastAt) > Consts.drinkFullyDecay;

    // 更新 firestore 上的資料
    final f1 = _userUpdater.updateJson({
      'drinks': {
        'count': fullyDecayed ? 1 : oldDrinks.count + 1,
        'lastAt': now,
      }
    });
    final f2 = triggerTaskComplete(KingdomTaskNames.drink);

    final recordsController = Get.find<RecordsController>();
    final f3 = recordsController.increaseRecord(name: RecordName.drink, round: AllRound());
    final f4 = recordsController.increaseRecord(name: RecordName.drink, round: MonthlyRound.now());

    return Future.wait([f1, f2, f3, f4]).then((_){});
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
}
