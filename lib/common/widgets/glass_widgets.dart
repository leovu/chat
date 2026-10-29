import 'package:chat/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

AppBar glassAppBar({
  Widget? title,
  Widget? leading,
  List<Widget>? actions,
  bool? centerTitle,
  PreferredSizeWidget? bottom,
  bool automaticallyImplyLeading = true,
  double? leadingWidth,
  double? titleSpacing,
  double? toolbarHeight,
  TextStyle? titleTextStyle,
  bool rounded = true,
}) {
  return AppBar(
    title: title,
    leading: leading,
    actions: actions,
    centerTitle: centerTitle ?? true,
    bottom: bottom,
    automaticallyImplyLeading: automaticallyImplyLeading,
    leadingWidth: leadingWidth,
    titleSpacing: titleSpacing,
    toolbarHeight: toolbarHeight,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    foregroundColor: Colors.white,
    iconTheme: const IconThemeData(color: Colors.white),
    actionsIconTheme: const IconThemeData(color: Colors.white),
    systemOverlayStyle: SystemUiOverlayStyle.light,
    shape: rounded ? AppGlass.headerShape : null,
    flexibleSpace: AppGlass.headerBackground(rounded: rounded),
    titleTextStyle: titleTextStyle ?? AppGlass.headerTitleStyle,
  );
}

class GlassBackground extends StatelessWidget {
  final Widget child;

  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(decoration: AppGlass.background(), child: child);
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color? color;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.margin,
    this.padding,
    this.radius = AppRadius.card,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool solid = AppGlass.reduceTransparency(context);
    final BorderRadius borderRadius = BorderRadius.circular(radius);
    return Container(
      margin: margin,
      decoration:
          AppGlass.card(radius: radius, color: solid ? Colors.white : color),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          onLongPress: onLongPress,
          child: padding == null
              ? child
              : Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}

class GlassTile extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final double radius;

  const GlassTile({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
    this.radius = AppRadius.md,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = BorderRadius.circular(radius);
    return Container(
      margin: margin,
      decoration: AppGlass.tile(radius: radius),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class GlassHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const GlassHeader(
      {super.key, required this.title, this.onBack, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: AppGlass.header(),
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      child: SizedBox(
        height: kToolbarHeight,
        child: NavigationToolbar(
          middleSpacing: 8.0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: InkWell(
              onTap: onBack ?? () => Navigator.of(context).pop(),
              child: const SizedBox(
                  width: 36.0,
                  child: Icon(Icons.arrow_back_ios, color: AppColors.white)),
            ),
          ),
          middle: Text(title,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppGlass.headerTitleStyle),
          trailing: (actions ?? []).isEmpty
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child:
                      Row(mainAxisSize: MainAxisSize.min, children: actions!),
                ),
        ),
      ),
    );
  }
}

class GlassHeaderIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final double size;

  const GlassHeaderIconButton(
      {super.key, required this.icon, this.onTap, this.size = 36.0});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppGlass.headerIconBackground,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: IconTheme(
              data: const IconThemeData(color: Colors.white, size: 20.0),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}

class GlassGrabber extends StatelessWidget {
  const GlassGrabber({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38.0,
      height: 5.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: AppColors.primaryDarkColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
    );
  }
}

class GlassSheet extends StatelessWidget {
  final Widget child;
  final bool showGrabber;

  const GlassSheet({super.key, required this.child, this.showGrabber = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppGlass.sheet(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showGrabber) const GlassGrabber(),
          Flexible(child: child),
        ],
      ),
    );
  }
}
