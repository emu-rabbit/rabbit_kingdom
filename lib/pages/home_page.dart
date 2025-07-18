import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';
import '../controllers/auth_controller.dart';
import '../controllers/theme_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final authController = Get.find<AuthController>();

    return ColoredBox(
      color: AppColors.surface,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RText.bodyLarge('目前是：${themeController.themeMode.value == ThemeMode.light ? '☀️ 明亮主題' : '🌙 黑暗主題'}'),
              const SizedBox(height: 24),
              RText.bodyLarge('UID ${authController.firebaseUser.value?.uid}'),
              RText.bodyLarge('Name ${authController.firebaseUser.value?.displayName}'),
              RText.bodyLarge('Email ${authController.firebaseUser.value?.email}'),

              // RButton.primary(
              //   onPressed: themeController.toggleTheme,
              //   text: '切換(主要按鈕)',
              // ),
              // const SizedBox(height: 16),
              // RButton.secondary(
              //   onPressed: themeController.toggleTheme,
              //   text: '切換(次要按鈕)',
              // ),
              // const SizedBox(height: 16),
              // RButton.surface(
              //   onPressed: themeController.toggleTheme,
              //   text: '切換(平淡按鈕)',
              // ),
              // const SizedBox(height: 16),
              // RButton.danger(
              //   onPressed: themeController.toggleTheme,
              //   text: '切換(危險按鈕)',
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
