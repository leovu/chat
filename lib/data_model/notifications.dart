import 'package:chat/data_model/room.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:intl/intl.dart';

class Notifications {
  int? limit;
  List<Notification>? notifications;

  Notifications({limit, notifications});

  Notifications.fromJson(Map<String, dynamic> json) {
    limit = json['limit'];
    if (json['notifications'] != null) {
      notifications = <Notification>[];
      json['notifications'].forEach((v) {
        notifications!.add(Notification.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['limit'] = limit;
    if (notifications != null) {
      data['notifications'] =
          notifications!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Notification {
  Room? room;
  String? message;
  int? isRead;
  int? isSend;
  int? isShow;
  String? sId;
  People? user;
  String? title;
  String? messageData;
  String? content;
  String? action;
  ActionParams? actionParams;
  People? createdBy;
  String? createdAt;
  int? iV;

  Notification(
      {room,
        message,
        isRead,
        isSend,
        isShow,
        sId,
        user,
        title,
        messageData,
        content,
        action,
        actionParams,
        createdBy,
        createdAt,
        iV});

  Notification.fromJson(Map<String, dynamic> json) {
    room = json['room'] != null ? Room.fromJson(json['room']) : null;
    message = json['message'];
    isRead = json['isRead'];
    isSend = json['isSend'];
    isShow = json['isShow'];
    sId = json['_id'];
    user = json['user'] != null ? People.fromJson(json['user']) : null;
    title = json['title'];
    messageData = json['messageData'];
    content = json['content'];
    action = json['action'];
    actionParams = json['actionParams'] != null
        ? ActionParams.fromJson(json['actionParams'])
        : null;
    createdBy =
    json['createdBy'] != null ? People.fromJson(json['createdBy']) : null;
    createdAt = json['createdAt'];
    iV = json['__v'];
  }

  String createMessageDate() {
    final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
    final dt = format.parse(createdAt!, true).toLocal();
    if(dt.isToday()) {
      String hour = dt.hour >= 10 ? '${dt.hour}' : '0${dt.hour}';
      String minute = dt.minute >= 10 ? '${dt.minute}' : '0${dt.minute}';
      return dt.hour > 12 ? '$hour:$minute PM' :'$hour:$minute AM';
    }
    else if (dt.isYesterday()) {
      return 'Yesterday';
    }
    else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (room != null) {
      data['room'] = room!.toJson();
    }
    data['message'] = message;
    data['isRead'] = isRead;
    data['isSend'] = isSend;
    data['isShow'] = isShow;
    data['_id'] = sId;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['title'] = title;
    data['messageData'] = messageData;
    data['content'] = content;
    data['action'] = action;
    if (actionParams != null) {
      data['actionParams'] = actionParams!.toJson();
    }
    if (createdBy != null) {
      data['createdBy'] = createdBy!.toJson();
    }
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    return data;
  }
}

class ActionParams {
  String? type;
  c.Messages? message;

  ActionParams({type, message});

  ActionParams.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    message =
    json['message'] != null ? c.Messages.fromJson(json['message']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    if (message != null) {
      data['message'] = message!.toJson();
    }
    return data;
  }
}

class NotificationCount {
  int? total;
  int? client;
  int? facebook;
  int? zalo;

  NotificationCount({this.total, this.facebook, this.zalo});

  NotificationCount.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    client = json['client'];
    facebook = json['facebook'];
    zalo = json['zalo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['client'] = client;
    data['facebook'] = facebook;
    data['zalo'] = zalo;
    return data;
  }
}