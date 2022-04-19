import 'package:chat/chat_ui/notification.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/connection/http_connection.dart';
import 'package:chat/connection/socket.dart';
import 'package:chat/data_model/contact.dart' as ct;
import 'package:chat/data_model/user.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:chat/data_model/room.dart' as r;
import 'package:image_picker/image_picker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_beep/flutter_beep.dart';

class ChatConnection {
  static late void Function() refreshRoom;
  static late void Function() refreshContact;
  static late void Function() refreshFavorites;
  static StreamSocket streamSocket = StreamSocket();
  static HTTPConnection connection = HTTPConnection();
  static late String appIcon;
  static String? roomId;
  static User? user;
  static Future<bool>init(String email,String password) async {
    HttpOverrides.global = MyHttpOverrides();
    ResponseData responseData = await connection.post('api/login', {'email':email,'password':password});
    if(responseData.isSuccess) {
      user = User(email:email,password:password,token:responseData.data['token']);
      Map<String, dynamic> payload = Jwt.parseJwt(responseData.data['token']);
      user!.id = payload['id'];
      user!.firstName = payload['firstName'];
      user!.lastName = payload['lastName'];
      streamSocket.connectAndListen(streamSocket,user!);
    }
    return responseData.isSuccess;
  }
  static Future<bool>register(String username,String email,String firstName,
      String lastName,String password,String repeatPassword) async{
    ResponseData responseData = await connection.post('api/register', {'username':username,'email':email,'firstName':firstName,
      'lastName':lastName,'password':password,'repeatPassword':repeatPassword});
    return responseData.isSuccess;
  }
  static Future<r.Rooms?>createRoom(String? counterpart) async {
    ResponseData responseData = await connection.post('api/room/create', {'counterpart':counterpart});
    if(responseData.isSuccess) {
      return r.Rooms.fromJson(responseData.data['room']);
    }
    return null;
  }
  static Future<r.Room?>roomList() async {
    ResponseData responseData = await connection.post('api/rooms/list', {'limit':500});
    if(responseData.isSuccess) {
      return r.Room.fromJson(responseData.data);
    }
    return null;
  }
  static Future<r.Room?>favoritesList() async {
    ResponseData responseData = await connection.post('api/favorites/list', {});
    if(responseData.isSuccess) {
      return r.Room.fromJson(responseData.data,isFavorite: true);
    }
    return null;
  }
  static Future<bool>toggleFavorites(String? roomId) async {
    ResponseData responseData = await connection.post('api/favorite/toggle', {'roomID':roomId});
    return responseData.isSuccess;
  }
  static Future<c.ChatMessage?>joinRoom(String id ,{bool refresh = false}) async {
    ResponseData responseData = await connection.post('api/room/join', {'id':id});
    if(responseData.isSuccess) {
      if(!refresh) {
        streamSocket.joinRoom(id);
      }
      return c.ChatMessage.fromJson(responseData.data);
    }
    return null;
  }
  static void listenChat(Function callback) {
    streamSocket.listenChat(callback);
  }
  static Future<void>sendChat(String? message, c.Room? room, String authorId) async {
    ResponseData responseData = await connection.post('api/message', {
      'authorID': authorId,
      'content': message,
      'contentType': "text",
      'roomID': room?.sId});
    if(responseData.isSuccess) {
      streamSocket.sendMessage(message, room);
    }
    return;
  }
  static Future<bool>uploadImage(XFile image, c.Room? room, String authorId)  async {
    ResponseData response = await connection.upload('api/upload', convertToFile(image),isImage: true);
    if(response.isSuccess) {
      ResponseData responseData = await connection.post('api/message', {
        'authorID': authorId,
        'content': response.data['image']['shieldedID'],
        'type': "image",
        'roomID': room?.sId});
      if(responseData.isSuccess) {
        streamSocket.sendMessage(response.data['image']['shieldedID'], room);
      }
      return responseData.isSuccess;
    }
    return response.isSuccess;
  }
  static Future<bool>uploadFile(File file, c.Room? room, String authorId)  async {
    ResponseData response = await connection.upload('api/upload/file', file, isImage: false);
    if(response.isSuccess) {
      ResponseData responseData = await connection.post('api/message', {
        'authorID': authorId,
        'content': response.data['file']['shieldedID'],
        'fileID': response.data['file']['_id'],
        'type': "file",
        'roomID': room?.sId});
      if(responseData.isSuccess) {
        streamSocket.sendMessage(response.data['file']['shieldedID'], room);
      }
      return responseData.isSuccess;
    }
    return response.isSuccess;
  }
  static Future<bool>removeRoom(String roomId) async {
    ResponseData responseData = await connection.post('api/room/remove', {'id':roomId});
    return responseData.isSuccess;
  }
  static Future<r.Rooms?>createGroup(String title ,List<String> people) async {
    ResponseData responseData = await connection.post('api/group/create', {'title':title, 'people': people});
    if(responseData.isSuccess) {
      return r.Rooms.fromJson(responseData.data);
    }
    return null;
  }
  static Future<ct.Contacts?>contactsList() async {
    ResponseData responseData = await connection.post('api/search', {'limit':500,'search':''});
    if(responseData.isSuccess) {
      return ct.Contacts.fromJson(responseData.data);
    }
    return null;
  }
  static File convertToFile(XFile xFile) => File(xFile.path);
  static reconnect() {
    streamSocket.socket.connect();
  }
  static dispose({bool isPaused=false}) {
    streamSocket.socket.disconnect();
    if(!isPaused) streamSocket.dispose();
  }
  static void showNotification(
      String notificationTitle,
      String notificationDes,
      Map<String, dynamic> message, String iconApp,
      Function(Map<String, dynamic>) onMessageCallback) {
    bool isImage = message['message']['type'] == 'image';
    bool isFile = message['message']['type'] == 'file';
    FlutterBeep.beep();
    showOverlayNotification((context) {
      return BannerNotification(
        notificationTitle: notificationTitle,
        notificationDescription: isImage ? '${HTTPConnection.domain}api/images/$notificationDes/256' : notificationDes,
        iconApp: iconApp,
        isImage: isImage,
        isFile: isFile,
        onReplay: () {
          onMessageCallback(message);
          OverlaySupportEntry.of(context)?.dismiss();
        },
      );
    }, duration: const Duration(seconds: 5));
  }
}