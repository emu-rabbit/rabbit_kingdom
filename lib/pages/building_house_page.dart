import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/auth_controller.dart';
import 'package:rabbit_kingdom/controllers/theme_controller.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/widgets/r_button_group.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RText.titleLarge("你回到了溫暖的窩"),
            RSpace(type: RSpaceType.small,),
            RText.labelSmall("看了混亂的房間，你決定明天再打掃"),
            RSpace(),
            Image.asset(
              "lib/assets/images/house_0.png",
              width: vmin(70),
              height: vmin(70),
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
              "滿地混亂的行李",
              [
                RButtonData(
                  text: "收拾行李並出境",
                  onPress: () async {
                    RLoading.start();
                    await authController.logout();
                    RLoading.stop();
                  }
                )
              ]
            )
          ],
        ),
      )
    );
  }
}