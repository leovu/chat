import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/chat_ui/widgets/audio_player.dart';
import 'package:flutter/material.dart';

class MediaScreen extends StatefulWidget {
  final String filePath;
  final String title;

  const MediaScreen({
    Key? key,
    required this.filePath,
    required this.title,
  }) : super(key: key);

  @override
  _MediaScreenState createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> with SingleTickerProviderStateMixin {

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: false);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.repeat();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.title,
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
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.05,
                  bottom: MediaQuery.of(context).size.height*0.05),
            child: RotationTransition(
              turns: _animation,
              child: const CircleAvatar(
                radius: 100,
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 100.0,
                ),
              ),
            )),
            Center(child: PlayAudio(url: widget.filePath))
          ],
        ),
      ),
    );
  }
}
