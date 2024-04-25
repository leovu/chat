import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:intl/intl.dart';

class Room {
  int? limit;
  List<Rooms>? rooms;
  Notifications? notifications;

  Room({limit, rooms});

  Room.fromJson(Map<String, dynamic> json ,{bool isFavorite = false}) {
    limit = json['limit'];
    if (json[!isFavorite ? 'rooms' : 'favorites'] != null) {
      rooms = <Rooms>[];
      json[!isFavorite ? 'rooms' : 'favorites'].forEach((v) {
        print(v);
        rooms!.add(Rooms.fromJson(v));
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
      data[!isFavorite ? 'rooms' : 'favorites'] = rooms!.map((v) => v.toJson()).toList();
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
  Picture? picture;
  List<MessagesReceived>? messagesReceived;
  String? createdAt;
  String? source;
  int? messageUnSeen;
  Channel? channel;
  String? shieldedID;

  Rooms(
      {people,
        isGroup,
        sId,
        title,
        iV,
        lastAuthor,
        lastMessage,
        lastUpdate,
        owner,
        messagesReceived,
        createdAt,
        source,
        messageUnSeen,
        channel, shieldedID});

  Rooms.fromJson(Map<String, dynamic> json) {
    if (json['people'] != null) {
      people = <People>[];
      json['people'].forEach((v) {
        people!.add(People.fromJson(v));
      });
    }
    isGroup = json['isGroup'];
    source = json['source'];
    channel = json['channel'] != null ? Channel.fromJson(json['channel']) : null;
    sId = json['_id'];
    title = json['title'];
    createdAt = json['createdAt'];
    iV = json['__v'];
    lastAuthor = json['lastAuthor'];
    try{
      owner = json['owner'] != null
          ? Owner.fromJson(json['owner'])
          : null;
    }catch(_){}
    messageUnSeen = json['messageUnSeen'];
    try{
      lastMessage = json['lastMessage'] != null
          ? LastMessage.fromJson(json['lastMessage'])
          : null;
    }catch(_){}
    if (json['messagesReceived'] != null) {
      messagesReceived = <MessagesReceived>[];
      json['messagesReceived'].forEach((v) {
        messagesReceived!.add(MessagesReceived.fromJson(v));
      });
    }
    lastUpdate = json['lastUpdate'];
    try {
      picture =
      json['picture'] != null ? Picture.fromJson(json['picture']) : null;
    }catch(_) {}
    shieldedID = json['shieldedID'];
  }

  String createdDate() {
    if(createdAt == null) return '';
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
    data['picture'] = picture;
    data['owner'] = owner;
    data['messageUnSeen'] = messageUnSeen;
    return data;
  }

  String getAvatarGroupName() {
    String avatarName = '';
    try{
      if(title != '' && title != null) {
        List<String> _arr = title!.split(' ');
        if(_arr.length > 1) {
          avatarName += _arr[0][0];
          avatarName += _arr[1][0];
        }
        else {
          avatarName += title![0];
          avatarName += title![1];
        }
      }
    }catch(_){}
    return avatarName == '' ? '*' : avatarName.toUpperCase();
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
  int? iV;

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
        this.iV});

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
    return data;
  }
}


class People {
  String? level;
  List<String>? favorites;
  String? tagLine;
  String? sId;
  String? username;
  String? firstName;
  String? phone;
  String? lastName;
  String? lastOnline;
  Picture? picture;
  bool? isSelected;
  List<Customer>? customer;
  List<String>? userTag;
  bool isUpdateTagList = false;

  People(
      {level,
        favorites,
        tagLine,
        sId,
        username,
        firstName,
        phone,
        lastName,
        lastOnline,
        customer,
        picture,
        userTag});

  People.fromJson(Map<String, dynamic> json) {
    level = json['level'];
    if(json['favorites'] != null) {
      favorites = json['favorites'].cast<String>();
    }
    tagLine = json['tagLine'];
    sId = json['_id'];
    username = json['username'];
    firstName = json['firstName'];
    phone = json['phone'];
    lastName = json['lastName'];
    lastOnline = json['lastOnline'];
    if (json['userTag'] != null) {
      userTag = <String>[];
      json['userTag'].forEach((v) {
        userTag!.add(v);
      });
    }
    if (json['customer'] != null) {
      customer = <Customer>[];
      json['customer'].forEach((v) {
        customer!.add(Customer.fromJson(v));
      });
    }
    try{
      picture = json['picture'] != null ? Picture.fromJson(json['picture']) : null;
    }catch(_){}
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['level'] = level;
    data['favorites'] = favorites;
    data['tagLine'] = tagLine;
    data['_id'] = sId;
    data['username'] = username;
    data['firstName'] = firstName;
    data['phone'] = phone;
    data['lastName'] = lastName;
    data['lastOnline'] = lastOnline;
    if (customer != null) {
      data['customer'] = customer!.map((v) => v.toJson()).toList();
    }
    if (picture != null) {
      data['picture'] = picture!.toJson();
    }
    return data;
  }

  String getName(){
    List<String> names = [];
    if((firstName ?? "").isNotEmpty) {
      names.add(firstName!);
    }
    if((lastName ?? "").isNotEmpty) {
      names.add(lastName!);
    }
    return names.join(" ");
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

  LastMessage(
      {sId,
        room,
        author,
        content,
        date,
        iV,
        type,
        file});

  String lastMessageDate() {
    final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z");
    final dt = format.parse(date!, true).toLocal();
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


  LastMessage.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    room = json['room'];
    author = json['author'];
    content = json['content'];
    date = json['date'];
    iV = json['__v'];
    type = json['type'];
    file = json['file'];
    if(content == 'Message recalled') {
      content = AppLocalizations.text(LangKey.messageRecalled);
    }
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
    return data;
  }
}

extension DateHelpers on DateTime {
  bool isToday() {
    final now = DateTime.now();
    return now.day == day &&
        now.month == month &&
        now.year == year;
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
  String? customerId;
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
        this.cpoCustomerCode,
        this.cpoCustomerId,
        this.customerCode,
        this.customerId,
        this.createdAt,
        this.isBlocked,
        this.isFollowed,
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
    customerId = json['customerId'] ?? '';
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
    if(firstNameResult != '' && firstNameResult != null) {
      avatarName += firstNameResult[0];
    }
    String? lastNameResult = lastName?.replaceAll(RegExp('[^A-Za-z0-9]'), '');
    if(lastNameResult != '' && lastNameResult != null) {
      avatarName += lastNameResult[0];
    }
    return avatarName == '' ? '*' : avatarName.toUpperCase();
  }

  String getName(){
    List<String> names = [];
    if((firstName ?? "").isNotEmpty) {
      names.add(firstName!);
    }
    if((lastName ?? "").isNotEmpty) {
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