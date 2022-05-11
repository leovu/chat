import 'package:chat/connection/chat_connection.dart';
import 'package:flutter/material.dart';
abstract class AppLifeCycle<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        ChatConnection.reconnect();
        break;
      case AppLifecycleState.paused:
        ChatConnection.dispose();
        break;
      case AppLifecycleState.inactive:
        ChatConnection.dispose();
        break;
      case AppLifecycleState.detached:
        ChatConnection.dispose();
        break;
      default: break;
    }
  }
}