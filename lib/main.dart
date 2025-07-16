import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/pages/home_page.dart';
import 'package:rabbit_kingdom/values/app_themes.dart';

import 'controllers/theme_controller.dart';

void main() {
  Get.put(ThemeController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();
    return Obx(() {
      return GetMaterialApp(
        title: '兔兔精華App',
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: controller.themeMode.value,
        home: const HomePage(),
      );
    });
  }
}
