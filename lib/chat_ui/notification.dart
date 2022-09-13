import 'package:chat/connection/chat_connection.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BannerNotification extends StatefulWidget {
  final String notificationTitle;
  final String notificationDescription;
  final String iconApp;
  final bool isImage;
  final bool isFile;
  final Function onReplay;

  const BannerNotification(
      {Key? key, required this.notificationTitle, required this.notificationDescription,
        required this.onReplay, required this.iconApp, this.isImage = false, this.isFile = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return BannerNotificationState();
  }
}

class BannerNotificationState extends State<BannerNotification> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFDEE7F1),
                blurRadius: 3.0,
                spreadRadius: 0.5,
              ),
            ],
          ),
          child: Card(
            margin: EdgeInsets.zero,
            color: Colors.white,
            child: ListTile(
              onTap: () {
                  widget.onReplay();
              },
              title: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                        maxWidth: 40,
                        maxHeight: 40,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Image.asset(widget.iconApp,
                            fit: BoxFit.contain),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              widget.notificationTitle,
                              maxLines: 1,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 5.0, top: 5.0, bottom: 5.0),
                            child: Text(widget.isImage ? AppLocalizations.text(LangKey.sentPicture) :
                            widget.isFile ? AppLocalizations.text(LangKey.sendFile) :
                            widget.notificationDescription,
                                maxLines: 2,
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 12),
                                textAlign: TextAlign.left),
                          )
                        ],
                      ),
                    ),
                    if(widget.isImage) SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 5.0, top: 5.0, bottom: 5.0),
                        child: CachedNetworkImage(
                          imageUrl: '${widget.notificationDescription}/${ChatConnection.brandCode!}',
                          httpHeaders: {'brand-code':ChatConnection.brandCode!},
                          placeholder: (context, url) => const CupertinoActivityIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              subtitle: Container(
                padding: const EdgeInsets.only(top: 15, bottom: 5),
                alignment: Alignment.center,
                child: Container(
                  height: 5,
                  width: 50,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(2.5)),
                      color: Color(0xffE2E4EC)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}