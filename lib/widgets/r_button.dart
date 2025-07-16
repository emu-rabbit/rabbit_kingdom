import 'package:flutter/material.dart';

enum RButtonType { primary, secondary, surface, danger }

class RButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final RButtonType type;
  final bool isDisabled;
  final double borderRadius;

  const RButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.type = RButtonType.primary,
    this.isDisabled = false,
    this.borderRadius = 16,
  });


  static RButton primary({
    required VoidCallback onPressed,
    required String text,
    bool isDisabled = false,
  }) {
    return RButton(
      onPressed: onPressed,
      text: text,
      type: RButtonType.primary,
      isDisabled: isDisabled,
    );
  }

  static RButton secondary({
    required VoidCallback onPressed,
    required String text,
    bool isDisabled = false,
  }) {
    return RButton(
      onPressed: onPressed,
      text: text,
      type: RButtonType.secondary,
      isDisabled: isDisabled,
    );
  }

  static RButton surface({
    required VoidCallback onPressed,
    required String text,
    bool isDisabled = false,
  }) {
    return RButton(
      onPressed: onPressed,
      text: text,
      type: RButtonType.surface,
      isDisabled: isDisabled,
    );
  }

  static RButton danger({
    required VoidCallback onPressed,
    required String text,
    bool isDisabled = false,
  }) {
    return RButton(
      onPressed: onPressed,
      text: text,
      type: RButtonType.danger,
      isDisabled: isDisabled,
    );
  }

  // 依據 type 決定配色
  Color _backgroundColor(ColorScheme colors) {
    if (isDisabled) {
      return colors.outline.withOpacity(0.3);
    }
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
    if (isDisabled) {
      return colors.onSurface.withOpacity(0.3);
    }
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
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: _backgroundColor(colors),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: _foregroundColor(colors),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

