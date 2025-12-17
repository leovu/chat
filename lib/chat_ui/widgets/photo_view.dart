import 'dart:io';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/download.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../connection/http_connection.dart' show HTTPConnection;

class PhotoScreen extends StatefulWidget {
  final String imageViewed;
  const PhotoScreen({Key? key, required this.imageViewed}) : super(key: key);

  @override
  _PhotoScreenState createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  /// Kiểm tra xem imageViewed là URL hay local file path
  bool get _isNetworkImage =>
      widget.imageViewed.startsWith('http://') ||
      widget.imageViewed.startsWith('https://');

  Widget _imageGalleryBuilder() {
    return Dismissible(
      key: const Key('photo_view_gallery'),
      direction: DismissDirection.down,
      onDismissed: (direction) => _onCloseGalleryPressed(),
      child: Stack(
        children: [
          PhotoViewGallery.builder(
            builder: (BuildContext context, int index) {
              ImageProvider imageProvider;
              if (_isNetworkImage) {
                imageProvider = NetworkImage(widget.imageViewed);
              } else {
                imageProvider = FileImage(File(widget.imageViewed));
              }

              return PhotoViewGalleryPageOptions(
                imageProvider: imageProvider,
                errorBuilder: (context, error, stackTrace) {
                  // Chỉ thử fallback URL nếu là network image
                  // Local file không cần fallback network
                  if (_isNetworkImage) {
                    final fallbackUrl = buildFallbackImageUrl(widget.imageViewed);
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
            itemCount: 1,
            loadingBuilder: (context, event) =>
                _imageGalleryLoadingBuilder(context, event),
            onPageChanged: _onPageChanged,
            pageController: PageController(initialPage: 0),
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
                showLoading();

                if (_isNetworkImage) {
                  // Network image: tải về và lưu vào gallery
                  // Sử dụng URL trực tiếp (đã được xử lý đầy đủ domain trong download.dart)
                  await download(context, widget.imageViewed,
                      '${DateTime.now().millisecondsSinceEpoch}.jpeg',
                      isSaveGallery: true);
                } else {
                  // Local file: lưu trực tiếp vào gallery
                  saveGallery(widget.imageViewed,
                      '${DateTime.now().millisecondsSinceEpoch}.jpeg');
                }

                Navigator.of(context).pop();
              },
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

  Future showLoading() async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              Center(
                child: Platform.isAndroid
                    ? const CircularProgressIndicator()
                    : const CupertinoActivityIndicator(),
              )
            ],
          );
        });
  }

  void _onCloseGalleryPressed() {
    Navigator.of(context).pop();
  }

  void _onPageChanged(int index) {
    setState(() {});
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
