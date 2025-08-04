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
              width: vmin(20),
              height: vmin(20),
              child: CircularProgressIndicator(
                strokeWidth: vmin(2),
                color: AppColors.primary,
              ),
            ),
          );
        }
        if (c.announcements.isEmpty) {
          return Center(child: RText.titleLarge('尚無公告紀錄'));
        }

        // 使用 ListView.builder 來提升效能
        return Column(
          children: [
            Expanded(
              child: SizedBox(
                width: vw(100) * deviceFactor(),
                  child: ListView.builder(
                    itemCount: c.announcements.length,
                    itemBuilder: (context, index) {
                      final announce = c.announcements[index];
                      // 這裡我們直接返回一個項目，而不是使用 SingleChildScrollView
                      return _AnnounceHistoryItem(
                      announce: announce,
                      isLastItem: index == c.announcements.length - 1,
                    );
                  },
                ),
              ),
            ),
            ColoredBox(
              color: AppColors.surfaceContainerHigh,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: RText.titleMedium("讀取最後10筆公告，唯讀模式。"),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

// 將每個公告項目封裝成一個獨立的 Widget
class _AnnounceHistoryItem extends StatelessWidget {
  final KingdomAnnouncement announce; // 這裡使用 dynamic 假設 Announce 物件
  final bool isLastItem;
  const _AnnounceHistoryItem({
    super.key,
    required this.announce,
    required this.isLastItem,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RSpace(type: RSpaceType.small),
        RAnnounceViewer(announce: announce),
        RSpace(),
        // 關鍵：使用 ConstrainedBox 來限制 RComments 的高度，並啟用內部滾動
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: vw(80)), // 這裡可以根據設計調整最大高度
          child: announce.comments.length < 6 ?
            SingleChildScrollView(
              child: RComments(comments: announce.comments, isScrollable: false,),
            ):
            RComments(comments: announce.comments, isScrollable: true,),
        ),
        RSpace(type: RSpaceType.large),
        if (isLastItem) RSpace(type: RSpaceType.large), // 讓最後一個項目底部有更多空間
      ],
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
      announcements.assignAll(data.sublist(1));
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
