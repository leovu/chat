import 'dart:async';
import 'dart:io';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/user.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:chat/data_model/chat_message.dart' as c;

class StreamSocket {
  final _socketResponse = StreamController<String>();
  void Function(String) get addResponse => _socketResponse.sink.add;
  Stream<String> get getResponse => _socketResponse.stream;
  io.Socket? socket;
  void dispose() {
    _socketResponse.close();
  }
  String? id () {return socket!.id;}
  void connectAndListen(StreamSocket streamSocket, User user) {
    socket = io.io(HTTPConnection.domain,
        io.OptionBuilder().setTransports(['websocket'])
            .setExtraHeaders({'brand-code': ChatConnection.brandCode, 'brand' : ChatConnection.brandCode})
            .setQuery({'brand-code': ChatConnection.brandCode, 'brand' : ChatConnection.brandCode})
            .build());
    socket!.onConnectError((data) {});
    socket!.on('authenticated', (data) {
      streamSocket.addResponse;
    });
    connectSocket(user);
    socket!.onDisconnect((_) => connectSocket(user));
  }
  void connectSocket(User user) {
    socket!.onConnect((_) {
      socket!.emit('authenticate',{'token':user.token});
    });
  }
  bool checkConnected() {
    return socket!.connected;
  }
  void sendMessage(String? message, c.Room? room){
    socket!.emit('message-in',{'status': 200, 'message':message, 'room':room?.toJson()});
  }
  void joinRoom(String? roomId) {
    socket!.emit('join',{'roomID':roomId});
    socket!.on('join', (data) {});
  }
  void listenChat(Function callback) {
    socket!.on('message-in', (data) {
      callback(data);
      ChatConnection.notificationList();
    });
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
