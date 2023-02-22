import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_ui/widgets/link_preview.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/download.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/room.dart' as r;
import 'package:intl/intl.dart';

class ByTimeResultScreen extends StatefulWidget {
  final c.ChatMessage? chatMessage;
  final r.Rooms roomData;
  final String? search;
  final String? title;
  final int tabbarIndex;
  const ByTimeResultScreen({Key? key, required this.roomData, required this.chatMessage, this.search, this.title, required this.tabbarIndex}) : super(key: key);
  @override
  _State createState() => _State();
}

class _State extends State<ByTimeResultScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.title ?? AppLocalizations.text(LangKey.byTime),
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
        child: ListView(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: Wrap(
                children: _list(),
              ),
            )
          ],
        ),
      ),
    );
  }
  List<Widget> _list() {
    Map<String,List<Widget>> values = {};
    List<String> keys = [];
    final format1 = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
    final format2 = DateFormat("dd/MM/yyyy");
    if(widget.tabbarIndex == 0) {
      widget.chatMessage?.room?.images?.forEach((e) {
        final dt = format1.parse(e.date!, true).toLocal();
        String formattedDate = format2.format(dt);
        if(widget.search != null && widget.search != '') {
          if(widget.search!.contains('-')) {
            List<String> listDates = widget.search!.split('-');
            if(listDates.length >= 2) {
              if (dt.isBetween(format2.parse(listDates[0]), format2.parse(listDates[1]))) {
                if(values.containsKey(formattedDate)) {
                  values[formattedDate]!.add(widgetCacheImage(e.content!));
                }
                else {
                  values[formattedDate] = [];
                  values[formattedDate]!.add(widgetCacheImage(e.content!));
                  keys.add(formattedDate);
                }
              }
            }
          }
          else {
            if(formattedDate == widget.search) {
              if(values.containsKey(formattedDate)) {
                values[formattedDate]!.add(widgetCacheImage(e.content!));
              }
              else {
                values[formattedDate] = [];
                values[formattedDate]!.add(widgetCacheImage(e.content!));
                keys.add(formattedDate);
              }
            }
          }
        }
        else {
          if(values.containsKey(formattedDate)) {
            values[formattedDate]!.add(widgetCacheImage(e.content!));
          }
          else {
            values[formattedDate] = [];
            values[formattedDate]!.add(widgetCacheImage(e.content!));
            keys.add(formattedDate);
          }
        }
      });
    }
    if(widget.tabbarIndex == 1) {
      widget.chatMessage?.room?.files?.forEach((e) {
        final dt = format1.parse(e.date!, true).toLocal();
        String formattedDate = format2.format(dt);
        if(widget.search != null && widget.search != '') {
          if(widget.search!.contains('-')) {
            List<String> listDates = widget.search!.split('-');
            if(listDates.length >= 2) {
              if (dt.isBetween(format2.parse(listDates[0]), format2.parse(listDates[1]))) {
                if(values.containsKey(formattedDate)) {
                  values[formattedDate]!.add(widgetCacheFile(e));
                }
                else {
                  values[formattedDate] = [];
                  values[formattedDate]!.add(widgetCacheFile(e));
                  keys.add(formattedDate);
                }
              }
            }
          }
          else {
            if(formattedDate == widget.search) {
              if(values.containsKey(formattedDate)) {
                values[formattedDate]!.add(widgetCacheFile(e));
              }
              else {
                values[formattedDate] = [];
                values[formattedDate]!.add(widgetCacheFile(e));
                keys.add(formattedDate);
              }
            }
          }
        }
        else {
          if(values.containsKey(formattedDate)) {
            values[formattedDate]!.add(widgetCacheFile(e));
          }
          else {
            values[formattedDate] = [];
            values[formattedDate]!.add(widgetCacheFile(e));
            keys.add(formattedDate);
          }
        }
      });
    }
    if(widget.tabbarIndex == 2) {
      final urlRegExp = RegExp(
          r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
      widget.chatMessage?.room?.links?.forEach((e) {
        final dt = format1.parse(e.date!, true).toLocal();
        String formattedDate = format2.format(dt);
        if(widget.search != null && widget.search != '') {
          if(widget.search!.contains('-')) {
            List<String> listDates = widget.search!.split('-');
            if(listDates.length >= 2) {
              if (dt.isBetween(format2.parse(listDates[0]), format2.parse(listDates[1]))) {
                if(values.containsKey(formattedDate)) {
                  List<String> urls = [];
                  final urlMatches = urlRegExp.allMatches(e.content ?? '');
                  List<String> url = urlMatches.map(
                          (urlMatch) => (e.content ?? '').substring(urlMatch.start, urlMatch.end))
                      .toList();
                  urls.addAll(url);
                  for (var e in urls) {
                    values[formattedDate]!.add(widgetCacheLink(e));
                  }
                }
                else {
                  values[formattedDate] = [];
                  List<String> urls = [];
                  final urlMatches = urlRegExp.allMatches(e.content ?? '');
                  List<String> url = urlMatches.map(
                          (urlMatch) => (e.content ?? '').substring(urlMatch.start, urlMatch.end))
                      .toList();
                  urls.addAll(url);
                  for (var e in urls) {
                    values[formattedDate]!.add(widgetCacheLink(e));
                  }
                  keys.add(formattedDate);
                }
              }
            }
          }
          else {
            if(formattedDate == widget.search) {
              if(values.containsKey(formattedDate)) {
                List<String> urls = [];
                final urlMatches = urlRegExp.allMatches(e.content ?? '');
                List<String> url = urlMatches.map(
                        (urlMatch) => (e.content ?? '').substring(urlMatch.start, urlMatch.end))
                    .toList();
                urls.addAll(url);
                for (var e in urls) {
                  values[formattedDate]!.add(widgetCacheLink(e));
                }
              }
              else {
                values[formattedDate] = [];
                List<String> urls = [];
                final urlMatches = urlRegExp.allMatches(e.content ?? '');
                List<String> url = urlMatches.map(
                        (urlMatch) => (e.content ?? '').substring(urlMatch.start, urlMatch.end))
                    .toList();
                urls.addAll(url);
                for (var e in urls) {
                  values[formattedDate]!.add(widgetCacheLink(e));
                }
                keys.add(formattedDate);
              }
            }
          }
        }
        else {
          if(values.containsKey(formattedDate)) {
            List<String> urls = [];
            final urlMatches = urlRegExp.allMatches(e.content ?? '');
            List<String> url = urlMatches.map(
                    (urlMatch) => (e.content ?? '').substring(urlMatch.start, urlMatch.end))
                .toList();
            urls.addAll(url);
            for (var e in urls) {
              values[formattedDate]!.add(widgetCacheLink(e));
            }
          }
          else {
            values[formattedDate] = [];
            List<String> urls = [];
            final urlMatches = urlRegExp.allMatches(e.content ?? '');
            List<String> url = urlMatches.map(
                    (urlMatch) => (e.content ?? '').substring(urlMatch.start, urlMatch.end))
                .toList();
            urls.addAll(url);
            for (var e in urls) {
              values[formattedDate]!.add(widgetCacheLink(e));
            }
            keys.add(formattedDate);
          }
        }
      });
    }
    List<Widget> widgets = [];
    for (var element in keys) {
      final dt = format2.parse(element, true);
      widgets.add(
        Row(
          children: [
            Expanded(child: Padding(
              padding: const EdgeInsets.only(left: 10.0,bottom: 15.0,top: 10.0),
              child: Text(
                dt.isToday() ? AppLocalizations.text(LangKey.today) : dt.isYesterday() ? AppLocalizations.text(LangKey.yesterday) :
                element,
                style: const TextStyle(fontWeight: FontWeight.w600),),
            ))
          ],
        )
      );
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          spacing: 5.0,
          children: values[element]!,),
      ));
      widgets.add(Container(height: 15.0,));
    }
    return widgets;
  }

  Widget widgetCacheFile(c.Images message) {
    return InkWell(
      onTap: () async {
        showLoading();
        String? result = await download(context,'${HTTPConnection.domain}api/files/${message.file?.shieldedID}','${message.date}_${message.file?.name}');
        Navigator.of(context).pop();
        openFile(result,context,message.file?.name ?? AppLocalizations.text(LangKey.file));
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
                    AutoSizeText(message.file?.name ?? '')
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
  }
  Widget widgetCacheImage(String content) {
    return InkWell(
      onTap: () async {
        openImage(context,'${HTTPConnection.domain}api/images/$content/512/${ChatConnection.brandCode}');
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.width * 0.3,
        child: CachedNetworkImage(
          imageUrl:
          '${HTTPConnection.domain}api/images/$content/256/${ChatConnection.brandCode!}',
          httpHeaders: {'brand-code':ChatConnection.brandCode!},
          fit: BoxFit.cover,
          placeholder: (context, url) => const CupertinoActivityIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      ),
    );
  }
  Widget widgetCacheLink(String content) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: PreviewLink(
        content: content,
      ),
    );
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

extension DateTimeExtension on DateTime? {
  bool? isAfterOrEqualTo(DateTime dateTime) {
    final date = this;
    if (date != null) {
      final isAtSameMomentAs = dateTime.isAtSameMomentAs(date);
      return isAtSameMomentAs | date.isAfter(dateTime);
    }
    return null;
  }
  bool? isBeforeOrEqualTo(DateTime dateTime) {
    final date = this;
    if (date != null) {
      final isAtSameMomentAs = dateTime.isAtSameMomentAs(date);
      return isAtSameMomentAs | date.isBefore(dateTime);
    }
    return null;
  }
  bool isBetween(
      DateTime fromDateTime,
      DateTime toDateTime,
      ) {
    final date = this;
    if (date != null) {
      final isAfter = date.isAfterOrEqualTo(fromDateTime) ?? false;
      final isBefore = date.isBeforeOrEqualTo(toDateTime) ?? false;
      return isAfter && isBefore;
    }
    return false;
  }
}