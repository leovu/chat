import 'package:chat/chat_ui/notification.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/notifications.dart' as n;
import 'package:chat/connection/http_connection.dart';
import 'package:chat/connection/socket.dart';
import 'package:chat/data_model/contact.dart' as ct;
import 'package:chat/data_model/user.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:chat/data_model/room.dart' as r;
import 'package:image_picker/image_picker.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ChatConnection {
  static late void Function() refreshRoom;
  static late Locale locale;
  static late void Function() refreshContact;
  static late void Function() refreshFavorites;
  static late void Function() refreshNotifications;
  static StreamSocket streamSocket = StreamSocket();
  static HTTPConnection connection = HTTPConnection();
  static late String appIcon;
  static String? roomId;
  static User? user;
  static late BuildContext buildContext;
  static List<Map<String,dynamic>>? addOnModules;
  static bool isLoadMore = false;
  static Map<String, dynamic>? initialData;
  static late Function(Map<String, dynamic> message) homeScreenNotificationHandler;
  static late Function(Map<String, dynamic> message) chatScreenNotificationHandler;
  static ValueNotifier<String> notificationNotifier = ValueNotifier('0');
  static Future<bool>init(String email,String password,{String? token}) async {
    HttpOverrides.global = MyHttpOverrides();
    String? resultToken;
    if(token != null) {
      resultToken = token;
    }
    else {
      resultToken = await login(email, password);
    }
    if(resultToken != null) {
      user = User(email:email,password:password,token:resultToken);
      Map<String, dynamic> payload = Jwt.parseJwt(resultToken);
      user!.id = payload['id'];
      user!.firstName = payload['firstName'];
      user!.lastName = payload['lastName'];
      streamSocket.connectAndListen(streamSocket,user!);
      return true;
    }
    else {
      return false;
    }
  }
  static Future<String?> login(String email,String password) async {
    ResponseData responseData = await connection.post('api/login', {'email':email,'password':password});
    if(responseData.isSuccess) {
      return responseData.data['token'];
    }
    return null;
  }
  static Future<String?>token(String email,String password) async {
    HttpOverrides.global = MyHttpOverrides();
    ResponseData responseData = await connection.post('api/login', {'email':email,'password':password});
    if(responseData.isSuccess) {
      return responseData.data['token'];
    }
    return null;
  }
  static bool checkConnected() {
    if(streamSocket.socket == null) {
      return false;
    }
    return streamSocket.checkConnected();
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
  static Future<n.Notifications?>notificationList() async {
    ResponseData responseData = await connection.post('api/notification/list', {});
    if(responseData.isSuccess) {
      n.Notifications result = n.Notifications.fromJson(responseData.data);
      int totalUnread = 0;
      result.notifications?.forEach((e) {
        if(e.isRead == 0) {
          totalUnread += 1;
        }
      });
      ChatConnection.notificationNotifier.value = totalUnread > 99 ? '99+' : '$totalUnread';
      return result;
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
  static Future<List<c.Messages>?>loadMoreMessageRoom(String id , String firstMessageID) async {
    ResponseData responseData = await connection.post('api/messages/more', {'roomID':id, 'firstMessageID':firstMessageID});
    if(responseData.isSuccess) {
      List<dynamic> json = responseData.data['messages'];
      List<c.Messages>? data = json.reversed.map((e) => c.Messages.fromJson(e)).toList();
      return data;
    }
    return null;
  }
  static void listenChat(Function callback) {
    streamSocket.listenChat(callback);
  }
  static Future<void>sendChat(c.ChatMessage? data,List<types.Message> listMessage,String id,
      String? message, c.Room? room, String authorId, {String? reppliedMessageId}) async {
    Map<String,dynamic> json = {
      'authorID': authorId,
      'content': message,
      'contentType': "text",
      'roomID': room?.sId};
    if(reppliedMessageId != null) {
      json['replies'] = reppliedMessageId;
    }
    ResponseData responseData = await connection.post('api/message', json);
    if(responseData.isSuccess) {
      streamSocket.sendMessage(message, room);
      types.Message val = listMessage.firstWhere((element) => element.id == id);
      int index = listMessage.indexOf(val);
      c.Messages valueResponse =  c.Messages.fromJson(responseData.data['message']);
      listMessage[index] = types.TextMessage(
          author: listMessage[index].author,
          createdAt: listMessage[index].createdAt,
          id: valueResponse.sId!,
          text: (listMessage[index] as types.TextMessage).text,
          repliedMessage: listMessage[index].repliedMessage
      );
      data?.room?.messages?.insert(0,valueResponse);
    }
    return;
  }
  static Future<bool>forwardMessage(String? message, c.Room? room, String authorId, String? reppliedMessageId) async {
    ResponseData responseData = await connection.post('api/message', {
      'authorID': authorId,
      'content': message,
      'contentType': "text",
      'roomID': room?.sId,
      'forward':1,
      'replies': reppliedMessageId});
    if(responseData.isSuccess) {
      streamSocket.sendMessage(message, room);
    }
    return responseData.isSuccess;
  }
  static Future<void>updateChat(String data,String? messageId,c.Room? room, {String? reppliedMessageId}) async {
    Map<String,dynamic> json = {
      'data': data,
      'messageId': messageId,
      'type': "edit",
      'roomId': room!.sId};
    if(reppliedMessageId != null) {
      json['replies'] = reppliedMessageId;
    }
    ResponseData responseData = await connection.post('api/message/update', json);
    if(responseData.isSuccess) {
      streamSocket.sendMessage(data, room);
    }
    return;
  }
  static Future<bool>recall(c.Messages? value, c.Room? room) async{
    ResponseData responseData = await connection.post('api/message/update', {'data':value?.content, 'messageId':value?.sId, 'roomId': room!.sId,'type':'recall'});
    if(responseData.isSuccess) {
      streamSocket.sendMessage(value?.content, room);
      return true;
    }
    return false;
  }
  static Future<bool>pinMessage(String? data, c.Room? room) async {
    ResponseData responseData = await connection.post('api/group/update',
        {'data':data, 'field': 'pinMessage', 'roomId': room?.sId,'type':'single-data'});
    if(responseData.isSuccess) {
      streamSocket.sendMessage(data, room);
      return true;
    }
    return false;
  }
  static Future<String?>uploadImage(BuildContext context, c.ChatMessage? data,List<types.Message> listMessage,String id,  XFile image, c.Room? room, String authorId)  async {
    int sizeInBytes = await image.length();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    if (sizeInMb > 20){
      showError(context);
      return 'limit';
    }
    ResponseData response = await connection.upload('api/upload', convertToFile(image),isImage: true);
    if(response.isSuccess) {
      ResponseData responseData = await connection.post('api/message', {
        'authorID': authorId,
        'content': response.data['image']['shieldedID'],
        'imageID': response.data['image']['_id'],
        'type': "image",
        'roomID': room?.sId});
      if(responseData.isSuccess) {
        streamSocket.sendMessage(response.data['image']['shieldedID'], room);
        types.Message val = listMessage.firstWhere((element) => element.id == id);
        int index = listMessage.indexOf(val);
        c.Messages valueResponse =  c.Messages.fromJson(responseData.data['message']);
        types.Status s = valueResponse.sId==null ? types.Status.error : types.Status.sent;
        listMessage[index] = types.ImageMessage(
            author: listMessage[index].author,
            createdAt: listMessage[index].createdAt,
            id: valueResponse.sId!,
            height: (listMessage[index] as types.ImageMessage).height,
            name: (listMessage[index] as types.ImageMessage).name,
            size: (listMessage[index] as types.ImageMessage).size,
            uri: '${HTTPConnection.domain}api/images/${valueResponse.content}',
            width: (listMessage[index] as types.ImageMessage).width,
            showStatus: true,
            status: s,
            repliedMessage: listMessage[index].repliedMessage
        );
        data?.room?.messages?.insert(0,valueResponse);
        return valueResponse.sId!;
      }
    }
    return null;
  }
  static Future<String?>uploadFile(BuildContext context, c.ChatMessage? data,List<types.Message> listMessage,String id, File file, c.Room? room, String authorId)  async {
    int sizeInBytes = file.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    if (sizeInMb > 20){
      showError(context);
      return 'limit';
    }
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
        types.Message val = listMessage.firstWhere((element) => element.id == id);
        int index = listMessage.indexOf(val);
        c.Messages valueResponse =  c.Messages.fromJson(responseData.data['message']);
        types.Status s = valueResponse.sId==null ? types.Status.error : types.Status.sent;
        listMessage[index] = types.FileMessage(
            author: listMessage[index].author,
            createdAt: listMessage[index].createdAt,
            id: valueResponse.sId!,
            mimeType: (listMessage[index] as types.FileMessage).mimeType,
            name: (listMessage[index] as types.FileMessage).name,
            size: (listMessage[index] as types.FileMessage).size,
            uri: '${HTTPConnection.domain}api/files/${valueResponse.file!.shieldedID!}',
            showStatus: true,
            status: s,
            repliedMessage: listMessage[index].repliedMessage
        );
        data?.room?.messages?.insert(0,valueResponse);
        return valueResponse.sId!;
      }
    }
    return null;
  }
  static Future<bool>updateRoomName(String roomId,String data) async {
    ResponseData responseData = await connection.post('api/group/update', {'data':data,'roomId':roomId,'type':'title'});
    return responseData.isSuccess;
  }
  static Future<bool>removeRoom(String roomId) async {
    ResponseData responseData = await connection.post('api/room/remove', {'id':roomId});
    return responseData.isSuccess;
  }
  static Future<bool>leaveRoom(String roomId, String? userId) async {
    ResponseData responseData = await connection.post('api/group/update', {'data': userId, 'type': 'remove-people', 'roomId' : roomId});
    return responseData.isSuccess;
  }
  static Future<r.Rooms?>createGroup(String title ,List<String> people, String owner) async {
    ResponseData responseData = await connection.post('api/group/create', {'title':title, 'people': people, 'owner':owner});
    if(responseData.isSuccess) {
      return r.Rooms.fromJson(responseData.data);
    }
    return null;
  }
  static Future<bool>readNotification(String notiId) async {
    ResponseData responseData = await connection.post('api/notification/update', {'type':'read', 'notiId': notiId});
    return responseData.isSuccess;
  }
  static Future<bool>addMemberGroup(List<String> people, String roomId) async {
    ResponseData responseData = await connection.post('api/group/update', {'data': people, 'type': 'add-people', 'roomId' : roomId});
    if(responseData.isSuccess) {
      return responseData.isSuccess;
    }
    return false;
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
    streamSocket.socket!.connect();
  }
  static dispose({bool isDispose = false}) {
    if(!isDispose) {
      streamSocket.socket!.disconnect();
    }
    else {
      streamSocket.socket!.disconnect();
      streamSocket.dispose();
    }
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
    }, duration: const Duration(seconds: 2));
  }
  static void showError(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.warning)),
        content: Text(AppLocalizations.text(LangKey.limitSizeUpload)),
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