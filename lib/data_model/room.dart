import 'package:intl/intl.dart';

class Room {
  int? limit;
  List<Rooms>? rooms;

  Room({limit, rooms});

  Room.fromJson(Map<String, dynamic> json ,{bool isFavorite = false}) {
    limit = json['limit'];
    if (json[!isFavorite ? 'rooms' : 'favorites'] != null) {
      rooms = <Rooms>[];
      json[!isFavorite ? 'rooms' : 'favorites'].forEach((v) {
        rooms!.add(Rooms.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson({bool isFavorite = false}) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['limit'] = limit;
    if (rooms != null) {
      data[!isFavorite ? 'rooms' : 'favorites'] = rooms!.map((v) => v.toJson()).toList();
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
  String? owner;
  LastMessage? lastMessage;
  String? lastUpdate;
  Picture? picture;
  List<MessagesReceived>? messagesReceived;

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
        messagesReceived,});

  Rooms.fromJson(Map<String, dynamic> json) {
    if (json['people'] != null) {
      people = <People>[];
      json['people'].forEach((v) {
        people!.add(People.fromJson(v));
      });
    }
    isGroup = json['isGroup'];
    sId = json['_id'];
    title = json['title'];
    iV = json['__v'];
    lastAuthor = json['lastAuthor'];
    owner = json['owner'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (people != null) {
      data['people'] = people!.map((v) => v.toJson()).toList();
    }
    data['isGroup'] = isGroup;
    data['_id'] = sId;
    data['title'] = title;
    data['__v'] = iV;
    data['lastAuthor'] = lastAuthor;
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
    return avatarName;
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
        picture});

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
    if(firstName != '' && firstName != null) {
      avatarName += firstName![0];
    }
    if(lastName != '' && lastName != null) {
      avatarName += lastName![0];
    }
    return avatarName;
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