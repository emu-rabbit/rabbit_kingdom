import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/widgets/r_popup.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class BudgetPopup extends StatelessWidget {
  const BudgetPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return RPopup(
      title: "安全感小錢包",
      child: GetBuilder<UserController>(
        builder: (userController) {
          return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _BudgetRow(imagePath: "lib/assets/images/money_bag.png", name: "總資產", value: userController.user?.budget.property ?? 0),
                RSpace(),
                _BudgetRow(imagePath: "lib/assets/images/rabbit_coin.png", name: "兔兔幣", value: userController.user?.budget.coin ?? 0),
                RSpace(),
                _BudgetRow(imagePath: "lib/assets/images/empire_poop.png", name: "兔兔精華", value: userController.user?.budget.poop ?? 0),
              ]
          );
        },
      )
    );
  }
}

class _BudgetRow extends StatelessWidget {
  final String imagePath;
  final String name;
  final int value;
  const _BudgetRow({ required this.imagePath, required this.name, required this.value });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          imagePath,
          width: 20,
          height: 20,
        ),
        RSpace(type: RSpaceType.small,),
        RText.bodyMedium("($name): $value", color: AppColors.onSecondary,),
      ],
    );
  }
}