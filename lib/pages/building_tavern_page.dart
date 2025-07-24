import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/pages/tasks_page.dart';
import 'package:rabbit_kingdom/widgets/r_button_group.dart';

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RText.titleLarge("酒館的們咿呀的一聲開了"),
              RSpace(type: RSpaceType.small,),
              RText.labelSmall("撲鼻而來的酒氣和歡鬧的氣氛衝你而來"),
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
              )
            ],
          ),
        )
    );
  }
}