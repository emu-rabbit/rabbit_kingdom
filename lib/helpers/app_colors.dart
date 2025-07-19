// lib/theme/app_colors.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/theme_controller.dart';
import '../values/app_themes.dart';

class AppColors {
  AppColors._();

  /// 快速取得目前 ColorScheme
  static ColorScheme get colorScheme {
    final controller = Get.find<ThemeController>();
    final mode = controller.themeMode.value;

    final brightness = () {
      if (mode == ThemeMode.system) {
        return MediaQuery.platformBrightnessOf(Get.context!);
      }
      return mode == ThemeMode.dark ? Brightness.dark : Brightness.light;
    }();

    return brightness == Brightness.dark
        ? AppThemes.dark
        : AppThemes.light;
  }

  /// 以下是各種色彩 getter（可自行擴充）
  static Color get primary => colorScheme.primary;
  static Color get onPrimary => colorScheme.onPrimary;
  static Color get surface => colorScheme.surface;
  static Color get onSurface => colorScheme.onSurface;
  static Color get surfaceContainerLow => colorScheme.surfaceContainerLow;
  static Color get surfaceContainerHigh => colorScheme.surfaceContainerHigh;
  static Color get secondary => colorScheme.secondary;
  static Color get onSecondary => colorScheme.onSecondary;
  static Color get outline => colorScheme.outline;
  static Color get error => colorScheme.error;
  static Color get onError => colorScheme.onError;
}
