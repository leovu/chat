/*
 * Copyright (c) 2021. MOBISALE V4.0. All rights reserved.
 */
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app_localizations.dart';
import 'lang_key.dart';

class LocalizationsConfig {
  static Locale getCurrentLocale(String lang) {
    return lang == "vi" ? const Locale(LangKey.langVi, 'VN') : const Locale(LangKey.langEn, 'EN');
  }

  static const List<Locale> supportedLocales = [
    Locale(LangKey.langVi, 'VN'),
    Locale(LangKey.langEn, 'EN'),
  ];

  static const List<LocalizationsDelegate> localizationsDelegates = [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,

    GlobalCupertinoLocalizations.delegate,
  ];

  static Locale localeResolutionCallback(
      Locale locale, List<Locale> supportedLocales) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode ||
          supportedLocale.countryCode == locale.countryCode) {
        return supportedLocale;
      }
    }
    return supportedLocales.first;
  }
}
