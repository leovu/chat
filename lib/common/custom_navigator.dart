/*
* Created by: nguyenan
* Created at: 2024/05/02 11:29
*/
import 'package:flutter/material.dart';

class CustomNavigator {
  // static push(BuildContext context, Widget screen,
  //     {bool root = true,
  //       bool opaque = true,
  //       String? routeName,
  //       bool isSaleV2 = false}) {
  //   String name =
  //       "${screen.runtimeType.toString().replaceAll('Screen', '')}Screen";
  //   return Navigator.of(context, rootNavigator: root).push(opaque
  //       ? CustomRoute(page: screen, routeName: routeName, arguments: arguments)
  //       : CustomRouteDialog(
  //       page: screen, routeName: routeName, arguments: arguments));
  // }

  static pushViewController(BuildContext context, Widget screen) {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) =>
        screen,
        transitionDuration: Duration.zero,
        barrierDismissible: false,
        barrierColor: Colors.black45,
        opaque: false,
      ),
    );
  }

  static popToScreen(BuildContext context, Widget screen,
      {bool root = true, String? routeName, bool isSaleV2 = false}) {
    Navigator.of(context, rootNavigator: root).popUntil((route) {
      return route.settings.name ==
          (routeName ?? screen.runtimeType.toString());
    });
  }

  static popToNameScreen(BuildContext context, String? routeName,
      {bool root = true, bool isSaleV2 = false}) {

    Navigator.of(context, rootNavigator: root).popUntil((route) {
      if (routeName != null) {
        return route.settings.name == routeName;
      } else {
        return route.isFirst;
      }
    });
  }

  static popToRoot(BuildContext context, {bool root = true}) {
    Navigator.of(context, rootNavigator: root)
        .popUntil((route) => route.isFirst);
  }

  static pop(BuildContext context, {dynamic object, bool root = true}) {
    if (object == null) {
      Navigator.of(context, rootNavigator: root).pop();
    } else {
      Navigator.of(context, rootNavigator: root).pop(object);
    }
  }
}