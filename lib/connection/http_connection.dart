import 'dart:convert';
import 'dart:io';
import 'package:chat/connection/chat_connection.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class HTTPConnection {
  static String domain = 'https://chat-stag.epoints.vn/';
  Future<ResponseData> upload(String path, File file , {bool isImage = false}) async {
    final uri = Uri.parse('$domain$path');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Authorization':'Bearer ${ChatConnection.user!.token}',
      'uid': ChatConnection.user!.id,
      'lang': ChatConnection.locale.languageCode
    });
    if(ChatConnection.brandCode != null) {
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
    if (kDebugMode) {
      print('***** Upload *****');
      print(uri);
      print(request.headers);
      print(response.statusCode);
      print('***** Upload *****');
    }
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
      headers['uid'] = ChatConnection.user!.id;
    }
    if(ChatConnection.brandCode != null) {
      headers['brand-code'] = ChatConnection.brandCode!;
    }
    headers['lang'] = ChatConnection.locale.languageCode;
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');
    http.Response response = await http.post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );
    if (kDebugMode) {
      print('***** POST *****');
      print(uri);
      print(headers);
      print(jsonBody);
      print(response.statusCode);
      print('***** POST *****');
    }
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
  Future<ResponseData>get(String path) async {
    final uri = Uri.parse('$domain$path');
    Map<String, String> headers = {};
    if(ChatConnection.user != null) {
      headers['Authorization'] = 'Bearer ${ChatConnection.user!.token}';
      headers['uid'] = ChatConnection.user!.id;
    }
    if(ChatConnection.brandCode != null) {
      headers['brand-code'] = ChatConnection.brandCode!;
    }
    headers['lang'] = ChatConnection.locale.languageCode;
    if (kDebugMode) {
      print('***** GET *****');
      print(uri);
      print(headers);
      print('***** GET *****');
    }
    http.Response response = await http.get(
      uri,
      headers: headers,
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
      try {
        String responseBody = response.body;
        data.data = jsonDecode(responseBody);
      }catch(_) {}
      return data;
    }
  }
}

class ResponseData {
  late bool isSuccess;
  late Map<String,dynamic> data;
}

