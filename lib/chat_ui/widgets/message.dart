import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../models/emoji_enlargement_behavior.dart';
import '../util.dart';
import 'file_message.dart';
import 'image_message.dart';
import 'inherited_chat_theme.dart';
import 'text_message.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:chat/data_model/chat_message.dart' as c;
import '../../data_model/room.dart' as r;

/// Base widget for all message types in the chat. Renders bubbles around
/// messages and status. Sets maximum width for a message for
/// a nice look on larger screens.
class Message extends StatelessWidget {
  /// Creates a particular message from any message type
  const Message({
    Key? key,
    this.bubbleBuilder,
    this.customMessageBuilder,
    required this.emojiEnlargementBehavior,
    this.fileMessageBuilder,
    required this.hideBackgroundOnEmojiMessages,
    this.imageMessageBuilder,
    required this.message,
    required this.messageWidth,
    this.onAvatarTap,
    this.onMessageDoubleTap,
    this.onMessageLongPress,
    this.onMessageStatusLongPress,
    this.onMessageStatusTap,
    this.onMessageTap,
    this.onMessageVisibilityChanged,
    this.onPreviewDataFetched,
    required this.roundBorder,
    required this.showAvatar,
    required this.showName,
    required this.showStatus,
    required this.showUserAvatars,
    this.textMessageBuilder,
    required this.usePreviewData,
    required this.searchController,
    required this.focusSearch,
    required this.replySwipeDirection,
    required this.onMessageReply,
    required this.people,
    this.seenPeople,
  }) : super(key: key);

  /// Customize the default bubble using this function. `child` is a content
  /// you should render inside your bubble, `message` is a current message
  /// (contains `author` inside) and `nextMessageInGroup` allows you to see
  /// if the message is a part of a group (messages are grouped when written
  /// in quick succession by the same author)
  final Widget Function(
    Widget child, {
    required types.Message message,
    required bool nextMessageInGroup,
  })? bubbleBuilder;

  /// Build a custom message inside predefined bubble
  final Widget Function(types.CustomMessage, {required int messageWidth})?
      customMessageBuilder;

  /// Controls the enlargement behavior of the emojis in the
  /// [types.TextMessage].
  /// Defaults to [EmojiEnlargementBehavior.multi].
  final EmojiEnlargementBehavior emojiEnlargementBehavior;

  /// Build a file message inside predefined bubble
  final Widget Function(types.FileMessage, {required int messageWidth})?
      fileMessageBuilder;

  /// Hide background for messages containing only emojis.
  final bool hideBackgroundOnEmojiMessages;

  /// Build an image message inside predefined bubble
  final Widget Function(types.ImageMessage, {required int messageWidth})?
      imageMessageBuilder;

  /// Any message type
  final types.Message message;

  /// Maximum message width
  final int messageWidth;

  /// Swipe direction for reply message feature
  final SwipeDirection replySwipeDirection;

  // Called when uses taps on an avatar
  final void Function(types.User)? onAvatarTap;

  /// Called when user double taps on any message
  final void Function(BuildContext context, types.Message)? onMessageDoubleTap;

  /// Called when user makes a long press on any message
  final void Function(BuildContext context, types.Message)? onMessageLongPress;

  /// Called when user makes a long press on any message
  final void Function(BuildContext context, types.Message?) onMessageReply;

  /// Called when user makes a long press on status icon in any message
  final void Function(BuildContext context, types.Message)?
      onMessageStatusLongPress;

  /// Called when user taps on status icon in any message
  final void Function(BuildContext context, types.Message)? onMessageStatusTap;

  /// Called when user taps on any message
  final void Function(BuildContext context, types.Message, bool isRepliedMessage)? onMessageTap;

  /// Called when the message's visibility changes
  final void Function(types.Message, bool visible)? onMessageVisibilityChanged;

  /// See [TextMessage.onPreviewDataFetched]
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// Rounds border of the message to visually group messages together.
  final bool roundBorder;

  /// Show user avatar for the received message. Useful for a group chat.
  final bool showAvatar;

  /// See [TextMessage.showName]
  final bool showName;

  /// Show message's status
  final bool showStatus;

  /// Show user avatars for received messages. Useful for a group chat.
  final bool showUserAvatars;

  final TextEditingController searchController;
  final Function focusSearch;

  /// Build a text message inside predefined bubble.
  final Widget Function(
    types.TextMessage, {
    required int messageWidth,
    required bool showName,
  })? textMessageBuilder;

  /// See [TextMessage.usePreviewData]
  final bool usePreviewData;

  final List<c.Author?>? seenPeople;
  final List<r.People>? people;

  Widget _avatarBuilder(BuildContext context) {
    final color = getUserAvatarNameColor(
      message.author,
      InheritedChatTheme.of(context).theme.userAvatarNameColors,
    );
    final hasImage = message.author.imageUrl != null;
    final initials = getUserInitials(message.author);
    return showAvatar
        ? Container(
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onAvatarTap?.call(message.author),
              child: CircleAvatar(
                backgroundColor: hasImage
                    ? InheritedChatTheme.of(context)
                        .theme
                        .userAvatarImageBackgroundColor
                    : color,
                backgroundImage:
                    hasImage ? NetworkImage(message.author.imageUrl!,headers: {'brand-code':ChatConnection.brandCode!}) : null,
                radius: 16,
                child: !hasImage
                    ? Text(
                        initials,
                        style: InheritedChatTheme.of(context)
                            .theme
                            .userAvatarTextStyle,
                      )
                    : null,
              ),
            ),
          )
        : const SizedBox(width: 40);
  }

  Widget _bubbleBuilder(
    BuildContext context,
    BorderRadius borderRadius,
    bool currentUserIsAuthor,
    bool enlargeEmojis,
  ) {
    return bubbleBuilder != null
        ? bubbleBuilder!(
            _messageBuilder(),
            message: message,
            nextMessageInGroup: roundBorder,
          )
        : enlargeEmojis && hideBackgroundOnEmojiMessages
            ? _messageBuilder()
            : Container(
              key: key,
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                color: !currentUserIsAuthor ||
                    message.type == types.MessageType.image
                    ? InheritedChatTheme.of(context).theme.secondaryColor
                    : InheritedChatTheme.of(context).theme.primaryColor,
              ),
              child: ClipRRect(
                borderRadius: borderRadius,
                child: _messageBuilder(),),
    );
  }

  Widget _messageBuilder() {
    switch (message.type) {
      case types.MessageType.custom:
        final customMessage = message as types.CustomMessage;
        return customMessageBuilder != null
            ? customMessageBuilder!(customMessage, messageWidth: messageWidth)
            : const SizedBox();
      case types.MessageType.file:
        final fileMessage = message as types.FileMessage;
        return fileMessageBuilder != null
            ? fileMessageBuilder!(fileMessage, messageWidth: messageWidth)
            : FileMessage(
                message: fileMessage,
                showUserNameForRepliedMessage: true,
                onMessageTap: onMessageTap,
                people: people,
              );
      case types.MessageType.image:
        final imageMessage = message as types.ImageMessage;
        return imageMessageBuilder != null
            ? imageMessageBuilder!(imageMessage, messageWidth: messageWidth)
            : ImageMessage(
                message: imageMessage,
                messageWidth: messageWidth,
                showUserNameForRepliedMessage: true,
                onMessageTap: onMessageTap,
          people: people,
              );
      case types.MessageType.text:
        final textMessage = message as types.TextMessage;
        return textMessageBuilder != null
            ? textMessageBuilder!(
                textMessage,
                messageWidth: messageWidth,
                showName: showName,
              )
            : TextMessage(
                emojiEnlargementBehavior: emojiEnlargementBehavior,
                hideBackgroundOnEmojiMessages: hideBackgroundOnEmojiMessages,
                message: textMessage,
                onPreviewDataFetched: onPreviewDataFetched,
                showName:  ChatConnection.isChatHub ? true : showName,
                usePreviewData: usePreviewData,
                searchController: searchController,
                showUserNameForRepliedMessage: true,
                people: people,
                onMessageTap: onMessageTap,
              );
      default:
        return const SizedBox();
    }
  }

  Widget _statusBuilder(BuildContext context) {
    switch (message.status) {
      case types.Status.delivered:
      case types.Status.sent:
        return InheritedChatTheme.of(context).theme.deliveredIcon != null
            ? InheritedChatTheme.of(context).theme.deliveredIcon!
            : Image.asset(
                'assets/icon-delivered.png',
                color: InheritedChatTheme.of(context).theme.primaryColor,
                package: 'chat',
              );
      case types.Status.error:
        return InheritedChatTheme.of(context).theme.errorIcon != null
            ? InheritedChatTheme.of(context).theme.errorIcon!
            : Image.asset(
                'assets/icon-error.png',
                color: InheritedChatTheme.of(context).theme.errorColor,
                package: 'chat',
              );
      case types.Status.seen:
        return InheritedChatTheme.of(context).theme.seenIcon != null
            ? InheritedChatTheme.of(context).theme.seenIcon!
            : Image.asset(
                'assets/icon-seen.png',
                color: InheritedChatTheme.of(context).theme.primaryColor,
                package: 'chat',
              );
      case types.Status.sending:
        return InheritedChatTheme.of(context).theme.sendingIcon != null
            ? InheritedChatTheme.of(context).theme.sendingIcon!
            : const Center(
                child: SizedBox(
                  height: 10,
                  width: 10,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.transparent,
                    strokeWidth: 1.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue,
                    ),
                  ),
                ),
              );
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    final _query = MediaQuery.of(context);
    final _currentUserIsAuthor = ChatConnection.checkUserTokenResponseModel!.user!.sId == message.author.id;
    var _enlargeEmojis =
        emojiEnlargementBehavior != EmojiEnlargementBehavior.never &&
            message is types.TextMessage &&
            isConsistsOfEmojis(
                emojiEnlargementBehavior, message as types.TextMessage);
    if(message.repliedMessage != null) {
      _enlargeEmojis = false;
    }
    final _messageBorderRadius =
        InheritedChatTheme.of(context).theme.messageBorderRadius;
    BorderRadiusDirectional _borderRadius = _currentUserIsAuthor
        ? BorderRadiusDirectional.only(
      bottomEnd: Radius.circular(
        _currentUserIsAuthor
            ? roundBorder
            ? _messageBorderRadius
            : 0
            : _messageBorderRadius,
      ),
      bottomStart: Radius.circular(
        _currentUserIsAuthor || roundBorder ? _messageBorderRadius : 0,
      ),
      topEnd: Radius.circular(_messageBorderRadius),
      topStart: Radius.circular(_messageBorderRadius),
    ) : BorderRadiusDirectional.only(
      bottomEnd: Radius.circular(_messageBorderRadius),
      bottomStart: Radius.circular(_messageBorderRadius),
      topEnd: Radius.circular(_messageBorderRadius),
      topStart: Radius.circular(!showAvatar
          ? _messageBorderRadius
          : 0),
    );
    return Column(
      children: [
          SwipeableTile.swipeToTrigger(
          behavior: HitTestBehavior.translucent,
            isElevated: false,
          color: InheritedChatTheme.of(context).theme.backgroundColor,
          swipeThreshold: 0.3,
          direction: replySwipeDirection,
          onSwiped: (_) {
            onMessageReply(context, message);
            focusSearch();
          },
          backgroundBuilder: (
              _,
              SwipeDirection direction,
              AnimationController progress,
              ) {
            bool vibrated = false;
            return AnimatedBuilder(
              animation: progress,
              builder: (_, __) {
                if (progress.value > 0.9999 && !vibrated) {
                  HapticFeedback.vibrate();
                  vibrated = true;
                } else if (progress.value < 0.9999) {
                  vibrated = false;
                }
                return Container(
                  alignment: replySwipeDirection == SwipeDirection.endToStart
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: replySwipeDirection == SwipeDirection.endToStart
                        ? const EdgeInsets.only(right: 32.0)
                        : const EdgeInsets.only(left: 32.0),
                    child: Transform.scale(
                      scale: Tween<double>(
                        begin: 0.0,
                        end: 1.2,
                      )
                          .animate(
                        CurvedAnimation(
                          parent: progress,
                          curve: const Interval(0.3, 1.0, curve: Curves.linear),
                        ),
                      )
                          .value,
                      child: Container(
                        decoration: BoxDecoration(
                          color: InheritedChatTheme.of(context)
                              .theme
                              .receivedMessageDocumentIconColor
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        height: 24,
                        width: 24,
                        child:
                        InheritedChatTheme.of(context).theme.replyIcon != null
                            ? InheritedChatTheme.of(context).theme.replyIcon!
                            : Image.asset(
                          'assets/icon-reply.png',
                          color: InheritedChatTheme.of(context)
                              .theme
                              .receivedMessageDocumentIconColor,
                          package: 'chat',
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
          key: UniqueKey(),
          child: Container(
            alignment: _currentUserIsAuthor
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            margin: EdgeInsetsDirectional.only(
              bottom: 4,
              end: kIsWeb ? 0 : _query.padding.right,
              start: 20 + (kIsWeb ? 0 : _query.padding.left),
            ),
            child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!_currentUserIsAuthor && showUserAvatars)  Padding(padding: const EdgeInsets.only(top: 5.0),child: _avatarBuilder(context),),
                    if(message.remoteId != null && message.remoteId == '1' && _currentUserIsAuthor)
                      const SizedBox(
                        height: 30.0,
                        child: Padding(
                          padding: EdgeInsets.only(right: 3.0,top: 20.0),
                          child: Icon(Icons.edit_outlined,color: Colors.black,size: 15.0,
                          ),
                        ),
                      ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: messageWidth.toDouble(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onDoubleTap: () => onMessageDoubleTap?.call(context, message),
                            onLongPress: () => onMessageLongPress?.call(context, message),
                            onTap: () => onMessageTap?.call(context, message, false),
                            child: onMessageVisibilityChanged != null ? VisibilityDetector(
                              key: Key(message.id),
                              onVisibilityChanged: (visibilityInfo) =>
                                  onMessageVisibilityChanged!(message,
                                      visibilityInfo.visibleFraction > 0.1),
                              child: _bubbleBuilder(
                                context,
                                _borderRadius.resolve(Directionality.of(context)),
                                _currentUserIsAuthor,
                                _enlargeEmojis,
                              ),
                            ) : _bubbleBuilder(
                              context,
                              _borderRadius.resolve(Directionality.of(context)),
                              _currentUserIsAuthor,
                              _enlargeEmojis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_currentUserIsAuthor)
                      Padding(
                        padding: InheritedChatTheme.of(context).theme.statusIconPadding,
                        child: showStatus
                            ? GestureDetector(
                          onLongPress: () =>
                              onMessageStatusLongPress?.call(context, message),
                          onTap: () => onMessageStatusTap?.call(context, message),
                          child: _statusBuilder(context),
                        )
                            : null,
                      ),
                    if(message.remoteId != null && message.remoteId == '1' && !_currentUserIsAuthor)
                      const SizedBox(
                        height: 30.0,
                        child: Padding(
                          padding: EdgeInsets.only(right: 3.0,top: 20.0),
                          child: Icon(Icons.edit_outlined,color: Colors.black,size: 15.0,
                          ),
                        ),
                      ),
                  ],
                ),
          ),
        ),
        if((seenPeople?.length ?? 0) != 0) Row(
          children: [
            Expanded(child: Container()),
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: InkWell(
                onTap: () {
                  num height = (seenPeople!.length > 5) ? 150 : (30*seenPeople!.length);
                  showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                      ),
                      builder: (BuildContext context) {
                        return SafeArea(
                          child: SizedBox(
                            height: height.toDouble(),
                            child: SingleChildScrollView(
                              physics: const ClampingScrollPhysics(),
                              child: Wrap(
                                children: seenPeople!.map((e) => Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      e?.picture == null ? CircleAvatar(
                                        radius: 10.0,
                                        child: Text(e?.getAvatarName() ?? ''),
                                      ) : CircleAvatar(
                                        radius: 10.0,
                                        backgroundImage:
                                        CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${e!.picture!.shieldedID}/256/${ChatConnection.brandCode!}',headers: {'brand-code':ChatConnection.brandCode!}),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      Expanded(child: Padding(
                                        padding: const EdgeInsets.only(left: 5.0),
                                        child: AutoSizeText('${e?.firstName ?? ''} ${e?.lastName ?? ''}',maxLines: 1,
                                        style: const TextStyle(fontSize: 10),),
                                      ),),
                                    ],
                                  ),
                                )).toList(),
                              ),
                            ),
                          ),
                        );
                      });
                },
                child: SizedBox(
                  height: 30.0,
                  child: Row(
                    children: seenPeopleList(),
                  ),
                ),
              ),
            )
          ],
        )
      ],
    );
  }
  List<Widget> seenPeopleList() {
    List<Widget> _arr = [];
    for (var e in seenPeople!) {
      if(e?.picture == null) {
        _arr.add(Padding(
          padding: const EdgeInsets.only(right: 1.0),
          child: CircleAvatar(
            radius: 8.0,
            child: Center(child: Text(e!.getAvatarName(),style: const TextStyle(color: Colors.white,fontSize: 6),)),
          ),
        ));
      }
      else {
        _arr.add( Padding(
          padding: const EdgeInsets.only(right: 1.0),
          child: CircleAvatar(
            radius: 8.0,
            backgroundImage:
            CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${e!.picture!.shieldedID}/256/${ChatConnection.brandCode!}',headers: {'brand-code':ChatConnection.brandCode!}),
            backgroundColor: Colors.transparent,
          ),
        ));
      }
      if(_arr.length == 3) {
        if(seenPeople!.length > _arr.length) {
          _arr.add(Text('+${seenPeople!.length-3}',style: const TextStyle(color: Colors.black,fontSize: 8),));
        }
        break;
      }
    }
    return _arr;
  }
}
