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
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() { _search = v; }),
        decoration: InputDecoration(
          hintText: AppLocalizations.text(LangKey.search),
          prefixIcon: const Icon(Icons.search, size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  Widget totalText(){
    List<r.People?>? senders = widget.roomData.people?.map((e) {
      try{
        if(widget.tabbarIndex == 0) {
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
        }
        else if(widget.tabbarIndex == 1) {
          if(widget.search != '' && widget.search != null) {
            var tmp = widget.chatMessage?.room?.files?.firstWhere((element) => element.author?.sId == e.sId && '${e.firstName} ${e.lastName}'.toLowerCase().contains(widget.search!.toLowerCase()));
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
          if(widget.search != '' && widget.search != null) {
            var tmp = widget.chatMessage?.room?.links?.firstWhere((element) => element.author?.sId == e.sId && '${e.firstName} ${e.lastName}'.toLowerCase().contains(widget.search!.toLowerCase()));
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
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
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
                        children: _listFiltered(),
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
  List<Widget> _listFiltered() {
    final query = _search.isNotEmpty ? _search : (widget.search ?? '');
    List<r.People?>? listPeople;
    List<c.Images>? listImages = widget.tabbarIndex == 0
        ? widget.chatMessage?.room?.images
        : widget.tabbarIndex == 1
            ? widget.chatMessage?.room?.files
            : widget.chatMessage?.room?.links;
    if (query.isNotEmpty) {
      listPeople = widget.roomData.people?.where((e) {
        final name = '${e.firstName} ${e.lastName}'.toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    } else {
      listPeople = widget.roomData.people;
    }
    final widgets = listPeople?.map((e) => GroupImageItem(
          people: e!,
          tabbarIndex: widget.tabbarIndex,
          images: listImages?.where((el) => el.author?.sId == e.sId).toList(),
        )).toList();
    return widgets ?? [];
  }
}
