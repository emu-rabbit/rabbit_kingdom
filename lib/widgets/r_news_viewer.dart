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
import 'package:rabbit_kingdom/widgets/r_icon.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

import '../helpers/app_colors.dart';

class RNewsViewer extends StatelessWidget {
  final TradingNews news;
  const RNewsViewer({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final change = news.newPrice - news.originalPrice;
    final changePercent = (change / news.originalPrice) * 100;
    final color = change < 0 ? AppColors.green : AppColors.red;
    final isGood = news.goods.length > news.bads.length;
    final totalReacts = news.goods.length + news.bads.length;
    final reactsPercent = (isGood ? news.goods.length : news.bads.length) / (totalReacts == 0 ? 1 : totalReacts) * 100;

    return Container(
      width: vw(90),
      decoration: BoxDecoration(
          color: color.withAlpha(20),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomRight: Radius.circular(20))
      ),
      child: Column(
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
      ),
    );
  }
}