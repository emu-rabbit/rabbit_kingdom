import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/prices_controller.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/pages/startup_gate.dart';
import 'package:rabbit_kingdom/widgets/r_blurred_overlay.dart';

import 'controllers/announce_controller.dart';
import 'controllers/theme_controller.dart';

void main() async {
  // Ensure binding
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(Duration(milliseconds: 150));

  Get.put(ThemeController());
  Get.put(UserController());
  Get.put(AnnounceController());
  Get.put(PricesController());

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
          home: const StartupGate(),
          builder: (context, child) {
            if (child == null) {
              return SizedBox.shrink();
            } else {
              try {
                Get.find<UserController>();
                return Stack(
                  children: [
                    child, // 你的頁面內容
                    const RBlurredOverlay(), // 作為全局疊層，它會一直存在
                  ],
                );
              } catch (e) {
                log(e.toString());
                return child;
              }
            }
          },
        )
      );
    });
  }
}
