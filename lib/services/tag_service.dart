import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/tag.dart';

class TagService {
  static Future<Tag?> getTagList(HTTPConnection connection) async {
    final responseData = await connection.get('api/tags/lists');
    if (responseData.isSuccess) return Tag.fromJson(responseData.data);
    return null;
  }

  static Future<Tag?> getTagListByUser(HTTPConnection connection, String userId) async {
    final responseData = await connection.post('api/v2/tags/list-by-user', {'user_id': userId});
    if (responseData.isSuccess) return Tag.fromListJson(responseData.data['data']);
    return null;
  }

  static Future<bool> createTag(HTTPConnection connection, String name, String color, String userId) async {
    final responseData = await connection.post('api/v2/tags/create', {'name': name, 'color': color, 'user_id': userId});
    return responseData.isSuccess;
  }

  static Future<Map<String, dynamic>> removeTag(HTTPConnection connection, String tagId, String userId) async {
    final responseData = await connection.post('api/tags/remove', {'tag_id': tagId, 'user_id': userId});
    return responseData.data;
  }

  static Future<bool> updateTag(HTTPConnection connection, List<String> tagIds, String userId) async {
    final responseData = await connection.post('api/tags/user-add', {'tag_ids': tagIds, 'user_id': userId});
    return responseData.isSuccess;
  }
}
