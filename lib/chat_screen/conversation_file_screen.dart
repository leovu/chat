import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/chat_screen/by_time_search_list.dart';
import 'package:chat/chat_ui/widgets/link_preview.dart';
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
  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    _searchController = TextEditingController();
    _searchNode = FocusNode();
    _tabController.addListener(_setActiveTabIndex);
    super.initState();
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
                          _buildSearchChip(AppLocalizations.text(LangKey.search),
                              const Icon(Icons.search, color: Colors.black),
                              () {
                            _showBottomDialog();
                          }),
                          _buildSearchChip(AppLocalizations.text(LangKey.bySender),
                              const Icon(Icons.people, color: Colors.black),
                              () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BySenderResultScreen(
                                      roomData: widget.roomData,
                                      chatMessage: widget.chatMessage,
                                      tabbarIndex: _activeTabIndex,
                                    )));
                          }),
                          _buildSearchChip(
                              AppLocalizations.text(LangKey.byTimes),
                              const Icon(Icons.timer, color: Colors.black),
                              () {
                                Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ByTimeResultScreen(
                                        roomData: widget.roomData,
                                        chatMessage: widget.chatMessage,
                                        tabbarIndex: _activeTabIndex,
                                      )));
                              }),
                        ],
                      ),
                    ),
                  ),
                  // : CustomSearchTextField(_searchNode, _searchController, "Tìm ảnh, bộ sưu tạp, files, links"),
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
                        _files(),
                        _links(),
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
    return InkWell(
      child: Chip(
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
      ),
      onTap: () => function(),
    );
  }

  Widget _images() {
    return GridView.builder(
        padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: widget.chatMessage?.room?.images?.length ?? 0,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 4),
        itemBuilder: (BuildContext context, int position) {
          return InkWell(
            onTap: () async {
              openImage(context,'${HTTPConnection.domain}api/images/${widget.chatMessage?.room?.images?[position].content}/512/${ChatConnection.brandCode}');
            },
            child: CachedNetworkImage(
              imageUrl:
                  '${HTTPConnection.domain}api/images/${widget.chatMessage?.room?.images?[position].content}/512/${ChatConnection.brandCode!}',
              httpHeaders: {'brand-code':ChatConnection.brandCode!},
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
        itemCount: widget.chatMessage?.room?.files?.length ?? 0,
        itemBuilder: (BuildContext context, int position) {
          return InkWell(
            onTap: () async {
              showLoading();
              var message = widget.chatMessage?.room?.files?[position].file!;
              String? result = await download(context,'${HTTPConnection.domain}api/files/${message!.shieldedID}','${widget.chatMessage?.room?.files?[position].date}_${message.name}');
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
                          AutoSizeText(widget.chatMessage?.room?.files?[position].file?.name ?? '')
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
    for(var e in widget.chatMessage?.room?.links ?? <c.Images>[] ) {
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
                content: urls[position],// This disables tap event
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

  Widget searchOptionItem(String title, int type , {bool dateType = false}) {
    return Container(
      margin: const EdgeInsets.only(top: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(!dateType) Container(
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
                  padding: EdgeInsets.only(left:dateType ? 15.0 : 0.0),
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
                                      hintText: AppLocalizations.text(LangKey.findConversationFile),
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
                                    if(searchType == 1) {
                                      setState(() {
                                        searchType = 0;
                                      });
                                    }
                                    else {
                                      Navigator.of(context).pop();
                                    }
                              } ,
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
                            child: searchOptionItem(AppLocalizations.text(LangKey.bySender), 1)),
                      if (searchType == 0)
                        InkWell(
                            onTap: () {
                              setState(() {
                                searchType = 1;
                              });
                            },
                            child: searchOptionItem(AppLocalizations.text(LangKey.byTimes), 2)),
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
                      if (searchType == 1) InkWell(
                          onTap: () {
                            final format2 = DateFormat("dd/MM/yyyy");
                            String formattedDate = format2.format(DateTime.now().toUtc().add(const Duration(hours: 7)).subtract(const Duration(days: 1)));
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ByTimeResultScreen(
                                  roomData: widget.roomData,
                                  chatMessage: widget.chatMessage,
                                  tabbarIndex: _activeTabIndex,
                                  search: formattedDate,
                                  title: AppLocalizations.text(LangKey.yesterday),
                                )));
                            _searchController.text = '';
                            searchType = 0;
                          },child: searchOptionItem(AppLocalizations.text(LangKey.yesterday), 4, dateType: true)),
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
                      if (searchType == 1) InkWell(
                          onTap: () {
                            final format2 = DateFormat("dd/MM/yyyy");
                            DateTime lastWeekFirstDay = firstDateOfTheThisWeek(DateTime.now().subtract(const Duration(days: 7)));
                            DateTime lastWeekLastDay = lastDateOfTheThisWeek(lastWeekFirstDay);
                            String formattedDate1 = format2.format(lastWeekFirstDay.toUtc().add(const Duration(hours: 7)));
                            String formattedDate2 = format2.format(lastWeekLastDay.toUtc().add(const Duration(hours: 7)));
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ByTimeResultScreen(
                                  roomData: widget.roomData,
                                  chatMessage: widget.chatMessage,
                                  tabbarIndex: _activeTabIndex,
                                  search: '$formattedDate1-$formattedDate2',
                                  title: AppLocalizations.text(LangKey.lastWeek),
                                )));
                            _searchController.text = '';
                            searchType = 0;
                          },child: searchOptionItem(AppLocalizations.text(LangKey.lastWeek), 4, dateType: true)),
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
                      if (searchType == 1) InkWell(
                          onTap: () {
                            final format2 = DateFormat("dd/MM/yyyy");
                            DateTime firstDayOfMonth = firstDayLastMonth(DateTime.now());
                            DateTime lastDayOfMonth = lastDayLastMonth(DateTime.now());
                            String formattedDate1 = format2.format(firstDayOfMonth.toUtc().add(const Duration(hours: 7)));
                            String formattedDate2 = format2.format(lastDayOfMonth.toUtc().add(const Duration(hours: 7)));
                            Navigator.of(context).pop();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => ByTimeResultScreen(
                                  roomData: widget.roomData,
                                  chatMessage: widget.chatMessage,
                                  tabbarIndex: _activeTabIndex,
                                  search: '$formattedDate1-$formattedDate2',
                                  title: AppLocalizations.text(LangKey.lastMonth),
                                )));
                            _searchController.text = '';
                            searchType = 0;
                          },child: searchOptionItem(AppLocalizations.text(LangKey.lastMonth), 4, dateType: true)),
                      if (searchType == 1) InkWell(
                          onTap: () async {
                            DateTimeRange? range = await showDateRangePicker(context: context,
                                firstDate: DateTime(1990, 1, 1),
                                lastDate: DateTime.now(),
                                currentDate: DateTime.now(),
                                locale: ChatConnection.locale);
                            if(range != null) {
                              final format2 = DateFormat("dd/MM/yyyy");
                              String formattedDate1 = format2.format(range.start.toUtc().add(const Duration(hours: 7)));
                              String formattedDate2 = format2.format(range.end.toUtc().add(const Duration(hours: 7)));
                              Navigator.of(context).pop();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ByTimeResultScreen(
                                    roomData: widget.roomData,
                                    chatMessage: widget.chatMessage,
                                    search: '$formattedDate1-$formattedDate2',
                                    tabbarIndex: _activeTabIndex,
                                    title: AppLocalizations.text(LangKey.custom),
                                  )));
                              _searchController.text = '';
                              searchType = 0;
                            }
                          },child: searchOptionItem(AppLocalizations.text(LangKey.custom), 4, dateType: true)),
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
    return dateTime.add(Duration(days: DateTime.daysPerWeek - dateTime.weekday));
  }
  DateTime firstDayCurrentMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }
  DateTime lastDayCurrentMonth(DateTime dateTime) {
    return DateTime(dateTime.year,dateTime.month+1,).subtract(const Duration(days: 1));
  }
  DateTime firstDayLastMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month-1, 1);
  }
  DateTime lastDayLastMonth(DateTime dateTime) {
    return DateTime(dateTime.year,dateTime.month,1).subtract(const Duration(days: 1));
  }
}
