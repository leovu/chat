import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_ui/conditional/conditional.dart';
import 'package:chat/chat_ui/widgets/link_preview.dart';
import 'package:chat/connection/download.dart';
import 'package:chat/data_model/chat_message.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/room.dart' as r;
import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:url_launcher/url_launcher.dart';

import '../connection/http_connection.dart';

class DetailGroupImageScreen extends StatefulWidget {
  final r.People people;
  final List<Images>? images;
  final int tabbarIndex;
  const DetailGroupImageScreen({Key? key, required this.people, required this.images, required this.tabbarIndex}) : super(key: key);
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
        child: widget.tabbarIndex == 0 ? _images() : widget.tabbarIndex == 1 ? _files() : _links(),
      ),
    );
  }
  Widget _images() {
    return GridView.builder(
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
        });
  }
  Widget _files() {
    return ListView.builder(
        padding: const EdgeInsets.fromLTRB(5, 15, 5, 5),
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: widget.images?.length,
        itemBuilder: (BuildContext context, int position) {
          return InkWell(
            onTap: () async {
              showLoading();
              var message = widget.images?[position].file!;
              String? result = await download(context,'${HTTPConnection.domain}api/files/${message!.shieldedID}','${widget.images?[position].date}_${message.name}');
              Navigator.of(context).pop();
              String? dataResult = await openFile(result,context,message.name ?? AppLocalizations.text(LangKey.file));
              if(dataResult != null) {
                setState(() {
                  _isImageViewVisible = true;
                  imageViewed = result;
                });
              }
            },
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 45.0,
                      height: 45.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.blue,
                      ),
                      child: Image.asset(
                        'assets/icon-document.png',
                        color: Colors.white,
                        package: 'chat',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          AutoSizeText(widget.images?[position].file?.name ?? '')
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Container(height: 1.0,color: Colors.grey.shade200,),
                )
              ],
            ),
          );
        });
  }
  Widget _links() {
    final urlRegExp = RegExp(
        r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
    List<String> urls = [];
    for(var e in widget.images ?? <Images>[] ) {
      final urlMatches = urlRegExp.allMatches(e.content ?? '');
      List<String> url = urlMatches.map(
              (urlMatch) => (e.content ?? '').substring(urlMatch.start, urlMatch.end))
          .toList();
      urls.addAll(url);
    }
    return ListView.builder(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: urls.length,
        itemBuilder: (BuildContext context, int position) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: PreviewLink(
              content: urls[position],
            ),
          );
        });
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
                child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator(),
              )
            ],
          );
        });
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
                await download(context,imageViewed!,'${DateTime.now().toUtc().millisecond}.jpeg',isSaveGallery: true);
                Navigator.of(context).pop();
              },
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
