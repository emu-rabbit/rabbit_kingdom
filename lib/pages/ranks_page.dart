import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/extensions/get_interface.dart';
import 'package:rabbit_kingdom/extensions/list.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/popups/rank_info_popup.dart';
import 'package:rabbit_kingdom/values/caches.dart';
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
            height: getFromDp(60),
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
                            c.rankData.value!,
                            c.selfData.value
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
  final selfData = Rxn<RankSingleData>();

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
      rankData.value = await Caches
        .ranksData[selectedRank.value]![selectedType.value]
        !.getData()
        .then((cache) => cache.data);
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (
        uid != null &&
        !rankData.value!.any((d) => d.uid == uid)
      ) {
        final rank = kingdomRanks[selectedRank.value];
        selfData.value = await rank!.getSelfData(selectedType.value);
      } else {
        selfData.value = null;
      }
    } catch (e) {
      rankData.value = [];
      RSnackBar.error("抓取失敗", e.toString());
    } finally {
      RLoading.stop();
    }
  }
}
class RankViewer extends StatefulWidget {
  final RankData data;
  final RankSingleData? self;
  final KingdomRank rank;
  const RankViewer(this.rank, this.data, this.self, {super.key});

  @override
  State<RankViewer> createState() => _RankViewerState();
}

class _RankViewerState extends State<RankViewer> {
  // 儲存計算後的最大寬度
  double _maxFormattedValueWidth = vw(20); // 預設值

  @override
  void initState() {
    super.initState();
    // 在組件第一次建立時進行計算
    _calculateMaxFormattedValueWidth();
  }

  @override
  void didUpdateWidget(covariant RankViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 當傳入的 data 或 self 屬性改變時，重新計算
    if (widget.data != oldWidget.data || widget.self != oldWidget.self) {
      _calculateMaxFormattedValueWidth();
    }
  }

  void _calculateMaxFormattedValueWidth() {
    double maxWidth = 0.0;

    // 遍歷所有需要測量的項目（第四名之後的及 self）
    final List<RankSingleData> itemsToMeasure = [];
    if (widget.data.length > 3) {
      itemsToMeasure.addAll(widget.data.sublist(3));
    }
    if (widget.self != null) {
      itemsToMeasure.add(widget.self!);
    }

    if (itemsToMeasure.isEmpty) {
      // 如果沒有需要測量的項目，使用預設值並返回
      setState(() {
        _maxFormattedValueWidth = vw(20);
      });
      return;
    }

    // 取得用於測量的 TextStyle
    const textStyle = TextStyle(fontSize: 16); // 假設 RText.titleMedium 的字體大小

    // 使用 TextPainter 測量每個 formattedValue 的寬度
    for (var item in itemsToMeasure) {
      final textPainter = TextPainter(
        text: TextSpan(text: item.formattedValue, style: textStyle),
        textDirection: TextDirection.ltr,
        textScaleFactor: 1.0,
      );
      textPainter.layout();
      if (textPainter.width > maxWidth) {
        maxWidth = textPainter.width;
      }
    }

    // 增加一些額外的空間，確保文字不會太擁擠
    final double padding = 20;

    // 更新狀態，觸發 build 方法重新繪製
    setState(() {
      _maxFormattedValueWidth = maxWidth + padding;
    });
  }

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
            widget.rank.descriptionBuilder(),
            const RSpace(),
            // 第一名
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
                        RText.headlineLarge(widget.data.firstOrNull?.name ?? "-", textAlign: TextAlign.center,),
                        const RSpace(),
                        RText.headlineLarge(widget.data.firstOrNull?.formattedValue ?? "-")
                      ],
                    )
                )
              ],
            ),
            const RSpace(type: RSpaceType.large,),
            // 第二名
            if (widget.data.get(1) != null)
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
                          RText.headlineMedium(widget.data.get(1)?.name ?? "-", maxLines: 2, textAlign: TextAlign.center,),
                          const RSpace(type: RSpaceType.small,),
                          RText.headlineMedium(widget.data.get(1)?.formattedValue ?? "-")
                        ],
                      )
                  )
                ],
              ),
            const RSpace(type: RSpaceType.large,),
            // 第三名
            if (widget.data.get(2) != null)
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
                          RText.headlineMedium(widget.data.get(2)?.name ?? "-", maxLines: 2, textAlign: TextAlign.center,),
                          const RSpace(type: RSpaceType.small,),
                          RText.headlineMedium(widget.data.get(2)?.formattedValue ?? "-")
                        ],
                      )
                  )
                ],
              ),
            const RSpace(),
            // 第四名之後的排名
            if (widget.data.length > 3)
              ...widget.data.sublist(3).asMap().entries.map((entry) {
                final key = entry.key;
                final value = entry.value;
                return SizedBox(
                  width: vw(80),
                  height: vw(8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: vw(10),
                        child: RText.titleMedium("${key+4}th"),
                      ),
                      RText.titleMedium(value.name),
                      SizedBox(
                        // 應用計算後的最大寬度
                        width: _maxFormattedValueWidth,
                        child: RText.titleMedium(value.formattedValue, textAlign: TextAlign.right,),
                      ),
                    ],
                  ),
                );
              }),
            // 自己的排名
            if (widget.self != null)
              SizedBox(
                width: vw(80),
                height: vw(8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: vw(10),
                      child: RText.titleMedium("---"),
                    ),
                    RText.titleMedium(widget.self!.name),
                    SizedBox(
                      // 應用計算後的最大寬度
                      width: _maxFormattedValueWidth,
                      child: RText.titleMedium(widget.self!.formattedValue, textAlign: TextAlign.right,),
                    ),
                  ],
                ),
              ),
            SizedBox(height: vw(15),)
          ],
        ),
      ),
    );
  }
}
