import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

void saveDraftInput (Map<String,dynamic> value, String roomId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('Draft_Chat_$roomId', jsonEncode(value));
}
Future<Map<String,dynamic>?> getDraftInput(String roomId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? chatDraft = prefs.getString('Draft_Chat_$roomId');
  if(chatDraft != null) {
    Map<String,dynamic> chatDraftMap = jsonDecode(chatDraft) as Map<String, dynamic>;
    return chatDraftMap;
  } else {
    return null;
  }
}
void deleteDraftInput(String roomId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('Draft_Chat_$roomId');
}