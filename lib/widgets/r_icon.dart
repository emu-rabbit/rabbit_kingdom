import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../helpers/app_colors.dart';

class RIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? size;

  const RIcon(this.icon, { super.key, this.color, this.size});

  @override
  Widget build(BuildContext context) {
    return FaIcon(
      icon,
      color: color ?? AppColors.onSurface,
      size: size,
    );
  }
}