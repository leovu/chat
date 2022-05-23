import 'dart:io';
import 'package:chat/chat_screen/local_file_view_page.dart';
import 'package:chat/chat_screen/media_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:permission/permission.dart';
import 'dart:io' as io;

Future<String?> download(BuildContext context,String url,String filename) async {
  try {
    bool granted = false;
    if (Platform.isAndroid) {
      granted = await PermissionRequest.request(PermissionRequestType.STORAGE, () {
        showDialog(
          context: context,
          builder: (context) =>
              AlertDialog(
                title: const Text('Request permissions'),
                content: const Text(
                    'Select Settings, go to App info, tap Permissions, turn on permission and re-enter this screen to use permission'),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        PermissionRequest.openSetting();
                      },
                      child: const Text('Open setting')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel')),
                ],
              ),
        );
      });
    }
    else {
      granted = true;
    }
    if(!granted) {
      return null;
    }
    Directory? directory;
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (Platform.isAndroid) {
      directory = await getTemporaryDirectory();
    }
    if (directory != null) {
      String urlPath = '${directory.path}/$filename';
      bool checkAvailable = await io.File(urlPath).exists();
      if(checkAvailable) {
        return urlPath;
      }
      await Dio().download(
        url,
        urlPath,
      );
      if (Platform.isAndroid) {
        final params = SaveFileDialogParams(
            sourceFilePath: urlPath);
        final filePath =
        await FlutterFileDialog.saveFile(params: params);
        return filePath;
      }
      else {
        return urlPath;
      }
    }
    else {
      return null;
    }
  }catch(_) {
    return null;
  }
}

bool isImage(String path) {
  final mimeType = lookupMimeType(path) ?? '';
  return mimeType.startsWith('image/');
}
bool isAudio(String path) {
  final mimeType = lookupMimeType(path) ?? '';
  return mimeType.startsWith('audio/');
}
bool isVideo(String path) {
  final mimeType = lookupMimeType(path) ?? '';
  return mimeType.startsWith('video/');
}

Future<String?> openFile(String? result,BuildContext context,String fileName) async {
  if(result != null) {
    List<String> documentFilesType = ['docx', 'doc', 'xlsx', 'xls', 'pptx', 'ppt', 'pdf', 'txt'];
    final mimeType = fileName.split('.').last.toLowerCase();
    if(documentFilesType.contains(fileName)) {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return LocalFileViewerPage(filePath: result,title: fileName,);
      }));
      return null;
    }
    else if(isAudio(mimeType)) {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return MediaScreen(filePath: result,title: fileName);
      }));
      return null;
    }
    else if(isVideo(mimeType)) {
      await OpenFile.open(result);
      return null;
    }
    else if(isImage(mimeType)) {
      return result;
    }
    else {
      await OpenFile.open(result);
      return null;
    }
  }
  return null;
}