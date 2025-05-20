import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/room.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';

enum TypeMessage {
  start,
  inProgress,
  end,
}

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
  Owner? owner;
  String? lastUpdate;
  String? lastAuthor;
  String? lastMessage;
  List<Messages>? messages;
  List<MessageSeen>? messageSeen;
  List<Images>? images;
  List<Images>? files;
  List<Images>? links;
  PinMessage? pinMessage;
  String? oa_group_id;
  Channel? channel;
  String? title;

  Room({
    sId,
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
    messageSeen,
    oa_group_id,
    channel,
    this.title = '',
  });

  Room.fromJson(Map<String, dynamic> json) {
    title = json['title']??'';
    sId = json['_id'];
    oa_group_id = json['oa_group_id'];
    if (json['people'] != null) {
      people = <People>[];
      json['people'].forEach((v) {
        people!.add(People.fromJson(v));
      });
    }
    try {
      if (json['messageSeen'] != null) {
        messageSeen = <MessageSeen>[];
        json['messageSeen'].forEach((v) {
          messageSeen!.add(MessageSeen.fromJson(v));
        });
      }
    } catch (_) {}
    isGroup = json['isGroup'];
    lastUpdate = json['lastUpdate'];
    lastAuthor = json['lastAuthor'];
    try {
      owner = json['owner'] != null ? Owner.fromJson(json['owner']) : null;
    } catch (_) {}
    try {
      lastMessage = json['lastMessage'];
    } catch (_) {}
    if (json['messages'] != null) {
      messages = <Messages>[];
      json['messages'].forEach((v) {
        if (v['content'] == 'Message recalled' && v['type'] == 'image') {
        } else {
          messages!.add(Messages.fromJson(v));
        }
      });
      messages = messages?.reversed.toList();
    }
    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        if (v['content'] != 'Message recalled') {
          images!.add(Images.fromJson(v));
        }
      });
    }
    if (json['files'] != null) {
      files = <Images>[];
      json['files'].forEach((v) {
        if (v['content'] != 'Message recalled') {
          files!.add(Images.fromJson(v));
        }
      });
    }
    if (json['links'] != null) {
      links = <Images>[];
      json['links'].forEach((v) {
        if (v['content'] != 'Message recalled') {
          links!.add(Images.fromJson(v));
        }
      });
    }
    try {
      pinMessage = json['pinMessage'] != null
          ? PinMessage.fromJson(json['pinMessage'])
          : null;
    } catch (_) {}

    // Thêm phần xử lý ChannelInfo
    try {
      channel = json['channelInfo'] != null
          ? Channel.fromJson(json['channelInfo'])
          : null;
    } catch (_) {}
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['title'] = title;
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
    if (pinMessage != null) {
      data['pinMessage'] = pinMessage!.toJson();
    }

    // Thêm ChannelInfo vào dữ liệu JSON
    if (channel != null) {
      data['channelInfo'] = channel!.toJson();
    }

    return data;
  }
}

class Channel {
  final String id;
  final int active;
  final int autoCreateLead;
  final String avatar;
  final String cover;
  final DateTime createdAt;
  final int enableBackgroundIcon;
  final int enableBot;
  final int enableGreeting;
  final int enableVoiceAi;
  final int isLostConnection;
  final List<int> managers;
  final String nameApp;
  final List<dynamic> quickQuestion;
  final int showFormLivechat;
  final String socialChanelId;
  final String source;
  final bool status;
  final int subscribed;
  final List<dynamic> zpCookie;
  final int v;

  Channel({
    required this.id,
    required this.active,
    required this.autoCreateLead,
    required this.avatar,
    required this.cover,
    required this.createdAt,
    required this.enableBackgroundIcon,
    required this.enableBot,
    required this.enableGreeting,
    required this.enableVoiceAi,
    required this.isLostConnection,
    required this.managers,
    required this.nameApp,
    required this.quickQuestion,
    required this.showFormLivechat,
    required this.socialChanelId,
    required this.source,
    required this.status,
    required this.subscribed,
    required this.zpCookie,
    required this.v,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['_id'],
      active: json['active'],
      autoCreateLead: json['auto_create_lead'],
      avatar: json['avatar'],
      cover: json['cover'],
      createdAt: DateTime.parse(json['createdAt']),
      enableBackgroundIcon: json['enable_background_icon'],
      enableBot: json['enable_bot'],
      enableGreeting: json['enable_greeting'],
      enableVoiceAi: json['enable_voice_ai'],
      isLostConnection: json['is_lost_connection'],
      managers: List<int>.from(json['managers']),
      nameApp: json['nameApp'],
      quickQuestion: List<dynamic>.from(json['quick_question']),
      showFormLivechat: json['show_form_livechat'],
      socialChanelId: json['socialChanelId'],
      source: json['source'],
      status: json['status'],
      subscribed: json['subscribed'],
      zpCookie: List<dynamic>.from(json['zp_cookie']),
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'active': active,
      'auto_create_lead': autoCreateLead,
      'avatar': avatar,
      'cover': cover,
      'createdAt': createdAt.toIso8601String(),
      'enable_background_icon': enableBackgroundIcon,
      'enable_bot': enableBot,
      'enable_greeting': enableGreeting,
      'enable_voice_ai': enableVoiceAi,
      'is_lost_connection': isLostConnection,
      'managers': managers,
      'nameApp': nameApp,
      'quick_question': quickQuestion,
      'show_form_livechat': showFormLivechat,
      'socialChanelId': socialChanelId,
      'source': source,
      'status': status,
      'subscribed': subscribed,
      'zp_cookie': zpCookie,
      '__v': v,
    };
  }
}

class Owner {
  String? sId;
  String? level;
  // List<Null>? favorites;
  List<String>? userTag;
  String? tagLine;
  bool? isIncognito;
  String? username;
  String? email;
  String? firstName;
  String? lastName;
  String? userSocialId;
  String? source;
  String? password;
  String? lastOnline;
  int? iV;
  String? picture;
  String? cpoCustomerCode;
  int? cpoCustomerId;
  String? customerCode;
  int? customerId;
  String? createdAt;
  String? avatar;
  bool? isBlocked;
  int? isFollowed;
  List<Tags>? tags;

  Owner(
      {this.sId,
      this.level,
      // this.favorites,
      this.userTag,
      this.tagLine,
      this.isIncognito,
      this.username,
      this.email,
      this.firstName,
      this.lastName,
      this.userSocialId,
      this.source,
      this.password,
      this.lastOnline,
      this.iV,
      this.picture,
      this.cpoCustomerCode,
      this.cpoCustomerId,
      this.customerCode,
      this.customerId,
      this.createdAt,
      this.isBlocked,
      this.isFollowed,
      this.avatar,
      this.tags});

  Owner.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    level = json['level'];
    // if (json['favorites'] != null) {
    //   favorites = <Null>[];
    //   json['favorites'].forEach((v) {
    //     favorites!.add(new Null.fromJson(v));
    //   });
    // }
    userTag = json['userTag'].cast<String>();
    tagLine = json['tagLine'];
    avatar = json['avatar'];
    isIncognito = json['isIncognito'];
    username = json['username'];
    email = json['email'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    userSocialId = json['userSocialId'];
    source = json['source'];
    password = json['password'];
    lastOnline = json['lastOnline'];
    iV = json['__v'];
    picture = json['picture'];
    cpoCustomerCode = json['cpoCustomerCode'];
    cpoCustomerId = json['cpoCustomerId'];
    customerCode = json['customerCode'] ?? '';
    customerId = int.tryParse(json['customerId'].toString());
    createdAt = json['createdAt'];
    isBlocked = json['isBlocked'];
    isFollowed = json['isFollowed'];
    if (json['tags'] != null) {
      tags = <Tags>[];
      json['tags'].forEach((v) {
        tags!.add(new Tags.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['level'] = this.level;
    // if (this.favorites != null) {
    //   data['favorites'] = this.favorites!.map((v) => v.toJson()).toList();
    // }
    data['userTag'] = this.userTag;
    data['tagLine'] = this.tagLine;
    data['isIncognito'] = this.isIncognito;
    data['username'] = this.username;
    data['email'] = this.email;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['userSocialId'] = this.userSocialId;
    data['source'] = this.source;
    data['password'] = this.password;
    data['lastOnline'] = this.lastOnline;
    data['__v'] = this.iV;
    data['picture'] = this.picture;
    data['cpoCustomerCode'] = this.cpoCustomerCode;
    data['cpoCustomerId'] = this.cpoCustomerId;
    data['customerCode'] = this.customerCode;
    data['customerId'] = this.customerId;
    data['createdAt'] = this.createdAt;
    data['isBlocked'] = this.isBlocked;
    data['isFollowed'] = this.isFollowed;
    if (this.tags != null) {
      data['tags'] = this.tags!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  String getAvatarName() {
    String avatarName = '';
    String? firstNameResult = firstName?.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    if (firstNameResult != '' && firstNameResult != null) {
      avatarName += firstNameResult[0];
    }
    String? lastNameResult = lastName?.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    if (lastNameResult != '' && lastNameResult != null) {
      avatarName += lastNameResult[0];
    }
    return avatarName == '' ? '*' : avatarName.toUpperCase();
  }

  String getName() {
    List<String> names = [];
    if ((firstName ?? "").isNotEmpty) {
      names.add(firstName!);
    }
    if ((lastName ?? "").isNotEmpty) {
      names.add(lastName!);
    }
    return names.join(" ");
  }
}

class Tags {
  String? sId;
  String? tag;
  String? attachedDate;

  Tags({this.sId, this.tag, this.attachedDate});

  Tags.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    tag = json['tag'];
    attachedDate = json['attachedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['tag'] = this.tag;
    data['attachedDate'] = this.attachedDate;
    return data;
  }
}

class File {
  String? sId;
  String? name;
  String? author;
  int? size;
  String? shield;
  int? iV;
  String? type;
  String? location;
  String? shieldedID;

  File({sId, name, author, size, shield, iV, location, shieldedID, type});

  File.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    author = json['author'];
    size = json['size'];
    shield = json['shield'];
    iV = json['__v'];
    location = json['location'];
    shieldedID = json['shieldedID'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['type'] = type;
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
  File? file;
  int? edit;
  String? errorMessage;
  Staff? staff;
  String? action;
  String? adId;
  int? enableBot;
  int? forward;
  int? isBot;
  int? isCharge;
  int? isSync;
  List<dynamic>? messageItems;
  String? messageTemplate;
  Photos? photos;
  int? reactionTotal;
  int? recall;
  int? seen;
  String? sessionStatus;
  String? sessionTime;
  String? socialMessageId;

  Messages({
    this.sId,
    this.replies,
    this.room,
    this.author,
    this.content,
    this.date,
    this.iV,
    this.type,
    this.file,
    this.edit,
    this.errorMessage,
    this.staff,
    this.action,
    this.adId,
    this.enableBot,
    this.forward,
    this.isBot,
    this.isCharge,
    this.isSync,
    this.messageItems,
    this.messageTemplate,
    this.photos,
    this.reactionTotal,
    this.recall,
    this.seen,
    this.sessionStatus,
    this.sessionTime,
    this.socialMessageId,
  });

  factory Messages.fromJson(Map<String, dynamic> json) {
    final message = Messages(
      sId: json['_id'] as String?,
      room: json['room'] as String?,
      content: (json['content'] as String?) ?? '',
      date: json['date'] as String?,
      iV: json['__v'] as int?,
      type: json['type'] as String?,
      edit: json['edit'] as int? ?? 0,
      errorMessage: json['error_message'] as String?,
      action: json['action'] as String?,
      adId: json['adId'] as String?,
      enableBot: json['enableBot'] as int? ?? 0,
      forward: json['forward'] as int? ?? 0,
      isBot: json['isBot'] as int? ?? 0,
      isCharge: json['isCharge'] as int? ?? 0,
      isSync: json['isSync'] as int? ?? 0,
      messageItems: json['messageItems'] as List<dynamic>? ?? [],
      messageTemplate: json['messageTemplate'] as String?,
      reactionTotal: json['reactionTotal'] as int? ?? 0,
      recall: json['recall'] as int? ?? 0,
      seen: json['seen'] as int? ?? 0,
      sessionStatus: json['sessionStatus'] as String?,
      sessionTime: json['sessionTime'] as String?,
      socialMessageId: json['socialMessageId'] as String?,
      replies: _safeParse(() => Replies.fromJson(json['replies'])),
      author: _safeParse(() => Author.fromJson(json['author'])),
      file: _safeParse(() => File.fromJson(json['file'])),
      staff: _safeParse(() => Staff.fromJson(json['staff'])),
      photos: _safeParse(() => Photos.fromJson(json['photos'])),
    );

    message.replies = _safeParse(() => Replies.fromJson(json['replies']));
    message.author = _safeParse(() => Author.fromJson(json['author']));
    message.file = _safeParse(() => File.fromJson(json['file']));
    message.staff = _safeParse(() => Staff.fromJson(json['staff']));
    message.photos = _safeParse(() => Photos.fromJson(json['photos']));

    if (message.content == 'Message recalled') {
      message.content = AppLocalizations.text(LangKey.messageRecalled);
      message.edit = 0;
    }

    return message;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'replies': replies?.toJson(),
      'room': room,
      'author': author?.toJson(),
      'content': content,
      'date': date,
      '__v': iV,
      'type': type,
      'file': file?.toJson(),
      'edit': edit,
      'error_message': errorMessage,
      'staff': staff?.toJson(),
      'action': action,
      'adId': adId,
      'enableBot': enableBot,
      'forward': forward,
      'isBot': isBot,
      'isCharge': isCharge,
      'isSync': isSync,
      'messageItems': messageItems,
      'messageTemplate': messageTemplate,
      'photos': photos?.toJson(),
      'reactionTotal': reactionTotal,
      'recall': recall,
      'seen': seen,
      'sessionStatus': sessionStatus,
      'sessionTime': sessionTime,
      'socialMessageId': socialMessageId,
    };
  }

  Map<String, dynamic> toMessageJson({List<MessageSeen>? messageSeen}) {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (errorMessage != null) {
      if (messageSeen != null) {
        data['metadata'] = {
          'error_message': errorMessage,
          'messageSeen': messageSeen.map((e) => e.toJson()).toList()
        };
      } else {
        data['metadata'] = {'error_message': errorMessage};
      }
      data['status'] = 'error';
    }
    if (edit != null) {
      data['remoteId'] = '$edit';
    }
    if (author != null) {
      if (staff != null && ChatConnection.isChatHub) {
        data['author'] = {
          'firstName': staff!.fullName,
          'id': author!.sId,
        };
      } else {
        data['author'] = {
          'firstName': author!.firstName,
          'lastName': author!.lastName,
          'id': author!.sId,
          'imageUrl': author!.picture != null
              ? '${HTTPConnection.domain}api/images/${author!.picture!.shieldedID}/512/${ChatConnection.brandCode}'
              : null,
        };
      }
    }
    if (staff != null) {
      data['staff'] = {
        'fullName': staff!.fullName,
        'staffId': staff!.staffId,
      };
    }
    if (date != null) {
      final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
      final dt = format.parse(date!, true);
      data['createdAt'] = dt.toUtc().millisecondsSinceEpoch;
    }
    data['id'] = sId;
    if (type == 'file' && file != null) {
      data['size'] = 0;
      data['type'] = 'file';
      final mimeType = lookupMimeType(file!.name!);
      data['mimeType'] = mimeType;
      data['size'] = file!.size;
      data['name'] = file!.name;
      data['uri'] =
          '${HTTPConnection.domain}api/files/${file!.shieldedID}/${ChatConnection.brandCode}';
    } else if (type == 'image') {
      data['size'] = 0;
      data['type'] = 'image';
      data['name'] = 'image';
      data['uri'] =
          '${HTTPConnection.domain}api/images/$content/${ChatConnection.brandCode}';
    } else {
      data['type'] = 'text';
      data['text'] = content;
    }
    // data['status'] = 'delivered';
    if (replies != null) {
      Map<String, dynamic> json = {};
      json = {
        'author': {
          'firstName': replies?.author?.firstName,
          'lastName': replies?.author?.lastName,
          'id': replies?.author?.sId,
          'imageUrl': replies?.author?.picture != null
              ? '${HTTPConnection.domain}api/images/${replies?.author?.picture!.shieldedID}/512/${ChatConnection.brandCode}'
              : null,
        },
      };
      json['id'] = replies!.sId!;
      final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
      final dt = format.parse(replies!.date!, true);
      json['createdAt'] = dt.toUtc().millisecondsSinceEpoch;
      if (replies?.type == 'file' && replies?.file != null) {
        json['size'] = 0;
        json['type'] = 'file';
        final mimeType = lookupMimeType(replies!.file!.name!);
        json['mimeType'] = mimeType;
        json['size'] = replies!.file!.size;
        json['name'] = replies!.file!.name;
        json['uri'] =
            '${HTTPConnection.domain}api/files/${replies!.file!.shieldedID}/${ChatConnection.brandCode}';
      } else if (replies?.type == 'image') {
        json['size'] = 0;
        json['type'] = 'image';
        json['name'] = 'image';
        json['uri'] =
            '${HTTPConnection.domain}api/images/${replies!.content}/${ChatConnection.brandCode}';
      } else {
        json['type'] = 'text';
        json['text'] = replies!.content;
      }
      data['repliedMessage'] = json;
    }
    return data;
  }
}

T? _safeParse<T>(T Function() fn) {
  try {
    return fn();
  } catch (_) {
    return null;
  }
}

class Photos {
  String? original;
  String? fullsize;
  String? thumbnail;

  Photos({this.original, this.fullsize, this.thumbnail});

  Photos.fromJson(Map<String, dynamic> json) {
    original = json['original'];
    fullsize = json['fullsize'];
    thumbnail = json['thumbnail'];
  }

  Map<String, dynamic> toJson() {
    return {
      'original': original,
      'fullsize': fullsize,
      'thumbnail': thumbnail,
    };
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
    author = json['author'] != null ? Author.fromJson(json['author']) : null;
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

class Staff {
  String? address;
  int? branchId;
  String? email;
  String? fullName;
  String? staffAvatar;
  int? staffId;
  String? userName;

  Staff({address, branchId, email, fullName, staffAvatar, staffId, userName});

  Staff.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    branchId = json['branch_id'];
    email = json['email'];
    fullName = json['full_name'];
    staffAvatar = json['staff_avatar'];
    staffId = json['staff_id'];
    userName = json['user_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['branch_id'] = branchId;
    data['email'] = email;
    data['full_name'] = fullName;
    data['staff_avatar'] = staffAvatar;
    data['staff_id'] = staffId;
    data['user_name'] = userName;
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
  File? picture;

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
      picture = json['picture'] != null ? File.fromJson(json['picture']) : null;
    } catch (_) {}
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
    if (firstNameResult != '' && firstNameResult != null) {
      avatarName += firstNameResult[0];
    }
    String? lastNameResult = lastName?.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    if (lastNameResult != '' && lastNameResult != null) {
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
  File? file;

  Images({sId, room, author, content, type, date, file, iV});

  Images.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    room = json['room'];
    author = json['author'] != null ? Author.fromJson(json['author']) : null;
    content = json['content'];
    type = json['type'];
    date = json['date'];
    iV = json['__v'];
    try {
      file = json['file'] != null ? File.fromJson(json['file']) : null;
    } catch (_) {}
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
    if (file != null) {
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
  File? file;

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
    author = json['author'] != null ? Author.fromJson(json['author']) : null;
    content = json['content'];
    date = json['date'];
    iV = json['__v'];
    type = json['type'];
    file = json['file'] != null ? File.fromJson(json['file']) : null;
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

  PinMessage({recall, edit, seen, sId, room, author, content, date, iV, type});

  PinMessage.fromJson(Map<String, dynamic> json) {
    recall = json['recall'];
    edit = json['edit'];
    seen = json['seen'];
    sId = json['_id'];
    room = json['room'];
    author = json['author'] != null ? Author.fromJson(json['author']) : null;
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
