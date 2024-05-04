import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_ui/models/send_button_visibility_mode.dart';
import 'package:chat/chat_ui/widgets/sticker.dart';
import 'package:chat/common/custom_navigator.dart';
import 'package:chat/common/theme.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/room.dart';
import 'package:chat/draft.dart';
import 'package:chat/localization/check_tag.dart';
import 'package:chat/presentation/chat_module/bloc/chat_bloc.dart';
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
    required this.canSend,
    required this.sendButtonVisibilityMode,
    required this.builder,
    required this.onCancelReplyPressed,
    required this.inputBuilder,
    required this.people,
    required this.isGroup,
    required this.onStickerPressed,
    required this.onMessageTap,
    required this.isVisible,
    required this.roomData
  }) : super(key: key);

  final Rooms roomData;
  final bool canSend;
  final ChatEmojiBuilder builder;
  final InputBuilder inputBuilder;
  /// See [AttachmentButton.onPressed]
  final void Function()? onAttachmentPressed;
  final void Function()? onCameraPressed;

  final types.Message? repliedMessage;

  final bool isVisible;

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
  late ChatBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ChatBloc();
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
          _textController.text = checkTag(value['text'],widget.people);
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
      try{
        saveDraftInput(value, ChatConnection.roomId!);
      }catch(_) {}
    }
    else {
      try{
        deleteDraftInput(ChatConnection.roomId!);
      }catch(_) {}
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
    List<String> tagListDetect = detectTag(value, widget.people);
    for (var e in tagListDetect) {
      if(!_idTagList.contains(e)) {
        _idTagList.add(e);
      }
    }
    //TODO: Check cursor to show tag list
    var cursorPos = _textController.selection.base.offset;
    int? index;
    String textBeforeCursor = _textController.text.substring(0, cursorPos);
    for(int i=textBeforeCursor.length-1;i>=0;i--) {
      if(textBeforeCursor[i] == ' ' || textBeforeCursor[i] == '\n' ) {
        break;
      }
      if(textBeforeCursor[i] == '@') {
        index = i;
      }
    }
    if(index!=null) {
      //TODO: Null string
      if(_textController.text == '') {
        setState(() {
          _taggingSuggestList = null;
        });
      }
      else {
        //TODO: Has Tag
        String tagString;
        try {
          tagString = textBeforeCursor.substring(index+1,textBeforeCursor.length);
        }catch(_) {
          tagString = '';
        }
        detectTagInTextField(tagString);
      }
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
    return widget.canSend ? Focus(
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
                        people: widget.people,
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
                                  onEmojiSelected: (Category? category, Emoji? emoji) {
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
                                      backspaceColor: Colors.blue,
                                      skinToneDialogBgColor: Colors.white,
                                      skinToneIndicatorColor: Colors.grey,
                                      enableSkinTones: true,
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
    ) :  sendInteractionMessage();
  }

  popUpSendInteractionMessage(BuildContext buildContext){
    return showDialog(context: buildContext, builder: (buildContext) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5.0))),
        content: Container(
            decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: new BorderRadius.all(Radius.circular(5))),
            height: 210,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 27),
            child: Row(
              children: [
                messageItem('rating'),
                Container(width: 10.0,),
                messageItem('promotion'),
              ],
            )),
      );
    });
  }

  Widget messageItem(String type){
    return Expanded(child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: AppColors.grayBackGround
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Text(
              type == "rating" ? AppLocalizations.text(LangKey.rating_message) : AppLocalizations.text(LangKey.promotion_message),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 1.0,
            color: AppColors.white,
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.0),
            width: MediaQuery.of(context).size.width,
            child: Text(
              AppLocalizations.text(LangKey.example_message),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.0),
            ),
          ),
          Expanded(child: Container()),
          // Container(
          //   child: Image.asset(type == "rating" ? 'Assets/image_rating_message.png' : 'Assets/image_promotion_message/png'),
          // ),
          InkWell(
            onTap: (){
              CustomNavigator.showCustomAlertDialog(context, null,
                  AppLocalizations.text(LangKey.charge_message),
                  titleHeader:
                  AppLocalizations.text(LangKey.warning),
                  enableCancel: true,
                  textSubSubmitted:
                  AppLocalizations.text(LangKey.cancel),
                  textSubmitted: AppLocalizations.text(LangKey.confirm),
                  onSubmitted: () async {
                    CustomNavigator.pop(context);
                    CustomNavigator.pop(context);
                   await _bloc.sendTransaction(widget.roomData.channel!.socialChanelId!, type, widget.roomData.owner!.userSocialId!);
                    _bloc.messageSystem(widget.roomData.owner!.sId!, widget.roomData.sId!);
                  });
            },
            child: Center(
              child: Container(
                margin: EdgeInsets.only(bottom: 5.0),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(6.0)
                ),
                child: Text(
                  AppLocalizations.text(LangKey.send_message_2),
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ),
          )
        ],
      ),
    ));
  }

  Widget sendInteractionMessage(){
    return InkWell(
      onTap: ()=> popUpSendInteractionMessage(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.0),
        height: 40.0,
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(10.0)
        ),
        child: Center(
          child: Text(
            AppLocalizations.text(LangKey.interaction_message),
            style: AppTextStyles.style15WhiteNormal,
            textAlign: TextAlign.center,
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
            int val = replaceTagInTextField(null, _textController.value.text);
            setState(() {
              _textController.selection = TextSelection.fromPosition(TextPosition(offset: val));
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
            int val = replaceTagInTextField(e, _textController.value.text);
            setState(() {
              _textController.selection = TextSelection.fromPosition(TextPosition(offset: val));
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
                CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${e.picture!.shieldedID}/256/${ChatConnection.brandCode!}',headers: {'brand-code':ChatConnection.brandCode!}),
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

  int replaceTagInTextField(People? p, String value) {
    var cursorPos = _textController.selection.base.offset;
    String textBeforeCursor = _textController.text.substring(0, cursorPos);
    String textAfterCursor =  _textController.text.substring(cursorPos);
    String result = _textController.text;
    int? indexing;
    if(textBeforeCursor != '') {
      int? index;
      for(int i=0;i<=textBeforeCursor.length-1;i++ ) {
        if(textBeforeCursor[i] == '@') {
          index = i;
        }
      }
      if(index!=null) {
        int? indexSpace;
        for(int i=index;i<=textBeforeCursor.length-1;i++ ) {
          if(textBeforeCursor[i] == ' '|| textBeforeCursor[i] == '\n' ) {
            indexSpace = i;
          }
          if(indexSpace == null && i == textBeforeCursor.length-1) {
            indexSpace = i;
          }
        }
        result = textBeforeCursor.substring(0, index);
        if(p == null) {
          result += '@${AppLocalizations.text(LangKey.all)}';
        }
        else {
          result += '@${p.firstName}${p.lastName}';
        }
        indexing = result.length;
        result += textBeforeCursor.substring(indexSpace!, textBeforeCursor.length-1);
        result += textAfterCursor;
      }
    }
    _textController.text = result;
    return indexing ?? _textController.text.length-1;
  }

  _onEmojiSelected(Emoji? emoji) {
    if(emoji != null) {
      _textController
        ..text += emoji.emoji
        ..selection = TextSelection.fromPosition(
            TextPosition(offset: _textController.text.length));
    }
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
      _textController.text = checkTag(editContent.text,widget.people);
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

  @override
  Widget build(BuildContext context) {
    widget.builder.call(hideEmoji);
    widget.inputBuilder.call(context, requestFocus);
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return !widget.isVisible ? Container(height: MediaQuery.of(context).padding.bottom,) :
      GestureDetector(
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
