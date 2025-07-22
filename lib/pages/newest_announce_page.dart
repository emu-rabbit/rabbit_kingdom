import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/announce_controller.dart';
import 'package:rabbit_kingdom/widgets/r_announce_viewer.dart';
import 'package:rabbit_kingdom/widgets/r_layout_with_header.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class NewestAnnouncePage extends StatelessWidget {
  const NewestAnnouncePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RLayoutWithHeader(
      "最新公告",
      child: GetBuilder<AnnounceController>(builder: (announceController) {
        if (announceController.announcement != null) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RAnnounceViewer(announce: announceController.announcement!)
              ],
            ),
          );
        }
        return Center(
          child: RText.titleMedium("目前沒有最新公告QQ"),
        );
      })
    );
  }
}