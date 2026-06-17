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
  final int tabbarIndex;
  const BySenderResultScreen({Key? key, required this.roomData, required this.chatMessage, this.search, required this.tabbarIndex}) : super(key: key);
  @override
  _State createState() => _State();
}

class _State extends State<BySenderResultScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _search = widget.search ?? '';
    _searchController = TextEditingController(text: _search);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
            color: const Color(0xFFE7EAEF),
            borderRadius: BorderRadius.circular(5)),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Center(child: Icon(Icons.search)),
            ),
            Expanded(
                child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _search = value;
                });
              },
              decoration: InputDecoration.collapsed(
                hintText: AppLocalizations.text(LangKey.bySender),
              ),
            )),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Center(child: Icon(Icons.close)),
                ),
                onTap: () {
                  _searchController.text = '';
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() {
                    _search = '';
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget totalText(){
    List<r.People?>? senders = widget.roomData.people?.map((e) {
      try{
        if(widget.tabbarIndex == 0) {
          if(_search != '') {
            var tmp = widget.chatMessage?.room?.images?.firstWhere((element) => element.author?.sId == e.sId && '${e.firstName} ${e.lastName}'.toLowerCase().contains(_search.toLowerCase()));
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
        }
        else if(widget.tabbarIndex == 1) {
          if(_search != '') {
            var tmp = widget.chatMessage?.room?.files?.firstWhere((element) => element.author?.sId == e.sId && '${e.firstName} ${e.lastName}'.toLowerCase().contains(_search.toLowerCase()));
            if(tmp != null) {
              return e;
            }
          }
          else {
            var tmp = widget.chatMessage?.room?.files?.firstWhere((element) => element.author?.sId == e.sId);
            if(tmp != null) {
              return e;
            }
          }
        }
        else {
          if(_search != '') {
            var tmp = widget.chatMessage?.room?.links?.firstWhere((element) => element.author?.sId == e.sId && '${e.firstName} ${e.lastName}'.toLowerCase().contains(_search.toLowerCase()));
            if(tmp != null) {
              return e;
            }
          }
          else {
            var tmp = widget.chatMessage?.room?.links?.firstWhere((element) => element.author?.sId == e.sId);
            if(tmp != null) {
              return e;
            }
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
            (senders?.length ?? 0) > 1 ?
            '${senders!.length} ${AppLocalizations.text(LangKey.senders)}' :
            '${senders?.length ?? 0} ${AppLocalizations.text(LangKey.sender)}',
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
          child: Icon(Icons.arrow_back_ios,
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
            _searchField(),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
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
            ),
          ],
        ),
      ),
    );
  }
  List<Widget> _list() {
    List<r.People?>? listPeople;
    List<c.Images>? listImages = widget.tabbarIndex == 0 ?
        widget.chatMessage?.room?.images : widget.tabbarIndex == 1 ?
    widget.chatMessage?.room?.files : widget.chatMessage?.room?.links;
    if(_search != '') {
      listPeople = [];
      for(var e in widget.roomData.people!) {
        if('${e.firstName} ${e.lastName}'.toLowerCase().contains(_search.toLowerCase())){
          listPeople.add(e);
        }
      }
    }
    else {
      listPeople = widget.roomData.people;
    }
    List<GroupImageItem>? widgets = listPeople?.map((e) =>  GroupImageItem(people: e!,
      tabbarIndex: widget.tabbarIndex,images:
    listImages?.where((element) => element.author?.sId == e.sId).toList()
      ,)).toList();
    return widgets ?? [];
  }
}
