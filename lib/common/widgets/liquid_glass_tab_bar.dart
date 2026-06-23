import 'dart:ui';
import 'package:chat/chat_ui/chat_theme.dart';
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
  final void Function(int index, LiquidGlassTabItem item)? onTabChanged;
  final Color? indicatorColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? badgeColor;
  final double indicatorRadius;
  final int animationDuration;
  final EdgeInsets? tabPadding;
  final MainAxisAlignment tabAlignment;
  final Widget Function(LiquidGlassTabItem item, bool isSelected)? itemBuilder;
  final bool expandItems;
  final bool equalWidth;

  const LiquidGlassTabBar({
    super.key,
    required this.items,
    this.selectedIndex = 0,
    this.onTabChanged,
    this.indicatorColor,
    this.selectedColor,
    this.unselectedColor,
    this.badgeColor,
    this.indicatorRadius = 20.0,
    this.animationDuration = 400,
    this.tabPadding,
    this.tabAlignment = MainAxisAlignment.spaceAround,
    this.itemBuilder,
    this.expandItems = false,
    this.equalWidth = false,
  });

  @override
  State<LiquidGlassTabBar> createState() => _LiquidGlassTabBarState();
}

class _LiquidGlassTabBarState extends State<LiquidGlassTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  final List<GlobalKey> _tabKeys = [];
  Rect? _indicatorRect;
  Rect? _targetRect;
  int? _pressedIndex;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: Duration(milliseconds: widget.animationDuration),
      vsync: this,
    );
    _initTabKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(LiquidGlassTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initTabKeys();
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _animateToSelected();
    }
  }

  void _initTabKeys() {
    while (_tabKeys.length < widget.items.length) {
      _tabKeys.add(GlobalKey());
    }
    while (_tabKeys.length > widget.items.length) {
      _tabKeys.removeLast();
    }
  }

  void _updateIndicator() {
    if (widget.selectedIndex < 0 || widget.selectedIndex >= _tabKeys.length)
      return;
    final key = _tabKeys[widget.selectedIndex];
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final parentBox = context.findRenderObject() as RenderBox?;
    if (parentBox == null) return;
    final position = renderBox.localToGlobal(Offset.zero, ancestor: parentBox);
    final size = renderBox.size;
    setState(() {
      _indicatorRect =
          Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
      _targetRect = _indicatorRect;
    });
  }

  void _animateToSelected() {
    if (widget.selectedIndex < 0 || widget.selectedIndex >= _tabKeys.length)
      return;
    final key = _tabKeys[widget.selectedIndex];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;
      final parentBox = context.findRenderObject() as RenderBox?;
      if (parentBox == null) return;
      final position =
          renderBox.localToGlobal(Offset.zero, ancestor: parentBox);
      final size = renderBox.size;
      setState(() {
        _targetRect =
            Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
      });
      _slideController.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_indicatorRect != null && _targetRect != null)
          AnimatedBuilder(
            animation: _slideController,
            builder: (context, child) {
              final t = Curves.easeOutCubic.transform(_slideController.value);
              final currentRect = Rect.lerp(_indicatorRect, _targetRect, t)!;
              if (_slideController.isCompleted &&
                  _indicatorRect != _targetRect) {
                WidgetsBinding.instance.addPostFrameCallback(
                    (_) => setState(() => _indicatorRect = _targetRect));
              }
              return Positioned(
                left: currentRect.left,
                top: currentRect.top,
                width: currentRect.width,
                height: currentRect.height,
                child: _LiquidGlassIndicator(
                  isAnimating: _slideController.isAnimating,
                  progress: t,
                  color: widget.indicatorColor ?? Colors.transparent,
                  borderRadius: widget.indicatorRadius,
                ),
              );
            },
          ),
        Row(
          mainAxisAlignment: widget.tabAlignment,
          children: widget.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = index == widget.selectedIndex;
            final tabButton = _LiquidGlassTabButton(
              key: _tabKeys[index],
              isSelected: isSelected,
              isPressed: _pressedIndex == index,
              onTapDown: () => setState(() => _pressedIndex = index),
              onTapUp: () => setState(() => _pressedIndex = null),
              onTapCancel: () => setState(() => _pressedIndex = null),
              onTap: () => widget.onTabChanged?.call(index, item),
              padding: widget.tabPadding ??
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: widget.itemBuilder != null
                  ? widget.itemBuilder!(item, isSelected)
                  : _buildDefaultTabContent(item, isSelected),
            );
            return widget.expandItems
                ? Expanded(
                    flex: widget.equalWidth ? 1 : (isSelected ? 2 : 1),
                    child: tabButton)
                : tabButton;
          }).toList(),
        ),
      ],
    );
  }

  String _abbreviate(String title) {
    return title
        .split(' ')
        .where((w) => w.isNotEmpty)
        .map((w) => w[0].toUpperCase())
        .join('');
  }

  Widget _buildDefaultTabContent(LiquidGlassTabItem item, bool isSelected) {
    final selectedColor = widget.selectedColor ?? primaryColor;
    final unselectedColor = widget.unselectedColor ?? primaryColor;
    final badgeColor = widget.badgeColor ?? Colors.red;
    final displayTitle = item.title != null
        ? (isSelected || widget.equalWidth
            ? item.title!
            : _abbreviate(item.title!))
        : null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (item.iconAsset != null)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Image.asset(
                  item.iconAsset!,
                  key: ValueKey('icon_${item.iconAsset}_$isSelected'),
                  width: 24.0,
                  height: 24.0,
                ),
              )
            else if (item.iconData != null)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Icon(
                  item.iconData,
                  key: ValueKey('iconData_$isSelected'),
                  color: isSelected ? selectedColor : unselectedColor,
                  size: 24.0,
                ),
              ),
            if (displayTitle != null) ...[
              const SizedBox(width: 4),
              Flexible(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? selectedColor : Colors.black,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                  child: Text(displayTitle,
                      overflow: TextOverflow.ellipsis, maxLines: 1),
                ),
              ),
            ],
            if (item.customChild != null) item.customChild!,
          ],
        ),
        if ((item.badgeCount ?? 0) > 0)
          Positioned(
            right: -12,
            top: -12,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  '${(item.badgeCount ?? 0) > 999 ? '999+' : item.badgeCount}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LiquidGlassIndicator extends StatelessWidget {
  final bool isAnimating;
  final double progress;
  final Color color;
  final double borderRadius;

  const _LiquidGlassIndicator({
    required this.isAnimating,
    required this.progress,
    required this.color,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final stretchX =
        isAnimating ? 1.0 + (0.1 * (1 - (2 * progress - 1).abs())) : 1.0;
    final stretchY =
        isAnimating ? 1.0 - (0.05 * (1 - (2 * progress - 1).abs())) : 1.0;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(stretchX, stretchY, 1.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: color != Colors.transparent
                  ? color.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LiquidGlassTabButton extends StatefulWidget {
  final bool isSelected;
  final bool isPressed;
  final VoidCallback? onTap;
  final VoidCallback? onTapDown;
  final VoidCallback? onTapUp;
  final VoidCallback? onTapCancel;
  final Widget child;
  final EdgeInsets padding;

  const _LiquidGlassTabButton({
    super.key,
    required this.isSelected,
    required this.isPressed,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    required this.child,
    required this.padding,
  });

  @override
  State<_LiquidGlassTabButton> createState() => _LiquidGlassTabButtonState();
}

class _LiquidGlassTabButtonState extends State<_LiquidGlassTabButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_LiquidGlassTabButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPressed && !oldWidget.isPressed) {
      _controller.forward();
    } else if (!widget.isPressed && oldWidget.isPressed) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        onHighlightChanged: (isPressed) {
          if (isPressed) {
            widget.onTapDown?.call();
          } else {
            widget.onTapUp?.call();
          }
        },
        onTapCancel: () => widget.onTapCancel?.call(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) =>
              Transform.scale(scale: _scaleAnimation.value, child: child),
          child: Container(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}
