import 'dart:io';

import 'package:chat/common/avatar_style.dart';
import 'package:chat/data_model/room.dart' show Owner;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

// Màu + chữ viết tắt avatar lấy từ nguồn đồng bộ duy nhất (avatar_style.dart).
export 'package:chat/common/avatar_style.dart'
    show getAvatarColor, getAvatarTextColor, getAvatarInitials, avatarColors;

String getAvatarName(String firstName, String lastName) =>
    getAvatarInitials(firstName, lastName);

configKeyboardActions(List<KeyboardActionsItem> actions) {
  return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.grey[200],
      actions: actions);
}

String? checkCustomerTypeChatHub(Owner owner) {
  String? result;
  try {
    if (owner.customerId != null) {
      result = 'customer';
    } else {
      if (owner.cpoCustomerId != null) {
        result = 'cpo';
      }
    }
  } catch (_) {}
  return result;
}

Future showLoading(BuildContext context) async {
  return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return SimpleDialog(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          children: <Widget>[
            Center(
              child: Platform.isAndroid
                  ? const CircularProgressIndicator()
                  : const CupertinoActivityIndicator(),
            )
          ],
        );
      });
}
