import 'package:chat/localization/lang_key.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter/services.dart';
import 'package:chat/chat.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

void main() {
  runApp(const OverlaySupport.global(
    child: MaterialApp(
      supportedLocales: [Locale('en', 'US')],
      locale: Locale('en','US'),
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        ViewerLocalizationsDelegate.delegate,
      ],
      title: 'Navigation Basics',
      debugShowCheckedModeBanner: false,
      home: MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await Chat.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: InkWell(
            onTap: () async {
              Chat.open(context,'waosupport@pioapps.vn', '123456', 'assets/icon-app.png',const Locale(LangKey.langVi, 'VN'), domain: 'https://chat-matthewsliquor.epoints.vn/');
            },
            child: Text('Running on: $_platformVersion\n')),
      ),
    );
  }
}
