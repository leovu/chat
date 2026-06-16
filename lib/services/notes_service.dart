import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/response/notes_response_model.dart';

class NotesService {
  static Future<NotesResponseModel?> notes(HTTPConnection connection, String roomId) async {
    final responseData = await connection.post('api/v2/notes', {'room_id': roomId, 'offset': 0, 'limit': 100});
    if (responseData.isSuccess) return NotesResponseModel.fromJson(responseData.data);
    return null;
  }

  static Future<bool> createNotes(HTTPConnection connection, String roomId, String content) async {
    final responseData = await connection.post('api/v2/notes/create', {'content': content, 'room_id': roomId});
    return responseData.isSuccess;
  }

  static Future<bool> updateNotes(HTTPConnection connection, String roomId, String content, String noteId) async {
    final responseData = await connection.post('api/v2/notes/update', {'room_id': roomId, 'content': content, 'note_id': noteId});
    return responseData.isSuccess;
  }

  static Future<bool> deleteNotes(HTTPConnection connection, String roomId, String noteId) async {
    final responseData = await connection.post('api/v2/notes/delete', {'note_id': noteId, 'room_id': roomId});
    return responseData.isSuccess;
  }
}
