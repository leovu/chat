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

                  //MATHEW TEST CHAT
                  // await Chat.open(
                  //     context,
                  //     'admin@pioapps.vn',
                  //     'Waosupport@2025',
                  //     'assets/icon-app.png',
                  //     const Locale(LangKey.langVi, 'VI'),
                  //     domain: 'https://chathub.epoints.vn/',
                  //     brandCode: 'sale',
                  //     isChatHub: true,
                  //     token:
                  //         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYyZmQwMjA0ZDcwMzNlMjRkYTc5YzYwNiIsInVpZCI6MSwic2lkIjoiYWRtaW4iLCJlbWFpbCI6InZ1QHBpb2FwcHMudm4iLCJsZXZlbCI6InJvb3QiLCJmaXJzdE5hbWUiOiJBZG1pbiIsImxhc3ROYW1lIjoiVXNlciIsInVzZXJuYW1lIjoiYWRtaW4iLCJicmFuZF9jb2RlIjoic2FsZSIsImlhdCI6MTc3MDY5NzAzMiwiZXhwIjoxNzc1ODgxMDMyfQ.D609LMdUBB4EBTYAL-Ys7vEH7jaBcE2QzV-TnXC2khk"
                  //     // roomId: '632a88f7dd01b42c37330585'
                  //     );

                  await Chat.open(
                      context,
                      'admin@pioapps.vn',
                      'Waosupport@2025',
                      'assets/icon-app.png',
                      const Locale(LangKey.langVi, 'VI'),
                      domain: 'https://chat.epoints.vn/',

                      // domain: 'https://chathub.epoints.vn/',
                      brandCode: 'sale',
                      isChatHub: false,
                      token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3dvcmtzcGFjZS5lcG9pbnRzLnZuL3YyL3VzZXIvbG9naW4iLCJpYXQiOjE3ODIxMjQyOTIsImV4cCI6MTc4MjE0NTg5MiwibmJmIjoxNzgyMTI0MjkyLCJqdGkiOiJwVkVlNlNncmdEbHJsU3RnIiwic3ViIjo4OCwicHJ2IjoiYTBmM2U3NGJlZGY1MTJjNDc3ODI5N2RlNWY5MjA4NmRhZDM5Y2E5ZiIsInNpZCI6InF1YW5nbG0iLCJicmFuZF9jb2RlIjoic2FsZSJ9.bDibJ4Nb1M6U2YKKjnUfUqGt0r0Zx59txV3Zo889kj4"
                      // token: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYyZmQwMjA0ZDcwMzNlMjRkYTc5YzYwNiIsInVpZCI6OTYsInNpZCI6ImFkbWluIiwiZW1haWwiOiJ2dUBwaW9hcHBzLnZuIiwibGV2ZWwiOiJyb290IiwiZmlyc3ROYW1lIjoiQWRtaW4iLCJsYXN0TmFtZSI6IlVzZXIiLCJ1c2VybmFtZSI6ImFkbWluIiwiYnJhbmRfY29kZSI6InNhbGUiLCJpYXQiOjE3ODE4NDE2NDEsImV4cCI6MTc4NzAyNTY0MX0.mh5c6vwdXGN1mgAvTDQIWPmrvaDUyjf9Sr50gBNt5yc'

                      // roomId: '632a88f7dd01b42c37330585'
                      );
                  //MATHEW TEST CHAT HUB
                  // await Chat.open(
                  //     // phoneNumber: '0708983437',
                  //     // phoneNumber: '+8490688627',
                  //     context,
                  //     // _userNameController.value.text,
                  //     // _passwordController.value.text,
                  //     'admin@matthewsliquor.com',
                  //     '123456',
                  //     'assets/icon-app.png',
                  //     const Locale(LangKey.langVi, 'VI'),
                  //     domain: 'https://chathub.matthewsliquor.com.au/',
                  //     // domain: 'https://chat.matthewsliquor.com.au/',
                  //     brandCode: 'matthewsliquor',
                  //     isChatHub: true,
                  //     token:
                  //         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYyN2JkMDc5NDhhNTUxMDUzZWFkMGFiNyIsInVpZCI6MjA3LCJzaWQiOiJhZG1pbiIsImVtYWlsIjoiYWRtaW5AbWF0dGhld3NsaXF1b3IuY29tIiwibGV2ZWwiOiJyb290IiwiZmlyc3ROYW1lIjoiQWRtaW4iLCJsYXN0TmFtZSI6IiIsInVzZXJuYW1lIjoiYWRtaW4iLCJicmFuZF9jb2RlIjoibWF0dGhld3NsaXF1b3IiLCJpYXQiOjE3NzA2MjYyOTgsImV4cCI6MTc3NTgxMDI5OH0.m7rqrMZGl0hs-uOpRWpeCVeC_U_qJXsPCqsHdHscfPs"
                  //     // roomId: '632a88f7dd01b42c37330585'
                  //     );

                  //MATHEW TEST
                  // await Chat.open(
                  //   // phoneNumber: '0708983437',
                  //   // phoneNumber: '+8490688627',
                  //   context,
                  //   _userNameController.value.text,
                  //   _passwordController.value.text,
                  //   'assets/icon-app.png',
                  //   const Locale(LangKey.langVi, 'VI'),
                  //   domain: 'https://chat.dev.matthewsliquor.com.au/',
                  //   brandCode: 'matthewsliquor',
                  //   isChatHub: false,
                  //   token:
                  //       "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYyN2JkMDc5NDhhNTUxMDUzZWFkMGFiNyIsInNpZCI6ImFkbWluQG1hdHRoZXdzbGlxdW9yLmNvbSIsImVtYWlsIjoidnVAcGlvYXBwcy52biIsImxldmVsIjoicm9vdCIsImZpcnN0TmFtZSI6IkFkbWluIiwibGFzdE5hbWUiOiJVc2VyIiwidXNlcm5hbWUiOiJhZG1pbkBtYXR0aGV3c2xpcXVvci5jb20iLCJicmFuZCI6Im1hdHRoZXdzbGlxdW9yIiwiaWF0IjoxNzYwNDAzOTQ5LCJleHAiOjE3NjU1ODc5NDl9.aR8aMgqe4KamfXYLJbMGjmHhmPyyq9-OHlEBQbBtwQw",
                  //   // roomId: '632a88f7dd01b42c37330585'
                  // );

                  // Chat.open(context,_userNameController.value.text, _passwordController.value.text, 'assets/icon-app.png',const Locale(LangKey.langVi, 'VN'), domain: _domainController.value.text,brandCode: 'qc',isChatHub: true,
                  //     token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYyZmQwMjA0ZDcwMzNlMjRkYTc5YzYwNiIsInVpZCI6MSwic2lkIjoiYWRtaW4iLCJlbWFpbCI6InZ1QHBpb2FwcHMudm4iLCJsZXZlbCI6InJvb3QiLCJmaXJzdE5hbWUiOiJBZG1pbiIsImxhc3ROYW1lIjoiVXNlciIsInVzZXJuYW1lIjoiYWRtaW4iLCJicmFuZF9jb2RlIjoic2FsZSIsImlhdCI6MTc0NDYxOTY3NSwiZXhwIjoxNzQ5ODAzNjc1fQ.A1gbHYmAxSWieWvEJ4uScRRC_zEhJSKRrtA7MzlkPV4");

                  /// An test
                  // await Chat.open(context,_userNameController.value.text, _passwordController.value.text, 'assets/icon-app.png',const Locale(LangKey.langVi, 'VN'),
                  //     domain: 'https://chathub.epoints.vn/',brandCode: 'qc',isChatHub: true,
                  //     token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3dvcmtzcGFjZS5lcG9pbnRzLnZuL3YyL3VzZXIvbG9naW4iLCJpYXQiOjE3MTk0NzY0NjksImV4cCI6MTcxOTQ5ODA2OSwibmJmIjoxNzE5NDc2NDY5LCJqdGkiOiJXbUZ4cE44S2RnV3pncTJPIiwic3ViIjoxNSwicHJ2IjoiYTBmM2U3NGJlZGY1MTJjNDc3ODI5N2RlNWY5MjA4NmRhZDM5Y2E5ZiIsInNpZCI6InRhbSIsImJyYW5kX2NvZGUiOiJzYWxlIn0.qFV9o7_8_DNHAi_fRJtlYamGBAhcB7DTu1Q4eC9zawA");

                  // / A Long Test
                  // Chat.open(context,_userNameController.value.text, _passwordController.value.text, 'assets/icon-app.png',const Locale(LangKey.langVi, 'VN'),
                  //     domain: _domainController.value.text,brandCode: 'sale',isChatHub: true,
                  //     token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYzMDMwOTNjYzM3M2JkMTg5YjQ1NmFjMCIsInNpZCI6ImFkbWluIiwiZW1haWwiOiJ2dUBwaW9hcHBzLnZuIiwibGV2ZWwiOiJyb290IiwiZmlyc3ROYW1lIjoiQWRtaW4iLCJsYXN0TmFtZSI6IiIsInVzZXJuYW1lIjoiYWRtaW4iLCJicmFuZF9jb2RlIjoicWMiLCJpYXQiOjE2ODc1MTY3OTgsImV4cCI6MTY5MjcwMDc5OH0.7xm-CWeZKDHkzoGinfjo_rORlMVMR_kNHn_G8qX88M4");
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

//66b9e2b23b3722001365cb66 (generic)
//632a88f7dd01b42c37330585 ("oa_template")
//6790715251835800113664ea (oa_list)
//683670f719fbc9001203bfae (zp_list)
