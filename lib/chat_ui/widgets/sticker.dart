import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class Stickers {
  static List<Widget> pandaStickers(Function select) => _stickers('panda',select);
  static List<Widget> usagyuunStickers(Function select) => _stickers('usagyuun',select);
  static List<Widget> _stickers(String name,Function select) {
    List<Widget> _arr = [];
    for (int i=1;i<= (name == 'panda' ? 88 : 24);i++) {
      _arr.add(InkWell(
          onTap: () async {
            final ByteData byteData = await rootBundle.load('packages/chat/assets/meme/$name/$i.${(name == 'panda' ? 'jpg' : 'png')}');
            File file = await writeToFile(byteData,'$name$i.${(name == 'panda' ? 'jpg' : 'png')}');
            select(file);
          },
          child: Image.asset('packages/chat/assets/meme/$name/$i.${(name == 'panda' ? 'jpg' : 'png')}')));
    }
    return _arr;
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