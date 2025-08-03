import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/values/kingdom_ranks.dart';
import 'package:rabbit_kingdom/widgets/r_custom_dropdown.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

import '../values/app_text_styles.dart';
import '../widgets/r_icon_button.dart';
import '../widgets/r_layout.dart';

class RanksPage extends StatelessWidget {
  const RanksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(RankPageController());

    return RLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            height: AppTextStyle.getFromDp(60),
            child: Stack(
              children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child: RIconButton.back()
                ),
                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx((){
                        return RCustomDropdown(
                          items: RankName.values,
                          selectedItem: c.selectedRank.value,
                          onChanged: (value) => { c.selectedRank.value = value },
                          stringify: (value) => value.toDisplayString(),
                        );
                      }),
                    ],
                  )
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Obx((){
                        return c.rankData.value != null ?
                        c.rankData.value!.isNotEmpty ?
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...c
                                .rankData
                                .value
                            !.map((data) {
                              return Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: vw(40),
                                    child: RText.titleLarge(data.name),
                                  ),
                                  RText.titleLarge(data.value.toStringAsFixed(2)),
                                ],
                              );
                            })
                          ],
                        )
                            : Center(
                          child: RText.titleLarge("目前沒有資料QQ"),
                        )
                            : Center(
                          child: RText.titleLarge("載入中..."),
                        );
                      }),
                    ),
                  )
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: GestureDetector(
                      onTap: (){
                        if (c.selectedType.value == RankType.all) {
                          c.selectedType.value = RankType.currentMonth;
                        } else {
                          c.selectedType.value = RankType.all;
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                        ),
                        child: Obx((){
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: c.selectedType.value == RankType.all ?
                                  AppColors.surfaceContainerHigh : Colors.transparent,
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                ),
                                child: RText.titleMedium("總排行"),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: c.selectedType.value == RankType.currentMonth ?
                                  AppColors.surfaceContainerHigh : Colors.transparent,
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                ),
                                child: RText.titleMedium("月排行"),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                )
              ],
            )
          )
        ],
      )
    );
  }
}

class RankPageController extends GetxController {
  final selectedRank = RankName.property.obs;
  final selectedType = RankType.all.obs;
  final rankData = Rxn<RankData>();

  @override
  void onReady() {
    super.onReady();
    fetchData();
    ever(selectedRank, (_) => fetchData());
    ever(selectedType, (_) => fetchData());
  }

  Future<void> fetchData() async {
    try {
      rankData.value = null;
      RLoading.start();
      final rank = kingdomRanks[selectedRank.value];
      rankData.value = rank != null ?
        await rank.getRank(selectedType.value):
        [];
    } catch (e) {
      rankData.value = [];
      RSnackBar.error("抓取失敗", e.toString());
    } finally {
      RLoading.stop();
    }
  }
}
