import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/announce_controller.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_popup.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text_input.dart';

class PublishComment extends StatelessWidget {
  const PublishComment({super.key});

  @override
  Widget build(BuildContext context) {
    final messageController = RTextInputController();
    final announceController = Get.find<AnnounceController>();

    return RPopup(
      title: "撰寫留言",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RSpace(),
          RTextInput(controller: messageController, label: "留言", foregroundColor: AppColors.onSecondary, backgroundColor: AppColors.secondary,),
          RSpace(),
          SizedBox(
            width: vw(65),
            child: RButton.secondary(
                text: "送出",
                onPressed: () async {
                  if (messageController.text.value.isNotEmpty) {
                    try {
                      RLoading.start();
                      await announceController.publishComment(messageController.text.value);
                      Get.back();
                    } catch(e) {
                      RSnackBar.error("送出失敗", e.toString());
                    } finally {
                      RLoading.stop();
                    }
                  }
                }),
          )
        ],
      )
    );
  }
}