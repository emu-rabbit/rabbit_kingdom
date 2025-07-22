import 'package:flutter/material.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';

class AppTextStyle {
  static final double _rootWidth = 411.4285714;
  static double getFromDp(double dp) => vw(dp / _rootWidth * 100);
  
  // 🐰 顯示級別（大招級別的文字）
  static TextStyle displayLarge = TextStyle(
    fontSize: getFromDp(38),
    fontWeight: FontWeight.bold,
    fontFamily: 'JFHuninn',
  );

  static TextStyle displayMedium = TextStyle(
    fontSize: getFromDp(32),
    fontWeight: FontWeight.bold,
    fontFamily: 'JFHuninn',
  );

  static TextStyle displaySmall = TextStyle(
    fontSize: getFromDp(28),
    fontWeight: FontWeight.w600,
    fontFamily: 'JFHuninn',
  );

  // 標題（常見於頁面頂部）
  static TextStyle headlineLarge = TextStyle(
    fontSize: getFromDp(26),
    fontWeight: FontWeight.w600,
    fontFamily: 'JFHuninn',
  );

  static TextStyle headlineMedium = TextStyle(
    fontSize: getFromDp(24),
    fontWeight: FontWeight.w500,
    fontFamily: 'JFHuninn',
  );

  static TextStyle headlineSmall = TextStyle(
    fontSize: getFromDp(20),
    fontWeight: FontWeight.w500,
    fontFamily: 'JFHuninn',
  );

  // 📝 卡片、欄位名稱
  static TextStyle titleLarge = TextStyle(
    fontSize: getFromDp(20),
    fontWeight: FontWeight.w600,
    fontFamily: 'JFHuninn',
  );

  static TextStyle titleMedium = TextStyle(
    fontSize: getFromDp(18),
    fontWeight: FontWeight.w500,
    fontFamily: 'JFHuninn',
  );

  static TextStyle titleSmall = TextStyle(
    fontSize: getFromDp(16),
    fontWeight: FontWeight.w500,
    fontFamily: 'JFHuninn',
  );

  //  正文內容
  static TextStyle bodyLarge = TextStyle(
    fontSize: getFromDp(22),
    fontWeight: FontWeight.normal,
    fontFamily: 'JFHuninn',
  );

  static TextStyle bodyMedium = TextStyle(
    fontSize: getFromDp(20),
    fontWeight: FontWeight.normal,
    fontFamily: 'JFHuninn',
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: getFromDp(18),
    fontWeight: FontWeight.normal,
    fontFamily: 'JFHuninn',
  );

  //  標籤/按鈕
  static TextStyle labelLarge = TextStyle(
    fontSize: getFromDp(16),
    fontWeight: FontWeight.bold,
    fontFamily: 'JFHuninn',
  );

  static TextStyle labelMedium = TextStyle(
    fontSize: getFromDp(14),
    fontWeight: FontWeight.w500,
    fontFamily: 'JFHuninn',
  );

  static TextStyle labelSmall = TextStyle(
    fontSize: getFromDp(12),
    fontWeight: FontWeight.w400,
    fontFamily: 'JFHuninn'
  );
}
