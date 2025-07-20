import 'package:flutter/cupertino.dart';
import 'package:rabbit_kingdom/widgets/r_icon_button.dart';
import 'package:rabbit_kingdom/widgets/r_layout.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class RLayoutWithHeader extends StatelessWidget {
  final String title;
  final Widget child;
  const RLayoutWithHeader(this.title, {super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return RLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              height: 60,
              child: Stack(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: RIconButton.back()
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: RText.titleLarge(title),
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