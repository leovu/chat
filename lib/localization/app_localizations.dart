import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lang_key.dart';


class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);
  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  static late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    Map<String, dynamic> jsonMap = await configLanguage(locale.languageCode);
    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });
    return true;
  }
  static String text(String key) {
    return _localizedStrings[key]!;
  }
}
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return [LangKey.langVi, LangKey.langEn].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    var localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

Future<Map<String, dynamic>> configLanguage(String lang) async{
  String path = 'packages/chat/assets/chat_$lang.json';
  var jsonString =
  await rootBundle.loadString(path,cache: false);
  Map<String, dynamic> jsonMap = json.decode(jsonString);
  return jsonMap;
}