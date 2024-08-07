import 'dart:convert';
import 'package:chat/common/global.dart';
import 'package:chat/common/shared_prefs/shared_prefs_key.dart';
import 'package:chat/presentation/chat_module/ui/chat_screen.dart';
import 'package:chat/chat_screen/chathub_room_list_screen.dart';
import 'package:chat/chat_screen/contacts_screen.dart';
import 'package:chat/chat_screen/create_group_screen.dart';
import 'package:chat/chat_screen/favorite_screen.dart';
import 'package:chat/chat_screen/notification_screen.dart';
import 'package:chat/chat_screen/room_list_screen.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/check_tag.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/room.dart' as r;
import 'package:chat/connection/app_lifecycle.dart';
import 'package:badges/badges.dart' as bdg;

typedef RefreshBuilder = void Function(BuildContext context, void Function() refresh);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}
class _HomeScreenState extends AppLifeCycle<HomeScreen> {
  @override
  void initState() {
    super.initState();
    /// SET LANGUAGE
    try{
      AppLocalizations.delegate.load(Locale(Globals.prefs!.getString(SharedPrefsKey.language)));
    } catch (e){
      AppLocalizations.delegate.load(Locale('vi'));
    }
    ChatConnection.homeScreenNotificationHandler = _notificationHandler;
    ChatConnection.listenChat(_getRooms);
    ChatConnection.notificationList();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(ChatConnection.initialData != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        _notificationHandler(Map.from(ChatConnection.initialData!));
        ChatConnection.initialData = null;
      }
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    ChatConnection.dispose(isDispose: true);
  }
  @override
  Widget build(BuildContext context) {
    return ChatConnection.isChatHub ? _chatHub() : _chat();
  }
  Widget _chatHub() {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        onTap: (index) {
          if(index == 1) {
            try{
              ChatConnection.refreshNotifications.call();
            }catch(_) {}
          }
        },
        backgroundColor: Colors.white,
        activeColor: const Color(0xff9012FE),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.chat),
              label: AppLocalizations.text(LangKey.chats)
          ),
          BottomNavigationBarItem(
              icon: ValueListenableBuilder(
                builder: (BuildContext context, value, Widget? child) {
                  return bdg.Badge(
                    badgeContent: Text('$value',style: const TextStyle(color: Colors.white,fontSize: 10)),
                    showBadge: value == '0' ? false : true,
                    badgeAnimation: const bdg.BadgeAnimation.rotation(
                      toAnimate: false,
                    ),
                    badgeStyle: const bdg.BadgeStyle(
                      badgeColor: Colors.red,
                    ),
                    child: const Icon(Icons.notifications),
                  );
                },
                valueListenable: ChatConnection.notificationNotifier,
              ),
              label: AppLocalizations.text(LangKey.notifications)
          ),
        ],
      ),
      tabBuilder: (context, index) {
        if (index == 0) {
          return CupertinoTabView(
            builder: (BuildContext context) =>
                ChatConnection.isChatHub ? RoomListChathubScreen(builder: (BuildContext context, void Function() method) {
                  ChatConnection.refreshRoom = method;
                },openCreateChatRoom: _openCreateRoom,) :
                RoomListScreen(builder: (BuildContext context, void Function() method) {
                  ChatConnection.refreshRoom = method;
                },openCreateChatRoom: _openCreateRoom,),
          );
        } else {
          return CupertinoTabView(
            builder: (BuildContext context) =>  NotificationScreen(builder: (BuildContext context, void Function() method) {
              ChatConnection.refreshNotifications = method;
            },homeCallback: ChatConnection.refreshRoom.call),
          );
        }
      },
    );
  }
  Widget _chat() {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        onTap: (index) {
          if(index == 3) {
            try{
              ChatConnection.refreshNotifications.call();
            }catch(_) {}
          }
        },
        backgroundColor: Colors.white,
        activeColor: const Color(0xff9012FE),
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.chat),
              label: AppLocalizations.text(LangKey.chats)
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.contact_mail),
              label: AppLocalizations.text(LangKey.contacts)
          ),
          BottomNavigationBarItem(
              icon: const Icon(Icons.star_border),
              label: AppLocalizations.text(LangKey.favorites)
          ),
          BottomNavigationBarItem(
              icon: ValueListenableBuilder(
                builder: (BuildContext context, value, Widget? child) {
                  return bdg.Badge(
                    badgeContent: Text(value,style: const TextStyle(color: Colors.white,fontSize: 10)),
                    showBadge: value == '0' ? false : true,
                    badgeAnimation: const bdg.BadgeAnimation.rotation(
                      toAnimate: false,
                    ),
                    badgeStyle: const bdg.BadgeStyle(
                      badgeColor: Colors.red,
                    ),
                    child: const Icon(Icons.notifications),
                  );
                },
                valueListenable: ChatConnection.notificationNotifier,
              ),
              label: AppLocalizations.text(LangKey.notifications)
          ),
        ],
      ),
      tabBuilder: (context, index) {
        if (index == 0) {
          return CupertinoTabView(
            builder: (BuildContext context) =>  RoomListScreen(builder: (BuildContext context, void Function() method) {
              ChatConnection.refreshRoom = method;
            },openCreateChatRoom: _openCreateRoom,),
          );
        } if (index == 1) {
          return CupertinoTabView(
              builder: (BuildContext context) => ContactsScreen(builder: (BuildContext context, void Function() method) {
                ChatConnection.refreshContact = method;
              })
          );
        } if (index == 2) {
          return CupertinoTabView(
            builder: (BuildContext context) =>  FavoriteScreen(builder: (BuildContext context, void Function() method) {
              ChatConnection.refreshFavorites = method;
            },homeCallback: ChatConnection.refreshRoom.call),
          );
        } else {
          return CupertinoTabView(
            builder: (BuildContext context) =>  NotificationScreen(builder: (BuildContext context, void Function() method) {
              ChatConnection.refreshNotifications = method;
            },homeCallback: ChatConnection.refreshRoom.call),
          );
        }
      },
    );
  }
  _openCreateRoom() {
    Navigator.of(context,rootNavigator: true).push(
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    );
  }
  _getRooms(dynamic data) {
    Map<String,dynamic> notificationData = json.decode(json.encode(data)) as Map<String, dynamic>;
    if(ChatConnection.roomId == null) {
      ChatConnection.showNotification(
          notificationData['room']['isGroup'] == true ?
          '${notificationData['message']['author']['firstName']} ${notificationData['message']['author']['lastName']} in ${notificationData['room']['title']}'
          : '${notificationData['message']['author']['firstName']} ${notificationData['message']['author']['lastName']}',
          checkTag(notificationData['message']['content'],null),
          notificationData, ChatConnection.appIcon, _notificationHandler);
      try{
        ChatConnection.refreshRoom.call();
        ChatConnection.refreshFavorites.call();
      }catch(_){}
    }
  }

  Future<dynamic> _notificationHandler(Map<String, dynamic> message) async {
    r.Room? room = await ChatConnection.roomList();
    try{
      r.Rooms? rooms = room?.rooms?.firstWhere((element) => element.sId == message['room']['_id']);
      await Navigator.of(context,rootNavigator: true).push(
        MaterialPageRoute(builder: (context) => ChatScreen(data: rooms!,source: rooms.source,),settings:const RouteSettings(name: 'chat_screen')),
      );
    }catch(_){
    }
    try{
      ChatConnection.refreshRoom.call();
      ChatConnection.refreshContact.call();
      ChatConnection.refreshFavorites.call();
    }catch(_){}
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
