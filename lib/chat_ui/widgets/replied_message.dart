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
  }) : super(key: key);

  /// Called when user presses cancel reply button
  final void Function()? onCancelReplyPressed;

  /// Current message author id
  final String? messageAuthorId;

  /// Message that is being replied to by current message
  final types.Message? repliedMessage;

  /// Show user names for replied messages.
  final bool showUserNames;

  @override
  Widget build(BuildContext context) {
    String _text = '';
    String? _imageUri;
    final bool _closable = onCancelReplyPressed != null;
    final bool _isCurrentUser =
        messageAuthorId == InheritedUser.of(context).user.id;
    final _theme = InheritedChatTheme.of(context).theme;

    if (repliedMessage != null) {
      switch (repliedMessage!.type) {
        case types.MessageType.file:
          final fileMessage = repliedMessage as types.FileMessage;
          _text = fileMessage.name;
          break;
        case types.MessageType.image:
          final imageMessage = repliedMessage as types.ImageMessage;
          _text = "Photo";
          _imageUri = imageMessage.uri;
          break;
        case types.MessageType.text:
          final textMessage = repliedMessage as types.TextMessage;
          _text = textMessage.text;
          break;
        default:
          break;
      }
    }

    return Container(
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
              : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (repliedMessage?.author.firstName != null && showUserNames)
                  Text(
                    _closable ? 'Replying ${repliedMessage!.author.firstName!} ${repliedMessage!.author.lastName!}' : _text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _closable ? Colors.black : _isCurrentUser ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                Text(
                  _closable ? _text :'${repliedMessage!.author.firstName!} ${repliedMessage!.author.lastName!}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _closable ? Colors.grey : _isCurrentUser ? Colors.grey.shade400 : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                if(!_closable) Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: Container(height: 1.0,color: _isCurrentUser ? Colors.white : Colors.grey,),
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
    );
  }
}
