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
    return Text(
      widget.content,
      textScaleFactor: 0.8,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
