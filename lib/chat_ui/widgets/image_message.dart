import 'package:chat/chat_ui/widgets/replied_message.dart';
import 'package:chat/data_model/room.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../../connection/chat_connection.dart';
import '../../connection/http_connection.dart';
import '../conditional/conditional.dart';
import '../util.dart';
import 'inherited_chat_theme.dart';
import 'inherited_user.dart';

/// A class that represents image message widget. Supports different
/// aspect ratios, renders blurred image as a background which is visible
/// if the image is narrow, renders image in form of a file if aspect
/// ratio is very small or very big.
class ImageMessage extends StatefulWidget {
  /// Creates an image message widget based on [types.ImageMessage]
  const ImageMessage(
      {Key? key,
      required this.message,
      required this.messageWidth,
      required this.showUserNameForRepliedMessage,
      required this.onMessageTap,
      required this.people,
      this.content})
      : super(key: key);

  /// [types.ImageMessage]
  final types.ImageMessage message;

  final List<People>? people;
  final String? content;

  /// Maximum message width
  final int messageWidth;

  /// Show user name for replied message.
  final bool showUserNameForRepliedMessage;

  /// See [Message.onMessageTap]
  final void Function(
      BuildContext context, types.Message, bool isRepliedMessage)? onMessageTap;

  @override
  _ImageMessageState createState() => _ImageMessageState();
}

/// [ImageMessage] widget state
class _ImageMessageState extends State<ImageMessage> {
  ImageProvider? _image;
  ImageStream? _stream;
  Size _size = const Size(0, 0);

  @override
  void initState() {
    super.initState();
    try {
      _image = Conditional().getProvider(widget.message.uri);

      final testStream = _image?.resolve(const ImageConfiguration());
      testStream?.addListener(
        ImageStreamListener(
          (info, _) {},
          onError: (error, stack) {
            final shieldedID = extractShieldedID(widget.message.uri);
            final fallbackUrl =
                "${HTTPConnection.domain}api/images/$shieldedID/512/${ChatConnection.brandCode}";

            setState(() {
              _image = NetworkImage(fallbackUrl);
            });
          },
        ),
      );
    } catch (e) {
      final shieldedID = extractShieldedID(widget.message.uri);
      final fallbackUrl =
          "${HTTPConnection.domain}api/images/$shieldedID/512/${ChatConnection.brandCode}";

      _image = NetworkImage(fallbackUrl);
    }

    _size = Size(widget.message.width ?? 0, widget.message.height ?? 0);
  }

  String extractShieldedID(String uri) {
    final file = uri.split('/').last;
    final id = file.split('.').first;
    return id;
  }

  @override
  void didUpdateWidget(ImageMessage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.message.uri != widget.message.uri) {
      try {
        _image = Conditional().getProvider(widget.message.uri);
        _size = Size(widget.message.width ?? 0, widget.message.height ?? 0);
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        // Error handling
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_size.isEmpty) {
      _getImage();
    }
  }

  void _getImage() {
    final oldImageStream = _stream;
    _stream = _image?.resolve(createLocalImageConfiguration(context));
    if (_stream?.key == oldImageStream?.key) {
      return;
    }
    final listener = ImageStreamListener(_updateImage);
    oldImageStream?.removeListener(listener);
    _stream?.addListener(listener);
  }

  Widget _repliedMessageBuilder(types.User user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: RepliedMessage(
        messageAuthorId: widget.message.author.id,
        repliedMessage: widget.message.repliedMessage,
        showUserNames: widget.showUserNameForRepliedMessage,
        onMessageTap: widget.onMessageTap,
        people: widget.people,
      ),
    );
  }

  void _updateImage(ImageInfo info, bool _) {
    setState(() {
      _size = Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      );
    });
  }

  @override
  void dispose() {
    _stream?.removeListener(ImageStreamListener(_updateImage));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _user = InheritedUser.of(context).user;

    if (_size.aspectRatio == 0) {
      return Container(
        color: InheritedChatTheme.of(context).theme.secondaryColor,
        height: _size.height,
        width: _size.width,
      );
    } else if (_size.aspectRatio < 0.1 || _size.aspectRatio > 10) {
      return Container(
        color: _user.id == widget.message.author.id
            ? InheritedChatTheme.of(context).theme.primaryColor
            : InheritedChatTheme.of(context).theme.secondaryColor,
        child: Column(
          children: [
            if (widget.message.repliedMessage != null)
              _repliedMessageBuilder(_user),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 100,
                  margin: EdgeInsetsDirectional.fromSTEB(
                    InheritedChatTheme.of(context).theme.messageInsetsVertical,
                    InheritedChatTheme.of(context).theme.messageInsetsVertical,
                    16,
                    InheritedChatTheme.of(context).theme.messageInsetsVertical,
                  ),
                  width: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image(
                      fit: BoxFit.cover,
                      image: _image!,
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: EdgeInsetsDirectional.fromSTEB(
                      0,
                      InheritedChatTheme.of(context)
                          .theme
                          .messageInsetsVertical,
                      InheritedChatTheme.of(context)
                          .theme
                          .messageInsetsHorizontal,
                      InheritedChatTheme.of(context)
                          .theme
                          .messageInsetsVertical,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.message.name,
                          style: _user.id == widget.message.author.id
                              ? InheritedChatTheme.of(context)
                                  .theme
                                  .sentMessageBodyTextStyle
                              : InheritedChatTheme.of(context)
                                  .theme
                                  .receivedMessageBodyTextStyle,
                          textWidthBasis: TextWidthBasis.longestLine,
                        ),
                        Container(
                          margin: const EdgeInsets.only(
                            top: 4,
                          ),
                          child: Text(
                            formatBytes(widget.message.size.truncate()),
                            style: _user.id == widget.message.author.id
                                ? InheritedChatTheme.of(context)
                                    .theme
                                    .sentMessageCaptionTextStyle
                                : InheritedChatTheme.of(context)
                                    .theme
                                    .receivedMessageCaptionTextStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: _user.id == widget.message.author.id
              ? InheritedChatTheme.of(context).theme.primaryColor
              : InheritedChatTheme.of(context).theme.secondaryColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
                child: Padding(
              padding: EdgeInsets.all(widget.content != '' ? 8 : 0),
              child: Container(
                color: Colors.transparent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Text(
                        '${widget.message.author.firstName ?? ''}${widget.message.author.lastName ?? ''}',
                        style: InheritedChatTheme.of(context)
                            .theme
                            .userNameTextStyle
                            .copyWith(
                                color: getUserAvatarNameColor(
                                    widget.message.author,
                                    InheritedChatTheme.of(context)
                                        .theme
                                        .userAvatarNameColors)),
                      ),
                    ),
                    if (widget.message.repliedMessage != null)
                      _repliedMessageBuilder(_user),
                    Flexible(
                        child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image(
                        fit: BoxFit.cover,
                        image: _image!,
                      ),
                    )),
                    if (widget.content != '' &&
                        isReadableText(widget.content ?? '')) ...[
                      Text(widget.content ?? ''),
                      SizedBox(
                        height: 8,
                      )
                    ],
                  ],
                ),
              ),
            ))
          ],
        ),
      );
    }
  }

  bool isReadableText(String text) {
    if (text.trim().isEmpty) return false;

    if (RegExp(r'^[a-zA-Z0-9]{30,}$').hasMatch(text)) {
      return false;
    }
    final letters = RegExp(r'[a-zA-ZÀ-ỹ ]').allMatches(text).length;
    final ratio = letters / text.length;

    return ratio > 0.4;
  }
}
