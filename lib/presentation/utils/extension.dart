import 'package:chat/common/custom_navigator.dart';
import 'package:chat/common/theme.dart';
import 'package:flutter/cupertino.dart';

extension NavigatorStateExtension on NavigatorState {
  removeHUD() {
    bool isHUDOn = false;
    popUntil((route) {
      if (route.settings.name == AppKeys.keyHUD) {
        isHUDOn = true;
      }
      return true;
    });

    if (isHUDOn) {
      CustomNavigator.hideProgressDialog();
    }
  }
}