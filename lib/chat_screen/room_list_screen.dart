import 'dart:io';
import 'package:chat/chat_screen/home_screen.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/chat_screen/chat_screen.dart';
import 'package:chat/data_model/room.dart';
import 'package:chat/connection/http_connection.dart';
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

  @override
  void initState() {
    super.initState();
    _getRooms();
  }
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    await _getRooms();
    _refreshController.loadComplete();
  }
  _getRooms() async {
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      roomListData = await ChatConnection.roomList();
      _getRoomVisible();
      setState(() {});
    });
  }

  _getRoomVisible() {
    String val = _controllerSearch.value.text.toLowerCase();
    if(val != '') {
      roomListVisible!.rooms = roomListVisible!.rooms!.where((element) {
        try {
          People p = element.people!.firstWhere((e) => e.sId != ChatConnection.user!.id);
          if(!element.isGroup! ?
          ('${p.firstName} ${p.lastName}'.toLowerCase()).contains(val) : element.title!.toLowerCase().contains(val)) {
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
      roomListVisible?.rooms = <Rooms>[...roomListData!.rooms!.toList()];
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    widget.builder.call(context, _getRooms);
    return roomListVisible != null ?
      GestureDetector(
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
                              Navigator.of(context).pop();
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
                        const Padding(
                          padding: EdgeInsets.only(bottom: 3.0,left: 10.0,right: 10.0),
                          child: Text('Chats',style: TextStyle(fontSize: 25.0,color: Colors.black)),
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
                                child: const Icon(Icons.edit,size: 25.0,color: Colors.grey,),)),
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
                              decoration: const InputDecoration.collapsed(
                                hintText: 'Search Chats',
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
                                  _getRoomVisible();
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
                  child: SmartRefresher(
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
                                    MaterialPageRoute(builder: (context) => ChatScreen(data: roomListVisible!.rooms![position])),
                                  );
                                  _getRooms();
                                },
                                child: Slidable(
                                    endActionPane: ActionPane(
                                      motion: const StretchMotion(),
                                      children: [
                                        SlidableAction(
                                          onPressed: (cxt) {
                                            showModalActionSheet<String>(
                                              context: context,
                                              actions: [
                                                const SheetAction(
                                                  icon: Icons.remove_circle,
                                                  label: 'Delete',
                                                  key: 'Delete',
                                                ),
                                                if(Platform.isAndroid) const SheetAction(
                                                    icon: Icons.cancel,
                                                    label: 'Cancel',
                                                    key: 'Cancel',
                                                    isDestructiveAction: true)
                                              ],
                                            ).then((value) => value == 'Delete'
                                                ? _removeRoom(roomListVisible!.rooms![position].sId!)
                                                : (){});
                                          },
                                          autoClose: true,
                                          backgroundColor: const Color(0xFFFE4A49),
                                          foregroundColor: Colors.white,
                                          icon: Icons.delete,
                                          label: 'Delete',
                                        ),
                                      ],
                                    ),
                                    child: _room(roomListVisible!.rooms![position], position == roomListVisible!.rooms!.length-1))),
                          );
                        }),
                  ),
                )
              ],),
            ),
        ),
      ) : Container();
  }
  void _removeRoom(String roomId) {
    ChatConnection.removeRoom(roomId).then((value) {
      if (value) {
        _getRooms();
      }
    });
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
                  info.picture == null ? CircleAvatar(
                    radius: 25.0,
                    child: Text(info.getAvatarName()),
                  ) : CircleAvatar(
                    radius: 25.0,
                    backgroundImage:
                    CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${info.picture!.shieldedID}/256'),
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
                              '${info.firstName} ${info.lastName}' : data.title ?? 'Group ${info.firstName} ${info.lastName}',overflow: TextOverflow.ellipsis),),
                              AutoSizeText(data.lastMessage?.lastMessageDate() ?? '',style: const TextStyle(fontSize: 11,color: Colors.grey),)
                            ],
                          )
                        ),
                        Container(height: 5.0,),
                        Expanded(child: AutoSizeText(
                          author != null ?
                          '$author: ${(data.lastMessage?.type == 'image' ? 'Sent a picture' :data.lastMessage?.type == 'file' ? 'Sent a file' :data.lastMessage?.content ?? '')}'
                          : '',
                          overflow: TextOverflow.ellipsis,))
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
  People getPeople(List<People>? people) {
    return people!.first.sId != ChatConnection.user!.id ? people.first : people.last;
  }
  String? findAuthor(List<People>? people, String? author) {
    People? p;
    try {
      p = people?.firstWhere((element) => element.sId == author);
      return p!.sId != ChatConnection.user!.id ? p.firstName : 'You';
    }catch(_){
      return null;
    }
  }
  @override
  bool get wantKeepAlive => true;
}