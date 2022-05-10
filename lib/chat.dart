import 'dart:async';
import 'dart:io';
import 'package:chat/connection/http_connection.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';
import 'chat_screen/home_screen.dart';
import 'connection/chat_connection.dart';
import 'localization/app_localizations.dart';
import 'localization/lang_key.dart';

class Chat {
  static const MethodChannel _channel = MethodChannel('chat');
  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  static Future<String?> chatToken(String email, String password, String domain) async {
    HTTPConnection.domain = domain;
    return await ChatConnection.token(email, password);
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
  static open(BuildContext context, String email, String password, String appIcon,Locale locale,{String? domain, Map<String, dynamic>? notificationData}) async {
    await initializeDateFormatting();
    if(domain != null) {
      HTTPConnection.domain = domain;
    }
    ChatConnection.locale = locale;
    ChatConnection.buildContext = context;
    ChatConnection.appIcon = appIcon;
    if(notificationData != null) {
      ChatConnection.initialData = notificationData;
    }
    AppLocalizations(ChatConnection.locale).load();
    bool result = await connectSocket(context,email,password,appIcon,domain:domain);
    if(result) {
      await Navigator.of(context,rootNavigator: true).push(
          MaterialPageRoute(builder: (context) => AppChat(email: email,password: password)));
    }else {
      loginError(context);
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
  static void loginError(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.warning)),
        content: Text(AppLocalizations.text(LangKey.accountLoginError)),
        actions: [
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.text(LangKey.accept)))
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