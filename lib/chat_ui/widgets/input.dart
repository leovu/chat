import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_ui/models/send_button_visibility_mode.dart';
import 'package:chat/chat_ui/widgets/sticker.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/room.dart';
import 'package:chat/draft.dart';
import 'package:rich_text_controller/rich_text_controller.dart';
import 'package:chat/chat_ui/widgets/inherited_replied_message.dart';
import 'package:chat/chat_ui/widgets/remove_edit_button.dart';
import 'package:chat/chat_ui/widgets/replied_message.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
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
    this.repliedMessage,
    required this.sendButtonVisibilityMode,
    required this.builder,
    required this.onCancelReplyPressed,
    required this.inputBuilder,
    required this.people,
    required this.isGroup,
    required this.onStickerPressed,
    required this.onMessageTap,
  }) : super(key: key);

  final ChatEmojiBuilder builder;
  final InputBuilder inputBuilder;
  /// See [AttachmentButton.onPressed]
  final void Function()? onAttachmentPressed;
  final void Function()? onCameraPressed;

  final types.Message? repliedMessage;

  /// See [Message.onMessageTap]
  final void Function(BuildContext context, types.Message, bool isRepliedMessage)? onMessageTap;

  final bool isGroup;
  final List<People>? people;

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

  final void Function(File sticker)
  onStickerPressed;

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
  late RichTextController _textController;
  types.TextMessage? editContent;
  List<People>? _taggingSuggestList;
  List<String> _idTagList = [];

  @override
  void initState() {
    super.initState();
    String regex = '';
    if(widget.people != null) {
      regex = "r'@\b|";
      for (var e in widget.people!) {
        if(e.sId != ChatConnection.user!.id) {
          String val = '@${e.firstName}${e.lastName}'.trim();
          regex += '$val|';
        }
      }
      regex += '@${AppLocalizations.text(LangKey.all)}|';
      regex += "r'+\b'";
    }
    getDraft();
    _textController = RichTextController(
      patternMatchMap: {
        RegExp(regex): TextStyle(color: Colors.blueAccent,backgroundColor: Colors.grey[200]),
      },
      onMatch: (List<String> match) {},
    );
    _idTagList = [];
    if (widget.sendButtonVisibilityMode == SendButtonVisibilityMode.editing) {
      _sendButtonVisible = _textController.text.trim() != '';
      _textController.addListener(_handleTextControllerChange);
    } else {
      _sendButtonVisible = true;
    }
  }

  void getDraft() async {
    Map<String,dynamic>? value = await getDraftInput(ChatConnection.roomId!);
    if(value != null) {
      if(value.containsKey('text')) {
        setState(() {
          _textController.text = checkTag(value['text']);
        });
      }
      if(value.containsKey('tag_list')) {
        _idTagList = List<String>.from(value['tag_list']);
      }
    }
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _textController.dispose();
    Map<String,dynamic> value = {};
    if(_textController.value.text != '') {
      value['text'] = _textController.value.text;
    }
    if(_idTagList.isNotEmpty) {
      value['tag_list'] = _idTagList;
    }
    if(widget.repliedMessage != null) {
      value['reply'] = widget.repliedMessage!.toJson();
    }
    if(value.isNotEmpty) {
      saveDraftInput(value, ChatConnection.roomId!);
    }
    else {
      deleteDraftInput(ChatConnection.roomId!);
    }
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
    _isEdit = false;
    var trimmedText = _textController.text.trim();
    trimmedText = trimmedText.replaceAll('@${AppLocalizations.text(LangKey.all)}', '@all-all@');
    if(widget.people != null) {
      if(_idTagList.isNotEmpty) {
        for(var e in _idTagList) {
          try {
            People p = widget.people!.firstWhere((element) => element.sId == e);
            trimmedText = trimmedText.replaceAll('@${p.firstName}${p.lastName}', '@${p.firstName}${p.lastName}-${p.sId}@');
          }catch(_) {}
        }
      }
      _idTagList = [];
    }
    if (trimmedText != '') {
      final _partialText = types.PartialText(text: trimmedText);
      widget.onSendPressed(_partialText,repliedMessage: InheritedRepliedMessage.of(context)
          .repliedMessage,isEdit: editContent);
      _textController.clear();
    }
    setState(() {
      _taggingSuggestList = null;
    });
    deleteDraftInput(ChatConnection.roomId!);
  }

  void _handleTextControllerChange() {
    setState(() {
      _sendButtonVisible = _textController.text.trim() != '';
      if(!_sendButtonVisible) {
        _idTagList = [];
      }
    });
  }

  void onChanged(String value) {
    List<String> contents = [];
    if(value.contains('@${AppLocalizations.text(LangKey.all)}')) {
      value.replaceAll('@${AppLocalizations.text(LangKey.all)}', '@all-all@');
    }
    if(value.contains('@')) {
      if(value[value.length-1] == "@") {
        contents.add('');
      }
      else {
        final selection = _textController.value.selection;
        final text = _textController.value.text;
        if(text == selection.textBefore(text)) {
          if(text[text.length-1] == "@") {
            contents.add('');
          }
          else {
            List<String> splits = text.split(' ');
            if(splits.last.contains('@')) {
              contents.add(splits.last.substring(1));
            }
          }
        }
        else {
          final before = selection.textBefore(text);
          if(before.contains('@')) {
            contents = before.split('@');
          }
        }
      }
    }
    if(contents.isNotEmpty) {
      try {
        for (var e in contents) {
          detectTagInTextField(e);
        }
      }catch(_) {
        setState(() {
          _taggingSuggestList = null;
        });
      }
    }
    else {
      setState(() {
        _taggingSuggestList = null;
      });
    }
  }
  detectTagInTextField(String data) {
    List<People> tmp = [];
    for (var e in widget.people!) {
      if('${e.firstName}${e.lastName}'.toLowerCase().contains(data.toLowerCase()) && e.sId != ChatConnection.user!.id) {
        if('${e.firstName}${e.lastName}'.toLowerCase() != data.toLowerCase()) {
          tmp.add(e);
        }
      }
    }
    if(tmp.isNotEmpty) {
      _taggingSuggestList = tmp;
      setState(() {});
    }
    else {
      if(data == '') {
        _taggingSuggestList = [];
        for (var e in widget.people!) {
          if(e.sId != ChatConnection.user!.id) {
            _taggingSuggestList!.add(e);
          }
        }
      }
      setState(() {});
    }
  }
  int emojiIndex = 0;
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
                Visibility(
                    visible: _taggingSuggestList != null,
                    child: _taggingSuggestList != null ? Wrap(
                      children: _arrayTaggingSuggestionList(_taggingSuggestList!.length == widget.people!.length-1 && widget.isGroup),
                    ) : Container()),
                if (InheritedRepliedMessage.of(context).repliedMessage != null)
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: RepliedMessage(
                        onCancelReplyPressed: widget.onCancelReplyPressed,
                        repliedMessage: InheritedRepliedMessage.of(context)
                            .repliedMessage,
                        showUserNames: true,
                        onMessageTap: widget.onMessageTap,
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
                                                emojiIndex = 0;
                                                // if(_emojiShowing) {
                                                //   _inputFocusNode.requestFocus();
                                                // }
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
                                            onChanged: (value) {
                                              onChanged(value);
                                            },
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
                          height: 250,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 50.0,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10.0),
                                      child: InkWell(
                                          child: Chip(
                                            labelPadding: const EdgeInsets.all(2.0),
                                            label: AutoSizeText(
                                              'Emotion Icon',
                                              style: TextStyle(
                                                color:  emojiIndex == 0 ? Colors.white : Colors.black,
                                              ),
                                            ),
                                            backgroundColor: emojiIndex == 0 ? Colors.blue : const Color(0xFFE5E5E5),
                                            elevation: 6.0,
                                            shadowColor: Colors.grey[60],
                                            padding: const EdgeInsets.all(8.0),
                                          ),
                                        onTap: () {
                                          setState(() {
                                            emojiIndex = 0;
                                          });
                                        }
                                      ),
                                    ),
                                    InkWell(
                                        child: Chip(
                                          labelPadding: const EdgeInsets.all(2.0),
                                          label: AutoSizeText(
                                            'Sticker',
                                            style: TextStyle(
                                              color:  emojiIndex == 1 ? Colors.white : Colors.black,
                                            ),
                                          ),
                                          backgroundColor: emojiIndex == 1 ? Colors.blue : const Color(0xFFE5E5E5),
                                          elevation: 6.0,
                                          shadowColor: Colors.grey[60],
                                          padding: const EdgeInsets.all(8.0),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            emojiIndex = 1;
                                          });
                                        }
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child:
                                emojiIndex == 0 ?
                                  EmojiPicker(
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
                                      noRecents: const Text(
                                        'No Recents',
                                        style: TextStyle(fontSize: 20, color: Colors.black26),
                                        textAlign: TextAlign.center,
                                      ),
                                      tabIndicatorAnimDuration: kTabScrollDuration,
                                      categoryIcons: const CategoryIcons(),
                                      buttonMode: ButtonMode.MATERIAL))
                                :
                                Column(
                                  children: [
                                    Expanded(child: GridView(
                                      scrollDirection: Axis.horizontal,
                                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                          maxCrossAxisExtent: 160,
                                          childAspectRatio: 2.25 / 2,
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 5
                                      ),
                                      children: stickers() ,
                                    )),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: SizedBox(height: 20.0,child: Row(
                                        children: [
                                          stickerSelection("assets/icon-cat.png",1),
                                          stickerSelection("assets/icon-rabbit.png",2),
                                          stickerSelection("assets/icon-panda.png",3),
                                        ],
                                      ),),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                      )),
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
  Widget stickerSelection(String icon, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        child:
        ImageIcon(AssetImage(icon,package: 'chat'),
          color: emojiIndex == index ? Colors.blue : Colors.grey.shade400,),
        onTap: () {
          setState(() {
            emojiIndex = index;
          });},
      ),
    );
  }
  List<Widget> stickers() {
    if(emojiIndex == 1) {
      return Stickers.mimiCatStickers(widget.onStickerPressed);
    }
    else if(emojiIndex == 2) {
      return Stickers.usagyuunStickers(widget.onStickerPressed);
    }
    else if(emojiIndex == 3) {
      return Stickers.pandaStickers(widget.onStickerPressed);
    }
    else {
      return [Container()];
    }
  }

  List<Widget> _arrayTaggingSuggestionList(bool isAll) {
    List<Widget> _arr = [];
    if(isAll) {
      _arr.add(Padding(
        padding: const EdgeInsets.only(left: 8.0,right: 8.0,bottom: 8.0),
        child: InkWell(
          onTap: (){
            String val = replaceTagInTextField(null, _textController.value.text);
            setState(() {
              _textController.text = val;
              _textController.selection = TextSelection.fromPosition(TextPosition(offset: _textController.text.length));
              _taggingSuggestList = null;
            });
          },
          child: Row(
            children: [
              const Icon(Icons.group,color: Colors.grey,),
              Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: AutoSizeText(AppLocalizations.text(LangKey.all),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ))
            ],
          ),
        ),
      ));
    }
    for (var e in _taggingSuggestList!) {
      _arr.add(Padding(
        padding: const EdgeInsets.only(left: 8.0,right: 8.0,bottom: 8.0),
        child: InkWell(
          onTap: () {
            if(!_idTagList.contains(e.sId!)) {
              _idTagList.add(e.sId!);
            }
            String val = replaceTagInTextField(e, _textController.value.text);
            setState(() {
              _textController.text = val;
              _textController.selection = TextSelection.fromPosition(TextPosition(offset: _textController.text.length));
              _taggingSuggestList = null;
            });
          },
          child: Row(
            children: [
              e.picture == null ? CircleAvatar(
                radius: 12.0,
                child: AutoSizeText(
                  e.getAvatarName(),
                  style: const TextStyle(color: Colors.white,fontSize: 8),),
              ) : CircleAvatar(
                radius: 12.0,
                backgroundImage:
                CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${e.picture!.shieldedID}/256'),
                backgroundColor: Colors.transparent,
              ),
              Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: AutoSizeText('${e.firstName}${e.lastName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              ))
            ],
          ),
        ),
      ));
      if(_arr.length == 5) {
        break;
      }
    }
    if(_arr.isNotEmpty) {
      _arr.insert(0, Padding(
          padding: const EdgeInsets.only(bottom: 5.0),child: Container(height: 1.0,color: Colors.grey.shade200,)));
    }
    return _arr;
  }

  String replaceTagInTextField(People? p, String value) {
    String result = value;
    List<String> contents = [];
    final selection = _textController.value.selection;
    final text = _textController.value.text;
    if(text == selection.textBefore(text)) {
      if(text[text.length-1] == "@") {
        if(p == null) {
          result += AppLocalizations.text(LangKey.all);
        }
        else {
          result += '${p.firstName}${p.lastName}';
        }
      }
      else {
        List<String> splits = text.split(' ');
        result = result.replaceFirst(splits.last, '@${p!.firstName}${p.lastName}');
      }
    }
    else {
      final before = selection.textBefore(text);
      contents = before.split('@');
      if(contents.last != '') {
        result = result.replaceFirst(contents.last, '${p!.firstName}${p.lastName}');
      }
      else {
        result = result.replaceFirst(before, '$before${p!.firstName}${p.lastName}');
      }
    }
    return result;
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
      _textController.text = checkTag(editContent.text);
      for (var e in widget.people!) {
        if(editContent.text.contains('@${e.firstName}${e.lastName}-${e.sId}')) {
          if(!_idTagList.contains(e.sId)) {
            _idTagList.add(e.sId!);
          }
        }
      }
      _isEdit = true;
    }
    _inputFocusNode.requestFocus();
  }


  String checkTag(String message) {
    List<String> contents = message.split(' ');
    String result = '';
    for (int i = 0; i < contents.length; i++) {
      var element = contents[i];
      if(element == '@all-all@') {
        element = '@${AppLocalizations.text(LangKey.all)}';
      }
      try {
        if(element[element.length-1] == '@' && element.contains('-')) {
          element = element.split('-').first;
        }
      }catch(_) {}
      result += '$element ';
    }
    return result.trim();
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
