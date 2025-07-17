import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/auth_controller.dart';
import 'package:rabbit_kingdom/pages/home_page.dart';
import 'package:rabbit_kingdom/values/app_themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'controllers/theme_controller.dart';

void main() async {
  // Ensure binding
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Put getx controllers
  Get.put(ThemeController());
  Get.put(AuthController());

  // Run app
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
