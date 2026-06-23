import 'dart:convert';
import 'dart:ui';
import 'package:chat/common/global.dart';
import 'package:chat/common/shared_prefs/shared_prefs_key.dart';
import 'package:chat/common/widgets/liquid_glass_tab_bar.dart';
import 'package:chat/presentation/chat_module/ui/chat_screen.dart';
import 'package:chat/chat_screen/chathub_room_list_screen.dart';
import 'package:chat/chat_screen/contacts_screen.dart';
import 'package:chat/chat_screen/create_group_screen.dart';
import 'package:chat/chat_screen/favorite_screen.dart';
import 'package:chat/chat_screen/notification_screen.dart';
import 'package:chat/chat_screen/room_list_screen.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/services/notification_service.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/check_tag.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/room.dart' as r;
import 'package:chat/connection/app_lifecycle.dart';

typedef RefreshBuilder = void Function(
    BuildContext context, void Function() refresh);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends AppLifeCycle<HomeScreen> {
  int _chatTabIndex = 0;
  int _chatHubTabIndex = 0;

  @override
  void initState() {
    super.initState();

    /// SET LANGUAGE
    try {
      AppLocalizations.delegate
          .load(Locale(Globals.prefs!.getString(SharedPrefsKey.language)));
    } catch (e) {
      AppLocalizations.delegate.load(Locale('vi'));
    }
    ChatConnection.homeScreenNotificationHandler = _notificationHandler;
    ChatConnection.listenChat(_getRooms);
    ChatConnection.notificationList();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (ChatConnection.initialData != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        _notificationHandler(Map.from(ChatConnection.initialData!));
        ChatConnection.initialData = null;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    ChatConnection.dispose(isDispose: true);
  }

  @override
  Widget build(BuildContext context) {
    return ChatConnection.isChatHub ? _chatHub() : _chat();
  }

  Widget _chatHub() {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _chatHubTabIndex,
        children: [
          ChatConnection.isChatHub
              ? RoomListChathubScreen(
                  builder: (BuildContext context, void Function() method) {
                    ChatConnection.refreshRoom = method;
                  },
                  openCreateChatRoom: _openCreateRoom,
                )
              : RoomListScreen(
                  builder: (BuildContext context, void Function() method) {
                    ChatConnection.refreshRoom = method;
                  },
                  openCreateChatRoom: _openCreateRoom,
                ),
          NotificationScreen(
            builder: (BuildContext context, void Function() method) {
              ChatConnection.refreshNotifications = method;
            },
            homeCallback: () {
              try {
                ChatConnection.refreshRoom.call();
              } catch (_) {}
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildChatHubTabBar(),
    );
  }

  Widget _buildChatHubTabBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            border: Border(
              top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.4), width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: ValueListenableBuilder<String>(
                valueListenable: ChatConnection.notificationNotifier,
                builder: (context, notifValue, _) {
                  final notifCount = int.tryParse(notifValue) ?? 0;
                  return LiquidGlassTabBar(
                    selectedIndex: _chatHubTabIndex,
                    expandItems: true,
                    equalWidth: true,
                    onTabChanged: (index, item) {
                      if (index == 1) {
                        try {
                          ChatConnection.refreshNotifications.call();
                        } catch (_) {}
                      }
                      setState(() => _chatHubTabIndex = index);
                    },
                    items: [
                      LiquidGlassTabItem(
                        iconData: Icons.chat,
                        title: AppLocalizations.text(LangKey.chats),
                      ),
                      LiquidGlassTabItem(
                        iconData: Icons.notifications,
                        title: AppLocalizations.text(LangKey.notifications),
                        badgeCount: notifCount,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chat() {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _chatTabIndex,
        children: [
          RoomListScreen(
            builder: (BuildContext context, void Function() method) {
              ChatConnection.refreshRoom = method;
            },
            openCreateChatRoom: _openCreateRoom,
          ),
          ContactsScreen(
            builder: (BuildContext context, void Function() method) {
              ChatConnection.refreshContact = method;
            },
          ),
          FavoriteScreen(
            builder: (BuildContext context, void Function() method) {
              ChatConnection.refreshFavorites = method;
            },
            homeCallback: () {
              try {
                ChatConnection.refreshRoom.call();
              } catch (_) {}
            },
          ),
          NotificationScreen(
            builder: (BuildContext context, void Function() method) {
              ChatConnection.refreshNotifications = method;
            },
            homeCallback: () {
              try {
                ChatConnection.refreshRoom.call();
              } catch (_) {}
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildChatTabBar(),
    );
  }

  Widget _buildChatTabBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            border: Border(
              top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.4), width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: ValueListenableBuilder<String>(
                valueListenable: ChatConnection.notificationNotifier,
                builder: (context, notifValue, _) {
                  final notifCount = int.tryParse(notifValue) ?? 0;
                  return LiquidGlassTabBar(
                    selectedIndex: _chatTabIndex,
                    expandItems: true,
                    onTabChanged: (index, item) {
                      if (index == 3) {
                        try {
                          ChatConnection.refreshNotifications.call();
                        } catch (_) {}
                      }
                      setState(() => _chatTabIndex = index);
                    },
                    items: [
                      LiquidGlassTabItem(
                        iconData: Icons.chat,
                        title: AppLocalizations.text(LangKey.chats),
                      ),
                      LiquidGlassTabItem(
                        iconData: Icons.contact_mail,
                        title: AppLocalizations.text(LangKey.contacts),
                      ),
                      LiquidGlassTabItem(
                        iconData: Icons.star_border,
                        title: AppLocalizations.text(LangKey.favorites),
                      ),
                      LiquidGlassTabItem(
                        iconData: Icons.notifications,
                        title: AppLocalizations.text(LangKey.notifications),
                        badgeCount: notifCount,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  _openCreateRoom() {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    );
  }

  _getRooms(dynamic data) {
    Map<String, dynamic> notificationData =
        json.decode(json.encode(data)) as Map<String, dynamic>;
    if (ChatConnection.roomId == null) {
      ChatConnection.showNotification(
          NotificationService.buildTitle(notificationData),
          checkTag(notificationData['message']['content'], null),
          notificationData,
          ChatConnection.appIcon,
          _notificationHandler);
      try {
        ChatConnection.refreshRoom.call();
        ChatConnection.refreshFavorites.call();
      } catch (_) {}
    }
  }

  Future<dynamic> _notificationHandler(Map<String, dynamic> message) async {
    r.Room? room = await ChatConnection.roomList();
    try {
      r.Rooms? rooms = room?.rooms
          ?.firstWhere((element) => element.sId == message['room']['_id']);
      await Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
            builder: (context) => ChatScreen(
                  data: rooms!,
                  source: rooms.source,
                ),
            settings: const RouteSettings(name: 'chat_screen')),
      );
    } catch (_) {}
    try {
      ChatConnection.refreshRoom.call();
      ChatConnection.refreshContact.call();
      ChatConnection.refreshFavorites.call();
    } catch (_) {}
  }
}

class RestartWidget extends StatefulWidget {
  RestartWidget({super.key, required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}
