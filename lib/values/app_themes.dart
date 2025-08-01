import 'package:flutter/material.dart';

class AppThemes {
  static final light = const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFFF95B7), // 草莓奶霜
    onPrimary: Color(0xFF5C0011), // 深莓紅字體
    surface: Color(0xFFFFF5F9), // 奶霜底色
    onSurface: Color(0xFF5E325E), // 櫻花棕
    surfaceContainerLow: Color(0xFFFFEAEF), // 淡粉卡片
    surfaceContainerHigh: Color(0xFFFFD3E3), // 飽和粉容器
    secondary: Color(0xFFFFC878), // 杏橙糖果
    onSecondary: Color(0xFF3D2A00), // 巧克力橙
    error: Color(0xFFEF5350), // 櫻桃紅
    onError: Color(0xFFFFFFFF),
    outline: Color(0xFFEECFD7), // 淡粉邊線
    // background: Color(0xFFFFFFFF), // 已棄用
    // onBackground: Color(0xFF000000),
  );
  static final lightExtra = const ExtraColors(
    green: Color(0xFF11A616),
    red: Color(0xFFD3251B)
  );

  static final dark = const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFE1B7F2), // 淡紫星雲
    onPrimary: Color(0xFF270033), // 夜幕紫字體
    surface: Color(0xFF1D132A), // 靛紫底色
    onSurface: Color(0xFFEFE3F7), // 星霧白
    surfaceContainerLow: Color(0xFF2C1A40), // 夜雲紫容器
    surfaceContainerHigh: Color(0xFF40255C), // 深夢紫卡片
    secondary: Color(0xFFF1BCA3), // 杏桃白橙
    onSecondary: Color(0xFF4A2B20),
    error: Color(0xFFFF6F91), // 黑莓玫紅
    onError: Color(0xFF3B0012),
    outline: Color(0xFF836B99), // 淺霧紫線條
    // background: Color(0xFF000000), // 已棄用
    // onBackground: Color(0xFFFFFFFF),
  );
  static final darkExtra = const ExtraColors(
      green: Color(0xFF28AA7F),
      red: Color(0xFFDF5827)
  );
}

class ExtraColors {
  final Color green;
  final Color red;
  const ExtraColors({
    required this.green,
    required this.red
  });
}
