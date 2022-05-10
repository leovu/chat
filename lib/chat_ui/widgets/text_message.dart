import 'package:chat/chat_ui/widgets/replied_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_link_previewer/flutter_link_previewer.dart'
    show LinkPreview, regexLink;
import '../models/emoji_enlargement_behavior.dart';
import '../util.dart';
import 'inherited_chat_theme.dart';
import 'inherited_user.dart';
/// A class that represents text message widget with optional link preview
class TextMessage extends StatelessWidget {
  /// Creates a text message widget from a [types.TextMessage] class
  const TextMessage({
    Key? key,
    required this.emojiEnlargementBehavior,
    required this.hideBackgroundOnEmojiMessages,
    required this.message,
    this.onPreviewDataFetched,
    required this.usePreviewData,
    required this.showName,
    required this.searchController,
    required this.showUserNameForRepliedMessage,
  }) : super(key: key);

  /// See [Message.emojiEnlargementBehavior]
  final EmojiEnlargementBehavior emojiEnlargementBehavior;

  /// See [Message.hideBackgroundOnEmojiMessages]
  final bool hideBackgroundOnEmojiMessages;

  /// [types.TextMessage]
  final types.TextMessage message;

  /// See [LinkPreview.onPreviewDataFetched]
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// Show user name for the received message. Useful for a group chat.
  final bool showName;

  /// Enables link (URL) preview
  final bool usePreviewData;

  final TextEditingController searchController;

  /// Show user name for replied message.
  final bool showUserNameForRepliedMessage;

  void _onPreviewDataFetched(types.PreviewData previewData) {
    if (message.previewData == null) {
      onPreviewDataFetched?.call(message, previewData);
    }
  }

  Widget _linkPreview(
    types.User user,
    double width,
    BuildContext context,
  ) {
    final bodyLinkTextStyle = user.id == message.author.id
        ? InheritedChatTheme.of(context).theme.sentMessageBodyLinkTextStyle
        : InheritedChatTheme.of(context).theme.receivedMessageBodyLinkTextStyle;
    final bodyTextStyle = user.id == message.author.id
        ? InheritedChatTheme.of(context).theme.sentMessageBodyTextStyle
        : InheritedChatTheme.of(context).theme.receivedMessageBodyTextStyle;
    final linkDescriptionTextStyle = user.id == message.author.id
        ? InheritedChatTheme.of(context)
            .theme
            .sentMessageLinkDescriptionTextStyle
        : InheritedChatTheme.of(context)
            .theme
            .receivedMessageLinkDescriptionTextStyle;
    final linkTitleTextStyle = user.id == message.author.id
        ? InheritedChatTheme.of(context).theme.sentMessageLinkTitleTextStyle
        : InheritedChatTheme.of(context)
            .theme
            .receivedMessageLinkTitleTextStyle;

    final color = getUserAvatarNameColor(message.author,
        InheritedChatTheme.of(context).theme.userAvatarNameColors);
    final name = getUserName(message.author);
    return LinkPreview(
      enableAnimation: true,
      header: showName ? name : null,
      headerStyle: InheritedChatTheme.of(context)
          .theme
          .userNameTextStyle
          .copyWith(color: color),
      linkStyle: bodyLinkTextStyle ?? bodyTextStyle,
      metadataTextStyle: linkDescriptionTextStyle,
      metadataTitleStyle: linkTitleTextStyle,
      onPreviewDataFetched: _onPreviewDataFetched,
      padding: EdgeInsets.symmetric(
        horizontal:
            InheritedChatTheme.of(context).theme.messageInsetsHorizontal,
        vertical: InheritedChatTheme.of(context).theme.messageInsetsVertical,
      ),
      previewData: message.previewData,
      text: message.text,
      textStyle: bodyTextStyle,
      width: width,
    );
  }

  Widget _textWidgetBuilder(
    types.User user,
    BuildContext context,
    bool enlargeEmojis,
  ) {
    final theme = InheritedChatTheme.of(context).theme;
    final color =
        getUserAvatarNameColor(message.author, theme.userAvatarNameColors);
    final name = getUserName(message.author);
    List<String> contents = message.text.split(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.repliedMessage != null)
          RepliedMessage(
            messageAuthorId: message.author.id,
            repliedMessage: message.repliedMessage,
            showUserNames: showUserNameForRepliedMessage,
          ),
        if (showName)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.userNameTextStyle.copyWith(color: color),
            ),
          ),
        SelectableText.rich(
          TextSpan(
            children: contentMessage(contents, user, context, color, enlargeEmojis),
          ),
        ),
      ],
    );
  }

  List<InlineSpan> contentMessage(List<String> contents,
      types.User user,
      BuildContext context,
      Color color,
      bool enlargeEmojis,) {
    final theme = InheritedChatTheme.of(context).theme;
    List<InlineSpan> arr = [];
    for (int i = 0; i < contents.length; i++) {
      var element = contents[i];
      if(element.toLowerCase() == searchController.value.text.toLowerCase()) {
        arr.add(TextSpan(
            text: element,
            style:
            TextStyle(
              color: const Color(0xffffffff),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
              background: Paint()
                ..color = Colors.redAccent,
            )));
      }
      else {
        arr.add(TextSpan(
            text: element,
            style: user.id == message.author.id
                ? enlargeEmojis
                ? theme.sentEmojiMessageTextStyle
                : theme.sentMessageBodyTextStyle
                : enlargeEmojis
                ? theme.receivedEmojiMessageTextStyle
                : theme.receivedMessageBodyTextStyle));
      }
      if(i < contents.length-1) {
        arr.add(TextSpan(
            text: ' ',
            style: user.id == message.author.id
                ? enlargeEmojis
                ? theme.sentEmojiMessageTextStyle
                : theme.sentMessageBodyTextStyle
                : enlargeEmojis
                ? theme.receivedEmojiMessageTextStyle
                : theme.receivedMessageBodyTextStyle));
      }
    }
    return arr;
  }

  @override
  Widget build(BuildContext context) {
    var _enlargeEmojis =
        emojiEnlargementBehavior != EmojiEnlargementBehavior.never &&
            isConsistsOfEmojis(emojiEnlargementBehavior, message);
    if(message.repliedMessage != null) {
      _enlargeEmojis = false;
    }
    final _theme = InheritedChatTheme.of(context).theme;
    final _user = InheritedUser.of(context).user;
    final _width = MediaQuery.of(context).size.width;

    if (usePreviewData && onPreviewDataFetched != null) {
      final urlRegexp = RegExp(regexLink, caseSensitive: false);
      final matches = urlRegexp.allMatches(message.text);

      if (matches.isNotEmpty) {
        return _linkPreview(_user, _width, context);
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: _enlargeEmojis && hideBackgroundOnEmojiMessages
            ? 0.0
            : _theme.messageInsetsHorizontal,
        vertical: _theme.messageInsetsVertical,
      ),
      child: _textWidgetBuilder(_user, context, _enlargeEmojis),
    );
  }
}
