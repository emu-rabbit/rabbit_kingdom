import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/models/kingdom_announcement.dart';
import 'package:rabbit_kingdom/widgets/r_announce_viewer.dart';
import 'package:rabbit_kingdom/widgets/r_comments.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

import '../helpers/app_colors.dart';
import '../helpers/screen.dart';
import '../services/kingdom_user_service.dart';

class AnnounceHistoryPage extends StatelessWidget {
  const AnnounceHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(_AnnounceHistoryController());

    return RLayoutWithHeader(
      "歷史公告",
      child: Obx(() {
        if (c.isLoading.value) {
          return Center(
              child: SizedBox(
              width: vmin(20),  // ⬅️ 這裡改大小
              height: vmin(20),
              child: CircularProgressIndicator(
                strokeWidth: vmin(2),
                color: AppColors.primary,
              ),
          ));
        }
        if (c.announcements.isEmpty) {
          return Center(child: RText.titleLarge('尚無公告紀錄'));
        }
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...c.announcements.map((announce) {
                      return [
                        RAnnounceViewer(announce: announce),
                        RSpace(),
                        RComments(comments: announce.comments),
                        RSpace(type: RSpaceType.large,)
                      ];
                    }).expand((e) => e)
                  ],
                ),
              )
            ),
            ColoredBox(
              color: AppColors.surfaceContainerHigh,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: RText.titleMedium("讀取最後10筆公告，唯讀模式。"),
                  )
                ],
              ),
            ),
          ]
        );
      })
    );
  }
}

class _AnnounceHistoryController extends GetxController {
  final announcements = <KingdomAnnouncement>[].obs;
  final isLoading = true.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final data = await KingdomUserService.getRecentAnnounce();
      announcements.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
