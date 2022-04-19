import 'dart:convert';
import 'dart:io';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/room.dart' as r;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:chat/chat_ui/flutter_chat_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:uuid/uuid.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/connection/app_lifecycle.dart';
import 'package:flutter_chat_types/src/message.dart';

class ChatScreen extends StatefulWidget {
  final Function? callback;
  final r.Rooms data;
  const ChatScreen({Key? key, required this.data, this.callback}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends AppLifeCycle<ChatScreen> {
  List<types.Message> _messages = [];
  final _user = types.User(id: ChatConnection.user!.id);
  c.ChatMessage? data;
  @override
  void initState() {
    super.initState();
    _loadMessages();
    ChatConnection.listenChat(_refreshMessage);
  }

  void _addMessage(types.Message message,{String? text}) async {
    if(message.type.name == 'text') {
      await ChatConnection.sendChat(text,data?.room,ChatConnection.user!.id);
    }
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleAttachmentPressed() {
    showModalActionSheet<String>(
      context: context,
      actions: [
        const SheetAction(
          icon: Icons.photo,
          label: 'Photo',
          key: 'Photo',
        ),
        const SheetAction(
          icon: Icons.camera_alt,
          label: 'Camera',
          key: 'Camera',
        ),
        const SheetAction(
          icon: Icons.file_copy,
          label: 'File',
          key: 'File',
        ),
        if(Platform.isAndroid) const SheetAction(
            icon: Icons.cancel,
            label: 'Cancel',
            key: 'Cancel',
            isDestructiveAction: true),
      ],
    ).then((value) => value == 'Photo'
        ? _handleImageSelection()
        : value == 'File'
        ? _handleFileSelection()
        : value == 'Camera'
        ? _handleImageSelection(isCamera: true)
        : {});
  }
  void _handleFileSelection() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowCompression: false,
        withData: false,
      );
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
        _addMessage(message);
        ChatConnection.uploadFile(file,data?.room,ChatConnection.user!.id).then((r) {
          setState(() {
            int index = _messages.indexWhere((element) => element.id==id);
            Status s = !r ? Status.error : Status.sent;
            _messages[index] = types.FileMessage(
              author: _user,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: const Uuid().v4(),
              mimeType: lookupMimeType(result.files.single.path!),
              name: result.files.single.name,
              size: result.files.single.size,
              uri: result.files.single.path!,
              showStatus: true,
              status: s,
            );
          });
        });
      }
    }catch(_){
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Warning'),
          content: const Text('Get file error!'),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Accept'))
          ],
        ),
      );
    }
  }
  void _handleImageSelection({bool isCamera=false}) async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: !isCamera ? ImageSource.gallery : ImageSource.camera,
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
      _addMessage(message);
      ChatConnection.uploadImage(result,data?.room,ChatConnection.user!.id).then((r) {
        Status s = !r ? Status.error : Status.sent;
        int index = _messages.indexWhere((element) => element.id==id);
        _messages[index] = types.ImageMessage(
          author: _user,
          createdAt: DateTime.now().millisecondsSinceEpoch,
          height: image.height.toDouble(),
          id: id,
          name: result.name,
          size: bytes.length,
          uri: result.path,
          width: image.width.toDouble(),
          showStatus: true,
          status: s,
        );
        setState(() {});
      });
    }
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    if (message is types.FileMessage) {
      await OpenFile.open(message.uri);
    }
  }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = _messages[index].copyWith(previewData: previewData);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );
    _addMessage(textMessage,text: message.text);
  }

  _loadMessages() async {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      ChatConnection.roomId = widget.data.sId!;
      data = await ChatConnection.joinRoom(widget.data.sId!);
      if(data != null) {
        List<c.Messages>? messages = data?.room?.messages;
        if(messages != null) {
          final values = (messages)
              .map((e) => types.Message.fromJson(e.toMessageJson()))
              .toList();
          setState(() {
            _messages = values;
          });
        }
      }
      setState(() {});
    });
  }
  _refreshMessage(dynamic cData) async {
    if(mounted) {
      if(widget.callback!= null) {
        widget.callback!();
      }
      data = await ChatConnection.joinRoom(widget.data.sId!,refresh: true);
      if(data != null) {
        List<c.Messages>? messages = data?.room?.messages;
        if(messages != null) {
          final values = (messages)
              .map((e) => types.Message.fromJson(e.toMessageJson()))
              .toList();
          setState(() {
            _messages = values;
          });
        }
      }
      setState(() {});
      Map<String,dynamic> notificationData = json.decode(json.encode(cData)) as Map<String, dynamic>;
      if(ChatConnection.roomId != null && ChatConnection.roomId != notificationData['room']['_id']) {
        ChatConnection.showNotification('${notificationData['message']['author']['firstName']} ${notificationData['message']['author']['lastName']}',
            notificationData['message']['content'],
            notificationData, ChatConnection.appIcon, _notificationHandler);
      }
    }
  }
  Future<dynamic> _notificationHandler(Map<String, dynamic> message) async {
    try{
      r.Room? room = await ChatConnection.roomList();
      r.Rooms? rooms = room?.rooms?.firstWhere((element) => element.sId == message['room']['_id']);
      Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => ChatScreen(data: rooms!)),);
      try{
        ChatConnection.refreshRoom.call();
        ChatConnection.refreshContact.call();
        ChatConnection.refreshFavorites.call();
      }catch(_){}
    }catch(_){}
  }
  @override
  Widget build(BuildContext context) {
    r.People info = getPeople(widget.data.people);
    bool f = isFavorite(widget.data.people,widget.data.sId);
    return WillPopScope(
      onWillPop: () async {
        ChatConnection.roomId = null;
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              icon: Icon(
                f ? Icons.star : Icons.star_border,
                color: const Color(0xFFE5B80B),
              ),
              onPressed: () async {
                bool result = await ChatConnection.toggleFavorites(widget.data.sId);
                if(result) {
                  setState(() {
                    toggleFavorite(widget.data.people,widget.data.sId);
                  });
                }
              },
            )
          ],
          title: SizedBox(
            height: !widget.data.isGroup! ?25.0 : 50.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(child: AutoSizeText(!widget.data.isGroup! ?
                '${info.firstName} ${info.lastName}' : widget.data.title ??
                    'Group with ${info.firstName} ${info.lastName}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),)),
                if (widget.data.isGroup!) Padding(
                  padding: const EdgeInsets.only(bottom: 3.0),
                  child: AutoSizeText('${widget.data.people!.length-1} members',
                    style: const TextStyle(color: Colors.black,fontSize: 15),),
                )
              ],
            ),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),),
        body: SafeArea(
          bottom: false,
          child: Chat(
            messages: _messages,
            showUserAvatars: true,
            showUserNames: true,
            onAttachmentPressed: _handleAttachmentPressed,
            onMessageTap: _handleMessageTap,
            onPreviewDataFetched: _handlePreviewDataFetched,
            onSendPressed: _handleSendPressed,
            user: _user,
          ),
        ),
      ),
    );
  }
  r.People getPeople(List<r.People>? people) {
    return people!.first.sId != ChatConnection.user!.id ? people.first : people.last;
  }
  bool isFavorite(List<r.People>? people, String? roomId) {
    try{
      r.People? p = people?.firstWhere((element) => element.sId == ChatConnection.user!.id);
      if(p!.favorites!.contains(roomId)) {
        return true;
      }
      else {
        return false;
      }
    }catch(_){
      return false;
    }
  }
  toggleFavorite(List<r.People>? people, String? roomId) {
    try{
      r.People? p = people?.firstWhere((element) => element.sId == ChatConnection.user!.id);
      if(p!.favorites!.contains(roomId)) {
        p.favorites!.remove(roomId);
      }
      else {
        p.favorites ??= [];
        p.favorites!.add(roomId!);
      }
      try{
        ChatConnection.refreshRoom.call();
        ChatConnection.refreshFavorites.call();
      }catch(_){}
    }catch(_){
    }
  }
}
