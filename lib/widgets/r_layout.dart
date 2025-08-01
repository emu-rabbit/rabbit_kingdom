import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/theme_controller.dart';

import '../helpers/app_colors.dart';

class RLayout extends StatelessWidget {
  final Widget child;

  const RLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(builder: (controller) {
      final brightness = controller.brightness;
      final phase = brightness == Brightness.light ? 'day' : 'night';

      return Scaffold(
        resizeToAvoidBottomInset: true, // 🌟 讓畫面遇到鍵盤時自動推開
        backgroundColor: Colors.transparent,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // 背景圖
            Image.asset(
              "lib/assets/images/bg_$phase.png",
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
            // SafeArea + 實際內容
            SafeArea(child: child),
          ],
        ),
      );
    });
  }
}
