import 'package:flutter/cupertino.dart';
import 'package:rabbit_kingdom/values/app_text_styles.dart';
import 'package:rabbit_kingdom/widgets/r_icon_button.dart';
import 'package:rabbit_kingdom/widgets/r_layout.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

import '../helpers/screen.dart';

class RLayoutWithHeader extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? topRight;
  const RLayoutWithHeader(this.title, {super.key, required this.child, this.topRight});

  @override
  Widget build(BuildContext context) {
    return RLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            height: getFromDp(60),
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: RIconButton.back()
                ),
                Align(
                  alignment: Alignment.center,
                  child: RText.titleLarge(title),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: topRight ?? SizedBox.shrink(),
                )
              ],
            ),
          ),
          Expanded(
              child: child
          )
        ],
      )
    );
  }
}