import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

import '../controllers/user_controller.dart';

class RMoney extends StatelessWidget {
  const RMoney({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
        builder: (userController) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'lib/assets/images/money_bag.png',
                width: 25,
                height: 25,
              ),
              SizedBox(width: 2,),
              RText.bodySmall(userController.user?.budget.propertyText ?? "0")
            ],
          );
        }
    );
  }
}