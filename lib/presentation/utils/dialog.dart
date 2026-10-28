import 'package:chat/common/custom_navigator.dart';
import 'package:chat/common/theme.dart';
import 'package:chat/common/widges/widget.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/material.dart';

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
      final Color headerColor =
          isError ? AppColors.dangerColor : AppColors.primaryColor;

      return AlertDialog(
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isError ? headerColor : null,
                gradient: isError ? null : AppGlass.headerGradient,
              ),
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
            // Body
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Text(
                content ?? '',
                style: const TextStyle(
                    color: AppColors.textBodyColor, fontSize: 14),
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
                    child: Text(
                      AppLocalizations.text(LangKey.cancel),
                      style:
                          const TextStyle(color: AppColors.textSecondaryColor),
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    onOk();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                        color: headerColor, fontWeight: FontWeight.w600),
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
      backgroundColor: AppColors.dangerColor,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}


class CustomDialogWidget extends StatelessWidget {
  final Widget screen;
  final bool cancelable;

  CustomDialogWidget({
    required this.screen,
    this.cancelable = true,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return CustomScaffold(
      backgroundColor: AppColors.textTitleColor.withValues(alpha: 0.3),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.sizeOf(context).height,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              GestureDetector(
                onTap: cancelable ? () => CustomNavigator.pop(context) : null,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    constraints: BoxConstraints(
                      maxWidth:  MediaQuery.sizeOf(context).height,
                    ),
                    margin:
                        EdgeInsets.symmetric(horizontal: 16),
                    child: screen,
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
class CustomPopupDialog extends StatelessWidget {

  final Widget child;
  final bool isExpanded;

  CustomPopupDialog({
    required this.child,
    this.isExpanded = false
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: isExpanded?Container(
        decoration: AppGlass.card(color: Colors.white),
        height: MediaQuery.of(context).size.height * 0.5,
        child: child,
      ):Container(
        decoration: AppGlass.card(color: Colors.white),
        child: child,
      ),
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}
