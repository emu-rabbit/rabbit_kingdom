import 'dart:developer';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rabbit_kingdom/helpers/collection_names.dart';
import '../models/kingdom_user.dart';

class UserController extends GetxController {
  final _user = Rxn<KingdomUser>();
  KingdomUser? get user => _user.value;

  final _userDocRef = Rxn<DocumentReference<Map<String, dynamic>>>();
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _userStream;

  Future<void> initUser(User firebaseUser) async {
    final uid = firebaseUser.uid;
    final displayName = firebaseUser.displayName == null || firebaseUser.displayName!.isEmpty ? '迷途旅人' : firebaseUser.displayName!;
    final docRef = FirebaseFirestore.instance.collection(CollectionNames.user).doc(uid);
    _userDocRef.value = docRef;

    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // 檢查是否有缺少欄位
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
      // 建立新使用者
      final newUser = KingdomUser.newUser(displayName);
      await docRef.set(newUser.toJson());
      _user.value = newUser;
    }

    // 綁定 Firestore 實時監聽
    _userStream = docRef.snapshots();
    _userStream!.listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final newUser = KingdomUser.fromJson(snapshot.data()!);
        _user.value = newUser;
        update();
      }
    });
  }
}
