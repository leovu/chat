class MemberZ {
  final String? id;
  final String? oaId;
  final String? name;
  final String? avatar;

  MemberZ({this.id, this.oaId, this.name, this.avatar});

  factory MemberZ.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MemberZ();

    return MemberZ(
      id: json['user_id'] as String?,
      oaId: json['oa_id'] as String?,
      name: json['name'] as String?,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'oa_id': oaId,
      'name': name,
      'avatar': avatar,
    };
  }
}

class MemberListData {
  final int? offset;
  final int? count;
  final int? total;
  final int? memberCount;
  final List<MemberZ>? members;

  MemberListData({
    this.offset,
    this.count,
    this.total,
    this.memberCount,
    this.members,
  });

  factory MemberListData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MemberListData();

    return MemberListData(
      offset: json['offset'] as int?,
      count: json['count'] as int?,
      total: json['total'] as int?,
      memberCount: json['member_count'] as int?,
      members: (json['members'] as List<dynamic>?)
          ?.map((e) => MemberZ.fromJson(e as Map<String, dynamic>?))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offset': offset,
      'count': count,
      'total': total,
      'member_count': memberCount,
      'members': members?.map((e) => e.toJson()).toList(),
    };
  }
}
