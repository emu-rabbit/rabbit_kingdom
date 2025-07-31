import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/theme_controller.dart';

import '../helpers/app_colors.dart';
import '../values/app_text_styles.dart';

class RIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? size;

  const RIcon(this.icon, { super.key, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (_) {
        return FaIcon(
          icon,
          color: color ?? AppColors.onSurface,
          size: size ?? AppTextStyle.getFromDp(25),
        );
      }
    );
  }
}