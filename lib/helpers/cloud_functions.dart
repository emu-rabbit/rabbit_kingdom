import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:rabbit_kingdom/values/kingdom_tasks.dart';

class CloudFunctions {
  static FirebaseFunctions get functions => FirebaseFunctions.instanceFor(region: "asia-east1");
  static HttpsCallable get userAction => functions.httpsCallable("onUserAction");
  static String get env => kDebugMode ? 'debug': 'production';
  
  static Future<void> modifyName(String name) async {
    await userAction.call({
      'env': env,
      'action': 'MODIFY_NAME',
      'payload': {
        'name': name
      }
    });
  }

  static Future<void> drink() async {
    await userAction.call({
      'env': env,
      'action': 'DRINK'
    });
  }

  static Future<void> completeTask(KingdomTaskNames task) async {
    await userAction.call({
      'env': env,
      'action': "COMPLETE_TASK",
      'payload': {
        'taskName': task.name
      }
    });
  }

  static Future<void> commentAnnounce(String id, String comment) async {
    await userAction.call({
      'env': env,
      'action': "COMMENT_ANNOUNCE",
      'payload': {
        'id': id,
        'comment': comment
      }
    });
  }

  static Future<void> heartAnnounce(String id) async {
    await userAction.call({
      'env': env,
      'action': "HEART_ANNOUNCE",
      'payload': {
        'id': id
      }
    });
  }
}