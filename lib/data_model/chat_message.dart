import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/room.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
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
  String? owner;
  String? lastUpdate;
  String? lastAuthor;
  String? lastMessage;
  List<Messages>? messages;
  List<MessageSeen>? messageSeen;
  List<Images>? images;
  List<Images>? files;
  List<Images>? links;
  PinMessage? pinMessage;

  Room(
      {sId,
        people,
        isGroup,
        lastUpdate,
        lastAuthor,
        lastMessage,
        messages,
        images,
        files,
        links,
        pinMessage,
        owner,
        messageSeen});

  Room.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    if (json['people'] != null) {
      people = <People>[];
      json['people'].forEach((v) {
        people!.add(People.fromJson(v));
      });
    }
    try{
      if (json['messageSeen'] != null) {
        messageSeen = <MessageSeen>[];
        json['messageSeen'].forEach((v) {
          messageSeen!.add(MessageSeen.fromJson(v));
        });
      }
    }catch(_){}
    isGroup = json['isGroup'];
    lastUpdate = json['lastUpdate'];
    lastAuthor = json['lastAuthor'];
    owner = json['owner'];
    try {
      lastMessage = json['lastMessage'];
    }catch(_) {}
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        if(v['content'] == 'Message recalled' && v['type'] == 'image') {}
        else {
          messages!.add(Messages.fromJson(v));
        }
      });
      messages = messages?.reversed.toList();
    }
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        if(v['content'] != 'Message recalled') {
          images!.add(Images.fromJson(v));
        }
      });
    }
    if (json['files'] != null) {
      files = <Images>[];
      json['files'].forEach((v) {
        if(v['content'] != 'Message recalled') {
          files!.add(Images.fromJson(v));
        }
      });
    }
    if (json['links'] != null) {
      links = <Images>[];
      json['links'].forEach((v) {
        if(v['content'] != 'Message recalled') {
          links!.add(Images.fromJson(v));
        }
      });
    }
    try{
      pinMessage = json['pinMessage'] != null
          ? PinMessage.fromJson(json['pinMessage'])
          : null;
    }catch(_){}
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
    data['owner'] = owner;
    if (messages != null) {
      data['messages'] = messages!.map((v) => v.toJson()).toList();
    }
    if (images != null) {
      data['images'] = images!.map((v) => v.toJson()).toList();
    }
    if (pinMessage != null) {
      data['pinMessage'] = pinMessage!.toJson();
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
  int? edit;

  Messages(
      {sId,
        replies,
        room,
        author,
        content,
        date,
        iV,
        type,
        file,
        edit});

  Messages.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    try{
      replies = json['replies'] != null ? Replies.fromJson(json['replies']) : null;
    }catch(_){}
    room = json['room'];
    try{
      author = json['author'] != null ? Author.fromJson(json['author']) : null;
    }catch(_) {}
    content = json['content'];
    date = json['date'];
    iV = json['__v'];
    type = json['type'];
    edit = json['edit'];
    if(content == 'Message recalled') {
      content = AppLocalizations.text(LangKey.messageRecalled);
      edit = 0;
    }
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
    data['edit'] = edit;
    return data;
  }

  Map<String, dynamic> toMessageJson({List<MessageSeen>? messageSeen}) {
    final Map<String, dynamic> data = <String, dynamic>{};
    if(messageSeen != null) {
      data['metadata'] = {
        'messageSeen': messageSeen.map((e) => e.toJson()).toList()
      };
    }
    if(edit != null){
      data['remoteId'] = '$edit';
    }
    if (author != null) {
      data['author'] = {
        'firstName': author!.firstName,
        'lastName': author!.lastName,
        'id':author!.sId,
        'imageUrl':author!.picture != null ? '${HTTPConnection.domain}api/images/${author!.picture!.shieldedID}/512/${ChatConnection.brandCode}' : null,
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
      data['uri'] = '${HTTPConnection.domain}api/files/${file!.shieldedID}/${ChatConnection.brandCode}';
    }
    else if(type == 'image') {
      data['size'] = 0;
      data['type'] = 'image';
      data['name'] = 'image';
      data['uri'] = '${HTTPConnection.domain}api/images/$content/${ChatConnection.brandCode}';
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
          'imageUrl':replies?.author?.picture != null ? '${HTTPConnection.domain}api/images/${replies?.author?.picture!.shieldedID}/512/${ChatConnection.brandCode}' : null,
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
        json['uri'] = '${HTTPConnection.domain}api/files/${replies!.file!.shieldedID}/${ChatConnection.brandCode}';
      }
      else if(replies?.type == 'image') {
        json['size'] = 0;
        json['type'] = 'image';
        json['name'] = 'image';
        json['uri'] = '${HTTPConnection.domain}api/images/${replies!.content}/${ChatConnection.brandCode}';
      }
      else {
        json['type'] = 'text';
        json['text'] = replies!.content;
      }
      data['repliedMessage'] = json;
    }
    return data;
  }
}

class MessageSeen {
  String? sId;
  Author? author;
  String? room;
  int? iV;
  String? message;

  MessageSeen({this.sId, this.author, this.room, this.iV, this.message});

  MessageSeen.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    author =
    json['author'] != null ? Author.fromJson(json['author']) : null;
    room = json['room'];
    iV = json['__v'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    if (author != null) {
      data['author'] = author!.toJson();
    }
    data['room'] = room;
    data['__v'] = iV;
    data['message'] = message;
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

  String getAvatarName() {
    String avatarName = '';
    String? firstNameResult = firstName?.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    if(firstNameResult != '' && firstNameResult != null) {
      avatarName += firstNameResult[0];
    }
    String? lastNameResult = lastName?.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    if(lastNameResult != '' && lastNameResult != null) {
      avatarName += lastNameResult[0];
    }
    return avatarName == '' ? '*' : avatarName.toUpperCase();
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
  Picture? file;

  Images({sId,
    room,
    author,
    content,
    type,
    date,
    file,
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
    try{
      file = json['file'] != null ? Picture.fromJson(json['file']) : null;
    }catch(_){}
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
    if(file != null) {
      data['file'] = file!.toJson();
    }
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

class PinMessage {
  int? recall;
  int? edit;
  int? seen;
  String? sId;
  String? room;
  Author? author;
  String? content;
  String? date;
  int? iV;
  String? type;

  PinMessage(
      {
        recall,
        edit,
        seen,
        sId,
        room,
        author,
        content,
        date,
        iV,
        type});

  PinMessage.fromJson(Map<String, dynamic> json) {
    recall = json['recall'];
    edit = json['edit'];
    seen = json['seen'];
    sId = json['_id'];
    room = json['room'];
    author =
    json['author'] != null ? Author.fromJson(json['author']) : null;
    content = json['content'];
    date = json['date'];
    iV = json['__v'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['recall'] = recall;
    data['edit'] = edit;
    data['seen'] = seen;
    data['_id'] = sId;
    data['room'] = room;
    if (author != null) {
      data['author'] = author!.toJson();
    }
    data['content'] = content;
    data['date'] = date;
    data['__v'] = iV;
    data['type'] = type;
    return data;
  }
}