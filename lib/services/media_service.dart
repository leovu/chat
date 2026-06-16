import 'dart:io';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/connection/socket.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';

class MediaService {
  static File convertToFile(XFile xFile) => File(xFile.path);

  static Future<String?> uploadImage(
    HTTPConnection connection,
    StreamSocket streamSocket, {
    required bool isChatHub,
    required String? brandCode,
    required BuildContext context,
    required c.ChatMessage? data,
    required List<types.Message> listMessage,
    required String id,
    required XFile image,
    required c.Room? room,
    required String authorId,
    required void Function(BuildContext, {String? content}) showError,
  }) async {
    final sizeInBytes = await image.length();
    final sizeInMb = sizeInBytes / (1024 * 1024);
    if (sizeInMb > 20) {
      showError(context);
      return 'limit';
    }
    final response = await connection.upload('api/upload', convertToFile(image), isImage: true);
    if (response.isSuccess) {
      final version = isChatHub ? '/v2' : '';
      final responseData = await connection.post('api$version/message', {
        'authorID': authorId,
        'content': response.data['image']['shieldedID'],
        'imageID': response.data['image']['_id'],
        'type': 'image',
        'roomID': room?.sId,
      });
      if (responseData.isSuccess) {
        streamSocket.sendMessage(response.data['image']['shieldedID'], room);
        final val = listMessage.firstWhere((element) => element.id == id);
        final index = listMessage.indexOf(val);
        final valueResponse = c.Messages.fromJson(
          isChatHub ? responseData.data['data']['message'] : responseData.data['message'],
        );
        final s = valueResponse.sId == null ? types.Status.error : types.Status.sent;
        final oldMessage = listMessage[index] as types.ImageMessage;
        String newUri;
        if (valueResponse.image?.location != null && valueResponse.image!.location!.isNotEmpty) {
          newUri = valueResponse.image!.location!;
        } else if (valueResponse.content != null && valueResponse.content!.isNotEmpty) {
          newUri = '${HTTPConnection.domain}api/images/${valueResponse.content}/$brandCode';
        } else {
          newUri = oldMessage.uri;
        }
        listMessage[index] = types.ImageMessage(
          author: oldMessage.author,
          createdAt: oldMessage.createdAt,
          id: valueResponse.sId!,
          height: oldMessage.height,
          name: oldMessage.name,
          size: oldMessage.size,
          uri: newUri,
          width: oldMessage.width,
          showStatus: true,
          status: s,
          metadata: oldMessage.metadata,
          repliedMessage: oldMessage.repliedMessage,
        );
        data?.room?.messages?.insert(0, valueResponse);
        return valueResponse.sId!;
      }
    }
    return null;
  }

  static Future<String?> uploadFile(
    HTTPConnection connection,
    StreamSocket streamSocket, {
    required bool isChatHub,
    required BuildContext context,
    required c.ChatMessage? data,
    required List<types.Message> listMessage,
    required String id,
    required File file,
    required c.Room? room,
    required String authorId,
    required void Function(BuildContext, {String? content}) showError,
  }) async {
    final sizeInBytes = file.lengthSync();
    final sizeInMb = sizeInBytes / (1024 * 1024);
    if (sizeInMb > 20) {
      showError(context);
      return 'limit';
    }
    final response = await connection.upload('api/upload/file', file, isImage: false);
    if (response.isSuccess) {
      final version = isChatHub ? '/v2' : '';
      final responseData = await connection.post('api$version/message', {
        'authorID': authorId,
        'content': response.data['file']['shieldedID'],
        'fileID': response.data['file']['_id'],
        'type': 'file',
        'roomID': room?.sId,
      });
      if (responseData.isSuccess) {
        streamSocket.sendMessage(response.data['file']['shieldedID'], room);
        final val = listMessage.firstWhere((element) => element.id == id);
        final index = listMessage.indexOf(val);
        final valueResponse = c.Messages.fromJson(
          isChatHub ? responseData.data['data']['message'] : responseData.data['message'],
        );
        final s = valueResponse.sId == null ? types.Status.error : types.Status.sent;
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
          repliedMessage: listMessage[index].repliedMessage,
        );
        data?.room?.messages?.insert(0, valueResponse);
        return valueResponse.sId!;
      }
    }
    return null;
  }
}
