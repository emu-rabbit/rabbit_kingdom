import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/auth_controller.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/helpers/cloud_functions.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_fade_in_column.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_money.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_text_input.dart';

import '../controllers/app_config_controller.dart';
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
    final config = Get.find<AppConfigController>().config;
    final priceModifyName = config?.priceModifyName ?? 100;

    return RLayoutWithHeader(
      "",
      topRight: RMoney(types: [MoneyType.coin],),
      child: Center(
        child: SingleChildScrollView(
          child: RFadeInColumn(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx((){
                return RText.headlineLarge(userController.user?.name ?? "未命名");
              }),
              RSpace(type: RSpaceType.small,),
              RText.bodySmall("兔兔公務員看了你的護照，念出了你的名字"),
              RSpace(),
              Image.asset(
                "lib/assets/images/modify_name.png",
                width: mainImageSize(),
                height: mainImageSize(),
              ),
              RSpace(),
              SizedBox(
                width: vw(75) * deviceFactor(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx((){
                      if (
                      authController.firebaseUser.value?.displayName == userController.user?.name ||
                          userController.user?.name == "未命名"
                      ) {
                        return RText.titleSmall("看來是第一次改名呢，這次是免費唷！");
                      }
                      return RText.titleSmall("改名的話，這邊要跟你收費$priceModifyName兔兔幣唷");
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
                                await CloudFunctions.modifyName(nameController.text.value);
                                Get.back();
                                RSnackBar.show("更名成功", "邁上新的旅途吧！");
                              } on FirebaseFunctionsException catch(e) {
                                RSnackBar.error("更名失敗", e.message ?? e.code);
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