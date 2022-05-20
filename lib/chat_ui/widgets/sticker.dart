import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Stickers {
  static List<Widget> pandaStickers(Function select) => _stickers('panda',select);
  static List<Widget> usagyuunStickers(Function select) => _stickers('usagyuun',select);
  static List<Widget> mimiCatStickers(Function select) => _stickers('mimicat',select);
  static List<Widget> _stickers(String name,Function select) {
    List<Widget> _arr = [];
    for (int i=1;i<= collection(name);i++) {
      _arr.add(InkWell(
          onTap: () async {
            final ByteData byteData = await rootBundle.load('packages/chat/assets/meme/$name/$i.${type(name)}');
            File file = await writeToFile(byteData,'$name$i.${type(name)}');
            select(file);
          },
          child: Image.asset('packages/chat/assets/meme/$name/$i.${type(name)}')));
    }
    return _arr;
  }
  static int collection(String sticker) {
    if(sticker == 'panda') {
      return 88;
    }
    else if(sticker == 'usagyuun') {
      return 24;
    }
    else {
      return 10;
    }
  }
  static String type(String sticker) {
    if(sticker == 'usagyuun') {
      return 'png';
    }
    else {
      return 'jpg';
    }
  }
  static Future<File> writeToFile(ByteData data,String stickerName) async {
    final buffer = data.buffer;
    late Directory directory;
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (Platform.isAndroid) {
      directory = await getTemporaryDirectory();
    }
    String tempPath = directory.path;
    var filePath = tempPath + '/$stickerName';
    return File(filePath).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}