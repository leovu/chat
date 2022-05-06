import 'dart:io';

import 'package:chat/chat_ui/widgets/inherited_replied_message.dart';
import 'package:chat/chat_ui/widgets/remove_edit_button.dart';
import 'package:chat/chat_ui/widgets/replied_message.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../models/send_button_visibility_mode.dart';
import 'attachment_button.dart';
import 'chat.dart';
import 'inherited_chat_theme.dart';
import 'send_button.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

class NewLineIntent extends Intent {
  const NewLineIntent();
}

class SendMessageIntent extends Intent {
  const SendMessageIntent();
}
typedef InputBuilder = void Function(BuildContext context, void Function({types.TextMessage? editContent}) focusTextField);
/// A class that represents bottom bar widget with a text field, attachment and
/// send buttons inside. By default hides send button when text field is empty.
class Input extends StatefulWidget {
  /// Creates [Input] widget
  const Input({
    Key? key,
    this.isAttachmentUploading,
    this.onAttachmentPressed,
    this.onCameraPressed,
    required this.onSendPressed,
    this.onTextChanged,
    this.onTextFieldTap,
    required this.sendButtonVisibilityMode,
    required this.builder,
    required this.onCancelReplyPressed,
    required this.inputBuilder,
  }) : super(key: key);

  final ChatEmojiBuilder builder;
  final InputBuilder inputBuilder;
  /// See [AttachmentButton.onPressed]
  final void Function()? onAttachmentPressed;
  final void Function()? onCameraPressed;

  /// Whether attachment is uploading. Will replace attachment button with a
  /// [CircularProgressIndicator]. Since we don't have libraries for
  /// managing media in dependencies we have no way of knowing if
  /// something is uploading so you need to set this manually.
  final bool? isAttachmentUploading;

  /// Will be called whenever the text inside [TextField] changes
  final void Function(String)? onTextChanged;

  /// Will be called on [TextField] tap
  final void Function()? onTextFieldTap;

  /// Controls the visibility behavior of the [SendButton] based on the
  /// [TextField] state inside the [Input] widget.
  /// Defaults to [SendButtonVisibilityMode.editing].
  final SendButtonVisibilityMode sendButtonVisibilityMode;


  /// Will be called on [SendButton] tap. Has [types.PartialText] which can
  /// be transformed to [types.TextMessage] and added to the messages list.
  final void Function(types.PartialText, {types.Message? repliedMessage , types.TextMessage? isEdit})
  onSendPressed;

  /// See [RepliedMessage.onCancelReplyPressed]
  final void Function() onCancelReplyPressed;

  @override
  _InputState createState() => _InputState();
}

/// [Input] widget state
class _InputState extends State<Input> {
  final _inputFocusNode = FocusNode();
  bool _sendButtonVisible = false;
  bool _emojiShowing = false;
  bool _isEdit = false;
  final _textController = TextEditingController();
  types.TextMessage? editContent;

  @override
  void initState() {
    super.initState();

    if (widget.sendButtonVisibilityMode == SendButtonVisibilityMode.editing) {
      _sendButtonVisible = _textController.text.trim() != '';
      _textController.addListener(_handleTextControllerChange);
    } else {
      _sendButtonVisible = true;
    }
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _handleNewLine() {
    final _newValue = '${_textController.text}\r\n';
    _textController.value = TextEditingValue(
      text: _newValue,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _newValue.length),
      ),
    );
  }

  void _handleSendPressed() {
    final trimmedText = _textController.text.trim();
    if (trimmedText != '') {
      final _partialText = types.PartialText(text: trimmedText);
      widget.onSendPressed(_partialText,repliedMessage: InheritedRepliedMessage.of(context)
          .repliedMessage,isEdit: editContent);
      _textController.clear();
    }
  }

  void _handleTextControllerChange() {
    setState(() {
      _sendButtonVisible = _textController.text.trim() != '';
    });
  }
  Widget _inputBuilder() {
    final _query = MediaQuery.of(context);
    final _safeAreaInsets = kIsWeb
        ? EdgeInsets.zero
        : EdgeInsets.fromLTRB(
            _query.padding.left,
            0,
            _query.padding.right,
            (_query.viewInsets.bottom + _query.padding.bottom) * 0.4,
          );
    return Focus(
      autofocus: true,
      child: Padding(
        padding: InheritedChatTheme.of(context).theme.inputMargin,
        child: Material(
          borderRadius: InheritedChatTheme.of(context).theme.inputBorderRadius,
          color: Colors.white,
          child: Container(
            decoration:
                InheritedChatTheme.of(context).theme.inputContainerDecoration,
            child: Column(
              children: [
                if (InheritedRepliedMessage.of(context).repliedMessage != null)
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: RepliedMessage(
                        onCancelReplyPressed: widget.onCancelReplyPressed,
                        repliedMessage: InheritedRepliedMessage.of(context)
                            .repliedMessage,
                        showUserNames: true,
                      )
                  ),
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20).add(_safeAreaInsets),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFFBCC5D7), width: 1.0),
                                  borderRadius:
                                  const BorderRadius.all(Radius.circular(10.0))),
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 3.0),
                                      child: SizedBox(
                                        height: 35.0,
                                        width: 35.0,
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                _emojiShowing = !_emojiShowing;
                                                if(_emojiShowing) {
                                                  _inputFocusNode.requestFocus();
                                                }
                                              });
                                            },
                                            child: Image.asset(
                                              'assets/icon-emoji.png',
                                              package: 'chat',
                                            )),
                                      ),
                                    ),
                                    Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 6.0),
                                          child: TextField(
                                            controller: _textController,
                                            cursorColor: InheritedChatTheme.of(context)
                                                .theme
                                                .inputTextCursorColor,
                                            decoration: InheritedChatTheme.of(context)
                                                .theme
                                                .inputTextDecoration
                                                .copyWith(
                                              hintStyle: InheritedChatTheme.of(context)
                                                  .theme
                                                  .inputTextStyle
                                                  .copyWith(
                                                color:
                                                Colors.black.withOpacity(0.2),
                                              ),
                                              hintText: AppLocalizations.text(LangKey.writeAMessage),
                                            ),
                                            focusNode: _inputFocusNode,
                                            keyboardType: TextInputType.multiline,
                                            maxLines: 5,
                                            minLines: 1,
                                            onChanged: widget.onTextChanged,
                                            onTap: widget.onTextFieldTap,
                                            style: InheritedChatTheme.of(context)
                                                .theme
                                                .inputTextStyle
                                                .copyWith(
                                              color: Colors.black,
                                            ),
                                            textCapitalization:
                                            TextCapitalization.sentences,
                                          ),
                                        ))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (widget.onAttachmentPressed != null &&
                              widget.onCameraPressed != null)
                            Visibility(
                              visible: !_sendButtonVisible,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10.0,bottom: 5.0),
                                child: _leftWidgetBuilder(),
                              ),
                            ),
                          Visibility(
                            visible: _isEdit,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: RemoveEditButton(
                                onPressed: (){
                                  _isEdit = false;
                                  _textController.text = '';
                                  if(!_isEdit) {
                                    editContent = null;
                                  }
                                },
                              ),
                            ),
                          ),
                          Visibility(
                            visible: _sendButtonVisible,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: SendButton(
                                onPressed: _handleSendPressed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: _emojiShowing,
                        child: SizedBox(
                          height: 200,
                          child: EmojiPicker(
                              onEmojiSelected: (Category category, Emoji emoji) {
                                _onEmojiSelected(emoji);
                              },
                              onBackspacePressed: _onBackspacePressed,
                              config: Config(
                                  columns: 7,
                                  emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                                  verticalSpacing: 0,
                                  horizontalSpacing: 0,
                                  initCategory: Category.RECENT,
                                  bgColor: Colors.white,
                                  indicatorColor: Colors.blue,
                                  iconColor: Colors.grey,
                                  iconColorSelected: Colors.blue,
                                  progressIndicatorColor: Colors.blue,
                                  backspaceColor: Colors.blue,
                                  skinToneDialogBgColor: Colors.white,
                                  skinToneIndicatorColor: Colors.grey,
                                  enableSkinTones: true,
                                  showRecentsTab: true,
                                  recentsLimit: 28,
                                  noRecentsText: 'No Recents',
                                  noRecentsStyle: const TextStyle(
                                      fontSize: 20, color: Colors.black26),
                                  tabIndicatorAnimDuration: kTabScrollDuration,
                                  categoryIcons: const CategoryIcons(),
                                  buttonMode: ButtonMode.MATERIAL)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _onEmojiSelected(Emoji emoji) {
    _textController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length));
  }

  _onBackspacePressed() {
    _textController
      ..text = _textController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length));
  }

  Widget _leftWidgetBuilder() {
    if (widget.isAttachmentUploading == true) {
      return Container(
        height: 24,
        margin: const EdgeInsets.only(right: 16),
        width: 24,
        child: const CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          strokeWidth: 1.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.black,
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 5.0),
        child: SizedBox(
          width: 50.0,
          child: Row(
            children: [
              Expanded(
                  child: AttachmentButton(
                    onPressed: widget.onCameraPressed,
                    image: 'assets/icon-camera.png',
                  )),
              Container(
                width: 10.0,
              ),
              Expanded(
                  child: AttachmentButton(
                    onPressed: widget.onAttachmentPressed,
                    image: 'assets/icon-chat-add.png',
                  ))
            ],
          ),
        ),
      );
    }
  }

  void requestFocus({types.TextMessage? editContent}) {
    if(editContent != null) {
      this.editContent = editContent;
      _textController.text = editContent.text;
      _isEdit = true;
    }
    _inputFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    widget.builder.call(hideEmoji);
    widget.inputBuilder.call(context, requestFocus);
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return GestureDetector(
      onTap: () => _inputFocusNode.requestFocus(),
      child: isAndroid || isIOS
          ? _inputBuilder()
          : Shortcuts(
              shortcuts: {
                LogicalKeySet(LogicalKeyboardKey.enter):
                    const SendMessageIntent(),
                LogicalKeySet(LogicalKeyboardKey.enter, LogicalKeyboardKey.alt):
                    const NewLineIntent(),
                LogicalKeySet(
                        LogicalKeyboardKey.enter, LogicalKeyboardKey.shift):
                    const NewLineIntent(),
              },
              child: Actions(
                actions: {
                  SendMessageIntent: CallbackAction<SendMessageIntent>(
                    onInvoke: (SendMessageIntent intent) =>
                        _handleSendPressed(),
                  ),
                  NewLineIntent: CallbackAction<NewLineIntent>(
                    onInvoke: (NewLineIntent intent) => _handleNewLine(),
                  ),
                },
                child: _inputBuilder(),
              ),
            ),
    );
  }

  void hideEmoji() {
    if(mounted) {
      setState(() {
        _emojiShowing = false;
      });
    }
  }
}
