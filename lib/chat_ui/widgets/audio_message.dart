import 'dart:async';

import 'package:chat/chat_ui/util.dart';
import 'package:chat/chat_ui/widgets/inherited_chat_theme.dart';
import 'package:chat/common/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:audioplayers/audioplayers.dart';
import 'package:rxdart/rxdart.dart';

class AudioMessage extends StatefulWidget {
  const AudioMessage({
    Key? key,
    required this.message,
    required this.showName,
    required this.showUserNameForRepliedMessage,
    required this.onMessageTap,
    required this.people,
  }) : super(key: key);

  final types.AudioMessage message;

  final bool showName;

  final bool showUserNameForRepliedMessage;

  final void Function(
      BuildContext context, types.Message, bool isRepliedMessage)? onMessageTap;

  final List<dynamic>? people;

  @override
  State<AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final Stream<_AudioData> _audioDataStream;

  late final bool _canCalculateDuration;

  @override
  void initState() {
    super.initState();
    _canCalculateDuration = widget.message.uri.toLowerCase().endsWith('.mp3');

    _audioDataStream =
        Rx.combineLatest3<PlayerState, Duration, Duration, _AudioData>(
      _audioPlayer.onPlayerStateChanged,
      _audioPlayer.onPositionChanged,
      _audioPlayer.onDurationChanged,
      (playerState, position, duration) => _AudioData(
        isPlaying: playerState == PlayerState.playing,
        currentPosition: position,
        totalDuration: duration,
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio() async {
    if (widget.message.uri.isNotEmpty) {
      await _audioPlayer.setSource(UrlSource(widget.message.uri));
      await _audioPlayer.resume();
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    final theme = InheritedChatTheme.of(context).theme;
    final color = getUserAvatarNameColor(
      widget.message.author,
      theme.userAvatarNameColors,
    );

    return StreamBuilder<_AudioData>(
      stream: _audioDataStream,
      initialData: _AudioData(
        isPlaying: false,
        currentPosition: Duration.zero,
        totalDuration: Duration.zero,
      ),
      builder: (context, snapshot) {
        final data = snapshot.data!;
        final maxMilliseconds = data.totalDuration.inMilliseconds.toDouble();
        final currentMilliseconds =
            data.currentPosition.inMilliseconds.toDouble();
        final hasDuration = _canCalculateDuration && maxMilliseconds > 0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${widget.message.author.firstName ?? ''} ${widget.message.author.lastName ?? ''}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.userNameTextStyle.copyWith(color: color),
              ),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    data.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 30,
                  ),
                  onPressed: data.isPlaying ? _pauseAudio : _playAudio,
                  color: color,
                ),
                Expanded(
                  child: hasDuration
                      ? Slider(
                          value:
                              currentMilliseconds.clamp(0.0, maxMilliseconds),
                          min: 0.0,
                          max: maxMilliseconds,
                          onChanged: (value) async {
                            final position =
                                Duration(milliseconds: value.toInt());
                            await _audioPlayer.seek(position);
                          },
                          activeColor: color,
                          inactiveColor: color.withOpacity(0.3),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(
                            height: 24,
                            width: 40,
                            child: data.isPlaying
                                ? const WaveAnimation()
                                : const SizedBox.shrink(),
                          ),
                        ),
                ),
                hasDuration
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          _formatDuration(data.currentPosition) +
                              (hasDuration
                                  ? ' / ${_formatDuration(data.totalDuration)}'
                                  : ''),
                          style: theme.userNameTextStyle.copyWith(
                              color: color, fontWeight: FontWeight.w500),
                        ),
                      )
                    : SizedBox(),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _AudioData {
  final bool isPlaying;
  final Duration currentPosition;
  final Duration totalDuration;

  _AudioData({
    required this.isPlaying,
    required this.currentPosition,
    required this.totalDuration,
  });
}

class WaveAnimation extends StatefulWidget {
  const WaveAnimation({super.key, this.color = AppColors.colorBlue});

  final Color color;

  @override
  State<WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<WaveAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _animations = List.generate(5, (i) {
      final delay = i * 0.1;
      return Tween<double>(begin: 4, end: 20).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, delay + 0.5, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _animations.map((animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Container(
              width: 4,
              height: animation.value,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}
