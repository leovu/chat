import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_ui/models/send_button_visibility_mode.dart';
import 'package:chat/chat_ui/widgets/sticker.dart';
import 'package:chat/common/assets.dart';
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
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class NewLineIntent extends Intent {
  const NewLineIntent();
}

class SendMessageIntent extends Intent {
  const SendMessageIntent();
}

typedef InputBuilder = void Function(BuildContext context,
    void Function({types.TextMessage? editContent}) focusTextField);

/// A class that represents bottom bar widget with a text field, attachment and
/// send buttons inside. By default hides send button when text field is empty.
class Input extends StatefulWidget {
  /// Creates [Input] widget
  const Input(
      {Key? key,
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
      required this.roomData,
      this.onImageSelected,
      this.onVideoSelected,
      this.onFileSelected,
      this.hasSelectedFiles = false})
      : super(key: key);

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
  final void Function(
      BuildContext context, types.Message, bool isRepliedMessage)? onMessageTap;

  final bool isGroup;
  final List<People>? people;

  /// Callbacks for file/image/video selection
  final void Function(List<XFile>)? onImageSelected;
  final void Function(XFile)? onVideoSelected;
  final void Function(PlatformFile)? onFileSelected;

  /// Whether there are files selected for preview
  final bool hasSelectedFiles;

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
  final void Function(types.PartialText,
      {types.Message? repliedMessage, types.TextMessage? isEdit}) onSendPressed;

  final void Function(File sticker) onStickerPressed;

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
  bool _attachmentShowing = false;
  // bool _isEdit = false;
  late RichTextController _textController;
  types.TextMessage? editContent;
  List<People>? _taggingSuggestList;
  List<String> _idTagList = [];
  late ChatBloc _bloc;
  String _imageData = '';

  @override
  void initState() {
    super.initState();
    _bloc = ChatBloc();
    String regex = '';

    // Kiểm tra nếu widget.people có giá trị và có người dùng hợp lệ
    if (widget.people != null && widget.people!.isNotEmpty) {
      regex = "r'@\b|";
      for (var e in widget.people!) {
        if (e.sId != ChatConnection.user!.id) {
          String val = '@${e.firstName}${e.lastName}'.trim();
          regex += '$val|';
        }
      }
      regex += '@${AppLocalizations.text(LangKey.all)}|';
      regex += "r'+\b'";
    } else {
      // Nếu không có người dùng hợp lệ, sử dụng một regex mặc định hoặc bỏ qua
      regex = 'r' '@\b';
    }

    getDraft();
    _textController = RichTextController(
      targetMatches: [
        MatchTargetItem(
            style: TextStyle(
                color: Colors.blueAccent, backgroundColor: Colors.grey[200]),
            regex: RegExp(regex))
      ],
      onMatch: (List<String> match) {},
    );

    _idTagList = [];
    if (widget.sendButtonVisibilityMode == SendButtonVisibilityMode.editing) {
      _sendButtonVisible =
          _textController.text.trim() != '' || widget.hasSelectedFiles;
      _textController.addListener(_handleTextControllerChange);
    } else {
      _sendButtonVisible = true;
    }

    // Add focus listener to close emoji/attachment when keyboard opens
    _inputFocusNode.addListener(() {
      if (_inputFocusNode.hasFocus) {
        // Keyboard is opening, close emoji and attachment pickers
        if (_emojiShowing || _attachmentShowing) {
          setState(() {
            _emojiShowing = false;
            _attachmentShowing = false;
          });
        }
      }
    });
  }

  void _deleteImage() {
    _imageData = '';
    setState(() {});
  }

  void getDraft() async {
    Map<String, dynamic>? value =
        await getDraftInput(ChatConnection.roomId ?? '');
    if (value != null) {
      if (value.containsKey('text')) {
        setState(() {
          _textController.text = checkTag(value['text'], widget.people);
        });
      }
      if (value.containsKey('tag_list')) {
        _idTagList = List<String>.from(value['tag_list']);
      }
    }
  }

  @override
  void didUpdateWidget(Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update send button visibility when hasSelectedFiles changes
    if (oldWidget.hasSelectedFiles != widget.hasSelectedFiles) {
      if (widget.sendButtonVisibilityMode == SendButtonVisibilityMode.editing) {
        setState(() {
          _sendButtonVisible =
              _textController.text.trim() != '' || widget.hasSelectedFiles;
        });
      }
    }
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _textController.dispose();
    Map<String, dynamic> value = {};
    if (_textController.value.text != '') {
      value['text'] = _textController.value.text;
    }
    if (_idTagList.isNotEmpty) {
      value['tag_list'] = _idTagList;
    }
    if (widget.repliedMessage != null) {
      value['reply'] = widget.repliedMessage?.toJson();
    }
    if (value.isNotEmpty) {
      try {
        saveDraftInput(value, ChatConnection.roomId!);
      } catch (_) {}
    } else {
      try {
        deleteDraftInput(ChatConnection.roomId ?? '');
      } catch (_) {}
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
    // _isEdit = false;
    var trimmedText = _textController.text.trim();
    trimmedText = trimmedText.replaceAll(
        '@${AppLocalizations.text(LangKey.all)}', '@all-all@');
    if (widget.people != null) {
      if (_idTagList.isNotEmpty) {
        for (var e in _idTagList) {
          try {
            People p = widget.people!.firstWhere((element) => element.sId == e);
            final searchName = '@${p.firstName}${p.lastName}';
            final replacement = '@${p.firstName}${p.lastName} -${p.sId}@';
            int idx = trimmedText.indexOf(searchName);
            while (idx != -1) {
              final after = trimmedText.substring(idx + searchName.length);
              if (!after.startsWith(' -')) {
                trimmedText = trimmedText.substring(0, idx) +
                    replacement +
                    trimmedText.substring(idx + searchName.length);
                break;
              }
              idx = trimmedText.indexOf(searchName, idx + 1);
            }
          } catch (_) {}
        }
      }
      _idTagList = [];
    }
    // Allow sending if there's text OR selected files
    if (trimmedText != '' || widget.hasSelectedFiles) {
      final _partialText = types.PartialText(text: trimmedText);
      widget.onSendPressed(_partialText,
          repliedMessage: InheritedRepliedMessage.of(context).repliedMessage,
          isEdit: editContent);
      editContent = null;
      _textController.clear();
    }
    setState(() {
      _taggingSuggestList = null;
    });
    deleteDraftInput(ChatConnection.roomId ?? '');
  }

  void _handleTextControllerChange() {
    setState(() {
      _sendButtonVisible =
          _textController.text.trim() != '' || widget.hasSelectedFiles;
      if (!_sendButtonVisible) {
        _idTagList = [];
      }
    });
  }

  Future<void> onChanged(String value) async {
    List<String> tagListDetect = detectTag(value, widget.people);
    for (var e in tagListDetect) {
      if (!_idTagList.contains(e)) {
        _idTagList.add(e);
      }
    }
    var cursorPos = _textController.selection.base.offset;
    int? index;
    String textBeforeCursor = _textController.text.substring(0, cursorPos);
    for (int i = textBeforeCursor.length - 1; i >= 0; i--) {
      if (textBeforeCursor[i] == ' ' || textBeforeCursor[i] == '\n') {
        break;
      }
      if (textBeforeCursor[i] == '@') {
        index = i;
      }
    }
    if (index != null) {
      if (_textController.text == '') {
        setState(() {
          _taggingSuggestList = null;
        });
      } else {
        String tagString;
        try {
          tagString =
              textBeforeCursor.substring(index + 1, textBeforeCursor.length);
        } catch (_) {
          tagString = '';
        }
        detectTagInTextField(tagString);
      }
    } else {
      if (_taggingSuggestList != null) {
        setState(() {
          _taggingSuggestList = null;
        });
      }
    }
  }

  detectTagInTextField(String data) {
    List<People> tmp = [];
    for (var e in widget.people!) {
      if ('${e.firstName}${e.lastName}'
              .toLowerCase()
              .contains(data.toLowerCase()) &&
          e.sId != ChatConnection.user!.id) {
        if ('${e.firstName}${e.lastName}'.toLowerCase() != data.toLowerCase()) {
          tmp.add(e);
        }
      }
    }
    if (tmp.isNotEmpty) {
      _taggingSuggestList = tmp;
      setState(() {});
    } else {
      if (data == '') {
        _taggingSuggestList = [];
        for (var e in widget.people!) {
          if (e.sId != ChatConnection.user!.id) {
            _taggingSuggestList!.add(e);
          }
        }
      }
      setState(() {});
    }
  }

  int emojiIndex = 0;

  Widget _buildEmojiStickerPicker() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        // color: Colors.grey[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Tabs với giao diện đẹp hơn
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              // borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Emoji Tab
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => emojiIndex = 0),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: emojiIndex == 0
                            ? const LinearGradient(
                                colors: [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                              )
                            : null,
                        color: emojiIndex == 0 ? null : Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_emotions,
                            size: 18,
                            color: emojiIndex == 0
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Emoji',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: emojiIndex == 0
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Sticker Tab
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => emojiIndex = 1),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: emojiIndex == 1
                            ? const LinearGradient(
                                colors: [Color(0xFFFF7043), Color(0xFFF4511E)],
                              )
                            : null,
                        color: emojiIndex == 1 ? null : Colors.transparent,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sticky_note_2,
                            size: 18,
                            color: emojiIndex == 1
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Sticker',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: emojiIndex == 1
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: emojiIndex == 0
                ? EmojiPicker(
                    onEmojiSelected: (Category? category, Emoji? emoji) {
                      _onEmojiSelected(emoji);
                    },
                    onBackspacePressed: _onBackspacePressed,
                    config: Config(
                      emojiViewConfig: EmojiViewConfig(
                        backgroundColor: Colors.grey[50]!,
                        columns: 7,
                        emojiSizeMax: 28,
                      ),
                      categoryViewConfig: CategoryViewConfig(
                        backgroundColor: Colors.white,
                        iconColorSelected: const Color(0xFF1E88E5),
                        indicatorColor: const Color(0xFF1E88E5),
                      ),
                      searchViewConfig: SearchViewConfig(
                        backgroundColor: Colors.transparent,
                        buttonIconColor: Colors.transparent,
                      ),
                      bottomActionBarConfig: BottomActionBarConfig(
                        backgroundColor: Colors.white,
                        enabled:
                            false, // Disable bottom action bar (search bar)
                      ),
                    ),
                  )
                : Column(
                    children: [
                      // Sticker categories với style đẹp hơn
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            stickerSelection("assets/icon-cat.png", 1),
                            const SizedBox(width: 12),
                            stickerSelection("assets/icon-rabbit.png", 2),
                            const SizedBox(width: 12),
                            stickerSelection("assets/icon-panda.png", 3),
                          ],
                        ),
                      ),
                      // Sticker grid
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: GridView(
                            scrollDirection: Axis.vertical,
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 120,
                              childAspectRatio: 1,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                            ),
                            children: stickers(),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// Toggle attachment picker
  void _showAttachmentOptions() {
    setState(() {
      _attachmentShowing = !_attachmentShowing;
      if (_attachmentShowing) {
        // Unfocus textfield when opening attachment picker
        _inputFocusNode.unfocus();
        _emojiShowing = false;
      }
    });
  }

  Widget _buildAttachmentPicker() {
    return Container(
      height: 150,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAttachmentItem(
            icon: Icons.photo_library,
            label: 'Gallery',
            color: const Color(0xFF4CAF50),
            onTap: () {
              _handleImageSelection();
            },
          ),
          _buildAttachmentItem(
            icon: Icons.insert_drive_file,
            label: 'Document',
            color: const Color(0xFF9C27B0),
            onTap: () {
              _handleFileSelection();
            },
          ),
          _buildAttachmentItem(
            icon: Icons.videocam,
            label: 'Video',
            color: const Color(0xFFE91E63),
            onTap: () {
              _handelVideoSelection();
            },
          ),
          _buildAttachmentItem(
            icon: Icons.emoji_emotions,
            label: 'Emoji',
            color: const Color(0xFFFFB300),
            onTap: () {
              // Unfocus keyboard when opening emoji picker
              _inputFocusNode.unfocus();
              setState(() {
                _attachmentShowing = false;
                _emojiShowing = true;
                emojiIndex = 0;
              });
            },
          ),
        ],
      ),
    );
  }

  /// Build single attachment item
  Widget _buildAttachmentItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget cho text field input
  Widget _buildTextField() {
    return Expanded(
      child: TextField(
        controller: _textController,
        cursorColor: InheritedChatTheme.of(context).theme.inputTextCursorColor,
        decoration: InheritedChatTheme.of(context)
            .theme
            .inputTextDecoration
            .copyWith(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 4,
              ),
              hintStyle:
                  InheritedChatTheme.of(context).theme.inputTextStyle.copyWith(
                        color: Colors.black.withValues(alpha: 0.2),
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
        style: InheritedChatTheme.of(context).theme.inputTextStyle.copyWith(
              color: Colors.black,
            ),
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.onAttachmentPressed != null &&
              widget.onCameraPressed != null)
            Visibility(
              visible: !_sendButtonVisible,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: _leftWidgetBuilder(),
              ),
            ),
          // Visibility(
          //   visible: _isEdit,
          //   child: Padding(
          //     padding: const EdgeInsets.only(left: 10.0, bottom: 4),
          //     child: RemoveEditButton(
          //       onPressed: () {
          //         _isEdit = false;
          //         _textController.text = '';
          //         if (!_isEdit) {
          //           editContent = null;
          //         }
          //       },
          //     ),
          //   ),
          // ),
          Visibility(
            visible: _sendButtonVisible,
            child: Padding(
              padding: EdgeInsets.only(
                right: 16.0,
                left: 8.0,
                bottom: 8,
              ),
              child: SendButton(
                onPressed: _handleSendPressed,
              ),
            ),
          ),
        ],
      ),
    );
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

    return widget.canSend
        ? Focus(
            autofocus: true,
            child: Material(
              borderRadius:
                  InheritedChatTheme.of(context).theme.inputBorderRadius,
              color: Colors.white,
              child: Container(
                margin: EdgeInsets.only(
                  bottom: AppSizes.maxPadding * 2,
                  left: AppSizes.maxPadding,
                  right: AppSizes.maxPadding,
                ),
                padding: EdgeInsets.only(bottom: AppSizes.maxPadding, top: 8),
                decoration: InheritedChatTheme.of(context)
                    .theme
                    .inputContainerDecoration,
                child: Column(
                  children: [
                    Visibility(
                        visible: _taggingSuggestList != null,
                        child: _taggingSuggestList != null
                            ? Wrap(
                                children: _arrayTaggingSuggestionList(
                                    _taggingSuggestList!.length ==
                                            widget.people!.length - 1 &&
                                        widget.isGroup),
                              )
                            : Container()),
                    if (InheritedRepliedMessage.of(context).repliedMessage !=
                        null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                        child: RepliedMessage(
                          isView: true,
                          onCancelReplyPressed: widget.onCancelReplyPressed,
                          repliedMessage: InheritedRepliedMessage.of(context)
                              .repliedMessage,
                          showUserNames: true,
                          onMessageTap: widget.onMessageTap,
                          people: widget.people,
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 0, 0, 16)
                          .add(_safeAreaInsets),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0xFFBCC5D7),
                                          width: 1.0),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10.0))),
                                  child: Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Visibility(
                                          visible: _imageData != '',
                                          child: Stack(
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child: Image.memory(
                                                    Uint8List.fromList(
                                                        _imageData.codeUnits),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 5.0,
                                                right: 5.0,
                                                child: GestureDetector(
                                                  onTap: _deleteImage,
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            4.0),
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.red,
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 16.0,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // _buildEmojiButton(),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              child: AttachmentButton(
                                                onPressed:
                                                    _showAttachmentOptions,
                                                // image:
                                                //     'assets/icon-chat-add.png',
                                                icon: Icon(
                                                    Icons
                                                        .add_circle_outline_outlined,
                                                    color: Colors.grey[700],
                                                    size: 25),
                                              ),
                                            ),
                                            _buildTextField(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              _buildActionButtons(),
                            ],
                          ),
                          Visibility(
                            visible: _attachmentShowing,
                            child: _buildAttachmentPicker(),
                          ),
                          Visibility(
                            visible: _emojiShowing,
                            child: _buildEmojiStickerPicker(),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : sendInteractionMessage();
  }

  popUpSendInteractionMessage(BuildContext buildContext) {
    return showDialog(
        context: buildContext,
        builder: (buildContext) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            content: Container(
                decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: new BorderRadius.all(Radius.circular(5))),
                height: MediaQuery.of(context).size.height * 0.5,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 27),
                child: Row(
                  children: [
                    messageItem('rating'),
                    Container(
                      width: 10.0,
                    ),
                    messageItem('promotion'),
                  ],
                )),
          );
        });
  }

  Widget messageItem(String type) {
    return Expanded(
        child: Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: AppColors.grayBackGround),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            child: Text(
              type == "rating"
                  ? AppLocalizations.text(LangKey.rating_message)
                  : AppLocalizations.text(LangKey.promotion_message),
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
          Expanded(
            child: Container(
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: Image.asset(
                  type == "rating"
                      ? Assets.imageRatingMessage
                      : Assets.imagePromotionMessage,
                  package: 'chat',
                  fit: BoxFit.fill,
                )),
          ),
          InkWell(
            onTap: () {
              CustomNavigator.showCustomAlertDialog(
                  context, null, AppLocalizations.text(LangKey.charge_message),
                  titleHeader: AppLocalizations.text(LangKey.warning),
                  enableCancel: true,
                  textSubSubmitted: AppLocalizations.text(LangKey.cancel),
                  textSubmitted: AppLocalizations.text(LangKey.confirm),
                  onSubmitted: () async {
                CustomNavigator.pop(context);
                CustomNavigator.pop(context);
                await _bloc.sendTransaction(
                    widget.roomData.channel!.socialChanelId!,
                    type,
                    widget.roomData.owner!.userSocialId!);
                _bloc.messageSystem(
                    widget.roomData.owner!.sId!, widget.roomData.sId!);
              });
            },
            child: Center(
              child: Container(
                margin: EdgeInsets.only(bottom: 5.0),
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 3),
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(6.0)),
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

  Widget sendInteractionMessage() {
    return InkWell(
      onTap: () => popUpSendInteractionMessage(context),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.0),
        height: 40.0,
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
            color: Colors.blue, borderRadius: BorderRadius.circular(10.0)),
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
    bool isSelected = emojiIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          emojiIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF4511E).withValues(alpha: 0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFF4511E)
                : Colors.grey.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: ImageIcon(
          AssetImage(icon, package: 'chat'),
          color: isSelected ? const Color(0xFFF4511E) : Colors.grey.shade400,
          size: 24,
        ),
      ),
    );
  }

  List<Widget> stickers() {
    if (emojiIndex == 1) {
      return Stickers.mimiCatStickers(widget.onStickerPressed);
    } else if (emojiIndex == 2) {
      return Stickers.usagyuunStickers(widget.onStickerPressed);
    } else if (emojiIndex == 3) {
      return Stickers.pandaStickers(widget.onStickerPressed);
    } else {
      return [Container()];
    }
  }

  List<Widget> _arrayTaggingSuggestionList(bool isAll) {
    List<Widget> _arr = [];
    if (isAll) {
      _arr.add(Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
        child: InkWell(
          onTap: () {
            int val = replaceTagInTextField(null, _textController.value.text);
            setState(() {
              _textController.selection =
                  TextSelection.fromPosition(TextPosition(offset: val));
              _taggingSuggestList = null;
            });
          },
          child: Row(
            children: [
              const Icon(
                Icons.group,
                color: Colors.grey,
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: AutoSizeText(AppLocalizations.text(LangKey.all),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ))
            ],
          ),
        ),
      ));
    }
    for (var e in _taggingSuggestList!) {
      _arr.add(Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
        child: InkWell(
          onTap: () {
            if (!_idTagList.contains(e.sId!)) {
              _idTagList.add(e.sId!);
            }
            int val = replaceTagInTextField(e, _textController.value.text);
            setState(() {
              _textController.selection =
                  TextSelection.fromPosition(TextPosition(offset: val));
              _taggingSuggestList = null;
            });
          },
          child: Row(
            children: [
              (e.avatar?.isNotEmpty == true)
                  ? CircleAvatar(
                      radius: 12.0,
                      backgroundImage: CachedNetworkImageProvider(e.avatar!),
                      backgroundColor: Colors.transparent,
                    )
                  : (e.picture?.shieldedID?.isNotEmpty == true)
                      ? CircleAvatar(
                          radius: 12.0,
                          backgroundImage: CachedNetworkImageProvider(
                              '${HTTPConnection.domain}api/images/${e.picture!.shieldedID}/256/${ChatConnection.brandCode!}',
                              headers: {
                                'brand-code': ChatConnection.brandCode!
                              }),
                          backgroundColor: Colors.transparent,
                        )
                      : CircleAvatar(
                          radius: 12.0,
                          child: AutoSizeText(
                            e.getAvatarName(),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 8),
                          ),
                        ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: AutoSizeText('${e.firstName}${e.lastName}',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ))
            ],
          ),
        ),
      ));
      if (_arr.length == 5) {
        break;
      }
    }
    if (_arr.isNotEmpty) {
      _arr.insert(
          0,
          Padding(
              padding: const EdgeInsets.only(bottom: 5.0),
              child: Container(
                height: 1.0,
                color: Colors.grey.shade200,
              )));
    }
    return _arr;
  }

  int replaceTagInTextField(People? p, String value) {
    var cursorPos = _textController.selection.base.offset;
    String textBeforeCursor = _textController.text.substring(0, cursorPos);
    String textAfterCursor = _textController.text.substring(cursorPos);
    String result = _textController.text;
    int? indexing;
    if (textBeforeCursor != '') {
      int? index;
      for (int i = 0; i <= textBeforeCursor.length - 1; i++) {
        if (textBeforeCursor[i] == '@') {
          index = i;
        }
      }
      if (index != null) {
        int? indexSpace;
        for (int i = index; i <= textBeforeCursor.length - 1; i++) {
          if (textBeforeCursor[i] == ' ' || textBeforeCursor[i] == '\n') {
            indexSpace = i;
          }
          if (indexSpace == null && i == textBeforeCursor.length - 1) {
            indexSpace = i;
          }
        }
        result = textBeforeCursor.substring(0, index);
        if (p == null) {
          result += '@${AppLocalizations.text(LangKey.all)}';
        } else {
          result += '@${p.firstName}${p.lastName}';
        }
        indexing = result.length;
        result += textBeforeCursor.substring(
            indexSpace!, textBeforeCursor.length - 1);
        result += textAfterCursor;
      }
    }
    _textController.text = result;
    return indexing ?? _textController.text.length - 1;
  }

  _onEmojiSelected(Emoji? emoji) {
    if (emoji != null) {
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
        height: 25,
        margin: const EdgeInsets.only(right: 16),
        width: 25,
        child: const CircularProgressIndicator(
          backgroundColor: Colors.transparent,
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(
            Colors.black,
          ),
        ),
      );
    } else {
      return Padding(
          padding: const EdgeInsets.only(bottom: 4, right: 8),
          child: AttachmentButton(
            onPressed: widget.onCameraPressed,
            icon: Icon(Icons.camera_alt_outlined,
                color: Colors.grey[700], size: 25),
          )
          // SizedBox(
          //   width: 35.0,
          //   height: 25.0,
          //   child: Row(
          //     children: [
          //       Expanded(
          //           child: AttachmentButton(
          //         onPressed: widget.onCameraPressed,
          //         image: 'assets/icon-camera.png',
          //       )),
          //       // Container(
          //       //   width: 10.0,
          //       // ),
          //       // Expanded(
          //       //     child: AttachmentButton(
          //       //   onPressed: widget.onAttachmentPressed,
          //       //   image: 'assets/icon-chat-add.png',
          //       // ))
          //     ],
          //   ),
          // ),
          );
    }
  }

  void requestFocus({types.TextMessage? editContent}) {
    if (editContent != null) {
      this.editContent = editContent;
      _textController.text = checkTag(editContent.text, widget.people);
      for (var e in widget.people!) {
        if (editContent.text
                .contains('@${e.firstName}${e.lastName}-${e.sId}') ||
            editContent.text
                .contains('@${e.firstName}${e.lastName} -${e.sId}')) {
          if (!_idTagList.contains(e.sId)) {
            _idTagList.add(e.sId!);
          }
        }
      }
      // _isEdit = true;
    }
    _inputFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    widget.builder.call(hideEmoji);
    widget.inputBuilder.call(context, requestFocus);
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    return !widget.isVisible
        ? Container(
            height: MediaQuery.of(context).padding.bottom,
          )
        : GestureDetector(
            onTap: () => _inputFocusNode.requestFocus(),
            child: isAndroid || isIOS
                ? _inputBuilder()
                : Shortcuts(
                    shortcuts: {
                      LogicalKeySet(LogicalKeyboardKey.enter):
                          const SendMessageIntent(),
                      LogicalKeySet(
                              LogicalKeyboardKey.enter, LogicalKeyboardKey.alt):
                          const NewLineIntent(),
                      LogicalKeySet(LogicalKeyboardKey.enter,
                          LogicalKeyboardKey.shift): const NewLineIntent(),
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
    if (mounted) {
      setState(() {
        _emojiShowing = false;
      });
    }
  }

  Future<bool> _requestStoragePermission() async {
    return true;
  }

  void _handleImageSelection() async {
    bool permission = await _requestStoragePermission();
    if (!permission) {
      return;
    }
    final listResult = await ImagePicker()
        .pickMultiImage(imageQuality: 70, maxWidth: 1440, maxHeight: 1440);
    if (listResult.isNotEmpty) {
      widget.onImageSelected?.call(listResult);
      setState(() {
        _attachmentShowing = false;
      });
    }
  }

  void _handelVideoSelection() async {
    bool permission = await _requestStoragePermission();
    if (!permission) {
      return;
    }
    final result = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (result != null) {
      widget.onVideoSelected?.call(result);
      setState(() {
        _attachmentShowing = false;
      });
    }
  }

  void _handleFileSelection() async {
    bool permission = await _requestStoragePermission();
    if (!permission) {
      return;
    }
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.any, allowCompression: false, withData: false);
      if (result != null && result.files.single.path != null) {
        widget.onFileSelected?.call(result.files.single);
        setState(() {
          _attachmentShowing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.text(LangKey.warning)),
            content: Text(AppLocalizations.text(LangKey.accept)),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.text(LangKey.accept)))
            ],
          ),
        );
      }
    }
  }
}
