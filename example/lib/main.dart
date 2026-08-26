import 'package:chat/chat.dart';
import 'package:chat/common/global.dart';
import 'package:chat/common/shared_prefs/shared_prefs.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance().then((event) async {
    Globals.prefs = SharedPrefs(event);
  });
  runApp(const OverlaySupport.global(
    child: MaterialApp(
      supportedLocales: [Locale('en', 'US')],
      locale: Locale('en', 'US'),
      localizationsDelegates: <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
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
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _domainController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        // _userNameController.text = 'admin@pioapps.vn';
        // _passwordController.text = 'piospa@2020';
        // _domainController.text = 'https://chat-hub-stag.epoints.vn/';
        _userNameController.text = 'admin@pioapps.vn';
        _passwordController.text = 'Waosupport@2025';
        _domainController.text = 'https://chathub.epoints.vn/';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(bottom: 15.0, left: 15.0, right: 15.0),
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(border: Border.all(width: 1.0)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Center(
                  child: TextField(
                    decoration:
                        const InputDecoration.collapsed(hintText: 'Username'),
                    controller: _userNameController,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(bottom: 15.0, left: 15.0, right: 15.0),
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(border: Border.all(width: 1.0)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Center(
                  child: TextField(
                    decoration:
                        const InputDecoration.collapsed(hintText: 'Password'),
                    controller: _passwordController,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(bottom: 15.0, left: 15.0, right: 15.0),
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(border: Border.all(width: 1.0)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Center(
                  child: TextField(
                    decoration:
                        const InputDecoration.collapsed(hintText: 'Domain'),
                    controller: _domainController,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: InkWell(
                onTap: () async {
                  if (_userNameController.value.text == '') {
                    errorDialog('Username Empty');
                    return;
                  }
                  if (_passwordController.value.text == '') {
                    errorDialog('Password Empty');
                    return;
                  }
                  if (_domainController.value.text == '') {
                    errorDialog('Domain Empty');
                    return;
                  }

                  await Chat.open(
                      context,
                      'admin@pioapps.vn',
                      'Waosupport@2025',
                      'assets/icon-app.png',
                      const Locale(LangKey.langVi, 'VI'),
                      // domain: 'https://chat.epoints.vn/',

                      domain: 'https://chathub.epoints.vn/',
                      brandCode: 'sale',
                      isChatHub: true,
                      token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYyZmQwMjA0ZDcwMzNlMjRkYTc5YzYwNiIsInVpZCI6MSwic2lkIjoiYWRtaW4iLCJlbWFpbCI6InZ1QHBpb2FwcHMudm4iLCJsZXZlbCI6InJvb3QiLCJmaXJzdE5hbWUiOiJBZG1pbiIsImxhc3ROYW1lIjoiVXNlciIsInVzZXJuYW1lIjoiYWRtaW4iLCJicmFuZF9jb2RlIjoic2FsZSIsImlhdCI6MTc4NzcxMzIxOSwiZXhwIjoxNzkyODk3MjE5fQ.fWVU9EYvnds_2okVv32wB-nbnKrcRB065COUjcZ6lak"
                      // token:
                      //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY3ZmNjMjM1ZDAwYzZjMDAxMjVlZmViNSIsInNpZCI6ImFkbWluQHBpb2FwcHMudm4iLCJlbWFpbCI6ImFkbWluQHBpb2FwcHMudm4iLCJsZXZlbCI6InN0YW5kYXJkIiwiZmlyc3ROYW1lIjoiQWRtaW4iLCJsYXN0TmFtZSI6IiIsInVzZXJuYW1lIjoiYWRtaW5AcGlvYXBwcy52biIsImJyYW5kIjoic2FsZSIsImlhdCI6MTc4NzcwODc0MiwiZXhwIjoxNzkyODkyNzQyfQ.c303lCDhLiPDnIUste4DiCSY3TueQSIX2oSGrpfUTrI'

                      // roomId: '632a88f7dd01b42c37330585'
                      );
                },
                child: Container(
                    height: 40.0,
                    width: 80.0,
                    color: Colors.blue,
                    child: const Center(
                        child: Text(
                      'Login',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )))),
          ),
        ],
      ),
    );
  }

  void errorDialog(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.warning)),
        content: Text(text),
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

