import 'package:chat/data_model/room.dart' show Owner;
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