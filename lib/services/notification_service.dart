import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../helpers/collection_names.dart';
import '../widgets/r_snack_bar.dart'; // for debugPrint

class NotificationService {
  static const _permissionKey = 'fcm_permission_status'; // 0 = 未詢問, 1 = 同意, -1 = 拒絕

  /// 請求通知權限，會根據目前狀態更新 SharedPreferences，避免重複詢問 UI
  static Future<void> requestPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 先取得目前系統的權限狀態
      final currentSettings = await FirebaseMessaging.instance.getNotificationSettings();

      AuthorizationStatus status = currentSettings.authorizationStatus;

      // 只有在尚未決定時，才觸發請求 UI
      if (status == AuthorizationStatus.notDetermined) {
        final result = await FirebaseMessaging.instance.requestPermission();
        status = result.authorizationStatus;
      }

      // 根據實際結果更新 SharedPreferences
      if (status == AuthorizationStatus.authorized) {
        await prefs.setInt(_permissionKey, 1); // 同意
      } else if (status == AuthorizationStatus.denied ||
          status == AuthorizationStatus.provisional) {
        await prefs.setInt(_permissionKey, -1); // 拒絕或暫時授權
      } else {
        await prefs.setInt(_permissionKey, 0); // 其他狀況當作未決定
      }
    } catch (e) {
      debugPrint("🔕 通知權限處理失敗：$e");
      // 默默失敗，不影響主功能
    }
  }

  /// 初始化通知功能，只有使用者授權時才會執行
  static Future<void> initialize(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final status = prefs.getInt(_permissionKey);

      if (status == -1) return; // 沒授權就不做初始化

      final token = await FirebaseMessaging.instance.getToken(
        vapidKey: 'BHFqe6POSJHaHNfqiSkX4h7TZNB439fGwRMvxTmi8MYNu2SQpya45Akoxn6gwP4GVFjGDiVBNQpaNxeH9oWzQYY'
      );
      if (token == null) return;
      FirebaseMessaging.onMessage.listen((message) {
        final notification = message.notification;
        RSnackBar.show(
            notification?.title ?? "收到通知",
            notification?.body ?? "訊息遺失了QQ"
        );
      });

      await FirebaseFirestore.instance
          .collection(CollectionNames.fcm)
          .doc(uid)
          .set({'token': token});
    } catch (e) {
      debugPrint("🔕 通知初始化失敗：$e");
      // 默默失敗不影響主流程
    }
  }
}
