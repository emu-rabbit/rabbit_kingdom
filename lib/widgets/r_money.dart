import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:rabbit_kingdom/extensions/get_interface.dart';
import 'package:rabbit_kingdom/extensions/int.dart';
import 'package:rabbit_kingdom/popups/budget_popup.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

import '../controllers/user_controller.dart';

enum MoneyType { property, poop, coin }

class RMoney extends StatelessWidget {
  final List<MoneyType> types;
  const RMoney({ this.types = const [MoneyType.coin], super.key });

  @override
  Widget build(BuildContext context) {

    return GetBuilder<UserController>(
        builder: (userController) {
          return GestureDetector(
            onTap: () { Get.rPopup(BudgetPopup()); },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ...types.map((type) {
                  final imageName = switch(type) {
                    MoneyType.property => 'lib/assets/images/money_bag.png',
                    MoneyType.poop => 'lib/assets/images/empire_poop.png',
                    MoneyType.coin => 'lib/assets/images/rabbit_coin.png',
                  };
                  final value = switch(type) {
                    MoneyType.property => userController.user?.budget.property.toRDisplayString() ?? "0",
                    MoneyType.poop => userController.user?.budget.poop.toRDisplayString() ?? "0",
                    MoneyType.coin => userController.user?.budget.coin.toRDisplayString() ?? "0",
                  };
                  return [
                    Image.asset(
                      imageName,
                      width: 25,
                      height: 25,
                    ),
                    SizedBox(width: 2,),
                    RText.bodySmall(value),
                    RSpace(type: RSpaceType.small,),
                  ];
                }).expand((e) => e)
              ],
            ),
          );
        }
    );
  }
}