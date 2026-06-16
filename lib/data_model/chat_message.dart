import 'dart:convert';

import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/room.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/foundation.dart';
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
  List<Messages>? stickers;
  List<Messages>? systemMessages;
  List<Messages>? audioMessages;
  List<Messages>? fileUrls;
  List<Messages>? imageUrls;
  List<Messages>? productMessages;
  List<Messages>? genericMessages;
  List<Messages>? oaListMessages;
  List<Messages>? zpListMessages;
  List<Messages>? oaTemplates;
  List<Messages>? textMessages;
  PinMessage? pinMessage;
  String? oa_group_id;
  Channel? channel;
  String? title;
  String? roomLink;
  int? duration;
  String? roomName;
  String? roomAvatar;
  String? source;

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
      stickers,
      systemMessages,
      audioMessages,
      fileUrls,
      imageUrls,
      productMessages,
      genericMessages,
      oaListMessages,
      zpListMessages,
      oaTemplates,
      textMessages,
      pinMessage,
      owner,
      messageSeen,
      oa_group_id,
      channel,
      this.roomName,
      this.roomAvatar,
      this.title = '',
      this.roomLink,
      this.source,
      this.duration = 0});

  Room.fromJson(Map<String, dynamic> json) {
    source = json['source'];
    roomAvatar = json['room_avatar'];
    roomName = json['room_name'];
    duration = json['duration'];
    roomLink = json['room_link'] ?? '';
    title = json['title'] ?? '';
    sId = json['_id'];
    oa_group_id = json['oa_group_id'];
    if (json['people'] != null) {
      people = <People>[];
      json['people'].forEach((v) {
        people?.add(People.fromJson(v));
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
      stickers = <Messages>[];
      systemMessages = <Messages>[];
      audioMessages = <Messages>[];
      fileUrls = <Messages>[];
      imageUrls = <Messages>[];
      productMessages = <Messages>[];
      genericMessages = <Messages>[];
      oaListMessages = <Messages>[];
      zpListMessages = <Messages>[];
      oaTemplates = <Messages>[];
      textMessages = <Messages>[];

      json['messages'].forEach((v) {
        if (v['content'] == 'Message recalled' && v['type'] == 'image') {
          return;
        }

        final type = v['type'];
        final msg = Messages.fromJson(v);

        messages!.add(msg);

        switch (type) {
          case 'sticker':
            stickers!.add(msg);
            break;
          case 'system':
            systemMessages!.add(msg);
            break;
          case 'audio':
            audioMessages!.add(msg);
            break;
          case 'file_url':
            fileUrls!.add(msg);
            break;
          case 'image_url':
            imageUrls!.add(msg);
            break;
          case 'products':
            productMessages!.add(msg);
            break;
          case 'generic':
            genericMessages!.add(msg);
            break;
          case 'oa_list':
            oaListMessages!.add(msg);
            break;
          case 'zp_list':
            zpListMessages!.add(msg);
            break;
          case 'oa_template':
            oaTemplates!.add(msg);
            break;
          case 'text':
            textMessages!.add(msg);
            break;
        }
      });
      messages = messages?.reversed.toList();
    }

    if (json['images'] != null) {
      images = <Images>[];
      json['images'].forEach((v) {
        if (v['content'] != 'Message recalled') {
          images?.add(Images.fromJson(v));
        }
      });
    }
    if (json['files'] != null) {
      files = <Images>[];
      json['files'].forEach((v) {
        if (v['content'] != 'Message recalled') {
          files?.add(Images.fromJson(v));
        }
      });
    }
    if (json['links'] != null) {
      links = <Images>[];
      json['links'].forEach((v) {
        if (v['content'] != 'Message recalled') {
          files?.add(Images.fromJson(v));
        }
      });
    }
    try {
      pinMessage = json['pinMessage'] != null
          ? PinMessage.fromJson(json['pinMessage'])
          : null;
    } catch (_) {}

    try {
      channel =
          json['channel'] != null ? Channel.fromJson(json['channel']) : null;
    } catch (_) {
      channel = Channel.fromJson(json['channel']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['people'] = people?.map((v) => v.toJson()).toList();
    data['isGroup'] = isGroup;
    data['owner'] = owner?.toJson();
    data['lastUpdate'] = lastUpdate;
    data['lastAuthor'] = lastAuthor;
    data['lastMessage'] = lastMessage;
    data['messages'] = messages?.map((v) => v.toJson()).toList();
    data['messageSeen'] = messageSeen?.map((v) => v.toJson()).toList();
    data['images'] = images?.map((v) => v.toJson()).toList();
    data['files'] = files?.map((v) => v.toJson()).toList();
    data['links'] = links?.map((v) => v.toJson()).toList();
    data['pinMessage'] = pinMessage?.toJson();
    data['oa_group_id'] = oa_group_id;
    data['channel'] = channel?.toJson();
    data['title'] = title;
    data['room_link'] = roomLink;
    data['duration'] = duration;
    data['room_name'] = roomName;
    data['room_avatar'] = roomAvatar;
    data['source'] = source;
    return data;
  }
}

class Channel {
  final String? id;
  final int? active;
  final int? autoCreateLead;
  final String? avatar;
  final String? cover;
  final String? createdAt;
  final int? enableBackgroundIcon;
  final int? enableBot;
  final int? enableGreeting;
  final int? enableVoiceAi;
  final int? isLostConnection;
  final List<int>? managers;
  final String? nameApp;
  final List<dynamic>? quickQuestion;
  final int? showFormLivechat;
  final String? socialChanelId;
  final String? source;
  final bool? status;
  final int? subscribed;
  final List<dynamic>? zpCookie;
  final int? v;

  Channel({
    this.id,
    this.active,
    this.autoCreateLead,
    this.avatar,
    this.cover,
    this.createdAt,
    this.enableBackgroundIcon,
    this.enableBot,
    this.enableGreeting,
    this.enableVoiceAi,
    this.isLostConnection,
    this.managers,
    this.nameApp,
    this.quickQuestion,
    this.showFormLivechat,
    this.socialChanelId,
    this.source,
    this.status,
    this.subscribed,
    this.zpCookie,
    this.v,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['_id'],
      active: json['active'],
      autoCreateLead: json['auto_create_lead'],
      avatar: json['avatar'] ?? '',
      cover: json['cover'],
      createdAt: json['createdAt'],
      enableBackgroundIcon: json['enable_background_icon'],
      enableBot: json['enable_bot'],

      enableGreeting: json['enable_greeting'],
      enableVoiceAi: json['enable_voice_ai'],
      isLostConnection: json['is_lost_connection'],
      // managers: List<int>.from(json['managers']),
      nameApp: json['nameApp'],
      // quickQuestion: List<dynamic>.from(json['quick_question']??[]),
      showFormLivechat: json['show_form_livechat'],
      socialChanelId: json['socialChanelId'],
      source: json['source'],
      status: json['status'],
      subscribed: json['subscribed'],
      // zpCookie: List<dynamic>.from(json['zp_cookie']),
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'active': active,
      'auto_create_lead': autoCreateLead,
      'avatar': avatar,
      // 'cover': cover,
      // 'createdAt': createdAt,
      // 'enable_background_icon': enableBackgroundIcon,
      'enable_bot': enableBot,
      'enable_greeting': enableGreeting,
      'enable_voice_ai': enableVoiceAi,
      'is_lost_connection': isLostConnection,
      // 'managers': managers,
      'nameApp': nameApp,
      // 'quick_question': quickQuestion,
      // 'show_form_livechat': showFormLivechat,
      'socialChanelId': socialChanelId,
      'source': source,
      'status': status,
      'subscribed': subscribed,
      // 'zp_cookie': zpCookie,
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
  String? sticker;
  Map<String, dynamic>? messageObject;
  ImageInfo? image;

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
    this.sticker,
    this.messageObject,
    this.image,
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
      // messageItems: json['messageItems'] as List<dynamic>? ?? [],

      messageItems: json['message_items'] as List<dynamic>? ?? [],
      messageTemplate: json['message_template'] as String?,
      reactionTotal: json['reactionTotal'] as int? ?? 0,
      recall: json['recall'] as int? ?? 0,
      seen: json['seen'] as int? ?? 0,
      sessionStatus: json['sessionStatus'] as String?,
      sessionTime: json['sessionTime'] as String?,
      socialMessageId:
          (json['social_message_id'] ?? json['socialMessageId']) as String?,
      replies: _safeParse(() => Replies.fromJson(json['replies'])),
      author: _safeParse(() => Author.fromJson(json['author'])),
      file: _safeParse(() => File.fromJson(json['file'])),
      staff: _safeParse(() => Staff.fromJson(json['staff'])),
      photos: _safeParse(() => Photos.fromJson(json['photos'])),
      sticker: json['sticker'] as String?,
      messageObject: json['message_object'] as Map<String, dynamic>?,
      image: _safeParse(() => ImageInfo.fromJson(json['image'])),
    );
    message.replies = _safeParse(() => Replies.fromJson(json['replies']));
    message.author = _safeParse(() => Author.fromJson(json['author']));
    message.file = _safeParse(() => File.fromJson(json['file']));
    message.staff = _safeParse(() => Staff.fromJson(json['staff']));
    message.photos = _safeParse(() => Photos.fromJson(json['photos']));

    if (message.type == 'image_url') {
      final imageUrl = message.content ?? '';

      if (imageUrl.isNotEmpty) {
        // Ensure URL has full domain (fix for relative paths like data/xxx/xxx.jpg)
        final fullImageUrl = ensureFullUrl(imageUrl);

        // Gắn giá trị image và photos dựa trên content
        message.image = ImageInfo(
          name: imageUrl.split('/').last,
          location: fullImageUrl,
          size: 0,
          shieldedID: imageUrl.split('/').last,
        );

        message.photos = Photos(
          original: fullImageUrl,
          fullsize: fullImageUrl,
          thumbnail: fullImageUrl,
        );
      }
    }

    if (message.type == 'link') {
      final linkText = message.content ?? '';
      final url = message._extractFirstUrl(linkText);
      message.messageObject = {
        'url': url,
        'text': linkText,
      };
    }

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
      'sticker': sticker,
      'message_object': messageObject,
      'image': image?.toJson(),
    };
  }

  Map<String, dynamic> toMessageJson({List<MessageSeen>? messageSeen}) {
    final Map<String, dynamic> data = <String, dynamic>{};

    final Map<String, dynamic> metadata = {};
    if (errorMessage != null) {
      metadata['error_message'] = errorMessage;
      data['status'] = 'error';
    }
    if (messageSeen != null) {
      metadata['messageSeen'] = messageSeen.map((e) => e.toJson()).toList();
    }
    if (edit != null) {
      data['remoteId'] = '$edit';
    }
    if (author != null) {
      if (staff != null && ChatConnection.isChatHub) {
        // ChatHub — staff message: dùng staffAvatar nếu có
        data['author'] = {
          'firstName': staff!.fullName,
          'id': author!.sId,
          'imageUrl': staff!.staffAvatar?.isNotEmpty == true
              ? staff!.staffAvatar
              : null,
        };
      } else {
        // ChatHub customer: ưu tiên author.avatar (CDN URL trực tiếp từ platform, luôn load được).
        // Non-ChatHub: ưu tiên picture.shieldedID (internal upload), fallback sang avatar.
        final String? imageUrl = ChatConnection.isChatHub
            ? (author!.avatar?.isNotEmpty == true
                ? author!.avatar
                : author!.picture != null
                    ? '${HTTPConnection.domain}api/images/${author!.picture!.shieldedID}/512/${ChatConnection.brandCode}'
                    : null)
            : (author!.picture != null
                ? '${HTTPConnection.domain}api/images/${author!.picture!.shieldedID}/512/${ChatConnection.brandCode}'
                : author!.avatar?.isNotEmpty == true
                    ? author!.avatar
                    : null);
        data['author'] = {
          'firstName': author!.firstName,
          'lastName': author!.lastName,
          'id': author!.sId,
          'imageUrl': imageUrl,
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
      try {
        final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
        final dt = format.parse(date!, true);
        data['createdAt'] = dt.toUtc().millisecondsSinceEpoch;
      } catch (e) {
        data['createdAt'] = DateTime.now().toUtc().millisecondsSinceEpoch;
      }
    }
    data['id'] = sId;
    switch (type) {
      case 'text':
        data['type'] = 'text';
        data['text'] = content;
        break;

      case 'image':
        data['type'] = 'image';
        data['size'] = image?.size ?? 0;
        data['name'] = image?.name ?? 'image.jpg';
        data['uri'] = photos?.original ??
            photos?.fullsize ??
            image?.location ??
            (content != null && content!.isNotEmpty
                ? '${HTTPConnection.domain}api/images/$content/${ChatConnection.brandCode}'
                : null);
        metadata['content'] = content;
        metadata['type'] = 'image';
        metadata['image'] = image?.toJson();
        break;

      case 'image_url':
        data['type'] = 'custom';
        data['name'] = image?.name ?? 'external_image.jpg';
        data['size'] = image?.size ?? 0;
        // Ensure URL has full domain (fix for relative paths like data/xxx/xxx.jpg)
        final imageUrlUri = image?.location ?? photos?.original ?? content;
        data['uri'] = ensureFullUrl(imageUrlUri);
        metadata['custom_type'] = 'image_url';
        metadata['source'] = 'external';
        metadata['content'] = ensureFullUrl(content);
        break;

      case 'link':
        data['type'] = 'custom';
        metadata['custom_type'] = 'link';
        metadata['text'] = content ?? '';
        metadata['url'] = _extractFirstUrl(content ?? '');
        break;

      case 'file':
        if (file != null) {
          data['type'] = 'file';
          data['size'] = file!.size;
          data['name'] = file!.name;
          data['uri'] =
              '${HTTPConnection.domain}api/files/${file!.shieldedID}/${ChatConnection.brandCode}';
          data['mimeType'] = lookupMimeType(file!.name!);
        }
        break;

      case 'file_url':
        data['type'] = 'file';
        // WhatsApp document: message_object có thể không có file_url (hasMedia=true, URL chưa được server lưu vào message_object)
        // Fallback: photos.original → photos.fullsize → null
        final rawFileUrl = messageObject?['file_url'] as String?;
        final photosFileUrl = (photos?.original?.isNotEmpty == true)
            ? photos!.original
            : (photos?.fullsize?.isNotEmpty == true ? photos!.fullsize : null);
        data['uri'] =
            (rawFileUrl?.isNotEmpty == true) ? rawFileUrl : photosFileUrl;
        data['name'] = messageObject?['file_name'] ?? content ?? 'File';
        data['size'] =
            int.tryParse(messageObject?['file_size']?.toString() ?? '0') ?? 0;
        data['file_type'] = messageObject?['file_type'];
        data['mimeType'] =
            messageObject?['file_type'] ?? lookupMimeType(data['name']);
        break;

      case 'audio':
        data['type'] = 'audio';
        data['size'] = 0;
        data['name'] = 'audio';
        data['duration'] = const Duration(seconds: 1).inMilliseconds;
        data['uri'] = file?.location;
        break;

      case 'sticker':
        data['type'] = 'custom';
        metadata['custom_type'] = 'sticker';
        metadata['url'] = sticker;
        break;

      case 'products':
        data['type'] = 'custom';
        metadata['custom_type'] = 'products';
        metadata['items'] = messageItems;
        break;

      case 'generic':
        data['type'] = 'custom';
        metadata['custom_type'] = 'generic';

        final items = (messageItems is List) ? messageItems as List : const [];

        Map<String, dynamic>? firstItem;
        if (items.isNotEmpty && items.first is Map<String, dynamic>) {
          firstItem = items.first as Map<String, dynamic>;
        }

        final payload = firstItem?['payload'];
        final elements = (payload is Map && payload['elements'] is List)
            ? payload['elements'] as List
            : null;

        if (elements != null && elements.isNotEmpty) {
          metadata['elements'] = elements;
        }
        break;

      case 'zp_list':
        {
          data['type'] = 'custom';
          metadata['custom_type'] = 'zp_list';
          final firstTitle = (messageItems)?.isNotEmpty == true
              ? (messageItems!.first['title'] as String? ?? '')
              : (content ?? '');

          metadata['text'] = firstTitle;
          try {
            metadata['zp_list_items'] = jsonEncode(messageItems ?? []);
          } catch (_) {
            metadata['zp_list_items'] = '[]';
          }
          break;
        }

      case 'oa_template':
        data['type'] = 'custom';
        metadata['custom_type'] = 'oa_template';
        metadata['html'] = messageTemplate;
        metadata['text'] = content ?? 'Tin nhắn mẫu OA';
        break;

      case 'oa_list':
        data['type'] = 'custom';
        metadata['custom_type'] = 'oa_list';
        metadata['data'] = (messageItems)?.first?['payload'];
        break;

      case 'template':
        data['type'] = 'custom';
        metadata['custom_type'] = 'template';
        data['text'] = messageObject?['title'] as String? ?? 'Message Template';
        if (messageObject != null) {
          metadata['template_title'] = messageObject!['title'];
          metadata['template_description'] = messageObject!['description'];
          metadata['template_url'] = messageObject!['url'];
          metadata['template_image'] = messageObject!['image'];
          if ((content ?? '').isNotEmpty) {
            data['text'] = content;
          }
        }
        break;

      case 'video':
        data['type'] = 'custom';
        metadata['custom_type'] = 'video';
        data['content'] = content;
        if (messageObject != null) {
          metadata['title'] = messageObject!['title'];
          metadata['description'] = messageObject!['description'];
          metadata['href'] = messageObject!['href'];
          metadata['thumb'] = messageObject!['thumb'];
          metadata['action'] = messageObject!['action'];
          metadata['params'] = messageObject!['params'];
        }
        break;

      default:
        data['type'] = 'text';
        data['text'] = content;
        break;
    }

    if (metadata.isNotEmpty) {
      data['metadata'] = metadata;
    }
    if (replies != null) {
      final Map<String, dynamic> repliedJson = {};

      repliedJson['author'] = {
        'firstName': replies!.author?.firstName,
        'lastName': replies!.author?.lastName,
        'id': replies!.author?.sId,
      };
      repliedJson['id'] = replies!.sId!;
      try {
        final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
        final dt = format.parse(replies!.date!, true);
        repliedJson['createdAt'] = dt.toUtc().millisecondsSinceEpoch;
      } catch (_) {}

      switch (replies?.type) {
        case 'link':
          repliedJson['type'] = 'custom';
          repliedJson['text'] = replies!.content ?? '';
          final url = _extractFirstUrl(replies!.content ?? '');
          repliedJson['metadata'] = {
            'custom_type': 'link',
            'url': url,
            'text': replies!.content,
          };
          break;

        case 'image':
          repliedJson['type'] = 'image';
          repliedJson['name'] = replies!.image?.name ?? 'image.jpg';
          repliedJson['size'] = replies!.image?.size ?? 0;
          // Áp dụng logic lấy URL thông minh và chính xác
          repliedJson['uri'] = replies!.photos?.original ??
              replies!.photos?.fullsize ??
              replies!.image?.location ??
              (replies!.content != null && replies!.content!.isNotEmpty
                  ? '${HTTPConnection.domain}api/images/${replies!.content}/${ChatConnection.brandCode}'
                  : null);
          break;

        case 'image_url':
          repliedJson['type'] = 'image';
          repliedJson['name'] = replies!.image?.name ?? 'external_image.jpg';
          repliedJson['size'] = replies!.image?.size ?? 0;
          // Ensure URL has full domain (fix for relative paths like data/xxx/xxx.jpg)
          final repliedImageUrl = replies!.image?.location ??
              replies!.photos?.original ??
              replies!.content;
          repliedJson['uri'] = ensureFullUrl(repliedImageUrl);
          repliedJson['metadata'] = {
            'custom_type': 'image_url',
            'source': 'external',
            'content': ensureFullUrl(replies!.content),
          };
          break;

        case 'file':
          repliedJson['type'] = 'file';
          repliedJson['name'] = replies!.file?.name ?? 'File';
          repliedJson['size'] = replies!.file?.size ?? 0;
          repliedJson['uri'] = replies!.file?.location ?? '';
          repliedJson['mimeType'] = lookupMimeType(replies?.file?.name ?? '--');
          break;

        case 'file_url':
          repliedJson['type'] = 'file';
          if (replies!.messageObject != null) {
            repliedJson['name'] =
                replies!.messageObject?['file_name'] ?? 'File';
            repliedJson['size'] = int.tryParse(
                    replies!.messageObject?['file_size']?.toString() ?? '0') ??
                0;
            repliedJson['uri'] = replies!.messageObject?['file_url'] ?? '';
            repliedJson['mimeType'] =
                lookupMimeType(replies!.messageObject?['file_name']);
          }
          break;

        case 'audio':
          repliedJson['type'] =
              'text'; // Hiển thị preview dưới dạng text cho đơn giản
          repliedJson['text'] = '▶ Tin nhắn thoại';
          break;

        case 'sticker':
          repliedJson['type'] = 'custom';
          repliedJson['text'] =
              'Sticker'; // Tùy chỉnh text hiển thị cho sticker
          repliedJson['url'] = replies!.sticker; // URL sticker
          if (replies?.sticker != null) {
            repliedJson['metadata'] = {
              'custom_type': 'sticker',
              'url': replies?.sticker,
            };
          }
          break;

        case 'products':
          repliedJson['type'] = 'custom';
          repliedJson['text'] = 'Products List';
          repliedJson['items'] = replies!.messageItems?.map((item) {
            return {
              'url': item['url'],
              'name': item['name'],
              'code': item['code'],
              'price': item['price'],
              'image_urls': item['image_urls'],
              'description': item['description'],
            };
          }).toList();
          break;

        case 'generic':
          repliedJson['type'] = 'custom';
          repliedJson['text'] = 'Generic Template';

          final repItems = (replies!.messageItems is List)
              ? replies!.messageItems as List
              : const [];

          Map<String, dynamic>? firstItem;
          if (repItems.isNotEmpty && repItems.first is Map<String, dynamic>) {
            firstItem = repItems.first as Map<String, dynamic>;
          }

          final payload = firstItem?['payload'];
          final elements = (payload is Map && payload['elements'] is List)
              ? payload['elements'] as List
              : null;

          if (elements != null && elements.isNotEmpty) {
            repliedJson['metadata'] = {
              'custom_type': 'generic',
              'elements': elements,
            };
          }
          break;

        case 'system':
          repliedJson['type'] = 'custom';
          repliedJson['text'] = replies!.content ?? 'System Message';
          break;

        case 'zp_list':
          {
            repliedJson['type'] = 'custom';
            final rawItems = replies!.messageItems; // dynamic

            final List<Map<String, dynamic>> items = (rawItems is List)
                ? rawItems
                    .whereType<Map>()
                    .map((e) =>
                        e.cast<String, dynamic>()) // cast key/value đúng kiểu
                    .toList()
                : <Map<String, dynamic>>[];

            // 3) Text fallback — ưu tiên title của item đầu
            final fallbackText = items.isNotEmpty
                ? (items.first['title'] as String? ?? replies!.content ?? '')
                : (replies!.content ?? '');

            // 4) Đặt đúng vào repliedJson['metadata'] vì widget đang đọc từ đây
            repliedJson['metadata'] = {
              'custom_type': 'zp_list',
              'text': fallbackText,
              'items': items
                  .map((item) => {
                        'title': item['title'] ?? '',
                        'description': item['description'] ?? '',
                        'href': item['href'] ?? '',
                        'thumb': item['thumb'] ?? '',
                        'childnumber': item['childnumber'] ?? 0,
                        'action': item['action'] ?? '',
                        'params': item['params'] ?? '', // server là JSON string
                        'type': item['type'] ?? '',
                      })
                  .toList(),

              // (tuỳ chọn) header nhanh cho UI
              'title': items.isNotEmpty
                  ? (items.first['title'] as String? ?? '')
                  : '',
              'description': items.isNotEmpty
                  ? (items.first['description'] as String? ?? '')
                  : '',
              'href': items.isNotEmpty
                  ? (items.first['href'] as String? ?? '')
                  : '',
            };

            repliedJson['text'] = fallbackText;

            break;
          }

        case 'oa_template':
          repliedJson['type'] = 'text';
          repliedJson['text'] = replies?.content ?? 'Tin nhắn mẫu OA';
          break;

        case 'oa_list':
          repliedJson['type'] = 'custom';
          repliedJson['text'] = 'OA List Message';
          repliedJson['items'] = replies?.messageItems?.map((item) {
            return {
              'thumbnail': item['thumbnail'],
              'description': item['description'],
              'title': item['title'],
              'url': item['url'],
            };
          }).toList();
          break;

        case 'template':
          repliedJson['type'] = 'custom';
          repliedJson['text'] =
              replies!.messageObject?['title'] as String? ?? 'Message Template';
          repliedJson['metadata'] = {
            'custom_type': 'template',
            'template_title': replies!.messageObject?['title'],
            'template_description': replies!.messageObject?['description'],
            'template_url': replies!.messageObject?['url'],
            'template_image': replies!.messageObject?['image'],
          };
          break;

        case 'video':
          repliedJson['type'] = 'custom';
          repliedJson['metadata'] = {
            'custom_type': 'video',
            'title': replies!.messageObject?['title'],
            'description': replies!.messageObject?['description'],
            'href': replies!.messageObject?['href'],
            'thumb': replies!.messageObject?['thumb'],
            'action': replies!.messageObject?['action'],
            'params': replies!.messageObject?['params'],
          };
          break;

        default:
          repliedJson['type'] = 'text';
          repliedJson['text'] = replies?.content;
          break;
      }

      data['repliedMessage'] = repliedJson;
    }
    return data;
  }

  String? _extractFirstUrl(String text) {
    final urlPattern = RegExp(
      r'((https?:\/\/)?([a-zA-Z0-9\-]+\.)+[a-zA-Z]{2,}(\/\S*)?)',
      caseSensitive: false,
    );
    final match = urlPattern.firstMatch(text);
    if (match != null) {
      var url = match.group(0);
      // Thêm https nếu thiếu
      if (url != null && !url.startsWith('http')) {
        url = 'https://$url';
      }
      return url;
    }
    return null;
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
  String? avatar;

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
      avatar,
      picture});

  Author.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    level = json['level'];
    tagLine = json['tagLine'];
    username = json['username'];
    firstName = json['firstName'];
    phone = json['phone'];
    avatar = json['avatar'];
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
  Photos? photos;
  ImageInfo? image;
  List<dynamic>? messageItems; // Mảng messageItems
  String? sticker; // URL của sticker
  Map<String, dynamic>? messageObject; // Thêm field messageObject
  Map<String, dynamic>? metadata; // Thêm trường metadata

  Replies({
    sId,
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
    file,
    this.photos,
    this.image,
    this.messageItems,
    this.sticker,
    this.messageObject,
    this.metadata, // Thêm metadata vào constructor
  });

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
    photos = _safeParse(() => Photos.fromJson(json['photos']));
    image = _safeParse(() => ImageInfo.fromJson(json['image']));
    messageItems = json['message_items'] != null
        ? List<dynamic>.from(json['message_items'])
        : null;
    sticker = json['sticker'];

    // Parse messageObject
    if (json['message_object'] != null) {
      messageObject = json['message_object'];
    }

    // Parse metadata (thêm phần này)
    if (json['metadata'] != null) {
      metadata = json['metadata'];
    }
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

    data['photos'] = photos?.toJson();
    data['image'] = image?.toJson();
    data['message_items'] = messageItems;
    data['sticker'] = sticker;
    data['message_object'] = messageObject; // Thêm message_object vào json

    // Thêm metadata vào json
    if (metadata != null) {
      data['metadata'] = metadata;
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

//_________________________________

class PhotoModel {
  final String original;
  final String fullsize;
  final String thumbnail;

  PhotoModel({
    required this.original,
    required this.fullsize,
    required this.thumbnail,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) => PhotoModel(
        original: json['original'] ?? '',
        fullsize: json['fullsize'] ?? '',
        thumbnail: json['thumbnail'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'original': original,
        'fullsize': fullsize,
        'thumbnail': thumbnail,
      };
}

class ProductItem {
  final String url;
  final String name;
  final String code;
  final String price;
  final List<String> imageUrls;
  final String description;

  ProductItem({
    required this.url,
    required this.name,
    required this.code,
    required this.price,
    required this.imageUrls,
    required this.description,
  });

  factory ProductItem.fromJson(Map<String, dynamic> json) => ProductItem(
        url: json['url'] ?? '',
        name: json['name'] ?? '',
        code: json['code'] ?? '',
        price: json['price'] ?? '',
        imageUrls: List<String>.from(json['image_urls'] ?? []),
        description: json['description'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'url': url,
        'name': name,
        'code': code,
        'price': price,
        'image_urls': imageUrls,
        'description': description,
      };
}

class TemplateButton {
  final String title;
  final String payload;
  final int pageId;
  final int appId;
  final String notificationMessagesFrequency;
  final String notificationMessagesReoptin;
  final String notificationMessagesTimezone;
  final String notificationMessagesCtaText;
  final int notificationMessagesTemplateSentTime;
  final String imageUrl;
  final String notificationMessagesCtaEntryPoint;
  final int notificationMessagesCtmAdId;
  final String notificationMessagesUniqueId;

  TemplateButton({
    required this.title,
    required this.payload,
    required this.pageId,
    required this.appId,
    required this.notificationMessagesFrequency,
    required this.notificationMessagesReoptin,
    required this.notificationMessagesTimezone,
    required this.notificationMessagesCtaText,
    required this.notificationMessagesTemplateSentTime,
    required this.imageUrl,
    required this.notificationMessagesCtaEntryPoint,
    required this.notificationMessagesCtmAdId,
    required this.notificationMessagesUniqueId,
  });

  factory TemplateButton.fromJson(Map<String, dynamic> json) => TemplateButton(
        title: json['title'] ?? '',
        payload: json['payload'] ?? '',
        pageId: json['page_id'] ?? 0,
        appId: json['app_id'] ?? 0,
        notificationMessagesFrequency:
            json['notification_messages_frequency'] ?? '',
        notificationMessagesReoptin:
            json['notification_messages_reoptin'] ?? '',
        notificationMessagesTimezone:
            json['notification_messages_timezone'] ?? '',
        notificationMessagesCtaText:
            json['notification_messages_cta_text'] ?? '',
        notificationMessagesTemplateSentTime:
            json['notification_messages_template_sent_time'] ?? 0,
        imageUrl: json['image_url'] ?? '',
        notificationMessagesCtaEntryPoint:
            json['notification_messages_cta_entry_point'] ?? '',
        notificationMessagesCtmAdId:
            json['notification_messages_ctm_ad_id'] ?? 0,
        notificationMessagesUniqueId:
            json['notification_messages_unique_id'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'payload': payload,
        'page_id': pageId,
        'app_id': appId,
        'notification_messages_frequency': notificationMessagesFrequency,
        'notification_messages_reoptin': notificationMessagesReoptin,
        'notification_messages_timezone': notificationMessagesTimezone,
        'notification_messages_cta_text': notificationMessagesCtaText,
        'notification_messages_template_sent_time':
            notificationMessagesTemplateSentTime,
        'image_url': imageUrl,
        'notification_messages_cta_entry_point':
            notificationMessagesCtaEntryPoint,
        'notification_messages_ctm_ad_id': notificationMessagesCtmAdId,
        'notification_messages_unique_id': notificationMessagesUniqueId,
      };
}

class LinkItem {
  final String thumbnail;
  final String description;
  final String title;
  final String url;

  LinkItem({
    required this.thumbnail,
    required this.description,
    required this.title,
    required this.url,
  });

  factory LinkItem.fromJson(Map<String, dynamic> json) => LinkItem(
        thumbnail: json['thumbnail'] ?? '',
        description: json['description'] ?? '',
        title: json['title'] ?? '',
        url: json['url'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'thumbnail': thumbnail,
        'description': description,
        'title': title,
        'url': url,
      };
}

class ActionItem {
  final String title;
  final String description;
  final String href;
  final String thumb;
  final int childNumber;
  final String action;
  final String params;
  final String type;

  ActionItem({
    required this.title,
    required this.description,
    required this.href,
    required this.thumb,
    required this.childNumber,
    required this.action,
    required this.params,
    required this.type,
  });

  factory ActionItem.fromJson(Map<String, dynamic> json) => ActionItem(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        href: json['href'] ?? '',
        thumb: json['thumb'] ?? '',
        childNumber: json['childnumber'] ?? 0,
        action: json['action'] ?? '',
        params: json['params'] ?? '',
        type: json['type'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'href': href,
        'thumb': thumb,
        'childnumber': childNumber,
        'action': action,
        'params': params,
        'type': type,
      };
}

class MessageFileObject {
  final String fileUrl;
  final String fileName;
  final String fileSize;
  final String fileType;

  MessageFileObject({
    required this.fileUrl,
    required this.fileName,
    required this.fileSize,
    required this.fileType,
  });

  factory MessageFileObject.fromJson(Map<String, dynamic> json) =>
      MessageFileObject(
        fileUrl: json['file_url'] ?? '',
        fileName: json['file_name'] ?? '',
        fileSize: json['file_size'] ?? '',
        fileType: json['file_type'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'file_url': fileUrl,
        'file_name': fileName,
        'file_size': fileSize,
        'file_type': fileType,
      };
}

class ImageInfo {
  String? location;
  String? name;
  int? size;
  String? shieldedID;

  ImageInfo({this.location, this.name, this.size, this.shieldedID});

  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    return ImageInfo(
        location: (json['location'] ?? '') as String?,
        name: (json['name'] ?? '') as String?,
        size: (json['size'] ?? 0) as int?,
        shieldedID: json['shieldedID'].toString());
  }

  Map<String, dynamic> toJson() => {
        'location': location,
        'name': name,
        'size': size,
        'shieldedID': shieldedID
      };
}

/// Helper function to ensure URL has a host
/// If URL is relative (doesn't start with http:// or https://), prepend the domain
String ensureFullUrl(String? url) {
  if (url == null || url.isEmpty) return '';

  // If already a full URL, return as is
  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }

  // If it's a relative path, prepend the domain
  return '${HTTPConnection.domain}$url';
}
