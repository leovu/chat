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
                  // await Chat.open(context, 'trind', '123456',
                  //     'assets/icon-app.png', const Locale(LangKey.langVi, 'VI'),
                  //     domain: 'https://chat.matthewsliquor.com.au/',
                  //     brandCode: 'matthewsliquor',
                  //     isChatHub: false,
                  //     token:
                  //         "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY4ZDI3MTQxMjI5Njg1MjI0MDFiOGIwOCIsInNpZCI6InRyaW5kIiwiZW1haWwiOiJ0cmluZEBwaW9hcHBzLnZuIiwibGV2ZWwiOiJzdGFuZGFyZCIsImZpcnN0TmFtZSI6IlRyaSBOZ3V5ZW4gV0FPIiwibGFzdE5hbWUiOiJURVNUIiwidXNlcm5hbWUiOiJ0cmluZCIsImJyYW5kIjoibWF0dGhld3NsaXF1b3IiLCJpYXQiOjE3NzA2MjM2ODYsImV4cCI6MTc3NTgwNzY4Nn0.paqcQkzpbSQbbxjsUudBkSC7LoMCAgMDz-0ZLFcP21E"
                  //     // roomId: '632a88f7dd01b42c37330585'
                  //     );
//MATHEW TEST CHAT HUB
                  await Chat.open(
                      // phoneNumber: '0708983437',
                      // phoneNumber: '+8490688627',
                      context,
                      // _userNameController.value.text,
                      // _passwordController.value.text,
                      'admin@matthewsliquor.com',
                      'matthews@2026',
                      'assets/icon-app.png',
                      const Locale(LangKey.langEn, 'EN'),
                      // domain: 'https://chathub.matthewsliquor.com.au/',
                      domain: 'https://chat.matthewsliquor.com.au/',
                      brandCode: 'matthewsliquor',
                      isChatHub: false,
                      token:
                          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjYyOTlhY2Q2NGE0MWMxNDc5NGEwMTdjYyIsInNpZCI6Indhb3N1cHBvcnQyQHBpb2FwcHMudm4iLCJlbWFpbCI6Indhb3N1cHBvcnQyQHBpb2FwcHMudm4iLCJsZXZlbCI6InN0YW5kYXJkIiwiZmlyc3ROYW1lIjoiMiIsImxhc3ROYW1lIjoiV0FPIFN1cHBvcnQiLCJwaWN0dXJlIjp7Il9pZCI6IjYyZmNjOTNiOThhODdlMjA1YzJlYmY3YSIsIm5hbWUiOiIzZmM1YjZiNC0zNjA4LTRlMzYtYmFkMi0wNTlmMGNmNTIzZDU1MzA5NzI2NDQyODM3MzYzODY3LmpwZyIsImF1dGhvciI6IjYyOTlhY2Q2NGE0MWMxNDc5NGEwMTdjYyIsInNpemUiOjI3MDAxNzEsInNoaWVsZCI6ImYwY2Z2OXk4NHl2NjRhc25wMDJnZnAyOWJ5eGQ4ZnFrNWg1bDUxcWJweGdnMWdueDM1NjZkN2wydGJrczA4NWRmd3g1ZWl0eXdtNTVmcm9qdzIyaW9hZDdlNnpieGhpamllbjRpZDhsMGN1eHQ2azAxOGtmbHI2bSIsIl9fdiI6MCwibG9jYXRpb24iOiIuL2RhdGEvNjI5OWFjZDY0YTQxYzE0Nzk0YTAxN2NjL2YwY2Z2OXk4NHl2NjRhc25wMDJnZnAyOWJ5eGQ4ZnFrNWg1bDUxcWJweGdnMWdueDM1NjZkN2wydGJrczA4NWRmd3g1ZWl0eXdtNTVmcm9qdzIyaW9hZDdlNnpieGhpamllbjRpZDhsMGN1eHQ2azAxOGtmbHI2bTYyZmNjOTNiOThhODdlMjA1YzJlYmY3YS5qcGciLCJzaGllbGRlZElEIjoiZjBjZnY5eTg0eXY2NGFzbnAwMmdmcDI5Ynl4ZDhmcWs1aDVsNTFxYnB4Z2cxZ254MzU2NmQ3bDJ0YmtzMDg1ZGZ3eDVlaXR5d201NWZyb2p3MjJpb2FkN2U2emJ4aGlqaWVuNGlkOGwwY3V4dDZrMDE4a2ZscjZtNjJmY2M5M2I5OGE4N2UyMDVjMmViZjdhIn0sInVzZXJuYW1lIjoid2Fvc3VwcG9ydDJAcGlvYXBwcy52biIsImJyYW5kIjoibWF0dGhld3NsaXF1b3IiLCJpYXQiOjE3ODQ2MDIzODIsImV4cCI6MTc4OTc4NjM4Mn0.pYZSYCJOpvsSROl8nrHLG1cAUc-z4MnI2qr8FPZMtmo"
                      // roomId: '632a88f7dd01b42c37330585'
                      );

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
