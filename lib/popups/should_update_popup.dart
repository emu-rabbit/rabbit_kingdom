import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_popup.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';
import 'package:url_launcher/url_launcher.dart';

class ShouldUpdatePopup extends StatelessWidget {
  final String appVersion;
  final String latestVersion;
  const ShouldUpdatePopup({super.key, required this.appVersion, required this.latestVersion});

  @override
  Widget build(BuildContext context) {
    return RPopup(
      title: "有新版本",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RText.titleMedium("當前版本: $appVersion", color: AppColors.onSecondary,),
          RText.titleMedium("最新版本: $latestVersion", color: AppColors.onSecondary,),
          RSpace(),
          RButton.secondary(text: "去商店更新", onPressed: (){
            try {
              if (Platform.isAndroid) {
                launchUrl(Uri.parse("https://play.google.com/store/apps/details?id=io.github.emu_rabbit.rabbit_kingdom"));
              } else if (Platform.isIOS) {
                launchUrl(Uri.parse("https://testflight.apple.com/join/NvnVW5qZ"));
              } else {
                throw Exception("Platform error");
              }
            } catch (e) {
              RSnackBar.error("開啟連結失敗", e.toString());
            }
          })
        ],
      )
    );
  }
}