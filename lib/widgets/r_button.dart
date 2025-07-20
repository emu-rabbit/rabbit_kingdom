import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/theme_controller.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';

enum RButtonType { primary, secondary, surface, danger }

class RButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget Function(Color) child;
  final RButtonType type;
  final bool isDisabled;

  const RButton._({
    super.key,
    required this.onPressed,
    required this.child,
    this.type = RButtonType.primary,
    this.isDisabled = false,
  });

  factory RButton.primary({
    required VoidCallback onPressed,
    required Widget Function(Color) child,
    bool isDisabled = false,
  }) => RButton._(
    onPressed: onPressed,
    type: RButtonType.primary,
    isDisabled: isDisabled,
    child: child,
  );

  factory RButton.secondary({
    required VoidCallback onPressed,
    required Widget Function(Color) child,
    bool isDisabled = false,
  }) => RButton._(
    onPressed: onPressed,
    type: RButtonType.secondary,
    isDisabled: isDisabled,
    child: child,
  );

  factory RButton.surface({
    required VoidCallback onPressed,
    required Widget Function(Color) child,
    bool isDisabled = false,
  }) => RButton._(
    onPressed: onPressed,
    type: RButtonType.surface,
    isDisabled: isDisabled,
    child: child,
  );

  factory RButton.danger({
    required VoidCallback onPressed,
    required Widget Function(Color) child,
    bool isDisabled = false,
  }) => RButton._(
    onPressed: onPressed,
    type: RButtonType.danger,
    isDisabled: isDisabled,
    child: child,
  );

  @override
  State<RButton> createState() => _RButtonState();
}

class _RButtonState extends State<RButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
    );
    _scale = _animationController.drive(Tween(begin: 1.0, end: 1.0));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.isDisabled) {
      _animationController.animateTo(0.95);
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (!widget.isDisabled) {
      _animationController.animateTo(1.0);
    }
  }

  void _onTapCancel() {
    if (!widget.isDisabled) {
      _animationController.animateTo(1.0);
    }
  }

  Color _backgroundColor(ColorScheme colors) {
    if (widget.isDisabled) return colors.outline.withAlpha((255 * 0.3).round());
    switch (widget.type) {
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
    if (widget.isDisabled) return colors.onSurface.withAlpha((255 * 0.3).round());
    switch (widget.type) {
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
      onTap: widget.isDisabled ? null : widget.onPressed,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Transform.scale(
          scale: _animationController.value,
          child: child,
        ),
        child: GetBuilder<ThemeController>(
          builder: (themeController) {
            final colors = AppColors.colorScheme;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _backgroundColor(colors),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: widget.child(_foregroundColor(colors)),
            );
          }
        ),
      ),
    );
  }
}
