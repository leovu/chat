import 'dart:io';
import 'package:chat/chat_screen/local_file_view_page.dart';
import 'package:chat/chat_screen/media_screen.dart';
import 'package:chat/chat_ui/widgets/photo_view.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:permission/permission.dart';
import 'dart:io' as io;
import 'package:gallery_saver/gallery_saver.dart';

Future<String?> download(BuildContext context,String url,String filename, {bool isSaveGallery = false}) async {
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
        if(isSaveGallery) saveGallery(context, urlPath);
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
        if(isSaveGallery) saveGallery(context, filePath);
        return filePath;
      }
      else {
        if(isSaveGallery) saveGallery(context,urlPath);
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

void saveGallery(BuildContext context, String? path) {
  if(path != null) {
    if(isImage(path)) {
      GallerySaver.saveImage(path).then((result) {
        if(result == true) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.text(LangKey.downloadSuccess)),duration: const Duration(seconds: 2),));
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.text(LangKey.downloadFailed)),duration: const Duration(seconds: 2),));
        }
      });
    }
    else if(isVideo(path)) {
      GallerySaver.saveVideo(path).then((result) {
        if(result == true) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.text(LangKey.downloadSuccess)),duration: const Duration(seconds: 2),));
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.text(LangKey.downloadFailed)),duration: const Duration(seconds: 2),));
        }
      });
    }
  }
}

bool isImage(String path) {
  final mimeType = lookupMimeType(path) ?? '';
  return mimeType.startsWith('image/') || path == 'image/';
}
bool isAudio(String path) {
  final mimeType = lookupMimeType(path) ?? '';
  return mimeType.startsWith('audio/');
}
bool isVideo(String path) {
  final mimeType = lookupMimeType(path) ?? '';
  return mimeType.startsWith('video/');
}

void openFile(String? result,BuildContext context,String fileName) async {
  if(result != null) {
    List<String> documentFilesType = ['docx', 'doc', 'xlsx', 'xls', 'pptx', 'ppt', 'pdf', 'txt'];
    final mimeType = fileName.split('.').last.toLowerCase();
    if(documentFilesType.contains(fileName)) {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return LocalFileViewerPage(filePath: result,title: fileName,);
      }));
    }
    else if(isAudio(mimeType)) {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return MediaScreen(filePath: result,title: fileName);
      }));
    }
    else if(isVideo(mimeType)) {
      await OpenFile.open(result);
    }
    else if(isImage(mimeType)) {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return PhotoScreen(imageViewed: result);
      }));
    }
    else {
      await OpenFile.open(result);
    }
  }
  return null;
}