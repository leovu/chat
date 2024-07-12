import 'package:chat/common/global.dart';
import 'package:chat/common/shared_prefs/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config {
  static Future<void> getPreferences() async {
    await SharedPreferences.getInstance().then((event) async {
      Globals.prefs = SharedPrefs(event);
    });
    return;
  }
}