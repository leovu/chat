import 'dart:async';
import 'dart:io';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_screen/filter_chathub_screen.dart';
import 'package:chat/chat_screen/home_screen.dart';
import 'package:chat/chat_ui/widgets/chat_room_widget.dart';
import 'package:chat/chat_ui/widgets/custom_room_avatar.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/room.dart';
import 'package:chat/draft.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/check_tag.dart';
import 'package:chat/localization/color_platform_chathub.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:chat/presentation/conversation_modules/src/bloc/chatbot_bloc.dart';
import 'package:chat/presentation/utils/ultility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../presentation/chat_module/ui/chat_screen.dart';

typedef ChatHubListFilerBuilder = void Function(void Function() filter);

class RoomListScreen extends StatefulWidget {
  final ChatHubListFilerBuilder? chatHubBuilder;
  final RefreshBuilder builder;
  final Function? homeCallback;
  final Function? filterCall;
  final Function? openCreateChatRoom;
  final String? source;
  final Function? refreshTabNoti;

  const RoomListScreen(
      {Key? key,
      required this.builder,
      this.homeCallback,
      this.openCreateChatRoom,
      this.source,
      this.chatHubBuilder,
      this.refreshTabNoti,
      this.filterCall})
      : super(key: key);

  @override
  _RoomListScreenState createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen>
    with AutomaticKeepAliveClientMixin {
  final _focusSearch = FocusNode();
  final _controllerSearch = TextEditingController();
  String? channel;
  String? status;
  List<String?>? tagIds;

  Room? roomListVisible;
  Room? roomListData;
  bool isInitScreen = true;
  Map<String, dynamic> colorAppName = {};
  late ScrollController _listViewController;
  int _currentPage = 1;

  String? link_status;
  String? startDay;
  String? endDay;
  bool isGroup = false;
  Timer? _debounce;
  Room? roomListSearch;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkUserToken();
      _getRooms();
      _listViewController = ScrollController()..addListener(_scrollListener);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controllerSearch.dispose();
    _focusSearch.dispose();
    super.dispose();
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _scrollListener() async {
    if (_listViewController.position.maxScrollExtent ==
        _listViewController.offset) {
      final prevCount = roomListVisible?.rooms?.length ?? 0;
      await _getRooms(page: _currentPage + 1);
      final newCount = roomListVisible?.rooms?.length ?? 0;
      if (newCount > prevCount) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    }
  }

  _onRefresh() async {
    _controllerSearch.text = '';
    await _getRooms();
    _refreshController.refreshCompleted();
    setState(() {
      _currentPage = 1;
    });
  }

  _onLoading() async {
    if (_currentPage == 1) {
      await _getRooms(page: _currentPage + 1);
    }
    _refreshController.loadComplete();
  }

  checkUserToken() async {
    await ChatConnection.checkUserToken();
  }

  _getRooms({int page = 1}) async {
    if (mounted) {
      roomListData = await ChatConnection.roomList(
        source: widget.source,
        channelId: channel,
        status: status,
        tagIds: tagIds,
        page: page,
        roomData: roomListData,
        link_status: link_status,
        isGroup: isGroup,
        endDate: endDay,
        startDate: startDay,
      );
      _getRoomVisible();
      isInitScreen = false;
      if (ChatConnection.isChatHub) {
        if (widget.refreshTabNoti != null) {
          widget.refreshTabNoti?.call();
        }
      }

      setState(() {});
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        roomListData = await ChatConnection.roomList(
            source: widget.source,
            channelId: channel,
            status: status,
            tagIds: tagIds,
            page: page,
            keyword: _controllerSearch.value.text,
            roomData: roomListData,
            link_status: link_status,
            isGroup: isGroup,
            endDate: endDay,
            startDate: startDay);
        _getRoomVisible();
        isInitScreen = false;
        if (ChatConnection.isChatHub) {
          if (widget.refreshTabNoti != null) {
            widget.refreshTabNoti?.call();
          }
        }

        setState(() {});
      });
    }
    if (page != 1)
      setState(() {
        _currentPage++;
      });
  }

  _getRoomVisible() async {
    String val = _controllerSearch.value.text;
    if (val != '') {
      roomListSearch = await ChatConnection.roomList(
          source: widget.source,
          channelId: channel,
          status: status,
          tagIds: tagIds,
          keyword: val,
          page: _currentPage,
          roomData: roomListData,
          link_status: link_status,
          isGroup: isGroup,
          endDate: endDay,
          startDate: startDay);
      roomListVisible = roomListSearch;
      setState(() {});
    } else {
      roomListVisible = Room();
      roomListVisible?.limit = roomListData?.limit;
      try {
        roomListVisible?.rooms = <Rooms>[
          ...(roomListData?.rooms?.toList() ?? [])
        ];
      } catch (_) {}
      setState(() {});
    }

    isInitScreen = false;
  }

  void filter() async {
    Map<String, dynamic>? result =
        await Navigator.of(ChatConnection.buildContext).push(MaterialPageRoute(
            builder: (context) => FilterChathubScreen(
                  channel: channel,
                  status: status,
                  arrLabel: tagIds,
                  link_status: link_status,
                  endDay: endDay,
                  startDay: startDay,
                  isGroup: isGroup,
                )));
    if (result != null) {
      channel = result['channel'];
      status = result['status'];
      tagIds = result['tag_ids'];
      link_status = result['link_status'];
      isInitScreen = true;
      endDay = result['endDay'];
      startDay = result['startDay'];
      isGroup = result['isGroup'] ?? false;
      setState(() {
        _getRooms();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    widget.builder.call(context, _getRooms);
    widget.chatHubBuilder?.call(filter);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!ChatConnection.isChatHub)
                    Container(
                      height: 30.0,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(ChatConnection.buildContext).pop();
                            },
                            child: SizedBox(
                                width: 30.0,
                                child: Icon(Icons.arrow_back_ios,
                                    color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                  if (!ChatConnection.isChatHub)
                    Row(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: 3.0, left: 10.0),
                          child: Text(AppLocalizations.text(LangKey.chats),
                              style: const TextStyle(
                                  fontSize: 25.0, color: Colors.black)),
                        ),
                        Expanded(child: Container()),
                        if (!ChatConnection.isChatHub)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: SizedBox(
                                width: 30.0,
                                height: 30.0,
                                child: InkWell(
                                  onTap: () async {
                                    if (widget.openCreateChatRoom != null) {
                                      widget.openCreateChatRoom?.call();
                                    }
                                  },
                                  child: Image.asset(
                                    'assets/icon-edit.png',
                                    package: 'chat',
                                  ),
                                )),
                          )
                      ],
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 10.0),
                    child: Container(
                      width: double.infinity,
                      height: 40,
                      decoration: BoxDecoration(
                          color: const Color(0xFFE7EAEF),
                          borderRadius: BorderRadius.circular(5)),
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Center(
                              child: Icon(
                                Icons.search,
                              ),
                            ),
                          ),
                          Expanded(
                              child: TextField(
                            focusNode: _focusSearch,
                            controller: _controllerSearch,
                            onChanged: (_) {
                              if (_debounce?.isActive ?? false)
                                _debounce?.cancel();
                              _debounce =
                                  Timer(const Duration(milliseconds: 300), () {
                                setState(() {
                                  isInitScreen = true;
                                  _getRoomVisible();
                                });
                              });
                            },
                            decoration: InputDecoration.collapsed(
                              hintText:
                                  AppLocalizations.text(LangKey.searchChats),
                            ),
                          )),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(5),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Center(
                                  child: Icon(
                                    Icons.close,
                                  ),
                                ),
                              ),
                              onTap: () {
                                _controllerSearch.text = '';
                                FocusManager.instance.primaryFocus?.unfocus();
                                setState(() {
                                  isInitScreen = true;
                                  _getRoomVisible();
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Expanded(
                child: isInitScreen
                    ? Center(
                        child: Platform.isAndroid
                            ? const CircularProgressIndicator()
                            : const CupertinoActivityIndicator())
                    : roomListVisible?.rooms != null
                        ? SmartRefresher(
                            enablePullDown: true,
                            enablePullUp: true,
                            controller: _refreshController,
                            onRefresh: _onRefresh,
                            onLoading: _onLoading,
                            header: const WaterDropHeader(),
                            footer: CustomFooter(
                              builder:
                                  (BuildContext context, LoadStatus? mode) {
                                Widget body;
                                if (mode == LoadStatus.failed) {
                                  body = const Text(LangKey.load_more_failed);
                                } else if (mode == LoadStatus.noMore ||
                                    mode == LoadStatus.idle) {
                                  body = const SizedBox.shrink();
                                } else {
                                  body = Platform.isAndroid
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 3),
                                        )
                                      : const CupertinoActivityIndicator();
                                }
                                return SizedBox(
                                  height: 60,
                                  child: Center(child: body),
                                );
                              },
                            ),
                            child: ValueListenableBuilder<int>(
                              valueListenable:
                                  ChatConnection.onlineUsersNotifier,
                              builder: (context, _, __) => ListView.builder(
                                controller: _listViewController,
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                itemCount: (ChatConnection.openChatGPT != null)
                                    ? (roomListVisible?.rooms?.length ?? 0) + 1
                                    : (roomListVisible?.rooms?.length ?? 0),
                                itemBuilder: (BuildContext context, int index) {
                                  int position =
                                      (ChatConnection.openChatGPT != null)
                                          ? index - 1
                                          : index;
                                  if (ChatConnection.openChatGPT != null &&
                                      index == 0) {
                                    return InkWell(
                                      onTap: () {
                                        ChatConnection.openChatGPT?.call();
                                      },
                                      child: _gptRoom(
                                          !(roomListVisible?.rooms != null &&
                                              (roomListVisible
                                                      ?.rooms?.isNotEmpty ??
                                                  false))),
                                    );
                                  }
                                  return parseRoom(position);
                                },
                              ),
                            ),
                          )
                        : Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget parseRoom(int position) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: InkWell(
          onTap: () async {
            final room = roomListVisible?.rooms?[position];
            if (room == null) return;
            if (ChatConnection.isChatHub) {
              ChatbotService().setRoomId(room.sId ?? '');
              ChatbotService().setStatus(room.enable_bot ?? 0);
            }
            final groupOwner = extractOwner(room);
            await Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                  builder: (context) => ChatScreen(
                        isChatbot: ChatConnection.isChatHub
                            ? room.channel?.enable_bot == 1
                                ? true
                                : false
                            : null,
                        data: room,
                        source: room.source,
                        groupOwner:
                            !ChatConnection.isChatHub ? groupOwner : null,
                      ),
                  settings: const RouteSettings(name: 'chat_screen')),
            );
            _getRooms();
          },
          child: Slidable(
              enabled: !ChatConnection.isChatHub,
              endActionPane: ActionPane(
                motion: const StretchMotion(),
                children: [
                  if (roomListVisible?.rooms?[position].isGroup ?? false)
                    SlidableAction(
                      onPressed: (cxt) {
                        showModalActionSheet<String>(
                          context: context,
                          actions: [
                            if (roomListVisible?.rooms?[position].isGroup ??
                                false)
                              SheetAction(
                                icon: Icons.remove_circle,
                                label: AppLocalizations.text(LangKey.leave),
                                key: 'Leave',
                              ),
                            if (Platform.isAndroid)
                              SheetAction(
                                  icon: Icons.cancel,
                                  label: AppLocalizations.text(LangKey.cancel),
                                  key: 'Cancel',
                                  isDestructiveAction: true)
                          ],
                        ).then((value) => value == 'Leave'
                            ? _leaveRoom(
                                roomListVisible?.rooms?[position].sId ?? '')
                            : () {});
                      },
                      autoClose: true,
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.remove_circle,
                      label: AppLocalizations.text(LangKey.leave),
                    ),
                  if (roomListVisible?.rooms?[position].owner?.sId ==
                              ChatConnection.user?.id &&
                          (roomListVisible?.rooms?[position].isGroup ??
                              false) ||
                      !(roomListVisible?.rooms?[position].isGroup ?? false))
                    SlidableAction(
                      onPressed: (cxt) {
                        showModalActionSheet<String>(
                          context: context,
                          actions: [
                            if (!(roomListVisible?.rooms?[position].isGroup ??
                                false))
                              SheetAction(
                                icon: Icons.remove_circle,
                                label: AppLocalizations.text(LangKey.delete),
                                key: 'Leave',
                              ),
                            if ((roomListVisible?.rooms?[position].isGroup ??
                                    false) &&
                                roomListVisible?.rooms?[position].owner?.sId ==
                                    ChatConnection.user?.id)
                              SheetAction(
                                icon: Icons.remove_circle,
                                label: AppLocalizations.text(LangKey.delete),
                                key: 'Delete',
                              ),
                            if (Platform.isAndroid)
                              SheetAction(
                                  icon: Icons.cancel,
                                  label: AppLocalizations.text(LangKey.cancel),
                                  key: 'Cancel',
                                  isDestructiveAction: true)
                          ],
                        ).then((value) => value == 'Delete'
                            ? _removeRoom(
                                roomListVisible?.rooms?[position].sId ?? '')
                            : value == 'Leave'
                                ? _removeLeaveRoom(
                                    roomListVisible?.rooms?[position].sId ?? '')
                                : () {});
                      },
                      autoClose: true,
                      backgroundColor: const Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: AppLocalizations.text(LangKey.delete),
                    ),
                ],
              ),
              child: () {
                final room = roomListVisible?.rooms?[position];
                if (room == null) return const SizedBox.shrink();
                return _room(room,
                    position == ((roomListVisible?.rooms?.length ?? 0) - 1));
              }())),
    );
  }

  void _leaveRoom(String roomId) {
    showDialog(
      context: context,
      builder: (cxt) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.leaveConversation)),
        content: Text(AppLocalizations.text(LangKey.leaveConfirm)),
        actions: [
          ElevatedButton(
              onPressed: () async {
                bool value = await ChatConnection.leaveRoom(
                    roomId, ChatConnection.user?.id);
                Navigator.of(cxt).pop();
                if (value) {
                  try {
                    ChatConnection.refreshRoom.call();
                    ChatConnection.refreshFavorites.call();
                  } catch (_) {}
                  _getRooms();
                } else {
                  showDialog(
                    context: context,
                    builder: (cxxt) => AlertDialog(
                      title: Text(AppLocalizations.text(LangKey.warning)),
                      content: Text(AppLocalizations.text(LangKey.leaveError)),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(cxxt);
                            },
                            child: Text(AppLocalizations.text(LangKey.accept)))
                      ],
                    ),
                  );
                }
              },
              child: Text(AppLocalizations.text(LangKey.leave))),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(cxt);
              },
              child: Text(AppLocalizations.text(LangKey.cancel))),
        ],
      ),
    );
  }

  void _removeLeaveRoom(String roomId) {
    showDialog(
      context: context,
      builder: (cxt) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.deleteConversation)),
        content: Text(AppLocalizations.text(LangKey.deleteConfirm)),
        actions: [
          ElevatedButton(
              onPressed: () {
                ChatConnection.leaveRoom(roomId, ChatConnection.user?.id)
                    .then((value) {
                  Navigator.of(cxt).pop();
                  if (value) {
                    _getRooms();
                  } else {
                    showDialog(
                      context: context,
                      builder: (cxxt) => AlertDialog(
                        title: Text(AppLocalizations.text(LangKey.warning)),
                        content:
                            Text(AppLocalizations.text(LangKey.deleteError)),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(cxxt);
                              },
                              child:
                                  Text(AppLocalizations.text(LangKey.accept)))
                        ],
                      ),
                    );
                  }
                });
              },
              child: Text(AppLocalizations.text(LangKey.delete))),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(cxt);
              },
              child: Text(AppLocalizations.text(LangKey.cancel))),
        ],
      ),
    );
  }

  void _removeRoom(String roomId) {
    showDialog(
      context: context,
      builder: (cxt) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.deleteConversation)),
        content: Text(AppLocalizations.text(LangKey.deleteConfirm)),
        actions: [
          ElevatedButton(
              onPressed: () {
                ChatConnection.removeRoom(roomId).then((value) {
                  Navigator.of(cxt).pop();
                  if (value) {
                    _getRooms();
                  } else {
                    showDialog(
                      context: context,
                      builder: (cxxt) => AlertDialog(
                        title: Text(AppLocalizations.text(LangKey.warning)),
                        content:
                            Text(AppLocalizations.text(LangKey.deleteError)),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(cxxt);
                              },
                              child:
                                  Text(AppLocalizations.text(LangKey.accept)))
                        ],
                      ),
                    );
                  }
                });
              },
              child: Text(AppLocalizations.text(LangKey.delete))),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(cxt);
              },
              child: Text(AppLocalizations.text(LangKey.cancel))),
        ],
      ),
    );
  }

  Widget _gptRoom(bool isLast) {
    return Column(
      children: [
        SizedBox(
          child: SizedBox(
            height: ChatConnection.isChatHub ? 80.0 : 50.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 25.0,
                    backgroundImage:
                        AssetImage('assets/icon-chat-gpt.png', package: 'chat'),
                    backgroundColor: Colors.transparent,
                  ),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 10.0),
                    child: const Text(
                      'ChatGPT',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ))
                ],
              ),
            ),
          ),
        ),
        !isLast
            ? Container(
                height: 5.0,
              )
            : Container(),
        !isLast
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  height: 1.0,
                  color: Colors.grey.shade300,
                ),
              )
            : Container()
      ],
    );
  }

  Widget _room(Rooms data, bool isLast) {
    Owner? owner;
    String? author = '';

    if (!ChatConnection.isChatHub) {
      owner = extractOwner(data);

      if (data.people != null && (data.people?.isNotEmpty ?? false)) {
        final matchLastAuthor =
            data.people?.where((e) => e.sId == data.lastAuthor);
        if (matchLastAuthor != null && matchLastAuthor.isNotEmpty) {
          Owner chatLastMessageOwner = Owner.fromPeople(matchLastAuthor.first);
          author = findAuthor(chatLastMessageOwner, data.lastMessage?.author);
        }
      }
    }

    if (!colorAppName.keys.contains(data.channel?.nameApp ?? '')) {
      Color color = RandomHexColor().colorRandom(data.channel?.nameApp ?? '');
      colorAppName[data.channel?.nameApp ?? ''] = color;
    }
    if (ChatConnection.isChatHub) {
      if (data.owner == null) {
        return Container();
      }

      return roomChatHubWidget(data, author ?? '', isLast);
    } else {
      return roomWidget(data, owner ?? Owner(), author, isLast);
    }
  }

  Widget roomWidget(Rooms data, Owner people, String? author, bool isLast) {
    return Column(
      children: [
        SizedBox(
          child: SizedBox(
            height: ChatConnection.isChatHub ? 80.0 : 50.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      !(data.isGroup ?? false)
                          ? (people.picture == null || people.picture == "")
                              ? CircleAvatar(
                                  radius: 25.0,
                                  backgroundColor: getAvatarColor(people.sId),
                                  child: Text(
                                    people.getAvatarName(),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                )
                              : CircleAvatar(
                                  radius: 25.0,
                                  backgroundImage: CachedNetworkImageProvider(
                                      '${HTTPConnection.domain}api/images/${people.picture}/256/${ChatConnection.brandCode ?? ''}',
                                      headers: {
                                        'brand-code':
                                            ChatConnection.brandCode ?? ''
                                      }),
                                  backgroundColor: Colors.transparent,
                                )
                          : ChatGroupAvatar(
                              people: data.people,
                              size: 50,
                            ),
                      if (!(data.isGroup ?? false) && _isOnline(people.sId))
                        Positioned(
                          right: 1,
                          bottom: 1,
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                !(data.isGroup ?? false)
                                    ? '${people.firstName ?? 'Unknow'} ${people.lastName ?? 'User'}'
                                    : data.title ??
                                        '${AppLocalizations.text(LangKey.group)} ${people.firstName ?? ''} ${people.lastName ?? ''}',
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                    fontWeight: findUnread(
                                                data.messagesReceived,
                                                data.messageUnSeen) !=
                                            '0'
                                        ? FontWeight.bold
                                        : FontWeight.normal),
                              ),
                            ),
                            AutoSizeText(
                              data.lastMessage?.lastMessageDate() ??
                                  data.createdDate(),
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        )),
                        Container(
                          height: 5.0,
                        ),
                        Expanded(
                            child: Row(
                          children: [
                            Expanded(
                                child: FutureBuilder<String>(
                              future: draftMessage(
                                  data.sId ?? '',
                                  '$author'
                                  '${checkTag(_checkContent(data), null)}'),
                              builder: (BuildContext context,
                                  AsyncSnapshot<String> snapshot) {
                                if (snapshot.hasData) {
                                  final text = snapshot.data;
                                  return ChatRoomWidget(content: text ?? "");
                                }
                                return Container();
                              },
                            )),
                            if (findUnread(data.messagesReceived,
                                    data.messageUnSeen) !=
                                '0')
                              CircleAvatar(
                                radius: 18.0,
                                child: Text(
                                  findUnread(data.messagesReceived,
                                      data.messageUnSeen),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                              )
                          ],
                        )),
                      ],
                    ),
                  ))
                ],
              ),
            ),
          ),
        ),
        !isLast
            ? Container(
                height: 5.0,
              )
            : Container(),
        !isLast
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  height: 1.0,
                  color: Colors.grey.shade300,
                ),
              )
            : Container()
      ],
    );
  }

  static const Map<String, String> _sourceIconMap = {
    'zalo': 'assets/icon-zalo.png',
    'zalo_personal': 'assets/icon_zalo_personal.png',
    'client': 'assets/icon_chat_client.png',
    'facebook': 'assets/icon-facebook.png',
    'whatsapp': 'assets/icon_whatsapp.png',
  };

  Widget _buildSingleAvatar(Rooms data) {
    const double radius = 25.0;
    final owner = data.owner;

    if (data.people?.first.avatar?.isNotEmpty == true)
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(
          '${data.people?.first.avatar}',
        ),
        backgroundColor: Colors.transparent,
      );

    if (owner?.picture == null || owner?.picture == '') {
      if (owner?.avatar != null && owner?.avatar != '') {
        return CircleAvatar(
          radius: radius,
          backgroundImage: CachedNetworkImageProvider(
            '${owner?.avatar}',
            headers: {'brand-code': ChatConnection.brandCode ?? ''},
          ),
          backgroundColor: Colors.transparent,
        );
      }
      return CircleAvatar(
        radius: radius,
        backgroundColor: getAvatarColor(owner?.sId),
        child: Text(
            getAvatarName(
                '${owner?.firstName ?? ''}', '${owner?.lastName ?? ''}'),
            style: const TextStyle(color: Colors.white)),
      );
    }

    if ((data.shieldedID != null && data.shieldedID != '') &&
        (data.shieldedID?.isNotEmpty ?? false)) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: Image(
            image: CachedNetworkImageProvider(
              '${HTTPConnection.domain}api/images/${data.shieldedID}/256/${ChatConnection.brandCode ?? ''}',
              headers: {'brand-code': ChatConnection.brandCode ?? ''},
            ),
            fit: BoxFit.cover,
            width: radius * 2,
            height: radius * 2,
            errorBuilder: (context, error, stackTrace) {
              return CircleAvatar(
                radius: radius,
                backgroundColor: getAvatarColor(data.people?.first.sId),
                child: Text(
                    getAvatarName('${data.people?.first.firstName ?? ''}',
                        '${data.people?.first.lastName ?? ''}'),
                    style: const TextStyle(color: Colors.white)),
              );
            },
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: getAvatarColor(owner?.sId),
      child: Text(
        getAvatarName('${owner?.firstName ?? ''}', '${owner?.lastName ?? ''}'),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildGroupAvatar(Rooms data) {
    // if (data.room_name?.isNotEmpty == true) {
    //   return CircleAvatar(
    //     radius: 25.0,
    //     child: Text(  '123',//getAvatarGroupName(data.room_name),
    //         style: const TextStyle(color: Colors.white)),
    //   );
    // }
    // else if (data.title?.isNotEmpty == true) {
    //   return CircleAvatar(
    //     radius: 25.0,
    //     child: Text(getAvatarGroupName(data.title?.split(' ').toString()),
    //         style: const TextStyle(color: Colors.white)),
    //   );
    // }
    return ChatGroupAvatar(
      people: data.people,
      size: 50,
    );
  }

  Widget? _buildSourceBadge(String? source) {
    final iconPath = _sourceIconMap[source];
    if (iconPath == null) return null;
    return Positioned(
      right: -7.0,
      bottom: -2.0,
      child: Padding(
        padding: const EdgeInsets.only(right: 6.0),
        child:
            Image.asset(iconPath, package: 'chat', width: 20.0, height: 20.0),
      ),
    );
  }

  Widget _buildNameRow(Rooms data) {
    final customerType =
        data.owner != null ? checkCustomerTypeChatHub(data.owner!) : null;
    final hasUnread =
        findUnread(data.messagesReceived, data.messageUnSeen) != '0';

    final roomName = !(data.isGroup ?? false)
        ? '${data.owner?.firstName} ${data.owner?.lastName}'
        : data.room_name ??
            data.title ??
            'Group ${data.owner?.firstName ?? ''} ${data.owner?.lastName ?? ''}';

    return Row(
      children: [
        if (customerType != null)
          Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: Image.asset(
              customerType == 'customer'
                  ? 'assets/icon-crown.png'
                  : 'assets/icon-star.png',
              package: 'chat',
              width: 15.0,
              height: 15.0,
            ),
          ),
        Expanded(
          child: Text(
            roomName,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: TextStyle(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal),
          ),
        ),
        AutoSizeText(
          data.lastMessage?.lastMessageDate() ?? data.createdDate(),
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom row: draft/last message preview + unread badge + blocked icon.
  // ---------------------------------------------------------------------------
  Widget _buildPreviewRow(Rooms data, String author) {
    final unread = findUnread(data.messagesReceived, data.messageUnSeen);
    return Row(
      children: [
        Expanded(
          child: FutureBuilder<String>(
            future: draftMessage(data.sId ?? '',
                '$author${checkTag(_checkContent(data), null)}'),
            builder: (context, snapshot) {
              return ChatRoomWidget(content: snapshot.data ?? '');
            },
          ),
        ),
        if (unread != '0')
          CircleAvatar(
            radius: 18.0,
            child: Text(unread,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        if (data.owner?.isBlocked == true)
          const Icon(Icons.block, color: Colors.red),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Channel name badge (only shown in ChatHub mode).
  // ---------------------------------------------------------------------------
  Widget _buildChannelBadge(Rooms data) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: colorAppName[data.channel?.nameApp ?? ''],
            borderRadius: BorderRadius.circular(10.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
          child: AutoSizeText(
            data.channel?.nameApp ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
            textScaleFactor: 0.85,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Main entry point — composes all the pieces above.
  // ---------------------------------------------------------------------------
  Widget roomChatHubWidget(Rooms data, String author, bool isLast) {
    final sourceBadge = _buildSourceBadge(data.source);

    return Column(
      children: [
        SizedBox(
          height: ChatConnection.isChatHub ? 80.0 : 50.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── Avatar + platform badge ──────────────────────────────────
                Stack(
                  children: [
                    data.isGroup == false
                        ? _buildSingleAvatar(data)
                        : _buildGroupAvatar(data),
                    if (sourceBadge != null) sourceBadge,
                  ],
                ),

                // ── Room info ────────────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 5.0, bottom: 5.0, left: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildNameRow(data)),
                        const SizedBox(height: 5.0),
                        Expanded(child: _buildPreviewRow(data, author)),
                        if (data.channel != null && ChatConnection.isChatHub)
                          Expanded(flex: 2, child: _buildChannelBadge(data)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast) ...[
          const SizedBox(height: 5.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(height: 1.0, color: Colors.grey.shade300),
          ),
        ],
      ],
    );
  }

  Future<String> draftMessage(String roomId, String content) async {
    Map<String, dynamic>? draft = await getDraftInput(roomId);
    if (draft != null) {
      return '[${AppLocalizations.text(LangKey.draft)}] ${draft['text'] ?? ''}';
    } else {
      return content;
    }
  }

  /// DEV
  String _checkContent(Rooms model) {
    if (model.lastMessage?.type == 'image') {
      return AppLocalizations.text(LangKey.sentPicture);
    }

    if (model.lastMessage?.type == 'file') {
      return AppLocalizations.text(LangKey.sendFile);
    }

    if ((model.lastMessage?.content ?? "").isEmpty) {
      return AppLocalizations.text(LangKey.forwardMessage);
    }
    return model.lastMessage?.content ?? '';
  }

  People getPeople(List<People>? people) {
    return people?.first.sId != ChatConnection.user?.id
        ? (people?.first ?? People())
        : (people?.last ?? People());
  }

  String findUnread(
      List<MessagesReceived>? messagesRecived, int? messageUnSeen) {
    if (!ChatConnection.isChatHub) {
      MessagesReceived? m;
      try {
        m = messagesRecived
            ?.firstWhere((e) => e.people == ChatConnection.user?.id);
        if ((m?.total ?? 0) > 99) {
          return '99+';
        }
        return '${m?.total ?? '0'}';
      } catch (_) {
        return '0';
      }
    } else {
      if (messageUnSeen == null) {
        return '0';
      } else {
        return '$messageUnSeen';
      }
    }
  }

  String? findAuthor(Owner? people, String? author,
      {bool isGroupOwner = false}) {
    Owner? p;
    try {
      p = people;
      return "${p?.sId != ChatConnection.user?.id ? ('${(p?.firstName ?? '').trim()} ${(p?.lastName ?? '').trim()}').trim() : AppLocalizations.text(LangKey.you)}: ";
    } catch (_) {
      return '';
    }
  }

  bool _isOnline(String? userId) {
    if (userId == null) return false;
    return ChatConnection.onlineUserIds.contains(userId);
  }

  @override
  bool get wantKeepAlive => true;
}
