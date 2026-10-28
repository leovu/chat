import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/chat_screen/home_screen.dart';
import 'package:chat/chat_screen/room_list_screen.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:chat/common/theme.dart';
import 'package:chat/common/widgets/glass_widgets.dart';
import 'package:flutter/material.dart';

class RoomListChathubScreen extends StatefulWidget {
  final RefreshBuilder builder;
  final Function? homeCallback;
  final Function? openCreateChatRoom;

  const RoomListChathubScreen(
      {Key? key,
      required this.builder,
      this.homeCallback,
      this.openCreateChatRoom})
      : super(key: key);

  @override
  _RoomListChathubScreenState createState() => _RoomListChathubScreenState();
}

class _RoomListChathubScreenState extends State<RoomListChathubScreen>
    with SingleTickerProviderStateMixin {
  late void Function() filterAll;
  late void Function() filterClient;
  late void Function() filterFacebook;
  late void Function() filterZalo;
  late TabController _tabController;
  late void Function() filterZaloPersonal;
  late void Function() filterWhatsApp;

  int _activeTabIndex = 0;
  Function? reloadAll;
  Function? reloadClient;
  Function? reloadFacebook;
  Function? reloadZalo;
  Function? reloadZaloPersonal;
  Function? reloadWhatsApp;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 6);
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
        backgroundColor: AppColors.surfaceColor,
        body: GlassBackground(
          child: SafeArea(
            top: false,
            child: Column(children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 44.0 + MediaQuery.paddingOf(context).top + 10.0,
                decoration: AppGlass.header(),
                padding: EdgeInsets.fromLTRB(
                    10.0, MediaQuery.paddingOf(context).top + 5.0, 10.0, 5.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(ChatConnection.buildContext).pop();
                      },
                      child: SizedBox(
                          width: 30.0,
                          child: Icon(
                              Icons.arrow_back_ios,
                              color: AppColors.white)),
                    ),
                    Text(AppLocalizations.text(LangKey.chats),
                        style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 17.0,
                            fontWeight: FontWeight.w600)),
                    Expanded(
                      child: Container(),
                    ),
                    GlassHeaderIconButton(
                      onTap: () {
                        if (_activeTabIndex == 0) {
                          filterAll.call();
                        } else if (_activeTabIndex == 1) {
                          filterClient.call();
                        } else if (_activeTabIndex == 2) {
                          filterFacebook.call();
                        } else if (_activeTabIndex == 3) {
                          filterZalo.call();
                        } else if (_activeTabIndex == 4) {
                          filterZaloPersonal.call();
                        } else if (_activeTabIndex == 5) {
                          filterWhatsApp.call();
                        }
                      },
                      icon: const Icon(Icons.filter_list),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  scrolledUnderElevation: 0.0,
                  elevation: 0.0,
                  bottom: TabBar(
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    controller: _tabController,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    dividerColor: Colors.transparent,
                    dividerHeight: 0,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding:
                        const EdgeInsets.symmetric(vertical: 6.0),
                    indicator: BoxDecoration(
                      color: AppGlass.surface,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                          color: AppColors.primaryColor.withValues(alpha: 0.4),
                          width: 1.0),
                      boxShadow: AppGlass.shadow,
                    ),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    tabs: [
                      SizedBox(
                        width: 70,
                        child: Tab(
                            icon: Row(
                          children: [
                            Image.asset(
                              'assets/icon_chat_all.png',
                              package: 'chat',
                              width: 30.0,
                              height: 30.0,
                            ),
                            Expanded(
                                child: AutoSizeText.rich(
                              TextSpan(children: [
                                TextSpan(
                                    text:
                                        '  ${AppLocalizations.text(LangKey.all)}',
                                    style:
                                        const TextStyle(color: AppColors.textStrongColor)),
                                if ((ChatConnection.notiChatHubAll ?? 0) > 0)
                                  TextSpan(
                                      text:
                                          ' (${ChatConnection.notiChatHubAll})',
                                      style: const TextStyle(
                                          color: AppColors.dangerColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                              ]),
                              maxLines: 1,
                            ))
                          ],
                        )),
                      ),
                      SizedBox(
                        width: 70,
                        child: Tab(
                            icon: Row(
                          children: [
                            Image.asset(
                              'assets/icon_chat_client.png',
                              package: 'chat',
                              width: 20.0,
                              height: 20.0,
                            ),
                            Expanded(
                                child: AutoSizeText.rich(
                                    TextSpan(children: [
                                      TextSpan(
                                          text:
                                              '  ${AppLocalizations.text(LangKey.client)}',
                                          style: const TextStyle(
                                              color: AppColors.textTitleColor)),
                                      if ((ChatConnection.notiChatHubClient ??
                                              0) >
                                          0)
                                        TextSpan(
                                            text:
                                                ' (${ChatConnection.notiChatHubClient})',
                                            style: const TextStyle(
                                                color: AppColors.dangerColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold))
                                    ]),
                                    maxLines: 1))
                          ],
                        )),
                      ),
                      SizedBox(
                        width: 80,
                        child: Tab(
                            icon: Row(
                          children: [
                            Image.asset(
                              'assets/icon-facebook-main.png',
                              package: 'chat',
                              width: 20.0,
                              height: 20.0,
                            ),
                            Expanded(
                                child: AutoSizeText.rich(
                                    TextSpan(children: [
                                      const TextSpan(
                                          text: '  Facebook',
                                          style: TextStyle(
                                            color: AppColors.textStrongColor,
                                          )),
                                      if ((ChatConnection.notiChatHubFacebook ??
                                              0) >
                                          0)
                                        TextSpan(
                                            text:
                                                ' (${ChatConnection.notiChatHubFacebook})',
                                            style: const TextStyle(
                                                color: AppColors.dangerColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold))
                                    ]),
                                    maxLines: 1))
                          ],
                        )),
                      ),
                      SizedBox(
                        width: 70,
                        child: Tab(
                            icon: Row(
                          children: [
                            Image.asset(
                              'assets/icon-zalo.png',
                              package: 'chat',
                              width: 20.0,
                              height: 20.0,
                            ),
                            Expanded(
                                child: AutoSizeText.rich(
                                    TextSpan(children: [
                                      const TextSpan(
                                          text: '  Zalo',
                                          style:
                                              TextStyle(color: AppColors.textStrongColor)),
                                      if ((ChatConnection.notiChatHubZalo ??
                                              0) >
                                          0)
                                        TextSpan(
                                            text:
                                                ' (${ChatConnection.notiChatHubZalo})',
                                            style: const TextStyle(
                                                color: AppColors.dangerColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold))
                                    ]),
                                    maxLines: 1))
                          ],
                        )),
                      ),
                      SizedBox(
                        width: 70,
                        child: Tab(
                            icon: Row(
                          children: [
                            Image.asset(
                              'assets/icon_zalo_personal.png',
                              package: 'chat',
                              width: 20.0,
                              height: 20.0,
                            ),
                            Expanded(
                                child: AutoSizeText.rich(
                                    TextSpan(children: [
                                      const TextSpan(
                                          text: '  Zalo',
                                          style:
                                              TextStyle(color: AppColors.textStrongColor)),
                                      if ((ChatConnection
                                                  .notiChatHubZaloPersonal ??
                                              0) >
                                          0)
                                        TextSpan(
                                            text:
                                                ' (${ChatConnection.notiChatHubZaloPersonal})',
                                            style: const TextStyle(
                                                color: AppColors.dangerColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold))
                                    ]),
                                    maxLines: 1))
                          ],
                        )),
                      ),
                      //Whatsapp
                      SizedBox(
                        width: 90,
                        child: Tab(
                            icon: Row(
                          children: [
                            Image.asset(
                              'assets/icon_whatsapp.png',
                              package: 'chat',
                              width: 20.0,
                              height: 20.0,
                            ),
                            Expanded(
                                child: AutoSizeText.rich(
                                    TextSpan(children: [
                                      const TextSpan(
                                          text: '  WhatsApp',
                                          style:
                                              TextStyle(color: AppColors.textStrongColor)),
                                      if ((ChatConnection.notiChatHubWhatsApp ??
                                              0) >
                                          0)
                                        TextSpan(
                                            text:
                                                ' (${ChatConnection.notiChatHubWhatsApp})',
                                            style: const TextStyle(
                                                color: AppColors.dangerColor,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold))
                                    ]),
                                    maxLines: 1))
                          ],
                        )),
                      ),
                    ],
                  ),
                ),
              ),
              body: Column(
                children: [
                  if (ChatConnection.isChatHub)
                    const SizedBox(height: 3.0),
                  Expanded(
                      child: TabBarView(controller: _tabController, children: [
                    ///Chathub all
                    RoomListScreen(
                      builder: (BuildContext context, void Function() method) {
                        reloadAll = method;
                      },
                      openCreateChatRoom: widget.openCreateChatRoom,
                      chatHubBuilder: (void Function() filter) {
                        filterAll = filter;
                      },
                      refreshTabNoti: refreshTabNoti,
                    ),

                    /// Chathub live chat
                    RoomListScreen(
                      builder: (BuildContext context, void Function() method) {
                        reloadClient = method;
                      },
                      openCreateChatRoom: widget.openCreateChatRoom,
                      source: 'client',
                      chatHubBuilder: (void Function() filter) {
                        filterClient = filter;
                      },
                      refreshTabNoti: refreshTabNoti,
                    ),

                    ///Chathub facebook
                    RoomListScreen(
                      builder: (BuildContext context, void Function() method) {
                        reloadFacebook = method;
                      },
                      openCreateChatRoom: widget.openCreateChatRoom,
                      source: 'facebook',
                      chatHubBuilder: (void Function() filter) {
                        filterFacebook = filter;
                      },
                      refreshTabNoti: refreshTabNoti,
                    ),

                    ///Chathub zalo
                    RoomListScreen(
                      builder: (BuildContext context, void Function() method) {
                        reloadZalo = method;
                      },
                      openCreateChatRoom: widget.openCreateChatRoom,
                      source: 'zalo',
                      chatHubBuilder: (void Function() filter) {
                        filterZalo = filter;
                      },
                      refreshTabNoti: refreshTabNoti,
                    ),

                    ///ChatHub Zalo Personal
                    RoomListScreen(
                      builder: (BuildContext context, void Function() method) {
                        reloadZaloPersonal = method;
                      },
                      openCreateChatRoom: widget.openCreateChatRoom,
                      source: 'zalo_personal',
                      chatHubBuilder: (void Function() filter) {
                        filterZaloPersonal = filter;
                      },
                      refreshTabNoti: refreshTabNoti,
                    ),

                    ///ChatHub WhatsApp
                    RoomListScreen(
                      builder: (BuildContext context, void Function() method) {
                        reloadWhatsApp = method;
                      },
                      openCreateChatRoom: widget.openCreateChatRoom,
                      source: 'whatsapp',
                      chatHubBuilder: (void Function() filter) {
                        filterWhatsApp = filter;
                      },
                      refreshTabNoti: refreshTabNoti,
                    )
                  ])),
                  if (ChatConnection.isChatHub)
                    const SizedBox(height: 3.0),
                ],
              ),
            ),
          )
        ])),
        ),
      ),
    );
  }

  void refresh() {
    if (reloadAll != null) {
      reloadAll!();
    }
    if (reloadClient != null) {
      reloadClient!();
    }
    if (reloadFacebook != null) {
      reloadFacebook!();
    }
    if (reloadZalo != null) {
      reloadZalo!();
    }
    if (reloadZaloPersonal != null) {
      reloadZaloPersonal!();
    }
    if (reloadWhatsApp != null) {
      reloadWhatsApp!();
    }
    refreshTabNoti();
  }

  void refreshTabNoti() {
    setState(() {});
  }
}
