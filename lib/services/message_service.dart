import 'package:chat/connection/http_connection.dart';
import 'package:chat/connection/socket.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class MessageService {
  static void listenChat(StreamSocket streamSocket, Function callback) {
    streamSocket.listenChat(callback);
  }

  static Future<String?> sendChat(
    HTTPConnection connection,
    StreamSocket streamSocket, {
    required bool isChatHub,
    required c.ChatMessage? data,
    required List<types.Message> listMessage,
    required String id,
    required String? message,
    required c.Room? room,
    required String authorId,
    String? reppliedMessageId,
  }) async {
    final json = {
      'authorID': authorId,
      'content': message ?? '',
      'type': 'text',
      'roomID': room?.sId ?? '',
      if (reppliedMessageId != null) ...{
        'replies': reppliedMessageId,
        'action': 'reply',
      },
    };
    final version = isChatHub ? '/v2' : '';
    final responseData = await connection.post('api$version/message', json);
    if (!responseData.isSuccess) return null;

    streamSocket.sendMessage(message, room);

    final defaultAuthor = types.User(id: 'default-user');
    final val = listMessage.cast<types.Message?>().firstWhere(
          (element) => element?.id == id,
          orElse: () => types.TextMessage(
            id: 'default-id',
            author: defaultAuthor,
            text: '',
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ),
        )!;
    final index = listMessage.indexWhere((element) => element.id == val.id);
    final targetIndex = index != -1 ? index : listMessage.length;
    final messageJson = responseData.data['data']?['message'];
    if (messageJson == null) return null;

    final valueResponse = c.Messages.fromJson(messageJson);
    final oldMessage = index != -1 ? listMessage[index] : val;
    final newMsg = types.TextMessage(
      author: oldMessage.author,
      createdAt: oldMessage.createdAt,
      id: valueResponse.sId ?? 'default-id',
      text: (oldMessage as types.TextMessage).text,
      repliedMessage: oldMessage.repliedMessage,
      status: (responseData.data['error'] == 0) ? null : types.Status.error,
      metadata: responseData.data['message'] != null
          ? {'error_message': responseData.data['message']}
          : null,
    );
    listMessage.length <= targetIndex
        ? listMessage.add(newMsg)
        : listMessage[targetIndex] = newMsg;
    data?.room?.messages?.insert(0, valueResponse);

    final quota = responseData.data['data']?['quota'];
    if (quota != null) {
      final type = quota['type'];
      if (type == 'OA Tier') return AppLocalizations.text(LangKey.zaloSendOATier);
      if (type == 'reply') {
        return '${AppLocalizations.text(LangKey.zaloSendReply1)}${quota['remain'] ?? 0}/${quota['total'] ?? 0}${AppLocalizations.text(LangKey.zaloSendReply2)}';
      }
      return AppLocalizations.text(LangKey.zaloSendOther);
    }
    return null;
  }

  static Future<bool> forwardMessage(
    HTTPConnection connection,
    StreamSocket streamSocket, {
    required bool isChatHub,
    required String? message,
    required c.Room? room,
    required String authorId,
    required String? reppliedMessageId,
  }) async {
    final version = isChatHub ? '/v2' : '';
    final responseData = await connection.post('api$version/message', {
      'authorID': authorId,
      'content': message,
      'contentType': 'text',
      'roomID': room?.sId,
      'forward': 1,
      'replies': reppliedMessageId,
    });
    if (responseData.isSuccess) streamSocket.sendMessage(message, room);
    return responseData.isSuccess;
  }

  static Future<void> updateChat(
    HTTPConnection connection,
    StreamSocket streamSocket,
    String data,
    String? messageId,
    c.Room? room, {
    String? reppliedMessageId,
  }) async {
    final Map<String, dynamic> json = {
      'data': data,
      'messageId': messageId,
      'type': 'edit',
      'roomId': room!.sId,
    };
    if (reppliedMessageId != null) json['replies'] = reppliedMessageId;
    final responseData = await connection.post('api/message/update', json);
    if (responseData.isSuccess) streamSocket.sendMessage(data, room);
  }

  static Future<bool> recall(
    HTTPConnection connection,
    StreamSocket streamSocket,
    c.Messages? value,
    c.Room? room,
  ) async {
    final responseData = await connection.post('api/message/update', {
      'data': value?.content,
      'messageId': value?.sId,
      'roomId': room!.sId,
      'type': 'recall',
    });
    if (responseData.isSuccess) {
      streamSocket.sendMessage(value?.content, room);
      return true;
    }
    return false;
  }

  static Future<bool> pinMessage(
    HTTPConnection connection,
    StreamSocket streamSocket,
    String? data,
    c.Room? room,
  ) async {
    final responseData = await connection.post('api/group/update', {
      'data': data,
      'field': 'pinMessage',
      'roomId': room?.sId,
      'type': 'single-data',
    });
    if (responseData.isSuccess) {
      streamSocket.sendMessage(data, room);
      return true;
    }
    return false;
  }
}
