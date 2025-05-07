class GroupInfoResponseZP {
  final RoomGroupInfo? room;
  final GroupInfo? groupInfo;
  final List<MemberZP>? members;

  GroupInfoResponseZP({this.room, this.groupInfo, this.members});

  factory GroupInfoResponseZP.fromJson(Map<String, dynamic> json) {
    return GroupInfoResponseZP(
      room: json['room'] != null ? RoomGroupInfo.fromJson(json['room']) : null,
      groupInfo: json['group_info'] != null
          ? GroupInfo.fromJson(json['group_info'])
          : null,
      members:
          (json['members'] as List?)?.map((e) => MemberZP.fromJson(e)).toList(),
    );
  }
}

class RoomGroupInfo {
  final String? id;
  final String? roomName;
  final String? description;
  final String? source;
  final List<String>? people;
  final bool? isGroup;
  final int? enableBot;
  final String? sessionStatus;
  final String? channel;
  final String? avatar;
  final String? owner;

  RoomGroupInfo({
    this.id,
    this.roomName,
    this.description,
    this.source,
    this.people,
    this.isGroup,
    this.enableBot,
    this.sessionStatus,
    this.channel,
    this.avatar,
    this.owner,
  });

  factory RoomGroupInfo.fromJson(Map<String, dynamic> json) {
    return RoomGroupInfo(
      id: json['_id'],
      roomName: json['room_name'],
      description: json['room_description'],
      source: json['source'],
      people: (json['people'] as List?)?.cast<String>(),
      isGroup: json['isGroup'],
      enableBot: json['enable_bot'],
      sessionStatus: json['session_status'],
      channel: json['channel'],
      avatar: json['room_avatar'],
      owner: json['owner'],
    );
  }
}

class GroupInfo {
  final String? groupId;
  final String? name;
  final String? desc;
  final int? type;
  final String? creatorId;
  final List<String>? memVerList;
  final int? totalMember;
  final int? maxMember;
  final GroupSetting? setting;

  GroupInfo({
    this.groupId,
    this.name,
    this.desc,
    this.type,
    this.creatorId,
    this.memVerList,
    this.totalMember,
    this.maxMember,
    this.setting,
  });

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    return GroupInfo(
      groupId: json['groupId'],
      name: json['name'],
      desc: json['desc'],
      type: json['type'],
      creatorId: json['creatorId'],
      memVerList: (json['memVerList'] as List?)?.cast<String>(),
      totalMember: json['totalMember'],
      maxMember: json['maxMember'],
      setting: json['setting'] != null
          ? GroupSetting.fromJson(json['setting'])
          : null,
    );
  }
}

class GroupSetting {
  final int? blockName;
  final int? signAdminMsg;

  GroupSetting({
    this.blockName,
    this.signAdminMsg,
  });

  factory GroupSetting.fromJson(Map<String, dynamic> json) {
    return GroupSetting(
      blockName: json['blockName'],
      signAdminMsg: json['signAdminMsg'],
    );
  }
}

class MemberZP {
  final String? id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatar;
  final String? level;
  final String? userSocialId;
  final List<String>? detectPhones;

  MemberZP({
    this.id,
    this.username,
    this.firstName,
    this.lastName,
    this.phone,
    this.avatar,
    this.level,
    this.userSocialId,
    this.detectPhones,
  });

  factory MemberZP.fromJson(Map<String, dynamic> json) {
    return MemberZP(
      id: json['_id'],
      username: json['username'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      avatar: json['avatar'],
      level: json['level'],
      userSocialId: json['userSocialId'],
      detectPhones: (json['detect_phones'] as List?)?.cast<String>(),
    );
  }
}
