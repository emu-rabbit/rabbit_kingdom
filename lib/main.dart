import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/prices_controller.dart';
import 'package:rabbit_kingdom/controllers/records_controller.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/pages/startup_gate.dart';
import 'package:rabbit_kingdom/values/kingdom_tasks.dart';
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
  Get.put(RecordsController());

  // Run app
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      try {
        final c = Get.find<UserController>();
        if (c.user != null) {
          c.triggerTaskComplete(KingdomTaskNames.login);
        }
      } catch (e) {
        //
      }
    }
  }

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
