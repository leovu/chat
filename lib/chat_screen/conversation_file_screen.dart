import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/chat_screen/by_time_search_list.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/download.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/chat_screen/by_sender_screen.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/room.dart' as r;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late TextEditingController _searchController;
  int _activeTabIndex = 0;
  c.ChatMessage? _chatMessage;
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController();
    _tabController.addListener(_setActiveTabIndex);
    _chatMessage = widget.chatMessage;
    super.initState();
    // Đồng bộ lại danh sách ảnh/file/link từ server (ảnh vừa gửi chưa có trong
    // dữ liệu được truyền vào -> fetch mới để hiển thị đầy đủ).
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncFiles());
  }

  Future<void> _syncFiles() async {
    final id = widget.roomData.sId ?? _chatMessage?.room?.sId;
    if (id == null) return;
    final fresh = await ChatConnection.joinRoom(id, refresh: true);
    if (!mounted || fresh == null) return;
    setState(() {
      _chatMessage = fresh;
    });
  }

  void _setActiveTabIndex() {
    _activeTabIndex = _tabController.index;
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
        title: AutoSizeText(
          AppLocalizations.text(LangKey.conversationFileTitle),
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: InkWell(
          child: Icon(Icons.arrow_back_ios, color: Colors.black),
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
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSearchChip(
                        AppLocalizations.text(LangKey.bySender),
                        const Icon(Icons.people, color: Colors.black), () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => BySenderResultScreen(
                                roomData: widget.roomData,
                                chatMessage: _chatMessage,
                                tabbarIndex: _activeTabIndex,
                              )));
                    }),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: _buildSearchChip(
                        AppLocalizations.text(LangKey.byTimes),
                        const Icon(Icons.timer, color: Colors.black), () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ByTimeResultScreen(
                                roomData: widget.roomData,
                                chatMessage: _chatMessage,
                                tabbarIndex: _activeTabIndex,
                              )));
                    }),
                  ),
                ],
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
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Colors.black),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _images(),
                  _files(),
                  _links(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchChip(String label, Icon icon, Function function) {
    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      onTap: () => function(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5E5),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[60] ?? Colors.grey,
              blurRadius: 6.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 4.0),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _images() {
    return GridView.builder(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: _chatMessage?.room?.images?.length ?? 0,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 4),
        itemBuilder: (BuildContext context, int position) {
          return InkWell(
            onTap: () async {
              openImage(context,
                  '${HTTPConnection.domain}api/images/${_chatMessage?.room?.images?[position].content}/512/${ChatConnection.brandCode}');
            },
            child: CachedNetworkImage(
              imageUrl:
                  '${HTTPConnection.domain}api/images/${_chatMessage?.room?.images?[position].content}/512/${ChatConnection.brandCode!}',
              httpHeaders: {'brand-code': ChatConnection.brandCode!},
              placeholder: (context, url) => const CupertinoActivityIndicator(),
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          );
        });
  }

  Widget _files() {
    return ListView.builder(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: _chatMessage?.room?.files?.length ?? 0,
        itemBuilder: (BuildContext context, int position) {
          return InkWell(
            onTap: () async {
              var message = _chatMessage?.room?.files?[position].file!;
              _showSnack(AppLocalizations.text(LangKey.downloading));
              String? result = await download(
                  context,
                  '${HTTPConnection.domain}api/files/${message!.shieldedID}/${ChatConnection.brandCode}',
                  '${_chatMessage?.room?.files?[position].date}_${message.name}');
              if (result != null) {
                _showSnack(AppLocalizations.text(LangKey.downloadSuccess));
                openFile(result, context,
                    message.name ?? AppLocalizations.text(LangKey.file));
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
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              _chatMessage?.room?.files?[position].file
                                      ?.name ??
                                  '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
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
        });
  }

  Widget _links() {
    final urlRegExp = RegExp(
        r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
    List<String> urls = [];
    for (var e in _chatMessage?.room?.links ?? <c.Images>[]) {
      final content = e.content ?? '';
      final urlMatches = urlRegExp.allMatches(content);
      List<String> url = urlMatches
          .map((urlMatch) => content.substring(urlMatch.start, urlMatch.end))
          .toList();
      if (url.isEmpty && content.isNotEmpty) {
        url = [content];
      }
      urls.addAll(url);
    }
    return ListView.builder(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: urls.length,
        itemBuilder: (BuildContext context, int position) {
          return InkWell(
            onTap: () => _openLink(urls[position]),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 45.0,
                    height: 45.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.blue,
                    ),
                    child: const Icon(Icons.link, color: Colors.white),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      urls[position],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
  }

  Future<void> _openLink(String url) async {
    String fullUrl = url;
    if (!fullUrl.startsWith('http://') && !fullUrl.startsWith('https://')) {
      fullUrl = 'https://$fullUrl';
    }
    final uri = Uri.tryParse(fullUrl);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
  }

  Widget searchOptionItem(String title, int type, {bool dateType = false}) {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!dateType)
            Container(
              margin: const EdgeInsets.only(left: 16.0, right: 16.0),
              height: 15.0,
              width: 15.0,
              child: type == 1
                  ? Icon(
                      Icons.people,
                      color: Colors.grey.shade500,
                    )
                  : (type == 2
                      ? Icon(
                          Icons.access_alarm,
                          color: Colors.grey.shade500,
                        )
                      : Icon(
                          Icons.video_call_outlined,
                          color: Colors.grey.shade500,
                        )),
            ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: dateType ? 15.0 : 0.0),
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade400),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16.0),
                  height: 1,
                  color: Colors.grey.shade200,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  int searchType = 0;
  _showBottomDialog() {
    showModalBottomSheet(
        context: context,
        isDismissible: true,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext bc) {
          return StatefulBuilder(
              builder: (BuildContext cxtx, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      searchType = 0;
                      Navigator.of(context).pop();
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (searchType == 1)
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    searchType = 0;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 12.0, top: 12.0, bottom: 12.0),
                                  child: Icon(Icons.arrow_back_ios,
                                      size: 18.0, color: Colors.grey.shade500),
                                ),
                              ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 12.0),
                                child: Text(
                                  searchType == 0
                                      ? AppLocalizations.text(LangKey.search)
                                      : AppLocalizations.text(LangKey.byTimes),
                                  style: const TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                            InkWell(
                                onTap: () {
                                  searchType = 0;
                                  Navigator.of(context).pop();
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 12.0, vertical: 12.0),
                                  child: Text(
                                    AppLocalizations.text(LangKey.cancel),
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.grey.shade500),
                                  ),
                                ))
                          ],
                        ),
                        if (searchType == 0)
                          InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => BySenderResultScreen(
                                          roomData: widget.roomData,
                                          chatMessage: _chatMessage,
                                          tabbarIndex: _activeTabIndex,
                                        )));
                                searchType = 0;
                              },
                              child: searchOptionItem(
                                  AppLocalizations.text(LangKey.bySender), 1)),
                        if (searchType == 0)
                          InkWell(
                              onTap: () {
                                setState(() {
                                  searchType = 1;
                                });
                              },
                              child: searchOptionItem(
                                  AppLocalizations.text(LangKey.byTimes), 2)),
                        // if (searchType == 1) InkWell(
                        //   onTap: () {
                        //     final format2 = DateFormat("dd/MM/yyyy");
                        //     String formattedDate = format2.format(DateTime.now().toUtc().add(const Duration(hours: 7)));
                        //     Navigator.of(context).pop();
                        //     Navigator.of(context).push(MaterialPageRoute(
                        //         builder: (context) => ByTimeResultScreen(
                        //           roomData: widget.roomData,
                        //           chatMessage: _chatMessage,
                        //           search: formattedDate,
                        //           title: 'Today',
                        //         )));
                        //     _searchController.text = '';
                        //     searchType = 0;
                        //   },
                        //     child: searchOptionItem("Today", 4, dateType: true)),
                        if (searchType == 1)
                          InkWell(
                              onTap: () {
                                final format2 = DateFormat("dd/MM/yyyy");
                                String formattedDate = format2.format(
                                    DateTime.now()
                                        .toUtc()
                                        .add(const Duration(hours: 7))
                                        .subtract(const Duration(days: 1)));
                                Navigator.of(context).pop();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ByTimeResultScreen(
                                          roomData: widget.roomData,
                                          chatMessage: _chatMessage,
                                          tabbarIndex: _activeTabIndex,
                                          search: formattedDate,
                                          title: AppLocalizations.text(
                                              LangKey.yesterday),
                                        )));
                                _searchController.text = '';
                                searchType = 0;
                              },
                              child: searchOptionItem(
                                  AppLocalizations.text(LangKey.yesterday), 4,
                                  dateType: true)),
                        // if (searchType == 1) InkWell(
                        //     onTap: () {
                        //       final format2 = DateFormat("dd/MM/yyyy");
                        //       DateTime thisWeekFirstDay = firstDateOfTheThisWeek(DateTime.now());
                        //       DateTime thisWeekLastDay = lastDateOfTheThisWeek(thisWeekFirstDay);
                        //       String formattedDate1 = format2.format(thisWeekFirstDay.toUtc().add(const Duration(hours: 7)));
                        //       String formattedDate2 = format2.format(thisWeekLastDay.toUtc().add(const Duration(hours: 7)));
                        //       Navigator.of(context).pop();
                        //       Navigator.of(context).push(MaterialPageRoute(
                        //           builder: (context) => ByTimeResultScreen(
                        //             roomData: widget.roomData,
                        //             chatMessage: _chatMessage,
                        //             search: '$formattedDate1-$formattedDate2',
                        //             title: 'This week',
                        //           )));
                        //       _searchController.text = '';
                        //       searchType = 0;
                        //     },child: searchOptionItem("This week", 4, dateType: true)),
                        if (searchType == 1)
                          InkWell(
                              onTap: () {
                                final format2 = DateFormat("dd/MM/yyyy");
                                DateTime lastWeekFirstDay =
                                    firstDateOfTheThisWeek(DateTime.now()
                                        .subtract(const Duration(days: 7)));
                                DateTime lastWeekLastDay =
                                    lastDateOfTheThisWeek(lastWeekFirstDay);
                                String formattedDate1 = format2.format(
                                    lastWeekFirstDay
                                        .toUtc()
                                        .add(const Duration(hours: 7)));
                                String formattedDate2 = format2.format(
                                    lastWeekLastDay
                                        .toUtc()
                                        .add(const Duration(hours: 7)));
                                Navigator.of(context).pop();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ByTimeResultScreen(
                                          roomData: widget.roomData,
                                          chatMessage: _chatMessage,
                                          tabbarIndex: _activeTabIndex,
                                          search:
                                              '$formattedDate1-$formattedDate2',
                                          title: AppLocalizations.text(
                                              LangKey.lastWeek),
                                        )));
                                _searchController.text = '';
                                searchType = 0;
                              },
                              child: searchOptionItem(
                                  AppLocalizations.text(LangKey.lastWeek), 4,
                                  dateType: true)),
                        // if (searchType == 1) InkWell(
                        //     onTap: () {
                        //       final format2 = DateFormat("dd/MM/yyyy");
                        //       DateTime firstDayOfMonth = firstDayCurrentMonth(DateTime.now());
                        //       DateTime lastDayOfMonth = lastDayCurrentMonth(DateTime.now());
                        //       String formattedDate1 = format2.format(firstDayOfMonth.toUtc().add(const Duration(hours: 7)));
                        //       String formattedDate2 = format2.format(lastDayOfMonth.toUtc().add(const Duration(hours: 7)));
                        //       Navigator.of(context).pop();
                        //       Navigator.of(context).push(MaterialPageRoute(
                        //           builder: (context) => ByTimeResultScreen(
                        //             roomData: widget.roomData,
                        //             chatMessage: _chatMessage,
                        //             search: '$formattedDate1-$formattedDate2',
                        //             title: 'This month',
                        //           )));
                        //       _searchController.text = '';
                        //       searchType = 0;
                        //     },child: searchOptionItem("This month", 4, dateType: true)),
                        if (searchType == 1)
                          InkWell(
                              onTap: () {
                                final format2 = DateFormat("dd/MM/yyyy");
                                DateTime firstDayOfMonth =
                                    firstDayLastMonth(DateTime.now());
                                DateTime lastDayOfMonth =
                                    lastDayLastMonth(DateTime.now());
                                String formattedDate1 = format2.format(
                                    firstDayOfMonth
                                        .toUtc()
                                        .add(const Duration(hours: 7)));
                                String formattedDate2 = format2.format(
                                    lastDayOfMonth
                                        .toUtc()
                                        .add(const Duration(hours: 7)));
                                Navigator.of(context).pop();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ByTimeResultScreen(
                                          roomData: widget.roomData,
                                          chatMessage: _chatMessage,
                                          tabbarIndex: _activeTabIndex,
                                          search:
                                              '$formattedDate1-$formattedDate2',
                                          title: AppLocalizations.text(
                                              LangKey.lastMonth),
                                        )));
                                _searchController.text = '';
                                searchType = 0;
                              },
                              child: searchOptionItem(
                                  AppLocalizations.text(LangKey.lastMonth), 4,
                                  dateType: true)),
                        if (searchType == 1)
                          InkWell(
                              onTap: () async {
                                DateTimeRange? range =
                                    await showDateRangePicker(
                                        context: context,
                                        firstDate: DateTime(1990, 1, 1),
                                        lastDate: DateTime.now(),
                                        currentDate: DateTime.now(),
                                        locale: ChatConnection.locale);
                                if (range != null) {
                                  final format2 = DateFormat("dd/MM/yyyy");
                                  String formattedDate1 = format2.format(range
                                      .start
                                      .toUtc()
                                      .add(const Duration(hours: 7)));
                                  String formattedDate2 = format2.format(range
                                      .end
                                      .toUtc()
                                      .add(const Duration(hours: 7)));
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ByTimeResultScreen(
                                            roomData: widget.roomData,
                                            chatMessage: _chatMessage,
                                            search:
                                                '$formattedDate1-$formattedDate2',
                                            tabbarIndex: _activeTabIndex,
                                            title: AppLocalizations.text(
                                                LangKey.custom),
                                          )));
                                  _searchController.text = '';
                                  searchType = 0;
                                }
                              },
                              child: searchOptionItem(
                                  AppLocalizations.text(LangKey.custom), 4,
                                  dateType: true)),
                        const SizedBox(height: 12.0),
                      ],
                    ),
                  ),
                ),
              ],
            );
          });
        });
  }

  DateTime firstDateOfTheThisWeek(DateTime dateTime) {
    return dateTime.subtract(Duration(days: dateTime.weekday - 1));
  }

  DateTime lastDateOfTheThisWeek(DateTime dateTime) {
    return dateTime
        .add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
  }

  DateTime firstDayCurrentMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }

  DateTime lastDayCurrentMonth(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month + 1,
    ).subtract(const Duration(days: 1));
  }

  DateTime firstDayLastMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month - 1, 1);
  }

  DateTime lastDayLastMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1)
        .subtract(const Duration(days: 1));
  }
}
