import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/auth_controller.dart';
import 'package:rabbit_kingdom/widgets/r_layout.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

import '../helpers/screen.dart';
import '../widgets/r_button.dart';
import '../widgets/r_loading.dart';
import '../widgets/r_space.dart';

class UnknownUserPage extends StatelessWidget {
  const UnknownUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController  = Get.find<AuthController>();

    return RLayout(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RText.displaySmall("是初次入境的旅人呢"),
            RSpace(),
            Image.asset(
              'lib/assets/images/rabbit_empire_2.png',
              width: mainImageSize(),
              height: mainImageSize(),
              fit: BoxFit.cover,
            ),
            RSpace(),
            RText.bodyMedium("請將你登入的郵件告知兔兔大帝"),
            RSpace(type: RSpaceType.small,),
            RText.bodyMedium("${authController.firebaseUser.value?.email}"),
            RSpace(type: RSpaceType.large,),
            RText.bodyMedium("大帝的公文很多，請耐心稍候"),
            RSpace(type: RSpaceType.small,),
            RText.bodyMedium("公文批准後請重新登入"),
            RSpace(type: RSpaceType.large,),
            SizedBox(
              width: vw(60) * deviceFactor(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RButton.primary(
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