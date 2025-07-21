import 'package:flutter/cupertino.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class RButtonGroup extends StatelessWidget {
  final String title;
  final List<RButtonData> buttons;
  const RButtonGroup(this.title, this.buttons, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: vw(60),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title.isNotEmpty ?
            RText.titleSmall(title): SizedBox.shrink(),
          title.isNotEmpty ?
            RSpace(): SizedBox.shrink(),
          ...buttons.map((data) {
            child(Color color) {
              return RText.bodyLarge(data.text, textAlign: TextAlign.center, color: color,);
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
  final String text;
  final RButtonType type;
  final Function() onPress;

  RButtonData({ required this.text, this.type = RButtonType.primary, required this.onPress });
}