import 'package:chat/common/theme.dart';
import 'package:flutter/material.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';

class SendButton extends StatelessWidget {
  const SendButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      // margin: InheritedChatTheme.of(context).theme.sendButtonMargin ??
      //     const EdgeInsets.only(left: 16),
      width: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppGlass.activeGradient,
        boxShadow: AppGlass.buttonShadow,
      ),
      child: IconButton(
        icon: InheritedChatTheme.of(context).theme.sendButtonIcon ??
            Image.asset(
              'assets/icon-send.png',
              color: AppColors.white,
              width: 18,
              height: 18,
              package: 'chat',
            ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        tooltip: InheritedL10n.of(context).l10n.sendButtonAccessibilityLabel,
      ),
    );
  }
}
