import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayAudio extends StatefulWidget {
  final String url;

  const PlayAudio({Key? key, required this.url}) : super(key: key);

  @override
  _PlayAudioState createState() => _PlayAudioState();
}

class _PlayAudioState extends State<PlayAudio> with TickerProviderStateMixin{
  AnimationController? _animationIconController1;
  AudioCache? audioCache;
  AudioPlayer? audioPlayer;
  Duration _duration = const Duration();
  Duration _position = const Duration();
  double? durationValue;
  bool isSongPlaying = false;
  bool isPlaying = false;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _animationIconController1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
      reverseDuration: const Duration(milliseconds: 750),
    );
    _progress =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationIconController1!);
    audioPlayer = AudioPlayer();
    audioCache = AudioCache(fixedPlayer: audioPlayer);
    audioPlayer?.onDurationChanged.listen((Duration d) {
      if(mounted) {
        setState(() {
          _duration = d;
        });
      }
    });
    audioPlayer?.onAudioPositionChanged.listen((p) {
      if(mounted) {
        setState(() {
          _position = p;
        });
      }
    });
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      play();
    });
  }

  @override
  void dispose() {
    super.dispose();
    audioPlayer?.dispose();
  }

  void seekToSeconds(int second) {
    Duration newDuration = Duration(seconds: second);
    audioPlayer?.seek(newDuration);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      height: 30,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              play();
            },
            child: ClipOval(
              child: Container(
                color: Colors.black,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    size: 14,
                    progress: _progress,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Slider(
            activeColor: Colors.black,
            inactiveColor: Colors.grey,
            thumbColor: Colors.black,
            value: _position.inSeconds.toDouble(),
            min: 0.0,
            max: _duration.inSeconds.toDouble(),
            onChanged: (double value) {
              seekToSeconds(value.toInt());
              value = value;
            },
          ),
        ],
      ),
    );
  }
  void play() {
    setState(() {
      isPlaying ? _animationIconController1?.reverse() : _animationIconController1?.forward();
      isPlaying = !isPlaying;
    });
    if (!isSongPlaying){
      audioPlayer?.play(widget.url,isLocal: true);
      setState(() {
        isSongPlaying = true;
      });
    } else {
      audioPlayer?.pause();
      setState(() {
        isSongPlaying = false;
      });
    }
  }
}