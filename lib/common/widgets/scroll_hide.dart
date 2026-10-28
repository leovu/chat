import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollHideController {
  static final ValueNotifier<bool> visible = ValueNotifier<bool>(true);

  static void show() => visible.value = true;

  static bool onNotification(UserScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification.direction == ScrollDirection.reverse &&
        notification.metrics.pixels > 0) {
      visible.value = false;
    } else if (notification.direction == ScrollDirection.forward) {
      visible.value = true;
    }
    return false;
  }
}

class ScrollHideCollapse extends StatelessWidget {
  final Widget child;

  const ScrollHideCollapse({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ScrollHideController.visible,
      child: child,
      builder: (context, visible, child) => ClipRect(
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: Alignment.bottomCenter,
          heightFactor: visible ? 1.0 : 0.0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: visible ? 1.0 : 0.0,
            child: child,
          ),
        ),
      ),
    );
  }
}

class ScrollHideSlide extends StatelessWidget {
  final Widget child;

  const ScrollHideSlide({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ScrollHideController.visible,
      child: child,
      builder: (context, visible, child) => AnimatedSlide(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        offset: visible ? Offset.zero : const Offset(0.0, 1.5),
        child: child,
      ),
    );
  }
}
