import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/pages/initialize_page.dart';

import 'controllers/theme_controller.dart';

void main() async {
  // Ensure binding
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(ThemeController());
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
          home: const InitializePage(),
        )
      );
    });
  }
}
