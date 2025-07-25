import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rabbit_kingdom/controllers/theme_controller.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

enum RButtonType { primary, secondary, surface, danger }

class RButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget Function(Color)? child;
  final String? text;
  final RButtonType type;
  final bool isDisabled;

  const RButton._({
    super.key,
    required this.onPressed,
    this.child,
    this.text,
    this.type = RButtonType.primary,
    this.isDisabled = false,
  });

  factory RButton.primary({
    required VoidCallback onPressed,
    Widget Function(Color)? child,
    String? text,
    bool isDisabled = false,
  }) => RButton._(
    onPressed: onPressed,
    type: RButtonType.primary,
    isDisabled: isDisabled,
    child: child,
    text: text,
  );

  factory RButton.secondary({
    required VoidCallback onPressed,
    Widget Function(Color)? child,
    String? text,
    bool isDisabled = false,
  }) => RButton._(
    onPressed: onPressed,
    type: RButtonType.secondary,
    isDisabled: isDisabled,
    child: child,
    text: text,
  );

  factory RButton.surface({
    required VoidCallback onPressed,
    Widget Function(Color)? child,
    String? text,
    bool isDisabled = false,
  }) => RButton._(
    onPressed: onPressed,
    type: RButtonType.surface,
    isDisabled: isDisabled,
    child: child,
    text: text,
  );

  factory RButton.danger({
    required VoidCallback onPressed,
    Widget Function(Color)? child,
    String? text,
    bool isDisabled = false,
  }) => RButton._(
    onPressed: onPressed,
    type: RButtonType.danger,
    isDisabled: isDisabled,
    child: child,
    text: text,
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
    );
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.isDisabled) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    if (!widget.isDisabled) {
      _animationController.reverse();
    }
  }

  void _onTapCancel() {
    if (!widget.isDisabled) {
      _animationController.reverse();
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

  Widget Function(Color) _resolveChildBuilder() {
    if (widget.child != null) {
      return widget.child!;
    } else {
      return (color) => RText.bodyLarge(
        widget.text ?? '',
        color: color,
        textAlign: TextAlign.center,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!widget.isDisabled) {
          if (widget.onPressed != null) {
            widget.onPressed!();
          }
          await _animationController.forward();
          _animationController.reverse();
        }
      },
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: GetBuilder<ThemeController>(
          builder: (themeController) {
            final colors = AppColors.colorScheme;
            final bg = _backgroundColor(colors);
            final fg = _foregroundColor(colors);
            final childBuilder = _resolveChildBuilder();
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: childBuilder(fg),
            );
          },
        ),
      ),
    );
  }
}
