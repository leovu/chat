import 'dart:async';
import 'dart:io';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/user.dart';
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
  void Function(String) get addResponse => _socketResponse.sink.add;
  Stream<String> get getResponse => _socketResponse.stream;
  io.Socket? socket;

  void dispose() {
    _socketResponse.close();
    socket?.dispose(); 
  }

  String? id() {
    return socket?.id;
  }

  void connectAndListen(StreamSocket streamSocket, User user) {
    print('--- [SOCKET] Đang khởi tạo kết nối... ---');
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

    // --- CÁC TRÌNH LẮNG NGHE QUAN TRỌNG ĐỂ DEBUG ---

    socket!.onConnect((_) {
      print('✅ [SOCKET] Kết nối thành công! ID: ${socket!.id}');
      print('🔑 [SOCKET] Đang gửi token để xác thực...');
      socket!.emit('authenticate', {'token': user.token});
    });

    socket!.on('authenticated', (data) {
      print('👍 [SOCKET] Xác thực thành công!');
      streamSocket.addResponse(data.toString());
    });

    socket!.onConnectError((data) {
      print('⛔️ [SOCKET] LỖI KẾT NỐI: $data');
    });

    socket!.onDisconnect((reason) {
      print('🔌 [SOCKET] Đã ngắt kết nối: $reason');
    });

  }

  bool checkConnected() {
    return socket?.connected ?? false;
  }

  void sendMessage(String? message, c.Room? room) {
    print('➡️ [SOCKET] Gửi đi sự kiện "message-in"');
    socket!.emit('message-in',
        {'status': 200, 'message': message, 'room': room?.toJson()});
  }

  void joinRoom(String? roomId) {
    socket!.emit('join', {'roomID': roomId});
  }

  void listenChat(Function callback) {
    socket!.on('message-in', (data) {
      callback(data);
      ChatConnection.notificationList(); 
    });
  }
}