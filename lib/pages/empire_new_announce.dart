import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/models/kingdom_announcement.dart';
import 'package:rabbit_kingdom/services/empire_service.dart';
import 'package:rabbit_kingdom/widgets/r_announce_viewer.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_dropdown.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';
import 'package:rabbit_kingdom/widgets/r_text_input.dart';

class EmpireNewAnnounce extends StatelessWidget {
  const EmpireNewAnnounce({super.key});

  @override
  Widget build(BuildContext context) {
    final moodController = RTextInputController();
    final messageController = RTextInputController();
    final stickerController = RDropdownController(AnnounceSticker.happy);
    Rxn<KingdomAnnouncement> announce = Rxn<KingdomAnnouncement>();

    return RLayoutWithHeader(
      "新公告",
      child: Column(
        children: [
          Obx(() {
            if (announce.value != null) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RAnnounceViewer(announce: announce.value!,),
                  RSpace(),
                  RText.bodySmall("賣出：${announce.value!.poopSell} | 買入：${announce.value!.poopBuy}"),
                  RSpace(),
                ],
              );
            }
            return SizedBox.shrink();
          }),
          SizedBox(
            width: vw(70),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RTextInput(controller: moodController, keyboardType: TextInputType.number, label: "心情值"),
                RSpace(),
                RTextInput(controller: messageController, label: "訊息"),
                RSpace(),
                RDropdown(controller: stickerController, options: AnnounceSticker.values),
                RSpace(),
                RButton.primary(text: "生成預覽", onPressed: (){
                  final mood = int.tryParse(moodController.text.value);
                  final message = messageController.text.value;
                  final sticker = stickerController.selected.value;
                  if (mood != null && mood >= 0 && mood <= 99 && message.isNotEmpty) {
                    announce.value = KingdomAnnouncement.create(mood: mood, message: message, sticker: sticker);
                  }
                }),
                RSpace(),
                Obx((){
                  if (announce.value != null) {
                    return RButton.primary(text: "確認發布", onPressed: () async {
                      try {
                        RLoading.start();
                        await EmpireService.publishNewAnnounce(announce.value!);
                        Get.back();
                        RSnackBar.show("發布成功", "新公告已發布");
                      } catch (e) {
                        RSnackBar.error("發布失敗", e.toString());
                      } finally {
                        RLoading.stop();
                      }
                    });
                  }
                  return SizedBox.shrink();
                })
              ],
            ),
          )
        ],
      )
    );
  }
}