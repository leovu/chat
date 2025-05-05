import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool?> showMissingDateDialog(
  BuildContext context,
  String title,
  String content,
) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false), // Hủy
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true), // Đồng ý
          child: const Text('Đồng ý'),
        ),
      ],
    ),
  );
}

Future<void> showInfoDialog(
  BuildContext context,
  String title,
  VoidCallback onOk, {
  String? content,
  bool isError = false,
  VoidCallback? onCancel,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      final Color headerColor = isError ? Colors.red : Colors.green;

      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Center(
                child: AutoSizeText(
                  title,
                  minFontSize: 10,
                  maxFontSize: 20,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            // Body
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: AutoSizeText(
                content ?? '',
                minFontSize: 10,
                maxFontSize: 20,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onCancel != null)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onCancel();
                    },
                    child: AutoSizeText(
                      AppLocalizations.text(LangKey.cancel),
                      minFontSize: 10,
                      maxFontSize: 20,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onOk();
                  },
                  child: AutoSizeText(
                    'OK',
                    minFontSize: 10,
                    maxFontSize: 20,
                    style: TextStyle(color: headerColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

void showSnackBarError(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}
