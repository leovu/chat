import 'dart:io';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/connection/socket.dart';
import 'package:chat/data_model/response/check_user_token_response_model.dart';
import 'package:chat/data_model/user.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthService {
  static Future<bool> init(
    HTTPConnection connection,
    StreamSocket streamSocket,
    String email,
    String password, {
    String? token,
    required void Function(User) onUserReady,
    required void Function(String) onUidReady,
  }) async {
    HttpOverrides.global = MyHttpOverrides();
    String? resultToken;
    if (token != null) {
      resultToken = token;
    } else {
      resultToken = await login(connection, email, password);
    }
    if (resultToken != null) {
      final user = User(email: email, password: password, token: resultToken);
      final payload = Jwt.parseJwt(resultToken);
      user.id = payload['sub'].toString();
      if (user.id == 'null') user.id = payload['id'];
      onUidReady(payload['uid'].toString());
      user.firstName = payload['firstName'] ?? '';
      user.lastName = payload['lastName'] ?? '';
      onUserReady(user);
      streamSocket.connectAndListen(streamSocket, user);
      return true;
    }
    return false;
  }

  static Future<String?> login(HTTPConnection connection, String email, String password) async {
    final responseData = await connection.post('api/login', {'email': email, 'password': password});
    if (responseData.isSuccess) return responseData.data['token'];
    return null;
  }

  static Future<String?> token(HTTPConnection connection, String email, String password) async {
    HttpOverrides.global = MyHttpOverrides();
    final responseData = await connection.post('api/check-user-token', {'email': email, 'password': password});
    if (responseData.isSuccess) return responseData.data['token'];
    return null;
  }

  static Future<bool> register(
    HTTPConnection connection,
    String username,
    String email,
    String firstName,
    String lastName,
    String password,
    String repeatPassword,
  ) async {
    final responseData = await connection.post('api/register', {
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'repeatPassword': repeatPassword,
    });
    return responseData.isSuccess;
  }

  static Future<bool> checkUserToken(
    HTTPConnection connection,
    User user,
    String? brandCode, {
    required void Function(CheckUserTokenResponseModel) onResult,
    required void Function(User) onUserUpdated,
  }) async {
    final header = {'brand-code': brandCode};
    final responseData = await connection.post(
      'api/check-user-token',
      {'token': user.token},
      header: header,
    );
    if (responseData.isSuccess) {
      final model = CheckUserTokenResponseModel.fromJson(responseData.data);
      onResult(model);
      onUserUpdated(User.fromCheckUserToken(model));
      return true;
    }
    return false;
  }

  static bool checkConnected(StreamSocket streamSocket) {
    if (streamSocket.socket == null) return false;
    return streamSocket.checkConnected();
  }

  static void reconnect(StreamSocket streamSocket) {
    streamSocket.socket!.connect();
  }

  static void reAuthenticate(StreamSocket streamSocket, User? user) {
    if (user != null && streamSocket.socket?.connected == true) {
      streamSocket.socket!.emit('authenticate', {'token': user.token});
    }
  }

  static void dispose(StreamSocket streamSocket, {bool isDispose = false}) {
    if (!isDispose) {
      streamSocket.socket!.disconnect();
    } else {
      streamSocket.socket!.disconnect();
      streamSocket.dispose();
    }
  }
}
