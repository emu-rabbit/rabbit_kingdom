import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/extensions/get_interface.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/pages/tasks_page.dart';
import 'package:rabbit_kingdom/values/prices.dart';
import 'package:rabbit_kingdom/widgets/r_button_group.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_money.dart';
import 'package:rabbit_kingdom/widgets/r_popup.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';

import '../helpers/screen.dart';
import '../widgets/r_layout_with_header.dart';
import '../widgets/r_space.dart';
import '../widgets/r_text.dart';

class BuildingTavernPage extends StatelessWidget {
  const BuildingTavernPage({super.key});

  @override
  Widget build(BuildContext context) {
    return RLayoutWithHeader(
        "",
        topRight: RMoney(types: [MoneyType.coin],),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RText.headlineLarge("酒館的門咿呀的一聲開了"),
              RSpace(type: RSpaceType.small,),
              RText.bodySmall("撲鼻而來的酒氣和歡鬧的氣氛衝你而來"),
              RSpace(),
              Image.asset(
                "lib/assets/images/tavern_0.png",
                width: mainImageSize(),
                height: mainImageSize(),
              ),
              RSpace(type: RSpaceType.large,),
              RButtonGroup(
                "牆上貼著密密麻麻的紙片",
                [
                  RButtonData(text: "查看任務區", onPress: (){ Get.to(() => TasksPage()); })
                ]
              ),
              RSpace(type: RSpaceType.large,),
              RButtonGroup(
                '吧檯後面的酒保微笑地看著你',
                [
                  RButtonData(
                    child: (color) {
                      return Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RText.bodyLarge("來一杯吧 (", color: color,),
                          Image.asset(
                            "lib/assets/images/rabbit_coin.png",
                            width: vw(6),
                            height: vw(6),
                          ),
                          RText.bodyLarge("-${Prices.drink})", color: color,),
                        ],
                      );
                    },
                    onPress: () async {
                      try {
                        RLoading.start();
                        final c = Get.find<UserController>();
                        await c.drink();
                        Get.rPopup(
                          RPopup(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                RText.titleMedium("你覺得有點暈...", color: AppColors.onSecondary,),
                                RText.titleMedium("視線開始模糊...", color: AppColors.onSecondary,)
                              ],
                            )
                          )
                        );
                      } catch (e) {
                        RSnackBar.error("喝不到酒QQ", e.toString());
                      } finally {
                        RLoading.stop();
                      }
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