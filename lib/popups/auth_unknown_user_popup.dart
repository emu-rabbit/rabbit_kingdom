import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/models/kingdom_user.dart';
import 'package:rabbit_kingdom/services/empire_service.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_dropdown.dart';
import 'package:rabbit_kingdom/widgets/r_icon_button.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_popup.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';

import '../widgets/r_text.dart';

class AuthUnknownUserPopup extends StatelessWidget {
  final UnknownUserData user;

  const AuthUnknownUserPopup(this.user, { super.key });

  @override
  Widget build(BuildContext context) {
    final groupController = RDropdownController(KingdomUserGroup.friend);

    return RPopup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RText.titleLarge(user.name, color: AppColors.onSecondary,),
          RText.titleSmall(user.email, color: AppColors.onSecondary, maxLines: 2,),
          RSpace(),
          SizedBox(
            width: vw(50),
            child: RDropdown.secondary(
              controller: groupController,
              options: KingdomUserGroup.values,
              toDisplayString: (group) => group.toDisplay(),
            ),
          ),
          RSpace(),
          SizedBox(
            width: vw(50),
            child: RButton.secondary(
              text: "送出",
              onPressed: () async {
                try {
                  RLoading.start();
                  await EmpireService.authUnknownUser(user, groupController.selected.value);
                  Get.back(result: true);
                } catch (e) {
                  RSnackBar.error("設定失敗", e.toString());
                } finally {
                  RLoading.stop();
                }
              }
            ),
          ),
        ],
      )
    );
  }
}