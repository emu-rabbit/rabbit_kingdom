import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/extensions/double.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
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
            SizedBox(
              width: vw(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(title: "買入總量", value: uc.user!.note.buyAmount.toString()),
                  RSpace(type: RSpaceType.small,),
                  _InfoRow(title: "買入均價", value: uc.user!.note.buyAverage?.toStringAsFixed(2) ?? "-"),
                  RSpace(type: RSpaceType.small,),
                  _InfoRow(title: "賣出總量", value: uc.user!.note.sellAmount.toString()),
                  RSpace(type: RSpaceType.small,),
                  _InfoRow(title: "賣出均價", value: uc.user!.note.sellAverage?.toStringAsFixed(2) ?? "-"),
                  RSpace(type: RSpaceType.small,),
                  _InfoRow(title: "均價差", value: uc.user!.note.averageDif?.toSignedString(fractionDigits: 2) ?? "-")
                ],
              ),
            ): RText.titleMedium("找不到使用者資料QQ", color: AppColors.onSecondary,);
        }
      )
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;
  const _InfoRow({ required this.title, required this.value });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RText.titleMedium("$title:", color: AppColors.onSecondary,),
        RText.titleMedium(value, color: AppColors.onSecondary,),
      ],
    );
  }
}