import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/models/kingdom_user.dart';
import 'package:rabbit_kingdom/pages/empire_auth_unknown_users.dart';
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
            RText.titleLarge("你進到了王國的市政廳"),
            RSpace(type: RSpaceType.small,),
            RText.labelSmall("忙碌的兔子們來來去去，差點撞到了你"),
            RSpace(),
            Image.asset(
              "lib/assets/images/townhall_0.png",
              width: vmin(50),
              height: vmin(50),
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
                          RButtonData(text: "審查新入境者", onPress: (){ Get.to(EmpireAuthUnknownUsers()); })
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