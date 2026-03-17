import 'dart:io';

import 'package:chat/data_model/room.dart' show Owner;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

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

String getAvatarName(String? firstName, String? lastName) {
  String clean(String? s) => (s ?? '').replaceAll(RegExp(r'[^A-Za-z0-9]'), '');

  final f = clean(firstName);
  final l = clean(lastName);

  final avatar = '${f.isNotEmpty ? f[0] : ''}${l.isNotEmpty ? l[0] : ''}';

  return avatar.isEmpty ? '*' : avatar.toUpperCase();
}

String getAvatarGroupName(String? title) {
  if (title == null || title.trim().isEmpty) return '*';

  final words = title.trim().split(RegExp(r'\s+'));
  final avatar = words.length > 1
      ? '${words[0][0]}${words[1][0]}'
      : words[0].substring(0, words[0].length >= 2 ? 2 : 1);

  return avatar.toUpperCase();
}
