import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/chat_screen/home_screen.dart';
import 'package:chat/chat_screen/room_list_screen.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/material.dart';

class RoomListChathubScreen extends StatefulWidget {
  final RefreshBuilder builder;
  final Function? homeCallback;
  final Function? openCreateChatRoom;
  const RoomListChathubScreen({Key? key, required this.builder, this.homeCallback , this.openCreateChatRoom}) : super(key: key);
  @override
  _RoomListChathubScreenState createState() => _RoomListChathubScreenState();
}

class _RoomListChathubScreenState extends State<RoomListChathubScreen> with SingleTickerProviderStateMixin {
  late void Function() filterAll;
  late void Function() filterFacebook;
  late void Function() filterZalo;
  late TabController _tabController;
  int _activeTabIndex = 0;
  Function? reloadAll;
  Function? reloadFacebook;
  Function? reloadZalo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
    _tabController.addListener(_setActiveTabIndex);
    ChatConnection.refreshRoom = refresh;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setActiveTabIndex() {
    _activeTabIndex = _tabController.index;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Column(children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 30.0,
                    margin: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.of(ChatConnection.buildContext).pop();
                          },
                          child: SizedBox(
                              width:30.0,
                              child: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.black)),
                        ),
                        Expanded(child: Container(),),
                        InkWell(
                          onTap: () {
                            if(_activeTabIndex == 0) {
                              filterAll.call();
                            }
                            else if(_activeTabIndex == 1) {
                              filterFacebook.call();
                            }
                            else if(_activeTabIndex == 2) {
                              filterZalo.call();
                            }
                          },
                          child: const SizedBox(
                              width:30.0,
                              child: Icon(Icons.filter_list, color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Scaffold(
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: AppBar(
                      backgroundColor: Colors.white,
                      elevation: 0.0,
                      bottom: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.blue,
                        tabs: [
                          Tab(icon: Row(
                            children: [
                              Image.asset('assets/icon-chathub-main.png',package: 'chat',width: 30.0,height: 30.0,),
                              Expanded(child: AutoSizeText.rich(TextSpan(
                                children: [
                                  TextSpan(
                                    text: ' ${AppLocalizations.text(LangKey.all)}',
                                    style: const TextStyle(color: Colors.black)
                                  ),
                                  if((ChatConnection.notiChatHubAll??0) > 0) TextSpan(
                                        text: ' (${ChatConnection.notiChatHubAll})',
                                        style: const TextStyle(color: Colors.red,fontSize: 12,fontWeight: FontWeight.bold)
                                  ),
                                ]
                              ),maxLines: 1,))
                            ],
                          )),
                          Tab(icon: Row(
                            children: [
                              Image.asset('assets/icon-facebook-main.png',package: 'chat',width: 20.0,height: 20.0,),
                              Expanded(child:
                              AutoSizeText.rich(TextSpan(
                                  children: [
                                    const TextSpan(
                                        text: '  Facebook',
                                        style: TextStyle(color: Colors.black)
                                    ),
                                    if((ChatConnection.notiChatHubFacebook??0) > 0) TextSpan(
                                        text: ' (${ChatConnection.notiChatHubFacebook})',
                                        style: const TextStyle(color: Colors.red,fontSize: 12,fontWeight: FontWeight.bold)
                                    )
                                  ]
                              ),maxLines: 1))
                            ],
                          )),
                          Tab(icon: Row(
                            children: [
                              Image.asset('assets/icon-zalo.png',package: 'chat',width: 20.0,height: 20.0,),
                              Expanded(child:
                              AutoSizeText.rich(TextSpan(
                                  children: [
                                    const TextSpan(
                                        text: '   Zalo',
                                        style: TextStyle(color: Colors.black)
                                    ),
                                    if((ChatConnection.notiChatHubZalo??0) > 0) TextSpan(
                                        text: ' (${ChatConnection.notiChatHubZalo})',
                                        style: const TextStyle(color: Colors.red,fontSize: 12,fontWeight: FontWeight.bold)
                                    )
                                  ]
                              ),maxLines: 1))
                            ],
                          )),
                        ],
                      ),
                    ),
                  ),
                  body: Column(
                    children: [
                      if (ChatConnection.isChatHub) Container(height: 3.0,color: Colors.grey.shade200,),
                      Expanded(child: TabBarView(
                          controller: _tabController,
                          children: [
                            RoomListScreen(builder: (BuildContext context, void Function() method) {
                              reloadAll = method;
                            },openCreateChatRoom: widget.openCreateChatRoom,chatHubBuilder: (void Function() filter) {
                              filterAll = filter;
                            },refreshTabNoti: refreshTabNoti,),
                            RoomListScreen(builder: (BuildContext context, void Function() method) {
                              reloadFacebook = method;
                            },openCreateChatRoom: widget.openCreateChatRoom,source: 'facebook',
                                chatHubBuilder: (void Function() filter) {
                                  filterFacebook = filter;
                                },refreshTabNoti: refreshTabNoti,),
                            RoomListScreen(builder: (BuildContext context, void Function() method) {
                              reloadZalo = method;
                            },openCreateChatRoom: widget.openCreateChatRoom,source: 'zalo',
                                chatHubBuilder: (void Function() filter) {
                                  filterZalo = filter;
                                },refreshTabNoti: refreshTabNoti,)
                          ]
                      )),
                      if (ChatConnection.isChatHub) Container(height: 3.0,color: Colors.grey.shade200,),
                    ],
                  ),
                ),
              )]
            )),
      ),
    );
  }
  void refresh() {
    if(reloadAll != null) {
      reloadAll!();
    }
    if(reloadFacebook != null) {
      reloadFacebook!();
    }
    if(reloadZalo != null) {
      reloadZalo!();
    }
    refreshTabNoti();
  }
  void refreshTabNoti() {
    setState(() {});
  }
}