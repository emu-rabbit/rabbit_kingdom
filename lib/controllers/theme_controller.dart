import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final themeMode = ThemeMode.light.obs;

  void setThemeMode(ThemeMode mode) {
    if (mode != themeMode.value) {
      themeMode.value = mode;
      update();
    }
  }
}
