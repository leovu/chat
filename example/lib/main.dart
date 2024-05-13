import 'package:chat/common/global.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:chat/chat.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:chat/common/shared_prefs/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance().then((event) async {
    Globals.prefs = SharedPrefs(event);
  });
  runApp(const OverlaySupport.global(
    child: MaterialApp(
      supportedLocales: [Locale('en', 'US')],
      locale: Locale('en','US'),
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
        _userNameController.text = 'admin@pioapps.vn';
        _passwordController.text = 'piospa@2020';
        _domainController.text = 'https://chat-hub-stag.epoints.vn/';
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
            padding: const EdgeInsets.only(bottom: 15.0,left: 15.0,right: 15.0),
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                border: Border.all(width: 1.0)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Center(
                  child: TextField(
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Username'
                    ),
                    controller: _userNameController,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0,left: 15.0,right: 15.0),
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                  border: Border.all(width: 1.0)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Center(
                  child: TextField(
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Password'
                    ),
                    controller: _passwordController,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 15.0,left: 15.0,right: 15.0),
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                  border: Border.all(width: 1.0)
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Center(
                  child: TextField(
                    decoration: const InputDecoration.collapsed(
                        hintText: 'Domain'
                    ),
                    controller: _domainController,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: InkWell(
                onTap: () async {
                  if(_userNameController.value.text == '') {
                    errorDialog('Username Empty');
                    return;
                  }
                  if(_passwordController.value.text == '') {
                    errorDialog('Password Empty');
                    return;
                  }
                  if(_domainController.value.text == '') {
                    errorDialog('Domain Empty');
                    return;
                  }
                  // Chat.open(context,_userNameController.value.text, _passwordController.value.text, 'assets/icon-app.png',const Locale(LangKey.langVi, 'VN'), domain: _domainController.value.text,brandCode: 'qc',isChatHub: true,
                  //     token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYzMDMwOTNjYzM3M2JkMTg5YjQ1NmFjMCIsInNpZCI6ImFkbWluIiwiZW1haWwiOiJ2dUBwaW9hcHBzLnZuIiwibGV2ZWwiOiJyb290IiwiZmlyc3ROYW1lIjoiQWRtaW4iLCJsYXN0TmFtZSI6IiIsInVzZXJuYW1lIjoiYWRtaW4iLCJicmFuZF9jb2RlIjoicWMiLCJpYXQiOjE2NzA5OTIwNDQsImV4cCI6MTY3NjE3NjA0NH0.U2UoNWnQnNkZOI3qGA5SiTetnggO5SlCKgV7NW0Ks-Q");

                  /// An test
                  Chat.open(context,_userNameController.value.text, _passwordController.value.text, 'assets/icon-app.png',const Locale(LangKey.langVi, 'VN'),
                      domain: 'https://chathub.epoints.vn/',brandCode: 'sale',isChatHub: false,
                      token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3dvcmtzcGFjZS5lcG9pbnRzLnZuL3YyL3VzZXIvbG9naW4iLCJpYXQiOjE3MTU1NjUzMzcsImV4cCI6MTcxNTU4NjkzNywibmJmIjoxNzE1NTY1MzM3LCJqdGkiOiI2WFNHRVZWNEJQNEIwNEZoIiwic3ViIjoxNSwicHJ2IjoiYTBmM2U3NGJlZGY1MTJjNDc3ODI5N2RlNWY5MjA4NmRhZDM5Y2E5ZiIsInNpZCI6InRhbSIsImJyYW5kX2NvZGUiOiJzYWxlIn0.O5SCs1p0U2JCjTywlYiN_x-Ykdqz8tRfz3tsZ5CMfNA");

                  /// A Long Test
                  // Chat.open(context,_userNameController.value.text, _passwordController.value.text, 'assets/icon-app.png',const Locale(LangKey.langVi, 'VN'),
                  //     domain: _domainController.value.text,brandCode: 'qc',isChatHub: false,
                  //     token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYzMDMwOTNjYzM3M2JkMTg5YjQ1NmFjMCIsInNpZCI6ImFkbWluIiwiZW1haWwiOiJ2dUBwaW9hcHBzLnZuIiwibGV2ZWwiOiJyb290IiwiZmlyc3ROYW1lIjoiQWRtaW4iLCJsYXN0TmFtZSI6IiIsInVzZXJuYW1lIjoiYWRtaW4iLCJicmFuZF9jb2RlIjoicWMiLCJpYXQiOjE2ODc1MTY3OTgsImV4cCI6MTY5MjcwMDc5OH0.7xm-CWeZKDHkzoGinfjo_rORlMVMR_kNHn_G8qX88M4");
                },
                child: Container(
                    height: 40.0,
                    width: 80.0,
                    color: Colors.blue,
                    child: const Center(child: Text('Login',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)))),
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
