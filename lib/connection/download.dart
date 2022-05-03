import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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