import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../helpers/app_colors.dart';

class RLayout extends StatelessWidget {
  final Widget child;

  const RLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Obx((){
      return ColoredBox(
        color: AppColors.surface,
        child: SafeArea(
            child: child
        ),
      );
    });
  }
}