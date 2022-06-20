import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/draft.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/material.dart';

class ChatRoomWidget extends StatefulWidget {
  final String content;
  final String roomId;
  const ChatRoomWidget({Key? key, required this.content,required this.roomId}) : super(key: key);
  @override
  _ChatRoomWidgetState createState() => _ChatRoomWidgetState();
}

class _ChatRoomWidgetState extends State<ChatRoomWidget> {
  String? _draftMessage;

  @override
  void initState() {
    super.initState();
    draftMessage(widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      _draftMessage == null ? widget.content : _draftMessage! ,
      textScaleFactor: 0.8,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,);
  }

  draftMessage(String roomId) async {
    Map<String,dynamic>? draft = await getDraftInput(roomId);
    if(draft != null) {
      _draftMessage ='[${AppLocalizations.text(LangKey.draft)}] ${draft['text'] ?? ''}';
      setState(() {});
    }
  }
}