/*
* Created by: nguyenan
* Created at: 2024/05/02 11:29
*/
import 'package:chat/common/widges/widget.dart';
import 'package:chat/presentation/utils/extension.dart';
import 'package:chat/presentation/utils/progress_dialog.dart';
import 'package:flutter/material.dart';

class CustomNavigator {
  static push(BuildContext context, Widget screen,
      {bool root = true,
        bool opaque = true,
        String? routeName,
        ScreenArguments? arguments,
        bool isSaleV2 = false}) {
    Navigator.of(context, rootNavigator: root).removeHUD();

    return Navigator.of(context, rootNavigator: root).push(opaque
        ? CustomRoute(page: screen, routeName: routeName, arguments: arguments)
        : CustomRouteDialog(
        page: screen, routeName: routeName, arguments: arguments));
  }

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

  static canPop(BuildContext context) {
    ModalRoute<Object?>? parentRoute = ModalRoute.of(context);
    return parentRoute?.canPop ?? false;
  }

  static showCustomAlertDialog(
      BuildContext context, String? title, String? content,
      {bool root = true,
        Function()? onSubmitted,
        String? textSubmitted,
        String? textSubSubmitted,
        Function()? onSubSubmitted,
        bool enableCancel = true,
        bool cancelable = true,
        bool isAsset = false,
        bool enableSubmitted = true,
        bool enableSubSubmitted = true,
        Widget? header,
        String? image,
        String? iconCenter,
        String? titleHeader,
        bool isProgress = false,
        Widget? widgetCopy}) {
    return push(
        context,
        CustomDialog(
          screen: CustomAlertDialog(
            title: title,
            content: content,
            textSubmitted: textSubmitted,
            onSubmitted: onSubmitted,
            textSubSubmitted: textSubSubmitted,
            onSubSubmitted: onSubSubmitted,
            enableCancel: enableCancel,
            iconCenter: iconCenter,
            titleHeader: titleHeader,
            enableSubmitted: enableSubmitted,
            enableSubSubmitted: enableSubSubmitted,
            isProgress: isProgress,
            widgetCopy: widgetCopy,
          ),
          cancelable: cancelable,
        ),
        opaque: false,
        root: root);
  }

  static ProgressDialog? _pr;
  static showProgressDialog(BuildContext context, {bool isWarning = false}) {
    if (_pr == null) {
      _pr = ProgressDialog(context, isWarning: isWarning);
      _pr!.show();
    }
  }

  static hideProgressDialog() {
    if (_pr != null && _pr!.isShowing()) {
      _pr!.hide();
      _pr = null;
    }
  }
}