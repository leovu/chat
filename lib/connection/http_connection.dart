import 'dart:convert';
import 'dart:io';
import 'package:chat/connection/chat_connection.dart';
import 'package:http/http.dart' as http;

import '../localization/app_localizations.dart';
import '../localization/lang_key.dart';

class HTTPConnection {
  // static String domain = 'https://chat-stag.epoints.vn/';
  static String domain = ChatConnection.isChatHub
      ? 'https://chathub.epoints.vn/'
      : 'https://chat.epoints.vn/';
  static String apiKeyGetRoom = '62da77474991df7aa711a632';
  Future<ResponseData> upload(String path, File file,
      {bool isImage = false}) async {
    final uri = Uri.parse('$domain$path');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer ${ChatConnection.user!.token}',
      'uid': ChatConnection.uid.toString(),
      'lang': ChatConnection.locale.languageCode,
    });
    if (ChatConnection.brandCode != null) {
      request.headers['brand-code'] = ChatConnection.brandCode!;
    }
    request.files.add(
      http.MultipartFile(
        isImage ? 'image' : 'file',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: file.path.split("/").last,
      ),
    );
    var streamResponse = await request.send();
    var response = await http.Response.fromStream(streamResponse);
    // if (kDebugMode) {
    //   print(
    //       '****************************** Upload ******************************');
    //   print(uri);
    //   print(request.headers);
    //   print(response.statusCode);
    //   print(response.body);
    //   print(
    //       '****************************** Upload ******************************');
    // }
    if (response.statusCode == 200) {
      ResponseData data = ResponseData();
      data.isSuccess = true;
      data.data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } else {
      ResponseData data = ResponseData();
      data.isSuccess = false;
      return data;
    }
  }

  Future<ResponseData> post(String path, Map<String, dynamic> body,
      {bool isJoinByNumberPhone = false, Map<String, dynamic>? header}) async {
    final uri = Uri.parse('$domain$path');
    final headers = {'Content-Type': 'application/json'};

    if (ChatConnection.user != null) {
      headers['Authorization'] = 'Bearer ${ChatConnection.user!.token}';
      headers['uid'] = ChatConnection.uid.toString();
      if (isJoinByNumberPhone) headers['api-key'] = apiKeyGetRoom;
    }
    if (ChatConnection.brandCode != null) {
      headers['brand-code'] = ChatConnection.brandCode!;
    }
    headers['lang'] = ChatConnection.locale.languageCode;

    final encoding = Encoding.getByName('utf-8');
    final jsonBody = json.encode(body);
    if (header != null && header.isNotEmpty) {
      headers.addAll(headers);
    }

    http.Response response = await http.post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    // if (kDebugMode) {
    //   print('\n******** POST ********');
    //   print(uri);
    //   print(headers);
    //   print(jsonBody);
    //   print(response.statusCode);
    //   print("response.body: ${response.body}");
    //   print('******** POST ********\n');
    // }

    ResponseData data = ResponseData();
    try {
      final decoded = jsonDecode(response.body);
      final hasErrorField = decoded is Map && decoded.containsKey('error');

      if (response.statusCode == 200 &&
          (!hasErrorField || decoded['error'] == 0)) {
        data.isSuccess = true;
        data.data = decoded;
      } else {
        data.isSuccess = false;
        data.message = decoded['message'] ?? 'Unknown error';
        data.data = decoded;
      }
    } catch (e) {
      data.isSuccess = false;
    }

    return data;
  }

  Future<List<dynamic>> postReturnList(String path, Map<String, dynamic> body,
      {bool isJoinByNumberPhone = false}) async {
    final uri = Uri.parse('$domain$path');
    final headers = {'Content-Type': 'application/json'};

    // Thêm thông tin user và brandCode nếu có
    if (ChatConnection.user != null) {
      headers['Authorization'] = 'Bearer ${ChatConnection.user!.token}';
      headers['uid'] = ChatConnection.uid.toString();
      if (isJoinByNumberPhone) headers['api-key'] = apiKeyGetRoom;
    }
    if (ChatConnection.brandCode != null) {
      headers['brand-code'] = ChatConnection.brandCode!;
    }
    headers['lang'] = ChatConnection.locale.languageCode;

    final encoding = Encoding.getByName('utf-8');
    final jsonBody = json.encode(body);

    // Gửi POST request
    http.Response response = await http.post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );

    // In thông tin khi ở chế độ debug
    // if (kDebugMode) {
    //   print('\n******** POST ********');
    //   print(uri);
    //   print(headers);
    //   print(jsonBody);
    //   print(response.statusCode);
    //   print("response.body: ${response.body}");
    //   print('******** POST ********\n');
    // }

    try {
      // Giải mã JSON từ response.body
      final decoded = jsonDecode(response.body);

      // Kiểm tra mã trạng thái HTTP và lỗi trong response
      if (response.statusCode == 200 && decoded is List) {
        // Trả về danh sách nếu response chứa List
        return decoded;
      } else {
        // Nếu có lỗi hoặc không phải danh sách, trả về danh sách rỗng
        return [];
      }
    } catch (e) {
      // Trường hợp xảy ra lỗi trong quá trình giải mã JSON
      return [];
    }
  }

  Future<ResponseData> get(String path) async {
    final uri = Uri.parse('$domain$path');
    Map<String, String> headers = {};

    if (ChatConnection.user != null) {
      headers['Authorization'] = 'Bearer ${ChatConnection.user!.token}';
      headers['uid'] = ChatConnection.uid.toString();
    }
    if (ChatConnection.brandCode != null) {
      headers['brand-code'] = ChatConnection.brandCode!;
    }
    headers['lang'] = ChatConnection.locale.languageCode;

    http.Response response = await http.get(
      uri,
      headers: headers,
    );

    // if (kDebugMode) {
    //   print('\n******** GET ********');
    //   print(uri);
    //   print(headers);
    //   print("status: ${response.statusCode}");
    //   print("body: ${response.body}");
    //   print('******** GET ********\n');
    // }

    ResponseData data = ResponseData();
    try {
      final decoded = jsonDecode(response.body);
      final hasErrorField = decoded is Map && decoded.containsKey('error');

      if (response.statusCode == 200 &&
          (!hasErrorField || decoded['error'] == 0)) {
        data.isSuccess = true;
        data.data = decoded;
      } else {
        data.isSuccess = false;
        data.message = decoded['message'] ?? 'Unknown error';
        data.data = decoded;
      }
    } catch (e) {
      data.isSuccess = false;
      data.message = AppLocalizations.text(LangKey.server_response_error);
    }

    return data;
  }
}

class ResponseData {
  late bool isSuccess;
  late Map<String, dynamic> data;
  late String message;
}
