import 'package:chat/connection/http_connection.dart';
import 'package:chat/connection/socket.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/contact.dart' as ct;
import 'package:chat/data_model/room.dart' as r;

class RoomService {
  static Future<r.Rooms?> createRoom(HTTPConnection connection, String? counterpart) async {
    final responseData = await connection.post('api/room/create', {'counterpart': counterpart});
    if (responseData.isSuccess) return r.Rooms.fromJson(responseData.data['room']);
    return null;
  }

  static Future<r.Room?> roomList(
    HTTPConnection connection, {
    required bool isChatHub,
    String? source,
    String? channelId,
    String? status,
    List<String?>? tagIds,
    int page = 1,
    r.Room? roomData,
    String? link_status,
    String? startDate,
    String? endDate,
    bool? isGroup,
    String? keyword,
  }) async {
    final Map<String, dynamic> json = {'page': page, 'limit': 15};
    if (source != null) json['source'] = source;
    if (channelId != null) json['channel_id'] = channelId;
    if (status != null) json['status'] = status;
    if (link_status != null) json['linked_status'] = link_status;
    if (startDate != null && endDate != null) json['created_at'] = [startDate, endDate];
    if (isGroup == true) json['is_group'] = isGroup;
    if (keyword != null) json['keyword'] = keyword;
    if (tagIds != null && tagIds.isNotEmpty) {
      final parsed = tagIds.where((e) => e != null).map((e) => e!).toList();
      if (parsed.isNotEmpty) json['tag_ids'] = parsed;
    }
    final url = isChatHub ? 'api/v3/list-rooms' : 'api/rooms/list';
    final responseData = await connection.post(url, json);
    if (responseData.isSuccess) {
      final room = r.Room.fromJson(responseData.data);
      if (page != 1 && roomData != null) {
        final existingIds = roomData.rooms!.map((r) => r.sId).toSet();
        final newRooms = room.rooms!.where((r) => !existingIds.contains(r.sId)).toList();
        roomData.rooms!.addAll(newRooms);
        return roomData;
      }
      return room;
    }
    return null;
  }

  static Future<r.Room?> favoritesList(HTTPConnection connection) async {
    final responseData = await connection.post('api/favorites/list', {});
    if (responseData.isSuccess) return r.Room.fromJson(responseData.data, isFavorite: true);
    return null;
  }

  static Future<c.ChatMessage?> joinRoom(
    HTTPConnection connection,
    StreamSocket streamSocket, {
    required bool isChatHub,
    required String id,
    bool refresh = false,
  }) async {
    try {
      final url = isChatHub ? 'api/v3/join-room' : 'api/room/join';
      final responseData = await connection.post(url, {'id': id});
      if (responseData.isSuccess) {
        if (!refresh) streamSocket.joinRoom(id);
        await autoUpdateChatSeenWhenJoinRoom(connection, id);
        return c.ChatMessage.fromJson(responseData.data);
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> autoUpdateChatSeenWhenJoinRoom(HTTPConnection connection, String id) async {
    final responseData = await connection.post('api/notification/update-chat', {'id': id});
    return responseData.isSuccess;
  }

  static Future<bool> toggleFavorites(HTTPConnection connection, String? roomId) async {
    final responseData = await connection.post('api/favorite/toggle', {'roomID': roomId});
    return responseData.isSuccess;
  }

  static Future<bool> updateRoomName(HTTPConnection connection, String roomId, String data) async {
    final responseData = await connection.post('api/group/update', {'data': data, 'roomId': roomId, 'type': 'title'});
    return responseData.isSuccess;
  }

  static Future<bool> removeRoom(HTTPConnection connection, String roomId) async {
    final responseData = await connection.post('api/room/remove', {'id': roomId});
    return responseData.isSuccess;
  }

  static Future<bool> leaveRoom(HTTPConnection connection, String roomId, String? userId) async {
    final responseData = await connection.post('api/group/update', {'data': userId, 'type': 'remove-people', 'roomId': roomId});
    return responseData.isSuccess;
  }

  static Future<r.Rooms?> createGroup(HTTPConnection connection, String title, List<String> people, String owner) async {
    final responseData = await connection.post('api/group/create', {'title': title, 'people': people, 'owner': owner});
    if (responseData.isSuccess) return r.Rooms.fromJson(responseData.data);
    return null;
  }

  static Future<List<c.Messages>?> loadMoreMessageRoom(
    HTTPConnection connection, {
    required bool isChatHub,
    required String id,
    required String firstMessageID,
    required String firstMessageDate,
  }) async {
    final url = isChatHub ? 'api/v2/message/more' : 'api/messages/more';
    final responseData = await connection.post(url, {
      'roomID': id,
      'firstMessageID': firstMessageID,
      'firstMessageDate': firstMessageDate,
    });
    if (responseData.isSuccess) {
      final List<dynamic> json = responseData.data['messages'];
      return json.reversed.map((e) => c.Messages.fromJson(e)).toList();
    }
    return null;
  }

  static Future<ct.Contacts?> contactsList(HTTPConnection connection) async {
    final responseData = await connection.post('api/search', {'limit': 500, 'search': ''});
    if (responseData.isSuccess) return ct.Contacts.fromJson(responseData.data);
    return null;
  }

  static Future<ct.Contacts?> contactsSearch(HTTPConnection connection, String search, {int limit = 50}) async {
    final responseData = await connection.post('api/search', {'limit': limit, 'search': search});
    if (responseData.isSuccess) return ct.Contacts.fromJson(responseData.data);
    return null;
  }
}
