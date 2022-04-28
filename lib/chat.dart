import 'dart:async';
import 'dart:io';
import 'package:chat/connection/http_connection.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'chat_screen/home_screen.dart';
import 'connection/chat_connection.dart';

class Chat {
  static const MethodChannel _channel = MethodChannel('chat');
  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  static Future<bool>connectSocket(BuildContext context, String email, String password, String appIcon, {String? domain}) async {
    ChatConnection.buildContext = context;
    ChatConnection.appIcon = appIcon;
    bool result = await ChatConnection.init(email, password);
    return result;
  }
  static disconnectSocket() {
    ChatConnection.dispose(isDispose: true);
  }
  static open(BuildContext context, String email, String password, String appIcon, {String? domain, Map<String, dynamic>? notificationData}) async {
    await initializeDateFormatting();
    if(domain != null) {
      HTTPConnection.domain = domain;
    }
    ChatConnection.buildContext = context;
    ChatConnection.appIcon = appIcon;
    bool result = false;
    if(notificationData != null) {
      ChatConnection.initialData = notificationData;
    }
    if(!ChatConnection.checkConnected()) {
      result = await connectSocket(context,email,password,appIcon,domain:domain);
    }
    if(result) {
      await Navigator.of(context,rootNavigator: true).push(
          MaterialPageRoute(builder: (context) => AppChat(email: email,password: password)));
    }else {
      loginError(context,email,password);
    }
  }
  static openNotification(Map<String, dynamic> notificationData) {
    try{
      if(ChatConnection.roomId != null) {
        ChatConnection.homeScreenNotificationHandler(notificationData);
      }
      else {
        ChatConnection.chatScreenNotificationHandler(notificationData);
      }
    }catch(_){}
  }
  static void loginError(BuildContext context,String username,String password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Warning'),
        content: Text('Account login error!\nAccount:$username,Password:$password'),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Accept'))
        ],
      ),
    );
  }
}

class AppChat extends StatelessWidget {
  final String? email;
  final String? password;
  const AppChat({Key? key, required this.email, required this.password}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if(Platform.isAndroid) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarBrightness: Brightness.dark,
      ));
    }
    return const HomeScreen();
  }
}