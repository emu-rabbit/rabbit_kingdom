import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/announce_controller.dart';
import 'package:rabbit_kingdom/extensions/date_time.dart';
import 'package:rabbit_kingdom/extensions/get_interface.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/models/kingdom_announcement.dart';
import 'package:rabbit_kingdom/popups/heart_list_popup.dart';
import 'package:rabbit_kingdom/widgets/r_icon.dart';
import 'package:rabbit_kingdom/widgets/r_icon_button.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class RAnnounceViewer extends StatelessWidget {
  final KingdomAnnouncement announce;
  const RAnnounceViewer({super.key, required this.announce});

  @override
  Widget build(BuildContext context) {
    final width = vw(100) * deviceFactor();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          border: Border.all(color: AppColors.onSurface, width: 1),
          borderRadius: BorderRadius.all(Radius.circular(20))
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RText.titleLarge("兔兔大帝心情指數：${announce.mood}"),
            RSpace(),
            Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  announce.sticker.imagePath,
                  width: width / 3,
                  height: width / 3,
                ),
                RSpace(),
                SizedBox(
                  height: width / 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RSpace(type: RSpaceType.small,),
                      Expanded(
                        child: SizedBox(
                          width: width * 2 / 3 - 75,
                          child: ClipRect(
                            child: RText.bodySmall(announce.message, maxLines: 30)),
                          ),
                      ),
                      RSpace(type: RSpaceType.small,),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RIconButton(
                            icon: FontAwesomeIcons.solidHeart,
                            size: vw(3),
                            onPress: () { Get.rPopup(HeartListPopup(hearts: announce.hearts)); },
                          ),
                          RSpace(type: RSpaceType.small,),
                          GetBuilder<AnnounceController>(builder: (announceController){
                            return RText.labelSmall(announce.hearts.length.toString());
                          }),
                          RSpace(),
                          RText.labelSmall("-"),
                          RSpace(),
                          RText.labelSmall(announce.createAt.toRelativeTimeString())
                        ],
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}