import 'dart:io';
import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_screen/add_member_group_screen.dart';
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data_model/response/group_info_response.dart';
import '../presentation/utils/dialog.dart';

class ChatGroupMembersScreen extends StatefulWidget {
  final r.Rooms roomData;
  final ChatMessage chatMessage;
  const ChatGroupMembersScreen(
      {Key? key, required this.roomData, required this.chatMessage})
      : super(key: key);
  @override
  _ChatGroupMembersScreenState createState() => _ChatGroupMembersScreenState();
}

class _ChatGroupMembersScreenState extends State<ChatGroupMembersScreen> {
  MemberListData? listMemberZalo;
  MemberListData? listPendingInvite;
  GroupInfoResponseZP? infoMemberZaloPersional;
  bool isInitScreen = true;
  late String source='';
  bool get isZalo => source == 'zalo';
  bool get isZaloPersonal => source == 'zalo_personal';
  List<String> memberId=[];
  @override
  void initState() {
    super.initState();
    if(ChatConnection.isChatHub){
      source = widget.roomData.channel?.source ?? '';
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        onGetInfoOnOpen();
      });
    }
    else{
      isInitScreen=false;
    }

  }
  void onGetInfoOnOpen() async {
    final channelId = widget.roomData.channel!.socialChanelId!;
    final channelZaloId = widget.roomData.channel!.sId;
    final groupId = widget.chatMessage.room!.oa_group_id!;

    if (source=='zalo') {
      listMemberZalo = await ChatConnection.getMemberInfo(channelZaloId!, widget.roomData.sId!);
      listPendingInvite =
          await ChatConnection.getMemberPendingInvite(channelZaloId, groupId);
    } else if (source=='zalo_personal') {
      infoMemberZaloPersional =
          await ChatConnection.getGroupInfo(channelId, groupId);

    }
    setState(() {
      isInitScreen = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMemberTitle(),
            isInitScreen
                ? const Center(child: CircularProgressIndicator())
                : _buildMemberList(),
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
        AppLocalizations.text(LangKey.members),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      leading: InkWell(
        onTap: () => Navigator.of(context).pop(),
        child: Icon(
          Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
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
                    roomData: widget.roomData,
                    chanel_id: ChatConnection.isChatHub? widget.roomData.channel?.socialChanelId:'',
                    chatMessage: widget.chatMessage,
                  ),
                ));
                if(ChatConnection.isChatHub)
                onGetInfoOnOpen();
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
  Widget _buildMemberTitle() {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, top: 10.0, bottom: 10.0),
      child: Text(
        '${AppLocalizations.text(LangKey.listMembers)} (${widget.chatMessage.room!.people!.length})',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    );
  }
  Widget _buildMemberList() {
    final count = ChatConnection.isChatHub?
    source == 'zalo'
        ? (listMemberZalo?.memberCount ?? 0)
        : (infoMemberZaloPersional?.members?.length ?? 0):widget.roomData.people?.length;

    return Expanded(
      child: ListView.builder(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.only(top: 5.0),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemBuilder:ChatConnection.isChatHub? _itemBuilder:_itemChat,
        itemCount: count,
      ),
    );
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
        widget.roomData.channel!.socialChanelId!,
        widget.chatMessage.room!.oa_group_id!,
        memberId);
    if (value) {
      onGetInfoOnOpen();
    }
  }
  void removeMemberZaloOA(String memberId)async{
    final response= await ChatConnection.removeMember(widget.roomData.channel!.sId!,widget.chatMessage.room!.oa_group_id!,[memberId]);
    if(response!.isSuccess){
      onGetInfoOnOpen();
    }else{
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
    bool value = await ChatConnection.leaveRoom(widget.roomData.sId!,people.sId);
    if(value) {
      widget.roomData.people?.remove(people);
      setState(() {});
    }
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (isZalo) {
      final memberZ = listMemberZalo?.members?[index];
      if (memberZ != null) {
        final isLast = index == (listMemberZalo?.members?.length ?? 1) - 1;
        return buildMemberZItem(context, memberZ, isLast, memberZ.id ?? memberZ.oaId!,
            widget.chatMessage.room!.isGroup!, index);
      }
    } else if (isZaloPersonal) {
      final memberZP = infoMemberZaloPersional?.members?[index];
      if (memberZP != null) {
        final isLast =
            index == (infoMemberZaloPersional?.members?.length ?? 1) - 1;
        if(memberZP.level=='root')
          return Container();
        return buildMemberZPItem(context, memberZP, isLast, memberZP.id!,
            widget.chatMessage.room!.isGroup!);
      }
    }
    else{

    }
    return const SizedBox.shrink();
    // return Text(listMemberZalo?.members![1].avatar ?? '');
  }
  Widget _itemChat(BuildContext context, int index){
    final data = widget.roomData.people![index];
    bool isLast = index == (widget.roomData.people?.length ?? 1)-1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              if(data.sId != ChatConnection.user!.id) {
                showModalActionSheet<String>(
                  context: context,
                  actions: [
                    SheetAction(
                      icon: Icons.chat,
                      label: AppLocalizations.text(LangKey.sendMessage),
                      key: 'Chat',
                    ),
                    if(widget.roomData.owner?.sId == ChatConnection.user!.id &&
                        widget.roomData.isGroup!) SheetAction(
                      icon: Icons.delete,
                      label: AppLocalizations.text(LangKey.removeFroumGroup),
                      key: 'Delete',
                    ),
                    if(Platform.isAndroid) SheetAction(
                        icon: Icons.cancel,
                        label: AppLocalizations.text(LangKey.cancel),
                        key: 'Cancel',
                        isDestructiveAction: true),
                  ],
                ).then((value) {
                  if(value == 'Chat') {
                    sendMessage(data);
                  }
                  else if(value == 'Delete') {
                    removeMemberChat(data);
                  }
                  else {

                  }
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
                    data.picture == null ? CircleAvatar(
                      radius: 25.0,
                      child: Text(data.getAvatarName()),
                    ) : CircleAvatar(
                      radius: 25.0,
                      backgroundImage:
                      CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${data.picture!.shieldedID}/256/${ChatConnection.brandCode!}',headers: {'brand-code':ChatConnection.brandCode!}),
                      backgroundColor: Colors.transparent,
                    ),
                    Expanded(child: Container(
                      padding: const EdgeInsets.only(top: 5.0,bottom: 5.0,left: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AutoSizeText('${data.firstName} ${data.lastName}'),
                          ),
                          Container(height: 5.0,),
                          Expanded(child: AutoSizeText('@${data.username}',
                            overflow: TextOverflow.ellipsis,))
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            ),
          ),
          !isLast ? Container(height: 5.0,) : Container(),
          !isLast ?  Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Container(height: 1.0,color: Colors.grey.shade300,),
          ) : Container(),
        ],
      ),
    );
  }

  Widget buildMemberZItem(BuildContext context, MemberZ member, bool isLast, String userId, bool isGroup, int index) {
    return buildMemberItem(
      context: context,
      id: member.oaId ?? member.id,
      avatarUrl: member.avatar,
      displayName: member.name ?? '',
      username: member.oaId ?? '',
      isLast: isLast,
      // isAdmin: widget.chatMessage.room!.owner!.sId==widget.chatMessage.room!.people![index].sId??false,
      isAdmin: ChatConnection.user!.id == listMemberZalo!.members![index].id,
      onTap: () {
        if (member.id != ChatConnection.user!.id) {
          removeMemberZaloOA(member.id!);
        }
      },
    );
  }

  Widget buildMemberZPItem(BuildContext context, MemberZP member, bool isLast, String userId, bool isGroup) {
    return buildMemberItem(
      context: context,
      id: member.userSocialId,
      avatarUrl: member.avatar,
      displayName: '${member.firstName ?? ''} ${member.lastName ?? ''}',
      username: member.username ?? '',
      isLast: isLast,
      isAdmin:ChatConnection.user?.id==infoMemberZaloPersional?.room?.owner,
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
      bool isAdmin = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
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
                      InkWell(
                        onTap: () async {
                          await showInfoDialog(
                            content:
                                AppLocalizations.text(LangKey.removeFroumGroup),
                            context,
                            AppLocalizations.text(LangKey.notifications),
                            () {
                              if(widget.roomData.source=='zalo'){
                                removeMemberZaloOA(id!);
                              }
                              else{
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
                      )
                  ],
                ),
              ),
            ),
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
