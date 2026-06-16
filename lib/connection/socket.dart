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
    print('--- [SOCKET] Đang khởi tạo kết nối tới: ${HTTPConnection.domain} ---');
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
      print('✅ [SOCKET] Kết nối thành công! ID: ${socket!.id}');
      print('🔑 [SOCKET] Đang gửi token để xác thực...');
      socket!.emit('authenticate', {'token': user.token});
    });

    socket!.on('authenticated', (data) {
      print('👍 [SOCKET] Xác thực thành công: $data');
      streamSocket.addResponse(data.toString());
    });

    socket!.onConnectError((data) {
      print('⛔️ [SOCKET] LỖI KẾT NỐI: $data');
    });

    socket!.on('error', (data) {
      print('❌ [SOCKET] Lỗi từ server: $data');
    });

    socket!.on('unauthorized', (data) {
      print('🚫 [SOCKET] Xác thực thất bại: $data');
    });

    socket!.onDisconnect((reason) {
      print('🔌 [SOCKET] Đã ngắt kết nối: $reason');
    });

  }

  bool checkConnected() {
    return socket?.connected ?? false;
  }

  void sendMessage(String? message, c.Room? room) {
    // print('➡️ [SOCKET] Gửi đi sự kiện "message-in"');
    socket!.emit('message-in',
        {'status': 200, 'message': message, 'room': room?.toJson()});
  }

  void joinRoom(String? roomId) {
    print('🚪 [SOCKET] Emit join: roomID=$roomId');
    socket!.emit('join', {'roomID': roomId});
    socket!.on('joined', (data) {
      print('✅ [SOCKET] Server xác nhận joined: $data');
    });
    socket!.on('join', (data) {
      print('✅ [SOCKET] Server phản hồi join: $data');
    });
  }

  void listenChat(Function callback) {
    print('👂 [SOCKET] Đăng ký lắng nghe message-in');
    socket!.on('message-in', (data) {
      print('📩 [SOCKET] Nhận message-in: $data');
      callback(data);
      ChatConnection.notificationList();
    });
  }
}