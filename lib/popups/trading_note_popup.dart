import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/widgets/r_popup.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class TradingNotePopup extends StatelessWidget {
  const TradingNotePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return RPopup(
      title: "小帳冊",
      child: GetBuilder<UserController>(
        builder: (uc) {
          return uc.user != null ?
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RText.titleMedium("買入總量: ${uc.user!.note.buyAmount}", color: AppColors.onSecondary,),
                RSpace(type: RSpaceType.small,),
                RText.titleMedium("買入均價: ${uc.user!.note.buyAverage?.toStringAsFixed(2) ?? "-"}", color: AppColors.onSecondary,),
                RSpace(type: RSpaceType.small,),
                RText.titleMedium("賣出總量: ${uc.user!.note.sellAmount}", color: AppColors.onSecondary,),
                RSpace(type: RSpaceType.small,),
                RText.titleMedium("賣出均價: ${uc.user!.note.sellAverage?.toStringAsFixed(2) ?? "-"}", color: AppColors.onSecondary,),
              ],
            ): RText.titleMedium("找不到使用者資料QQ", color: AppColors.onSecondary,);
        }
      )

    );
  }
}