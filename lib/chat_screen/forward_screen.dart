import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_ui/util.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:chat/data_model/room.dart';

class ForwardScreen extends StatefulWidget {
  final types.Message message;
  final c.Messages? value;
  const ForwardScreen({Key? key, required this.message, required this.value}) : super(key: key);
  @override
  ForwardScreenState createState() => ForwardScreenState();
}

class ForwardScreenState extends State<ForwardScreen> {
  final _controllerSearch = TextEditingController();
  final _focusSearch = FocusNode();
  final _controllerContent = TextEditingController();
  final _focusContent = FocusNode();
  Room? roomListVisible;
  Room? roomListData;
  bool _isSentCurrentChatRoom = false;
  List<String?> idSent = [];
  @override
  void initState() {
    super.initState();
    _getRooms();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      _focusContent.requestFocus();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _getRooms() async {
    if(mounted) {
      roomListData = await ChatConnection.roomList();
      _getRoomVisible();
      setState(() {});
    }
    else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        roomListData = await ChatConnection.roomList();
        _getRoomVisible();
        setState(() {});
      });
    }
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
      try{
        roomListVisible?.rooms = <Rooms>[...roomListData!.rooms!.toList()];
      }catch(_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: AutoSizeText(
              AppLocalizations.text(LangKey.forwardMessage),
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            leading: InkWell(
              child: Icon(
                  Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                  color: Colors.black),
              onTap: () => Navigator.of(context).pop(_isSentCurrentChatRoom),
            ),
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFFE7EAEF), borderRadius: BorderRadius.circular(5)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left:5.0,right: 5.0),
                              child: Icon(Icons.format_quote,color: Colors.black,size: 15.0,),
                            ),
                            Expanded(child: Padding(
                              padding: widget.message is types.TextMessage ?
                                const EdgeInsets.only(right: 10.0,bottom: 10.0,top: 10.0) :
                              widget.message is types.FileMessage ?
                                const EdgeInsets.only(right: 10.0,bottom: 10.0,top: 10.0,left: 10.0) :
                              const EdgeInsets.only(right: 10.0,bottom: 0.0,top: 0.0),
                              child:
                              widget.message is types.TextMessage ?
                                checkTag((widget.message as types.TextMessage).text) :
                              widget.message is types.ImageMessage ?
                                Row(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width*0.15,
                                      height: MediaQuery.of(context).size.width*0.25,
                                      child: CachedNetworkImage(
                                        imageUrl:
                                        '${(widget.message as types.ImageMessage).uri}/${ChatConnection.brandCode!}',
                                        httpHeaders: {'brand-code':ChatConnection.brandCode!},
                                        placeholder: (context, url) => const CupertinoActivityIndicator(),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Expanded(child: Container())
                                  ],
                                ) :
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(21),
                                    ),
                                    height: 42,
                                    width: 42,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/icon-document.png',
                                          color: Colors.grey,
                                          package: 'chat',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(
                                      margin: const EdgeInsetsDirectional.only(
                                        start: 16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (widget.message as types.FileMessage).name,
                                            textWidthBasis: TextWidthBasis.longestLine,
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              formatBytes((widget.message as types.FileMessage).size.truncate()),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),)
                          ],
                        ),
                        Container(height: 1.0,color: Colors.grey.shade500),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: SizedBox(
                            child: TextField(
                              focusNode: _focusContent,
                              controller: _controllerContent,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration.collapsed(
                                hintText: AppLocalizations.text(LangKey.inputMessageOptional),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
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
                            hintText: AppLocalizations.text(LangKey.searchUserAndGroup),
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
                ),
                Expanded(
                child: roomListVisible != null ? ListView.builder(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: roomListVisible!.rooms?.length ?? 0,
                    itemBuilder: (BuildContext context, int position) {
                      return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: _room(roomListVisible!.rooms![position], position == roomListVisible!.rooms!.length-1)
                      );
                    }) : Container()
            )],),
          )),
    );
  }
  Widget checkTag(String message) {
    Widget _widget;
    List<InlineSpan> _arr = [];
    List<String> contents = message.split(' ');
    for (int i = 0; i < contents.length; i++) {
      var element = contents[i];
      if(element == '@all-all@') {
        element = '@${AppLocalizations.text(LangKey.all)}';
        _arr.add(TextSpan(
            text: '$element ',
            style:
            const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
            )));
      }
      else {
        try {
          if(element[element.length-1] == '@' && element.contains('-')) {
            element = element.split('-').first;
            _arr.add(TextSpan(
                text: '$element ',
                style:
                const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold
                )));
          }
          else {
            _arr.add(TextSpan(
                text: i == contents.length-1 ? element : '$element ',
                style:
                TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.normal
                )));
          }
        }catch(_) {
          _arr.add(TextSpan(
              text: i == contents.length-1 ? element : '$element ',
              style:
              TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.normal
              )));
        }
      }
    }
    _widget = Text.rich(
      TextSpan(
        children: _arr,
      ),
    );
    return _widget;
  }
  Widget _room(Rooms data, bool isLast) {
    People info = getPeople(data.people);
    return Column(
      children: [
        SizedBox(
          child: SizedBox(
            height: 30.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  !data.isGroup! ? info.picture == null ? CircleAvatar(
                    radius: 10.0,
                    child: Text(
                      info.getAvatarName(),
                      style: const TextStyle(color: Colors.white,fontSize: 8),),
                  ) : CircleAvatar(
                    radius: 10.0,
                    backgroundImage:
                    CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${info.picture!.shieldedID}/256/${ChatConnection.brandCode!}',headers: {'brand-code':ChatConnection.brandCode!}),
                    backgroundColor: Colors.transparent,
                  ) : data.picture == null ? CircleAvatar(
                    radius: 10.0,
                    child: Text(
                      data.getAvatarGroupName(),
                      style: const TextStyle(color: Colors.white,fontSize: 8),),
                  ) : CircleAvatar(
                    radius: 10.0,
                    backgroundImage:
                    CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${data.picture!.shieldedID}/256/${ChatConnection.brandCode!}',headers: {'brand-code':ChatConnection.brandCode!}),
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
                                '${info.firstName} ${info.lastName}' : data.title ?? '${AppLocalizations.text(LangKey.group)} ${info.firstName} ${info.lastName}',overflow: TextOverflow.ellipsis),),
                                ButtonTheme(
                                  minWidth: 50.0,
                                  child: MaterialButton(onPressed: () async {
                                      if(!idSent.contains(data.sId)) {
                                        bool result = await ChatConnection.forwardMessage(_controllerContent.text,
                                            c.Room.fromJson(data.toJson()),
                                            ChatConnection.user!.id, widget.message.id);
                                        if(result) {
                                          idSent.add(data.sId);
                                          if(data.sId == ChatConnection.roomId) {
                                            _isSentCurrentChatRoom = true;
                                          }
                                          setState(() {});
                                        }
                                      }
                                  },
                                    color: idSent.contains(data.sId) ? Colors.grey : Colors.blue,
                                    textColor: idSent.contains(data.sId) ? Colors.black : Colors.white,
                                  child: AutoSizeText(idSent.contains(data.sId) ? AppLocalizations.text(LangKey.sent) : AppLocalizations.text(LangKey.send))),
                                )
                              ],
                            )
                        ),
                        Container(height: 5.0,),
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
}
