import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/values/app_text_styles.dart';
import 'package:rabbit_kingdom/widgets/r_icon.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart'; // 要記得引入上面的 controller

class RTextInput extends StatelessWidget {
  final String label;
  final String? hint;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final TextInputType keyboardType;

  final RTextInputController controller;

  const RTextInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final textController = TextEditingController(
            text: controller.text.value,
          );

          // 把游標移到文字最後
          textController.selection = TextSelection.fromPosition(
            TextPosition(offset: textController.text.length),
          );

          return Material(
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: textController,
                  obscureText: controller.obscure.value,
                  maxLines: maxLines,
                  maxLength: maxLength,
                  keyboardType: keyboardType,
                  style: AppTextStyle.bodySmall.copyWith(color: AppColors.onSurface),
                  decoration: InputDecoration(
                    label: RText.titleLarge(
                      label,
                      color: AppColors.onSurface,
                    ),
                    hintText: hint,
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary, width: 1.0),
                      borderRadius: BorderRadius.zero
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                      borderRadius: BorderRadius.zero
                    ),
                    // 預留右側空間，避免按鈕蓋住文字
                    contentPadding: obscureText
                        ? const EdgeInsets.only(right: 48, left: 12, top: 12, bottom: 12)
                        : const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  onChanged: controller.setText,
                  buildCounter: (
                      context, {
                        required int currentLength,
                        required bool isFocused,
                        required int? maxLength,
                      }) {
                    return RText.labelSmall('$currentLength / $maxLength',);
                  },
                ),
                if (obscureText)
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: RIcon(
                        controller.obscure.value ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.onSurface,
                      ),
                      onPressed: controller.toggleObscure,
                      tooltip: controller.obscure.value ? '顯示密碼' : '隱藏密碼',
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}


class RTextInputController extends GetxController {
  final text = ''.obs;
  final obscure = false.obs;

  RTextInputController({bool obscure = false}) {
    this.obscure.value = obscure;
  }

  void setText(String value) => text.value = value;
  void clear() => text.value = '';
  void toggleObscure() => obscure.value = !obscure.value;
}
