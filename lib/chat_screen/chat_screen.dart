import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_screen/conversation_information_screen.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/room.dart' as r;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:chat/chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:uuid/uuid.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/connection/app_lifecycle.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

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
  bool _isSearchMessage = false;
  final _focusSearch = FocusNode();
  final _controllerSearch = TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  List<int> _listIdSearch = [];
  int currentIndexSearch = 0;
  Map<String,int> listIdMessages = {};
  final ChatController chatController = ChatController();
  @override
  void initState() {
    super.initState();
    _loadMessages();
    ChatConnection.listenChat(_refreshMessage);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    itemPositionsListener.itemPositions.removeListener(() {});
    ChatConnection.isLoadMore = false;
    ChatConnection.roomId = null;
  }

  void _addMessage(types.Message message, String id,{String? text, String? repliedMessageId}) async {
    if(mounted) {
      setState(() {
        _messages.insert(0, message);
      });
    }
    if(message.type.name == 'text') {
      await ChatConnection.sendChat(data,_messages,id,text,data?.room,ChatConnection.user!.id,reppliedMessageId: repliedMessageId);
      if(mounted) {
        setState(() {});
      }
    }
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
        _addMessage(message,id);
        ChatConnection.uploadFile(data,_messages,id,file,data?.room,ChatConnection.user!.id).then((r) {
          if(mounted) {
            setState(() {
              int index = _messages.indexWhere((element) => element.id==id);
              Status s = !r ? Status.error : Status.sent;
              _messages[index] = types.FileMessage(
                author: _user,
                createdAt: DateTime.now().millisecondsSinceEpoch,
                id: id,
                mimeType: lookupMimeType(result.files.single.path!),
                name: result.files.single.name,
                size: result.files.single.size,
                uri: result.files.single.path!,
                showStatus: true,
                status: s,
              );
            });
          }
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
  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
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
      _addMessage(message,id);
      ChatConnection.uploadImage(data,_messages,id,result,data?.room,ChatConnection.user!.id).then((r) {
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
        if(mounted) {
          setState(() {});
        }
      });
    }
  }

  void _handleCameraSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
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
      _addMessage(message,id);
      ChatConnection.uploadImage(data,_messages,id,result,data?.room,ChatConnection.user!.id).then((r) {
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
        if(mounted) {
          setState(() {});
        }
      });
    }
  }

  void _handleMessageTap(BuildContext context, types.Message message) async {
    if (message is types.FileMessage) {
      await OpenFile.open(message.uri);
    }
  }

  void _handleMessageLongPress(BuildContext context, types.Message message) async {
    if(message is types.TextMessage || message is types.ImageMessage) {
      if(message is types.TextMessage && message.text == 'Message recalled') {
        return;
      }
      c.Messages? mess = data?.room?.messages?.firstWhere((e) => e.sId == message.id);
      showModalActionSheet<String>(
        context: context,
        actions: [
          const SheetAction(
            icon: Icons.reply,
            label: 'Reply',
            key: 'Reply',
          ),
          const SheetAction(
            icon: Icons.reply,
            label: 'Forward',
            key: 'Forward',
          ),
          if(mess?.author?.sId == ChatConnection.user?.id) const SheetAction(
            icon: Icons.replay_30_outlined,
            label: 'Recall',
            key: 'Recall',
          ),
          const SheetAction(
            icon: Icons.replay_30_outlined,
            label: 'Pin Message',
            key: 'Pin Message',
          ),
          if(Platform.isAndroid) const SheetAction(
              icon: Icons.cancel,
              label: 'Cancel',
              key: 'Cancel',
              isDestructiveAction: true),
        ],
      ).then((value) => value == 'Reply'
          ? chatController.reply(message)
          : value == 'Recall'
          ? recall(message,mess)
          : value == 'Pin Message'
          ? pinMesage(message,mess)
          : value == 'Forward'
          ? {}
          : {});
    }
  }

  void pinMesage(types.Message message, c.Messages? value) async {
    bool result = await ChatConnection.pinMessage(value!.sId, data?.room);
    if(result) {
      setState(() {
        data?.room?.pinMessage = c.PinMessage.fromJson(value.toJson());
      });
    }
  }

  void recall(types.Message message, c.Messages? value) async {
    bool result = await ChatConnection.recall(value, data?.room);
    if(result) {
      setState(() {
        if(message is types.ImageMessage) {
          data?.room?.messages?.remove(value);
          _messages.remove(message);
        }
        else if(message is types.TextMessage) {
          value?.content = 'Message recalled recalled';
          int index = _messages.indexOf(message);
          final textMessage = types.TextMessage(
              author: _user,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: message.id,
              text: 'Message recalled recalled'
          );
          _messages[index] = textMessage;
        }
      });
    }
  }

  void forwward() {

  }

  void _handlePreviewDataFetched(
      types.TextMessage message,
      types.PreviewData previewData,
      ) {
    final index = _messages.indexWhere((element) => element.id == message.id);
    final updatedMessage = _messages[index].copyWith(previewData: previewData);

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      if(mounted) {
        setState(() {
          _messages[index] = updatedMessage;
        });
      }
    });
  }

  void _handleSendPressed(types.PartialText message, {types.Message? repliedMessage}) {
    String id = const Uuid().v4();
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: id,
      text: message.text,
      repliedMessage: repliedMessage
    );
    _addMessage(textMessage,id,text: message.text, repliedMessageId: repliedMessage?.id);
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
          if(mounted) {
            setState(() {
              _messages = values;
            });
          }
        }
      }
      if(mounted) {
        setState(() {});
      }
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
          if(mounted) {
            setState(() {
              _messages = values;
            });
          }
        }
      }
      if(mounted) {
        setState(() {});
      }
      Map<String,dynamic> notificationData = json.decode(json.encode(cData)) as Map<String, dynamic>;
      if(ChatConnection.roomId != null && ChatConnection.roomId != notificationData['room']['_id']) {
        ChatConnection.showNotification(
            notificationData['room']['isGroup'] == true ?
            '${notificationData['room']['title']}'
            : '${notificationData['message']['author']['firstName']} ${notificationData['message']['author']['lastName']}',
            notificationData['message']['content'],
            notificationData, ChatConnection.appIcon, _notificationHandler);
      }
    }
  }
  Future<dynamic> _notificationHandler(Map<String, dynamic> message) async {
    try{
      r.Room? room = await ChatConnection.roomList();
      r.Rooms? rooms = room?.rooms?.firstWhere((element) => element.sId == message['room']['_id']);
      Navigator.of(context).popUntil((route) => route.settings.name == "chat_screen");
      Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => ChatScreen(data: rooms!),settings:const RouteSettings(name: 'chat_screen')),);
      try{
        ChatConnection.refreshRoom.call();
        ChatConnection.refreshContact.call();
        ChatConnection.refreshFavorites.call();
      }catch(_){}
    }catch(_){}
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ChatConnection.roomId = null;
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        appBar: !_isSearchMessage ? _defaultAppbar() : _searchAppBar(),
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if(data?.room?.pinMessage != null)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 15.0),
                  child:
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.chat_outlined,color: Color(0xff5686E1),),
                      ),
                      Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText('${data?.room?.pinMessage?.author?.firstName} ${data?.room?.pinMessage?.author?.lastName}',
                            style: const TextStyle(fontWeight: FontWeight.w600,color: Color(0xff5686E1)),),
                          data?.room?.pinMessage?.type == 'image'
                              ? SizedBox(
                            height: MediaQuery.of(context).size.width*0.15,
                            width: MediaQuery.of(context).size.width*0.15,
                            child: Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                              imageUrl: '${HTTPConnection.domain}api/images/${data?.room?.pinMessage?.content}/256',
                              placeholder: (context, url) => const CupertinoActivityIndicator(),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                            ),)
                         : AutoSizeText('${data?.room?.pinMessage?.content}',style: TextStyle(color: Colors.grey.shade400),),
                        ],
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
                            await ChatConnection.pinMessage(null,data?.room);
                          },
                          padding: EdgeInsets.zero,
                        ),
                      )
                    ],
                  )
                ),
              if(data?.room?.pinMessage != null) Container(height: 2.0,color: Colors.grey.shade300,),
              Expanded(child: Chat(
                messages: _messages,
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
                focusSearch: (){
                  _focusSearch.requestFocus();
                },
                loadMore: loadMore,
              )),
              _resultSearchChat()
            ],
          ),
        ),
      ),
    );
  }
  void loadMore() async {
    List<c.Messages>? value = await ChatConnection.loadMoreMessageRoom(ChatConnection.roomId!,_messages.last.id);
    if(value != null) {
      List<c.Messages>? messages = value;
      if(messages.isNotEmpty) {
        final values = (messages)
            .map((e) => types.Message.fromJson(e.toMessageJson()))
            .toList();
        if(mounted) {
          setState(() {
            _messages.addAll(values);
            Future.delayed(const Duration(seconds: 2)).then((value) => ChatConnection.isLoadMore = false);
          });
        }
      }
      else {
        ChatConnection.isLoadMore = false;
      }
    }
    else {
      ChatConnection.isLoadMore = false;
    }
  }
  Widget _resultSearchChat() {
    return Visibility(
        visible: _isSearchMessage,
        child: Container(
          color: Colors.grey.shade200,
          child: Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(bottom:15.0,left: 10.0,right: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        if(_listIdSearch.isNotEmpty && currentIndexSearch > 0) {
                          currentIndexSearch -= 1;
                          scroll(_listIdSearch[currentIndexSearch]);
                          setState(() {});
                        }
                      },
                      child: SizedBox(
                          width: 30.0,
                          child: Icon(Icons.arrow_drop_down,
                              color: currentIndexSearch > 0 ? const Color(0xFF787878) : const Color(0xFF787878).withAlpha(60))),
                    ),
                    InkWell(
                      onTap: () {
                        if(_listIdSearch.isNotEmpty && currentIndexSearch < _listIdSearch.length-1) {
                          currentIndexSearch += 1;
                          scroll(_listIdSearch[currentIndexSearch]);
                          setState(() {});
                        }
                      },
                      child: SizedBox(
                          width: 30.0,child: Icon(Icons.arrow_drop_up,
                        color: currentIndexSearch < _listIdSearch.length-1 ? const Color(0xFF787878) : const Color(0xFF787878).withAlpha(60))),
                    ),
                    Expanded(child: Container(),),
                    AutoSizeText('${_listIdSearch.isEmpty ? 0 : currentIndexSearch+1}/${_listIdSearch.length} results'),
                    Expanded(child: Container(),),
                    const SizedBox(
                      width: 30.0,),
                    const SizedBox(
                      width: 30.0,)
                  ],
                ),
              ),
            ),
          ),
        )
    );
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
              }, child: const Text('Cancel',style: TextStyle(color: Color(0xFF787878)),),
            ),
          ),
        ],
      backgroundColor: Colors.white,
      title: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
            color: const Color(0xFFE7EAEF), borderRadius: BorderRadius.circular(5)),
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
            Expanded(child: TextField(
              focusNode: _focusSearch,
              controller: _controllerSearch,
              onChanged: (_) {
                if(mounted) {
                  searchChat();
                  if(_listIdSearch.isNotEmpty) {
                    scroll(_listIdSearch.first);
                  }
                  setState(() {});
                }
                else {
                  WidgetsBinding.instance?.addPostFrameCallback((_) {
                    searchChat();
                    if(_listIdSearch.isNotEmpty) {
                      scroll(_listIdSearch.first);
                      setState(() {});
                    }
                  });
                }
              },
              decoration: const InputDecoration.collapsed(
                hintText: 'Find in chat',
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
                onTap: (){
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
        leadingWidth: 0
    );
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
    try{
      if(data != null) {
        _messages.asMap().forEach((index, element) {
          if(element.type == types.MessageType.text) {
            String id = element.id;
            var message = element as types.TextMessage;
            List<String> contents = message.text.toLowerCase().split(' ');
            if(contents.contains(_controllerSearch.value.text.toLowerCase())) {
              int? index = listIdMessages[id];
              if(index != null) {
                _listIdSearch.add(index);
              }
            }
          }
        });
        if(_listIdSearch.isNotEmpty) {
          _listIdSearch.sort();
        }
      }
    }catch(_) {}
  }
  AppBar _defaultAppbar() {
    r.People info = getPeople(widget.data.people);
    bool f = isFavorite(widget.data.people,widget.data.sId);
    return AppBar(
        actions: <Widget>[
          IconButton(
            visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
            padding: EdgeInsets.zero,
            icon: Icon(
              f ? Icons.star : Icons.star_border,
              color: const Color(0xFFE5B80B),
            ),
            onPressed: () async {
              bool result = await ChatConnection.toggleFavorites(widget.data.sId);
              if(result) {
                if(mounted) {
                  setState(() {
                    toggleFavorite(widget.data.people,widget.data.sId);
                  });
                }
              }
            },
          ),
          IconButton(
            visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.search,
              color: Color(0xFF787878),
            ),
            onPressed: () {
              setState(() {
                _isSearchMessage = !_isSearchMessage;
                if(_isSearchMessage) {
                  _focusSearch.requestFocus();
                }
              });
            },
          ),
          IconButton(
            visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.info,
              color: Color(0xFF787878),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ConversationInformationScreen(roomData: widget.data,chatMessage: data),
                  settings:const RouteSettings(name: 'conversation_information_screen')));
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
                  child: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.black),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              Padding(padding: const EdgeInsets.only(top: 10.0,bottom: 10.0),
                  child: !widget.data.isGroup! ? info.picture == null ? CircleAvatar(
                    radius: 15.0,
                    child: Text(
                        info.getAvatarName(),
                        style: const TextStyle(color: Colors.white),),
                  ) : CircleAvatar(
                    radius: 15.0,
                    backgroundImage:
                    CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${info.picture!.shieldedID}/256'),
                    backgroundColor: Colors.transparent,
                  ) : widget.data.picture == null ? CircleAvatar(
                    radius: 15.0,
                    child: Text(
                        widget.data.getAvatarGroupName(),
                        style: const TextStyle(color: Colors.white),),
                  ) : CircleAvatar(
                    radius: 15.0,
                    backgroundImage:
                    CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${widget.data.picture!.shieldedID}/256'),
                    backgroundColor: Colors.transparent,
                  )),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: SizedBox(
                    height: !widget.data.isGroup! ?25.0 : 50.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AutoSizeText(!widget.data.isGroup! ?
                          '${info.firstName} ${info.lastName}' : widget.data.title ??
                              'Group with ${info.firstName} ${info.lastName}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),),
                        ),
                        if (widget.data.isGroup!) Padding(
                          padding: const EdgeInsets.only(bottom: 3.0),
                          child: AutoSizeText('${widget.data.people!.length-1} members',
                            style: const TextStyle(color: Colors.black,fontSize: 12),),
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
