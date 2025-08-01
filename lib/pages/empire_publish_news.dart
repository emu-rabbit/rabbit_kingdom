import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/prices_controller.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/models/trading_news.dart';
import 'package:rabbit_kingdom/services/empire_service.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_news_viewer.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';
import 'package:rabbit_kingdom/widgets/r_text_input.dart';

class EmpirePublishNews extends StatelessWidget {
  const EmpirePublishNews({super.key});

  @override
  Widget build(BuildContext context) {
    final priceController = RTextInputController();
    final titleController = RTextInputController();
    final contentController = RTextInputController();
    final news = Rxn<TradingNews>();

    return RLayoutWithHeader(
      "干預精華價格",
      child: SingleChildScrollView(
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
            RText.titleLarge("新聞"),
            RSpace(),
            SizedBox(
                width: vw(60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RTextInput(controller: priceController, label: "新買入價", keyboardType: TextInputType.number,),
                    RSpace(type: RSpaceType.small,),
                    RTextInput(controller: titleController, label: "標題",),
                    RSpace(type: RSpaceType.small,),
                    RTextInput(controller: contentController, label: "內容",),
                  ],
                )
            ),
            RSpace(),
            GetBuilder<PricesController>(
              builder: (pc) {
                return pc.prices != null ? SizedBox(
                  width: vw(60),
                  child: RButton.primary(
                      text: "預覽新聞",
                      onPressed: () async {
                        final newPrice = int.tryParse(priceController.text.value);
                        if (newPrice != null &&
                            titleController.text.value.isNotEmpty &&
                            contentController.text.value.isNotEmpty
                        ) {
                          news.value = TradingNews.create(
                              originalPrice: pc.prices!.buy,
                              newPrice: newPrice,
                              title: titleController.text.value,
                              content: contentController.text.value
                          );
                        }
                      }
                  ),
                ): RText.titleLarge("抓不到價格資料");
              }
            ),
            RSpace(),
            Obx((){
              return news.value != null ?
                RNewsViewer(
                    news: news.value!
                ): SizedBox.shrink();
            }),
            RSpace(),
            SizedBox(
              width: vw(60),
              child: Obx((){
                return news.value != null ?
                RButton.primary(
                    text: "送出",
                    onPressed: () async {
                      try {
                        RLoading.start();
                        await EmpireService.publishNews(news.value!);
                        RSnackBar.show("干預成功", "今天也是邪惡的一天");
                      } catch (e) {
                        RSnackBar.error("干預失敗", e.toString());
                      } finally {
                        RLoading.stop();
                      }
                    }
                ): SizedBox.shrink();
              }),
            )
          ],
        ),
      )
    );
  }
}