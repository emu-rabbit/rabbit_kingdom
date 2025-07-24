import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/user_controller.dart';
import 'package:rabbit_kingdom/models/kingdom_user.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

import '../helpers/app_colors.dart';
import '../helpers/screen.dart';
import '../values/kingdom_tasks.dart';

class RTaskComplete {
  static final RTaskComplete _singleton = RTaskComplete._internal();

  factory RTaskComplete() => _singleton;

  RTaskComplete._internal();

  OverlayEntry? _overlayEntry;

  /// 顯示任務完成提示
  static void show(KingdomTaskNames name) {
    _singleton._show(name);
  }

  /// 關閉任務完成提示
  static void close() {
    _singleton._hide();
  }

  void _show(KingdomTaskNames name) {
    if (_overlayEntry != null) return; // 已經顯示

    final context = Get.overlayContext ?? Get.context;
    if (context == null) return;

    _overlayEntry = OverlayEntry(
      builder: (_) => GestureDetector(
        onTap: (){ _hide(); },
        child: Stack(
          children: [
            // ✨ 主人可在這裡自訂畫面樣式 ✨
            Positioned.fill(
              child: Container(
                color: AppColors.surface.withAlpha(220),
                alignment: Alignment.center,
                child: GetBuilder<UserController>(
                  builder: (userController) {
                    if (userController.user == null) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RText.displayLarge("任務完成！"),
                        ],
                      );
                    }
                    final task = userController.user!.taskData[name]!;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RText.displayLarge("任務完成！"),
                        RSpace(),
                        RText.titleLarge("${task.text}: ${task.completed}/${task.limit}"),
                        Image.asset(
                          "lib/assets/images/sticker_happy.png",
                          width: mainImageSize(),
                          height: mainImageSize(),
                        ),
                        RSpace(),
                        RText.titleLarge("經驗值 + ${task.expReward}"),
                        RSpace(),
                        RText.titleLarge("兔兔幣 + ${task.coinReward}"),
                      ],
                    );
                  }
                )
                , // 這裡是占位符，請替換掉
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
