import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';

enum RButtonType { primary, secondary, surface, danger }

class RButtonAnimationController extends GetxController {
  final scale = 1.0.obs;

  void pressDown() => scale.value = 0.95;
  void release() => scale.value = 1.0;
}

class RButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget Function(Color) child;
  final RButtonType type;
  final String? tag;
  final bool isDisabled;
  late final RButtonAnimationController _controller;

  RButton._({
    super.key,
    required this.onPressed,
    required this.child,
    this.type = RButtonType.primary,
    this.isDisabled = false,
    this.tag,
  }) {
    _controller = Get.put(RButtonAnimationController(), tag: tag ?? UniqueKey().toString());
  }

  factory RButton.primary({
    required VoidCallback onPressed,
    required Widget Function(Color) child,
    bool isDisabled = false,
    String? tag
  }) => RButton._(
    onPressed: onPressed,
    type: RButtonType.primary,
    isDisabled: isDisabled,
    child: child,
    tag: tag,
  );

  factory RButton.secondary({
    required VoidCallback onPressed,
    required Widget Function(Color) child,
    bool isDisabled = false,
    String? tag
  }) => RButton._(
    onPressed: onPressed,
    type: RButtonType.secondary,
    isDisabled: isDisabled,
    child: child,
    tag: tag,
  );

  factory RButton.surface({
    required VoidCallback onPressed,
    required Widget Function(Color) child,
    bool isDisabled = false,
    String? tag
  }) => RButton._(
    onPressed: onPressed,
    type: RButtonType.surface,
    isDisabled: isDisabled,
    child: child,
    tag: tag,
  );

  factory RButton.danger({
    required VoidCallback onPressed,
    required Widget Function(Color) child,
    bool isDisabled = false,
    String? tag
  }) => RButton._(
    onPressed: onPressed,
    type: RButtonType.danger,
    isDisabled: isDisabled,
    child: child,
    tag: tag,
  );

  Color _backgroundColor(ColorScheme colors) {
    if (isDisabled) return colors.outline.withAlpha((255 * 0.3).round());
    switch (type) {
      case RButtonType.primary:
        return colors.primary;
      case RButtonType.secondary:
        return colors.secondary;
      case RButtonType.surface:
        return colors.surfaceContainerHigh;
      case RButtonType.danger:
        return colors.error;
    }
  }

  Color _foregroundColor(ColorScheme colors) {
    if (isDisabled) return colors.onSurface.withAlpha((255 * 0.3).round());
    switch (type) {
      case RButtonType.primary:
        return colors.onPrimary;
      case RButtonType.secondary:
        return colors.onSecondary;
      case RButtonType.surface:
        return colors.onSurface;
      case RButtonType.danger:
        return colors.onError;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      onTapDown: (_) => isDisabled ? null : _controller.pressDown(),
      onTapUp: (_) => isDisabled ? null : _controller.release(),
      onTapCancel: isDisabled ? null : _controller.release,
      child: Obx(() => AnimatedScale(
        scale: _controller.scale.value,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _backgroundColor(AppColors.colorScheme),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: child(_foregroundColor(AppColors.colorScheme)),
        ),
      )),
    );
  }
}
