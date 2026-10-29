import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/chat_ui/widgets/audio_player.dart';
import 'package:chat/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:chat/common/widgets/glass_widgets.dart';

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

class _MediaScreenState extends State<MediaScreen>
    with SingleTickerProviderStateMixin {
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
      backgroundColor: AppColors.surfaceColor,
      appBar: AppBar(
        centerTitle: true,
        title: AutoSizeText(
          widget.title,
          style: AppGlass.headerTitleStyle,
        ),
        leading: GlassBackButton(onTap: () => Navigator.of(context).pop()),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: AppGlass.headerShape,
        flexibleSpace: AppGlass.headerBackground(),
        systemOverlayStyle: AppGlass.headerOverlay,
        iconTheme: const IconThemeData(
          color: AppGlass.headerForeground,
        ),
      ),
      body: DecoratedBox(
        decoration: AppGlass.background(),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.05,
                      bottom: MediaQuery.of(context).size.height * 0.05),
                  child: RotationTransition(
                    turns: _animation,
                    child: const CircleAvatar(
                      radius: 100,
                      backgroundColor: AppColors.primaryColor,
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
      ),
    );
  }
}
