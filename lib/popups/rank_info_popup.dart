import 'package:flutter/cupertino.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/widgets/r_popup.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class RRankInfoPopup extends StatelessWidget {
  const RRankInfoPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return RPopup(
      title: "排行榜說明",
      width: vw(80),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RText.bodySmall("王國富豪：總資產(總額/月累計)最高", color: AppColors.onSecondary,),
          RSpace(),
          RText.bodySmall("兔幣至上：兔兔幣(總額/月累計)最高", color: AppColors.onSecondary,),
          RSpace(),
          RText.bodySmall("精華之巔：兔兔精華(總額/月累計)最高", color: AppColors.onSecondary,),
          RSpace(),
          RText.bodySmall("老謀深算：經驗值(總額/月累計)最高", color: AppColors.onSecondary,),
          RSpace(),
          RText.bodySmall("不醉不歸：喝酒數(總額/月累計)最高", color: AppColors.onSecondary,),
          RSpace(),
          RText.bodySmall("交易大戶：交易量(總額/月累計)最高", color: AppColors.onSecondary,),
          RSpace(),
          RText.bodySmall("操盤高手：買賣差額(總計/月計)最好", color: AppColors.onSecondary,),
          RSpace(),
          RText.bodySmall("韭菜盒子：買賣差額(總計/月計)最差", color: AppColors.onSecondary,),
          RSpace(),
          RText.labelLarge("(排行榜約每4小時更新一次)", color: AppColors.onSecondary, textAlign: TextAlign.center,),
        ],
      )
    );
  }
}