import 'dart:developer';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // ← 為了 LinearProgressIndicator
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rabbit_kingdom/controllers/auth_controller.dart';
import 'package:rabbit_kingdom/helpers/ad.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/services/version_service.dart';
import 'package:rabbit_kingdom/widgets/r_layout.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

import '../controllers/announce_controller.dart';
import '../controllers/user_controller.dart';
import '../firebase_options.dart';
import '../services/notification_service.dart';

class InitializePage extends StatelessWidget {
  const InitializePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InitializePageController());

    return RLayout(
      child: Obx(() =>
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "lib/assets/images/sticker_happy.png",
                width: mainImageSize(),
                height: mainImageSize(),
              ),
              RSpace(),
              RText.displaySmall("兔兔王國正在努力載入中..."),
              RSpace(type: RSpaceType.large,),
              SizedBox(
                width: vw(80),
                child: LinearProgressIndicator(
                  value: controller.progress.value / 100.0,
                  minHeight: 8,
                  backgroundColor: AppColors.onSurface.withAlpha(100),
                  color: AppColors.onSurface,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
              ),
              RSpace(),
              RText.bodyMedium("${controller.progress.value}%"),
            ],
          ),
        ),
      )
    );
  }
}

class InitializePageController extends GetxController {
  final progress = 0.obs;

  void setProgress(int percent) {
    if (percent < 0) percent = 0;
    if (percent > 100) percent = 100;
    progress.value = percent;
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    try {
      setProgress(5);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      setProgress(10);
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      if (!kIsWeb) FirebaseCrashlytics.instance.setCustomKey('platform', Platform.operatingSystem);

      setProgress(20);
      try {
        await FirebaseAppCheck.instance.activate(
            androidProvider: !kDebugMode ? AndroidProvider.playIntegrity : AndroidProvider.debug,
            appleProvider: !kDebugMode ? AppleProvider.appAttest : AppleProvider.debug,
            webProvider: ReCaptchaV3Provider('6Ld8NJArAAAAAKuha0NZH9GKA83OEjcEWcC2QiUj')
        );
        FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
      } catch(e, stack) {
        FirebaseCrashlytics.instance.recordError(e, stack, reason: "AppCheck activation failed");
      }
      try {
        final token = await FirebaseAppCheck.instance.getToken(kDebugMode ? true : false);
        if (token == null || token.isEmpty) {
          FirebaseCrashlytics.instance.log("AppCheck token is empty");
        } else {
          FirebaseCrashlytics.instance.setCustomKey("appCheck_token_short", token.substring(0, 10));
          FirebaseCrashlytics.instance.log("AppCheck token retrieved successfully");
        }
      } catch (e, stack) {
        FirebaseCrashlytics.instance.recordError(e, stack, reason: "AppCheck token fetch failed");
      }

      setProgress(25);
      if (!kDebugMode) FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

      setProgress(30);
      await VersionService.checkUpdate();

      setProgress(50);
      if (isAdSupported()) {
        await AppTrackingTransparency.requestTrackingAuthorization();
        await MobileAds.instance.initialize();
      }

      setProgress(70);
      await NotificationService.requestPermission();

      setProgress(90);
      Get.put(AuthController(), permanent: true);

      setProgress(100);
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, reason: "InitializePageController failed");
      RSnackBar.error("王國加載失敗", e.toString());
    }
  }
}
