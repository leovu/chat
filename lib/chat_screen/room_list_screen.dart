import 'dart:io';
import 'package:chat/chat_screen/home_screen.dart';
import 'package:chat/chat_ui/vietnamese_text.dart';
import 'package:chat/chat_ui/widgets/chat_room_widget.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/chat_screen/chat_screen.dart';
import 'package:chat/data_model/room.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/draft.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

class RoomListScreen extends StatefulWidget {
  final RefreshBuilder builder;
  final Function? homeCallback;
  final Function? openCreateChatRoom;
  const RoomListScreen({Key? key, required this.builder, this.homeCallback , this.openCreateChatRoom}) : super(key: key);
  @override
  _RoomListScreenState createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> with AutomaticKeepAliveClientMixin {

  final _focusSearch = FocusNode();
  final _controllerSearch = TextEditingController();

  Room? roomListVisible;
  Room? roomListData;
  bool isInitScreen = true;

  @override
  void initState() {
    super.initState();
    _getRooms();
  }
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    await _getRooms();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    await _getRooms();
    _refreshController.loadComplete();
  }
  _getRooms() async {
    if(mounted) {
      roomListData = await ChatConnection.roomList();
      _getRoomVisible();
      isInitScreen = false;
      setState(() {});
    }
    else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        roomListData = await ChatConnection.roomList();
        _getRoomVisible();
        isInitScreen = false;
        setState(() {});
      });
    }
  }

  _getRoomVisible() {
    String val = _controllerSearch.value.text.toLowerCase().removeAccents();
    if(val != '') {
      roomListVisible!.rooms = roomListData!.rooms!.where((element) {
        try {
          People p = element.people!.firstWhere((e) => e.sId != ChatConnection.user!.id);
          if(!element.isGroup! ?
          ('${p.firstName} ${p.lastName}'.toLowerCase().removeAccents()).contains(val) : element.title!.toLowerCase().contains(val)) {
            return true;
          }
          return false;
        }catch(e){
          return false;
        }
      }).toList();
    }
    else {
      roomListVisible = Room();
      roomListVisible?.limit = roomListData?.limit;
      try{
        roomListVisible?.rooms = <Rooms>[...roomListData!.rooms!.toList()];
      }catch(_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    widget.builder.call(context, _getRooms);
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: SafeArea(
              child: Column(children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 30.0,
                      margin: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(ChatConnection.buildContext).pop();
                            },
                            child: SizedBox(
                                width:30.0,
                                child: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3.0,left: 10.0,right: 10.0),
                          child: Text(AppLocalizations.text(LangKey.chats),style: const TextStyle(fontSize: 25.0,color: Colors.black)),
                        ),
                        Expanded(child: Container()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: SizedBox(width:30.0,height: 30.0,
                              child: InkWell(onTap: () async {
                                if(widget.openCreateChatRoom != null){
                                  widget.openCreateChatRoom!();
                                }
                              },
                                child: Image.asset('assets/icon-edit.png',package: 'chat',),)),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
                      child: Container(
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
                                ),
                              ),
                            ),
                            Expanded(child: TextField(
                              focusNode: _focusSearch,
                              controller: _controllerSearch,
                              onChanged: (_) {
                                setState(() {
                                  _getRoomVisible();
                                });
                              },
                              decoration: InputDecoration.collapsed(
                                hintText: AppLocalizations.text(LangKey.searchChats),
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
                                    ),
                                  ),
                                ),
                                onTap: (){
                                  _controllerSearch.text = '';
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  setState(() {
                                    _getRoomVisible();
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child:
                  isInitScreen ? Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator()) :
                  roomListVisible?.rooms != null ? SmartRefresher(
                    enablePullDown: true,
                    enablePullUp: false,
                    controller: _refreshController,
                    onRefresh: _onRefresh,
                    onLoading: _onLoading,
                    header: const WaterDropHeader(),
                    child: ListView.builder(
                        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: roomListVisible!.rooms?.length,
                        itemBuilder: (BuildContext context, int position) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: InkWell(
                                onTap: () async {
                                  await Navigator.of(context,rootNavigator: true).push(
                                    MaterialPageRoute(builder: (context) => ChatScreen(data: roomListVisible!.rooms![position]),settings:const RouteSettings(name: 'chat_screen')),
                                  );
                                  setState(() {});
                                  _getRooms();
                                },
                                child: Slidable(
                                    endActionPane: ActionPane(
                                      motion: const StretchMotion(),
                                      children: [
                                        if(roomListVisible!.rooms![position].isGroup!) SlidableAction(
                                          onPressed: (cxt) {
                                            showModalActionSheet<String>(
                                              context: context,
                                              actions: [
                                                if (roomListVisible!.rooms![position].isGroup!)
                                                  SheetAction(
                                                  icon: Icons.remove_circle,
                                                  label: AppLocalizations.text(LangKey.leave),
                                                  key: 'Leave',
                                                ),
                                                if(Platform.isAndroid) SheetAction(
                                                    icon: Icons.cancel,
                                                    label: AppLocalizations.text(LangKey.cancel),
                                                    key: 'Cancel',
                                                    isDestructiveAction: true)
                                              ],
                                            ).then((value) => value == 'Leave'
                                                ? _leaveRoom(roomListVisible!.rooms![position].sId!)
                                                : (){});
                                          },
                                          autoClose: true,
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          icon: Icons.remove_circle,
                                          label: AppLocalizations.text(LangKey.leave),
                                        ),
                                        if(roomListVisible!.rooms![position].owner == ChatConnection.user!.id &&
                                                roomListVisible!.rooms![position].isGroup! || !roomListVisible!.rooms![position].isGroup!)
                                          SlidableAction(
                                          onPressed: (cxt) {
                                            showModalActionSheet<String>(
                                              context: context,
                                              actions: [
                                                if (!roomListVisible!.rooms![position].isGroup!) SheetAction(
                                                  icon: Icons.remove_circle,
                                                  label: AppLocalizations.text(LangKey.delete),
                                                  key: 'Leave',
                                                ),
                                                if (roomListVisible!.rooms![position].isGroup!
                                                    && roomListVisible!.rooms![position].owner == ChatConnection.user!.id)
                                                  SheetAction(
                                                    icon: Icons.remove_circle,
                                                    label: AppLocalizations.text(LangKey.delete),
                                                    key: 'Delete',
                                                  ),
                                                if(Platform.isAndroid) SheetAction(
                                                    icon: Icons.cancel,
                                                    label: AppLocalizations.text(LangKey.cancel),
                                                    key: 'Cancel',
                                                    isDestructiveAction: true)
                                              ],
                                            ).then((value) => value == 'Delete'
                                                ? _removeRoom(roomListVisible!.rooms![position].sId!)
                                                : value == 'Leave'
                                                ? _removeLeaveRoom(roomListVisible!.rooms![position].sId!)
                                                : (){});
                                          },
                                          autoClose: true,
                                          backgroundColor: const Color(0xFFFE4A49),
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: AppLocalizations.text(LangKey.delete),
                                        ),
                                      ],
                                    ),
                                    child: _room(roomListVisible!.rooms![position], position == roomListVisible!.rooms!.length-1))),
                          );
                        }),
                  ) : Container(),
                )
              ],),
            ),
        ),
      );
  }
  void _leaveRoom(String roomId) {
    showDialog(
      context: context,
      builder: (cxt) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.leaveConversation)),
        content: Text(AppLocalizations.text(LangKey.leaveConfirm)),
        actions: [
          ElevatedButton(
              onPressed: () async {
                bool value = await ChatConnection.leaveRoom(roomId,ChatConnection.user?.id);
                Navigator.of(cxt).pop();
                if (value) {
                  try {
                    ChatConnection.refreshRoom.call();
                    ChatConnection.refreshFavorites.call();
                  }catch(_){}
                  _getRooms();
                }
                else {
                  showDialog(
                    context: context,
                    builder: (cxxt) => AlertDialog(
                      title: Text(AppLocalizations.text(LangKey.warning)),
                      content: Text(AppLocalizations.text(LangKey.leaveError)),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(cxxt);
                            },
                            child: Text(AppLocalizations.text(LangKey.accept)))
                      ],
                    ),
                  );
                }
              },
              child: Text(AppLocalizations.text(LangKey.leave))),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(cxt);
              },
              child: Text(AppLocalizations.text(LangKey.cancel))),
        ],
      ),
    );
  }
  void _removeLeaveRoom(String roomId) {
    showDialog(
      context: context,
      builder: (cxt) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.deleteConversation)),
        content: Text(AppLocalizations.text(LangKey.deleteConfirm)),
        actions: [
          ElevatedButton(
              onPressed: () {
                ChatConnection.leaveRoom(roomId,ChatConnection.user?.id).then((value) {
                  Navigator.of(cxt).pop();
                  if (value) {
                    _getRooms();
                  }
                  else {
                    showDialog(
                      context: context,
                      builder: (cxxt) => AlertDialog(
                        title: Text(AppLocalizations.text(LangKey.warning)),
                        content: Text(AppLocalizations.text(LangKey.deleteError)),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(cxxt);
                              },
                              child: Text(AppLocalizations.text(LangKey.accept)))
                        ],
                      ),
                    );
                  }
                });
              },
              child: Text(AppLocalizations.text(LangKey.delete))),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(cxt);
              },
              child: Text(AppLocalizations.text(LangKey.cancel))),
        ],
      ),
    );
  }
  void _removeRoom(String roomId) {
    showDialog(
      context: context,
      builder: (cxt) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.deleteConversation)),
        content: Text(AppLocalizations.text(LangKey.deleteConfirm)),
        actions: [
          ElevatedButton(
              onPressed: () {
                ChatConnection.removeRoom(roomId).then((value) {
                  Navigator.of(cxt).pop();
                  if (value) {
                    _getRooms();
                  }
                  else {
                    showDialog(
                      context: context,
                      builder: (cxxt) => AlertDialog(
                        title: Text(AppLocalizations.text(LangKey.warning)),
                        content: Text(AppLocalizations.text(LangKey.deleteError)),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(cxxt);
                              },
                              child: Text(AppLocalizations.text(LangKey.accept)))
                        ],
                      ),
                    );
                  }
                });
              },
              child: Text(AppLocalizations.text(LangKey.delete))),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(cxt);
              },
              child: Text(AppLocalizations.text(LangKey.cancel))),
        ],
      ),
    );
  }
  Widget _room(Rooms data, bool isLast) {
    People info = getPeople(data.people);
    String? author = findAuthor(data.people,data.lastMessage?.author);
    return Column(
      children: [
        SizedBox(
          child: SizedBox(
            height: 50.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  !data.isGroup! ? info.picture == null ? CircleAvatar(
                    radius: 25.0,
                    child: Text(
                        info.getAvatarName(),
                        style: const TextStyle(color: Colors.white),),
                  ) : CircleAvatar(
                    radius: 25.0,
                    backgroundImage:
                    CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${info.picture!.shieldedID}/256'),
                    backgroundColor: Colors.transparent,
                  ) : data.picture == null ? CircleAvatar(
                    radius: 25.0,
                    child: Text(
                        data.getAvatarGroupName(),
                      style: const TextStyle(color: Colors.white),),
                  ) : CircleAvatar(
                    radius: 25.0,
                    backgroundImage:
                    CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${data.picture!.shieldedID}/256'),
                    backgroundColor: Colors.transparent,
                  ),
                  Expanded(child: Container(
                    padding: const EdgeInsets.only(top: 5.0,bottom: 5.0,left: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: AutoSizeText(!data.isGroup! ?
                              '${info.firstName} ${info.lastName}' : data.title ?? 'Group ${info.firstName} ${info.lastName}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: findUnread(data.messagesReceived) != '0' ? FontWeight.bold : FontWeight.normal),
                                ),
                              ),
                              AutoSizeText(data.lastMessage?.lastMessageDate() ?? data.createdDate(),style: const TextStyle(fontSize: 11,color: Colors.grey),),
                            ],
                          )
                        ),
                        Container(height: 5.0,),
                        Expanded(child:
                        Row(
                          children: [
                            Expanded(child:
                              FutureBuilder<String>(
                                future: draftMessage(data.sId!,'$author''${checkTag(_checkContent(data))}'),
                                builder:
                                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                                  if (snapshot.hasData) {
                                    final text = snapshot.data;
                                    return ChatRoomWidget(content: text ?? "");
                                  }return Container();
                                },
                              )),
                            if(findUnread(data.messagesReceived) != '0') CircleAvatar(
                              radius: 18.0,
                              child: Text(
                                findUnread(data.messagesReceived),
                                style: const TextStyle(color: Colors.white,fontSize: 12),),
                            )
                          ],
                        )),
                      ],
                    ),
                  ))
                ],
              ),
            ),
          ),
        ),
        !isLast ? Container(height: 5.0,) : Container(),
        !isLast ?  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(height: 1.0,color: Colors.grey.shade300,),
        ) : Container()
      ],
    );
  }
  Future<String> draftMessage(String roomId,String content) async {
    Map<String, dynamic>? draft = await getDraftInput(roomId);
    if (draft != null) {
      return '[${AppLocalizations.text(LangKey.draft)}] ${draft['text'] ?? ''}';
    } else {
      return content;
    }
  }
  String _checkContent(Rooms model) {
    if((model.messagesReceived?.length ?? 0) == 0){
      return (findAuthor(model.people,model.owner,isGroupOwner: true) ?? '') + AppLocalizations.text(LangKey.justCreatedRoom);
    }
    if(model.lastMessage?.type == 'image'){
      return AppLocalizations.text(LangKey.sentPicture);
    }

    if(model.lastMessage?.type == 'file'){
      return AppLocalizations.text(LangKey.sendFile);
    }

    if((model.lastMessage?.content ?? "").isEmpty) {
      return AppLocalizations.text(LangKey.forwardMessage);
    }
    return model.lastMessage!.content!;
  }

  String checkTag(String message) {
    List<String> contents = message.split(' ');
    String result = '';
    if(message.trim() == '') {
      return '';
    }
    for (int i = 0; i < contents.length; i++) {
      var element = contents[i];
      if(element == '@all-all@') {
        element = '@${AppLocalizations.text(LangKey.all)}';
      }
      try {
        if(element[element.length-1] == '@' && element.contains('-')) {
          element = element.split('-').first;
        }
      }catch(_){}
      result += '$element ';
    }
    return result.trim();
  }
  People getPeople(List<People>? people) {
    return people!.first.sId != ChatConnection.user!.id ? people.first : people.last;
  }
  String findUnread(List<MessagesReceived>? messagesRecived) {
    MessagesReceived? m;
    try {
      m = messagesRecived?.firstWhere((e) => e.people == ChatConnection.user!.id);
      if((m?.total ?? 0) > 99) {
        return '99+';
      }
      return '${m?.total ?? '0'}';
    }catch(_){
      return '0';
    }
  }
  String? findAuthor(List<People>? people, String? author,{bool isGroupOwner = false}) {
    People? p;
    try {
      p = people?.firstWhere((element) => element.sId == author);
      return (p!.sId != ChatConnection.user!.id ? ((p.firstName ?? '').trim() + ' ' + (p.lastName ?? '').trim()).trim() : AppLocalizations.text(LangKey.you)) + (isGroupOwner ? ' ' : ': ');
    }catch(_){
      return '';
    }
  }
  @override
  bool get wantKeepAlive => true;
}