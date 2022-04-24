import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_screen/chat_group_members_screen.dart';
import 'package:chat/chat_screen/conversation_file_screen.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/room.dart' as r;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ConversationInformationScreen extends StatefulWidget {
  final r.Rooms roomData;
  final c.ChatMessage? chatMessage;
  const ConversationInformationScreen({Key? key, required this.roomData, this.chatMessage}) : super(key: key);
  @override
  _ConversationInformationScreenState createState() => _ConversationInformationScreenState();
}

class _ConversationInformationScreenState extends State<ConversationInformationScreen> {
  @override
  Widget build(BuildContext context) {
    r.People info = getPeople(widget.roomData.people);
    return Scaffold(
      appBar: AppBar(
          title: const AutoSizeText('Conversation information',
              style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),
          ),
          leading: InkWell(
            child: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.black),
            onTap: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),),
      body: SafeArea(child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 17.0),
            child: Center(child:
            !widget.roomData.isGroup! ? info.picture == null ? CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.125,
              child: Text(
                  info.getAvatarName(),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 1,
                  textScaleFactor: 1.75),
            ) : CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.125,
              backgroundImage:
              CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${info.picture!.shieldedID}/256'),
              backgroundColor: Colors.transparent,
            ) : widget.roomData.picture == null ? CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.125,
              child: Text(
                  widget.roomData.getAvatarGroupName(),
                  maxLines: 1,
                  style: const TextStyle(color: Colors.white),
                  textScaleFactor: 1.75),
            ) : CircleAvatar(
              radius: MediaQuery.of(context).size.width * 0.125,
              backgroundImage:
              CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${widget.roomData.picture!.shieldedID}/256'),
              backgroundColor: Colors.transparent,
            )),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              height: 1.0,
              color: const Color(0xFFE5E5E5),
            ),
          ),
          Expanded(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              children: [
                _section(const Icon(Icons.folder,color: Color(0xff5686E1),size: 35,),'File',() {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ConversationFileScreen(roomData: widget.roomData,chatMessage: widget.chatMessage,)));
                }),
                if(widget.roomData.isGroup!) Padding(padding:
                const EdgeInsets.only(left: 50.0, right: 50.0,top: 13.0),child:
                  Container(height: 1.0,color: const Color(0xFFE5E5E5),),),
                if(widget.roomData.isGroup!)
                  _section(const Icon(Icons.group,color: Color(0xff5686E1),size: 35,),'View members',() {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ChatGroupMembersScreen(roomData: widget.roomData)));
                  }),
                // if(!widget.roomData.isGroup!)
                  Padding(padding:
                const EdgeInsets.only(left: 50.0, right: 50.0,top: 13.0),child:
                Container(height: 1.0,color: const Color(0xFFE5E5E5),),),
                // if(!widget.roomData.isGroup!)
                  _section(const Icon(Icons.delete,color: Colors.red,size: 35,),'Delete the conversation',() {
                    _removeRoom(widget.roomData.sId!);
                  },textColor: Colors.red),
              ],
            ),
          )
        ],
      ),),
    );
  }
  r.People getPeople(List<r.People>? people) {
    return people!.first.sId != ChatConnection.user!.id ? people.first : people.last;
  }
  Widget _section(Icon icon, String name, Function function, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: InkWell(
        onTap: () {
          function();
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 23.0,right: 10),
              child: icon,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: AutoSizeText(name,maxLines: 1,textScaleFactor: 1.2,style: TextStyle(
                  color: textColor ?? Colors.black
                ),),
              ),
            ),
            if(textColor == null)const Padding(
              padding: EdgeInsets.only(left: 5.0,right: 23.0),
              child: Icon(Icons.navigate_next_outlined,color: Color(0xFFE5E5E5),),
            ),
          ],
        ),
      ),
    );
  }
  void _removeRoom(String roomId) {
    showDialog(
      context: context,
      builder: (cxt) => AlertDialog(
        title: const Text('Delete the conversation'),
        content: const Text('Are you sure you want to delete this conversation?'),
        actions: [
          ElevatedButton(
              onPressed: () {
                ChatConnection.removeRoom(roomId).then((value) {
                  Navigator.of(cxt).pop();
                  if (value) {
                    Navigator.of(context).popUntil((route) => route.settings.name == "chat_screen");
                    Navigator.of(context).pop();
                  }
                  else {
                    showDialog(
                      context: context,
                      builder: (cxxt) => AlertDialog(
                        title: const Text('Warning'),
                        content: const Text('Get file error!'),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(cxxt);
                              },
                              child: const Text('Accept'))
                        ],
                      ),
                    );
                  }
                });
              },
              child: const Text('Delete')),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel')),
        ],
      ),
    );
  }
}