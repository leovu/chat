import 'dart:convert';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_ui/flutter_chat_ui.dart';
import 'package:chat/connection/app_lifecycle.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/services/notification_service.dart';
import 'package:chat/connection/download.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/room.dart' as r;
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/check_tag.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:chat/presentation/chat_module/bloc/chat_bloc.dart';
import 'package:chat/presentation/chat_module/ui/chat_hub_screen.dart';
import 'package:chat/presentation/chat_module/ui/internal_chat_screen.dart';
import 'package:chat/presentation/conversation_modules/src/ui/conversation_information_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:uuid/uuid.dart';

import '../../../chat_ui/widgets/custom_message_builder.dart';
import '../../../data_model/room.dart';

// ── Routing widget (public API unchanged) ────────────────────────────────────

class ChatScreen extends StatelessWidget {
  final Function? callback;
  final r.Rooms data;
  final String? source;
  final bool? isChatbot;
  final Owner? groupOwner;

  const ChatScreen({
    Key? key,
    required this.data,
    this.callback,
    this.source,
    this.isChatbot = false,
    this.groupOwner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ChatConnection.isChatHub) {
      return ChatHubScreen(
        data: data,
        callback: callback,
        source: source,
        isChatbot: isChatbot,
        groupOwner: groupOwner,
      );
    }
    return InternalChatScreen(
      data: data,
      callback: callback,
      source: source,
      isChatbot: isChatbot,
      groupOwner: groupOwner,
    );
  }
}

// ── Abstract base StatefulWidget ─────────────────────────────────────────────

abstract class ChatScreenBase extends StatefulWidget {
  final Function? callback;
  final r.Rooms data;
  final String? source;
  final bool? isChatbot;
  final Owner? groupOwner;

  const ChatScreenBase({
    Key? key,
    required this.data,
    this.callback,
    this.source,
    this.isChatbot = false,
    this.groupOwner,
  }) : super(key: key);
}

// ── Abstract base State with all shared logic ─────────────────────────────────

abstract class ChatScreenBaseState<T extends ChatScreenBase>
    extends AppLifeCycle<T> {
  // ── Shared state ───────────────────────────────────────────────────────────
  List<types.Message> messages = [];
  late final types.User user;
  c.ChatMessage? data;
  bool _isSearchMessage = false;
  final _focusSearch = FocusNode();
  final _controllerSearch = TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  List<int> _listIdSearch = [];
  int currentIndexSearch = 0;
  Map<String, int> listIdMessages = {};
  final ChatController chatController = ChatController();
  bool newMessage = false;
  double progress = 0;
  late Function() focusTextField;
  bool isInitScreen = true;
  String? note;
  int? peopleLength;
  late ChatBloc bloc;
  Owner? groupOwner1;
  Map<String, List<types.ImageMessage>> _imageGroups = {};
  Set<String> _hiddenImageIds = {};

  // ── Abstract interface ─────────────────────────────────────────────────────

  AppBar buildDefaultAppBar();
  Widget buildTagArea();
  CircleAvatar buildAvatar({double? width});
  void onExtraInit() {}

  List<SheetAction<String>> extraLongPressActions(
      c.Messages? mess, types.Message message);

  void handleLongPressValue(
      String? value, types.Message message, c.Messages? mess);

  CircleAvatar? get chatAvatar;
  bool get canSendMessage;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    bloc = ChatBloc();
    final currentUser = ChatConnection.checkUserTokenResponseModel?.user;
    user = types.User(
      id: currentUser?.sId ?? '',
      firstName: currentUser?.firstName ?? '',
      lastName: currentUser?.lastName ?? '',
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ChatConnection.chatScreenNotificationHandler = _notificationHandler;
      loadMessages();
      ChatConnection.listenChat(_refreshMessage);
      onExtraInit();
      groupOwner1 = extractOwner(widget.data);
    });
  }

  @override
  void dispose() {
    super.dispose();
    itemPositionsListener.itemPositions.removeListener(() {});
    ChatConnection.isLoadMore = false;
    ChatConnection.removeListenChat(_refreshMessage);
    ChatConnection.roomId = null;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        floatingActionButton: newMessage
            ? Padding(
                padding: EdgeInsets.only(
                    bottom: (MediaQuery.of(context).size.height +
                            MediaQuery.of(context).viewPadding.bottom) *
                        0.03),
                child: FloatingActionButton(
                  onPressed: () => itemScrollController.jumpTo(index: 0),
                  mini: true,
                  foregroundColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  child: buildAvatar(width: 18.0),
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: !_isSearchMessage ? buildDefaultAppBar() : _searchAppBar(),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTagArea(),
              _pinnedMessageWidget(),
              Expanded(child: _messageListWidget()),
              _searchResultWidget(),
            ],
          ),
        ),
      ),
      canPop: false,
      onPopInvokedWithResult: (event, _) {
        if (!event) {
          ChatConnection.roomId = null;
          Navigator.of(context).pop();
        }
      },
    );
  }

  // ── Image grouping ─────────────────────────────────────────────────────────

  void _groupConsecutiveImages() {
    _imageGroups.clear();
    _hiddenImageIds.clear();

    for (int i = 0; i < messages.length; i++) {
      if (messages[i] is types.ImageMessage) {
        final currentMsg = messages[i] as types.ImageMessage;
        if (_hiddenImageIds.contains(currentMsg.id)) continue;

        List<types.ImageMessage> group = [currentMsg];
        int j = i + 1;
        while (j < messages.length) {
          if (messages[j] is types.ImageMessage) {
            final nextMsg = messages[j] as types.ImageMessage;
            if (nextMsg.author.id == currentMsg.author.id &&
                (currentMsg.createdAt! - nextMsg.createdAt!).abs() <= 1000) {
              group.add(nextMsg);
              _hiddenImageIds.add(nextMsg.id);
              j++;
            } else {
              break;
            }
          } else {
            break;
          }
        }
        if (group.length > 1) {
          _imageGroups[currentMsg.id] = group;
        }
      }
    }
  }

  // ── Message sending ────────────────────────────────────────────────────────

  Future<void> _addMessage(types.Message message, String id,
      {String? text,
      String? repliedMessageId,
      types.TextMessage? isEdit}) async {
    if (isEdit != null) {
      types.Message ms =
          messages.firstWhere((element) => element.id == isEdit.id);
      final textMessage = types.TextMessage(
          author: user,
          createdAt: ms.createdAt,
          id: ms.id,
          remoteId: '1',
          text: (message as types.TextMessage).text,
          repliedMessage: isEdit.repliedMessage ?? ms.repliedMessage);
      int index = messages.indexOf(ms);
      messages[index] = textMessage;
      if (mounted) {
        setState(() {});
        int? idx = listIdMessages[ms.id]!;
        scroll(idx);
      }
      String? reppliedMessageId =
          (isEdit.repliedMessage ?? ms.repliedMessage)?.id;
      await ChatConnection.updateChat(message.text, ms.id, data?.room,
          reppliedMessageId: reppliedMessageId);
    } else {
      messages.insert(0, message);
      if (message.type.name == 'text') {
        note = await ChatConnection.sendChat(
            data,
            messages,
            id,
            text,
            data?.room,
            ChatConnection.checkUserTokenResponseModel?.user?.sId ?? '',
            reppliedMessageId: repliedMessageId);
      }
    }

    if (mounted) {
      _groupConsecutiveImages();
      setState(() {});
    }
  }

  // ── Attachment handlers ────────────────────────────────────────────────────

  Future<bool> _requestStoragePermission() async => true;

  void _handleAttachmentPressed() {
    showModalActionSheet<String>(
      context: context,
      actions: _attachmentSheetAction(),
    ).then((value) => value == 'Photo'
        ? _handleImageSelection()
        : value == 'Video'
            ? _handelVideoSelection()
            : value == 'File'
                ? _handleFileSelection()
                : ChatConnection.addOnModules != null
                    ? ChatConnection.addOnModules!
                        .firstWhere((e) => e['key'] == value)['function']('')
                    : {});
  }

  List<SheetAction<String>> _attachmentSheetAction() {
    final list = <SheetAction<String>>[];
    list.add(SheetAction(
      icon: Icons.photo,
      label: AppLocalizations.text(LangKey.photo),
      key: 'Photo',
    ));
    if (widget.source == null) {
      list.add(const SheetAction(
        icon: Icons.video_collection_sharp,
        label: 'Video',
        key: 'Video',
      ));
    }
    list.add(SheetAction(
      icon: Icons.file_copy,
      label: AppLocalizations.text(LangKey.file),
      key: 'File',
    ));
    if (ChatConnection.addOnModules != null) {
      for (var e in ChatConnection.addOnModules!) {
        list.add(SheetAction(icon: e['icon'], label: e['name'], key: e['key']));
      }
    }
    if (Platform.isAndroid) {
      list.add(SheetAction(
          icon: Icons.cancel,
          label: AppLocalizations.text(LangKey.cancel),
          key: 'Cancel',
          isDestructiveAction: true));
    }
    return list;
  }

  Future<void> _handleFileSelection() async {
    bool permission = await _requestStoragePermission();
    if (!permission) return;
    try {
      FilePickerResult? result;
      if (widget.source != null && widget.source == 'zalo') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.any,
          allowCompression: false,
          withData: false,
          allowedExtensions: ['pdf', 'doc'],
        );
      } else {
        result = await FilePicker.platform.pickFiles(
            type: FileType.any, allowCompression: false, withData: false);
      }
      if (result != null && result.files.single.path != null) {
        String id = const Uuid().v4();
        final message = types.FileMessage(
          author: user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: id,
          mimeType: lookupMimeType(result.files.single.path!),
          name: result.files.single.name,
          size: result.files.single.size,
          uri: result.files.single.path!,
          showStatus: true,
          status: Status.sending,
        );
        File file = File(result.files.single.path!);
        _addMessage(message, id);
        if (mounted) setState(() {});
        ChatConnection.uploadFile(context, data, messages, id, file, data?.room,
                ChatConnection.checkUserTokenResponseModel?.user?.sId ?? '')
            .then((r) {
          if (r == 'limit') {
            try {
              int index = messages
                  .indexOf(messages.firstWhere((element) => element.id == id));
              messages.removeAt(index);
            } catch (_) {}
          }
          if (mounted) setState(() {});
        });
      }
    } catch (_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.text(LangKey.warning)),
          content: Text(AppLocalizations.text(LangKey.limitSizeUpload)),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.text(LangKey.accept)),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handelVideoSelection() async {
    bool permission = await _requestStoragePermission();
    if (!permission) return;
    final result = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (result != null) {
      var size = await result.length();
      String id = const Uuid().v4();
      final message = types.FileMessage(
        author: user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: id,
        mimeType: lookupMimeType(result.path),
        name: result.name,
        size: size,
        uri: result.path,
        showStatus: true,
        status: Status.sending,
      );
      File file = File(result.path);
      _addMessage(message, id);
      if (mounted) setState(() {});
      ChatConnection.uploadFile(context, data, messages, id, file, data?.room,
              ChatConnection.checkUserTokenResponseModel?.user?.sId ?? '')
          .then((r) {
        if (r == 'limit') {
          try {
            int index = messages
                .indexOf(messages.firstWhere((element) => element.id == id));
            messages.removeAt(index);
          } catch (_) {}
        }
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _handleImageSelection() async {
    bool permission = await _requestStoragePermission();
    if (!permission) return;
    final listResult = await ImagePicker()
        .pickMultiImage(imageQuality: 70, maxWidth: 1440, maxHeight: 1440);
    if (listResult.isNotEmpty) {
      for (var result in listResult) {
        pickedImageFromMulti(result);
      }
    }
  }

  Future<void> pickedImageFromMulti(XFile result) async {
    final bytes = await result.readAsBytes();
    final image = await decodeImageFromList(bytes);
    String id = const Uuid().v4();
    final message = types.ImageMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      height: image.height.toDouble(),
      id: id,
      name: result.name,
      size: bytes.length,
      uri: result.path,
      width: image.width.toDouble(),
      showStatus: true,
      status: Status.sending,
    );
    _addMessage(message, id);
    if (mounted) setState(() {});
    ChatConnection.uploadImage(context, data, messages, id, result, data?.room,
            ChatConnection.checkUserTokenResponseModel?.user?.sId ?? '')
        .then((r) {
      if (r == 'limit') {
        try {
          int index = messages
              .indexOf(messages.firstWhere((element) => element.id == id));
          messages.removeAt(index);
        } catch (_) {}
      }
      if (mounted) {
        _groupConsecutiveImages();
        setState(() {});
      }
    });
  }

  Future<void> _handleCameraSelection() async {
    bool permission = await Permission.camera.request().isGranted;
    if (!permission) return;
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      maxHeight: 1440,
      source: ImageSource.camera,
    );
    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      String id = const Uuid().v4();
      final message = types.ImageMessage(
        author: user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: id,
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
        showStatus: true,
        status: Status.sending,
      );
      _addMessage(message, id);
      if (mounted) setState(() {});
      ChatConnection.uploadImage(
              context,
              data,
              messages,
              id,
              result,
              data?.room,
              ChatConnection.checkUserTokenResponseModel?.user?.sId ?? '')
          .then((r) {
        if (r == 'limit') {
          try {
            int index = messages
                .indexOf(messages.firstWhere((element) => element.id == id));
            messages.removeAt(index);
          } catch (_) {}
        }
        if (mounted) setState(() {});
      });
    }
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────

  Future<void> showLoading() async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              Center(
                child: Platform.isAndroid
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const CupertinoActivityIndicator(color: Colors.white),
              )
            ],
          );
        });
  }

  // ── Message interaction ────────────────────────────────────────────────────

  void _handleMessageTap(
      BuildContext cxt, types.Message message, bool isRepliedMessage) async {
    if (isRepliedMessage) {
      if (message is types.FileMessage) {
        showLoading();
        String? result = await download(
            context, message.uri, '${message.createdAt}_${message.name}');
        Navigator.of(context).pop();
        openFile(result, context, message.name);
      }
      if (message is types.ImageMessage) {
        openImage(context, message.uri, onResend: _resendEditedImage);
      }
    } else {
      if (message is types.FileMessage &&
          message.status != Status.sending &&
          message.status != Status.error) {
        showLoading();
        String? result = await download(
            context, message.uri, '${message.createdAt}_${message.name}');
        Navigator.of(context).pop();
        openFile(result, context, message.name);
      } else if (message is types.ImageMessage) {
        openImage(context, message.uri, onResend: _resendEditedImage);
      }
    }
  }

  /// Gửi lại ảnh đã chỉnh sửa (vẽ/khoanh) vào cuộc trò chuyện hiện tại.
  Future<void> _resendEditedImage(File editedImage) async {
    await pickedImageFromMulti(XFile(editedImage.path));
  }

  void _handleMessageLongPress(
      BuildContext context, types.Message message) async {
    if (message is types.TextMessage &&
        message.text == AppLocalizations.text(LangKey.messageRecalled)) {
      return;
    }
    c.Messages? mess =
        data?.room?.messages?.firstWhere((e) => e.sId == message.id);

    showModalActionSheet<String>(
      context: context,
      actions: [
        ...extraLongPressActions(mess, message),
        if (message is types.ImageMessage || message is types.FileMessage)
          SheetAction(
            icon: Icons.download_rounded,
            label: AppLocalizations.text(LangKey.download),
            key: 'Download',
          ),
        if (message is types.TextMessage)
          SheetAction(
            icon: Icons.copy,
            label: AppLocalizations.text(LangKey.copy),
            key: 'Copy',
          ),
        if (Platform.isAndroid)
          SheetAction(
              icon: Icons.cancel,
              label: AppLocalizations.text(LangKey.cancel),
              key: 'Cancel',
              isDestructiveAction: true),
      ],
    ).then((value) {
      if (value == null || value == 'Cancel') return;
      if (value == 'Download') {
        downloadMessage(message);
        return;
      }
      if (value == 'Copy') {
        copyMessage(message as types.TextMessage);
        return;
      }
      handleLongPressValue(value, message, mess);
    });
  }

  void downloadMessage(types.Message message) async {
    showLoading();
    if (message is types.FileMessage) {
      await download(
          context, message.uri, '${message.createdAt}_${message.name}',
          isSaveGallery: true);
    } else if (message is types.ImageMessage) {
      await download(
          context, message.uri, '${message.createdAt}_${message.name}.jpeg',
          isSaveGallery: true);
    }
    Navigator.of(context).pop();
  }

  void copyMessage(types.TextMessage message) {
    String copyText = checkTag(message.text, data?.room?.people);
    if (copyText.isNotEmpty) {
      try {
        Clipboard.setData(ClipboardData(text: copyText)).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.text(LangKey.copyAlert)),
            duration: const Duration(seconds: 2),
          ));
        });
      } catch (_) {}
    }
  }

  void _handlePreviewDataFetched(
      types.TextMessage message, types.PreviewData previewData) {
    final index = messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (messages[index] as types.TextMessage)
        .copyWith(previewData: previewData);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => messages[index] = updatedMessage);
    });
  }

  void _handleSendPressed(types.PartialText message,
      {types.Message? repliedMessage, types.TextMessage? isEdit}) {
    String id = const Uuid().v4();
    final textMessage = types.TextMessage(
        author: user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: id,
        text: message.text,
        repliedMessage: repliedMessage);
    String? repliedMsgSId;
    if (repliedMessage != null) {
      final rid = repliedMessage.id;
      if (RegExp(r'^[a-f0-9]{24}$').hasMatch(rid)) {
        repliedMsgSId = rid;
      }
    }
    _addMessage(textMessage, id,
        text: message.text, repliedMessageId: repliedMsgSId, isEdit: isEdit);
  }

  void _onStickerPressed(File sticker) async {
    final result = XFile(sticker.path);
    final bytes = await result.readAsBytes();
    final image = await decodeImageFromList(bytes);
    String id = const Uuid().v4();
    final message = types.ImageMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      height: image.height.toDouble(),
      id: id,
      name: result.name,
      size: bytes.length,
      uri: result.path,
      width: image.width.toDouble(),
      showStatus: true,
      status: Status.sending,
    );
    _addMessage(message, id);
    if (mounted) setState(() {});
    ChatConnection.uploadImage(context, data, messages, id, result, data?.room,
            ChatConnection.checkUserTokenResponseModel?.user?.sId ?? '')
        .then((r) {
      if (r == 'limit') {
        try {
          int index = messages
              .indexOf(messages.firstWhere((element) => element.id == id));
          messages.removeAt(index);
        } catch (_) {}
      }
      if (mounted) {
        _groupConsecutiveImages();
        setState(() {});
      }
    });
  }

  // ── Image builders ─────────────────────────────────────────────────────────

  Widget _buildImageMessageWidget(types.ImageMessage message,
      {required int messageWidth}) {
    if (_hiddenImageIds.contains(message.id)) return const SizedBox.shrink();
    final groupedImages = _imageGroups[message.id];
    if (groupedImages != null && groupedImages.length > 1) {
      return _buildGroupedImages(groupedImages, messageWidth);
    }
    return _buildSingleImage(message, messageWidth);
  }

  Widget _buildSingleImage(types.ImageMessage message, int messageWidth) {
    final isLocalFile = !message.uri.startsWith('http://') &&
        !message.uri.startsWith('https://');

    Widget imageWidget;
    if (isLocalFile) {
      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(message.uri),
          width: messageWidth.toDouble() * 0.7,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: messageWidth.toDouble() * 0.7,
            height: 100,
            child:
                const Icon(Icons.broken_image, size: 100, color: Colors.grey),
          ),
        ),
      );
    } else {
      String ensureFullUrl(String? url) {
        if (url == null || url.isEmpty) return '';
        if (url.startsWith('http://') || url.startsWith('https://')) return url;
        return '${HTTPConnection.domain}$url';
      }

      imageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: ensureFullUrl(message.uri),
          width: messageWidth.toDouble() * 0.7,
          fit: BoxFit.cover,
          httpHeaders: ChatConnection.brandCode != null
              ? {'brand-code': ChatConnection.brandCode!}
              : null,
          placeholder: (context, url) => Container(
            width: messageWidth.toDouble() * 0.7,
            height: 100,
            child:
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (context, url, error) => Container(
            width: messageWidth.toDouble() * 0.7,
            height: 100,
            child:
                const Icon(Icons.broken_image, size: 100, color: Colors.grey),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () =>
          openImage(context, message.uri, onResend: _resendEditedImage),
      child: imageWidget,
    );
  }

  Widget _buildGroupedImages(
      List<types.ImageMessage> images, int messageWidth) {
    final maxWidth = messageWidth.toDouble() * 0.7;
    const spacing = 4.0;
    double imageSize;
    if (images.length == 1) {
      imageSize = maxWidth;
    } else if (images.length == 2) {
      imageSize = (maxWidth - spacing) / 2;
    } else {
      imageSize = (maxWidth - spacing * 2) / 3;
    }
    final imageUrls = images.map((img) => img.uri).toList();

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: images.asMap().entries.map((entry) {
          final index = entry.key;
          final img = entry.value;
          final isLocalFile =
              !img.uri.startsWith('http://') && !img.uri.startsWith('https://');

          Widget imageWidget;
          if (isLocalFile) {
            imageWidget = Image.file(
              File(img.uri),
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: imageSize,
                height: imageSize,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            );
          } else {
            imageWidget = CachedNetworkImage(
              imageUrl: img.uri,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.cover,
              httpHeaders: ChatConnection.brandCode != null
                  ? {'brand-code': ChatConnection.brandCode!}
                  : null,
              placeholder: (context, url) => Container(
                width: imageSize,
                height: imageSize,
                child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                width: imageSize,
                height: imageSize,
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            );
          }

          return GestureDetector(
            onTap: () => openImages(context, imageUrls,
                initialIndex: index, onResend: _resendEditedImage),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageWidget,
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Message send handlers ──────────────────────────────────────────────────

  Future<void> _handleImageMessageSend(List<XFile> images) async {
    for (var image in images) {
      pickedImageFromMulti(image);
    }
  }

  Future<void> _handleVideoMessageSend(XFile video) async {
    var size = await video.length();
    String id = const Uuid().v4();
    final message = types.FileMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: id,
      mimeType: lookupMimeType(video.path),
      name: video.name,
      size: size,
      uri: video.path,
      showStatus: true,
      status: Status.sending,
    );
    File file = File(video.path);
    _addMessage(message, id);
    if (mounted) setState(() {});
    ChatConnection.uploadFile(context, data, messages, id, file, data?.room,
            ChatConnection.checkUserTokenResponseModel?.user?.sId ?? '')
        .then((r) {
      if (r == 'limit') {
        try {
          int index = messages
              .indexOf(messages.firstWhere((element) => element.id == id));
          messages.removeAt(index);
        } catch (_) {}
      }
      if (mounted) setState(() {});
    });
  }

  Future<void> _handleFileMessageSend(PlatformFile platformFile) async {
    String id = const Uuid().v4();
    final message = types.FileMessage(
      author: user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: id,
      mimeType: lookupMimeType(platformFile.path!),
      name: platformFile.name,
      size: platformFile.size,
      uri: platformFile.path!,
      showStatus: true,
      status: Status.sending,
    );
    File file = File(platformFile.path!);
    _addMessage(message, id);
    if (mounted) setState(() {});
    ChatConnection.uploadFile(context, data, messages, id, file, data?.room,
            ChatConnection.checkUserTokenResponseModel?.user?.sId ?? '')
        .then((r) {
      if (r == 'limit') {
        try {
          int index = messages
              .indexOf(messages.firstWhere((element) => element.id == id));
          messages.removeAt(index);
        } catch (_) {}
      }
      if (mounted) setState(() {});
    });
  }

  // ── Load / refresh ─────────────────────────────────────────────────────────

  Future<void> loadMessages() async {
    ChatConnection.roomId = widget.data.sId!;
    data = await ChatConnection.joinRoom(widget.data.sId!);
    peopleLength = data?.room?.people?.length;
    isInitScreen = false;

    if (data != null) {
      final rawMessages = data?.room?.messages;
      final List<types.Message> values = [];
      if (rawMessages != null) {
        for (var e in rawMessages) {
          if (e.author?.sId != null && e.sId != null) {
            final result = Map<String, dynamic>.from(
                e.toMessageJson(messageSeen: data?.room?.messageSeen));
            try {
              values.add(types.Message.fromJson(result));
            } catch (_) {}
          }
        }
        messages = values;
        _groupConsecutiveImages();
      }
    }

    if (mounted) {
      setState(() {});
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _refreshMessage(dynamic cData) async {
    if (!mounted) return;
    if (widget.callback != null) widget.callback!();
    data = await ChatConnection.joinRoom(widget.data.sId!, refresh: true);
    isInitScreen = false;
    if (data != null) {
      List<c.Messages>? rawMessages = data?.room?.messages;
      if (rawMessages != null) {
        List<types.Message> values = [];
        for (var e in rawMessages) {
          Map<String, dynamic> result =
              e.toMessageJson(messageSeen: data?.room?.messageSeen);
          if (e.author?.sId != null && e.sId != null) {
            values.add(types.Message.fromJson(result));
          }
        }
        if (mounted) {
          setState(() {
            messages = values;
            _groupConsecutiveImages();
          });
        }
      }
    }
    if (mounted) {
      if (progress >= 0.15) newMessage = true;
      setState(() {});
    }
    Map<String, dynamic> notificationData =
        json.decode(json.encode(cData)) as Map<String, dynamic>;
    if (ChatConnection.roomId != null &&
        ChatConnection.roomId != notificationData['room']['_id']) {
      ChatConnection.showNotification(
          NotificationService.buildTitle(notificationData),
          checkTag(notificationData['message']['content'], null),
          notificationData,
          ChatConnection.appIcon,
          _notificationHandler);
    }
  }

  Future<dynamic> _notificationHandler(Map<String, dynamic> message) async {
    try {
      if (ChatConnection.roomId == message['room']['_id']) {
        await loadMessages();
      } else {
        r.Room? room = await ChatConnection.roomList();
        r.Rooms? rooms = room?.rooms
            ?.firstWhere((element) => element.sId == message['room']['_id']);
        Navigator.of(context)
            .popUntil((route) => route.settings.name == 'home_screen');
        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
              builder: (context) =>
                  ChatScreen(data: rooms!, source: rooms.source),
              settings: const RouteSettings(name: 'chat_screen')),
        );
        try {
          ChatConnection.refreshRoom.call();
          ChatConnection.refreshContact.call();
          ChatConnection.refreshFavorites.call();
        } catch (_) {}
      }
    } catch (_) {}
  }

  // ── Owner helper ───────────────────────────────────────────────────────────

  Owner? extractOwner(Rooms data) {
    if (data.people == null || data.people!.isEmpty) return null;
    if (data.isGroup == true && data.owner != null) {
      final match = data.people!.where((e) => e.sId == data.owner!.sId);
      if (match.isNotEmpty) return Owner.fromPeople(match.first);
    } else {
      final match = data.people!.where((e) => e.sId != ChatConnection.user?.id);
      if (match.isNotEmpty) return Owner.fromPeople(match.first);
    }
    return null;
  }

  // ── Widgets ────────────────────────────────────────────────────────────────

  Widget _pinnedMessageWidget() {
    final pin = data?.room?.pinMessage;
    if (pin == null) return const SizedBox.shrink();
    final imgSize = MediaQuery.sizeOf(context).width * 0.15;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        border:
            Border(bottom: BorderSide(color: Colors.grey.shade300, width: 2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(Icons.chat_outlined, color: Color(0xff5686E1)),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  try {
                    scroll(listIdMessages[pin.sId]!);
                  } catch (_) {}
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      '${pin.author?.firstName} ${pin.author?.lastName}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xff5686E1)),
                    ),
                    if (pin.type == 'image')
                      SizedBox(
                        height: imgSize,
                        width: imgSize,
                        child: Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl:
                                '${HTTPConnection.domain}api/images/${pin.content}/256/${ChatConnection.brandCode!}',
                            httpHeaders: {
                              'brand-code': ChatConnection.brandCode!
                            },
                            placeholder: (_, __) =>
                                const CupertinoActivityIndicator(),
                            errorWidget: (_, __, ___) =>
                                const Icon(Icons.error),
                          ),
                        ),
                      )
                    else
                      checkTagWidget(pin.content ?? ''),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 30,
              width: 30,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey, size: 20.0),
                onPressed: () async {
                  setState(() => data?.room?.pinMessage = null);
                  await ChatConnection.pinMessage(null, data?.room);
                },
                padding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageListWidget() {
    if (isInitScreen) {
      return Center(
        child: Platform.isAndroid
            ? const CircularProgressIndicator()
            : const CupertinoActivityIndicator(),
      );
    }
    return Chat(
      note: note,
      source: widget.source,
      messages: messages.where((m) => !_hiddenImageIds.contains(m.id)).toList(),
      onMessageStatusTap: (context, message) {
        if (message.metadata != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          final snackBar = SnackBar(
              content: AutoSizeText(message.metadata!['error_message']));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      isGroup: data?.room?.isGroup ?? false,
      people: data?.room?.people ?? widget.data.people,
      progressUpdate: (value) {
        progress = value;
        if (progress < 0.1 && newMessage) setState(() => newMessage = false);
      },
      onAvatarTap: (p0) {},
      avatar: chatAvatar,
      imageMessageBuilder: _buildImageMessageWidget,
      fileMessageBuilder: buildFileWidget,
      customMessageBuilder: customMessageBuilder,
      onStickerPressed: _onStickerPressed,
      showUserAvatars: true,
      showUserNames: true,
      onAttachmentPressed: _handleAttachmentPressed,
      onMessageTap: _handleMessageTap,
      onMessageLongPress: _handleMessageLongPress,
      onPreviewDataFetched: _handlePreviewDataFetched,
      onCameraPressed: _handleCameraSelection,
      onSendPressed: _handleSendPressed,
      onImageMessageSend: _handleImageMessageSend,
      onVideoMessageSend: _handleVideoMessageSend,
      onFileMessageSend: _handleFileMessageSend,
      user: user,
      isSearchChat: _isSearchMessage,
      scrollPhysics: const ClampingScrollPhysics(),
      itemPositionsListener: itemPositionsListener,
      itemScrollController: itemScrollController,
      listIdMessages: listIdMessages,
      searchController: _controllerSearch,
      chatController: chatController,
      loadMore: loadMore,
      builder: (BuildContext context, Function() method) {
        focusTextField = method;
      },
      canSend: canSendMessage,
      roomData: widget.data,
    );
  }

  Widget _searchResultWidget() {
    return Visibility(
        visible: _isSearchMessage,
        child: Container(
          color: Colors.grey.shade200,
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 15.0, left: 10.0, right: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        if (_listIdSearch.isNotEmpty &&
                            currentIndexSearch > 0) {
                          currentIndexSearch -= 1;
                          scroll(_listIdSearch[currentIndexSearch]);
                          setState(() {});
                        }
                      },
                      child: SizedBox(
                          width: 30.0,
                          child: Icon(Icons.arrow_drop_down,
                              color: _listIdSearch.isNotEmpty &&
                                      currentIndexSearch > 0
                                  ? Colors.blue
                                  : Colors.grey)),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          _listIdSearch.isEmpty
                              ? '0/0'
                              : '${currentIndexSearch + 1}/${_listIdSearch.length}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13.0),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        if (_listIdSearch.isNotEmpty &&
                            currentIndexSearch < _listIdSearch.length - 1) {
                          currentIndexSearch += 1;
                          scroll(_listIdSearch[currentIndexSearch]);
                          setState(() {});
                        }
                      },
                      child: SizedBox(
                          width: 30.0,
                          child: Icon(Icons.arrow_drop_up,
                              color: _listIdSearch.isNotEmpty &&
                                      currentIndexSearch <
                                          _listIdSearch.length - 1
                                  ? Colors.blue
                                  : Colors.grey)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  AppBar _searchAppBar() {
    return AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _controllerSearch.text = '';
                  _listIdSearch = [];
                  currentIndexSearch = 0;
                  _isSearchMessage = !_isSearchMessage;
                });
              },
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF787878))),
            ),
          ),
        ],
        backgroundColor: Colors.white,
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
              color: const Color(0xFFE7EAEF),
              borderRadius: BorderRadius.circular(5)),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child:
                    Center(child: Icon(Icons.search, color: Color(0xFF787878))),
              ),
              Expanded(
                  child: TextField(
                focusNode: _focusSearch,
                controller: _controllerSearch,
                onChanged: (_) {
                  if (mounted) {
                    searchChat();
                    if (_listIdSearch.isNotEmpty) scroll(_listIdSearch.first);
                    setState(() {});
                  } else {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      searchChat();
                      if (_listIdSearch.isNotEmpty) {
                        scroll(_listIdSearch.first);
                        setState(() {});
                      }
                    });
                  }
                },
                decoration: InputDecoration.collapsed(
                    hintText: AppLocalizations.text(LangKey.findInChat)),
              )),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                        child: Icon(Icons.close, color: Color(0xFF787878))),
                  ),
                  onTap: () {
                    _controllerSearch.text = '';
                    setState(() {
                      _listIdSearch = [];
                      currentIndexSearch = 0;
                    });
                  },
                ),
              )
            ],
          ),
        ),
        centerTitle: false,
        leadingWidth: 0);
  }

  void scroll(int index) {
    itemScrollController.scrollTo(
        index: index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear);
  }

  void searchChat() {
    _listIdSearch = [];
    currentIndexSearch = 0;
    try {
      if (data != null) {
        messages.asMap().forEach((index, element) {
          if (element.type == types.MessageType.text) {
            String id = element.id;
            var message = element as types.TextMessage;
            List<String> contents = message.text.toLowerCase().split(' ');
            if (contents.contains(_controllerSearch.value.text.toLowerCase())) {
              int? idx = listIdMessages[id];
              if (idx != null) _listIdSearch.add(idx);
            }
          }
        });
        if (_listIdSearch.isNotEmpty) _listIdSearch.sort();
      }
    } catch (_) {}
  }

  Widget checkTagWidget(String message) {
    List<InlineSpan> arr = [];
    List<String> contents = message.split(' ');
    for (int i = 0; i < contents.length; i++) {
      var element = contents[i];
      if (element == '@all-all@') {
        element = '@${AppLocalizations.text(LangKey.all)}';
        arr.add(TextSpan(
            text: '$element ',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)));
      } else {
        try {
          if (element[element.length - 1] == '@' && element.contains('-')) {
            element = element.split('-').first;
            arr.add(TextSpan(
                text: '$element ',
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)));
          } else {
            arr.add(TextSpan(
                text: i == contents.length - 1 ? element : '$element ',
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.normal)));
          }
        } catch (_) {
          arr.add(TextSpan(
              text: i == contents.length - 1 ? element : '$element ',
              style: TextStyle(
                  color: Colors.grey.shade700, fontWeight: FontWeight.normal)));
        }
      }
    }
    return Text.rich(TextSpan(children: arr), maxLines: 2);
  }

  // ── Shared info-button handler (subclass calls this in their AppBar) ────────

  void onOpenConversationInfo() async {
    showLoading();
    Navigator.of(context).pop();
    await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ConversationInformationScreen(
            isChatBot: widget.isChatbot,
            roomData: widget.data,
            chatMessage: data,
            groupOwner: null),
        settings:
            const RouteSettings(name: 'conversation_information_screen')));
    loadMessages();
    setState(() {});
  }

  // ── Load more ──────────────────────────────────────────────────────────────

  Future<void> loadMore() async {
    List<c.Messages>? value = await ChatConnection.loadMoreMessageRoom(
        ChatConnection.roomId!,
        messages.last.id,
        data!.room!.messages!.last.date!);
    if (value != null) {
      if (value.isNotEmpty) {
        data?.room?.messages?.addAll(value);
        List<types.Message> values = [];
        for (var e in value) {
          Map<String, dynamic> result =
              e.toMessageJson(messageSeen: data?.room?.messageSeen);
          if (e.author?.sId != null && e.sId != null) {
            values.add(types.Message.fromJson(result));
          }
        }
        if (mounted) {
          setState(() {
            messages.addAll(values);
            Future.delayed(const Duration(seconds: 2))
                .then((_) => ChatConnection.isLoadMore = false);
          });
        }
      } else {
        ChatConnection.isLoadMore = false;
      }
    } else {
      ChatConnection.isLoadMore = false;
    }
  }
}

// ── Top-level helper ──────────────────────────────────────────────────────────

Owner? extractOwner(Rooms data) {
  if (data.people == null || data.people!.isEmpty) return null;
  if (data.isGroup == true && data.owner != null) {
    final match = data.people!.where((e) => e.sId == data.owner?.sId);
    if (match.isNotEmpty) return Owner.fromPeople(match.first);
  } else {
    final match = data.people!.where((e) => e.sId != ChatConnection.user?.id);
    if (match.isNotEmpty) return Owner.fromPeople(match.first);
  }
  return null;
}
