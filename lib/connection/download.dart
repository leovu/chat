import 'dart:io';
import 'package:chat/chat_screen/media_screen.dart';
import 'package:chat/chat_ui/widgets/photo_view.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' as io;

import 'package:saver_gallery/saver_gallery.dart';

/// Request permission để lưu vào gallery
/// - Android: Không cần permission, SaverGallery sử dụng MediaStore API
/// - iOS: Cần permission Photos để lưu vào thư viện ảnh
Future<bool> _requestGalleryPermission() async {
  if (Platform.isIOS) {
    // iOS cần permission để lưu vào Photos
    final status = await Permission.photos.status;
    if (status.isGranted || status.isLimited) {
      return true;
    }
    final result = await Permission.photos.request();
    return result.isGranted || result.isLimited;
  }
  // Android: SaverGallery sử dụng MediaStore, không cần permission
  return true;
}

Future<String?> download(BuildContext context, String url, String filename,
    {bool isSaveGallery = false}) async {
  try {
    // Chỉ cần permission khi lưu vào gallery trên iOS
    if (isSaveGallery) {
      bool granted = await _requestGalleryPermission();
      if (!granted) {
        _showErrorSnackBar('Không có quyền truy cập thư viện ảnh');
        return null;
      }
    }

    Directory? directory;
    if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else if (Platform.isAndroid) {
      directory = await getTemporaryDirectory();
    }

    if (directory == null) {
      _showErrorSnackBar('Không thể truy cập thư mục lưu trữ');
      return null;
    }

    var uri = Uri.encodeComponent(filename);
    String urlPath = '${directory.path}/$uri';

    // Kiểm tra file đã tồn tại chưa
    bool checkAvailable = await io.File(urlPath).exists();
    if (checkAvailable) {
      if (isSaveGallery) {
        saveGallery(urlPath, filename);
      }
      return urlPath;
    }

    // Tải file về
    await Dio().download(
      url,
      urlPath,
      options: Options(
        headers: {
          'brand-code': ChatConnection.brandCode!,
          'Authorization': 'Bearer ${ChatConnection.user!.token}'
        },
      ),
    );

    // Kiểm tra file đã tải thành công chưa
    if (!await io.File(urlPath).exists()) {
      _showErrorSnackBar('Tải file thất bại');
      return null;
    }

    // Lưu vào gallery nếu được yêu cầu
    if (isSaveGallery) {
      saveGallery(urlPath, filename);
    }

    // Trả về đường dẫn file có thể mở được
    // Không trả về content URI từ FlutterFileDialog vì không thể dùng để mở file
    return urlPath;
  } catch (e) {
    _showErrorSnackBar('Lỗi tải file: ${e.toString()}');
    return null;
  }
}

/// Hiển thị thông báo lỗi
void _showErrorSnackBar(String message) {
  try {
    ScaffoldMessenger.of(ChatConnection.buildContext).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );
  } catch (_) {}
}

void saveGallery(String? path, String filename) {
  if (path == null || path.isEmpty) {
    _showErrorSnackBar('Đường dẫn file không hợp lệ');
    return;
  }

  // Kiểm tra nếu là content URI (không thể đọc trực tiếp)
  if (path.startsWith('/document/') || path.startsWith('content://')) {
    _showErrorSnackBar('Không thể lưu file từ đường dẫn này');
    return;
  }

  // Kiểm tra file tồn tại
  final file = io.File(path);
  if (!file.existsSync()) {
    _showErrorSnackBar('File không tồn tại');
    return;
  }

  if (isImage(path) || isImage(filename)) {
    try {
      SaverGallery.saveImage(
        file.readAsBytesSync(),
        fileName: filename,
        skipIfExists: false,
      ).then((result) {
        _showSaveResult(result);
      }).catchError((e) {
        _showErrorSnackBar('Lỗi lưu ảnh: ${e.toString()}');
      });
    } catch (e) {
      _showErrorSnackBar('Không thể đọc file ảnh');
    }
  } else if (isVideo(path) || isVideo(filename)) {
    SaverGallery.saveFile(
      filePath: path,
      fileName: filename,
      skipIfExists: false,
    ).then((result) {
      _showSaveResult(result);
    }).catchError((e) {
      _showErrorSnackBar('Lỗi lưu video: ${e.toString()}');
    });
  } else {
    // File khác (audio, document, etc.) - thông báo đã tải về cache
    _showSuccessSnackBar('Đã tải file về thiết bị');
  }
}

/// Hiển thị kết quả lưu gallery
void _showSaveResult(SaveResult result) {
  try {
    if (result.isSuccess) {
      _showSuccessSnackBar(AppLocalizations.text(LangKey.downloadSuccess));
    } else {
      _showErrorSnackBar(
          "${AppLocalizations.text(LangKey.downloadFailed)}: ${result.errorMessage}");
    }
  } catch (_) {}
}

/// Hiển thị thông báo thành công
void _showSuccessSnackBar(String message) {
  try {
    ScaffoldMessenger.of(ChatConnection.buildContext).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  } catch (_) {}
}

bool isImage(String path) {
  final mimeType = lookupMimeType(path) ?? '';
  bool result = mimeType.startsWith('image/') || path == 'image/';
  if(path.contains('jfif')) {
    result = true;
  }
  return result;
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
    final mimeType = fileName.split('.').last.toLowerCase();
    if(isAudio(mimeType)) {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return MediaScreen(filePath: result,title: fileName);
      }));
    }
    else if(isVideo(mimeType)) {
      await OpenFilex.open(result);
    }
    else if(isImage(mimeType)) {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return PhotoScreen(imageViewed: result);
      }));
    }
    else {
      await OpenFilex.open(result);
    }
  }
  return null;
}

void openImage(BuildContext context, String url) {
  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
    return PhotoScreen(imageViewed: url);
  }));
}