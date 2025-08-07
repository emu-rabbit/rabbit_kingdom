import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

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
}