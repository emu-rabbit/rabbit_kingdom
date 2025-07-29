import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rabbit_kingdom/controllers/prices_controller.dart';
import 'package:rabbit_kingdom/extensions/int.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/models/poop_prices.dart';
import 'package:rabbit_kingdom/services/kingdom_user_service.dart';
import 'package:rabbit_kingdom/values/prices.dart';
import 'package:rabbit_kingdom/widgets/r_amount_input.dart';
import 'package:rabbit_kingdom/widgets/r_button.dart';
import 'package:rabbit_kingdom/widgets/r_dropdown.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';
import 'package:rabbit_kingdom/widgets/r_text_input.dart';

final Color colorBuy = Color(0xFFEF602B);
final Color colorSell = Color(0xFF2FBF8E);

enum TradeType { buy, sell }

class TradingPage extends StatelessWidget {
  const TradingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tc = Get.put(TradingController());
    final amountController = RAmountInputController();

    return RLayoutWithHeader(
      "兔兔精華交易所",
      child: Obx((){
        final pc = Get.find<PricesController>();
        if (tc.historyPrices.value == null) {
          return Center(
            child: RText.bodyMedium("載入資料中..."),
          );
        } else if (tc.historyPrices.value!.isEmpty || pc.prices == null) {
          return Center(
            child: RText.bodyMedium("目前沒有資料QQ"),
          );
        }
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RText.titleMedium("歷史報價"),
              RSpace(type: RSpaceType.small,),
              SizedBox(
                width: vw(90),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: HistoryChart(prices: tc.historyPrices.value!),
                ),
              ),
              RSpace(type: RSpaceType.large,),
              Divider(color: AppColors.primary.withAlpha(180),),
              RSpace(type: RSpaceType.large,),
              RText.titleMedium("最新報價"),
              RSpace(type: RSpaceType.small,),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RText.titleMedium("交易所賣出：${pc.prices!.sell ?? "-"}", color: colorSell,),
                  RSpace(type: RSpaceType.small,),
                  RText.bodyMedium(" | ", color: AppColors.onSurface,),
                  RSpace(type: RSpaceType.small,),
                  RText.titleMedium("交易所買入：${pc.prices!.buy ?? "-"}", color: colorBuy,),
                ],
              ),
              RSpace(type: RSpaceType.large,),
              Divider(color: AppColors.primary.withAlpha(180),),
              RSpace(type: RSpaceType.large,),
              RText.titleMedium("即時交易"),
              RSpace(),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RAmountInput(
                    controller: amountController,
                    valueBuilder: (v) {
                      return Transform.scale(
                        scale: 1.2,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RText.displayLarge(v.toString()),
                            RSpace(),
                            RText.displaySmall("x"),
                            RSpace(),
                            Image.asset(
                              "lib/assets/images/empire_poop.png",
                              width: vw(10),
                              height: vw(10),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  RSpace(type: RSpaceType.large,),
                  SizedBox(
                    width: vw(75),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                RButton.primary(text: "買入精華", onPressed: (){}),
                                RSpace(),
                                PreviewChange(
                                  coinChange: amountController.value * pc.prices!.sell * -1,
                                  poopChange: amountController.value
                                )
                              ],
                            )
                        ),
                        RSpace(),
                        Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                RButton.primary(text: "賣出精華", onPressed: (){}),
                                RSpace(),
                                PreviewChange(
                                    coinChange: amountController.value * pc.prices!.buy,
                                    poopChange: amountController.value * -1
                                )
                              ],
                            )
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      })
    );
  }
}

class TradingController extends GetxController {
  final historyPrices = Rxn<List<PoopPrices>>();

  @override
  void onReady() async {
    super.onReady();
    historyPrices.value = await KingdomUserService.getRecentPrices();
  }
}

class HistoryChart extends StatelessWidget {
  final List<PoopPrices> prices;
  const HistoryChart({super.key, required this.prices});

  @override
  Widget build(BuildContext context) {
    final DateTime startDate = prices.last.createAt;
    double dateToX(DateTime date) => date.difference(startDate).inMinutes.toDouble();
    DateTime xToDate(double x) => startDate.add(Duration(minutes: x.toInt()));

    final buySpots = prices.map((p) => FlSpot(dateToX(p.createAt), p.buy.toDouble())).toList();
    final sellSpots = prices.map((p) => FlSpot(dateToX(p.createAt), p.sell.toDouble())).toList();
    final minY = [...buySpots, ...sellSpots].map((e) => e.y).reduce(min) - 3;
    final maxY = [...buySpots, ...sellSpots].map((e) => e.y).reduce(max) + 3;
    
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(enabled: false),
        minY: minY,
        maxY: maxY,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) => RText.labelSmall(value.toInt().toString(), overflow: TextOverflow.visible,)
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              maxIncluded: false,
              getTitlesWidget: (value, meta) {
                final date = xToDate(value);
                final formatted = DateFormat('HH:mm').format(date); // "7/25"
                return Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: RText.labelSmall(formatted),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(
          show: true,
          border: Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide(color: AppColors.onSurface, width: 1),
            bottom: BorderSide(color: AppColors.onSurface, width: 1)
          )
        ),
        lineBarsData: [
          LineChartBarData(
            spots: buySpots,
            color: colorBuy,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: sellSpots,
            color: colorSell,
            barWidth: 3,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(show: false),
          ),
        ]
      )
    );
  }
}

class PreviewChange extends StatelessWidget {
  final int coinChange;
  final int poopChange;
  const PreviewChange({super.key,  required this.coinChange, required this.poopChange });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "lib/assets/images/empire_poop.png",
              width: vw(5),
              height: vw(5),
            ),
            RSpace(type: RSpaceType.small,),
            RText.labelLarge(poopChange.toSignedString())
          ],
        ),
        RSpace(type: RSpaceType.small,),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "lib/assets/images/rabbit_coin.png",
              width: vw(5),
              height: vw(5),
            ),
            RSpace(type: RSpaceType.small,),
            RText.labelLarge(coinChange.toSignedString())
          ],
        ),
      ],
    );
  }
}