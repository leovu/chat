import 'dart:io';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_screen/add_member_group_screen.dart';
import 'package:chat/chat_screen/chat_screen.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/room.dart' as r;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ChatGroupMembersScreen extends StatefulWidget {
  final r.Rooms roomData;
  const ChatGroupMembersScreen({Key? key, required this.roomData}) : super(key: key);
  @override
  _ChatGroupMembersScreenState createState() => _ChatGroupMembersScreenState();
}

class _ChatGroupMembersScreenState extends State<ChatGroupMembersScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: const AutoSizeText(
            'Members',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          leading: InkWell(
            child: Icon(
                Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                color: Colors.black),
            onTap: () => Navigator.of(context).pop(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(width:30.0,height: 30.0,
                  child: InkWell(onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder:  (context) => AddMemberGroupScreen(roomData: widget.roomData,)));
                    setState(() {});
                  },
                    child: Image.asset('assets/icon-edit.png',package: 'chat',),)),
            )
          ],
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left:15.0,top: 10.0,bottom: 10.0),
                child: Text('List of members (${widget.roomData.people?.length})',style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15
                ),),
              ),
              Expanded(child: ListView.builder(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.only(top: 5.0),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                itemBuilder: _itemBuilder,
                itemCount: widget.roomData.people?.length,),)
            ],
          )
        ));
  }
  void sendMessage(r.People people) async {
    r.Room? roomListData = await ChatConnection.roomList();
    r.Rooms? val;
    if(roomListData?.rooms != null) {
      for (var value in roomListData!.rooms!) {
        if(!value.isGroup!) {
          r.People? result = value.people?.firstWhere((e) => e.sId == people.sId);
          if(result != null) {
            val = value;
            break;
          }
        }
      }
    }
    if(val != null) {
      Navigator.of(context).popUntil((route) => route.settings.name == "chat_screen");
      Navigator.of(context,rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (context) => ChatScreen(data: val!),settings:const RouteSettings(name: 'chat_screen')),);
    }
  }
  void removeMember(r.People people) async {
    bool value = await ChatConnection.leaveRoom(widget.roomData.sId!,people.sId);
    if(value) {
      widget.roomData.people?.remove(people);
      setState(() {});
    }
  }
  Widget _itemBuilder(BuildContext context, int index) {
    final data = widget.roomData.people![index];
    bool isLast = index == (widget.roomData.people?.length ?? 1)-1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              if(data.sId != ChatConnection.user!.id) {
                showModalActionSheet<String>(
                  context: context,
                  actions: [
                    const SheetAction(
                      icon: Icons.chat,
                      label: 'Send message',
                      key: 'Chat',
                    ),
                    if(widget.roomData.owner == ChatConnection.user!.id &&
                        widget.roomData.isGroup!) const SheetAction(
                      icon: Icons.delete,
                      label: 'Remove from group',
                      key: 'Delete',
                    ),
                    if(Platform.isAndroid) const SheetAction(
                        icon: Icons.cancel,
                        label: 'Cancel',
                        key: 'Cancel',
                        isDestructiveAction: true),
                  ],
                ).then((value) {
                  if(value == 'Chat') {
                    sendMessage(data);
                  }
                  else if(value == 'Delete') {
                    removeMember(data);
                  }
                  else {

                  }
                });
              }
            },
            child: SizedBox(
              height: 50.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    data.picture == null ? CircleAvatar(
                      radius: 25.0,
                      child: Text(data.getAvatarName()),
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
                            child: AutoSizeText('${data.firstName} ${data.lastName}'),
                          ),
                          Container(height: 5.0,),
                          Expanded(child: AutoSizeText('@${data.username}',
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
          ) : Container(),
        ],
      ),
    );
  }
}
