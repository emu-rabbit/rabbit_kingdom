import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/prices_controller.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/services/empire_service.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';
import 'package:rabbit_kingdom/widgets/r_text_input.dart';

class EmpireSetPrices extends StatelessWidget {
  const EmpireSetPrices({super.key});

  @override
  Widget build(BuildContext context) {
    final priceController = RTextInputController();

    return RLayoutWithHeader(
      "干預精華價格",
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RText.titleLarge("當前價格"),
          RSpace(),
          GetBuilder<PricesController>(
            builder: (pc) {
              return RText.bodyMedium("買入：${pc.prices?.buy ?? "-"} | 賣出：${pc.prices?.sell ?? "-"}");
            }
          ),
          RSpace(type: RSpaceType.large,),
          RText.titleLarge("修改價格為"),
          RSpace(),
          SizedBox(
            width: vw(60),
            child: RTextInput(controller: priceController, label: "買入價", keyboardType: TextInputType.number,),
          ),
          RSpace(),
          Obx((){
            final buyPrice = int.tryParse(priceController.text.value);
            final sellPrice = buyPrice != null ? buyPrice + 6 : null;
            return RText.bodyMedium("買入：${buyPrice ?? "-"} | 賣出：${sellPrice ?? "-"}");
          }),
          RSpace(),
          SizedBox(
            width: vw(60),
            child: RButton.primary(
              text: "送出",
              onPressed: () async {
                try {
                  final buyPrice = int.tryParse(priceController.text.value);
                  if (buyPrice != null) {
                    RLoading.start();
                    await EmpireService.publishNewPrices(buyPrice);
                    RSnackBar.show("干預成功", "今天也是邪惡的一天");
                  }
                } catch (e) {
                  RSnackBar.error("干預失敗", e.toString());
                } finally {
                  RLoading.stop();
                }
              }
            ),
          ),
        ],
      )
    );
  }
}