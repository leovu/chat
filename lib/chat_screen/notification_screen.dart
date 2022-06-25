import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_screen/chat_screen.dart';
import 'package:chat/chat_screen/home_screen.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/notifications.dart' as n;
import 'package:chat/data_model/room.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class NotificationScreen extends StatefulWidget {
  final Function? homeCallback;
  final RefreshBuilder builder;
  const NotificationScreen({Key? key,  required this.builder, this.homeCallback}) : super(key: key);
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with AutomaticKeepAliveClientMixin {

  n.Notifications? notificationListData;
  bool isInitScreen = true;

  @override
  void initState() {
    super.initState();
    _getNotifications();
  }
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    await _getNotifications();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    await _getNotifications();
    _refreshController.loadComplete();
  }
  _getNotifications() async {
    if(mounted) {
      notificationListData = await ChatConnection.notificationList();
      isInitScreen = false;
      setState(() {});
    }
    else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        notificationListData = await ChatConnection.notificationList();
        isInitScreen = false;
        if(mounted) {
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.builder.call(context, _getNotifications);
    super.build(context);
    return Scaffold(
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 3.0,left: 10.0,right: 10.0),
                child: Text(AppLocalizations.text(LangKey.notifications),style: const TextStyle(fontSize: 25.0,color: Colors.black)),
              ),
            ],
          ),
          Expanded(
            child:
            isInitScreen ? Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator()) :
            notificationListData?.notifications != null ? SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              header: const WaterDropHeader(),
              child: ListView.builder(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: notificationListData!.notifications?.length,
                  itemBuilder: (BuildContext context, int position) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: InkWell(
                          onTap: () async {
                            ChatConnection.readNotification(notificationListData!.notifications![position].sId!);
                            try{
                              Room? room = await ChatConnection.roomList();
                              Rooms? rooms = room?.rooms?.firstWhere((element) => element.sId == notificationListData!.notifications![position].actionParams!.message!.room);
                              await Navigator.of(context,rootNavigator: true).push(MaterialPageRoute(builder: (context) => ChatScreen(data: rooms!),settings:const RouteSettings(name: 'chat_screen')),);
                            }catch(_) {}
                            if(widget.homeCallback != null) {
                              widget.homeCallback!();
                            }
                            _getNotifications();
                          },
                          child: _notification(notificationListData!.notifications![position], position == notificationListData!.notifications!.length-1)),
                    );
                  }),
            ) : Container(),
          )
        ],),
      ),
    );
  }
  Widget _notification(n.Notification data, bool isLast) {
    return Column(
      children: [
        SizedBox(
          height: 50.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                data.createdBy?.picture == null ? CircleAvatar(
                  radius: 20.0,
                  child: Text(data.createdBy!.getAvatarName()),
                ) : CircleAvatar(
                  radius: 20.0,
                  backgroundImage:
                  CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${data.createdBy!.picture!.shieldedID}/256'),
                  backgroundColor: Colors.transparent,
                ),
                Expanded(child: Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Opacity(
                                opacity: data.isRead == 0 ? 1.0 : 0.3,
                                child: dataMessage(data.messageData ?? ''))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: AutoSizeText(data.createMessageDate(),style: const TextStyle(fontSize: 11,color: Colors.grey),),
                            ),
                          ],
                        )
                      ),
                    ],
                  ),
                ))
              ],
            ),
          ),
        ),
        !isLast ? Container(height: 5.0,) : Container(),
        !isLast ?  Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Container(height: 1.0,color: Colors.grey.shade300,),
        ) : Container(),
      ],
    );
  }
  Widget dataMessage(String value) {
    Widget _widget;
    if(value.contains('@mentioned')) {
      List<InlineSpan> _arr = [];
      List<String> contents = value.split('@mentioned');
      for (int i = 0; i < contents.length; i++) {
        var element = contents[i];
        _arr.add(TextSpan(
            text: element,
            style:
            TextStyle(
              color: Colors.black,
              fontWeight:
              i == 0 ? FontWeight.bold : FontWeight.w500
            )));
        if(i != contents.length-1) {
          _arr.add(const TextSpan(
              text: 'mentioned',
              style:
              TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500
              )));
        }
      }
      _widget = Text.rich(
        TextSpan(
          children: _arr,
        ),
      );
      return _widget;
    }
    if(value.contains('replied')) {
      List<InlineSpan> _arr = [];
      List<String> contents = value.split('replied');
      for (int i = 0; i < contents.length; i++) {
        var element = contents[i];
        _arr.add(TextSpan(
            text: element,
            style:
            TextStyle(
                color: Colors.black,
                fontWeight:
                i == 0 ? FontWeight.bold : FontWeight.w500
            )));
        if(i != contents.length-1) {
          _arr.add(const TextSpan(
              text: 'replied',
              style:
              TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500
              )));
        }
      }
      _widget = Text.rich(
        TextSpan(
          children: _arr,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
      return _widget;
    }
    return Container();
  }
  @override
  bool get wantKeepAlive => true;
}