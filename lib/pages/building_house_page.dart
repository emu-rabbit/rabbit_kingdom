import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/auth_controller.dart';
import 'package:rabbit_kingdom/controllers/theme_controller.dart';
import 'package:rabbit_kingdom/extensions/get_interface.dart';
import 'package:rabbit_kingdom/helpers/ad.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/popups/web_notification_popup.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_button_group.dart';
import 'package:rabbit_kingdom/widgets/r_fade_in_column.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_popup.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class BuildingHousePage extends StatelessWidget {
  const BuildingHousePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return RLayoutWithHeader(
      "",
      child: SingleChildScrollView(
        child: RFadeInColumn(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RText.headlineLarge("你回到了溫暖的窩"),
            RSpace(type: RSpaceType.small,),
            RText.bodySmall("看了混亂的房間，你決定明天再打掃"),
            RSpace(),
            Image.asset(
              "lib/assets/images/house_0.png",
              width: mainImageSize(),
              height: mainImageSize(),
            ),
            RSpace(type: RSpaceType.large,),
            GetBuilder<ThemeController>(
              builder: (themeController) {
                return RButtonGroup(
                  "溫暖軟呼呼的床...",
                  [
                    RButtonData(
                      text: "一覺到天${themeController.brightness == Brightness.light ? "黑": "亮"}" ,
                      onPress: () async {
                        RLoading.start();
                        await Future.delayed(Duration(seconds: 3));
                        themeController.setThemeMode(
                          themeController.brightness == Brightness.light ?
                            ThemeMode.dark : ThemeMode.light
                        );
                        RLoading.stop();
                      }
                    )
                  ]
                );
              }
            ),
            RSpace(type: RSpaceType.large,),
            RButtonGroup(
              "一台閃亮亮的新電腦",
              [
                RButtonData(
                    text: "調整通知設定",
                    onPress: (){
                      if (kIsWeb) {
                        Get.rPopup(WebNotificationPopup());
                      } else {
                        AppSettings.openAppSettings(type: AppSettingsType.notification);
                      }
                    }
                ),
                isAdSupported() ?
                  RButtonData(
                      text: "安裝殺廣告軟體",
                      onPress: (){
                        Get.rPopup(
                          RPopup(
                            title: "去除廣告",
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RText.bodySmall("未來將會提供應用程式內付費", color: AppColors.onSecondary,),
                                RText.bodySmall("以解鎖去除廣告功能", color: AppColors.onSecondary,),
                              ],
                            )
                          )
                        );
                      }
                  ) : null,
              ]
            ),
            RSpace(type: RSpaceType.large,),
            RButtonGroup(
              "滿地混亂的行李",
              [
                RButtonData(
                  text: "收拾行李並出境",
                  type: RButtonType.danger,
                  onPress: () async {
                    RLoading.start();
                    await authController.logout();
                    RLoading.stop();
                  }
                )
              ]
            ),
            RSpace(type: RSpaceType.large,),
          ],
        ),
      )
    );
  }
}