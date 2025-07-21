import 'package:flutter/cupertino.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text_input.dart';

class EmpireNewAnnounce extends StatelessWidget {
  const EmpireNewAnnounce({super.key});

  @override
  Widget build(BuildContext context) {
    final moodValueController = RTextInputController();
    final moodMessageController = RTextInputController();

    return RLayoutWithHeader(
      "新公告",
      child: Column(
        children: [
          SizedBox(
            width: vw(60),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RTextInput(controller: moodValueController, keyboardType: TextInputType.number, label: "心情值"),
                RSpace(),
                RTextInput(controller: moodMessageController, keyboardType: TextInputType.number, label: "訊息"),
              ],
            ),
          )
        ],
      )
    );
  }
}