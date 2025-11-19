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
  Widget _imageGalleryBuilder() {
    return Dismissible(
      key: const Key('photo_view_gallery'),
      direction: DismissDirection.down,
      onDismissed: (direction) => _onCloseGalleryPressed(),
      child: Stack(
        children: [
          PhotoViewGallery.builder(
            builder: (BuildContext context, int index) {
              final imageProvider = NetworkImage(widget.imageViewed);

              return PhotoViewGalleryPageOptions(
                imageProvider: imageProvider,
                errorBuilder: (context, error, stackTrace) {
                  final fallbackUrl = buildFallbackImageUrl(widget.imageViewed);
                  return Image.network(
                    fallbackUrl,
                    fit: BoxFit.contain,
                  );
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
                String linkDowload = ChatConnection.isChatHub
                    ? widget.imageViewed
                    : buildFallbackImageUrl(widget.imageViewed);
                showLoading();
                await download(context, linkDowload,
                    '${DateTime.now().toUtc().millisecond}.jpeg',
                    isSaveGallery: true);
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
