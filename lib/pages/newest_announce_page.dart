import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/announce_controller.dart';
import 'package:rabbit_kingdom/controllers/auth_controller.dart';
import 'package:rabbit_kingdom/extensions/get_interface.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/popups/publish_comment.dart';
import 'package:rabbit_kingdom/widgets/r_announce_viewer.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_comment.dart';
import 'package:rabbit_kingdom/widgets/r_icon_button.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class NewestAnnouncePage extends StatelessWidget {
  const NewestAnnouncePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RLayoutWithHeader(
      "最新公告",
      child: GetBuilder<AnnounceController>(builder: (announceController) {
        if (announceController.announcement != null) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              RAnnounceViewer(announce: announceController.announcement!),
              RSpace(),
              Expanded(
                child: announceController.announcement!.comments.isEmpty ?
                  Center(
                    child: RText.titleLarge("目前沒留言，快搶頭香！"),
                  ):
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow.withAlpha(180),
                          border: Border.all(color: AppColors.onSurface.withAlpha(50)),
                          borderRadius: BorderRadius.all(Radius.circular(20))
                        ),
                        child: Column(
                          children: [
                            ...announceController.announcement!.comments.asMap().entries.map((entry) {
                              return [
                                RComment(entry.value),
                                entry.key != announceController.announcement!.comments.length - 1 ?
                                  SizedBox(
                                    width: vw(100) - 60,
                                    child: Divider(color: AppColors.onSurface.withAlpha(50),),
                                  ) : SizedBox.shrink()
                              ];
                            }).expand((e) => e)
                          ],
                        ),
                      ),
                    ),
                  )
              ),
              RSpace(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: Row(
                  children: [
                    Obx(() {
                      final authController = Get.find<AuthController>();
                      final uid = authController.firebaseUser.value?.uid ?? "";
                      final isHearted = announceController.announcement!.hearts.any((e) => e.uid == uid);
                      return RIconButton(
                        icon: isHearted ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                        size: vmin(10),
                        color: AppColors.onPrimary,
                        onPress: () async {
                          if (!isHearted) {
                            try {
                              RLoading.start();
                              await announceController.markHeart();
                            } catch(e) {
                              RSnackBar.error("標記失敗", e.toString());
                            } finally {
                              RLoading.stop();
                            }
                          }
                        },
                      );
                    }),
                    RSpace(),
                    Expanded(child: RButton.primary(text: "張貼新留言", onPressed: (){ Get.rPopup(PublishComment()); }))
                  ],
                ),
              )
            ],
          );
        }
        return Center(
          child: RText.titleMedium("目前沒有最新公告QQ"),
        );
      })
    );
  }
}