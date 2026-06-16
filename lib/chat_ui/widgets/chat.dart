import 'dart:io';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/chat_ui/chat_l10n.dart';
import 'package:chat/chat_ui/chat_theme.dart';
import 'package:chat/chat_ui/models/date_header.dart';
import 'package:chat/chat_ui/models/emoji_enlargement_behavior.dart';
import 'package:chat/chat_ui/models/message_spacer.dart';
import 'package:chat/chat_ui/models/send_button_visibility_mode.dart';
import 'package:chat/chat_ui/util.dart';
import 'package:chat/chat_ui/widgets/inherited_replied_message.dart';
import 'package:chat/common/constant.dart';
import 'package:chat/common/theme.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/download.dart';
import 'package:chat/data_model/room.dart' as r;
import 'package:chat/data_model/room.dart';
import 'package:chat/draft.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:chat/chat_ui/widgets/inherited_l10n.dart';
import 'package:intl/intl.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:swipeable_tile/swipeable_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'chat_list.dart';
import 'inherited_chat_theme.dart';
import 'inherited_user.dart';
import 'input.dart';
import 'message.dart';
import 'package:chat/data_model/chat_message.dart' as c;

/// Entry widget, represents the complete chat. If you wrap it in [SafeArea] and
/// it should be full screen, set [SafeArea]'s `bottom` to `false`.

typedef ChatEmojiBuilder = void Function(void Function() hideEmoji);

class ChatController {
  late void Function(types.Message? message) reply;
  late void Function(types.Message? message, c.Messages? value) edit;
}

class Chat extends StatefulWidget {
  /// Creates a chat widget
  const Chat({
    Key? key,
    this.bubbleBuilder,
    this.customBottomWidget,
    this.customDateHeaderText,
    this.customMessageBuilder,
    this.dateFormat,
    this.dateHeaderThreshold = 900000,
    this.dateLocale,
    this.disableImageGallery,
    this.emojiEnlargementBehavior = EmojiEnlargementBehavior.multi,
    this.emptyState,
    this.fileMessageBuilder,
    this.groupMessagesThreshold = 60000,
    this.hideBackgroundOnEmojiMessages = true,
    this.imageMessageBuilder,
    this.isAttachmentUploading,
    this.isLastPage,
    this.l10n = const ChatL10nEn(),
    required this.messages,
    this.onAttachmentPressed,
    this.onCameraPressed,
    this.onAvatarTap,
    this.onBackgroundTap,
    this.onEndReached,
    this.onEndReachedThreshold,
    this.onMessageDoubleTap,
    this.onMessageLongPress,
    this.onMessageStatusLongPress,
    this.onMessageStatusTap,
    this.onMessageTap,
    this.onMessageVisibilityChanged,
    this.onPreviewDataFetched,
    required this.onSendPressed,
    this.onTextChanged,
    this.onTextFieldTap,
    this.scrollPhysics,
    this.sendButtonVisibilityMode = SendButtonVisibilityMode.editing,
    this.showUserAvatars = false,
    this.showUserNames = false,
    this.textMessageBuilder,
    this.theme = const DefaultChatTheme(),
    this.timeFormat,
    this.usePreviewData = true,
    required this.user,
    this.isSearchChat = false,
    required this.itemPositionsListener,
    required this.itemScrollController,
    required this.listIdMessages,
    required this.searchController,
    this.loadMore,
    required this.chatController,
    required this.progressUpdate,
    required this.builder,
    required this.people,
    required this.isGroup,
    required this.onStickerPressed,
    this.source,
    this.note,
    this.canSend = true,
    required this.roomData,
    this.avatar,
    this.onImageMessageSend,
    this.onVideoMessageSend,
    this.onFileMessageSend,
  }) : super(key: key);

  /// See [Message.bubbleBuilder]
  final Widget Function(
    Widget child, {
    required types.Message message,
    required bool nextMessageInGroup,
  })? bubbleBuilder;

  /// Allows you to replace the default Input widget e.g. if you want to create
  /// a channel view.
  final Rooms roomData;

  final bool canSend;

  final Widget? customBottomWidget;

  final bool isGroup;

  final ChatController chatController;

  final CircleAvatar? avatar;

  final InputBuilder builder;

  final Function? loadMore;
  final TextEditingController searchController;

  final String? source;

  /// If [dateFormat], [dateLocale] and/or [timeFormat] is not enough to
  /// customize date headers in your case, use rn an arbitrary
  /// string based on a [DateTime] of a particular message. Can be helpful to
  /// return "Today" if [DateTime] is today. IMPORTANT: this will replace
  /// all default date headers, so you must handle all cases yourself, like
  /// for example today, yesterday and before. Or you can just return the same
  /// date header for any message.
  final String Function(DateTime)? customDateHeaderText;

  /// See [Message.customMessageBuilder]
  final Widget Function(types.CustomMessage, {required int messageWidth})?
      customMessageBuilder;

  /// Allows you to customize the date format. IMPORTANT: only for the date,
  /// do not return time here. See [timeFormat] to customize the time format.
  /// [dateLocale] will be ignored if you use this, so if you want a localized date
  /// make sure you initialize your [DateFormat] with a locale. See [customDateHeaderText]
  /// for more customization.
  final DateFormat? dateFormat;

  final Function(double progress) progressUpdate;

  /// Time (in ms) between two messages when we will render a date header.
  /// Default value is 15 minutes, 900000 ms. When time between two messages
  /// is higher than this threshold, date header will be rendered. Also,
  /// not related to this value, date header will be rendered on every new day.
  final int dateHeaderThreshold;

  /// Locale will be passed to the `Intl` package. Make sure you initialized
  /// date formatting in your app before passing any locale here, otherwise
  /// an error will be thrown. Also see [customDateHeaderText], [dateFormat], [timeFormat].
  final String? dateLocale;

  /// Disable automatic image preview on tap.
  final bool? disableImageGallery;

  /// See [Message.emojiEnlargementBehavior]
  final EmojiEnlargementBehavior emojiEnlargementBehavior;

  /// Allows you to change what the user sees when there are no messages.
  /// `emptyChatPlaceholder` and `emptyChatPlaceholderTextStyle` are ignored
  /// in this case.
  final Widget? emptyState;

  /// See [Message.fileMessageBuilder]
  final Widget Function(types.FileMessage, {required int messageWidth})?
      fileMessageBuilder;

  /// Time (in ms) between two messages when we will visually group them.
  /// Default value is 1 minute, 60000 ms. When time between two messages
  /// is lower than this threshold, they will be visually grouped.
  final int groupMessagesThreshold;

  /// See [Message.hideBackgroundOnEmojiMessages]
  final bool hideBackgroundOnEmojiMessages;

  /// See [Message.imageMessageBuilder]
  final Widget Function(types.ImageMessage, {required int messageWidth})?
      imageMessageBuilder;

  /// See [Input.isAttachmentUploading]
  final bool? isAttachmentUploading;

  /// See [ChatList.isLastPage]
  final bool? isLastPage;

  /// Localized copy. Extend [ChatL10n] class to create your own copy or use
  /// existing one, like the default [ChatL10nEn]. You can customize only
  /// certain properties, see more here [ChatL10nEn].
  final ChatL10n l10n;

  /// List of [types.Message] to render in the chat widget
  final List<types.Message> messages;

  final List<r.People>? people;

  /// See [Input.onAttachmentPressed]
  final void Function()? onAttachmentPressed;

  /// See [Input.onAttachmentPressed]
  final void Function()? onCameraPressed;

  /// See [Message.onAvatarTap]
  final void Function(types.User)? onAvatarTap;

  /// Called when user taps on background
  final void Function()? onBackgroundTap;

  /// See [ChatList.onEndReached]
  final Future<void> Function()? onEndReached;

  /// See [ChatList.onEndReachedThreshold]
  final double? onEndReachedThreshold;

  /// See [Message.onMessageDoubleTap]
  final void Function(BuildContext context, types.Message)? onMessageDoubleTap;

  /// See [Message.onMessageLongPress]
  final void Function(BuildContext context, types.Message)? onMessageLongPress;

  /// See [Message.onMessageStatusLongPress]
  final void Function(BuildContext context, types.Message)?
      onMessageStatusLongPress;

  /// See [Message.onMessageStatusTap]
  final void Function(BuildContext context, types.Message)? onMessageStatusTap;

  /// See [Message.onMessageTap]
  final void Function(
      BuildContext context, types.Message, bool isRepliedMessage)? onMessageTap;

  /// See [Message.onMessageVisibilityChanged]
  final void Function(types.Message, bool visible)? onMessageVisibilityChanged;

  /// See [Message.onPreviewDataFetched]
  final void Function(types.TextMessage, types.PreviewData)?
      onPreviewDataFetched;

  /// See [Input.onSendPressed]
  final void Function(types.PartialText,
      {types.Message? repliedMessage, types.TextMessage? isEdit}) onSendPressed;

  /// See [Input.onTextChanged]
  final void Function(String)? onTextChanged;

  /// See [Input.onTextFieldTap]
  final void Function()? onTextFieldTap;

  /// See [ChatList.scrollPhysics]
  final ScrollPhysics? scrollPhysics;
  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;

  /// See [Input.sendButtonVisibilityMode]
  final SendButtonVisibilityMode sendButtonVisibilityMode;

  /// See [Message.showUserAvatars]
  final bool showUserAvatars;
  final Map<String, int> listIdMessages;

  /// Show user names for received messages. Useful for a group chat. Will be
  /// shown only on text messages.
  final bool showUserNames;

  final void Function(File sticker) onStickerPressed;

  /// Callbacks for sending media messages
  final void Function(List<XFile> images)? onImageMessageSend;
  final void Function(XFile video)? onVideoMessageSend;
  final void Function(PlatformFile file)? onFileMessageSend;

  /// See [Message.textMessageBuilder]
  final Widget Function(
    types.TextMessage, {
    required int messageWidth,
    required bool showName,
  })? textMessageBuilder;

  /// Chat theme. Extend [ChatTheme] class to create your own theme or use
  /// existing one, like the [DefaultChatTheme]. You can customize only certain
  /// properties, see more here [DefaultChatTheme].
  final ChatTheme theme;

  /// Allows you to customize the time format. IMPORTANT: only for the time,
  /// do not return date here. See [dateFormat] to customize the date format.
  /// [dateLocale] will be ignored if you use this, so if you want a localized time
  /// make sure you initialize your [DateFormat] with a locale. See [customDateHeaderText]
  /// for more customization.
  final DateFormat? timeFormat;

  /// See [Message.usePreviewData]
  final bool usePreviewData;

  /// See [InheritedUser.user]
  final types.User user;

  final bool isSearchChat;

  final String? note;

  @override
  _ChatState createState() => _ChatState();
}

/// [Chat] widget state
class _ChatState extends State<Chat> {
  List<Object> _chatMessages = [];
  void Function() hideEmoji = () {};
  types.Message? _repliedMessage;
  Function({types.TextMessage? editContent}) requestFocusTextField =
      ({types.TextMessage? editContent}) {};

  // File preview states
  List<XFile> _selectedImages = [];
  XFile? _selectedVideo;
  PlatformFile? _selectedFile;

  void reply(types.Message? message) {
    setState(() {
      _repliedMessage = message?.copyWith();
    });
  }

  void edit(types.Message? message, c.Messages? value) {
    requestFocusTextField(editContent: (message as types.TextMessage));
  }

  // File selection handlers
  void _handleImageSelection(List<XFile> images) {
    setState(() {
      _selectedImages.addAll(images);
    });
  }

  void _handleVideoSelection(XFile video) {
    setState(() {
      _selectedVideo = video;
    });
  }

  void _handleFileSelection(PlatformFile file) {
    setState(() {
      _selectedFile = file;
    });
  }

  // File removal handlers
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeVideo() {
    setState(() {
      _selectedVideo = null;
    });
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  void _clearAllFiles() {
    setState(() {
      _selectedImages.clear();
      _selectedVideo = null;
      _selectedFile = null;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.chatController.reply = reply;
    widget.chatController.edit = edit;

    getDraft();
    didUpdateWidget(widget);
  }

  void getDraft() async {
    Map<String, dynamic>? value =
        await getDraftInput(ChatConnection.roomId ?? '');
    if (value != null) {
      if (value.containsKey('reply')) {
        types.Message message = types.Message.fromJson(value['reply']);
        reply(message);
      }
    }
  }

  @override
  void didUpdateWidget(covariant Chat oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.messages.isNotEmpty) {
      final result = calculateChatMessages(widget.messages, widget.user,
          customDateHeaderText: widget.customDateHeaderText,
          dateFormat: widget.dateFormat,
          dateHeaderThreshold: widget.dateHeaderThreshold,
          dateLocale: widget.dateLocale,
          groupMessagesThreshold: widget.groupMessagesThreshold,
          showUserNames: widget.showUserNames,
          timeFormat: widget.timeFormat);
      _chatMessages = result[0] as List<Object>;
      for (var i = 0; i < _chatMessages.length; i++) {
        if (_chatMessages[i] is DateHeader) {
        } else if (_chatMessages[i] is MessageSpacer) {
        } else {
          final map = _chatMessages[i] as Map<String, Object>;
          final message = map['message']! as types.Message;
          widget.listIdMessages[message.id] = i;
        }
      }
    }
  }

  Widget _emptyStateBuilder() {
    return widget.emptyState ??
        Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.symmetric(
            horizontal: 24,
          ),
          child: Text(
            widget.l10n.emptyChatPlaceholder,
            style: widget.theme.emptyChatPlaceholderTextStyle,
            textAlign: TextAlign.center,
          ),
        );
  }

  Future showLoading() async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              Center(
                child: Platform.isAndroid
                    ? const CircularProgressIndicator()
                    : const CupertinoActivityIndicator(),
              )
            ],
          );
        });
  }

  Widget _messageBuilder(Object object, BoxConstraints constraints) {
    if (object is DateHeader) {
      return Container(
        alignment: Alignment.center,
        margin: widget.theme.dateDividerMargin,
        child: Text(
          object.text,
          style: widget.theme.dateDividerTextStyle,
        ),
      );
    } else if (object is MessageSpacer) {
      return SizedBox(
        height: object.height,
      );
    } else {
      final map = object as Map<String, Object>;
      final message = map['message']! as types.Message;
      final _messageWidth =
          widget.showUserAvatars && message.author.id != widget.user.id
              ? min(constraints.maxWidth * 0.6, 440).floor()
              : min(constraints.maxWidth * 0.6, 440).floor();
      final metadata = message.metadata;
      List<c.Author?>? seenPeople;
      if (metadata != null) {
        List<Map<String, dynamic>>? list = metadata['messageSeen'];
        if (list != null) {
          List<c.MessageSeen> messageSeen =
              list.map((e) => c.MessageSeen.fromJson(e)).toList();
          seenPeople = [];
          for (var e in messageSeen) {
            if (e.message == message.id) {
              if (e.author?.sId != ChatConnection.user?.id) {
                seenPeople.add(e.author);
              }
            }
          }
        }
      }
      return Message(
        key: ValueKey(message.id),
        content: message.metadata?['content'],
        bubbleBuilder: widget.bubbleBuilder,
        searchController: widget.searchController,
        customMessageBuilder: widget.customMessageBuilder,
        emojiEnlargementBehavior: widget.emojiEnlargementBehavior,
        fileMessageBuilder: widget.fileMessageBuilder,
        hideBackgroundOnEmojiMessages: widget.hideBackgroundOnEmojiMessages,
        imageMessageBuilder: widget.imageMessageBuilder,
        message: message,
        circleAvatar: widget.avatar,
        messageWidth: _messageWidth,
        seenPeople: seenPeople,
        onAvatarTap: widget.onAvatarTap,
        onMessageDoubleTap: widget.onMessageDoubleTap,
        onMessageLongPress: widget.onMessageLongPress,
        onMessageStatusLongPress: widget.onMessageStatusLongPress,
        onMessageStatusTap: widget.onMessageStatusTap,
        people: widget.people,
        onMessageTap: (context, tappedMessage, isRepliedMessage) {
          if (tappedMessage is types.ImageMessage &&
              widget.disableImageGallery != true &&
              !isRepliedMessage) {
            _onImagePressed(tappedMessage);
          }
          widget.onMessageTap?.call(context, tappedMessage, isRepliedMessage);
        },
        onMessageVisibilityChanged: widget.onMessageVisibilityChanged,
        onPreviewDataFetched: _onPreviewDataFetched,
        roundBorder: map['isFirstInGroup'] == true,
        showAvatar: map['isFirstInGroup'] == true,
        showName: map['showName'] == true,
        showStatus: map['showStatus'] == true,
        showUserAvatars: widget.showUserAvatars,
        textMessageBuilder: widget.textMessageBuilder,
        usePreviewData: widget.usePreviewData,
        replySwipeDirection: message.author.id != widget.user.id
            ? SwipeDirection.startToEnd
            : SwipeDirection.endToStart,
        onMessageReply: _onMessageReply,
        focusSearch: requestFocusTextField,
      );
    }
  }

  void _onMessageReply(BuildContext context, types.Message? message) {
    setState(() {
      _repliedMessage = message?.copyWith();
    });
  }

  void _onImagePressed(types.ImageMessage message) async {
    openImage(context, message.uri);
  }

  void _onPreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    widget.onPreviewDataFetched?.call(message, previewData);
  }

  void _onSendPressed(types.PartialText message,
      {types.Message? repliedMessage, types.TextMessage? isEdit}) {
    setState(() {
      _repliedMessage = null;
    });

    if (message.text.trim().isNotEmpty) {
      widget.onSendPressed(message,
          repliedMessage: repliedMessage, isEdit: isEdit);
    }

    if (_selectedImages.isNotEmpty && widget.onImageMessageSend != null) {
      widget.onImageMessageSend!(_selectedImages);
    }

    if (_selectedVideo != null && widget.onVideoMessageSend != null) {
      widget.onVideoMessageSend!(_selectedVideo!);
    }

    if (_selectedFile != null && widget.onFileMessageSend != null) {
      widget.onFileMessageSend!(_selectedFile!);
    }

    _clearAllFiles();
  }

  void _onStickerPressed(File sticker) {
    widget.onStickerPressed(sticker);
  }

  void _onCancelReplyPressed() {
    setState(() {
      _repliedMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return InheritedUser(
      user: widget.user,
      child: InheritedRepliedMessage(
        repliedMessage: _repliedMessage,
        child: InheritedChatTheme(
          theme: widget.theme,
          child: InheritedL10n(
            l10n: widget.l10n,
            child: Stack(
              children: [
                Container(
                  color: widget.theme.backgroundColor,
                  child: Column(
                    children: [
                      !widget.canSend ? bannerCantSendOA() : Container(),
                      Flexible(
                        child: widget.messages.isEmpty
                            ? SizedBox.expand(
                                child: _emptyStateBuilder(),
                              )
                            : GestureDetector(
                                onTap: () {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  hideEmoji.call();
                                  widget.onBackgroundTap?.call();
                                },
                                child: LayoutBuilder(
                                  builder: (BuildContext context,
                                          BoxConstraints constraints) =>
                                      ChatList(
                                    isLastPage: widget.isLastPage,
                                    itemBuilder: (item, index) =>
                                        _messageBuilder(item, constraints),
                                    items: _chatMessages,
                                    onEndReached: widget.onEndReached,
                                    onEndReachedThreshold:
                                        widget.onEndReachedThreshold,
                                    scrollPhysics: widget.scrollPhysics,
                                    itemScrollController:
                                        widget.itemScrollController,
                                    itemPositionsListener:
                                        widget.itemPositionsListener,
                                    loadMore: widget.loadMore,
                                    progressUpdate: widget.progressUpdate,
                                  ),
                                ),
                              ),
                      ),
                      if (widget.note != null)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 5.0, right: 5.0, bottom: 8.0),
                          child: AutoSizeText(
                            widget.note!,
                            style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      !widget.isSearchChat
                          ? Column(
                              children: [
                                _buildFilePreview(),
                                widget.customBottomWidget ??
                                    checkSourceAvailableChat(),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Build file preview widget
  Widget _buildFilePreview() {
    if (_selectedImages.isEmpty &&
        _selectedVideo == null &&
        _selectedFile == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Selected Files',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _clearAllFiles,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Clear All',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Images preview
                ..._selectedImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final image = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(image.path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),

                // Video preview
                if (_selectedVideo != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Show video preview dialog
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.black,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Video player would go here
                                    // For now, show file info
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          const Icon(
                                            Icons.play_circle_outline,
                                            color: Colors.white,
                                            size: 64,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            _selectedVideo!.name,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Video ready to send',
                                            style: TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text(
                                        'Close',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.videocam,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Video',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: _removeVideo,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // File preview
                if (_selectedFile != null)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF9C27B0).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF9C27B0),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.insert_drive_file,
                                color: Color(0xFF9C27B0),
                                size: 32,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedFile!.name.length > 10
                                    ? '${_selectedFile!.name.substring(0, 10)}...'
                                    : _selectedFile!.name,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF9C27B0),
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: _removeFile,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget bannerCantSendOA() {
    return Container(
      padding: const EdgeInsets.all(10.0),
      width: MediaQuery.of(context).size.width,
      color: AppColors.orange1.withValues(alpha: 0.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 10.0),
            height: 20.0,
            width: 20.0,
            child: Icon(
              Icons.warning_amber,
              color: AppColors.orange1,
            ),
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.text(LangKey.banner_cant_send_OA)),
              InkWell(
                onTap: () => launchUrl(Uri.parse(httpPolicyOA)),
                child: Text(
                  AppLocalizations.text(LangKey.watch_detail),
                  style: TextStyle(color: AppColors.orange1),
                ),
              )
            ],
          ))
        ],
      ),
    );
  }

  Widget checkSourceAvailableChat() {
    bool isVisible = true;
    if (ChatConnection.isChatHub) {
      // TODO: Hide Facebook 1 day not replied
      // try {
      //   List<types.Message> customerMessage = widget.messages.where((e) => e.author.id != ChatConnection.user!.id).toList();
      //   var date = DateTime.fromMillisecondsSinceEpoch(customerMessage.first.createdAt??0);
      //   final difference = DateTime.now().difference(date).inDays;
      //   if(widget.source == 'facebook' && difference >= 1) {
      //     isVisible = false;
      //   }
      // }catch(_) {}
    }
    return Input(
      canSend: widget.canSend,
      isGroup: widget.isGroup,
      isVisible: isVisible,
      isAttachmentUploading: widget.isAttachmentUploading,
      onAttachmentPressed: widget.onAttachmentPressed,
      onCameraPressed: widget.onCameraPressed,
      onTextChanged: widget.onTextChanged,
      onTextFieldTap: widget.onTextFieldTap,
      people: widget.people,
      sendButtonVisibilityMode: widget.sendButtonVisibilityMode,
      onCancelReplyPressed: _onCancelReplyPressed,
      onSendPressed: _onSendPressed,
      onStickerPressed: _onStickerPressed,
      onFileSelected: _handleFileSelection,
      onVideoSelected: _handleVideoSelection,
      onImageSelected: _handleImageSelection,
      hasSelectedFiles: _selectedImages.isNotEmpty ||
          _selectedVideo != null ||
          _selectedFile != null,
      inputBuilder: (BuildContext context,
          void Function({types.TextMessage? editContent}) method) {
        requestFocusTextField = method;
      },
      repliedMessage: _repliedMessage,
      onMessageTap: widget.onMessageTap,
      builder: (void Function() method) {
        hideEmoji = method;
      },
      roomData: widget.roomData,
    );
  }
}
