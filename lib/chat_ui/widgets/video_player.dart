import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class PlayVideo extends StatefulWidget{
  final String url;
  const PlayVideo({Key? key, required this.url}) : super(key: key);
  @override
  _PlayVideoState createState() => _PlayVideoState();
}

class _PlayVideoState extends State<PlayVideo> {
  late VideoPlayerController controller;
  @override
  void initState() {
    loadVideoPlayer();
    super.initState();
  }

  loadVideoPlayer(){
    controller = VideoPlayerController.file(File(widget.url));
    controller.addListener(() {
      setState(() {});
    });
    controller.initialize().then((value){
      controller.play();
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      width: MediaQuery.of(context).size.width * 0.95,
      child: Column(
          children:[
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
            VideoProgressIndicator(
                controller,
                allowScrubbing: true,
                colors:const VideoProgressColors(
                  backgroundColor: Colors.black,
                  playedColor: Colors.black,
                  bufferedColor: Colors.grey,
                )
            ),
            Row(
              children: [
                IconButton(
                    onPressed: (){
                      if(controller.value.isPlaying){
                        controller.pause();
                      }else{
                        controller.play();
                      }
                      setState(() {});
                    },
                    icon:Icon(controller.value.isPlaying?Icons.pause:Icons.play_arrow)
                ),
                IconButton(
                    onPressed: (){
                      controller.seekTo(const Duration(seconds: 0));
                      setState(() {});
                    },
                    icon:const Icon(Icons.stop)
                )
              ],
            )
          ]
      ),
    );
  }
}