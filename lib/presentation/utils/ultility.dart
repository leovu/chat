import 'dart:io';

import 'package:chat/chat_ui/chat_theme.dart' show avatarColors;
import 'package:chat/data_model/room.dart' show Owner;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

Color getAvatarColor(String? id) {
  if (id == null || id.isEmpty) return avatarColors[0];
  int hash = 0;
  for (final c in id.codeUnits) {
    hash = (hash * 31 + c) & 0x7FFFFFFF;
  }
  return avatarColors[hash % avatarColors.length];
}

String getAvatarName(String firstName, String lastName) {
  final f = firstName.trim();
  final l = lastName.trim();
  if (f.isEmpty && l.isEmpty) return '?';
  if (l.isEmpty) return f[0].toUpperCase();
  if (f.isEmpty) return l[0].toUpperCase();
  return '${f[0]}${l[0]}'.toUpperCase();
}

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