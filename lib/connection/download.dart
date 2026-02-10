import 'dart:io';
import 'package:chat/chat_screen/media_screen.dart';
import 'package:chat/chat_ui/widgets/photo_view.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
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

/// Helper function to ensure URL has a host
String _ensureFullUrl(String? url) {
  if (url == null || url.isEmpty) return '';
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }
  return '${HTTPConnection.domain}$url';
}

Future<String?> download(BuildContext context, String url, String filename,
    {bool isSaveGallery = false}) async {
  try {
    // Ensure URL has full domain (fix for relative paths like data/xxx/xxx.jpg)
    final fullUrl = _ensureFullUrl(url);
    if (fullUrl.isEmpty) {
      _showErrorSnackBar('Invalid URL');
      return null;
    }

    // Chỉ cần permission khi lưu vào gallery trên iOS
    if (isSaveGallery) {
      bool granted = await _requestGalleryPermission();
      if (!granted) {
        _showErrorSnackBar('Photo library access is not granted');
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
      _showErrorSnackBar('Unable to access storage directory');
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
      fullUrl,
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
      _showErrorSnackBar('File download failed');
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
    _showErrorSnackBar('File download error: ${e.toString()}');
    print('Error: ${e.toString()}');
    return null;
  }
}

void _showErrorSnackBar(String message) {
  try {
    final context = ChatConnection.buildContext;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: const Duration(seconds: 2),
          content: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  } catch (_) {}
}

void saveGallery(String? path, String filename) {
  if (path == null || path.isEmpty) {
    _showErrorSnackBar('Invalid file path');
    return;
  }

  // Kiểm tra nếu là content URI (không thể đọc trực tiếp)
  if (path.startsWith('/document/') || path.startsWith('content://')) {
    _showErrorSnackBar('Cannot save file from this path');
    return;
  }

  // Kiểm tra file tồn tại
  final file = io.File(path);
  if (!file.existsSync()) {
    _showErrorSnackBar('File does not exist');
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
        _showErrorSnackBar('Failed to save image: ${e.toString()}');
      });
    } catch (e) {
      _showErrorSnackBar('Unable to read image file');
    }
  } else if (isVideo(path) || isVideo(filename)) {
    SaverGallery.saveFile(
      filePath: path,
      fileName: filename,
      skipIfExists: false,
    ).then((result) {
      _showSaveResult(result);
    }).catchError((e) {
      _showErrorSnackBar('Failed to save video: ${e.toString()}');
    });
  } else {
    // File khác (audio, document, etc.) - thông báo đã tải về cache
    _showSuccessSnackBar('File has been downloaded to the device');
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
  if (path.contains('jfif')) {
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

void openFile(String? result, BuildContext context, String fileName) async {
  if (result != null) {
    final mimeType = fileName.split('.').last.toLowerCase();
    if (isAudio(mimeType)) {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return MediaScreen(filePath: result, title: fileName);
      }));
    } else if (isVideo(mimeType)) {
      await OpenFilex.open(result);
    } else if (isImage(mimeType)) {
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
        return PhotoScreen(imageViewed: result);
      }));
    } else {
      await OpenFilex.open(result);
    }
  }
  return null;
}

void openImage(BuildContext context, String url) {
  // Ensure URL has full domain (fix for relative paths like data/xxx/xxx.jpg)
  final fullUrl = _ensureFullUrl(url);
  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
    return PhotoScreen(imageViewed: fullUrl);
  }));
}

void openImages(BuildContext context, List<String> urls, {int initialIndex = 0}) {
  // Ensure all URLs have full domain
  final fullUrls = urls.map((url) => _ensureFullUrl(url)).toList();
  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
    return PhotoScreen(
      imageViewed: fullUrls[initialIndex],
      imageUrls: fullUrls,
      initialIndex: initialIndex,
    );
  }));
}
