import 'dart:ui';
import 'package:flutter/material.dart';

class RBlurredOverlay extends StatefulWidget {
  const RBlurredOverlay({super.key});

  @override
  State<RBlurredOverlay> createState() => _RBlurredOverlayState();
}

class _RBlurredOverlayState extends State<RBlurredOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // 循環來回動畫

    _blurAnimation = Tween<double>(begin: 2, end: 12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // 記得銷毀！
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _blurAnimation,
        builder: (context, child) {
          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _blurAnimation.value,
              sigmaY: _blurAnimation.value,
            ),
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
            ),
          );
        },
      ),
    );
  }
}
