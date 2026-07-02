class FriendListResponse {
  List<FriendModel>? friends;

  FriendListResponse({this.friends});

  factory FriendListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] ?? [];
    return FriendListResponse(
      friends: dataList.map((e) => FriendModel.fromJson(e)).toList(),
    );
  }
}

class FriendModel {
  final String userId;
  final String username;
  final String displayName;
  final String zaloName;
  final String avatar;
  final String bgavatar;
  final String cover;
  final int gender;
  final int dob;
  final String sdob;
  final String status;
  final String phoneNumber;
  final int isFr;
  final int isBlocked;
  final int lastActionTime;
  final int lastUpdateTime;
  final int isActive;
  final int key;
  final int type;
  final int isActivePC;
  final int isActiveWeb;
  final int isValid;
  final String userKey;
  final int accountStatus;
  final int userMode;
  final String globalId;
  final int createdTs;
  final int? oaStatus;
  final BizPkg? bizPkg;
  bool? isSelected = false;

  FriendModel(
      {required this.userId,
      required this.username,
      required this.displayName,
      required this.zaloName,
      required this.avatar,
      required this.bgavatar,
      required this.cover,
      required this.gender,
      required this.dob,
      required this.sdob,
      required this.status,
      required this.phoneNumber,
      required this.isFr,
      required this.isBlocked,
      required this.lastActionTime,
      required this.lastUpdateTime,
      required this.isActive,
      required this.key,
      required this.type,
      required this.isActivePC,
      required this.isActiveWeb,
      required this.isValid,
      required this.userKey,
      required this.accountStatus,
      required this.userMode,
      required this.globalId,
      required this.createdTs,
      required this.oaStatus,
      required this.bizPkg,
      this.isSelected});

  factory FriendModel.fromJson(Map<String, dynamic> json) {
    return FriendModel(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      zaloName: json['zaloName'] ?? '',
      avatar: json['avatar'] ?? '',
      bgavatar: json['bgavatar'] ?? '',
      cover: json['cover'] ?? '',
      gender: json['gender'] ?? 0,
      dob: json['dob'] ?? 0,
      sdob: json['sdob'] ?? '',
      status: json['status'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      isFr: json['isFr'] ?? 0,
      isBlocked: json['isBlocked'] ?? 0,
      lastActionTime: json['lastActionTime'] ?? 0,
      lastUpdateTime: json['lastUpdateTime'] ?? 0,
      isActive: json['isActive'] ?? 0,
      key: json['key'] ?? 0,
      type: json['type'] ?? 0,
      isActivePC: json['isActivePC'] ?? 0,
      isActiveWeb: json['isActiveWeb'] ?? 0,
      isValid: json['isValid'] ?? 0,
      userKey: json['userKey'] ?? '',
      accountStatus: json['accountStatus'] ?? 0,
      userMode: json['user_mode'] ?? 0,
      globalId: json['globalId'] ?? '',
      createdTs: json['createdTs'] ?? 0,
      oaStatus: json['oa_status'],
      bizPkg: json['bizPkg'] != null ? BizPkg.fromJson(json['bizPkg']) : null,
    );
  }
}

class BizPkg {
  final String? label;
  final int pkgId;

  BizPkg({
    required this.label,
    required this.pkgId,
  });

  factory BizPkg.fromJson(Map<String, dynamic> json) {
    return BizPkg(
      label:
          json['label'] is String ? json['label'] : json['label']?.toString(),
      pkgId: json['pkgId'] ?? 0,
    );
  }
}
