import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/widgets/r_icon.dart';

class RIconButton extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double? size;
  final Function() onPress;

  const RIconButton({super.key, required this.icon, required this.onPress, this.color, this.size});

  static RIconButton back() => RIconButton(icon: FontAwesomeIcons.arrowLeft, onPress: Get.back);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPress,
        child: RIcon(icon, color: color, size: size,)
    );
  }
}