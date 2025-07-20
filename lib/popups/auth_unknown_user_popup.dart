import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/models/kingdom_user.dart';
import 'package:rabbit_kingdom/services/empire_service.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_icon_button.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';

import '../widgets/r_text.dart';

class AuthUnknownUserPopup extends StatelessWidget {
  final UnknownUserData user;

  const AuthUnknownUserPopup(this.user, { super.key });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Color(0xaa000000),
      child: SafeArea(
        child: Center(
          child: IntrinsicHeight(
            child: Container(
              width: vw(70),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.all(Radius.circular(20))
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: RIconButton(
                        icon: FontAwesomeIcons.xmark,
                        onPress: (){ Get.back(); }
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 40, bottom: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RText.titleLarge(user.name),
                          RText.titleSmall(user.email, maxLines: 2,),
                          RSpace(),
                          ...KingdomUserGroup
                            .values
                            .map((group) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RButton.primary(
                                      onPressed: () async {
                                        try {
                                          RLoading.start();
                                          await EmpireService.authUnknownUser(user, group);
                                          Get.back(result: true);
                                        } catch (e) {
                                          RSnackBar.error("設定失敗", e.toString());
                                        } finally {
                                          RLoading.stop();
                                        }
                                      },
                                      child: (color) {
                                        return RText.labelSmall("設為${group.toDisplay()}", color: color,);
                                      }
                                  ),
                                  RSpace()
                                ],
                              );
                            })
                        ],
                      ),
                    )
                  )
                ],
              ),
            )
          )
        )
      ),
    );
  }
}