/*
* Created by: nguyenan
* Created at: 2021/07/05 2:07 PM
*/
part of widget;

class CustomRoute extends MaterialPageRoute {
  final Widget page;
  final String? routeName;
  final ScreenArguments? arguments;
  CustomRoute({required this.page, this.routeName, this.arguments})
      : super(builder: (context) => page);

  @override
  // TODO: implement settings
  RouteSettings get settings => RouteSettings(
      name: routeName ?? page.runtimeType.toString(), arguments: arguments);
}

class CustomRouteHero extends PageRouteBuilder {
  final Widget page;
  final String? routeName;
  final ScreenArguments? arguments;
  CustomRouteHero({
    this.arguments,
    required this.page,
    this.routeName,
  }) : super(
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
      page,
      transitionsBuilder: (BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(animation),
          child: child,
        );
      },
      opaque: true,
      transitionDuration: Duration(milliseconds: 1000));

  @override
  // TODO: implement settings
  RouteSettings get settings => opaque
      ? RouteSettings(
      name: routeName ?? page.runtimeType.toString(), arguments: arguments)
      : super.settings;
}

class CustomRouteDialog extends PageRouteBuilder {
  final Widget page;
  final String? routeName;
  final ScreenArguments? arguments;
  CustomRouteDialog({
    this.arguments,
    required this.page,
    this.routeName,
  }) : super(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder:
          (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(animation),
          child: child,
        );
      },
      opaque: false);
  @override
  // TODO: implement settings
  RouteSettings get settings => opaque
      ? RouteSettings(
      name: routeName ?? page.runtimeType.toString(), arguments: arguments)
      : super.settings;
}

class ScreenArguments {
  final String? title;
  final dynamic model;

  ScreenArguments(this.model,{this.title});
}
