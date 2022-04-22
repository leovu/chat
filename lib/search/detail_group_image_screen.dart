import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class DetailGroupImageScreen extends StatefulWidget {
  const DetailGroupImageScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<DetailGroupImageScreen>
    with SingleTickerProviderStateMixin {
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
        title: const AutoSizeText(
          'An An',
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
      body: SafeArea(
        child: Container(),
        // child: GridView.builder(
        //     padding: EdgeInsets.zero,
        //     shrinkWrap: true,
        //     physics: const ClampingScrollPhysics(),
        //     keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        //     itemCount: widget.chatMessage?.room?.images?.length,
        //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //       crossAxisCount: 3,
        //     ),
        //     itemBuilder: (BuildContext context, int position) {
        //       return InkWell(
        //         onTap: () {
        //           setState(() {
        //             _isImageViewVisible = true;
        //             imageViewed =
        //             '${HTTPConnection.domain}api/images/${widget.chatMessage?.room?.images?[position].content}/512';
        //           });
        //         },
        //         child: CachedNetworkImage(
        //           imageUrl:
        //           '${HTTPConnection.domain}api/images/${widget.chatMessage?.room?.images?[position].content}/512',
        //           placeholder: (context, url) => const CupertinoActivityIndicator(),
        //           errorWidget: (context, url, error) => const Icon(Icons.error),
        //         ),
        //       );
        //     }),
      ),
    );
  }
}
