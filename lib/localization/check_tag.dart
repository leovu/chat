import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import '../data_model/room.dart';

String checkTag(String message,List<People>? list) {
  List<String> _tagList = [];
  String result = message;
  if (result.contains('@@')) {
    result = result.replaceAll('@@', '@ @');
  }
  if (result.contains('@all-all@')) {
    result = result.replaceAll('@all-all@', '@${AppLocalizations.text(LangKey.all)}');
  }
  if(list != null && list.isNotEmpty) {
    for (var e in list) { 
      if(result.contains('@${e.firstName}${e.lastName}-${e.sId}@')) {
        if(!_tagList.contains(e.sId!)) {
          _tagList.add(e.sId!);
          result = result.replaceAll('@${e.firstName}${e.lastName}-${e.sId}@', '@${e.firstName} ${e.lastName}');
        }
      }
      else if(result.contains('@${e.firstName} ${e.lastName}-${e.sId}@')) {
        if(!_tagList.contains(e.sId!)) {
          _tagList.add(e.sId!);
          result = result.replaceAll('@${e.firstName} ${e.lastName}-${e.sId}@', '@${e.firstName} ${e.lastName}');
        }
      }
      else {
        if(result.contains('@${e.firstName}${e.lastName}')) {
          if(!_tagList.contains(e.sId!)) {
            _tagList.add(e.sId!);
          }
        }
        else if(result.contains('@${e.firstName} ${e.lastName}')) {
          if(!_tagList.contains(e.sId!)) {
            _tagList.add(e.sId!);
          }
        }
      }
    }
  }
  else {
    List<String> contents = result.split(' ');
    String resultNull = "";
    for (int i = 0; i < contents.length; i++) {
      var element = contents[i];
      try {
        if(element[element.length-1] == '@' && element.contains('-')) {
          element = element.split('-').first;
        }
      }catch(_){}
      resultNull += '$element ';
    }
    List<String> contentsChecked = resultNull.split('\n');
    String resultNullChecked = "";
    for (int i = 0; i < contentsChecked.length; i++) {
      var element = contentsChecked[i];
      try {
        if(element[element.length-1] == '@' && element.contains('-')) {
          element = element.split('-').first;
        }
      }catch(_){}
      resultNullChecked += '$element ';
    }
    return resultNullChecked.trim();
  }
  return result.trim();
}

List<String> detectTag(String message,List<People>? list) {
  List<String> _tagList = [];
  String result = message;
  if (result.contains('@all-all@')) {
    result = result.replaceAll('@all-all@', '@${AppLocalizations.text(LangKey.all)}');
  }
  if(list != null && list.isNotEmpty) {
    for (var e in list) {
      if(result.contains('@${e.firstName}${e.lastName}-${e.sId}@')) {
        if(!_tagList.contains(e.sId!)) {
          _tagList.add(e.sId!);
          result = result.replaceAll('@${e.firstName}${e.lastName}-${e.sId}@', '@${e.firstName} ${e.lastName}');
        }
      }
      else if(result.contains('@${e.firstName} ${e.lastName}-${e.sId}@')) {
        if(!_tagList.contains(e.sId!)) {
          _tagList.add(e.sId!);
          result = result.replaceAll('@${e.firstName} ${e.lastName}-${e.sId}@', '@${e.firstName}${e.lastName}');
        }
      }
      else {
        if(result.contains('@${e.firstName}${e.lastName}')) {
          if(!_tagList.contains(e.sId!)) {
            _tagList.add(e.sId!);
          }
        }
        else if(result.contains('@${e.firstName} ${e.lastName}')) {
          if(!_tagList.contains(e.sId!)) {
            _tagList.add(e.sId!);
          }
        }
      }
    }
  }
  return _tagList;
}