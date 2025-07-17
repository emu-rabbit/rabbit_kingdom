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
  final bool isDisabled;
  final double borderRadius;
  final RButtonAnimationController _controller =
  Get.put(RButtonAnimationController(), tag: UniqueKey().toString());

  RButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.type = RButtonType.primary,
    this.isDisabled = false,
    this.borderRadius = 9999,
  });

  factory RButton.primary({
    required VoidCallback onPressed,
    required Widget Function(Color) child,
    bool isDisabled = false,
  }) => RButton(
    onPressed: onPressed,
    type: RButtonType.primary,
    isDisabled: isDisabled,
    child: child,
  );

  factory RButton.secondary({
    required VoidCallback onPressed,
    required Widget Function(Color) child,
    bool isDisabled = false,
  }) => RButton(
    onPressed: onPressed,
    type: RButtonType.secondary,
    isDisabled: isDisabled,
    child: child,
  );

  factory RButton.surface({
    required VoidCallback onPressed,
    required Widget Function(Color) child,
    bool isDisabled = false,
  }) => RButton(
    onPressed: onPressed,
    type: RButtonType.surface,
    isDisabled: isDisabled,
    child: child,
  );

  factory RButton.danger({
    required VoidCallback onPressed,
    required Widget Function(Color) child,
    bool isDisabled = false,
  }) => RButton(
    onPressed: onPressed,
    type: RButtonType.danger,
    isDisabled: isDisabled,
    child: child,
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
      onTapDown: (_) => _controller.pressDown(),
      onTapUp: (_) => _controller.release(),
      onTapCancel: _controller.release,
      child: Obx(() => AnimatedScale(
        scale: _controller.scale.value,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: Container(
          padding:
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _backgroundColor(AppColors.colorScheme),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: child(_foregroundColor(AppColors.colorScheme)),
        ),
      )),
    );
  }
}
