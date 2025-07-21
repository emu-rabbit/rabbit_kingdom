import 'package:flutter/material.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/widgets/r_icon.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class RCollapsible extends StatefulWidget {
  final String title;
  final dynamic content; // 可以是 String 或 Widget
  final bool initiallyExpanded;

  const RCollapsible({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
  });

  @override
  State<RCollapsible> createState() => _RCollapsibleState();
}

class _RCollapsibleState extends State<RCollapsible>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (_isExpanded) _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildContent() {
    if (widget.content is String) {
      return ColoredBox(
        color: AppColors.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: RText.bodySmall(
            widget.content as String,
            maxLines: null,
            overflow: TextOverflow.visible,
          ),
        ),
      );
    } else if (widget.content is Widget) {
      return widget.content as Widget;
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleExpanded,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: RText.titleLarge(widget.title, maxLines: 2,),
                  ),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const RIcon(Icons.keyboard_arrow_down),
                  )
                ],
              ),
            ),
          ),
        ),
        SizeTransition(
          sizeFactor: _expandAnimation,
          child: SizedBox(
            width: double.infinity,
            child: ClipRect(
              child: _buildContent(),
            ),
          ),
        ),
      ],
    );
  }
}
