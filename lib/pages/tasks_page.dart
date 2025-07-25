import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/extensions/get_interface.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/popups/task_info_popup.dart';
import 'package:rabbit_kingdom/widgets/r_icon_button.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';

import '../widgets/r_text.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RLayoutWithHeader(
      "每日任務",
      // topRight: RIconButton(icon: FontAwesomeIcons.circleQuestion, onPress: (){ Get.rPopup(TaskQuestionPopup()); }),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: GetBuilder<UserController>(
            builder: (userController) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...userController
                    .user
                    ?.taskData
                    .entries
                    .map((entry) {
                      final task = entry.value;
                      final isComplete = task.completed >= task.limit;
                      return [
                        GestureDetector(
                          onTap: (){
                            if (isComplete) return;
                            task.navigator();
                          },
                          child: Opacity(
                            opacity: isComplete ? 0.5 : 1,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  border: Border.all(color: AppColors.onSurface, width: 2),
                                  borderRadius: BorderRadius.all(Radius.circular(20))
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      RText.displaySmall(task.text),
                                      RText.titleSmall("${task.completed} / ${task.limit}")
                                    ],
                                  ),
                                  RSpace(),
                                  RText.bodySmall("獎勵：經驗值（${task.expReward}）、兔兔幣（${task.coinReward}）")
                                ],
                              ),
                            ),
                          ),
                        ),
                        RSpace(type: RSpaceType.large,)
                      ];
                  }).expand((e) => e) ?? []
                ],
              );
            }
          ),
        ),
      )
    );
  }
}