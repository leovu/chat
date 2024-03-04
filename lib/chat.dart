import 'dart:async';
import 'dart:io';
import 'package:chat/connection/http_connection.dart';
import 'package:flutter/cupertino.dart';
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
  static Future<bool>connectSocket(BuildContext context, String email, String password, String appIcon, {String? domain, String? token}) async {
    ChatConnection.buildContext = context;
    ChatConnection.appIcon = appIcon;
    bool result = await ChatConnection.init(email, password, token: token);
    return result;
  }
  static disconnectSocket() {
    ChatConnection.dispose(isDispose: true);
  }
  static open(BuildContext context, String email, String password,
      String appIcon,Locale locale,
      { String? domain, String? token,
        String? brandCode,
        bool isChatHub = false,
        Map<String, dynamic>? notificationData,
        List<Map<String,dynamic>>? addOnModules,
        Function? searchProducts,
        Function? searchOrders,
        Function? createOrder,
        Function? createAppointment,
        Function? createDeal,
        Function? createTask,
        Function? addCustomer,
        Function? addCustomerPotential,
        Function? viewProfileChatHub,
        Function? editCustomerLead,
        Function? openChatGPT
      }) async {
    showLoading(context);
    await initializeDateFormatting();
    if(domain != null) {
      HTTPConnection.domain = domain;
    }

    ChatConnection.addOnModules = addOnModules;
    ChatConnection.locale = locale;
    ChatConnection.buildContext = context;
    ChatConnection.appIcon = appIcon;
    ChatConnection.brandCode = brandCode;
    ChatConnection.isChatHub = isChatHub;
    ChatConnection.searchProducts = searchProducts;
    ChatConnection.searchOrders = searchOrders;
    ChatConnection.createOrder = createOrder;
    ChatConnection.createAppointment = createAppointment;
    ChatConnection.createDeal = createDeal;
    ChatConnection.createTask = createTask;
    ChatConnection.addCustomer = addCustomer;
    ChatConnection.addCustomerPotential = addCustomerPotential;
    ChatConnection.viewProfileChatHub = viewProfileChatHub;
    ChatConnection.editCustomerLead = editCustomerLead;
    ChatConnection.openChatGPT = openChatGPT;

    if(notificationData != null) {
      ChatConnection.initialData = notificationData;
    }
    AppLocalizations(ChatConnection.locale).load();
    bool result = await connectSocket(context,email,password,appIcon,domain:domain,token: token);
    Navigator.of(context).pop();
    if(result) {
      await Navigator.of(context,rootNavigator: true).push(
          MaterialPageRoute(builder: (context) => AppChat(email: email,password: password),settings: const RouteSettings(name: 'home_screen')));
      ChatConnection.dispose(isDispose: true);
    }else {
      loginError(context);
    }
  }
  static Future showLoading(BuildContext context) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              Center(
                child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator(),
              )
            ],
          );
        });
  }
  static openNotification(Map<String, dynamic> notificationData) {
    ChatConnection.notificationList();
    try{
      if(ChatConnection.roomId == null) {
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