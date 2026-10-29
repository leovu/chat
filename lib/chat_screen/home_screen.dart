import 'dart:convert';
import 'package:chat/common/global.dart';
import 'package:chat/common/theme.dart';
import 'package:chat/common/shared_prefs/shared_prefs_key.dart';
import 'package:chat/common/widgets/scroll_hide.dart';
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
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart' as lg;
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
    ScrollHideController.show();

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
      bottomNavigationBar: ScrollHideSlide(child: _buildChatHubTabBar()),
    );
  }

  Widget _buildChatHubTabBar() {
    return ValueListenableBuilder<String>(
      valueListenable: ChatConnection.notificationNotifier,
      builder: (context, notifValue, _) {
        final notifCount = int.tryParse(notifValue) ?? 0;
        return _buildGlassTabBar(
          selectedIndex: _chatHubTabIndex,
          onTabSelected: (index) {
            if (index == 1) {
              try {
                ChatConnection.refreshNotifications.call();
              } catch (_) {}
            }
            ScrollHideController.show();
            setState(() => _chatHubTabIndex = index);
          },
          tabs: [
            _buildGlassTab(Icons.chat, AppLocalizations.text(LangKey.chats)),
            _buildGlassTab(Icons.notifications,
                AppLocalizations.text(LangKey.notifications),
                badge: notifCount),
          ],
        );
      },
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
      bottomNavigationBar: ScrollHideSlide(child: _buildChatTabBar()),
    );
  }

  Widget _buildChatTabBar() {
    return ValueListenableBuilder<String>(
      valueListenable: ChatConnection.notificationNotifier,
      builder: (context, notifValue, _) {
        final notifCount = int.tryParse(notifValue) ?? 0;
        return _buildGlassTabBar(
          selectedIndex: _chatTabIndex,
          onTabSelected: (index) {
            if (index == 3) {
              try {
                ChatConnection.refreshNotifications.call();
              } catch (_) {}
            }
            ScrollHideController.show();
            setState(() => _chatTabIndex = index);
          },
          tabs: [
            _buildGlassTab(Icons.chat, AppLocalizations.text(LangKey.chats)),
            _buildGlassTab(
                Icons.contact_mail, AppLocalizations.text(LangKey.contacts)),
            _buildGlassTab(
                Icons.star_border, AppLocalizations.text(LangKey.favorites)),
            _buildGlassTab(Icons.notifications,
                AppLocalizations.text(LangKey.notifications),
                badge: notifCount),
          ],
        );
      },
    );
  }

  Widget _buildGlassTabBar(
      {required int selectedIndex,
      required ValueChanged<int> onTabSelected,
      required List<lg.GlassTab> tabs}) {
    return SafeArea(
      top: false,
      child: lg.GlassTabBar.bottom(
        selectedIndex: selectedIndex,
        onTabSelected: onTabSelected,
        barHeight: 60.0,
        horizontalPadding: 12.0,
        verticalPadding: 6.0,
        settings: AppGlass.barSettings,
        selectedIconColor: AppColors.primaryColor,
        unselectedIconColor: AppColors.textSecondaryColor,
        selectedLabelColor: AppColors.primaryColor,
        unselectedLabelColor: AppColors.textSecondaryColor,
        tabs: tabs,
      ),
    );
  }

  lg.GlassTab _buildGlassTab(IconData icon, String label, {int badge = 0}) {
    return lg.GlassTab(
      icon: _buildBadgeIcon(icon, badge),
      label: label,
    );
  }

  Widget _buildBadgeIcon(IconData icon, int badge) {
    if (badge <= 0) {
      return Icon(icon);
    }
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        Positioned(
          right: -10.0,
          top: -6.0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 1.0),
            decoration: BoxDecoration(
              color: AppColors.dangerColor,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.white, width: 1.0),
            ),
            child: Text(
              badge > 999 ? '999+' : '$badge',
              style: const TextStyle(
                  fontSize: 10.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
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
