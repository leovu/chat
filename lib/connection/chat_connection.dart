import 'dart:io';

import 'package:chat/connection/http_connection.dart';
import 'package:chat/connection/socket.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/chathub_channel.dart';
import 'package:chat/data_model/contact.dart' as ct;
import 'package:chat/data_model/customer_account.dart';
import 'package:chat/data_model/notifications.dart' as n;
import 'package:chat/data_model/response/check_user_token_response_model.dart';
import 'package:chat/data_model/response/friend_response_model.dart';
import 'package:chat/data_model/response/group_info_response.dart';
import 'package:chat/data_model/response/group_member_response_model.dart';
import 'package:chat/data_model/response/notes_response_model.dart';
import 'package:chat/data_model/response/quota_response_model.dart';
import 'package:chat/data_model/response/room_info_response_model.dart';
import 'package:chat/data_model/room.dart' as r;
import 'package:chat/data_model/session.dart';
import 'package:chat/data_model/summary.dart';
import 'package:chat/data_model/tag.dart';
import 'package:chat/data_model/user.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/chathub_service.dart';
import 'package:chat/services/customer_service.dart';
import 'package:chat/services/group_service.dart';
import 'package:chat/services/media_service.dart';
import 'package:chat/services/message_service.dart';
import 'package:chat/services/notes_service.dart';
import 'package:chat/services/notification_service.dart';
import 'package:chat/services/room_service.dart';
import 'package:chat/services/tag_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import '../data_model/response/base_response_model.dart';

class ChatConnection {
  // ── State ────────────────────────────────────────────────────────────────
  static late void Function() refreshRoom;
  static late Locale locale;
  static late void Function() refreshContact;
  static late void Function() refreshFavorites;
  static late void Function() refreshNotifications;
  static StreamSocket streamSocket = StreamSocket();
  static HTTPConnection connection = HTTPConnection();
  static late String appIcon;
  static String? roomId;
  static bool isChatHub = false;
  static User? user;
  static CheckUserTokenResponseModel? checkUserTokenResponseModel;
  static String? brandCode;
  static late BuildContext buildContext;
  static List<Map<String, dynamic>>? addOnModules;
  static bool isLoadMore = false;
  static Map<String, dynamic>? initialData;
  static late Function(Map<String, dynamic> message)
      homeScreenNotificationHandler;
  static late Function(Map<String, dynamic> message)
      chatScreenNotificationHandler;
  static ValueNotifier<String> notificationNotifier = ValueNotifier('0');
  static Function? searchProducts;
  static Function? searchOrders;
  static Function? createOrder;
  static Function? createAppointment;
  static Function? createDeal;
  static Function? createTask;
  static Function? addCustomer;
  static Function? addCustomerPotential;
  static Function? viewProfileChatHub;
  static Function? editCustomerLead;
  static int? notiChatHubAll;
  static int? notiChatHubClient;
  static int? notiChatHubFacebook;
  static int? notiChatHubZalo;
  static int? notiChatHubZaloPersonal;
  static int? notiChatHubWhatsApp;
  static Function? openChatGPT;
  static String? uid;
  static String? creatorIdGroup;
  static String? ownerId;

  // ── Auth ─────────────────────────────────────────────────────────────────
  static Future<bool> init(String email, String password, {String? token}) =>
      AuthService.init(connection, streamSocket, email, password,
          token: token,
          onUserReady: (u) => user = u,
          onUidReady: (id) => uid = id);

  static Future<String?> login(String email, String password) =>
      AuthService.login(connection, email, password);

  static Future<String?> token(String email, String password) =>
      AuthService.token(connection, email, password);

  static Future<bool> register(String username, String email, String firstName,
          String lastName, String password, String repeatPassword) =>
      AuthService.register(connection, username, email, firstName, lastName,
          password, repeatPassword);

  static Future<bool> checkUserToken() => AuthService.checkUserToken(
        connection,
        user!,
        brandCode,
        onResult: (m) => checkUserTokenResponseModel = m,
        onUserUpdated: (u) => user = u,
      );

  static bool checkConnected() => AuthService.checkConnected(streamSocket);

  static void reconnect() => AuthService.reconnect(streamSocket);

  static void reAuthenticate() =>
      AuthService.reAuthenticate(streamSocket, user);

  static dispose({bool isDispose = false}) =>
      AuthService.dispose(streamSocket, isDispose: isDispose);

  // ── Room ─────────────────────────────────────────────────────────────────
  static Future<r.Rooms?> createRoom(String? counterpart) =>
      RoomService.createRoom(connection, counterpart);

  static Future<r.Room?> roomList({
    String? source,
    String? channelId,
    String? status,
    List<String?>? tagIds,
    int page = 1,
    r.Room? roomData,
    String? link_status,
    String? startDate,
    String? endDate,
    bool? isGroup,
    String? keyword,
  }) =>
      RoomService.roomList(connection,
          isChatHub: isChatHub,
          source: source,
          channelId: channelId,
          status: status,
          tagIds: tagIds,
          page: page,
          roomData: roomData,
          link_status: link_status,
          startDate: startDate,
          endDate: endDate,
          isGroup: isGroup,
          keyword: keyword);

  static Future<r.Room?> favoritesList() =>
      RoomService.favoritesList(connection);

  static Future<c.ChatMessage?> joinRoom(String id, {bool refresh = false}) =>
      RoomService.joinRoom(connection, streamSocket,
          isChatHub: isChatHub, id: id, refresh: refresh);

  static Future<bool> autoUpdateChatSeenWhenJoinRoom(String id) =>
      RoomService.autoUpdateChatSeenWhenJoinRoom(connection, id);

  static Future<bool> toggleFavorites(String? roomId) =>
      RoomService.toggleFavorites(connection, roomId);

  static Future<bool> updateRoomName(String roomId, String data) =>
      RoomService.updateRoomName(connection, roomId, data);

  static Future<bool> removeRoom(String roomId) =>
      RoomService.removeRoom(connection, roomId);

  static Future<bool> leaveRoom(String roomId, String? userId) =>
      RoomService.leaveRoom(connection, roomId, userId);

  static Future<r.Rooms?> createGroup(
          String title, List<String> people, String owner) =>
      RoomService.createGroup(connection, title, people, owner);

  static Future<List<c.Messages>?> loadMoreMessageRoom(
          String id, String firstMessageID, String firstMessageDate) =>
      RoomService.loadMoreMessageRoom(connection,
          isChatHub: isChatHub,
          id: id,
          firstMessageID: firstMessageID,
          firstMessageDate: firstMessageDate);

  static Future<ct.Contacts?> contactsList() =>
      RoomService.contactsList(connection);

  static Future<ct.Contacts?> contactsSearch(String search, {int limit = 50}) =>
      RoomService.contactsSearch(connection, search, limit: limit);

  // ── Message ───────────────────────────────────────────────────────────────
  static void listenChat(Function callback) =>
      MessageService.listenChat(streamSocket, callback);

  static void removeListenChat(Function callback) =>
      MessageService.removeListenChat(streamSocket, callback);

  static Future<String?> sendChat(
          c.ChatMessage? data,
          List<types.Message> listMessage,
          String id,
          String? message,
          c.Room? room,
          String authorId,
          {String? reppliedMessageId}) =>
      MessageService.sendChat(connection, streamSocket,
          isChatHub: isChatHub,
          data: data,
          listMessage: listMessage,
          id: id,
          message: message,
          room: room,
          authorId: authorId,
          reppliedMessageId: reppliedMessageId);

  static Future<bool> forwardMessage(String? message, c.Room? room,
          String authorId, String? reppliedMessageId) =>
      MessageService.forwardMessage(connection, streamSocket,
          isChatHub: isChatHub,
          message: message,
          room: room,
          authorId: authorId,
          reppliedMessageId: reppliedMessageId);

  static Future<void> updateChat(String data, String? messageId, c.Room? room,
          {String? reppliedMessageId}) =>
      MessageService.updateChat(connection, streamSocket, data, messageId, room,
          reppliedMessageId: reppliedMessageId);

  static Future<bool> recall(c.Messages? value, c.Room? room) =>
      MessageService.recall(connection, streamSocket, value, room);

  static Future<bool> pinMessage(String? data, c.Room? room) =>
      MessageService.pinMessage(connection, streamSocket, data, room);

  // ── Media ─────────────────────────────────────────────────────────────────
  static File convertToFile(XFile xFile) => MediaService.convertToFile(xFile);

  static Future<String?> uploadImage(
          BuildContext context,
          c.ChatMessage? data,
          List<types.Message> listMessage,
          String id,
          XFile image,
          c.Room? room,
          String authorId) =>
      MediaService.uploadImage(connection, streamSocket,
          isChatHub: isChatHub,
          brandCode: brandCode,
          context: context,
          data: data,
          listMessage: listMessage,
          id: id,
          image: image,
          room: room,
          authorId: authorId,
          showError: (ctx, {content}) => showError(ctx, content: content));

  static Future<String?> uploadFile(
          BuildContext context,
          c.ChatMessage? data,
          List<types.Message> listMessage,
          String id,
          File file,
          c.Room? room,
          String authorId) =>
      MediaService.uploadFile(connection, streamSocket,
          isChatHub: isChatHub,
          context: context,
          data: data,
          listMessage: listMessage,
          id: id,
          file: file,
          room: room,
          authorId: authorId,
          showError: (ctx, {content}) => showError(ctx, content: content));

  // ── Notification ──────────────────────────────────────────────────────────
  static Future<n.Notifications?> notificationList() =>
      NotificationService.notificationList(connection,
          onCountUpdated: (v) => notificationNotifier.value = v);

  static Future<void> notificationCount() =>
      NotificationService.notificationCount(connection,
          onResult: (all, client, fb, zalo, zaloP, wa) {
        notiChatHubAll = all;
        notiChatHubClient = client;
        notiChatHubFacebook = fb;
        notiChatHubZalo = zalo;
        notiChatHubZaloPersonal = zaloP;
        notiChatHubWhatsApp = wa;
      });

  static Future<bool> readNotification(String notiId) =>
      NotificationService.readNotification(connection, notiId);

  static void showNotification(
          String notificationTitle,
          String notificationDes,
          Map<String, dynamic> message,
          String iconApp,
          Function(Map<String, dynamic>) onMessageCallback) =>
      NotificationService.showNotification(notificationTitle, notificationDes,
          message, iconApp, onMessageCallback);

  static void showError(BuildContext context, {String? content}) =>
      NotificationService.showError(context, content: content);

  // ── ChatHub ───────────────────────────────────────────────────────────────
  static Future<ChathubChannel?> channelList() =>
      ChatHubService.channelList(connection);

  static Future<bool> changeStatusChatbot(String roomId, int status) =>
      ChatHubService.changeStatusChatbot(connection, roomId, status);

  static Future<bool> clearChat(String roomId) =>
      ChatHubService.clearChat(connection, roomId);

  static Future<c.Owner?> blockUser(String userId, bool isBlocked) =>
      ChatHubService.blockUser(connection, userId, isBlocked);

  static Future<List<SessionModel>> getSession(String roomId,
          {int? limit = 5, int? offset = 0}) =>
      ChatHubService.getSession(connection, roomId,
          limit: limit, offset: offset);

  static Future<ConversationSummaryModel?> getSummary(String session_id) =>
      ChatHubService.getSummary(connection, session_id);

  static Future<List<c.Messages>> getSessionMessages(List<String> messageIds) =>
      ChatHubService.getSessionMessages(connection, messageIds);

  static Future<RoomResponse?> getRoomByPhoneNumber(String customerPhone) =>
      ChatHubService.getRoomByPhoneNumber(connection, customerPhone);

  static Future<bool> messageSystem(String authorID, String roomID) =>
      ChatHubService.messageSystem(connection, authorID, roomID);

  // ── Customer ──────────────────────────────────────────────────────────────
  static Future<CustomerAccount?> detect(String userId) =>
      CustomerService.detect(connection, userId);

  static Future<bool> customerLink(
    String userId,
    int? customerId,
    String? typeCustomer,
    String? mappingId,
    String? source,
    String? socialId, {
    String? customerLeadId = '',
  }) =>
      CustomerService.customerLink(connection, userId, customerId,
          typeCustomer: typeCustomer,
          mappingId: mappingId,
          source: source,
          socialId: socialId,
          customerLeadId: customerLeadId);

  static Future<CustomerAccount?> customerUnlink(String userId, int? customerId,
          {int? customerLeadId}) =>
      CustomerService.customerUnlink(connection, userId, customerId,
          customerLeadId: customerLeadId);

  static Future<List<CustomerAccount?>?> searchCustomer(String keyword) =>
      CustomerService.searchCustomer(connection, keyword);

  static Future<bool> updateNameChatHub(
          String id, String typeCustomer, String fullName) =>
      CustomerService.updateNameChatHub(connection, id, typeCustomer, fullName);

  // ── Tag ───────────────────────────────────────────────────────────────────
  static Future<Tag?> getTagList() => TagService.getTagList(connection);

  static Future<Tag?> getTagListByUser(String userId) =>
      TagService.getTagListByUser(connection, userId);

  static Future<bool> createTag(String name, String color, String userId) =>
      TagService.createTag(connection, name, color, userId);

  static Future<Map<String, dynamic>> removeTag(String tagId, String userId) =>
      TagService.removeTag(connection, tagId, userId);

  static Future<bool> updateTag(List<String> tagIds, String userId) =>
      TagService.updateTag(connection, tagIds, userId);

  // ── Notes ─────────────────────────────────────────────────────────────────
  static Future<NotesResponseModel?> notes(String roomId) =>
      NotesService.notes(connection, roomId);

  static Future<bool> createNotes(String roomId, String content) =>
      NotesService.createNotes(connection, roomId, content);

  static Future<bool> updateNotes(
          String roomId, String content, String noteId) =>
      NotesService.updateNotes(connection, roomId, content, noteId);

  static Future<bool> deleteNotes(String roomId, String noteId) =>
      NotesService.deleteNotes(connection, roomId, noteId);

  // ── Group ─────────────────────────────────────────────────────────────────
  static Future<bool> addMemberGroup(List<String> people, String roomId) =>
      GroupService.addMemberGroup(connection, people, roomId);

  static Future<ResponseData> addUserGroup(
          List<String> memberUserIds, String channelId, String groupId) =>
      GroupService.addUserGroup(connection, memberUserIds, channelId, groupId);

  static Future<MemberListData?> getMemberInfo(String channelId, String roomId,
          {int? limit = 10, int? offset = 0}) =>
      GroupService.getMemberInfo(connection, channelId, roomId,
          limit: limit, offset: offset);

  static Future<MemberListData?> getMemberPendingInvite(
          String channelId, String groupId) =>
      GroupService.getMemberPendingInvite(connection, channelId, groupId);

  static Future<GroupInfoResponseZP?> getGroupInfo(
          String channelId, String groupId) =>
      GroupService.getGroupInfo(connection, channelId, groupId,
          onCreatorId: (id) => creatorIdGroup = id);

  static Future<bool> removeUserGroup(
          String channelId, String groupId, String memberUserId) =>
      GroupService.removeUserGroup(
          connection, channelId, groupId, memberUserId);

  static Future<ResponseData?> removeMember(
          String channelId, String groupId, List<String> memberUserIds) =>
      GroupService.removeMember(connection, channelId, groupId, memberUserIds);

  static Future<FriendListResponse?> getListFriend(String channelId) =>
      GroupService.getListFriend(connection, channelId);

  static Future<r.UserZaloOAList?> getListUserZaloOA(
          {String source = 'zalo', String? search}) =>
      GroupService.getListUserZaloOA(connection,
          source: source, search: search);

  static Future<ResponseData?> inviteMember(
          String? groupId, List<String> memberUserIds, String channelId) =>
      GroupService.inviteMember(connection, groupId, memberUserIds, channelId);

  static Future<bool?> updateUserInfo(
          String userId, String name, String phone) =>
      GroupService.updateUserInfo(connection, userId, name, phone);

  static Future<ResponseData?> acceptPendingInvite(
          String chanelId, String groupId, List<String> memberUserIds) =>
      GroupService.acceptPendingInvite(
          connection, chanelId, groupId, memberUserIds);

  static Future<ResponseData?> rejectPendingInvite(
          String chanelId, String groupId, List<String> memberUserIds) =>
      GroupService.rejectPendingInvite(
          connection, chanelId, groupId, memberUserIds);

  static Future<ResponseData?> getContactWhatsapp(String phone) =>
      GroupService.getContactWhatsapp(connection, phone);

  static Future<QuotaResponseModel?> getQuota(
          String socialChannelId, String userSocialId) =>
      GroupService.getQuota(connection, socialChannelId, userSocialId);

  static Future<bool> sendTransaction(
          String channelId, String type, String userSocialId) =>
      GroupService.sendTransaction(connection, channelId, type, userSocialId);
}
