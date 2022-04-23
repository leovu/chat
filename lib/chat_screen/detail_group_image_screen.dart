import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_ui/conditional/conditional.dart';
import 'package:chat/data_model/chat_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/room.dart' as r;
import 'package:photo_view/photo_view_gallery.dart';

import '../connection/http_connection.dart';

class DetailGroupImageScreen extends StatefulWidget {
  final r.People people;
  final List<Images>? images;
  const DetailGroupImageScreen({Key? key, required this.people, required this.images}) : super(key: key);
  @override
  _State createState() => _State();
}

class _State extends State<DetailGroupImageScreen>
    with SingleTickerProviderStateMixin {
  bool _isImageViewVisible = false;
  String? imageViewed;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          '${widget.people.firstName} ${widget.people.lastName}',
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
      body:  _isImageViewVisible
          ? _imageGalleryBuilder()
          : SafeArea(
        child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemCount: widget.images?.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 4),
            itemBuilder: (BuildContext context, int position) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _isImageViewVisible = true;
                    imageViewed =
                    '${HTTPConnection.domain}api/images/${widget.images?[position].content}/512';
                  });
                },
                child: CachedNetworkImage(
                  imageUrl:
                  '${HTTPConnection.domain}api/images/${widget.images?[position].content}/512',
                  placeholder: (context, url) => const CupertinoActivityIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              );
            }),
      ),
    );
  }
  Widget _imageGalleryBuilder() {
    return imageViewed != null
        ? Dismissible(
      key: const Key('photo_view_gallery'),
      direction: DismissDirection.down,
      onDismissed: (direction) => _onCloseGalleryPressed(),
      child: Stack(
        children: [
          PhotoViewGallery.builder(
            builder: (BuildContext context, int index) =>
                PhotoViewGalleryPageOptions(
                  imageProvider: Conditional().getProvider(imageViewed!),
                ),
            itemCount: 1,
            loadingBuilder: (context, event) =>
                _imageGalleryLoadingBuilder(context, event),
            onPageChanged: _onPageChanged,
            pageController: PageController(initialPage: 0),
            scrollPhysics: const ClampingScrollPhysics(),
          ),
          Positioned(
            right: 16,
            top: 56,
            child: CloseButton(
              color: Colors.white,
              onPressed: _onCloseGalleryPressed,
            ),
          ),
        ],
      ),
    )
        : Container();
  }

  void _onCloseGalleryPressed() {
    try{
      setState(() {
        _isImageViewVisible = false;
      });
    }catch(_) {}
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
}
