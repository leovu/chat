import 'dart:io';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_screen/add_member_group_screen.dart';
import 'package:chat/chat_ui/widgets/widget_divider.dart';
import 'package:chat/common/theme.dart';
import 'package:chat/data_model/chat_message.dart';
import 'package:chat/data_model/response/group_member_response_model.dart';
import 'package:chat/presentation/chat_module/ui/chat_screen.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/contact.dart' as ct;
import 'package:chat/data_model/room.dart' as r;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:chat/presentation/conversation_modules/module/group_member/bloc/chat_group_member_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../data_model/response/group_info_response.dart';
import '../../../../../data_model/response/whatsapp_contact_response_model.dart';
import '../../../../utils/dialog.dart';

class ChatGroupMembersScreen extends StatefulWidget {
  // final r.Rooms roomData;
  final ChatMessage chatMessage;
  final String? channelSocialId;
  const ChatGroupMembersScreen(
      {Key? key, required this.chatMessage, this.channelSocialId})
      : super(key: key);
  @override
  _ChatGroupMembersScreenState createState() => _ChatGroupMembersScreenState();
}

class _ChatGroupMembersScreenState extends State<ChatGroupMembersScreen> {
  late ChatGroupMemberBloc _bloc;
  // MemberListData? listMemberZalo;
  MemberListData? listPendingInvite;
  GroupInfoResponseZP? infoMemberZaloPersional;
  // TODO: Thay thế bằng model chính thức khi API WhatsApp hoàn thiện
  List<WhatsAppMember> membersWhatsApp = [];
  bool isInitScreen = true;
  late String source = '';
  bool get isZalo => source == 'zalo';
  bool get isZaloPersonal => source == 'zalo_personal';
  bool get isWhatsApp => source == 'whatsapp';
  List<String> memberId = [];
  late int lengthPeople = 0;

  @override
  void initState() {
    super.initState();
    _bloc = ChatGroupMemberBloc();
    if (ChatConnection.isChatHub) {
      source = widget.chatMessage.room?.source ?? '';
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        onGetInfoOnOpen();
      });
      isZalo
          ? lengthPeople = widget.chatMessage.room?.people?.length ?? 0
          : lengthPeople = widget.chatMessage.room?.people?.length ?? 1 - 1;
    } else {
      isInitScreen = false;
    }
  }

  void onGetInfoOnOpen() async {
    final channelId = widget.chatMessage.room?.channel?.socialChanelId;
    final channelZaloId = widget.chatMessage.room?.channel?.id;
    final groupId = widget.chatMessage.room?.oa_group_id;

    if (isZalo) {
      await _bloc.onGetMemberInfo(
          channelZaloId!, widget.chatMessage.room?.sId ?? '');
      listPendingInvite = await ChatConnection.getMemberPendingInvite(
          channelZaloId, groupId ?? '');
    } else if (isZaloPersonal) {
      infoMemberZaloPersional =
          await ChatConnection.getGroupInfo(channelId ?? '', groupId ?? '');
    } else if (isWhatsApp) {
      // TODO: Phân tích response thực tế khi API hoàn thiện.
      // Hiện parse theo WhatsAppContactsResponse.fromJson — điều chỉnh nếu cấu trúc response thay đổi.
      final phone = widget.channelSocialId ?? '';
      if (phone.isNotEmpty) {
        final response = await ChatConnection.getContactWhatsapp(phone);
        if (response != null && response.isSuccess) {
          final parsed = WhatsAppContactsResponse.fromJson(response.data);
          membersWhatsApp = parsed.members ?? [];
          lengthPeople = membersWhatsApp.length;
        }
      }
    }
    isInitScreen = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: isInitScreen
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildMemberList(),
                  ),
                  if (ChatConnection.isChatHub &&
                      isZalo == true &&
                      listPendingInvite?.memberCount != 0)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 10),
                        child: customDivider(
                            '${AppLocalizations.text(LangKey.request_to_join_group)} (${listPendingInvite?.memberCount ?? listPendingInvite?.members?.length})'),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildItemPending(),
                      childCount: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
      title: AutoSizeText(
        '${AppLocalizations.text(LangKey.members)} ($lengthPeople)',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      leading: InkWell(
        onTap: () => Navigator.of(context).pop(),
        child: Icon(
          Icons.arrow_back_ios,
          color: Colors.black,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            width: 30.0,
            height: 30.0,
            child: InkWell(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => AddMemberGroupScreen(
                    // roomData: widget.chatMessage.room,
                    chanel_id: ChatConnection.isChatHub
                        ? widget.chatMessage.room?.channel?.socialChanelId
                        : '',
                    chatMessage: widget.chatMessage,
                  ),
                ));
                if (ChatConnection.isChatHub) onGetInfoOnOpen();
              },
              child: Image.asset(
                'assets/icon-edit.png',
                package: 'chat',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMemberList() {
    if (ChatConnection.isChatHub) {
      if (isZalo) {
        return StreamBuilder<MemberListData>(
          stream: _bloc.listMemberZalo,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data?.members != null) {
              final members = snapshot.data!.members!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final memberZ = members[index];
                  final isLast = index == members.length - 1;
                  return buildMemberZItem(context, memberZ, isLast, index);
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        );
      } else if (isZaloPersonal) {
        final members = infoMemberZaloPersional?.members ?? [];
        if (members.isNotEmpty) {
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final memberZP = members[index];
              if (memberZP.level == 'root') return Container();
              final isLast = index == members.length - 1;
              return buildMemberZPItem(context, memberZP, isLast, memberZP.id!,
                  widget.chatMessage.room!.isGroup!);
            },
          );
        }
        // Fallback: API không trả về dữ liệu, dùng people từ màn hình trước
        final fallbackMembers = widget.chatMessage.room?.people ?? [];
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: fallbackMembers.length,
          itemBuilder: (context, index) => _itemChat(context, index),
        );
      } else if (isWhatsApp) {
        // TODO: Cập nhật lại cách hiển thị khi API WhatsApp hoàn thiện
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: membersWhatsApp.length,
          itemBuilder: (context, index) {
            final member = membersWhatsApp[index];
            final isLast = index == membersWhatsApp.length - 1;
            return buildMemberItem(
              context: context,
              id: member.id,
              avatarUrl: member.avatar,
              displayName: member.name ?? '',
              username: member.phone ?? '',
              isLast: isLast,
              onTap: () {},
            );
          },
        );
      }
    } else {
      final members = widget.chatMessage.room?.people ?? [];
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: members.length,
        itemBuilder: (context, index) => _itemChat(context, index),
      );
    }

    return const SizedBox.shrink();
  }

  Future showLoading() async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              Center(
                child: Platform.isAndroid
                    ? const CircularProgressIndicator()
                    : const CupertinoActivityIndicator(),
              )
            ],
          );
        });
  }

  void sendMessage(r.People people) async {
    showLoading();
    ct.Contacts? contactsListData = await ChatConnection.contactsList();
    r.People? val;
    if (contactsListData?.users != null) {
      for (var value in contactsListData!.users!) {
        if (value.sId == people.sId) {
          val = value;
          break;
        }
      }
    }
    if (val != null) {
      r.Rooms? rooms = await ChatConnection.createRoom(val.sId);
      Navigator.of(context).pop();
      Navigator.of(context)
          .popUntil((route) => route.settings.name == "chat_screen");
      await Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute(
            builder: (context) => ChatScreen(data: rooms!),
            settings: const RouteSettings(name: 'chat_screen')),
      );
      try {
        ChatConnection.refreshRoom.call();
        ChatConnection.refreshFavorites.call();
      } catch (_) {}
    } else {
      Navigator.of(context).pop();
    }
  }

  void removeMemberChathub(String memberId) async {
    bool value = await ChatConnection.removeUserGroup(
        widget.chatMessage.room?.channel?.socialChanelId ?? '',
        widget.chatMessage.room!.oa_group_id!,
        memberId);
    if (value) {
      onGetInfoOnOpen();
    }
  }

  void removeMemberZaloOA(String memberId) async {
    final response = await ChatConnection.removeMember(
        widget.chatMessage.room?.channel?.id ?? '',
        widget.chatMessage.room!.oa_group_id!,
        [memberId]);
    if (response!.isSuccess) {
      onGetInfoOnOpen();
    } else {
      showDialog(
        context: context,
        builder: (cxxt) => AlertDialog(
          title: Text(AppLocalizations.text(LangKey.notifications)),
          content: Text(AppLocalizations.text(LangKey.leaveError)),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(cxxt);
                },
                child: Text(AppLocalizations.text(LangKey.accept)))
          ],
        ),
      );
    }
  }

  void removeMemberChat(r.People people) async {
    bool value = await ChatConnection.leaveRoom(
        widget.chatMessage.room?.sId ?? '', people.sId);
    if (value) {
      widget.chatMessage.room?.people?.remove(people);
      setState(() {});
    }
  }

  Widget _buildItemPending() {
    final itemCount = listPendingInvite?.memberCount ??
        listPendingInvite?.members?.length ??
        0;
    return ListView.builder(
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final item = listPendingInvite?.members?[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Card(
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  )),
              child: buildMemberZItem(
                  context, item!, !(index == itemCount), index,
                  isPending: true),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPeopleAvatar(r.People? data) {
    const double radius = 25.0;
    String? avatarUrl;

    if (ChatConnection.isChatHub) {
      if (data?.avatar?.isNotEmpty == true) {
        avatarUrl = data!.avatar;
      } else if (data?.picture?.shieldedID?.isNotEmpty == true) {
        avatarUrl =
            '${HTTPConnection.domain}api/images/${data!.picture!.shieldedID}/256/${ChatConnection.brandCode}';
      }
    } else {
      if (data?.picture?.shieldedID?.isNotEmpty == true) {
        avatarUrl =
            '${HTTPConnection.domain}api/images/${data!.picture!.shieldedID}/256/${ChatConnection.brandCode}';
      }
    }

    if (avatarUrl != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(
          avatarUrl,
          headers: {'brand-code': ChatConnection.brandCode!},
        ),
        backgroundColor: Colors.transparent,
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.bluePrimary,
      child: Text(
        data?.getAvatarName() ?? '*',
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        textScaler: TextScaler.linear(1.0),
      ),
    );
  }

  Widget _itemChat(BuildContext context, int index) {
    final data = widget.chatMessage.room?.people![index];
    bool isLast = index == (widget.chatMessage.room?.people?.length ?? 1) - 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [
          // Text(data.toString()),
          InkWell(
            onTap: () {
              if (data?.sId != ChatConnection.user!.id) {
                showModalActionSheet<String>(
                  context: context,
                  actions: [
                    SheetAction(
                      icon: Icons.chat,
                      label: AppLocalizations.text(LangKey.sendMessage),
                      key: 'Chat',
                    ),
                    if (widget.chatMessage.room?.owner?.sId ==
                            ChatConnection.user!.id &&
                        widget.chatMessage.room?.isGroup == true)
                      SheetAction(
                        icon: Icons.delete,
                        label: AppLocalizations.text(LangKey.removeFroumGroup),
                        key: 'Delete',
                      ),
                    if (Platform.isAndroid)
                      SheetAction(
                          icon: Icons.cancel,
                          label: AppLocalizations.text(LangKey.cancel),
                          key: 'Cancel',
                          isDestructiveAction: true),
                  ],
                ).then((value) {
                  if (value == 'Chat') {
                    sendMessage(data!);
                  } else if (value == 'Delete') {
                    removeMemberChat(data!);
                  } else {}
                });
              }
            },
            child: SizedBox(
              height: 50.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildPeopleAvatar(data),
                    Expanded(
                        child: Container(
                      padding: const EdgeInsets.only(
                          top: 5.0, bottom: 5.0, left: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AutoSizeText(
                                '${data?.firstName} ${data?.lastName}'),
                          ),
                          Container(
                            height: 5.0,
                          ),
                          Expanded(
                              child: AutoSizeText(
                            '@${data?.username}',
                            overflow: TextOverflow.ellipsis,
                          ))
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            ),
          ),
          !isLast
              ? Container(
                  height: 5.0,
                )
              : Container(),
          !isLast
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    height: 1.0,
                    color: Colors.grey.shade300,
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget buildMemberZItem(
      BuildContext context, MemberZ member, bool isLast, int index,
      {bool isPending = false}) {
    return buildMemberItem(
      context: context,
      id: (member.oaId == '' || member.oaId == null) ? member.id : member.oaId,
      avatarUrl: member.avatar,
      displayName: member.name ?? '',
      username: '',
      isLast: isLast,
      isPending: isPending,
      onTap: () {
        if (member.id != ChatConnection.user!.id) {
          removeMemberZaloOA(member.id!);
        }
      },
    );
  }

  Widget buildMemberZPItem(
    BuildContext context,
    MemberZP member,
    bool isLast,
    String userId,
    bool isGroup,
  ) {
    return buildMemberItem(
      context: context,
      id: member.userSocialId,
      avatarUrl: member.avatar,
      displayName: '${member.firstName ?? ''} ${member.lastName ?? ''}',
      username: member.username ?? '',
      isLast: isLast,
      onTap: () {
        if (infoMemberZaloPersional?.room?.owner != ChatConnection.user!.id) {
          removeMemberChathub(member.id!);
        }
      },
    );
  }

  Widget buildMemberItem(
      {required BuildContext context,
      required String? id,
      required String? avatarUrl,
      required String displayName,
      required String username,
      required bool isLast,
      required VoidCallback onTap,
      // bool isAdmin = false,
      bool isPending = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [
          InkWell(
            onTap: () {},
            child: SizedBox(
              height: 50.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  children: [
                    avatarUrl == null
                        ? CircleAvatar(
                            radius: 25.0,
                            child: Text(
                                displayName.isNotEmpty ? displayName[0] : '?'))
                        : CircleAvatar(
                            radius: 25.0,
                            backgroundImage: CachedNetworkImageProvider(
                              avatarUrl,
                              headers: {
                                'brand-code': ChatConnection.brandCode!
                              },
                            ),
                            backgroundColor: Colors.transparent,
                          ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(displayName),
                          const SizedBox(height: 5.0),
                          AutoSizeText('$username',
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    // if (isAdmin)
                    if (isPending == false) ...[
                      InkWell(
                        onTap: () async {
                          await showInfoDialog(
                            content:
                                AppLocalizations.text(LangKey.removeFroumGroup),
                            context,
                            AppLocalizations.text(LangKey.notifications),
                            () {
                              if (widget.chatMessage.room?.source == 'zalo') {
                                removeMemberZaloOA(id!);
                              } else {
                                removeMemberChathub(id!);
                              }
                            },
                            onCancel: () {},
                          );
                        },
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (isPending == true)
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _itemButtonPending(() {
                  _bloc.onAcceptPending(
                      widget.chatMessage.room?.channel?.id ??
                          widget.chatMessage.room?.channel?.id ??
                          '',
                      widget.chatMessage.room?.oa_group_id ?? '',
                      [id ?? '']);
                  onGetInfoOnOpen();
                }, isAccept: true),
                _itemButtonPending(() {
                  _bloc.onRejectPending(
                      widget.chatMessage.room?.channel?.id ??
                          widget.chatMessage.room?.channel?.id ??
                          '',
                      widget.chatMessage.room?.oa_group_id ?? '',
                      [id ?? '']);

                  onGetInfoOnOpen();
                }, isAccept: false),
              ],
            ),
          if (!isLast) ...[
            const SizedBox(height: 5.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(height: 1.0, color: Colors.grey.shade300),
            ),
          ],
        ],
      ),
    );
  }

  Widget _itemButtonPending(VoidCallback onTap, {bool isAccept = false}) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: InkWell(
        onTap: () {
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: isAccept ? Color(0xff5686E1) : Colors.redAccent),
          child: Row(
            children: [
              Icon(
                isAccept ? Icons.check : Icons.close,
                color: Colors.white,
                size: 24,
              ),
              AutoSizeText(
                isAccept
                    ? AppLocalizations.text(LangKey.accept)
                    : AppLocalizations.text(LangKey.reject),
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showActionSheet(
      BuildContext context, dynamic member, String userId, bool isGroup) {
    showModalActionSheet<String>(
      context: context,
      actions: [
        // SheetAction(
        //     icon: Icons.chat,
        //     label: AppLocalizations.text(LangKey.sendMessage),
        //     key: 'Chat'),
        // if (roomData.owner?.sId == ChatConnection.user!.id && roomData.isGroup!)
        if (userId != ChatConnection.user!.id && isGroup)
          SheetAction(
              icon: Icons.delete,
              label: AppLocalizations.text(LangKey.removeFroumGroup),
              key: 'Delete'),
        if (Platform.isAndroid)
          SheetAction(
            icon: Icons.cancel,
            label: AppLocalizations.text(LangKey.cancel),
            key: 'Cancel',
            isDestructiveAction: true,
          ),
      ],
    ).then((value) {
      // if (value == 'Chat') {
      //   sendMessage(member);
      // } else
      if (value == 'Delete') {
        removeMemberChathub(member);
      }
    });
  }
}
