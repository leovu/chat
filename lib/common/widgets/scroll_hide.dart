import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollHideController {
  static final ValueNotifier<double> progress = ValueNotifier<double>(0.0);

  static Object? _activeOwner;
  static final Map<Object, double> _lastProgress = {};
  static final Map<Object, bool Function()> _revealers = {};

  static void report(Object owner, double value) {
    _lastProgress[owner] = value;
    if (_activeOwner == null || _activeOwner == owner) {
      progress.value = value;
    }
  }

  static void activate(Object? owner) {
    _activeOwner = owner;
    progress.value = _lastProgress[owner] ?? 0.0;
    show();
  }

  static void register(Object key, bool Function() reveal) =>
      _revealers[key] = reveal;

  static void unregister(Object key) => _revealers.remove(key);

  static void show() {
    var revealed = false;
    for (final reveal in _revealers.values.toList()) {
      if (reveal()) revealed = true;
    }
    if (!revealed) progress.value = 0.0;
  }
}

class ScrollHideSlide extends SingleChildRenderObjectWidget {
  final double? distance;

  const ScrollHideSlide({super.key, this.distance, required Widget child})
      : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderScrollHideSlide(distance);

  @override
  void updateRenderObject(
      BuildContext context, _RenderScrollHideSlide renderObject) {
    renderObject.distance = distance;
  }
}

class _RenderScrollHideSlide extends RenderProxyBox {
  _RenderScrollHideSlide(this._distance);

  double? _distance;

  set distance(double? value) {
    if (_distance == value) return;
    _distance = value;
    markNeedsCompositedLayerUpdate();
  }

  double get _dy =>
      ScrollHideController.progress.value * (_distance ?? size.height);

  @override
  bool get isRepaintBoundary => true;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    ScrollHideController.progress.addListener(markNeedsCompositedLayerUpdate);
  }

  @override
  void detach() {
    ScrollHideController.progress
        .removeListener(markNeedsCompositedLayerUpdate);
    super.detach();
  }

  @override
  OffsetLayer updateCompositedLayer(
      {required covariant OffsetLayer? oldLayer}) {
    final layer = oldLayer is TransformLayer ? oldLayer : TransformLayer();
    layer.transform = Matrix4.translationValues(0.0, _dy, 0.0);
    return layer;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return result.addWithPaintOffset(
      offset: Offset(0.0, _dy),
      position: position,
      hitTest: (result, transformed) =>
          super.hitTestChildren(result, position: transformed),
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    transform.translateByDouble(0.0, _dy, 0.0, 1.0);
  }
}

class ScrollHideHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Object owner;
  final double extent;
  final Color background;
  final Widget child;
  @override
  final TickerProvider vsync;

  ScrollHideHeaderDelegate({
    required this.owner,
    required this.extent,
    required this.background,
    required this.vsync,
    required this.child,
  });

  @override
  double get maxExtent => extent;

  @override
  double get minExtent => 0.0;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration =>
      FloatingHeaderSnapConfiguration(
          duration: const Duration(milliseconds: 200), curve: Curves.easeOut);

  @override
  PersistentHeaderShowOnScreenConfiguration get showOnScreenConfiguration =>
      const PersistentHeaderShowOnScreenConfiguration();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    ScrollHideController.report(
        owner, extent <= 0.0 ? 0.0 : (shrinkOffset / extent).clamp(0.0, 1.0));
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.bottomCenter,
        minHeight: extent,
        maxHeight: extent,
        child: ColoredBox(
          color: overlapsContent ? background : Colors.transparent,
          child: child,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(ScrollHideHeaderDelegate oldDelegate) =>
      oldDelegate.child != child ||
      oldDelegate.extent != extent ||
      oldDelegate.owner != owner ||
      oldDelegate.background != background ||
      oldDelegate.vsync != vsync;
}

bool revealScrollHideHeader(GlobalKey headerKey) {
  final header = headerKey.currentContext
      ?.findAncestorRenderObjectOfType<RenderSliverFloatingPersistentHeader>();
  if (header == null) return false;
  header.maybeStartSnapAnimation(ScrollDirection.forward);
  return true;
}
