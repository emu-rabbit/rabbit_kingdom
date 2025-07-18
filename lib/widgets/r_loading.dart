import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';

class RLoading {
  static final RLoading _singleton = RLoading._internal();

  factory RLoading() => _singleton;

  RLoading._internal();

  OverlayEntry? _overlayEntry;

  static void start() {
    _singleton._show();
  }

  static void stop() {
    _singleton._hide();
  }

  void _show() {
    if (_overlayEntry != null) return; // 已經顯示了

    final context = Get.overlayContext ?? Get.context;
    if (context == null) return;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // 半透明遮罩
          Positioned.fill(
            child: Container(
              color: AppColors.surface.withAlpha(180),
              alignment: Alignment.center,
              child: SizedBox(
                width: vmin(20),  // ⬅️ 這裡改大小
                height: vmin(20),
                child: CircularProgressIndicator(
                  strokeWidth: vmin(2),
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}