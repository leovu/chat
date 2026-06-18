import 'dart:ui';
import 'package:chat/chat_ui/chat_theme.dart' show primaryColor;
import 'package:flutter/material.dart';

class LiquidGlassTabItem {
  final dynamic id;
  final String? title;
  final IconData? iconData;
  final String? iconAsset;
  final int? badgeCount;
  final Widget? customChild;

  const LiquidGlassTabItem({
    this.id,
    this.title,
    this.iconData,
    this.iconAsset,
    this.badgeCount,
    this.customChild,
  });
}

class LiquidGlassTabBar extends StatefulWidget {
  final List<LiquidGlassTabItem> items;
  final int selectedIndex;
  final void Function(int, LiquidGlassTabItem)? onTabChanged;
  final Color? indicatorColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final bool expandItems;
  final int animationDuration;

  const LiquidGlassTabBar({
    Key? key,
    required this.items,
    this.selectedIndex = 0,
    this.onTabChanged,
    this.indicatorColor,
    this.selectedColor,
    this.unselectedColor,
    this.expandItems = false,
    this.animationDuration = 400,
  }) : super(key: key);

  @override
  _LiquidGlassTabBarState createState() => _LiquidGlassTabBarState();
}

class _LiquidGlassTabBarState extends State<LiquidGlassTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _fromIndex;
  late int _toIndex;

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.selectedIndex;
    _toIndex = widget.selectedIndex;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animationDuration),
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant LiquidGlassTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _fromIndex = oldWidget.selectedIndex;
      _toIndex = widget.selectedIndex;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _abbreviate(String title) {
    return title
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase())
        .join('');
  }

  List<double> _calcWidths(double totalWidth) {
    final n = widget.items.length;
    if (n == 0) return [];
    if (!widget.expandItems) return List.filled(n, totalWidth / n);

    final t = _controller.value;
    final fluxes = List.generate(n, (i) {
      if (_fromIndex == _toIndex) return i == _toIndex ? 2.0 : 1.0;
      if (i == _fromIndex) return 2.0 - t;
      if (i == _toIndex) return 1.0 + t;
      return 1.0;
    });
    final sumFlex = fluxes.fold(0.0, (a, b) => a + b);
    return fluxes.map((f) => f / sumFlex * totalWidth).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = widget.selectedColor ?? primaryColor;
    final unselectedColor =
        widget.unselectedColor ?? primaryColor.withValues(alpha: 0.5);
    final indicatorColor = widget.indicatorColor ?? Colors.transparent;
    final n = widget.items.length;
    final t = _controller.value;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final widths = _calcWidths(totalWidth);

        double indicatorLeft = 0;
        for (int i = 0; i < _toIndex && i < widths.length; i++) {
          indicatorLeft += widths[i];
        }
        final indicatorWidth = widths.isNotEmpty ? widths[_toIndex] : 0.0;

        final isAnimating = _controller.isAnimating;
        final stretchX = isAnimating
            ? 1.0 + (0.1 * (1 - (2 * t - 1).abs()))
            : 1.0;
        final stretchY = isAnimating
            ? 1.0 - (0.05 * (1 - (2 * t - 1).abs()))
            : 1.0;

        return SizedBox(
          height: 44,
          child: Stack(
            children: [
              Positioned(
                left: indicatorLeft,
                top: 2,
                bottom: 2,
                width: indicatorWidth,
                child: Transform(
                  alignment: Alignment.center,
                  transform:
                      Matrix4.diagonal3Values(stretchX, stretchY, 1.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: indicatorColor != Colors.transparent
                              ? indicatorColor.withValues(alpha: 0.85)
                              : Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: List.generate(n, (i) {
                  final item = widget.items[i];
                  final isSelected = i == widget.selectedIndex;
                  final color = isSelected ? selectedColor : unselectedColor;
                  final displayTitle = item.title != null
                      ? (isSelected
                          ? item.title!
                          : _abbreviate(item.title!))
                      : null;

                  return SizedBox(
                    width: widths[i],
                    height: 44,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () =>
                            widget.onTabChanged?.call(i, item),
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        overlayColor: WidgetStateProperty.all(
                            Colors.transparent),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (item.iconData != null)
                                _buildIcon(item, color),
                              if (displayTitle != null) ...[
                                if (item.iconData != null)
                                  const SizedBox(width: 4),
                                Flexible(
                                  child: AnimatedDefaultTextStyle(
                                    duration: Duration(
                                        milliseconds:
                                            widget.animationDuration),
                                    style: TextStyle(
                                      color: color,
                                      fontSize: isSelected ? 13 : 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                    child: Text(
                                      displayTitle,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ),
                              ],
                              if (item.customChild != null)
                                item.customChild!,
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIcon(LiquidGlassTabItem item, Color color) {
    final badge = item.badgeCount;
    final icon = Icon(item.iconData, color: color, size: 22);
    if (badge != null && badge > 0) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          icon,
          Positioned(
            top: -4,
            right: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints:
                  const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Text(
                badge > 99 ? '99+' : '$badge',
                style: const TextStyle(color: Colors.white, fontSize: 9),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }
    return icon;
  }
}
