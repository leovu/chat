import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:chat/chat_ui/widgets/inherited_user.dart';
import 'inherited_chat_theme.dart';

class RepliedMessage extends StatelessWidget {
  const RepliedMessage({
    Key? key,
    this.onCancelReplyPressed,
    this.messageAuthorId,
    required this.repliedMessage,
    this.showUserNames = false,
    required this.onMessageTap,
  }) : super(key: key);

  /// Called when user presses cancel reply button
  final void Function()? onCancelReplyPressed;

  /// Current message author id
  final String? messageAuthorId;

  /// Message that is being replied to by current message
  final types.Message? repliedMessage;

  /// Show user names for replied messages.
  final bool showUserNames;

  /// See [Message.onMessageTap]
  final void Function(BuildContext context, types.Message, bool isRepliedMessage)? onMessageTap;

  @override
  Widget build(BuildContext context) {
    String _text = '';
    String? _imageUri;
    bool _isFile = false;
    final bool _closable = onCancelReplyPressed != null;
    final bool _isCurrentUser =
        messageAuthorId == InheritedUser.of(context).user.id;
    final _theme = InheritedChatTheme.of(context).theme;

    if (repliedMessage != null) {
      switch (repliedMessage!.type) {
        case types.MessageType.file:
          final fileMessage = repliedMessage as types.FileMessage;
          _text = fileMessage.name;
          _isFile = true;
          break;
        case types.MessageType.image:
          final imageMessage = repliedMessage as types.ImageMessage;
          _text = AppLocalizations.text(LangKey.photo);
          _imageUri = imageMessage.uri;
          break;
        case types.MessageType.text:
          final textMessage = repliedMessage as types.TextMessage;
          _text = checkTag(textMessage.text);
          break;
        default:
          break;
      }
    }

    return InkWell(
      onTap: () {
        if ((_imageUri != null || _isFile) &&
            repliedMessage != null &&
            onMessageTap != null) {
          onMessageTap!(context, repliedMessage!,true);
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(_text),
            ),
          );
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(bottom: _closable ? 0 : 8),
        padding: _closable
            ? _theme.closableRepliedMessagePadding
            : const EdgeInsets.fromLTRB(0, 0, 0, 0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30.0)),
          color: _closable ? Colors.grey.shade50 : Colors.transparent,
        ),
        child: Row(
          children: [
            _imageUri != null
                ? Container(
                    width: 44,
                    height: 44,
                    margin: _theme.repliedMessageImageMargin,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _imageUri,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : _isFile
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(21),
                          ),
                          child: Image.asset(
                            'assets/icon-document.png',
                            color: Colors.white,
                            package: 'chat',
                          ),
                        ),
                      )
                    : Container(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (repliedMessage?.author.firstName != null && showUserNames)
                    Text(
                      _closable
                          ? '${AppLocalizations.text(LangKey.replying)} ${repliedMessage!.author.firstName!} ${repliedMessage!.author.lastName!}'
                          : _text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _closable
                            ? Colors.black
                            : _isCurrentUser
                                ? Colors.black
                                : Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  Text(
                    _closable
                        ? _text
                        : '${repliedMessage!.author.firstName!} ${repliedMessage!.author.lastName!}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _closable
                          ? Colors.grey
                          : _isCurrentUser
                              ? Colors.grey.shade600
                              : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  if (!_closable)
                    Padding(
                      padding: const EdgeInsets.only(top: 1.0),
                      child: Container(
                        height: 1.0,
                        color: Colors.grey,
                      ),
                    )
                ],
              ),
            ),
            if (_closable)
              Container(
                margin: _theme.closableRepliedMessageImageMargin,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(12),
                ),
                height: 20,
                width: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 15.0,
                  ),
                  onPressed: () => onCancelReplyPressed?.call(),
                  padding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String checkTag(String message) {
    List<String> contents = message.split(' ');
    String result = '';
    for (int i = 0; i < contents.length; i++) {
      var element = contents[i];
      if (element == '@all-all@') {
        element = '@${AppLocalizations.text(LangKey.all)}';
      }
      try {
        if (element[element.length - 1] == '@' && element.contains('-')) {
          element = element.split('-').first;
        }
      } catch (_) {}
      result += '$element ';
    }
    return result.trim();
  }
}
