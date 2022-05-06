import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/chat_screen/group_image_item.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/room.dart' as r;

class BySenderResultScreen extends StatefulWidget {
  final c.ChatMessage? chatMessage;
  final r.Rooms roomData;
  final String? search;
  const BySenderResultScreen({Key? key, required this.roomData, required this.chatMessage, this.search}) : super(key: key);
  @override
  _State createState() => _State();
}

class _State extends State<BySenderResultScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget totalText(){
    List<r.People?>? senders = widget.roomData.people?.map((e) {
      try{
        if(widget.search != '' && widget.search != null) {
          var tmp = widget.chatMessage?.room?.images?.firstWhere((element) => element.author?.sId == e.sId && '${e.firstName} ${e.lastName}'.toLowerCase().contains(widget.search!.toLowerCase()));
          if(tmp != null) {
            return e;
          }
        }
        else {
          var tmp = widget.chatMessage?.room?.images?.firstWhere((element) => element.author?.sId == e.sId);
          if(tmp != null) {
            return e;
          }
        }
      }catch(_){}
    }).toList();
    senders?.remove(null);
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 8.0),
      child: Center(
        child: Text(
            (senders?.length ?? 0) > 1 ? '${senders!.length} ${AppLocalizations.text(LangKey.senders)}' : '${senders?.length ?? 0} ${AppLocalizations.text(LangKey.sender)}',
            style: TextStyle(fontSize: 15.0, color: Colors.grey.shade600, fontWeight: FontWeight.w500)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          AppLocalizations.text(LangKey.bySenders),
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: InkWell(
          child: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
              color: Colors.black),
          onTap: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: Wrap(
                children: _list(),
              ),
            ),
            totalText()
          ],
        ),
      ),
    );
  }
  List<Widget> _list() {
    List<r.People?>? listPeople = widget.roomData.people;
    List<c.Images>? listImages = widget.chatMessage?.room?.images;
    if(widget.search != '' && widget.search != null) {
      listPeople = widget.roomData.people?.map((e) {
        if('${e.firstName} ${e.lastName}'.toLowerCase().contains(widget.search!.toLowerCase())){
          var tmp = widget.chatMessage?.room?.images?.firstWhere((element) => element.author?.sId == e.sId);
          if(tmp != null) {
            return e;
          }
        }
      }).toList();
      listPeople?.remove(null);
    }
    List<GroupImageItem>? widgets = listPeople?.map((e) =>  GroupImageItem(people: e!,images:
    listImages?.where((element) => element.author?.sId == e.sId).toList()
      ,)).toList();
    return widgets ?? [];
  }
}
