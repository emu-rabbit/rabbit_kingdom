import 'package:flutter/material.dart';

class RFadeInColumn extends StatefulWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final Duration fadeDuration; // 單個 item 淡入動畫時間
  final Duration delayBetween; // 每個 item 的間隔時間

  const RFadeInColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.fadeDuration = const Duration(milliseconds: 500),
    this.delayBetween = const Duration(milliseconds: 250),
  });

  @override
  State<RFadeInColumn> createState() => _RFadeInColumnState();
}

class _RFadeInColumnState extends State<RFadeInColumn>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.children.length,
          (_) => AnimationController(
        vsync: this,
        duration: widget.fadeDuration,
      ),
    );
    _animations = _controllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeIn))
        .toList();
    _playAnimations();
  }

  Future<void> _playAnimations() async {
    for (var i = 0; i < _controllers.length; i++) {
      await Future.delayed(widget.delayBetween);
      _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: widget.mainAxisAlignment,
      mainAxisSize: widget.mainAxisSize,
      crossAxisAlignment: widget.crossAxisAlignment,
      textDirection: widget.textDirection,
      verticalDirection: widget.verticalDirection,
      textBaseline: widget.textBaseline,
      children: List.generate(widget.children.length, (i) {
        return FadeTransition(
          opacity: _animations[i],
          child: widget.children[i],
        );
      }),
    );
  }
}
