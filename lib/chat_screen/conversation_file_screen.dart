import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:url_launcher/url_launcher.dart';
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
  late FocusNode _searchNode;
  int _activeTabIndex = 0;

  // Dữ liệu media hiện tại (đồng bộ lại từ server, không dùng snapshot cũ).
  c.ChatMessage? _data;
  bool _loading = false;

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController();
    _searchNode = FocusNode();
    _tabController.addListener(_setActiveTabIndex);
    _data = widget.chatMessage;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  // Nạp lại media (image/file/link) mới nhất cho phòng để đồng bộ tin vừa gửi.
  Future<void> _fetchData() async {
    if (_loading) return;
    final roomId = widget.roomData.sId;
    if (roomId == null) return;
    if (mounted) setState(() => _loading = true);
    try {
      final res = await ChatConnection.joinRoom(roomId, refresh: true);
      if (res != null && mounted) {
        setState(() => _data = res);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setActiveTabIndex() {
    if (mounted) setState(() => _activeTabIndex = _tabController.index);
  }

  @override
  void dispose() {
    _tabController.removeListener(_setActiveTabIndex);
    _tabController.dispose();
    _searchController.dispose();
    _searchNode.dispose();
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
            Container(
              color: Colors.white,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _buildSearchChip(
                            AppLocalizations.text(LangKey.bySender),
                            Icons.people, () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => BySenderResultScreen(
                                    roomData: widget.roomData,
                                    chatMessage: _data,
                                    tabbarIndex: _activeTabIndex,
                                  )));
                        }),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildSearchChip(
                            AppLocalizations.text(LangKey.byTimes), Icons.timer,
                            () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ByTimeResultScreen(
                                    roomData: widget.roomData,
                                    chatMessage: _data,
                                    tabbarIndex: _activeTabIndex,
                                  )));
                        }),
                      ),
                    ],
                  )),
            ),
            // : CustomSearchTextField(_searchNode, _searchController, "Tìm ảnh, bộ sưu tạp, files, links"),
            Container(
              margin: const EdgeInsets.fromLTRB(12, 6, 12, 10),
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
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
            ),
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

  Widget _buildSearchChip(String label, IconData iconData, Function function) {
    return GestureDetector(
      onTap: () => function(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: 18, color: Colors.black87),
            const SizedBox(width: 6),
            Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }

  void _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {}
    }
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

  // Trạng thái rỗng/đang tải, vẫn cuộn được để kéo-làm-mới hoạt động.
  Widget _emptyState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.28),
        Center(
          child: _loading
              ? (Platform.isAndroid
                  ? const CircularProgressIndicator()
                  : const CupertinoActivityIndicator())
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(message,
                        style: TextStyle(color: Colors.grey.shade500)),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _images() {
    final images = _data?.room?.images ?? <c.Images>[];
    if (images.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchData,
        child: _emptyState('Chưa có dữ liệu'),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: images.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 4),
          itemBuilder: (BuildContext context, int position) {
            final content = images[position].content;
            return InkWell(
              onTap: () async {
                openImage(context,
                    '${HTTPConnection.domain}api/images/$content/512/${ChatConnection.brandCode}');
              },
              child: CachedNetworkImage(
                imageUrl:
                    '${HTTPConnection.domain}api/images/$content/512/${ChatConnection.brandCode!}',
                httpHeaders: {'brand-code': ChatConnection.brandCode!},
                placeholder: (context, url) =>
                    const CupertinoActivityIndicator(),
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            );
          }),
    );
  }

  Widget _files() {
    final files = _data?.room?.files ?? <c.Images>[];
    if (files.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchData,
        child: _emptyState('Chưa có dữ liệu'),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: files.length,
          itemBuilder: (BuildContext context, int position) {
            final file = files[position].file;
            return InkWell(
              onTap: () async {
                if (file?.shieldedID == null) return;
                _showSnack('Đang tải...');
                String? result = await download(
                    context,
                    '${HTTPConnection.domain}api/files/${file!.shieldedID}',
                    '${files[position].date}_${file.name}');
                openFile(result, context,
                    file.name ?? AppLocalizations.text(LangKey.file));
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
                          child: AutoSizeText(
                            file?.name ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
          }),
    );
  }

  Widget _links() {
    final urlRegExp = RegExp(
        r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
    List<String> urls = [];
    for (var e in _data?.room?.links ?? <c.Images>[]) {
      final urlMatches = urlRegExp.allMatches(e.content ?? '');
      List<String> url = urlMatches
          .map((urlMatch) =>
              (e.content ?? '').substring(urlMatch.start, urlMatch.end))
          .toList();
      urls.addAll(url);
    }
    if (urls.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchData,
        child: _emptyState('Chưa có dữ liệu'),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: urls.length,
        itemBuilder: (BuildContext context, int position) {
          return InkWell(
            onTap: () => _openLink(urls[position]),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.link, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      urls[position],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
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
              children: [
                Container(
                  height: MediaQuery.of(context).viewPadding.top,
                  color: Colors.white,
                ),
                Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                              child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              width: double.infinity,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(10),
                                  borderRadius: BorderRadius.circular(5)),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Center(
                                      child: Icon(
                                        Icons.search,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      child: TextField(
                                    focusNode: _searchNode,
                                    controller: _searchController,
                                    onChanged: (_) {},
                                    decoration: InputDecoration.collapsed(
                                      hintText: AppLocalizations.text(
                                          LangKey.findConversationFile),
                                    ),
                                  )),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Center(
                                          child: Icon(
                                            Icons.close,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        _searchController.text = '';
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )),
                          InkWell(
                              onTap: () {
                                if (searchType == 1) {
                                  setState(() {
                                    searchType = 0;
                                  });
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
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
                              String text = _searchController.value.text;
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => BySenderResultScreen(
                                        roomData: widget.roomData,
                                        chatMessage: widget.chatMessage,
                                        tabbarIndex: _activeTabIndex,
                                        search: text,
                                      )));
                              _searchController.text = '';
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
                      //           chatMessage: widget.chatMessage,
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
                                        chatMessage: widget.chatMessage,
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
                      //             chatMessage: widget.chatMessage,
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
                                        chatMessage: widget.chatMessage,
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
                      //             chatMessage: widget.chatMessage,
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
                                        chatMessage: widget.chatMessage,
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
                              DateTimeRange? range = await showDateRangePicker(
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
                                String formattedDate2 = format2.format(range.end
                                    .toUtc()
                                    .add(const Duration(hours: 7)));
                                Navigator.of(context).pop();
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ByTimeResultScreen(
                                          roomData: widget.roomData,
                                          chatMessage: widget.chatMessage,
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
                    ],
                  ),
                ),
                Container(
                  height: 10.0,
                  color: Colors.white,
                ),
                Expanded(child: InkWell(
                  onTap: () {
                    _searchController.text = '';
                    searchType = 0;
                    Navigator.of(context).pop();
                  },
                ))
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
