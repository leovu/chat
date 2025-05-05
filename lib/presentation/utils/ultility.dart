import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

configKeyboardActions(List<KeyboardActionsItem> actions) {
  return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
      keyboardBarColor: Colors.grey[200],
      actions: actions);
}
