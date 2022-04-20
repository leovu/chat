import 'package:flutter/material.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';

/// A class that represents send button widget
class SendButton extends StatelessWidget {
  /// Creates send button widget
  const SendButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  /// Callback for send button tap event
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24,
      margin: InheritedChatTheme.of(context).theme.sendButtonMargin ??
          const EdgeInsets.only(left: 16),
      width: 24,
      child: IconButton(
        icon: InheritedChatTheme.of(context).theme.sendButtonIcon ??
            Image.asset(
              'assets/icon-send.png',
              color: const Color(0xFF9012FE),
              package: 'chat',
            ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        tooltip: InheritedL10n.of(context).l10n.sendButtonAccessibilityLabel,
      ),
    );
  }
}
