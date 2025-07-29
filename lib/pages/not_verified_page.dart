import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../helpers/screen.dart';
import '../widgets/r_button.dart';
import '../widgets/r_layout.dart';
import '../widgets/r_loading.dart';
import '../widgets/r_space.dart';
import '../widgets/r_text.dart';

class NotVerifiedPage extends StatelessWidget {
  NotVerifiedPage({super.key});

  final RxInt cooldown = 0.obs;

  void startCooldown() {
    if (cooldown.value == 0) {
      cooldown.value = 60;
      // 每秒倒數
      Stream.periodic(const Duration(seconds: 1), (x) => 59 - x)
          .take(60)
          .listen((value) {
        cooldown.value = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return RLayout(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RText.displaySmall("喔不，這地址還沒驗證"),
            RSpace(),
            RText.bodyMedium("兔兔大帝可以請紅燒雞"),
            RText.bodyMedium("寄送驗證信"),
            Image.asset(
              'lib/assets/images/red_parrot_0.png',
              width: mainImageSize(),
              height: mainImageSize(),
              fit: BoxFit.cover,
            ),
            RSpace(),
            RText.labelSmall("據說笨蛋紅燒雞可能會不小心丟進垃圾郵件夾...", textAlign: TextAlign.center,),
            RSpace(),
            SizedBox(
              width: vw(60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(() => RButton.surface(
                    isDisabled: cooldown.value > 0,
                    onPressed: () async {
                      startCooldown();
                      RLoading.start();
                      await authController.sendVerificationEmail();
                      RLoading.stop();
                    },
                    child: (color) => RText.bodyLarge(
                        cooldown.value == 0
                            ? "去吧紅燒雞！"
                            : "請稍候 ${cooldown.value} 秒",
                        textAlign: TextAlign.center),
                  )),
                  RSpace(),
                  RButton.primary(
                    onPressed: () async {
                      authController.firebaseUser.value?.reload();
                    },
                    child: (color) => RText.bodyLarge(
                        "我剛剛認證了！",
                        textAlign: TextAlign.center
                    ),
                  ),
                  RSpace(type: RSpaceType.large,),
                  RText.bodySmall("或是...", textAlign: TextAlign.center,),
                  RSpace(),
                  RButton.secondary(
                      onPressed: () async {
                        RLoading.start();
                        await authController.logout();
                        RLoading.stop();
                      },
                      child: (color) =>
                          RText.bodyLarge("返回城門", textAlign: TextAlign.center, color: color,)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
