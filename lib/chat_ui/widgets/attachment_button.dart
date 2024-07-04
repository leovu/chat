import 'package:flutter/material.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';

/// A class that represents attachment button widget
class AttachmentButton extends StatelessWidget {
  /// Creates attachment button widget
  const AttachmentButton({
    Key? key,
    this.onPressed,
    this.image,
    this.icon,
  }) : super(key: key);

  /// Callback for attachment button tap event
  final void Function()? onPressed;
  final String? image;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 24,
      child: IconButton(
        icon: InheritedChatTheme.of(context).theme.attachmentButtonIcon != null
            ? InheritedChatTheme.of(context).theme.attachmentButtonIcon!
            : (icon != null ) ? Icon(icon, color: Colors.black54,) :
        Padding(
              padding: EdgeInsets.all(image == 'assets/icon-chat-add.png' ? 1.5 : 0.0),
              child:  Image.asset(
                  image!,
                  package: 'chat',
                ),
            ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        tooltip:
            InheritedL10n.of(context).l10n.attachmentButtonAccessibilityLabel,
      ),
    );
  }
}
