import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/extensions/get_interface.dart';
import 'package:rabbit_kingdom/extensions/list.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/popups/rank_info_popup.dart';
import 'package:rabbit_kingdom/values/kingdom_ranks.dart';
import 'package:rabbit_kingdom/widgets/r_custom_dropdown.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
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
                Align(
                  alignment: Alignment.centerRight,
                  child: RIconButton(
                    icon: FontAwesomeIcons.circleQuestion,
                    onPress: (){
                      Get.rPopup(RRankInfoPopup());
                    },
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    child: Obx((){
                      return c.rankData.value != null ?
                        c.rankData.value!.isNotEmpty ?
                          RankViewer(
                            kingdomRanks[c.selectedRank.value]!,
                            c.rankData.value!
                          ):
                          Center(child: RText.titleLarge("目前沒有資料QQ")):
                          Center(child: RText.titleLarge("載入中..."));
                    }),
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

class RankViewer extends StatelessWidget {
  final RankData data;
  final KingdomRank rank;
  const RankViewer(this.rank, this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    final firstPlaceImageSize = vw(35);
    final secondPlaceImageSize = vw(25);

    return Center(
      child: SizedBox(
        width: vw(90),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            rank.descriptionBuilder(),
            RSpace(),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Image.asset(
                  'lib/assets/images/no1.png',
                  width: firstPlaceImageSize,
                  height: firstPlaceImageSize,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RText.headlineLarge(data.firstOrNull?.name ?? "-", textAlign: TextAlign.center,),
                      RSpace(),
                      RText.headlineLarge(data.firstOrNull?.formattedValue ?? "-")
                    ],
                  )
                )
              ],
            ),
            RSpace(type: RSpaceType.large,),
            data.get(1) != null ?
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.asset(
                    'lib/assets/images/no2.png',
                    width: secondPlaceImageSize,
                    height: secondPlaceImageSize,
                  ),
                  SizedBox(width: firstPlaceImageSize - secondPlaceImageSize,),
                  Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RText.headlineMedium(data.get(1)?.name ?? "-", maxLines: 2, textAlign: TextAlign.center,),
                          RSpace(type: RSpaceType.small,),
                          RText.headlineMedium(data.get(1)?.formattedValue ?? "-")
                        ],
                      )
                  )
                ],
              ): SizedBox.shrink(),
            RSpace(type: RSpaceType.large,),
            data.get(2) != null ?
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Image.asset(
                    'lib/assets/images/no3.png',
                    width: secondPlaceImageSize,
                    height: secondPlaceImageSize,
                  ),
                  SizedBox(width: firstPlaceImageSize - secondPlaceImageSize,),
                  Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RText.headlineMedium(data.get(2)?.name ?? "-", maxLines: 2, textAlign: TextAlign.center,),
                          RSpace(type: RSpaceType.small,),
                          RText.headlineMedium(data.get(2)?.formattedValue ?? "-")
                        ],
                      )
                  )
                ],
              ): SizedBox.shrink(),
            RSpace(),
            ...(data.length > 3 ?
              data
                .sublist(3)
                .asMap()
                .entries
                .map((entry) {
                  final key = entry.key;
                  final value = entry.value;
                  return SizedBox(
                    width: vw(77),
                    height: vw(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RText.titleMedium("${key+4}th"),
                        RText.titleMedium(value.name),
                        RText.titleMedium(value.formattedValue)
                      ],
                    ),
                  );
              }): [SizedBox.shrink()]),
            SizedBox(height: vw(15),)
          ],
        ),
      ),
    );
  }
}
