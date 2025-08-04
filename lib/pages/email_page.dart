import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/widgets/r_icon_button.dart';
import 'package:rabbit_kingdom/widgets/r_layout.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_text_input.dart';

import '../controllers/auth_controller.dart';
import '../helpers/screen.dart';
import '../widgets/r_button.dart';
import '../widgets/r_space.dart';
import '../widgets/r_text.dart';

class EmailPage extends StatelessWidget {
  final emailController = RTextInputController();
  final passwordController = RTextInputController(obscure: true);
  bool get loginAllow =>
      emailController.text.value.isNotEmpty &&
      passwordController.text.value.isNotEmpty;

  EmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return RLayout(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            height: 60,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: RIconButton.back(),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'lib/assets/images/rabbit_empire_1.png',
                      width: mainImageSize(),
                      height: mainImageSize(),
                      fit: BoxFit.cover,
                    ),
                    RSpace(),
                    RText.bodySmall("要用信箱入境？希望你不會忘記密碼..."),
                    RSpace(type: RSpaceType.large),
                    SizedBox(
                      width: vw(75) * deviceFactor(),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RSpace(),
                          RTextInput(label: "信箱", controller: emailController),
                          RSpace(),
                          RTextInput(
                            label: "密碼",
                            controller: passwordController,
                            obscureText: true,
                          ),
                          RSpace(type: RSpaceType.large),
                          Obx(() {
                            return RButton.surface(
                              onPressed: () async {
                                try {
                                  RLoading.start();
                                  if (loginAllow) {
                                    await authController.loginWithEmail(
                                      emailController.text.value,
                                      passwordController.text.value,
                                    );
                                  }
                                } catch (e, stack) {
                                  FirebaseCrashlytics.instance.setCustomKey("login_method", "email");
                                  FirebaseCrashlytics.instance.recordError(e, stack);
                                  RSnackBar.error("入境失敗", e.toString());
                                } finally {
                                  RLoading.stop();
                                }
                              },
                              isDisabled: !loginAllow,
                              child: (color) => Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    RText.bodyLarge("申請入境", color: color),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
