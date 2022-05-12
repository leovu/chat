import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_screen/chat_group_members_screen.dart';
import 'package:chat/chat_screen/conversation_file_screen.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/room.dart' as r;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
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
          title: AutoSizeText(AppLocalizations.text(LangKey.conversationInformation),
              style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 16),
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
                _section(const Icon(Icons.folder,color: Color(0xff5686E1),size: 35,),AppLocalizations.text(LangKey.file),() {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ConversationFileScreen(roomData: widget.roomData,chatMessage: widget.chatMessage,)));
                }),
                if(widget.roomData.isGroup!) Padding(padding:
                const EdgeInsets.only(left: 50.0, right: 50.0,top: 13.0),child:
                  Container(height: 1.0,color: const Color(0xFFE5E5E5),),),
                if(widget.roomData.isGroup!)
                  _section(const Icon(Icons.group,color: Color(0xff5686E1),size: 35,),AppLocalizations.text(LangKey.viewMembers),() {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => ChatGroupMembersScreen(roomData: widget.roomData)));
                  }),
                if(widget.roomData.isGroup!) Padding(padding:
                const EdgeInsets.only(left: 50.0, right: 50.0,top: 13.0),child:
                Container(height: 1.0,color: const Color(0xFFE5E5E5),),),
                if(widget.roomData.isGroup!) _section(const Icon(Icons.remove_circle,color: Color(0xff5686E1),size: 35,),
                    AppLocalizations.text(LangKey.leaveConversation),() {
                  _leaveRoom(widget.roomData.sId!);
                },textColor: Colors.black),
                if(!widget.roomData.isGroup! ||
                    (widget.roomData.owner == ChatConnection.user!.id &&
                        widget.roomData.isGroup!))Padding(padding:
                    const EdgeInsets.only(left: 50.0, right: 50.0,top: 13.0),child:
                    Container(height: 1.0,color: const Color(0xFFE5E5E5),),),
                  if(!widget.roomData.isGroup! ||
                      (widget.roomData.owner == ChatConnection.user!.id &&
                          widget.roomData.isGroup!))
                    _section(const Icon(Icons.delete,color: Colors.red,size: 35,),
                        AppLocalizations.text(LangKey.deleteConversation),() {
                      _removeRoom(widget.roomData.sId!);
                },textColor: Colors.red)
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
                  Navigator.of(context).popUntil((route) => route.settings.name == "chat_screen");
                  Navigator.of(context).pop();
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
                    Navigator.of(context).popUntil((route) => route.settings.name == "chat_screen");
                    Navigator.of(context).pop();
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
}