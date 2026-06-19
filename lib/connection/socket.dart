import 'dart:async';
import 'dart:io';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/user.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:chat/data_model/chat_message.dart' as c;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class StreamSocket {
  final _socketResponse = StreamController<String>.broadcast();
  void addResponse(String data) {
    if (!_socketResponse.isClosed) _socketResponse.sink.add(data);
  }

  Stream<String> get getResponse => _socketResponse.stream;
  io.Socket? socket;
  final List<Function> _chatListeners = [];

  void dispose() {
    _socketResponse.close();
    socket?.dispose();
  }

  String? id() {
    return socket?.id;
  }

  void connectAndListen(StreamSocket streamSocket, User user) {
    debugPrint('[SOCKET] Initializing connection to: ${HTTPConnection.domain}');
    socket = io.io(
        HTTPConnection.domain,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableReconnection()
            .setExtraHeaders({
              'brand-code': ChatConnection.brandCode,
              'brand': ChatConnection.brandCode
            })
            .setQuery({
              'brand-code': ChatConnection.brandCode,
              'brand': ChatConnection.brandCode
            })
            .build());

    socket!.onConnect((_) {
      debugPrint('[SOCKET] Connected. ID: ${socket!.id}');
      debugPrint('[SOCKET] Sending token for authentication...');
      socket!.emit('authenticate', {'token': user.token});
    });

    socket!.on('authenticated', (data) {
      debugPrint('[SOCKET] Authenticated: $data');
      streamSocket.addResponse(data.toString());
    });

    socket!.onConnectError((data) {
      debugPrint('[SOCKET] Connection error: $data');
    });

    socket!.on('error', (data) {
      debugPrint('[SOCKET] Server error: $data');
    });

    socket!.on('unauthorized', (data) {
      debugPrint('[SOCKET] Authentication failed: $data');
    });

    socket!.onDisconnect((reason) {
      debugPrint('[SOCKET] Disconnected: $reason');
    });

    socket!.on('message-in', (data) {
      debugPrint('[SOCKET] Received message-in: $data');
      for (final cb in List.from(_chatListeners)) {
        cb(data);
      }
      ChatConnection.notificationList();
    });
  }

  bool checkConnected() {
    return socket?.connected ?? false;
  }

  void sendMessage(String? message, c.Room? room) {
    socket!.emit('message-in',
        {'status': 200, 'message': message, 'room': room?.toJson()});
  }

  void joinRoom(String? roomId) {
    debugPrint('[SOCKET] Emit join: roomID=$roomId');
    socket!.emit('join', {'roomID': roomId});
    socket!.on('joined', (data) {
      debugPrint('[SOCKET] Server confirmed joined: $data');
    });
    socket!.on('join', (data) {
      debugPrint('[SOCKET] Server join response: $data');
    });
  }

  void listenChat(Function callback) {
    if (!_chatListeners.contains(callback)) {
      _chatListeners.add(callback);
    }
  }

  void removeListenChat(Function callback) {
    _chatListeners.remove(callback);
  }
}
