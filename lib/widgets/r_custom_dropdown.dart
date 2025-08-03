
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rabbit_kingdom/helpers/app_colors.dart';
import 'package:rabbit_kingdom/helpers/screen.dart';
import 'package:rabbit_kingdom/widgets/r_icon.dart';
import 'package:rabbit_kingdom/widgets/r_space.dart';
import 'package:rabbit_kingdom/widgets/r_text.dart';

class RCustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T selectedItem;
  final ValueChanged<T> onChanged;
  final Widget Function(T)? itemBuilder;
  final Widget Function(T)? selectedBuilder;
  final String Function(T)? stringify;

  const RCustomDropdown({
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    this.itemBuilder,
    this.selectedBuilder,
    this.stringify,
    super.key,
  });

  @override
  State<RCustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<RCustomDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  void _toggleDropdown() {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlay();
      Overlay.of(context).insert(_overlayEntry!);
    } else {
      _removeOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width + vw(2),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(color: const Color(0x55000000), blurRadius: 6),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.items.map((item) {
                return GestureDetector(
                  onTap: () {
                    widget.onChanged(item);
                    _removeOverlay();
                  },
                  child: widget.itemBuilder == null ?
                    Container(
                      padding: EdgeInsets.symmetric(vertical: vw(2.5)),
                      child: RText.titleLarge(
                        widget.stringify == null ?
                          item.toString():
                          widget.stringify!(item)
                      ),
                    )
                    : widget.itemBuilder!(item),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
          onTap: _toggleDropdown,
          child: widget.selectedBuilder == null ?
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RText.titleLarge(
                  widget.stringify == null ?
                    widget.selectedItem.toString():
                    widget.stringify!(widget.selectedItem)
                ),
                RSpace(),
                RIcon(FontAwesomeIcons.caretDown)
              ],
            ): widget.selectedBuilder!(widget.selectedItem)
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }
}