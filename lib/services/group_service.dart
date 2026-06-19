import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/response/base_response_model.dart';
import 'package:chat/data_model/response/friend_response_model.dart';
import 'package:chat/data_model/response/group_info_response.dart';
import 'package:chat/data_model/response/group_member_response_model.dart';
import 'package:chat/data_model/response/quota_response_model.dart';
import 'package:chat/data_model/room.dart' as r;

class GroupService {
  static Future<bool> addMemberGroup(HTTPConnection connection, List<String> people, String roomId) async {
    final responseData = await connection.post('api/group/update', {'data': people, 'type': 'add-people', 'roomId': roomId});
    return responseData.isSuccess;
  }

  static Future<ResponseData> addUserGroup(HTTPConnection connection, List<String> memberUserIds, String channelId, String groupId) async {
    return await connection.post('api/zalo-personal/add-user-group', {
      'member_user_ids': memberUserIds,
      'channel_id': channelId,
      'group_id': groupId,
    });
  }

  static Future<MemberListData?> getMemberInfo(HTTPConnection connection, String channelId, String roomId, {int? limit = 10, int? offset = 0}) async {
    try {
      final response = await connection.post('api/group/get-members', {
        'channel_id': channelId, 'room_id': roomId, 'limit': limit, 'offset': offset,
      }, isJoinByNumberPhone: true);
      final base = BaseResponse<MemberListData>.fromJson(response.data, (json) => MemberListData.fromJson(json));
      if (base.error == 0 && base.data != null) return base.data;
    } catch (_) {}
    return null;
  }

  static Future<MemberListData?> getMemberPendingInvite(HTTPConnection connection, String channelId, String groupId) async {
    try {
      final response = await connection.post('api/group/list-pending-invite', {
        'channel_id': channelId, 'group_id': groupId,
      }, isJoinByNumberPhone: true);
      final base = BaseResponse<MemberListData>.fromJson(response.data, (json) => MemberListData.fromJson(json));
      if (base.error == 0 && base.data != null) return base.data;
    } catch (_) {}
    return null;
  }

  static Future<GroupInfoResponseZP?> getGroupInfo(HTTPConnection connection, String channelId, String groupId, {required void Function(String?) onCreatorId}) async {
    try {
      final response = await connection.post('api/zalo-personal/get-group-info', {'channel_id': channelId, 'group_id': groupId});
      final base = BaseResponse<GroupInfoResponseZP>.fromJson(response.data, (json) => GroupInfoResponseZP.fromJson(json));
      if (base.error == 0 && base.data != null) {
        onCreatorId(base.data!.groupInfo?.creatorId);
        return base.data;
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> removeUserGroup(HTTPConnection connection, String channelId, String groupId, String memberUserId) async {
    try {
      final response = await connection.post('api/zalo-personal/remove-user-group', {
        'channel_id': channelId, 'group_id': groupId, 'member_user_id': memberUserId,
      });
      return response.isSuccess;
    } catch (_) {
      return false;
    }
  }

  static Future<ResponseData?> removeMember(HTTPConnection connection, String channelId, String groupId, List<String> memberUserIds) async {
    try {
      return await connection.post('api/group/remove-member', {
        'channel_id': channelId, 'group_id': groupId, 'member_user_ids': memberUserIds,
      });
    } catch (_) {}
    return null;
  }

  static Future<FriendListResponse?> getListFriend(HTTPConnection connection, String channelId) async {
    try {
      final response = await connection.post('api/zalo-personal/get-friends', {'channel_id': channelId});
      return FriendListResponse.fromJson(response.data);
    } catch (e, s) {
      print("ERROR in getListFriend: $e");
      print(s);
      return null;
    }
  }

  static Future<r.UserZaloOAList?> getListUserZaloOA(HTTPConnection connection, {String source = 'zalo', String? search}) async {
    try {
      final userListJson = await connection.postReturnList('api/user/list', {'search': search, 'source': source});
      if (userListJson.isNotEmpty) return r.UserZaloOAList.fromJsonList(userListJson);
    } catch (_) {}
    return null;
  }

  static Future<ResponseData?> inviteMember(HTTPConnection connection, String? groupId, List<String> memberUserIds, String channelId) async {
    try {
      return await connection.post('api/group/invite-member', {
        'channel_id': channelId, 'group_id': groupId, 'member_user_ids': memberUserIds,
      });
    } catch (_) {}
    return null;
  }

  static Future<bool?> updateUserInfo(HTTPConnection connection, String userId, String name, String phone) async {
    try {
      final response = await connection.post('api/user/update-info', {
        'user_id': userId,
        'params': {'firstName': name, 'phone': phone},
      });
      return response.isSuccess;
    } catch (_) {
      return false;
    }
  }

  static Future<ResponseData?> acceptPendingInvite(HTTPConnection connection, String chanelId, String groupId, List<String> memberUserIds) async {
    try {
      return await connection.post('api/group/accept-pending-invite', {
        'channel_id': chanelId, 'group_id': groupId, 'member_user_ids': memberUserIds,
      });
    } catch (_) {}
    return null;
  }

  static Future<ResponseData?> rejectPendingInvite(HTTPConnection connection, String chanelId, String groupId, List<String> memberUserIds) async {
    try {
      return await connection.post('api/group/reject-pending-invite', {
        'channel_id': chanelId, 'group_id': groupId, 'member_user_ids': memberUserIds,
      });
    } catch (_) {}
    return null;
  }

  static Future<ResponseData?> getContactWhatsapp(HTTPConnection connection, String phone) async {
    try {
      return await connection.post('api/whatsapp/get-contacts', {'phone': phone});
    } catch (_) {}
    return null;
  }

  static Future<QuotaResponseModel?> getQuota(HTTPConnection connection, String socialChannelId, String userSocialId) async {
    final responseData = await connection.post('api/zalo/get-quota', {
      'social_channel_id': socialChannelId, 'user_social_id': userSocialId,
    });
    if (responseData.isSuccess) return QuotaResponseModel.fromJson(responseData.data);
    return null;
  }

  static Future<bool> sendTransaction(HTTPConnection connection, String channelId, String type, String userSocialId) async {
    final responseData = await connection.post('api/zalo/send-transaction', {
      'channel_id': channelId, 'type': type, 'user_social_id': userSocialId,
    });
    return responseData.isSuccess;
  }
}
