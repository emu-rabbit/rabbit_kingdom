import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/extensions/get_interface.dart';
import 'package:rabbit_kingdom/models/kingdom_user.dart';
import 'package:rabbit_kingdom/pages/empire_auth_unknown_users.dart';
import 'package:rabbit_kingdom/pages/empire_new_announce.dart';
import 'package:rabbit_kingdom/pages/empire_publish_news.dart';
import 'package:rabbit_kingdom/pages/faq_page.dart';
import 'package:rabbit_kingdom/pages/modify_name_page.dart';
import 'package:rabbit_kingdom/pages/newest_announce_page.dart';
import 'package:rabbit_kingdom/popups/release_note_popup.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_button_group.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';

import '../helpers/screen.dart';
import '../widgets/r_space.dart';
import '../widgets/r_text.dart';

class BuildingTownHallPage extends StatelessWidget {
  const BuildingTownHallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RLayoutWithHeader(
      "",
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RText.headlineLarge("你進到了王國的市政廳"),
            RSpace(type: RSpaceType.small,),
            RText.bodySmall("忙碌的兔子們來來去去，差點撞到了你"),
            RSpace(),
            Image.asset(
              "lib/assets/images/townhall_0.png",
              width: mainImageSize(),
              height: mainImageSize(),
            ),
            RSpace(),
            RButtonGroup(
                "某個角落有個很大的布告欄",
                [
                  RButtonData(text: "查看最新公告", onPress: (){ Get.to(() => NewestAnnouncePage()); })
                ]
            ),
            RSpace(type: RSpaceType.large,),
            RButtonGroup(
                "櫃台有個可愛的兔兔公務員",
                [
                  RButtonData(text: "我要申請護照改名", onPress: (){ Get.to(() => ModifyNamePage()); }),
                  RButtonData(text: "我有問題想問...", onPress: (){ Get.to(() => FaqPage()); }),
                  RButtonData(text: "最近在忙什麼呢？", onPress: (){ Get.rPopup(ReleaseNotePopup()); }),
                ]
            ),
            RSpace(type: RSpaceType.large,),
            GetBuilder<UserController>(
              builder: (userController) {
                if (userController.user?.group == KingdomUserGroup.empire) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RButtonGroup(
                        "阿，是大帝！",
                        [
                          RButtonData(text: "審查新入境者", type: RButtonType.secondary, onPress: (){ Get.to(() => EmpireAuthUnknownUsers()); }),
                          RButtonData(text: "發布新公告", type: RButtonType.secondary, onPress: (){ Get.to(() => EmpireNewAnnounce()); }),
                          RButtonData(text: "發布交易所新聞", type: RButtonType.secondary, onPress: (){ Get.to(() => EmpirePublishNews()); })
                        ]
                      ),
                      RSpace(type: RSpaceType.large,),
                    ],
                  );
                }
                return SizedBox.shrink();
              }
            )
          ],
        ),
      )
    );
  }
}