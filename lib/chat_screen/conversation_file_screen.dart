import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/chat_ui/conditional/conditional.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/room.dart' as r;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ConversationFileScreen extends StatefulWidget {
  final c.ChatMessage? chatMessage;
  final r.Rooms roomData;
  const ConversationFileScreen(
      {Key? key, required this.roomData, this.chatMessage})
      : super(key: key);
  @override
  _ConversationFileScreenState createState() => _ConversationFileScreenState();
}

class _ConversationFileScreenState extends State<ConversationFileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isImageViewVisible = false;
  String? imageViewed;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoSizeText(
          'File, images, link are sent',
          style: TextStyle(
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
      body: _isImageViewVisible
          ? _imageGalleryBuilder()
          : SafeArea(
        child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSearchChip(
                              'Search',
                              const Icon(Icons.search, color: Colors.black),
                              () {}),
                          _buildSearchChip(
                              'By sender',
                              const Icon(Icons.people, color: Colors.black),
                              () {}),
                          _buildSearchChip(
                              'By time',
                              const Icon(Icons.timer, color: Colors.black),
                              () {}),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 3.0,
                    color: const Color(0xFFE5E5E5),
                  ),
                  TabBar(
                      unselectedLabelColor: Colors.grey,
                      labelColor: Colors.black,
                      tabs: const [
                        Tab(
                          text: 'IMAGE',
                        ),
                        Tab(
                          text: 'FILE',
                        ),
                        Tab(
                          text: 'LINK',
                        )
                      ],
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: Colors.black),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _images(),
                        Container(),
                        Container(),
                      ],
                      controller: _tabController,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSearchChip(String label, Icon icon, Function function) {
    return Chip(
      labelPadding: const EdgeInsets.all(2.0),
      avatar: icon,
      label: AutoSizeText(
        '  $label',
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
      backgroundColor: const Color(0xFFE5E5E5),
      elevation: 6.0,
      shadowColor: Colors.grey[60],
      padding: const EdgeInsets.all(8.0),
    );
  }

  Widget _images() {
    return GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: widget.chatMessage?.room?.images?.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (BuildContext context, int position) {
          return InkWell(
            onTap: () {
              setState(() {
                _isImageViewVisible = true;
                imageViewed =
                    '${HTTPConnection.domain}api/images/${widget.chatMessage?.room?.images?[position].content}/512';
              });
            },
            child: CachedNetworkImage(
              imageUrl:
                  '${HTTPConnection.domain}api/images/${widget.chatMessage?.room?.images?[position].content}/512',
              placeholder: (context, url) => const CupertinoActivityIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
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
