import 'dart:ui';

import 'package:get/get.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';

class RSnackBar {
  static show(
    String title,
    String message,
    {
      Color? colorText,
      Color? backgroundColor
    }
  ) {
    Get.snackbar(
      title,
      message,
      colorText: colorText ?? AppColors.onPrimary,
      backgroundColor: backgroundColor ?? AppColors.primary,
      snackPosition: SnackPosition.BOTTOM
    );
  }
  static error(
    String title,
    String message
  ) => show(title, message, colorText: AppColors.onError, backgroundColor: AppColors.error);
}