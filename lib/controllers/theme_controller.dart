import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const _prefKey = 'theme_mode';

  final themeMode = ThemeMode.light.obs;
  Brightness get brightness {
    if (themeMode.value == ThemeMode.system) {
      return MediaQuery.platformBrightnessOf(Get.context!);
    }
    return themeMode.value == ThemeMode.dark ? Brightness.dark : Brightness.light;
  }

  /// 初始化時讀取儲存的主題設定
  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();
  }

  /// 設定主題模式，並寫入儲存
  void setThemeMode(ThemeMode mode) async {
    if (mode != themeMode.value) {
      themeMode.value = mode;
      update();
      await _saveThemeToPrefs(mode);
    }
  }

  /// 儲存主題到 SharedPreferences
  Future<void> _saveThemeToPrefs(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, mode.name); // 用 mode.name 儲存 'light' / 'dark' / 'system'
  }

  /// 從 SharedPreferences 載入主題
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final storedMode = prefs.getString(_prefKey);
    if (storedMode != null) {
      switch (storedMode) {
        case 'light':
          themeMode.value = ThemeMode.light;
          break;
        case 'dark':
          themeMode.value = ThemeMode.dark;
          break;
        case 'system':
          themeMode.value = ThemeMode.system;
          break;
      }
      update();
    }
  }
}
