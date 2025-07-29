import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/widgets/r_icon_button.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class RAmountInput extends StatelessWidget {
  final RAmountInputController controller;
  late final Widget Function(int) _valueBuilder;
  RAmountInput({super.key, required this.controller, Widget Function(int)? valueBuilder}) {
    _valueBuilder = valueBuilder ?? (v) => RText.displaySmall(v.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RIconButton(
          icon: FontAwesomeIcons.anglesLeft,
          size: vmin(6),
          onPress: () => controller.decrease(amount: 10)
        ),
        RSpace(),
        RIconButton(
          icon: FontAwesomeIcons.angleLeft,
          size: vmin(6),
          onPress: () => controller.decrease()
        ),
        RSpace(type: RSpaceType.large,),
        RSpace(),
        Obx((){
          return _valueBuilder(controller.value);
        }),
        RSpace(),
        RSpace(type: RSpaceType.large,),
        RIconButton(
            icon: FontAwesomeIcons.angleRight,
            size: vmin(6),
            onPress: () => controller.increase()
        ),
        RSpace(),
        RIconButton(
            icon: FontAwesomeIcons.anglesRight,
            size: vmin(6),
            onPress: () => controller.increase(amount: 10)
        ),
      ],
    );
  }
}

class RAmountInputController extends GetxController {
  late final Rx<int> _value;
  int get value => _value.value;
  RAmountInputController({ int defaultValue = 1 }) {
    _value = Rx<int>(defaultValue);
  }

  void increase({int amount = 1}) {
    _value.value += amount;
  }

  void decrease({int amount = 1}) {
    if (_value.value - amount < 1) {
      _value.value = 1;
      return;
    }
    _value.value -= amount;
  }
}