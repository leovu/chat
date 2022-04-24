import 'package:chat/connection/http_connection.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';

class ChatMessage {
  Room? room;

  ChatMessage({room});

  ChatMessage.fromJson(Map<String, dynamic> json) {
    room = json['room'] != null ? Room.fromJson(json['room']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (room != null) {
      data['room'] = room!.toJson();
    }
    return data;
  }
}

class Room {
  String? sId;
  List<People>? people;
  bool? isGroup;
  String? lastUpdate;
  String? lastAuthor;
  String? lastMessage;
  List<Messages>? messages;
  List<Images>? images;

  Room(
      {sId,
        people,
        isGroup,
        lastUpdate,
        lastAuthor,
        lastMessage,
        messages,
        images});

  Room.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['people'] != null) {
      people = <People>[];
      json['people'].forEach((v) {
        people!.add(People.fromJson(v));
      });
    }
    isGroup = json['isGroup'];
    lastUpdate = json['lastUpdate'];
    lastAuthor = json['lastAuthor'];
    lastMessage = json['lastMessage'];
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        messages!.add(Messages.fromJson(v));
      });
      messages = messages?.reversed.toList();
    }
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        images!.add(Images.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (people != null) {
      data['people'] = people!.map((v) => v.toJson()).toList();
    }
    data['isGroup'] = isGroup;
    data['lastUpdate'] = lastUpdate;
    data['lastAuthor'] = lastAuthor;
    data['lastMessage'] = lastMessage;
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class People {
  String? level;
  String? sId;
  String? username;
  String? firstName;
  String? phone;
  String? lastName;
  String? lastOnline;
  Picture? picture;

  People(
      {level,
        favorites,
        sId,
        username,
        firstName,
        phone,
        lastName,
        lastOnline,
        picture});

  People.fromJson(Map<String, dynamic> json) {
    level = json['level'];
    sId = json['_id'];
    username = json['username'];
    firstName = json['firstName'];
    phone = json['phone'];
    lastName = json['lastName'];
    lastOnline = json['lastOnline'];
    picture =
    json['picture'] != null ? Picture.fromJson(json['picture']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['level'] = level;
    data['_id'] = sId;
    data['username'] = username;
    data['firstName'] = firstName;
    data['phone'] = phone;
    data['lastName'] = lastName;
    data['lastOnline'] = lastOnline;
    if (picture != null) {
      data['picture'] = picture!.toJson();
    }
    return data;
  }
}

class Picture {
  String? sId;
  String? name;
  String? author;
  int? size;
  String? shield;
  int? iV;
  String? location;
  String? shieldedID;

  Picture(
      {sId,
        name,
        author,
        size,
        shield,
        iV,
        location,
        shieldedID});

  Picture.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    author = json['author'];
    size = json['size'];
    shield = json['shield'];
    iV = json['__v'];
    location = json['location'];
    shieldedID = json['shieldedID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['author'] = author;
    data['size'] = size;
    data['shield'] = shield;
    data['__v'] = iV;
    data['location'] = location;
    data['shieldedID'] = shieldedID;
    return data;
  }
}

class Messages {
  String? sId;
  Replies? replies;
  String? room;
  Author? author;
  String? content;
  String? date;
  int? iV;
  String? type;
  Picture? file;

  Messages(
      {sId,
        replies,
        room,
        author,
        content,
        date,
        iV,
        type,
        file});

  Messages.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    replies = json['replies'] != null ? Replies.fromJson(json['replies']) : null;
    room = json['room'];
    author =
    json['author'] != null ? Author.fromJson(json['author']) : null;
    content = json['content'];
    date = json['date'];
    iV = json['__v'];
    type = json['type'];
    try{
      file = json['file'] != null ? Picture.fromJson(json['file']) : null;
    }catch(_){}
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (replies != null) {
      data['replies'] = replies!.toJson();
    }
    data['room'] = room;
    if (author != null) {
      data['author'] = author!.toJson();
    }
    data['content'] = content;
    data['date'] = date;
    data['__v'] = iV;
    data['type'] = type;
    if (file != null) {
      data['file'] = file!.toJson();
    }
    return data;
  }

  Map<String, dynamic> toMessageJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (author != null) {
      data['author'] = {
        'firstName': author!.firstName,
        'lastName': author!.lastName,
        'id':author!.sId,
        'imageUrl':author!.picture != null ? '${HTTPConnection.domain}api/images/${author!.picture!.shieldedID}/512' : null,
      };
    }
    if(date != null) {
      final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
      final dt = format.parse(date!, true);
      data['createdAt'] = dt.toUtc().millisecondsSinceEpoch;
    }
    data['id'] = sId;
    if(type == 'file' && file != null) {
      data['size'] = 0;
      data['type'] = 'file';
      final mimeType = lookupMimeType(file!.name!);
      data['mimeType'] = mimeType;
      data['size'] = file!.size;
      data['name'] = file!.name;
      data['uri'] = '${HTTPConnection.domain}api/files/${file!.shieldedID}';
    }
    else if(type == 'image') {
      data['size'] = 0;
      data['type'] = 'image';
      data['name'] = 'image';
      data['uri'] = '${HTTPConnection.domain}api/images/$content';
    }
    else {
      data['type'] = 'text';
      data['text'] = content;
    }
    // data['status'] = 'delivered';
    if(replies != null) {
      Map<String,dynamic> json = {};
      json = {
        'author' : {
          'firstName': replies?.author?.firstName,
          'lastName': replies?.author?.lastName,
          'id':replies?.author?.sId,
          'imageUrl':replies?.author?.picture != null ? '${HTTPConnection.domain}api/images/${replies?.author?.picture!.shieldedID}/512' : null,
        },
      };
      json['id'] = replies!.sId!;
      final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
      final dt = format.parse(replies!.date!, true);
      json['createdAt'] = dt.toUtc().millisecondsSinceEpoch;
      if(replies?.type == 'file' && replies?.file != null) {
        json['size'] = 0;
        json['type'] = 'file';
        final mimeType = lookupMimeType(replies!.file!.name!);
        json['mimeType'] = mimeType;
        json['size'] = replies!.file!.size;
        json['name'] = replies!.file!.name;
        json['uri'] = '${HTTPConnection.domain}api/files/${replies!.file!.shieldedID}';
      }
      else if(type == 'image') {
        json['size'] = 0;
        json['type'] = 'image';
        json['name'] = 'image';
        json['uri'] = '${HTTPConnection.domain}api/images/$content';
      }
      else {
        json['type'] = 'text';
        json['text'] = content;
      }
      data['repliedMessage'] = json;
    }
    return data;
  }
}

class Author {
  String? sId;
  String? level;
  String? tagLine;
  String? username;
  String? firstName;
  String? phone;
  String? lastName;
  String? lastOnline;
  Picture? picture;

  Author(
      {sId,
        level,
        favorites,
        tagLine,
        username,
        firstName,
        phone,
        lastName,
        lastOnline,
        picture});

  Author.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    level = json['level'];
    tagLine = json['tagLine'];
    username = json['username'];
    firstName = json['firstName'];
    phone = json['phone'];
    lastName = json['lastName'];
    lastOnline = json['lastOnline'];
    try {
      picture =
      json['picture'] != null ? Picture.fromJson(json['picture']) : null;
    }catch(_) {}
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['level'] = level;
    data['tagLine'] = tagLine;
    data['username'] = username;
    data['firstName'] = firstName;
    data['phone'] = phone;
    data['lastName'] = lastName;
    data['lastOnline'] = lastOnline;
    if (picture != null) {
      data['picture'] = picture!.toJson();
    }
    return data;
  }
}

class Images {
  String? sId;
  String? room;
  Author? author;
  String? content;
  String? type;
  String? date;
  int? iV;

  Images({sId,
    room,
    author,
    content,
    type,
    date,
    iV});

  Images.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    room = json['room'];
    author =
    json['author'] != null ? Author.fromJson(json['author']) : null;
    content = json['content'];
    type = json['type'];
    date = json['date'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['room'] = room;
    if (author != null) {
      data['author'] = author!.toJson();
    }
    data['content'] = content;
    data['type'] = type;
    data['date'] = date;
    data['__v'] = iV;
    return data;
  }
}

class Replies {
  String? sId;
  int? recall;
  int? edit;
  int? reactionTotal;
  int? seen;
  String? room;
  Author? author;
  String? content;
  String? date;
  int? iV;
  String? type;
  Picture? file;

  Replies(
      {sId,
        recall,
        edit,
        reactionTotal,
        seen,
        room,
        author,
        content,
        date,
        iV,
        type,
        file});

  Replies.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    recall = json['recall'];
    edit = json['edit'];
    reactionTotal = json['reaction_total'];
    seen = json['seen'];
    room = json['room'];
    author =
    json['author'] != null ? Author.fromJson(json['author']) : null;
    content = json['content'];
    date = json['date'];
    iV = json['__v'];
    type = json['type'];
    file = json['file'] != null ? Picture.fromJson(json['file']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['recall'] = recall;
    data['edit'] = edit;
    data['reaction_total'] = reactionTotal;
    data['seen'] = seen;
    data['room'] = room;
    if (author != null) {
      data['author'] = author!.toJson();
    }
    data['content'] = content;
    data['date'] = date;
    data['__v'] = iV;
    data['type'] = type;
    if (file != null) {
      data['file'] = file!.toJson();
    }
    return data;
  }
}