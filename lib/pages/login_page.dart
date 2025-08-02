import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/auth_controller.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/pages/email_page.dart';
import 'package:rabbit_kingdom/pages/privacy_page.dart';
import 'package:rabbit_kingdom/pages/terms_page.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_layout.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

import '../controllers/theme_controller.dart';
import '../values/app_text_styles.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return RLayout(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: _BrightnessIconSwitcher(),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RText.displayLarge("兔兔王國城門"),
                RSpace(),
                _RabbitEmpireImage(),
                RSpace(),
                SizedBox(
                  width: vw(60),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _LoginButton(
                        text: "用Google登入",
                        icon: FontAwesomeIcons.google,
                        onPressed: () async {
                          try {
                            RLoading.start();
                            await authController.loginWithGoogle();
                          } catch(e, stack) {
                            FirebaseCrashlytics.instance.setCustomKey("login_method", "google");
                            FirebaseCrashlytics.instance.recordError(e, stack);
                            RSnackBar.error("登入失敗", e.toString());
                          } finally {
                            RLoading.stop();
                          }
                        },
                      ),
                      RSpace(),
                      if (!kIsWeb && Platform.isIOS) ...[
                        _LoginButton(
                          text: "用Apple登入",
                          icon: FontAwesomeIcons.apple,
                          onPressed: () async {
                            try {
                              RLoading.start();
                              await authController.loginWithApple(); // 這裡也要改喔！
                            } catch (e, stack) {
                              FirebaseCrashlytics.instance.setCustomKey("login_method", "apple");
                              FirebaseCrashlytics.instance.recordError(e, stack);
                              RSnackBar.error("登入失敗", e.toString());
                            } finally {
                              RLoading.stop();
                            }
                          },
                        ),
                        RSpace(),
                      ],
                      _LoginButton(
                        text: "使用信箱登入",
                        icon: FontAwesomeIcons.envelope,
                        onPressed: () {
                          Get.to(() => EmailPage());
                        },
                      )
                    ],
                  ),
                ),
                RSpace(type: RSpaceType.large,),
                RText.bodySmall("~今天也要很可愛的入境~"),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppTextStyle.getFromDp(20), vertical: AppTextStyle.getFromDp(16)),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: '點擊登入表示您同意',
                  style: TextStyle(color: Colors.grey[600], fontSize: AppTextStyle.getFromDp(12)),
                  children: [
                    TextSpan(
                      text: '《隱私政策》',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        Get.to(() => PrivacyPage());
                      },
                    ),
                    TextSpan(text: '與'),
                    TextSpan(
                      text: '《使用條款》',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        Get.to(() => TermsPage());
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}

class _BrightnessIconSwitcher extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ThemeController>();

    return Obx((){
      return GestureDetector(
        onTap: () => controller.setThemeMode(
            controller.themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light
        ),
        child: FaIcon(
          controller.themeMode.value == ThemeMode.light ? FontAwesomeIcons.sun : FontAwesomeIcons.moon,
          size: AppTextStyle.getFromDp(30),
          color: AppColors.secondary,
        ),
      );
    });
  }
}

class _RabbitEmpireImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'lib/assets/images/rabbit_empire_0.png',
      width: mainImageSize(),
      height: mainImageSize(),
      fit: BoxFit.cover,
    );
  }
}

class _LoginButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Function() onPressed;

  const _LoginButton({
    required this.text,
    required this.icon, required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return RButton.primary(
        onPressed: onPressed,
        child: (color) => Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FaIcon(icon, color: color, size: AppTextStyle.getFromDp(20),),
              RSpace(type: RSpaceType.small,),
              RText.bodyLarge(
                text,
                color: color,
              )
            ],
          ),
        )
    );
  }
}