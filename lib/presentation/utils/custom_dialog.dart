import 'package:chat/common/custom_navigator.dart';
import 'package:chat/presentation/utils/dialog.dart';
import 'package:flutter/material.dart';

class CustomShowDialog{
  static showPopup(
    BuildContext context,
    Widget child, {
    bool root = true,
    bool isExpanded = false,
    bool cancelable = true,
  }) {
    return CustomNavigator.push(
      context,
      CustomDialogWidget(
        screen: CustomPopupDialog(child: child, isExpanded: isExpanded),
        cancelable: cancelable,
      ),
      opaque: false,
      root: root,
    );
  }
}
