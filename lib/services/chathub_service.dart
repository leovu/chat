import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/chathub_channel.dart';
import 'package:chat/data_model/response/room_info_response_model.dart';
import 'package:chat/data_model/session.dart';
import 'package:chat/data_model/summary.dart';

class ChatHubService {
  static Future<ChathubChannel?> channelList(HTTPConnection connection) async {
    final responseData = await connection.post('api/channels/list', {});
    if (responseData.isSuccess) return ChathubChannel.fromJson(responseData.data);
    return null;
  }

  static Future<bool> changeStatusChatbot(HTTPConnection connection, String roomId, int status) async {
    try {
      final response = await connection.post('api/chatbot/change-status', {'room_id': roomId, 'status': status});
      return response.isSuccess;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> clearChat(HTTPConnection connection, String roomId) async {
    try {
      final response = await connection.post('api/message/clear', {'roomId': roomId});
      return response.isSuccess;
    } catch (_) {
      return false;
    }
  }

  static Future<c.Owner?> blockUser(HTTPConnection connection, String userId, bool isBlocked) async {
    try {
      final response = await connection.post('api/user/block', {'userId': userId, 'isBlocked': isBlocked});
      if (response.isSuccess) return c.Owner.fromJson(response.data['data']);
    } catch (_) {}
    return null;
  }

  static Future<List<SessionModel>> getSession(HTTPConnection connection, String roomId, {int? limit = 5, int? offset = 0}) async {
    try {
      final response = await connection.post('api/sessions', {'room_id': roomId, 'limit': limit, 'offset': offset});
      if (response.isSuccess) {
        final List<dynamic> dataList = response.data['data'];
        return dataList.map((json) => SessionModel.fromJson(json)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<List<c.Messages>> getSessionMessages(HTTPConnection connection, List<String> messageIds) async {
    try {
      final response = await connection.post('api/sessions/messages', {'message_ids': messageIds});
      if (response.isSuccess) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => c.Messages.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<ConversationSummaryModel?> getSummary(HTTPConnection connection, String sessionId) async {
    try {
      final response = await connection.post('api/summary', {'session_id': sessionId});
      if (response.isSuccess) return ConversationSummaryModel.fromJson(response.data['data']);
    } catch (_) {}
    return null;
  }

  static Future<RoomResponse?> getRoomByPhoneNumber(HTTPConnection connection, String customerPhone) async {
    try {
      final response = await connection.post(
        'public/zalo-personal/redirect-to-room',
        {'customer_phone': customerPhone},
        isJoinByNumberPhone: true,
      );
      return RoomResponse.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }

  static Future<bool> messageSystem(HTTPConnection connection, String authorID, String roomID) async {
    final responseData = await connection.post('api/v2/message-system', {
      'action': 'message',
      'authorID': authorID,
      'content': 'Đã gửi tin tương tác: Tin đánh giá',
      'roomID': roomID,
      'type': 'system',
    });
    return responseData.isSuccess;
  }
}
