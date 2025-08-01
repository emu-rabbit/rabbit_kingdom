import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/theme_controller.dart';
import 'package:rabbit_kingdom/extensions/date_time.dart';
import 'package:rabbit_kingdom/extensions/double.dart';
import 'package:rabbit_kingdom/extensions/int.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/models/trading_news.dart';
import 'package:rabbit_kingdom/services/kingdom_user_service.dart';
import 'package:rabbit_kingdom/widgets/r_icon.dart';
import 'package:rabbit_kingdom/widgets/r_loading.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

import '../helpers/app_colors.dart';

class RNewsViewer extends StatefulWidget {
  final TradingNews news;
  const RNewsViewer({super.key, required this.news});

  @override
  State<RNewsViewer> createState() => _RNewsViewerState();
}

class _RNewsViewerState extends State<RNewsViewer> with SingleTickerProviderStateMixin {
  bool _showInfo = true;

  @override
  Widget build(BuildContext context) {
    final change = widget.news.newPrice - widget.news.originalPrice;
    final color = change < 0 ? AppColors.green : AppColors.red;

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: vw(90),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          // 資訊層
          AnimatedOpacity(
            opacity: _showInfo ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: (){
                if (_showInfo == true) {
                  setState(() {
                    _showInfo = false;
                  });
                }
              },
              child: _NewsInfo(widget.news),
            ),
          ),
          !_showInfo ?
            // 互動層
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: _showInfo ? 0.0 : 1.0,
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _NewsReactor(
                  widget.news,
                  requestOut: (){
                    if (_showInfo == false) {
                      setState(() {
                        _showInfo = true;
                      });
                    }
                  },
                ),
              )
            ): SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _NewsInfo extends StatelessWidget {
  final TradingNews news;
  const _NewsInfo(this.news);

  @override
  Widget build(BuildContext context) {
    final change = news.newPrice - news.originalPrice;
    final changePercent = (change / news.originalPrice) * 100;
    final color = change < 0 ? AppColors.green : AppColors.red;
    final isGood = news.goods.length > news.bads.length;
    final totalReacts = news.goods.length + news.bads.length;
    final reactsPercent = (isGood ? news.goods.length : news.bads.length) / (totalReacts == 0 ? 1 : totalReacts) * 100;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
              color: color.withAlpha(50),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20))
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RText.headlineLarge(news.title, color: color,),
              RText.titleSmall(news.createAt.toRelativeTimeString(), color: color,)
            ],
          ),
        ),
        Divider(color: color.withAlpha(80), thickness: 1, height: 1,),
        Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 20),
          color: color.withAlpha(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RSpace(),
              RText.bodyMedium(news.content, maxLines: 4, color: color.withAlpha(240),),
              RSpace(),
              RText.labelMedium(
                "兔兔精華新價格：${news.newPrice}，漲跌幅：${change.toSignedString()} (${changePercent.toSignedString()}%)",
                color: color.withAlpha(220),
              ),
              RSpace(),
              Divider(color: color.withAlpha(100), thickness: 1,),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  totalReacts > 0 ?
                  RIcon(isGood ? FontAwesomeIcons.thumbsUp : FontAwesomeIcons.thumbsDown, color: color, size: vw(4),):
                  SizedBox.shrink(),
                  totalReacts > 0 ? RSpace() : SizedBox.shrink(),
                  totalReacts > 0 ?
                  RText.bodySmall("${reactsPercent.toStringAsFixed(0)}%的人覺得這新聞很${isGood ? "讚": "爛"}", color: color):
                  RText.bodySmall("目前沒有人對這則新聞做出反應", color: color.withAlpha(180))
                ],
              )
            ],
          ),
        )
      ],
    );
  }
  
}

class _NewsReactor extends StatelessWidget {
  final TradingNews news;
  final Function requestOut;
  const _NewsReactor(this.news, { required this.requestOut });

  @override
  Widget build(BuildContext context) {
    final change = news.newPrice - news.originalPrice;
    final color = change < 0 ? AppColors.green : AppColors.red;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => requestOut(),
        child: Center(
          child: RText.titleLarge("抓不到使用者資料", color: color,),
        ),
      );
    }
    final reactedWithGood = news.goods.contains(uid);
    final reactedWithBad = news.bads.contains(uid);
    if (reactedWithGood || reactedWithBad) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => requestOut(),
        child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RIcon(reactedWithGood ? FontAwesomeIcons.thumbsUp : FontAwesomeIcons.thumbsDown, color: color, size: vw(8),),
                RSpace(),
                RText.displaySmall("你覺得這新聞很${reactedWithGood ? "讚": "爛"}", color: color)
              ],
            )
        ),
      );
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                    child: GestureDetector(
                      onTap: () => reactWith(true),
                      child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RIcon(FontAwesomeIcons.thumbsUp, color: color, size: vw(8),),
                            RSpace(),
                            RText.displaySmall("讚透了", color: color)
                          ]
                      ),
                    )
                ),
                VerticalDivider(color: color.withAlpha(100), thickness: 1, width: 1,),
                Expanded(
                    child: GestureDetector(
                      onTap: () => reactWith(false),
                      child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RIcon(FontAwesomeIcons.thumbsDown, color: color, size: vw(8),),
                            RSpace(),
                            RText.displaySmall("爛死了", color: color)
                          ]
                      ),
                    )
                )
              ],
            ),
          ),
          Divider(color: color.withAlpha(100), thickness: 1, height: 1,),
          GestureDetector(
            onTap: () => requestOut(),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: RText.headlineLarge("我沒啥感覺 030", color: color,),
                )
              ],
            ),
          )
        ],
      )
    );
  }

  Future<void> reactWith(bool good) async {
    if (news is! TradingNewsWithID) {
      RSnackBar.error("反應失敗", "新聞遺失重要資料");
      requestOut();
    }
    final newsId = (news as TradingNewsWithID).id;
    try {
      RLoading.start();
      await KingdomUserService.reactToNews(newsId, good);
      RSnackBar.show("反應成功", good ? "這個不讚不行": "氣噗噗氣噗噗");
      requestOut();
    } catch (e) {
      RSnackBar.error("反應失敗", e.toString());
    } finally {
      RLoading.stop();
    }
  }
}