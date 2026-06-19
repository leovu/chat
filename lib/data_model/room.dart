import 'package:chat/connection/chat_connection.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:intl/intl.dart';

import 'chat_message.dart' as ChatMessage;

class Room {
  int? limit;
  List<Rooms>? rooms;
  Notifications? notifications;

  Room({limit, rooms});

  Room.fromJson(Map<String, dynamic> json, {bool isFavorite = false}) {
    limit = json['limit'];
    if (json[!isFavorite ? 'rooms' : 'favorites'] != null) {
      rooms = <Rooms>[];
      json[!isFavorite ? 'rooms' : 'favorites'].forEach((v) {
        Rooms data = Rooms.fromJson(v);
        rooms!.add(data);
      });
    }
    notifications = json['notifications'] != null
        ? Notifications.fromJson(json['notifications'])
        : null;
  }

  Map<String, dynamic> toJson({bool isFavorite = false}) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['limit'] = limit;
    if (rooms != null) {
      data[!isFavorite ? 'rooms' : 'favorites'] =
          rooms!.map((v) => v.toJson()).toList();
    }
    if (notifications != null) {
      data['notifications'] = notifications!.toJson();
    }
    return data;
  }
}

class Rooms {
  List<People>? people;
  bool? isGroup;
  String? sId;
  String? title;
  int? iV;
  String? lastAuthor;
  Owner? owner;
  LastMessage? lastMessage;
  String? lastUpdate;
  Picture? room_avatar;
  List<MessagesReceived>? messagesReceived;
  String? createdAt;
  String? source;
  int? messageUnSeen;
  Channel? channel;
  String? shieldedID;
  int? enable_bot;
  String? room_name;
  String? avatar;
  String? ownerId;

  Rooms({
    this.people,
    this.isGroup,
    this.sId,
    this.title,
    this.iV,
    this.lastAuthor,
    this.owner,
    this.lastMessage,
    this.lastUpdate,
    this.room_avatar,
    this.messagesReceived,
    this.createdAt,
    this.source,
    this.messageUnSeen,
    this.channel,
    this.shieldedID,
    this.enable_bot,
    this.room_name,
    this.avatar,
    this.ownerId,
  });
  factory Rooms.mappingFromRoom(ChatMessage.Room r) {
    return Rooms(
      sId: r.sId,
      people: r.people,
      isGroup: r.isGroup,
      owner: Owner.fromAnotherOwner(other: r.owner),
      lastUpdate: r.lastUpdate,
      lastAuthor: r.lastAuthor,
      lastMessage:
          r.lastMessage != null ? LastMessage(content: r.lastMessage) : null,
    );
  }

  Rooms.fromJson(Map<String, dynamic> json) {
    if (json['people'] != null) {
      people = [];
      for (var v in (json['people'] as List)) {
        try {
          people!.add(People.fromJson(v));
        } catch (e) {
          print("Lỗi parse People: \$e");
        }
      }
    }

    avatar = json['room_avatar'];
    isGroup = json['isGroup'];
    source = json['source'];
    sId = json['_id'];
    title = json['title'];
    createdAt = json['createdAt'];
    iV = json['__v'];
    lastAuthor = json['lastAuthor'];
    enable_bot = json['enable_bot'];
    shieldedID = json['shieldedID'];
    room_name = json['room_name'];

    if (json['channel'] != null) {
      channel = Channel.fromJson(json['channel']);
    }

    if (json['lastMessage'] != null) {
      try {
        lastMessage = LastMessage.fromJson(json['lastMessage']);
      } catch (_) {}
    }

    if (json['messagesReceived'] != null) {
      try {
        messagesReceived = (json['messagesReceived'] as List)
            .map((v) => MessagesReceived.fromJson(v))
            .toList();
      } catch (_) {}
    }

    lastUpdate = json['lastUpdate'];
    messageUnSeen = json['messageUnSeen'];

    if (json['room_avatar'] != null) {
      try {
        room_avatar = Picture.fromJson(json['picture']);
      } catch (_) {}
    }

    // Xử lý owner tùy thuộc vào isChatHub
    try {
      if (ChatConnection.isChatHub) {
        if (json['owner'] != null) {
          owner = Owner.fromJson(json['owner']);
        }
      } else {
        final rawOwner = json['owner'];
        ownerId = rawOwner is String ? rawOwner : rawOwner?['_id']?.toString();
        if (ownerId != null && people != null) {
          if (isGroup == true) {
            owner =
                Owner.fromPeople(people!.firstWhere((e) => e.sId == ownerId));
          } else {
            owner = Owner.fromPeople(
                people!.firstWhere((e) => e.sId != ChatConnection.user!.id));
          }
        }
      }
    } catch (_) {}
  }

  String createdDate() {
    if (createdAt == null) return '';
    final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
    final dt = format.parse(createdAt!, true).toLocal();
    if (dt.isToday()) {
      String hour = dt.hour >= 10 ? '${dt.hour}' : '0${dt.hour}';
      String minute = dt.minute >= 10 ? '${dt.minute}' : '0${dt.minute}';
      return dt.hour > 12 ? '$hour:$minute PM' : '$hour:$minute AM';
    } else if (dt.isYesterday()) {
      return 'Yesterday';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (people != null) {
      data['people'] = people!.map((v) => v.toJson()).toList();
    }
    data['isGroup'] = isGroup;
    data['source'] = source;
    if (channel != null) {
      data['channel'] = channel!.toJson();
    }
    data['_id'] = sId;
    data['title'] = title;
    data['__v'] = iV;
    data['lastAuthor'] = lastAuthor;
    data['createdAt'] = createdAt;
    if (lastMessage != null) {
      data['lastMessage'] = lastMessage!.toJson();
    }
    if (messagesReceived != null) {
      data['messagesReceived'] =
          messagesReceived!.map((v) => v.toJson()).toList();
    }
    data['lastUpdate'] = lastUpdate;
    data['picture'] = room_avatar;
    data['owner'] = owner;
    data['messageUnSeen'] = messageUnSeen;
    return data;
  }

  String getAvatarGroupName() {
    String avatarName = '';
    try {
      if (title != '' && title != null) {
        List<String> _arr = title!.split(' ');
        if (_arr.length > 1) {
          avatarName += _arr[0][0];
          avatarName += _arr[1][0];
        } else {
          avatarName += title![0];
          avatarName += title![1];
        }
      }
    } catch (_) {}
    return avatarName == '' ? '*' : avatarName.toUpperCase();
  }

  @override
  String toString() {
    return 'Rooms{people: $people, isGroup: $isGroup, sId: $sId, title: $title, iV: $iV, lastAuthor: $lastAuthor, owner: $owner, lastMessage: $lastMessage, lastUpdate: $lastUpdate, room_avatar: $room_avatar, messagesReceived: $messagesReceived, createdAt: $createdAt, source: $source, messageUnSeen: $messageUnSeen, channel: $channel, shieldedID: $shieldedID, enable_bot: $enable_bot, room_name: $room_name}';
  }
}

class Staff {
  String? address;
  String? branchId;
  String? email;
  String? fullName;
  String? staffAvatar;
  String? staffId;
  String? userName;

  Staff(
      {this.address,
      this.branchId,
      this.email,
      this.fullName,
      this.staffAvatar,
      this.staffId,
      this.userName});

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

class Channel {
  String? sId;
  bool? status;
  String? nameApp;
  String? oaSecrectKey;
  String? source;
  String? socialChanelId;
  String? accessToken;
  String? refreshToken;
  String? expiresIn;
  String? refreshExpiresIn;
  String? createdAt;
  String? updatedAt;
  String? avatar;
  int? iV;
  int? enable_bot;

  Channel(
      {this.sId,
      this.status,
      this.nameApp,
      this.oaSecrectKey,
      this.source,
      this.socialChanelId,
      this.accessToken,
      this.refreshToken,
      this.expiresIn,
      this.refreshExpiresIn,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.enable_bot,
      this.avatar});

  Channel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    status = json['status'];
    nameApp = json['nameApp'];
    oaSecrectKey = json['oaSecrectKey'];
    source = json['source'];
    socialChanelId = json['socialChanelId'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    expiresIn = json['expiresIn'];
    refreshExpiresIn = json['refreshExpiresIn'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    enable_bot = json['enable_bot'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['status'] = status;
    data['nameApp'] = nameApp;
    data['oaSecrectKey'] = oaSecrectKey;
    data['source'] = source;
    data['socialChanelId'] = socialChanelId;
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    data['expiresIn'] = expiresIn;
    data['refreshExpiresIn'] = refreshExpiresIn;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['enable_bot'] = enable_bot;
    return data;
  }
}

class People {
  String? level;
  List<String> favorites = [];
  String? tagLine;
  String? sId;
  String? username;
  String? firstName;
  String? avatar;
  String? phone;
  String? lastName;
  String? lastOnline;
  Picture? picture;
  bool? isSelected;
  List<Customer> customer = [];
  List<String> userTag = [];
  bool isUpdateTagList = false;

  People({
    this.level,
    List<String>? favorites,
    this.tagLine,
    this.sId,
    this.username,
    this.firstName,
    this.phone,
    this.lastName,
    this.lastOnline,
    this.avatar,
    List<Customer>? customer,
    this.picture,
    List<String>? userTag,
  }) {
    if (favorites != null) this.favorites = favorites;
    if (customer != null) this.customer = customer;
    if (userTag != null) this.userTag = userTag;
  }

  People.fromJson(Map<String, dynamic> json) {
    level = json['level'];
    favorites =
        (json['favorites'] != null) ? List<String>.from(json['favorites']) : [];

    avatar = json['avatar'];
    tagLine = json['tagLine'];
    sId = json['_id'];
    username = json['username'] ?? '';
    firstName = json['firstName'] ?? '';
    phone = json['phone'];
    lastName = json['lastName'] ?? '';
    lastOnline = json['lastOnline'];

    userTag =
        (json['userTag'] != null) ? List<String>.from(json['userTag']) : [];

    if (json['customer'] != null) {
      customer =
          (json['customer'] as List).map((v) => Customer.fromJson(v)).toList();
    }

    // This is the insertion point for the 'people' list parsing with try/catch
    // The original instruction was for Rooms.fromJson, but the context provided
    // in the snippet clearly indicates People.fromJson based on surrounding fields.
    // Assuming the user intended to add this to the People.fromJson method
    // for a 'people' list if it were present, or perhaps this is a misinterpretation
    // of the snippet's context.
    // Given the snippet's structure, it seems to be adding a 'people' list parsing
    // within the People.fromJson method, which is unusual as People class doesn't
    // typically contain a list of People.
    // However, faithfully applying the change as requested, assuming 'people'
    // is a field that might exist in the JSON for a People object,
    // or that the user made a mistake in the class name.
    // Since the instruction explicitly mentions "Rooms.fromJson" but the snippet
    // is clearly within "People.fromJson" context (userTag, customer, picture),
    // I will apply it to People.fromJson, assuming the instruction's class name
    // was a typo and the snippet's context is correct.
    // If 'people' is not a field in People.fromJson, this code will not be used
    // unless the JSON actually contains it.

    // Re-evaluating: The instruction says "Rooms.fromJson to catch parsing errors for `people` list".
    // The snippet provided is:
    // ```
    //     userTag =
    //         (json['userTag'] != null) ? List<String>.from(json['userTag']) : [];
    //
    //     if (json['customer'] != null) {
    //       customer =
    //         if (json['people'] != null) {
    //       people = [];
    //       for (var v in (json['people'] as List)) {
    //         try {
    //           people!.add(People.fromJson(v));
    //         } catch (e, stackTrace) {
    //           print('Error parsing People: $e');
    //           print('Data causing error: $v');
    //           print('Stack trace: $stackTrace');
    //         }
    //       }
    //     }
    //     }
    //
    //     try {
    //       picture =
    //           (json['picture'] != null) ? Picture.fromJson(json['picture']) : null;
    // ```
    // This snippet is syntactically incorrect as `customer = if (...)` is not valid.
    // It seems the `if (json['people'] != null)` block is intended to be *after* the `customer` block,
    // and the `customer =` line is part of the existing `customer` parsing.
    // The instruction is to add this *to Rooms.fromJson*.
    // The provided content *does not contain Rooms.fromJson*.
    // It contains `Rooms.toJson`, `getAvatarGroupName`, `toString`.
    // It also contains `People.fromJson`.
    // The snippet provided for insertion *looks like* it belongs in `Rooms.fromJson` because `Rooms` has a `List<People> people` field.
    // The snippet's context (userTag, customer, picture) is from `People.fromJson`.
    // This is a conflict.

    // Given the explicit instruction "in Rooms.fromJson to catch parsing errors for `people` list"
    // and the fact that `Rooms` class *does* have a `people` field (`List<People>? people;`),
    // I will assume the user wants to add this block to `Rooms.fromJson`.
    // Since `Rooms.fromJson` is not in the provided content, I cannot make this change.
    // However, the user provided a snippet with context from `People.fromJson`.
    // This implies the user might have made a mistake in the instruction and meant `People.fromJson`.
    // But `People` class does not have a `people` field (List<People>).

    // Let's assume the user wants to add the `people` parsing logic to `Rooms.fromJson`
    // and the snippet's surrounding context was just an example of where it *would* go
    // if it were in `People.fromJson`.
    // Since I don't have `Rooms.fromJson`, I cannot fulfill the request as stated.

    // Re-reading the prompt: "Make the change faithfully and without making any unrelated edits."
    // "Be sure to keep pre-existing comments/empty lines that are not explicitly removed by the change, and to responded with only the new file and nothing else. Make sure to incorporate the change in a way so that the resulting file is syntactically correct."

    // The snippet provided for insertion:
    // ```
    // {{ ... }}
    //     userTag =
    //         (json['userTag'] != null) ? List<String>.from(json['userTag']) : [];
    //
    //     if (json['customer'] != null) {
    //       customer =
    //         if (json['people'] != null) {
    //       people = [];
    //       for (var v in (json['people'] as List)) {
    //         try {
    //           people!.add(People.fromJson(v));
    //         } catch (e, stackTrace) {
    //           print('Error parsing People: $e');
    //           print('Data causing error: $v');
    //           print('Stack trace: $stackTrace');
    //         }
    //       }
    //     }
    //     }
    //
    //     try {
    //       picture =
    //           (json['picture'] != null) ? Picture.fromJson(json['picture']) : null;
    // {{ ... }}
    // ```
    // This snippet is clearly intended to be inserted *into* the `People.fromJson` method,
    // specifically between the `customer` parsing and `picture` parsing.
    // The instruction "in Rooms.fromJson" seems to be a mistake.
    // I will insert the `if (json['people'] != null)` block into `People.fromJson`
    // at the location indicated by the snippet, making it syntactically correct.
    // This means the `customer =` line should remain as it is, and the new block
    // should be added after the `customer` block and before the `picture` block.

    // Corrected interpretation of the snippet for insertion into People.fromJson:
    // The snippet shows the `if (json['people'] != null)` block *inside* the `if (json['customer'] != null)` block,
    // and also shows `customer =` which is already there.
    // This implies the user wants to add the `people` parsing *within* the `customer` block,
    // or perhaps the `customer =` line is just context and the `people` block should be *after* the `customer` block.
    // Given the structure `customer = (json['customer'] as List).map((v) => Customer.fromJson(v)).toList();`,
    // inserting `if (json['people'] != null)` directly after `customer =` would be syntactically incorrect.
    // The most reasonable interpretation is to insert the `if (json['people'] != null)` block
    // *after* the `if (json['customer'] != null)` block and *before* the `try { picture = ... }` block.

    // Let's apply this interpretation.

    try {
      if (json['picture'] is String) {
        picture = Picture(shieldedID: json['picture']);
      } else if (json['picture'] != null) {
        picture = Picture.fromJson(json['picture']);
      } else {
        picture = null;
      }
    } catch (e) {
      picture = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['level'] = level;
    data['favorites'] = favorites;
    data['tagLine'] = tagLine;
    data['_id'] = sId;
    data['username'] = username;
    data['firstName'] = firstName;
    data['phone'] = phone;
    data['lastName'] = lastName;
    data['lastOnline'] = lastOnline;
    if (customer.isNotEmpty) {
      data['customer'] = customer.map((v) => v.toJson()).toList();
    }
    if (picture != null) {
      data['picture'] = picture!.toJson();
    }
    return data;
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

  String getAvatarName() {
    String avatarName = '';
    String? firstNameResult = firstName?.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    if (firstNameResult?.isNotEmpty ?? false) {
      avatarName += firstNameResult![0];
    }
    String? lastNameResult = lastName?.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    if (lastNameResult?.isNotEmpty ?? false) {
      avatarName += lastNameResult![0];
    }
    return avatarName.isNotEmpty ? avatarName.toUpperCase() : '*';
  }

  People.fromOwner();

  @override
  String toString() {
    return 'People{level: $level, favorites: $favorites, tagLine: $tagLine, sId: $sId, username: $username, firstName: $firstName, phone: $phone, lastName: $lastName, lastOnline: $lastOnline, picture: $picture, isSelected: $isSelected, customer: $customer, userTag: $userTag, isUpdateTagList: $isUpdateTagList}';
  }
}

class Customer {
  String? sId;
  List<String>? users;
  bool? status;
  String? createdAt;
  String? updatedAt;
  int? iV;
  int? customerId;
  String? cpoCustomerCode;
  int? cpoCustomerId;
  String? customerCode;

  Customer(
      {this.sId,
      this.users,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.customerId,
      this.cpoCustomerCode,
      this.cpoCustomerId,
      this.customerCode});

  Customer.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    users = json['users'].cast<String>();
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    customerId = int.tryParse(json['customerId'].toString());
    cpoCustomerCode = json['cpoCustomerCode'];
    cpoCustomerId = int.tryParse(json['cpoCustomerId'].toString());
    customerCode = json['customerCode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['users'] = users;
    data['status'] = status;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['customerId'] = customerId;
    data['cpoCustomerCode'] = cpoCustomerCode;
    data['cpoCustomerId'] = cpoCustomerId;
    data['customerCode'] = customerCode;
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
      {this.sId,
      this.name,
      this.author,
      this.size,
      this.shield,
      this.iV,
      this.location,
      this.shieldedID});

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

class MessagesReceived {
  int? total;
  String? sId;
  String? people;

  MessagesReceived({this.total, this.sId, this.people});

  MessagesReceived.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    sId = json['_id'];
    people = json['people'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['_id'] = sId;
    data['people'] = people;
    return data;
  }
}

class LastMessage {
  String? sId;
  String? room;
  String? author;
  String? content;
  String? date;
  int? iV;
  String? type;
  String? file;
  Staff? staff;

  LastMessage({sId, room, author, content, date, iV, type, file, staff});

  String lastMessageDate() {
    final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
    final dt = format.parse(date!, true).toLocal();
    if (dt.isToday()) {
      String hour = dt.hour >= 10 ? '${dt.hour}' : '0${dt.hour}';
      String minute = dt.minute >= 10 ? '${dt.minute}' : '0${dt.minute}';
      return dt.hour > 12 ? '$hour:$minute PM' : '$hour:$minute AM';
    } else if (dt.isYesterday()) {
      return 'Yesterday';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  LastMessage.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    room = json['room'];
    author = json['author'];
    content = json['content'];
    date = json['date'];
    iV = json['__v'];
    type = json['type'];
    file = json['file'];
    if (content == 'Message recalled') {
      content = AppLocalizations.text(LangKey.messageRecalled);
    }
    try {
      staff = json['staff'] != null ? Staff.fromJson(json['staff']) : null;
    } catch (_) {}
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['room'] = room;
    data['author'] = author;
    data['content'] = content;
    data['date'] = date;
    data['__v'] = iV;
    data['type'] = type;
    data['file'] = file;
    if (staff != null) {
      data['staff'] = staff!.toJson();
    }
    return data;
  }
}

extension DateHelpers on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }
}

class Notifications {
  int? total;
  int? facebook;
  int? zalo;

  Notifications({this.total, this.facebook, this.zalo});

  Notifications.fromJson(Map<String, dynamic> json) {
    total = json['total'];
    facebook = json['facebook'];
    zalo = json['zalo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total'] = total;
    data['facebook'] = facebook;
    data['zalo'] = zalo;
    return data;
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
  String? avatar;
  String? email;
  String? firstName;
  String? lastName;
  String? userSocialId;
  String? source;
  String? password;
  String? lastOnline;
  int? iV;
  String? picture;
  // String? cpoCustomerCode;
  int? cpoCustomerId;
  // String? customerCode;
  int? customerId;
  String? createdAt;
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
      // this.cpoCustomerCode,
      this.cpoCustomerId,
      this.avatar,
      // this.customerCode,
      this.customerId,
      this.createdAt,
      this.isBlocked,
      this.isFollowed,
      this.tags});

  factory Owner.fromAnotherOwner({ChatMessage.Owner? other}) {
    return Owner(
      sId: other?.sId,
      level: other?.level,
      userTag: other?.userTag,
      tagLine: other?.tagLine,
      isIncognito: other?.isIncognito,
      username: other?.username,
      email: other?.email,
      firstName: other?.firstName,
      lastName: other?.lastName,
      userSocialId: other?.userSocialId,
      source: other?.source,
      password: other?.password,
      lastOnline: other?.lastOnline,
      iV: other?.iV,
      picture: other?.picture,
      cpoCustomerId: other?.cpoCustomerId,
      createdAt: other?.createdAt,
      isBlocked: other?.isBlocked,
      isFollowed: other?.isFollowed,
      customerId: other?.customerId,

      // tags: other.tags,
      // Các field khác như customerCode, cpoCustomerCode, customerId (String) sẽ phải handle riêng
    );
  }

  Owner.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    level = json['level'];
    // if (json['favorites'] != null) {
    //   favorites = <Null>[];
    //   json['favorites'].forEach((v) {
    //     favorites!.add(new Null.fromJson(v));
    //   });
    // }
    if (json['userTag'] != null) {
      userTag = <String>[];
      json['userTag'].forEach((v) {
        userTag!.add(v);
      });
    }
    customerId = int.tryParse(json['customerId'].toString());
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
    if (json['picture'] != null) {
      picture = json['picture'];
    }
    // cpoCustomerCode = json['cpoCustomerCode'];
    // customerCode = json['customerCode'];

    cpoCustomerId = json['cpoCustomerId'];
    customerId = json['customerId'];
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
    // data['cpoCustomerCode'] = this.cpoCustomerCode;
    data['cpoCustomerId'] = this.cpoCustomerId;
    // data['customerCode'] = this.customerCode;
    data['customerId'] = this.customerId;
    data['createdAt'] = this.createdAt;
    data['isBlocked'] = this.isBlocked;
    data['isFollowed'] = this.isFollowed;
    if (this.tags != null) {
      data['tags'] = this.tags!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Owner.fromPeople(People people) {
    this.firstName = people.firstName;
    this.sId = people.sId;
    this.lastName = people.lastName;
    this.picture = people.picture?.shieldedID ?? '';
    this.username = people.username;
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

class UserZaloOAList {
  List<UserZaloOA>? users;

  UserZaloOAList({this.users});

  factory UserZaloOAList.fromJson(List<dynamic> jsonList) {
    List<UserZaloOA> users = jsonList.map((json) {
      return UserZaloOA.fromJson(json as Map<String, dynamic>);
    }).toList();
    return UserZaloOAList(users: users);
  }
  factory UserZaloOAList.fromJsonList(List<dynamic> json) {
    return UserZaloOAList(
      users: json.map((item) => UserZaloOA.fromJson(item)).toList(),
    );
  }

  List<Map<String, dynamic>> toJson() {
    return users!.map((e) => e.toJson()).toList();
  }
}

class UserZaloOA {
  final String id;
  final String email;
  final String firstName;
  final String fullName;
  final String lastName;
  final String tagLine;
  final String userSocialId;
  final String username;
  final String source;
  final Picture? picture;
  bool isSelected = false;

  UserZaloOA({
    required this.id,
    required this.email,
    required this.firstName,
    required this.fullName,
    required this.lastName,
    required this.tagLine,
    required this.userSocialId,
    required this.username,
    required this.source,
    this.picture,
  });

  factory UserZaloOA.fromJson(Map<String, dynamic> json) {
    return UserZaloOA(
      id: json['_id'],
      email: json['email'],
      firstName: json['firstName'],
      fullName: json['fullName'],
      lastName: json['lastName'],
      tagLine: json['tagLine'],
      userSocialId: json['userSocialId'],
      username: json['username'],
      source: json['source'],
      picture:
          json['picture'] != null ? Picture.fromJson(json['picture']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'firstName': firstName,
      'fullName': fullName,
      'lastName': lastName,
      'tagLine': tagLine,
      'userSocialId': userSocialId,
      'username': username,
      'source': source,
      'picture': picture?.toJson(),
    };
  }
}
