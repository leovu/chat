import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class ChatRoomWidget extends StatefulWidget {
  final String content;
  const ChatRoomWidget({Key? key, required this.content})
      : super(key: key);
  @override
  _ChatRoomWidgetState createState() => _ChatRoomWidgetState();
}

class _ChatRoomWidgetState extends State<ChatRoomWidget> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      widget.content,
      textScaleFactor: 0.8,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
