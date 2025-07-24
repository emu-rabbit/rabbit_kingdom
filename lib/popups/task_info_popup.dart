import 'package:flutter/cupertino.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/widgets/r_popup.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class TaskQuestionPopup extends StatelessWidget {
  const TaskQuestionPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return RPopup(
      title: "關於任務",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RText.bodySmall("此處的任務僅供檢視", color: AppColors.onSecondary),
          RText.bodySmall("任務完成時獎勵將會自動給予", color: AppColors.onSecondary),
        ],
      )
    );
  }
}