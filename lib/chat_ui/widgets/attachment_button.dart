import 'package:flutter/material.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';

/// A class that represents attachment button widget
class AttachmentButton extends StatelessWidget {
  /// Creates attachment button widget
  const AttachmentButton({
    Key? key,
    this.onPressed,
    required this.image,

  }) : super(key: key);

  /// Callback for attachment button tap event
  final void Function()? onPressed;
  final String image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 24,
      child: IconButton(
        icon: InheritedChatTheme.of(context).theme.attachmentButtonIcon != null
            ? InheritedChatTheme.of(context).theme.attachmentButtonIcon!
            : Image.asset(
                image,
                package: 'chat',
              ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        tooltip:
            InheritedL10n.of(context).l10n.attachmentButtonAccessibilityLabel,
      ),
    );
  }
}
