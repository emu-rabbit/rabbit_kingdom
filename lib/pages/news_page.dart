import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/helpers/collection_names.dart';
import 'package:rabbit_kingdom/models/trading_news.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_news_viewer.dart';
import 'package:rabbit_kingdom/widgets/r_snack_bar.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

import '../helpers/app_colors.dart';
import '../helpers/screen.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(_NewsController());

    return RLayoutWithHeader(
      "交易所新聞",
      child: Obx((){
        if (controller.news.value == null) {
          return Center(
            child: SizedBox(
              width: vmin(20) * deviceFactor(),
              height: vmin(20) * deviceFactor(),
              child: CircularProgressIndicator(
                strokeWidth: vmin(2),
                color: AppColors.primary,
              ),
            )
          );
        }
        if (controller.news.value!.isEmpty) {
          return Center(
            child: RText.titleMedium("目前沒有資料QQ"),
          );
        }
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...controller
                .news
                .value
                !.map((n) => [
                  RNewsViewer(news: n),
                  RSpace()
                ]).expand((e) => e)
            ],
          ),
        );
      })
    );
  }
}

class _NewsController extends GetxController {
  final news = Rxn<List<TradingNewsWithID>>();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _newsListener;

  @override
  void onReady() {
    super.onReady();

    _newsListener = FirebaseFirestore
      .instance
      .collection(CollectionNames.news)
      .orderBy('createAt', descending: true)
      .limit(10)
      .snapshots()
      .listen((data) {
        news.value = data
          .docs
          .map((doc) {
            final n = TradingNews.fromJson(doc.data());
            return TradingNewsWithID.create(doc.id, n);
          })
          .toList();
    });
    _newsListener!.onError((e) {
      RSnackBar.error("抓取失敗", e.toString());
    });
  }

  @override
  void onClose() {
    _newsListener?.cancel(); // 清除監聽
    super.onClose();
  }
}