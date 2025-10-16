import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart'; // Import thư viện để mở link

//==============================================================================
// WIDGET 1: Hiển thị thumbnail video trong khung chat
//==============================================================================

class VideoMessageWidget extends StatelessWidget {
  final String videoUrl;
  final String? thumbUrl;
  final String? title;

  const VideoMessageWidget({
    Key? key,
    required this.videoUrl,
    this.thumbUrl,
    this.title,
  }) : super(key: key);

  void _openFullScreenPlayer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoViewer(videoUrl: videoUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFullScreenPlayer(context),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: thumbUrl != null
                  ? Image.network(
                      thumbUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: Colors.grey[800],
                        child: const Icon(Icons.video_camera_back, color: Colors.white, size: 50),
                      ),
                    )
                  : Container(
                      height: 150,
                      color: Colors.grey[800],
                      child: const Icon(Icons.video_camera_back, color: Colors.white, size: 50),
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 50,
              ),
            ),
            if (title != null)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  title!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 4.0, color: Colors.black)]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

//==============================================================================
// WIDGET 2: Màn hình phát video toàn màn hình (Giao diện cũ + Chức năng mới)
//==============================================================================

class FullScreenVideoViewer extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoViewer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _FullScreenVideoViewerState createState() => _FullScreenVideoViewerState();
}

class _FullScreenVideoViewerState extends State<FullScreenVideoViewer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // *** HÀM MỚI: Mở link video trong trình duyệt ***
  Future<void> _openInBrowser() async {
    final Uri url = Uri.parse(widget.videoUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể mở link: ${widget.videoUrl}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // *** THAY ĐỔI Ở ĐÂY: Nút bấm luôn là icon download và gọi hàm _openInBrowser ***
          IconButton(
            icon: const Icon(Icons.download_rounded),
            onPressed: _openInBrowser, // Gọi hàm mở trình duyệt
          ),
        ],
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    VideoPlayer(_controller),
                    // Thanh điều khiển tua video
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      padding: const EdgeInsets.all(10.0),
                      colors: const VideoProgressColors(
                        playedColor: Colors.red,
                        bufferedColor: Colors.white54,
                        backgroundColor: Colors.black38,
                      ),
                    ),
                    // Nút Play/Pause ở giữa (Giao diện cũ)
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                        // Vùng nhấn lớn hơn, trong suốt
                        child: Container(
                          color: Colors.transparent,
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Colors.white.withOpacity(0.7),
                            size: 60,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}