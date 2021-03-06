import 'dart:convert';
import 'dart:io';
import 'package:chat/connection/chat_connection.dart';
import 'package:http/http.dart' as http;

class HTTPConnection {
  static String domain = 'https://chat-stag.epoints.vn/';
  Future<ResponseData> upload(String path, File file , {bool isImage = false}) async {
    final uri = Uri.parse('$domain$path');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({'Content-Type': 'multipart/form-data','Authorization':'Bearer ${ChatConnection.user!.token}'});
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
    if(response.statusCode == 200) {
      ResponseData data = ResponseData();
      data.isSuccess = true;
      data.data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    }
    else {
      ResponseData data = ResponseData();
      data.isSuccess = false;
      return data;
    }
  }
  Future<ResponseData>post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$domain$path');
    final headers = {'Content-Type': 'application/json'};
    if(ChatConnection.user != null) {
      headers['Authorization'] = 'Bearer ${ChatConnection.user!.token}';
    }
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');
    http.Response response = await http.post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );
    int statusCode = response.statusCode;
    if(statusCode == 200) {
      String responseBody = response.body;
      ResponseData data = ResponseData();
      data.isSuccess = true;
      data.data = jsonDecode(responseBody);
      return data;
    }
    else {
      ResponseData data = ResponseData();
      data.isSuccess = false;
      return data;
    }
  }
}

class ResponseData {
  late bool isSuccess;
  late Map<String,dynamic> data;
}

