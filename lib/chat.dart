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
  static open(BuildContext context, String email, String password, {String? domain}) async {
    initializeDateFormatting().then((_) async {
      if(domain != null) {
        HTTPConnection.domain = domain;
      }
      ChatConnection.buildContext = context;
      ChatConnection.init(email, password).then((value) => Navigator.of(context,rootNavigator: true).push(
        MaterialPageRoute(builder: (context) => AppChat(email: email,password: password,))
      ));
    });
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