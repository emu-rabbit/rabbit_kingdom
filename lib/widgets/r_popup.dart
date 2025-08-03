import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/widgets/r_icon_button.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

import '../helpers/app_colors.dart';
import '../helpers/screen.dart';

class RPopup extends StatelessWidget {
  final String? title;
  final double? width;
  final Widget child;
  final bool closable;
  const RPopup({ required this.child, this.title, this.width, this.closable = true, super.key });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Color(0xaa000000),
      child: SafeArea(
        child: Center(
          child: IntrinsicHeight(
            child: Container(
              width: width ?? vw(70),
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(220),
                borderRadius: BorderRadius.all(Radius.circular(20)),
                border: Border.all(
                  color: AppColors.onSecondary,
                  width: 2
                )
              ),
              child: Stack(
                children: [
                  closable ? Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      child: RIconButton(
                          icon: FontAwesomeIcons.xmark,
                          color: AppColors.onSecondary,
                          onPress: (){ Get.back(); }
                      ),
                    ),
                  ): SizedBox.shrink(),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: RText.titleLarge(title ?? "", color: AppColors.onSecondary,)
                    ),
                  ),
                  Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 40, bottom: 20, left: 20, right: 20),
                        child: child,
                      )
                  )
                ],
              ),
            )
          )
        )
      ),
    );
  }

}