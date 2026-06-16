import 'package:chat/chat_ui/notification.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/notifications.dart' as n;
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

class NotificationService {
  static Future<n.Notifications?> notificationList(
    HTTPConnection connection, {
    required void Function(String) onCountUpdated,
  }) async {
    final responseData = await connection.post('api/notification/list', {});
    if (responseData.isSuccess) {
      final result = n.Notifications.fromJson(responseData.data);
      int totalUnread = 0;
      result.notifications?.forEach((e) {
        if (e.isRead == 0) totalUnread += 1;
      });
      onCountUpdated(totalUnread > 99 ? '99+' : '$totalUnread');
      return result;
    }
    return null;
  }

  static Future<void> notificationCount(
    HTTPConnection connection, {
    required void Function(int? all, int? client, int? facebook, int? zalo, int? zaloPersonal, int? whatsapp) onResult,
  }) async {
    final responseData = await connection.post('api/notification/user', {});
    if (responseData.isSuccess) {
      final result = n.NotificationCount.fromJson(responseData.data);
      onResult(result.total, result.client, result.facebook, result.zalo, result.zalo_personal, result.whatsapp);
    }
  }

  static Future<bool> readNotification(HTTPConnection connection, String notiId) async {
    final responseData = await connection.post('api/notification/update', {'type': 'read', 'notiId': notiId});
    return responseData.isSuccess;
  }

  static void showNotification(
    String notificationTitle,
    String notificationDes,
    Map<String, dynamic> message,
    String iconApp,
    Function(Map<String, dynamic>) onMessageCallback,
  ) {
    final isImage = message['message']['type'] == 'image';
    final isFile = message['message']['type'] == 'file';
    showOverlayNotification((context) {
      return BannerNotification(
        notificationTitle: notificationTitle,
        notificationDescription: isImage
            ? '${HTTPConnection.domain}api/images/$notificationDes/256'
            : notificationDes,
        iconApp: iconApp,
        isImage: isImage,
        isFile: isFile,
        onReplay: () {
          onMessageCallback(message);
          OverlaySupportEntry.of(context)?.dismiss();
        },
      );
    }, duration: const Duration(seconds: 2));
  }

  static void showError(BuildContext context, {String? content}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.warning)),
        content: Text(content ?? AppLocalizations.text(LangKey.limitSizeUpload)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.text(LangKey.accept)),
          ),
        ],
      ),
    );
  }
}
