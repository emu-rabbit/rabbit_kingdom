import 'package:flutter/cupertino.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/widgets/r_popup.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class WebNotificationPopup extends StatelessWidget {
  const WebNotificationPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return RPopup(
      title: "通知設定",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RText.titleMedium("網頁版請點擊瀏覽器的鎖頭", color: AppColors.onPrimary,),
          RText.titleMedium("或進入設定頁進行設定唷", color: AppColors.onPrimary,),
        ],
      )
    );
  }
}