import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/values/app_text_styles.dart';
import 'package:rabbit_kingdom/widgets/r_icon.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

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
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: controller.textController,
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
                      borderRadius: BorderRadius.zero,
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.primary, width: 2.0),
                      borderRadius: BorderRadius.zero,
                    ),
                    contentPadding: obscureText
                        ? const EdgeInsets.only(right: 48, left: 12, top: 12, bottom: 12)
                        : const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  // 不要在這裡 setText，組字會壞掉！
                  onChanged: (_) {}, // 如果要監聽，可使用 debounce 實作
                  buildCounter: (
                      context, {
                        required int currentLength,
                        required bool isFocused,
                        required int? maxLength,
                      }) {
                    if (maxLength != null) {
                      return RText.labelSmall('$currentLength / $maxLength');
                    }
                    return SizedBox.shrink();
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
          ),
        ],
      );
    });
  }
}

class RTextInputController extends GetxController {
  final textController = TextEditingController();
  final obscure = false.obs;

  // ✅ 外部可用來監聽的文字 observable
  final text = ''.obs;

  RTextInputController({bool obscure = false}) {
    this.obscure.value = obscure;

    // 🔗 綁定 listener，追蹤輸入框變化
    textController.addListener(() {
      text.value = textController.text;
    });
  }

  /// 設定文字時，同步更新 textController 和 text Rx
  void setText(String value) {
    final old = textController.value;
    textController.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: old.composing,
    );
    text.value = value; // 同步 RxString
  }

  void clear() {
    textController.clear();
    text.value = '';
  }

  void toggleObscure() => obscure.value = !obscure.value;

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
