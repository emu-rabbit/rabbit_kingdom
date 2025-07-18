import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/theme_controller.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import '../values/app_text_styles.dart';

class RText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color? color;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  const RText._(
      this.text,
      this.style, {
        this.color,
        this.textAlign,
        this.overflow,
        this.maxLines,
      });

  factory RText.displayLarge(String text, {
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => RText._(text, AppTextStyle.displayLarge,
      color: color, textAlign: textAlign, overflow: overflow, maxLines: maxLines);

  factory RText.headlineMedium(String text, {
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => RText._(text, AppTextStyle.headlineMedium,
      color: color, textAlign: textAlign, overflow: overflow, maxLines: maxLines);

  factory RText.titleLarge(String text, {
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => RText._(text, AppTextStyle.titleLarge,
      color: color, textAlign: textAlign, overflow: overflow, maxLines: maxLines);

  factory RText.titleMedium(String text, {
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => RText._(text, AppTextStyle.titleMedium,
      color: color, textAlign: textAlign, overflow: overflow, maxLines: maxLines);

  factory RText.titleSmall(String text, {
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => RText._(text, AppTextStyle.titleSmall,
      color: color, textAlign: textAlign, overflow: overflow, maxLines: maxLines);

  factory RText.bodyLarge(String text, {
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => RText._(text, AppTextStyle.bodyLarge,
      color: color, textAlign: textAlign, overflow: overflow, maxLines: maxLines);

  factory RText.bodyMedium(String text, {
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => RText._(text, AppTextStyle.bodyMedium,
      color: color, textAlign: textAlign, overflow: overflow, maxLines: maxLines);

  factory RText.bodySmall(String text, {
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => RText._(text, AppTextStyle.bodySmall,
      color: color, textAlign: textAlign, overflow: overflow, maxLines: maxLines);

  factory RText.labelLarge(String text, {
    Color? color,
    TextAlign? textAlign,
    TextOverflow? overflow,
    int? maxLines,
  }) => RText._(text, AppTextStyle.labelLarge,
      color: color, textAlign: textAlign, overflow: overflow, maxLines: maxLines);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
        builder: (controller) {
          return Text(
            text,
            style: color != null ?
            style.copyWith(color: color, decoration: TextDecoration.none) :
            style.copyWith(color: AppColors.onSurface, decoration: TextDecoration.none),
            textAlign: textAlign,
            overflow: overflow,
            maxLines: maxLines,
          );
        }
    );
  }
}
