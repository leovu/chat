import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/chat_message.dart';
import 'package:chat/chat_screen/detail_group_image_screen.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/room.dart' as r;
import 'package:cached_network_image/cached_network_image.dart';

class GroupImageItem extends StatelessWidget {
  final r.People people;
  final List<Images>? images;
  final int tabbarIndex;
  const GroupImageItem({Key? key, required this.people, required this.images, required this.tabbarIndex}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => DetailGroupImageScreen(people: people,images: images,tabbarIndex: tabbarIndex,)));
      },
      child: Container(
        margin: const EdgeInsets.only(left: 8.0, bottom: 8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.6)),
          borderRadius: BorderRadius.circular(8.0)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2 - 16.0,
              height: MediaQuery.of(context).size.width / 4,
              decoration: const BoxDecoration(
                color: Color(0xff9012FE),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8.0),
                    topLeft: Radius.circular(8.0),
                  )),
              child:
              people.picture == null ? Center(child: AutoSizeText(people.getAvatarName(),
                style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
              textScaleFactor: 2.5,)) :
              CachedNetworkImage(
                imageUrl:
                '${HTTPConnection.domain}api/images/${people.picture!.shieldedID}/256/${ChatConnection.brandCode!}',
                httpHeaders: {'brand-code':ChatConnection.brandCode!},
                fit: BoxFit.cover,
                placeholder: (context, url) => const CupertinoActivityIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(8.0),
              child: Text(
                '${people.firstName} ${people.lastName}',
                style: const TextStyle(fontSize: 15.0, color: Colors.black, fontWeight: FontWeight.w400),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                '${images?.length ?? 0} '
                    '${ tabbarIndex == 0 ?
                    AppLocalizations.text(LangKey.photos) :
                tabbarIndex == 1 ? AppLocalizations.text(LangKey.file) : 'Links'
                }',
                style: TextStyle(fontSize: 14.0, color: Colors.grey.shade600, fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}