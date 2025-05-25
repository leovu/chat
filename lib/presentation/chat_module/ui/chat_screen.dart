import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_screen/forward_screen.dart';
import 'package:chat/chat_ui/flutter_chat_ui.dart';
import 'package:chat/connection/app_lifecycle.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/download.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/room.dart' as r;
import 'package:chat/data_model/tag.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/check_tag.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:chat/presentation/chat_module/bloc/chat_bloc.dart';
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

import '../../../chat_ui/hex_color.dart';
import '../../../data_model/room.dart';
import '../../utils/dialog.dart';

class ChatScreen extends StatefulWidget {
  final Function? callback;
  final r.Rooms data;
  final String? source;
  final bool? isChatbot;
  final Owner? groupOwner;

  const ChatScreen(
      {Key? key,
      required this.data,
      this.callback,
      this.source,
      this.isChatbot = false,
      this.groupOwner})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends AppLifeCycle<ChatScreen> {
  List<types.Message> _messages = [];
  final _user = types.User(
      id: ChatConnection.checkUserTokenResponseModel?.user!.sId ?? '');
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
  late void Function() focusTextField;
  bool isInitScreen = true;
  Tag? tag;
  Tag? tagByUser = null;
  String? note;
  late ChatBloc _bloc;
  bool checkQuota = true;

  bool? isActive;
  int? peopleLength;
  bool? isBlock = false;
  Owner? groupOwner1;

  @override
  void initState() {
    super.initState();
    _bloc = ChatBloc();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ChatConnection.chatScreenNotificationHandler = _notificationHandler;

      if (widget.data.isGroup == false && ChatConnection.isChatHub)
        _getTagList();
      _loadMessages();

      ChatConnection.listenChat(_refreshMessage);

      if (widget.source == 'zalo' && widget.data.isGroup == false) {
        getQuota();
      }
      if (ChatConnection.isChatHub) {
        isBlock = widget.data.owner?.isBlocked ?? false;
      }

      groupOwner1 = extractOwner(widget.data);
    });
    final imageUrl =
        '${HTTPConnection.domain}api/images/vs9lgw7ey86805c7187f5011001205cbf6/256/${ChatConnection.brandCode!}';
    print('Image URL: $imageUrl');
  }

  getQuota() async {
    checkQuota = await _bloc.getQuota(
        widget.data.channel!.socialChanelId!, widget.data.owner!.userSocialId!);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    itemPositionsListener.itemPositions.removeListener(() {});
    ChatConnection.isLoadMore = false;
    ChatConnection.roomId = null;
  }

  Future<void> _getTagList() async {
    if (ChatConnection.isChatHub && widget.data.isGroup == true) return;
    tagByUser =
        await ChatConnection.getTagListByUser(widget.data.owner?.sId ?? '');
    setState(() {});
  }

  void _addMessage(types.Message message, String id,
      {String? text,
      String? repliedMessageId,
      types.TextMessage? isEdit}) async {
    if (isEdit != null) {
      types.Message ms =
          _messages.firstWhere((element) => element.id == isEdit.id);
      final textMessage = types.TextMessage(
          author: _user,
          createdAt: ms.createdAt,
          id: ms.id,
          text: (message as types.TextMessage).text,
          repliedMessage: isEdit.repliedMessage ?? ms.repliedMessage);
      int index = _messages.indexOf(ms);
      _messages[index] = textMessage;
      if (mounted) {
        setState(() {});
        int? index = listIdMessages[ms.id]!;
        scroll(index);
      }
      String? reppliedMessageId =
          (isEdit.repliedMessage ?? ms.repliedMessage)?.id;
      await ChatConnection.updateChat(message.text, ms.id, data?.room,
          reppliedMessageId: reppliedMessageId);
    } else {
      if (mounted) {
        setState(() {
          _messages.insert(0, message);
        });
      }
      if (message.type.name == 'text') {
        note = await ChatConnection.sendChat(
            data,
            _messages,
            id,
            text,
            data?.room,
            ChatConnection.checkUserTokenResponseModel?.user?.sId ?? '',
            reppliedMessageId: repliedMessageId);
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  void addTaskInstance(String textMessage) {
    ChatConnection.addOnModules!.firstWhere((e) => e['key'] == 'create_jobs')[
        'function'](checkTag(textMessage, data?.room?.people));
  }

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
    List<SheetAction<String>> _list = [];
    _list.add(SheetAction(
      icon: Icons.photo,
      label: AppLocalizations.text(LangKey.photo),
      key: 'Photo',
    ));
    if (widget.source == null) {
      _list.add(const SheetAction(
        icon: Icons.video_collection_sharp,
        label: 'Video',
        key: 'Video',
      ));
    }
    _list.add(SheetAction(
      icon: Icons.file_copy,
      label: AppLocalizations.text(LangKey.file),
      key: 'File',
    ));
    if (ChatConnection.addOnModules != null) {
      for (var e in ChatConnection.addOnModules!) {
        _list.add(SheetAction(
          icon: e['icon'],
          label: e['name'],
          key: e['key'],
        ));
      }
    }
    if (Platform.isAndroid) {
      _list.add(SheetAction(
          icon: Icons.cancel,
          label: AppLocalizations.text(LangKey.cancel),
          key: 'Cancel',
          isDestructiveAction: true));
    }
    return _list;
  }

  void _handleFileSelection() async {
    bool permission = await Permission.storage.request().isGranted;
    if (!permission) {
      return;
    }
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
          author: _user,
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
        if (mounted) {
          setState(() {});
        }
        ChatConnection.uploadFile(
                context,
                data,
                _messages,
                id,
                file,
                data?.room,
                ChatConnection.checkUserTokenResponseModel?.user?.sId ?? '')
            .then((r) {
          if (r == 'limit') {
            try {
              int index = _messages
                  .indexOf(_messages.firstWhere((element) => element.id == id));
              _messages.removeAt(index);
            } catch (_) {}
          }
          if (mounted) {
            setState(() {});
          }
        });
      }
    } catch (_) {
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

  void _handelVideoSelection() async {
    bool permission = await Permission.storage.request().isGranted;
    if (!permission) {
      return;
    }
    final result = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
    );
    if (result != null) {
      var size = await result.length();
      String id = const Uuid().v4();
      final message = types.FileMessage(
        author: _user,
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
      if (mounted) {
        setState(() {});
      }
      ChatConnection.uploadFile(context, data, _messages, id, file, data?.room,
              ChatConnection.checkUserTokenResponseModel?.user?.sId ?? '')
          .then((r) {
        if (r == 'limit') {
          try {
            int index = _messages
                .indexOf(_messages.firstWhere((element) => element.id == id));
            _messages.removeAt(index);
          } catch (_) {}
        }
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  void _handleImageSelection() async {
    bool permission = await Permission.storage.request().isGranted;
    if (!permission) {
      return;
    }
    final listResult = await ImagePicker()
        .pickMultiImage(imageQuality: 70, maxWidth: 1440, maxHeight: 1440);
    if (listResult.isNotEmpty) {
      for (var result in listResult) {
        pickedImageFromMulti(result);
      }
    }
  }

  void pickedImageFromMulti(XFile result) async {
    final bytes = await result.readAsBytes();
    final image = await decodeImageFromList(bytes);
    String id = const Uuid().v4();
    final message = types.ImageMessage(
      author: _user,
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
    if (mounted) {
      setState(() {});
    }
    ChatConnection.uploadImage(context, data, _messages, id, result, data?.room,
            ChatConnection.checkUserTokenResponseModel?.user?.sId ?? '')
        .then((r) {
      if (r == 'limit') {
        try {
          int index = _messages
              .indexOf(_messages.firstWhere((element) => element.id == id));
          _messages.removeAt(index);
        } catch (_) {}
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _handleCameraSelection() async {
    bool permission = await Permission.camera.request().isGranted;
    if (!permission) {
      return;
    }
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
        author: _user,
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
      if (mounted) {
        setState(() {});
      }
      ChatConnection.uploadImage(
              context,
              data,
              _messages,
              id,
              result,
              data?.room,
              ChatConnection.checkUserTokenResponseModel?.user?.sId ?? '')
          .then((r) {
        if (r == 'limit') {
          try {
            int index = _messages
                .indexOf(_messages.firstWhere((element) => element.id == id));
            _messages.removeAt(index);
          } catch (_) {}
        }
        if (mounted) {
          setState(() {});
        }
      });
    }
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
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const CupertinoActivityIndicator(
                        color: Colors.white,
                      ),
              )
            ],
          );
        });
  }

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
        openImage(context, message.uri);
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
      }
    }
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
        if (!ChatConnection.isChatHub)
          SheetAction(
            icon: Icons.reply,
            label: AppLocalizations.text(LangKey.reply),
            key: 'Reply',
          ),
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
        if (!ChatConnection.isChatHub)
          SheetAction(
            icon: Icons.forward,
            label: AppLocalizations.text(LangKey.forward),
            key: 'Forward',
          ),
        if (mess?.author?.sId == ChatConnection.user?.id &&
            !ChatConnection.isChatHub)
          SheetAction(
            icon: Icons.refresh,
            label: AppLocalizations.text(LangKey.recall),
            key: 'Recall',
          ),
        if (mess?.author?.sId == ChatConnection.user?.id &&
            message.type.name == 'text' &&
            !ChatConnection.isChatHub)
          SheetAction(
            icon: Icons.edit,
            label: AppLocalizations.text(LangKey.edit),
            key: 'Edit',
          ),
        if (!ChatConnection.isChatHub)
          SheetAction(
            icon: Icons.push_pin,
            label: AppLocalizations.text(LangKey.pinMessage),
            key: 'Pin Message',
          ),
        if (checkAddTaskIntanceAvailable() &&
            message is types.TextMessage &&
            !ChatConnection.isChatHub)
          SheetAction(
            icon: Icons.add_task,
            label: AppLocalizations.text(LangKey.createTask),
            key: 'Create Task',
          ),
        if (Platform.isAndroid)
          SheetAction(
              icon: Icons.cancel,
              label: AppLocalizations.text(LangKey.cancel),
              key: 'Cancel',
              isDestructiveAction: true),
      ],
    ).then((value) => value == 'Reply'
        ? chatController.reply(message)
        : value == 'Recall'
            ? recall(message, mess)
            : value == 'Pin Message'
                ? pinMesage(message, mess)
                : value == 'Forward'
                    ? forward(message, mess)
                    : value == 'Edit'
                        ? chatController.edit(message, mess)
                        : value == 'Copy'
                            ? copyMessage(message as types.TextMessage)
                            : value == 'Download'
                                ? downloadMessage(message)
                                : value == 'Create Task'
                                    ? addTaskInstance(
                                        (message as types.TextMessage).text)
                                    : {});
  }

  bool checkAddTaskIntanceAvailable() {
    if (ChatConnection.addOnModules != null) {
      if (ChatConnection.addOnModules!.isNotEmpty) {
        for (var e in ChatConnection.addOnModules!) {
          if (e['key'] == 'create_jobs') {
            return true;
          }
        }
      }
    }
    return false;
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

  void pinMesage(types.Message message, c.Messages? value) async {
    bool result = await ChatConnection.pinMessage(value!.sId, data?.room);
    if (result) {
      setState(() {
        data?.room?.pinMessage = c.PinMessage.fromJson(value.toJson());
      });
    }
  }

  void recall(types.Message message, c.Messages? value) async {
    bool result = await ChatConnection.recall(value, data?.room);
    if (result) {
      setState(() {
        if (message is types.ImageMessage) {
          data?.room?.messages?.remove(value);
          _messages.remove(message);
        } else if (message is types.TextMessage) {
          value?.content = AppLocalizations.text(LangKey.messageRecalled);
          int index = _messages.indexOf(message);
          final textMessage = types.TextMessage(
              author: _user,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: message.id,
              text: AppLocalizations.text(LangKey.messageRecalled));
          _messages[index] = textMessage;
        }
      });
    }
  }

  void forward(types.Message message, c.Messages? value) async {
    bool? result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ForwardScreen(message: message, value: value),
        settings: const RouteSettings(name: 'forward_screen')));
    if (result != null && result) {
      await _loadMessages();
      itemScrollController.jumpTo(index: 0);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = (_messages[index] as types.TextMessage)
        .copyWith(previewData: previewData);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _messages[index] = updatedMessage;
        });
      }
    });
  }

  void _handleSendPressed(types.PartialText message,
      {types.Message? repliedMessage, types.TextMessage? isEdit}) {
    String id = const Uuid().v4();
    final textMessage = types.TextMessage(
        author: _user,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        id: id,
        text: message.text,
        repliedMessage: repliedMessage);
    _addMessage(textMessage, id,
        text: message.text,
        repliedMessageId: repliedMessage?.id,
        isEdit: isEdit);
  }

  void _onStickerPressed(File sticker) async {
    final result = XFile(sticker.path);
    final bytes = await result.readAsBytes();
    final image = await decodeImageFromList(bytes);
    String id = const Uuid().v4();
    final message = types.ImageMessage(
      author: _user,
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
    if (mounted) {
      setState(() {});
    }
    ChatConnection.uploadImage(context, data, _messages, id, result, data?.room,
            ChatConnection.checkUserTokenResponseModel?.user?.sId ?? '')
        .then((r) {
      if (r == 'limit') {
        try {
          int index = _messages
              .indexOf(_messages.firstWhere((element) => element.id == id));
          _messages.removeAt(index);
        } catch (_) {}
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  _loadMessages() async {
    ChatConnection.roomId = widget.data.sId!;
    data = await ChatConnection.joinRoom(widget.data.sId!);
    peopleLength = data!.room!.people!.length;
    isInitScreen = false;

    if (data != null) {
      final messages = data?.room?.messages;
      final List<types.Message> values = [];

      if (messages != null) {
        for (var e in messages) {
          if (e.author?.sId != null && e.sId != null) {
            final result = Map<String, dynamic>.from(
              e.toMessageJson(messageSeen: data?.room?.messageSeen),
            );
            try {
              final msg = types.Message.fromJson(result);
              values.add(msg);
            } catch (err) {}
          }
        }

        _messages = values;
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

  _refreshMessage(dynamic cData) async {
    if (mounted) {
      if (widget.callback != null) {
        widget.callback!();
      }
      data = await ChatConnection.joinRoom(widget.data.sId!, refresh: true);
      isInitScreen = false;
      if (data != null) {
        List<c.Messages>? messages = data?.room?.messages;
        if (messages != null) {
          List<types.Message> values = [];
          for (var e in messages) {
            Map<String, dynamic> result =
                e.toMessageJson(messageSeen: data?.room?.messageSeen);
            if (e.author?.sId != null && e.sId != null) {
              values.add(types.Message.fromJson(result));
            }
          }
          if (mounted) {
            setState(() {
              _messages = values;
            });
          }
        }
      }
      if (mounted) {
        if (progress >= 0.15) {
          newMessage = true;
        }
        setState(() {});
      }
      Map<String, dynamic> notificationData =
          json.decode(json.encode(cData)) as Map<String, dynamic>;
      if (ChatConnection.roomId != null &&
          ChatConnection.roomId != notificationData['room']['_id']) {
        ChatConnection.showNotification(
            notificationData['room']['isGroup'] == true
                ? '${notificationData['message']['author']['firstName']} ${notificationData['message']['author']['lastName']} in ${notificationData['room']['title']}'
                : '${notificationData['message']['author']['firstName']} ${notificationData['message']['author']['lastName']}',
            checkTag(notificationData['message']['content'], null),
            notificationData,
            ChatConnection.appIcon,
            _notificationHandler);
      }
    }
  }

  Future<dynamic> _notificationHandler(Map<String, dynamic> message) async {
    try {
      if (ChatConnection.roomId == message['room']['_id']) {
        await _loadMessages();
      } else {
        r.Room? room = await ChatConnection.roomList();
        r.Rooms? rooms = room?.rooms
            ?.firstWhere((element) => element.sId == message['room']['_id']);
        Navigator.of(context)
            .popUntil((route) => route.settings.name == "home_screen");
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

  void _handleBlockUser() async {
    final owner = widget.data.owner;
    final fullName = '${owner!.firstName} ${owner.lastName}';
    await showInfoDialog(
      context,
      AppLocalizations.text(LangKey.notifications),
      content: isBlock == false
          ? '${AppLocalizations.text(LangKey.confirm_block_name)}$fullName'
          : '${AppLocalizations.text(LangKey.confirm_unblock_name)}$fullName',
      () async {
        await ChatConnection.blockUser(owner.sId!, !isBlock!);
        Navigator.of(context, rootNavigator: true).pop();
      },
      onCancel: () async {
        Navigator.of(context).pop();
      },
    );
  }

  Owner? extractOwner(Rooms data) {
    if (data.people == null || data.people!.isEmpty) return null;

    if (data.isGroup == true && data.owner != null) {
      final matchOwner = data.people!.where((e) => e.sId == data.owner!.sId);
      if (matchOwner.isNotEmpty) {
        return Owner.fromPeople(matchOwner.first);
      }
    } else {
      final matchOther =
          data.people!.where((e) => e.sId != ChatConnection.user?.id);
      if (matchOther.isNotEmpty) {
        return Owner.fromPeople(matchOther.first);
      }
    }

    return null;
  }

  bool isShowUserTag = true;

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
                  onPressed: () {
                    itemScrollController.jumpTo(index: 0);
                  },
                  child: !widget.data.isGroup!
                      ? (widget.data.room_avatar!.shieldedID != null &&
                              widget.data.room_avatar!.shieldedID != '')
                          ? CircleAvatar(
                              radius: 18.0,
                              backgroundImage: CachedNetworkImageProvider(
                                  '${HTTPConnection.domain}api/images/${widget.data.shieldedID}/256/${ChatConnection.brandCode!}',
                                  headers: {
                                    'brand-code': ChatConnection.brandCode!
                                  }),
                              backgroundColor: Colors.transparent,
                            )
                          : data!.room!.owner!.avatar != null
                              ? CircleAvatar(
                                  radius: 18.0,
                                  backgroundImage: CachedNetworkImageProvider(
                                      data!.room!.owner!.avatar!,
                                      headers: {
                                        'brand-code': ChatConnection.brandCode!
                                      }),
                                  backgroundColor: Colors.transparent,
                                )
                              : CircleAvatar(
                                  radius: 18.0,
                                  child: Text(
                                    widget.data.owner!.getAvatarName(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                )
                      : (widget.data.room_avatar!.shieldedID == null &&
                              widget.data.room_avatar!.shieldedID == '')
                          ? CircleAvatar(
                              radius: 18.0,
                              child: Text(
                                widget.data.getAvatarGroupName(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                          : CircleAvatar(
                              radius: 18.0,
                              backgroundImage: CachedNetworkImageProvider(
                                  '${HTTPConnection.domain}api/images/${widget.data.room_avatar!.shieldedID}/256/${ChatConnection.brandCode!}',
                                  headers: {
                                    'brand-code': ChatConnection.brandCode!
                                  }),
                              backgroundColor: Colors.transparent,
                            ),
                  mini: true,
                  foregroundColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        appBar: !_isSearchMessage ? _defaultAppbar() : _searchAppBar(),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _tagListWidget(),
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

  Widget _tagListWidget() {
    if (tagByUser == null ||
        tagByUser?.data == null ||
        !(ChatConnection.isChatHub && widget.data.isGroup == false)) {
      return const SizedBox.shrink();
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: !isShowUserTag
                      ? Container()
                      : Wrap(
                          children: tagByUser!.data!
                              .map((e) => _tagChip(e))
                              .toList()))),
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                setState(() {
                  isShowUserTag = !isShowUserTag;
                });
              },
              child: Container(
                  color: Colors.white,
                  constraints: const BoxConstraints(minHeight: 30),
                  child: Icon(
                      isShowUserTag
                          ? Icons.remove_red_eye
                          : Icons.remove_red_eye_outlined,
                      color: HexColor.fromHex('#0067AC'))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pinnedMessageWidget() {
    if (data?.room?.pinMessage == null) return const SizedBox.shrink();
    return Column(
      children: [
        Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.chat_outlined,
                    color: Color(0xff5686E1),
                  ),
                ),
                Expanded(
                    child: InkWell(
                  onTap: () {
                    try {
                      int? index = listIdMessages[data?.room?.pinMessage?.sId]!;
                      scroll(index);
                    } catch (_) {}
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        '${data?.room?.pinMessage?.author?.firstName} ${data?.room?.pinMessage?.author?.lastName}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xff5686E1)),
                      ),
                      data?.room?.pinMessage?.type == 'image'
                          ? SizedBox(
                              height: MediaQuery.of(context).size.width * 0.15,
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: CachedNetworkImage(
                                  fit: BoxFit.cover,
                                  imageUrl:
                                      '${HTTPConnection.domain}api/images/${data?.room?.pinMessage?.content}/256/${ChatConnection.brandCode!}',
                                  httpHeaders: {
                                    'brand-code': ChatConnection.brandCode!
                                  },
                                  placeholder: (context, url) =>
                                      const CupertinoActivityIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            )
                          : checkTagWidget(
                              data?.room?.pinMessage?.content ?? ''),
                    ],
                  ),
                )),
                Container(
                  margin: const EdgeInsets.only(left: 16),
                  height: 30,
                  width: 30,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 20.0,
                    ),
                    onPressed: () async {
                      setState(() {
                        data?.room?.pinMessage = null;
                      });
                      await ChatConnection.pinMessage(null, data?.room);
                    },
                    padding: EdgeInsets.zero,
                  ),
                )
              ],
            )),
        Container(
          height: 2.0,
          color: Colors.grey.shade300,
        ),
      ],
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
      messages: _messages,
      onMessageStatusTap: (context, message) {
        if (message.metadata != null) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          final snackBar = SnackBar(
              content: AutoSizeText(message.metadata!['error_message']));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      },
      isGroup: data?.room?.isGroup ?? false,
      people: widget.data.people,
      progressUpdate: (value) {
        progress = value;
        if (progress < 0.1 && newMessage) {
          setState(() {
            newMessage = false;
          });
        }
      },
      onAvatarTap: (p0) {},
      //  (types.User user) async {
      //Lỗi chưa xác định, xử lí phần chathub
      // if (user.id != ChatConnection.user!.id && data!.room!.isGroup!) {
      //   showLoading();
      //   r.Rooms? rooms = await ChatConnection.createRoom(user.id);
      //   Navigator.of(context).pop();
      //   ChatConnection.roomId = rooms!.sId!;

      //   await Navigator.of(context, rootNavigator: true).pushReplacement(
      //     MaterialPageRoute(
      //         builder: (context) =>
      //             ChatScreen(data: rooms, source: rooms.source),
      //         settings: const RouteSettings(name: 'chat_screen')),
      //   );
      //   try {
      //     ChatConnection.refreshRoom.call();
      //     ChatConnection.refreshFavorites.call();
      //     ChatConnection.refreshContact.call();
      //   } catch (_) {}
      // }
      // },
      onStickerPressed: _onStickerPressed,
      showUserAvatars: true,
      showUserNames: true,
      onAttachmentPressed: _handleAttachmentPressed,
      onMessageTap: _handleMessageTap,
      onMessageLongPress: _handleMessageLongPress,
      onPreviewDataFetched: _handlePreviewDataFetched,
      onCameraPressed: _handleCameraSelection,
      onSendPressed: _handleSendPressed,
      user: _user,
      isSearchChat: _isSearchMessage,
      scrollPhysics: const ClampingScrollPhysics(),
      itemPositionsListener: itemPositionsListener,
      itemScrollController: itemScrollController,
      listIdMessages: listIdMessages,
      searchController: _controllerSearch,
      chatController: chatController,
      loadMore: loadMore,
      builder: (BuildContext context, void Function() method) {
        focusTextField = method;
      },
      canSend: checkQuota,
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
                              color: currentIndexSearch > 0
                                  ? const Color(0xFF787878)
                                  : const Color(0xFF787878).withAlpha(60))),
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
                              color:
                                  currentIndexSearch < _listIdSearch.length - 1
                                      ? const Color(0xFF787878)
                                      : const Color(0xFF787878).withAlpha(60))),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                    AutoSizeText(
                        '${_listIdSearch.isEmpty ? 0 : currentIndexSearch + 1}/${_listIdSearch.length} results'),
                    Expanded(
                      child: Container(),
                    ),
                    const SizedBox(
                      width: 30.0,
                    ),
                    const SizedBox(
                      width: 30.0,
                    )
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
                  setState(() {
                    _listIdSearch = [];
                    currentIndexSearch = 0;
                    _isSearchMessage = !_isSearchMessage;
                  });
                });
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF787878)),
              ),
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
                child: Center(
                  child: Icon(
                    Icons.search,
                    color: Color(0xFF787878),
                  ),
                ),
              ),
              Expanded(
                  child: TextField(
                focusNode: _focusSearch,
                controller: _controllerSearch,
                onChanged: (_) {
                  if (mounted) {
                    searchChat();
                    if (_listIdSearch.isNotEmpty) {
                      scroll(_listIdSearch.first);
                    }
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
                  hintText: AppLocalizations.text(LangKey.findInChat),
                ),
              )),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(5),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: Icon(
                        Icons.close,
                        color: Color(0xFF787878),
                      ),
                    ),
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
        _messages.asMap().forEach((index, element) {
          if (element.type == types.MessageType.text) {
            String id = element.id;
            var message = element as types.TextMessage;
            List<String> contents = message.text.toLowerCase().split(' ');
            if (contents.contains(_controllerSearch.value.text.toLowerCase())) {
              int? index = listIdMessages[id];
              if (index != null) {
                _listIdSearch.add(index);
              }
            }
          }
        });
        if (_listIdSearch.isNotEmpty) {
          _listIdSearch.sort();
        }
      }
    } catch (_) {}
  }

  AppBar _defaultAppbar() {
    bool f = isFavorite(widget.data.people, widget.data.sId);
    return AppBar(
        actions: <Widget>[
          if (ChatConnection.isChatHub)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: InkWell(
                child: Icon(
                  Icons.block,
                  color: isBlock == false ? Colors.grey : Colors.red,
                ),
                onTap: () => _handleBlockUser(),
              ),
            ),
          if (!ChatConnection.isChatHub)
            IconButton(
              visualDensity:
                  const VisualDensity(horizontal: -4.0, vertical: -4.0),
              padding: EdgeInsets.zero,
              icon: Icon(
                f ? Icons.star : Icons.star_border,
                color: const Color(0xFFE5B80B),
              ),
              onPressed: () async {
                bool result =
                    await ChatConnection.toggleFavorites(widget.data.sId);
                if (result) {
                  if (mounted) {
                    setState(() {
                      toggleFavorite(widget.data.people, widget.data.sId);
                    });
                  }
                }
              },
            ),
          IconButton(
            visualDensity:
                const VisualDensity(horizontal: -4.0, vertical: -4.0),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.format_list_bulleted,
              color: Colors.black,
            ),
            onPressed: () async {
              showLoading();
              // data = await ChatConnection.joinRoom(widget.data.sId!,
              //     refresh: true);
              Navigator.of(context).pop();
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ConversationInformationScreen(
                      isChatBot: widget.isChatbot,
                      roomData: widget.data,
                      chatMessage: data,
                      groupOwner:
                          !ChatConnection.isChatHub ? groupOwner1 : null),
                  settings: const RouteSettings(
                      name: 'conversation_information_screen')));
              _loadMessages();
              // if (ChatConnection.isChatHub &&
              //     widget.data.isGroup == false)
              await _getTagList();
              setState(() {});
              // if(getPeople(widget.data.people).isUpdateTagList) {
              //   getPeople(widget.data.people).isUpdateTagList = false;
              //   await _getTagList();
              //   setState(() {});
              // }
              // else {
              //   setState(() {});
              // }
            },
          )
        ],
        title: SizedBox(
          height: 50.0,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: InkWell(
                  child: Icon(
                      Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                      color: Colors.black),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: buildAvatar(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: SizedBox(
                    height: !widget.data.isGroup! ? 25.0 : 50.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (ChatConnection.isChatHub)
                          AutoSizeText(
                            !widget.data.isGroup!
                                ? '${data?.room?.owner?.firstName ?? ''} ${data?.room?.owner?.lastName ?? ''}'
                                : widget.data.title ?? widget.data.room_name!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        if (!ChatConnection.isChatHub)
                          AutoSizeText(
                            !widget.data.isGroup!
                                ? '${widget.data.people![1].firstName} ${widget.data.people![1].lastName}'
                                : widget.data.room_name != null
                                    ? widget.data.room_name!
                                    : widget.data.title ??
                                        'Group ${widget.data.owner!.firstName} ${widget.data.owner!.lastName}',
                            // !widget.data.isGroup!
                            //     ? '${widget.data.owner!.firstName} ${widget.data.owner!.lastName}'
                            //     : widget.data.title ??
                            //         'Group ${widget.groupOwner!.firstName} ${widget.groupOwner!.lastName}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        if (widget.data.isGroup!)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3.0),
                            child: !ChatConnection.isChatHub
                                ? AutoSizeText(
                                    '${widget.data.people!.length} '
                                    '${AppLocalizations.text(LangKey.members).toLowerCase()}',
                                    maxLines: 1,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  )
                                : AutoSizeText(
                                    '${peopleLength != null ? peopleLength! - 1 : ''} '
                                    '${AppLocalizations.text(LangKey.members).toLowerCase()}',
                                    maxLines: 1,
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 12),
                                  ),
                          )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        leading: Container(),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        centerTitle: false,
        titleSpacing: 0,
        leadingWidth: 0);
  }

  CircleAvatar buildAvatar() {
    const double radius = 25.0;

    if (data?.room?.owner?.avatar != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(
          data!.room!.owner!.avatar!,
          headers: {'brand-code': ChatConnection.brandCode!},
        ),
        backgroundColor: Colors.transparent,
      );
    }

    if (!ChatConnection.isChatHub) {
      if (!widget.data.isGroup!) {
        final owner = extractOwner(widget.data);
        final isOwnerPictureEmpty = owner?.picture?.isEmpty ?? true;

        return isOwnerPictureEmpty
            ? CircleAvatar(
                radius: radius,
                child: Text(
                  owner?.getAvatarName() ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : CircleAvatar(
                radius: radius,
                backgroundImage: CachedNetworkImageProvider(
                  '${HTTPConnection.domain}api/images/${widget.data.room_avatar!.shieldedID}/256/${ChatConnection.brandCode!}',
                  headers: {'brand-code': ChatConnection.brandCode!},
                ),
                backgroundColor: Colors.transparent,
              );
      } else {
        if (widget.data.room_avatar == null) {
          final avatar = data?.room?.owner?.avatar;

          return avatar != null
              ? CircleAvatar(
                  radius: 18.0,
                  backgroundImage: CachedNetworkImageProvider(
                    avatar,
                    headers: {'brand-code': ChatConnection.brandCode!},
                  ),
                  backgroundColor: Colors.transparent,
                )
              : CircleAvatar(
                  radius: 18.0,
                  child: Text(
                    widget.data.owner?.getAvatarName() ?? '',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
        } else {
          return CircleAvatar(
            radius: radius,
            backgroundImage: CachedNetworkImageProvider(
              '${HTTPConnection.domain}api/images/${widget.data.room_avatar!.shieldedID}/256/${ChatConnection.brandCode!}',
              headers: {'brand-code': ChatConnection.brandCode!},
            ),
            backgroundColor: Colors.transparent,
          );
        }
      }
    } else {
      if (widget.data.isGroup == false) {
        final avatar = widget.data.owner?.avatar;

        if (avatar == null) {
          final sid = widget.data.shieldedID;

          return (sid != null && sid != '')
              ? CircleAvatar(
                  radius: radius,
                  backgroundImage: CachedNetworkImageProvider(
                    '${HTTPConnection.domain}api/images/$sid/256/${ChatConnection.brandCode!}',
                    headers: {'brand-code': ChatConnection.brandCode!},
                  ),
                  backgroundColor: Colors.transparent,
                )
              : CircleAvatar(
                  radius: radius,
                  child: Text(
                    widget.data.owner?.getAvatarName() ?? '',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
        } else {
          return CircleAvatar(
            radius: radius,
            backgroundImage: CachedNetworkImageProvider(
              avatar,
              headers: {'brand-code': ChatConnection.brandCode!},
            ),
            backgroundColor: Colors.transparent,
          );
        }
      } else {
        return widget.data.avatar == null
            ? CircleAvatar(
                radius: radius,
                child: Text(
                  widget.data.getAvatarGroupName() ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : CircleAvatar(
                radius: radius,
                backgroundImage: CachedNetworkImageProvider(
                  widget.data.avatar!,
                  headers: {'brand-code': ChatConnection.brandCode!},
                ),
                backgroundColor: Colors.transparent,
              );
      }
    }
  }

  r.People getPeople(List<r.People>? people) {
    return people!.first.sId != ChatConnection.user!.id
        ? people.first
        : people.last;
  }

  bool isFavorite(List<r.People>? people, String? roomId) {
    try {
      r.People? p = people
          ?.firstWhere((element) => element.sId == ChatConnection.user!.id);
      if (p!.favorites.contains(roomId)) {
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  toggleFavorite(List<r.People>? people, String? roomId) {
    try {
      r.People? p = people
          ?.firstWhere((element) => element.sId == ChatConnection.user!.id);
      if (p!.favorites.contains(roomId)) {
        p.favorites.remove(roomId);
      } else {
        p.favorites ??= [];
        p.favorites.add(roomId!);
      }
      try {
        ChatConnection.refreshRoom.call();
        ChatConnection.refreshFavorites.call();
      } catch (_) {}
    } catch (_) {}
  }

  Widget checkTagWidget(String message) {
    Widget _widget;
    List<InlineSpan> _arr = [];
    List<String> contents = message.split(' ');
    for (int i = 0; i < contents.length; i++) {
      var element = contents[i];
      if (element == '@all-all@') {
        element = '@${AppLocalizations.text(LangKey.all)}';
        _arr.add(TextSpan(
            text: '$element ',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)));
      } else {
        try {
          if (element[element.length - 1] == '@' && element.contains('-')) {
            element = element.split('-').first;
            _arr.add(TextSpan(
                text: '$element ',
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)));
          } else {
            _arr.add(TextSpan(
                text: i == contents.length - 1 ? element : '$element ',
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.normal)));
          }
        } catch (_) {
          _arr.add(TextSpan(
              text: i == contents.length - 1 ? element : '$element ',
              style: TextStyle(
                  color: Colors.grey.shade700, fontWeight: FontWeight.normal)));
        }
      }
    }
    _widget = Text.rich(
      TextSpan(
        children: _arr,
      ),
      maxLines: 2,
    );
    return _widget;
  }

  Widget _tagChip(Data e) {
    if (e.isActive == false) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
        child: Container(
          height: 30.0,
          decoration: BoxDecoration(
              color: HexColor.fromHex(
                  (e.color != null && e.color != 'null') ? e.color : '#0067AC'),
              borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
            child: AutoSizeText(
              e.name ?? '',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }
  }

  void loadMore() async {
    List<c.Messages>? value = await ChatConnection.loadMoreMessageRoom(
        ChatConnection.roomId!,
        _messages.last.id,
        data!.room!.messages!.last.date!);
    if (value != null) {
      List<c.Messages>? messages = value;
      if (messages.isNotEmpty) {
        data?.room?.messages?.addAll(messages);
        List<types.Message> values = [];
        for (var e in messages) {
          Map<String, dynamic> result =
              e.toMessageJson(messageSeen: data?.room?.messageSeen);
          if (e.author?.sId != null && e.sId != null) {
            values.add(types.Message.fromJson(result));
          }
        }
        if (mounted) {
          setState(() {
            _messages.addAll(values);
            Future.delayed(const Duration(seconds: 2))
                .then((value) => ChatConnection.isLoadMore = false);
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

Owner? extractOwner(Rooms data) {
  if (data.people == null || data.people!.isEmpty) return null;

  if (data.isGroup == true && data.owner != null) {
    final matchOwner = data.people!.where((e) => e.sId == data.owner!.sId);
    if (matchOwner.isNotEmpty) {
      return Owner.fromPeople(matchOwner.first);
    }
  } else {
    final matchOther =
        data.people!.where((e) => e.sId != ChatConnection.user?.id);
    if (matchOther.isNotEmpty) {
      return Owner.fromPeople(matchOther.first);
    }
  }

  return null;
}
