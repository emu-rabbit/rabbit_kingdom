import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  final themeMode = ThemeMode.system.obs;

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
  }
}
