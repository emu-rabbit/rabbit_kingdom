import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/theme_controller.dart';

import '../helpers/app_colors.dart';

class RLayout extends StatelessWidget {
  final Widget child;

  const RLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
        builder: (controller)  {
          return ColoredBox(
            color: AppColors.surface,
            child: SafeArea(
                child: child
            ),
          );
        }
    );
  }
}