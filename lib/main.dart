import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/announce_controller.dart';
import 'package:rabbit_kingdom/controllers/auth_controller.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/pages/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'controllers/theme_controller.dart';

void main() async {
  // Ensure binding
  WidgetsFlutterBinding.ensureInitialized();

  // Lock screen orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Initialize firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await FirebaseMessaging.instance.requestPermission();
  } catch(e) {
    log("Message failed to request permission");
  }

  // Put getx controllers
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(UserController());
  Get.put(AnnounceController());

  // Run app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();
    return Obx(() {
      return GestureDetector(
        behavior: HitTestBehavior.translucent, // 這個很重要！
        onTap: () {
          FocusScope.of(context).unfocus(); // 收起鍵盤
        },
        child: GetMaterialApp(
          title: '兔兔王國',
          themeMode: controller.themeMode.value,
          home: const LoginPage(),
        )
      );
    });
  }
}
