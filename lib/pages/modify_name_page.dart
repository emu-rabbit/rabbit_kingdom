import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/auth_controller.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/values/consts.dart';
import 'package:rabbit_kingdom/values/prices.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_money.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_text_input.dart';

import '../helpers/screen.dart';
import '../widgets/r_space.dart';
import '../widgets/r_text.dart';

class ModifyNamePage extends StatelessWidget {
  const ModifyNamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final authController = Get.find<AuthController>();
    final nameController = RTextInputController();

    return RLayoutWithHeader(
      "",
      topRight: RMoney(types: [MoneyType.coin],),
      child: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx((){
                return RText.titleLarge(userController.user?.name ?? "未命名");
              }),
              RSpace(type: RSpaceType.small,),
              RText.labelSmall("兔兔公務員看了你的護照，念出了你的名字"),
              RSpace(),
              Image.asset(
                "lib/assets/images/modify_name.png",
                width: mainImageSize(),
                height: mainImageSize(),
              ),
              RSpace(),
              SizedBox(
                width: vw(70),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx((){
                      if (
                      authController.firebaseUser.value?.displayName == userController.user?.name ||
                          userController.user?.name == Consts.defaultUserName
                      ) {
                        return RText.titleSmall("看來是第一次改名呢，這次是免費唷！");
                      }
                      return RText.titleSmall("改名的話，這邊要跟你收費${Prices.modifyName}兔兔幣唷");
                    }),
                    RSpace(),
                    RTextInput(label: "新名字", controller: nameController, maxLength: 10,),
                    RSpace(),
                    Obx((){
                      return RButton.primary(
                          text: "申請改名",
                          isDisabled: nameController.text.value.isEmpty,
                          onPressed: () async {
                            if (nameController.text.value.isNotEmpty) {
                              try {
                                RLoading.start();
                                await userController.changeName(
                                    nameController.text.value,
                                    !(authController.firebaseUser.value?.displayName == userController.user?.name ||
                                        userController.user?.name == Consts.defaultUserName)
                                );
                                Get.back();
                                RSnackBar.show("更名成功", "邁上新的旅途吧！");
                              } catch(e) {
                                RSnackBar.error("更名失敗", e.toString());
                              } finally {
                                RLoading.stop();
                              }
                            }
                          });
                    })
                  ],
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}