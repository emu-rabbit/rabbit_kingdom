import 'package:flutter/cupertino.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class RButtonGroup extends StatelessWidget {
  final String title;
  final List<RButtonData?> buttons;
  const RButtonGroup(this.title, this.buttons, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: vw(65) * deviceFactor(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title.isNotEmpty ?
            RText.titleMedium(title): SizedBox.shrink(),
          title.isNotEmpty ?
            RSpace(): SizedBox.shrink(),
          ...buttons.whereType<RButtonData>().map((data) {
            Widget Function(Color) child;
            if (data.child != null) {
              child = data.child!;
            } else {
              child = (Color color) {
                return RText.bodyLarge(data.text ?? "", textAlign: TextAlign.center, color: color,);
              };
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                switch(data.type) {
                  RButtonType.primary => RButton.primary(onPressed: data.onPress, child: child),
                  RButtonType.secondary => RButton.secondary(onPressed: data.onPress, child: child),
                  RButtonType.surface => RButton.surface(onPressed: data.onPress, child: child),
                  RButtonType.danger => RButton.danger(onPressed: data.onPress, child: child),
                },
                RSpace(type: RSpaceType.small,)
              ],
            );
          })
        ],
      ),
    );
  }
}

class RButtonData {
  final String? text;
  final Widget Function(Color)? child;
  final RButtonType type;
  final Function() onPress;

  RButtonData({ this.text, this.child, this.type = RButtonType.primary, required this.onPress });
}