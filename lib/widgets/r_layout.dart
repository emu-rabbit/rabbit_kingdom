import 'package:flutter/cupertino.dart';
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
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/images/bg_$phase.png"),
            fit: BoxFit.cover,
            alignment: Alignment.center
          )
        ),
        child: SafeArea(
            child: child
        ),
      );
    });
  }
}