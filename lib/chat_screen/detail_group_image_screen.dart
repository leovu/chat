import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_ui/widgets/link_preview.dart';
import 'package:chat/connection/download.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/chat_message.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/room.dart' as r;

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
      body: SafeArea(
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
        itemCount: widget.images?.length ?? 0,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 4),
        itemBuilder: (BuildContext context, int position) {
          return InkWell(
            onTap: () async {
              openImage(context,'${HTTPConnection.domain}api/images/${widget.images?[position].content}/512');
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
        itemCount: widget.images?.length ?? 0,
        itemBuilder: (BuildContext context, int position) {
          return InkWell(
            onTap: () async {
              showLoading();
              var message = widget.images?[position].file!;
              String? result = await download(context,'${HTTPConnection.domain}api/files/${message!.shieldedID}','${widget.images?[position].date}_${message.name}');
              Navigator.of(context).pop();
              openFile(result,context,message.name ?? AppLocalizations.text(LangKey.file));
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
}
