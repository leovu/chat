import 'dart:io';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/download.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../connection/http_connection.dart' show HTTPConnection;

class PhotoScreen extends StatefulWidget {
  final String imageViewed;
  final List<String>? imageUrls;
  final int initialIndex;
  final Future<void> Function(File editedImage)? onResend;

  const PhotoScreen({
    Key? key,
    required this.imageViewed,
    this.imageUrls,
    this.initialIndex = 0,
    this.onResend,
  }) : super(key: key);

  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get _imageList => widget.imageUrls ?? [widget.imageViewed];

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
  }

  Widget _imageGalleryBuilder() {
    return Dismissible(
      key: const Key('photo_view_gallery'),
      direction: DismissDirection.down,
      onDismissed: (direction) => _onCloseGalleryPressed(),
      child: Stack(
        children: [
          PhotoViewGallery.builder(
            builder: (BuildContext context, int index) {
              final imageUrl = _imageList[index];
              final isNetwork = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
              ImageProvider imageProvider;
              if (isNetwork) {
                imageProvider = NetworkImage(imageUrl);
              } else {
                imageProvider = FileImage(File(imageUrl));
              }

              return PhotoViewGalleryPageOptions(
                imageProvider: imageProvider,
                errorBuilder: (context, error, stackTrace) {
                  if (isNetwork) {
                    final fallbackUrl = buildFallbackImageUrl(imageUrl);
                    return Image.network(
                      fallbackUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildErrorWidget();
                      },
                    );
                  }
                  return _buildErrorWidget();
                },
              );
            },
            itemCount: _imageList.length,
            loadingBuilder: (context, event) =>
                _imageGalleryLoadingBuilder(context, event),
            onPageChanged: _onPageChanged,
            pageController: _pageController,
            scrollPhysics: const ClampingScrollPhysics(),
          ),
          Positioned(
            right: 5,
            top: 0,
            child: CloseButton(
              color: Colors.white,
              onPressed: _onCloseGalleryPressed,
            ),
          ),
          Positioned(
            right: 45,
            top: 0,
            child: IconButton(
              icon: const Icon(Icons.download_rounded),
              color: Colors.white,
              tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: () async {
                _showSnack('Đang tải...');
                final currentUrl = _imageList[_currentIndex];
                final isNetwork = currentUrl.startsWith('http://') || currentUrl.startsWith('https://');
                if (isNetwork) {
                  await download(context, currentUrl,
                      '${DateTime.now().millisecondsSinceEpoch}.jpeg',
                      isSaveGallery: true);
                } else {
                  saveGallery(currentUrl,
                      '${DateTime.now().millisecondsSinceEpoch}.jpeg');
                }
                _showSnack('Đã lưu ảnh');
              },
            ),
          ),
          if (_imageList.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${_imageList.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String buildFallbackImageUrl(String? original, {String size = "512"}) {
    if (original == null) return "";

    final uri = Uri.tryParse(original);
    String shieldedId = "";

    if (uri != null && uri.pathSegments.isNotEmpty) {
      shieldedId = uri.pathSegments.last.replaceAll('.jpg', '');
    } else {
      shieldedId = original;
    }

    return "${HTTPConnection.domain}api/images/$shieldedId/$size/${ChatConnection.brandCode}";
  }

  void _onCloseGalleryPressed() {
    Navigator.of(context).pop();
  }

  void _onPageChanged(int index) {
    setState(() { _currentIndex = index; });
  }

  Widget _imageGalleryLoadingBuilder(
    BuildContext context,
    ImageChunkEvent? event,
  ) {
    return Center(
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          value: event == null || event.expectedTotalBytes == null
              ? 0
              : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
        ),
      ),
    );
  }

  /// Widget hiển thị khi không load được ảnh
  Widget _buildErrorWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            color: Colors.white54,
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            'Không thể tải ảnh',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: _imageGalleryBuilder(),
        ),
      ),
    );
  }
}
