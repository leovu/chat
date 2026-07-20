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
  const ByTimeResultScreen(
      {Key? key,
      required this.roomData,
      required this.chatMessage,
      this.search,
      this.title,
      required this.tabbarIndex})
      : super(key: key);
  @override
  _State createState() => _State();
}

class _State extends State<ByTimeResultScreen>
    with SingleTickerProviderStateMixin {
  late int _tabIndex;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.tabbarIndex;
    _tabController =
        TabController(length: 3, vsync: this, initialIndex: widget.tabbarIndex);
    _tabController.addListener(() {
      if (_tabIndex != _tabController.index) {
        setState(() => _tabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Segmented chọn loại (IMAGE/FILE/LINK) — cùng style với ConversationFileScreen.
  Widget _typeSegmented() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashBorderRadius: BorderRadius.circular(9),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: const Color(0xff5686E1),
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        labelPadding: EdgeInsets.zero,
        tabs: const [
          Tab(
            height: 38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 16),
                SizedBox(width: 6),
                Text('IMAGE'),
              ],
            ),
          ),
          Tab(
            height: 38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insert_drive_file_outlined, size: 16),
                SizedBox(width: 6),
                Text('FILE'),
              ],
            ),
          ),
          Tab(
            height: 38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.link, size: 16),
                SizedBox(width: 6),
                Text('LINK'),
              ],
            ),
          ),
        ],
      ),
    );
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
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onTap: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _typeSegmented(),
            Expanded(
              child: Builder(builder: (context) {
                final items = _list();
                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text('Chưa có dữ liệu',
                            style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  );
                }
                return ListView(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      child: Wrap(
                        children: items,
                      ),
                    )
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _list() {
    Map<String, List<Widget>> values = {};
    List<String> keys = [];
    final format1 = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
    final format2 = DateFormat("dd/MM/yyyy");
    if (_tabIndex == 0) {
      widget.chatMessage?.room?.images?.forEach((e) {
        if (e.date == null || e.content == null) return;
        final dt = format1.parse(e.date!, true).toLocal();
        String formattedDate = format2.format(dt);
        if (widget.search != null && widget.search != '') {
          if (widget.search!.contains('-')) {
            List<String> listDates = widget.search!.split('-');
            if (listDates.length >= 2) {
              if (dt.isBetween(
                  format2.parse(listDates[0]),
                  format2.parse(listDates[1]).add(const Duration(
                      hours: 23,
                      minutes: 59,
                      seconds: 59,
                      milliseconds: 999)))) {
                if (values.containsKey(formattedDate)) {
                  values[formattedDate]!.add(widgetCacheImage(e.content!));
                } else {
                  values[formattedDate] = [];
                  values[formattedDate]!.add(widgetCacheImage(e.content!));
                  keys.add(formattedDate);
                }
              }
            }
          } else {
            if (formattedDate == widget.search) {
              if (values.containsKey(formattedDate)) {
                values[formattedDate]!.add(widgetCacheImage(e.content!));
              } else {
                values[formattedDate] = [];
                values[formattedDate]!.add(widgetCacheImage(e.content!));
                keys.add(formattedDate);
              }
            }
          }
        } else {
          if (values.containsKey(formattedDate)) {
            values[formattedDate]!.add(widgetCacheImage(e.content!));
          } else {
            values[formattedDate] = [];
            values[formattedDate]!.add(widgetCacheImage(e.content!));
            keys.add(formattedDate);
          }
        }
      });
    }
    if (_tabIndex == 1) {
      widget.chatMessage?.room?.files?.forEach((e) {
        if (e.date == null) return;
        final dt = format1.parse(e.date!, true).toLocal();
        String formattedDate = format2.format(dt);
        if (widget.search != null && widget.search != '') {
          if (widget.search!.contains('-')) {
            List<String> listDates = widget.search!.split('-');
            if (listDates.length >= 2) {
              if (dt.isBetween(
                  format2.parse(listDates[0]),
                  format2.parse(listDates[1]).add(const Duration(
                      hours: 23,
                      minutes: 59,
                      seconds: 59,
                      milliseconds: 999)))) {
                if (values.containsKey(formattedDate)) {
                  values[formattedDate]!.add(widgetCacheFile(e));
                } else {
                  values[formattedDate] = [];
                  values[formattedDate]!.add(widgetCacheFile(e));
                  keys.add(formattedDate);
                }
              }
            }
          } else {
            if (formattedDate == widget.search) {
              if (values.containsKey(formattedDate)) {
                values[formattedDate]!.add(widgetCacheFile(e));
              } else {
                values[formattedDate] = [];
                values[formattedDate]!.add(widgetCacheFile(e));
                keys.add(formattedDate);
              }
            }
          }
        } else {
          if (values.containsKey(formattedDate)) {
            values[formattedDate]!.add(widgetCacheFile(e));
          } else {
            values[formattedDate] = [];
            values[formattedDate]!.add(widgetCacheFile(e));
            keys.add(formattedDate);
          }
        }
      });
    }
    if (_tabIndex == 2) {
      final urlRegExp = RegExp(
          r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
      widget.chatMessage?.room?.links?.forEach((e) {
        if (e.date == null) return;
        final dt = format1.parse(e.date!, true).toLocal();
        String formattedDate = format2.format(dt);
        if (widget.search != null && widget.search != '') {
          if (widget.search!.contains('-')) {
            List<String> listDates = widget.search!.split('-');
            if (listDates.length >= 2) {
              if (dt.isBetween(
                  format2.parse(listDates[0]),
                  format2.parse(listDates[1]).add(const Duration(
                      hours: 23,
                      minutes: 59,
                      seconds: 59,
                      milliseconds: 999)))) {
                if (values.containsKey(formattedDate)) {
                  List<String> urls = [];
                  final urlMatches = urlRegExp.allMatches(e.content ?? '');
                  List<String> url = urlMatches
                      .map((urlMatch) => (e.content ?? '')
                          .substring(urlMatch.start, urlMatch.end))
                      .toList();
                  urls.addAll(url);
                  for (var e in urls) {
                    values[formattedDate]!.add(widgetCacheLink(e));
                  }
                } else {
                  values[formattedDate] = [];
                  List<String> urls = [];
                  final urlMatches = urlRegExp.allMatches(e.content ?? '');
                  List<String> url = urlMatches
                      .map((urlMatch) => (e.content ?? '')
                          .substring(urlMatch.start, urlMatch.end))
                      .toList();
                  urls.addAll(url);
                  for (var e in urls) {
                    values[formattedDate]!.add(widgetCacheLink(e));
                  }
                  keys.add(formattedDate);
                }
              }
            }
          } else {
            if (formattedDate == widget.search) {
              if (values.containsKey(formattedDate)) {
                List<String> urls = [];
                final urlMatches = urlRegExp.allMatches(e.content ?? '');
                List<String> url = urlMatches
                    .map((urlMatch) => (e.content ?? '')
                        .substring(urlMatch.start, urlMatch.end))
                    .toList();
                urls.addAll(url);
                for (var e in urls) {
                  values[formattedDate]!.add(widgetCacheLink(e));
                }
              } else {
                values[formattedDate] = [];
                List<String> urls = [];
                final urlMatches = urlRegExp.allMatches(e.content ?? '');
                List<String> url = urlMatches
                    .map((urlMatch) => (e.content ?? '')
                        .substring(urlMatch.start, urlMatch.end))
                    .toList();
                urls.addAll(url);
                for (var e in urls) {
                  values[formattedDate]!.add(widgetCacheLink(e));
                }
                keys.add(formattedDate);
              }
            }
          }
        } else {
          if (values.containsKey(formattedDate)) {
            List<String> urls = [];
            final urlMatches = urlRegExp.allMatches(e.content ?? '');
            List<String> url = urlMatches
                .map((urlMatch) =>
                    (e.content ?? '').substring(urlMatch.start, urlMatch.end))
                .toList();
            urls.addAll(url);
            for (var e in urls) {
              values[formattedDate]!.add(widgetCacheLink(e));
            }
          } else {
            values[formattedDate] = [];
            List<String> urls = [];
            final urlMatches = urlRegExp.allMatches(e.content ?? '');
            List<String> url = urlMatches
                .map((urlMatch) =>
                    (e.content ?? '').substring(urlMatch.start, urlMatch.end))
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
      widgets.add(Row(
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 15.0, top: 10.0),
            child: Text(
              dt.isToday()
                  ? AppLocalizations.text(LangKey.today)
                  : dt.isYesterday()
                      ? AppLocalizations.text(LangKey.yesterday)
                      : element,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ))
        ],
      ));
      widgets.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          spacing: 5.0,
          children: values[element]!,
        ),
      ));
      widgets.add(Container(
        height: 15.0,
      ));
    }
    return widgets;
  }

  Widget widgetCacheFile(c.Images message) {
    return InkWell(
      onTap: () async {
        showLoading();
        String? result = await download(
            context,
            '${HTTPConnection.domain}api/files/${message.file?.shieldedID}',
            '${message.date}_${message.file?.name}');
        Navigator.of(context).pop();
        openFile(result, context,
            message.file?.name ?? AppLocalizations.text(LangKey.file));
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
                  children: [AutoSizeText(message.file?.name ?? '')],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              height: 1.0,
              color: Colors.grey.shade200,
            ),
          )
        ],
      ),
    );
  }

  // Bottomsheet xem nhanh ảnh (thay cho mở màn hình mới).
  void _showImageSheet(String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.open_in_full, size: 20),
                      tooltip: 'Xem',
                      onPressed: () {
                        Navigator.of(context).pop();
                        openImage(this.context,
                            '${HTTPConnection.domain}api/images/$content/512/${ChatConnection.brandCode}');
                      },
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: CachedNetworkImage(
                          imageUrl:
                              '${HTTPConnection.domain}api/images/$content/512/${ChatConnection.brandCode!}',
                          httpHeaders: {
                            'brand-code': ChatConnection.brandCode!
                          },
                          fit: BoxFit.contain,
                          placeholder: (context, url) =>
                              const Center(child: CupertinoActivityIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget widgetCacheImage(String content) {
    return InkWell(
      onTap: () => _showImageSheet(content),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.3,
        height: MediaQuery.of(context).size.width * 0.3,
        child: CachedNetworkImage(
          imageUrl:
              '${HTTPConnection.domain}api/images/$content/256/${ChatConnection.brandCode!}',
          httpHeaders: {'brand-code': ChatConnection.brandCode!},
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
                child: Platform.isAndroid
                    ? const CircularProgressIndicator()
                    : const CupertinoActivityIndicator(),
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
