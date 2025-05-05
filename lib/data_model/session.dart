class AiTag {
  final String type;
  final String tag;

  AiTag({required this.type, required this.tag});

  factory AiTag.fromJson(Map<String, dynamic> json) {
    return AiTag(
      type: json['type'],
      tag: json['tag'],
    );
  }
}

class StaffInfo {
  final int staffId;
  final int branchId;
  final String userName;
  final String fullName;
  final String? email;
  final String? staffAvatar;
  final String address;

  StaffInfo({
    required this.staffId,
    required this.branchId,
    required this.userName,
    required this.fullName,
    this.email,
    this.staffAvatar,
    required this.address,
  });

  factory StaffInfo.fromJson(Map<String, dynamic> json) {
    return StaffInfo(
      staffId: json['staff_id'],
      branchId: json['branch_id'],
      userName: json['user_name'],
      fullName: json['full_name'],
      email: json['email'],
      staffAvatar: json['staff_avatar'],
      address: json['address'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'branch_id': branchId,
      'user_name': userName,
      'full_name': fullName,
      'email': email,
      'staff_avatar': staffAvatar,
      'address': address,
    };
  }
}

class SessionModel {
  final String? id;
  final String? sessionId;
  final String? channel;
  final String? room;
  final String? owner;
  final String? status;
  final String? closedBy;
  final List<String>? messageIds;
  final int? sessionTimeout;
  final List<AiTag>? aiTags;
  final String? startTime;
  final String? lastMessageTime;
  final String? createdAt;
  final String? updatedAt;
  final int? v;
  final String? sessionTitle;
  final String? summary;
  final String? summaryBy;
  final String? closed_at;
  final String? summary_by_staff;
  final StaffInfo? summaryByStaff;

  SessionModel(
      {this.id,
      this.sessionId,
      this.channel,
      this.room,
      this.owner,
      this.status,
      this.closedBy,
      this.messageIds,
      this.sessionTimeout,
      this.aiTags,
      this.startTime,
      this.lastMessageTime,
      this.createdAt,
      this.updatedAt,
      this.v,
      this.sessionTitle,
      this.summary,
      this.summaryBy,
      this.summaryByStaff,
      this.closed_at,
      this.summary_by_staff});

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['_id'],
      sessionId: json['session_id'],
      channel: json['channel'],
      room: json['room'],
      owner: json['owner'],
      status: json['status'],
      closedBy: json['closed_by'],
      messageIds: List<String>.from(json['messages']),
      sessionTimeout: json['session_timeout'],
      aiTags: (json['ai_tags'] as List).map((e) => AiTag.fromJson(e)).toList(),
      startTime: (json['start_time']),
      lastMessageTime: (json['last_message_time']),
      createdAt: (json['created_at']),
      updatedAt: (json['updated_at']),
      v: json['__v'],
      sessionTitle: json['session_title'],
      summary: json['summary'],
      summaryBy: json['summary_by'],
      summaryByStaff: json['summary_by_staff'] != null
          ? StaffInfo.fromJson(json['summary_by_staff'])
          : null,
      closed_at: json['closed_at'],
    );
  }
}
