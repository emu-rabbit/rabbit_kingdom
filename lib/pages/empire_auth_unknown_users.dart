import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:rabbit_kingdom/extensions/get_interface.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/popups/auth_unknown_user_popup.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_button_group.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

import '../helpers/screen.dart';
import '../services/empire_service.dart';

class EmpireAuthUnknownUsers extends StatelessWidget {
  const EmpireAuthUnknownUsers({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(_EmpireAuthController());

    return RLayoutWithHeader(
      "授權旅人",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(() {
            if (controller.unknownUsers.isEmpty) {
              return RText.titleMedium("目前沒有未知旅人");
            }

            return Column(
              children: controller
                  .unknownUsers
                  .map((user) {
                return Column(
                  children: [
                    _UnknownUserCard(
                      user: user,
                      onPress: () async {
                        final result = await Get.rPopup(AuthUnknownUserPopup(user));
                        if (result == true) {
                          controller.popUser(user);
                        }
                      }
                    ),
                    RSpace()
                  ],
                );
              }).toList(),
            );
          }),
          RSpace(),
          RButtonGroup(
            "",
            [
              RButtonData(text: "拉取新旅人", onPress: (){ controller.fetchUnknownUsers(); })
            ]
          ),
        ],
      )
    );
  }
}

class _UnknownUserCard extends StatelessWidget {
  final UnknownUserData user;
  final Function() onPress;
  const _UnknownUserCard({ required this.user, required this.onPress });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: vw(80) * deviceFactor(),
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          border: Border.all(
              color: AppColors.outline,
              width: 2
          ),
          borderRadius: BorderRadius.all(Radius.circular(20))
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RText.titleLarge(user.name),
          RText.titleSmall(user.email, maxLines: 2,),
          RSpace(),
          RButton.secondary(
              onPressed: onPress,
              child: (color) {
                return RText.bodySmall("通過申請", color: color,);
              }
          ),
        ],
      ),
    );
  }
}

class _EmpireAuthController extends GetxController {
  final unknownUsers = <UnknownUserData>[].obs;

  Future<void> fetchUnknownUsers() async {
    RLoading.start();
    try {
      final users = await EmpireService.getUnknownUsers();
      unknownUsers.assignAll(users);
    } catch (e) {
      RSnackBar.error("抓取失敗", e.toString());
    } finally {
      RLoading.stop();
    }
  }

  void popUser(UnknownUserData user) {
    unknownUsers.remove(user);
  }
}