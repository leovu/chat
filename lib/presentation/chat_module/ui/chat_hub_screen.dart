import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/room.dart' as r;
import 'package:chat/data_model/tag.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:chat/presentation/chat_module/ui/chat_screen.dart';
import 'package:chat/presentation/conversation_modules/src/ui/conversation_information_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../../chat_ui/hex_color.dart';
import '../../../chat_ui/widgets/custom_room_avatar.dart';
import '../../../data_model/room.dart';
import '../../utils/dialog.dart';
import '../../utils/ultility.dart';

class ChatHubScreen extends ChatScreenBase {
  const ChatHubScreen({
    Key? key,
    required r.Rooms data,
    Function? callback,
    String? source,
    bool? isChatbot,
    Owner? groupOwner,
  }) : super(
            key: key,
            data: data,
            callback: callback,
            source: source,
            isChatbot: isChatbot,
            groupOwner: groupOwner);

  @override
  State<ChatHubScreen> createState() => _ChatHubScreenState();
}

class _ChatHubScreenState extends ChatScreenBaseState<ChatHubScreen> {
  Tag? tag;
  Tag? tagByUser;
  bool? isBlock = false;
  bool checkQuota = true;
  bool isShowUserTag = true;

  // ── Abstract interface ─────────────────────────────────────────────────────

  @override
  CircleAvatar? get chatAvatar => null;

  @override
  bool get canSendMessage => checkQuota;

  @override
  void onExtraInit() {
    if (widget.data.isGroup == false) _getTagList();
    isBlock = widget.data.owner?.isBlocked ?? false;
    if (widget.source == 'zalo' && widget.data.isGroup == false) getQuota();
  }

  @override
  List<SheetAction<String>> extraLongPressActions(
          c.Messages? mess, types.Message message) =>
      [];

  @override
  void handleLongPressValue(
      String? value, types.Message message, c.Messages? mess) {}

  // ── ChatHub-specific methods ───────────────────────────────────────────────

  Future<void> getQuota() async {
    checkQuota = await bloc.getQuota(
        widget.data.channel!.socialChanelId!, widget.data.owner!.userSocialId!);
    setState(() {});
  }

  Future<void> _getTagList() async {
    if (widget.data.isGroup == true) return;
    tagByUser =
        await ChatConnection.getTagListByUser(widget.data.owner?.sId ?? '');
    setState(() {});
  }

  Future<void> _handleBlockUser() async {
    final owner = widget.data.owner;
    final fullName = '${owner!.firstName} ${owner.lastName}';
    await showInfoDialog(
      context,
      AppLocalizations.text(LangKey.notifications),
      content: isBlock == false
          ? '${AppLocalizations.text(LangKey.confirm_block_name)}$fullName'
          : '${AppLocalizations.text(LangKey.confirm_unblock_name)}$fullName',
      () async {
        await ChatConnection.blockUser(owner.sId!, !isBlock!);
        Navigator.of(context, rootNavigator: true).pop();
      },
      onCancel: () async => Navigator.of(context).pop(),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  @override
  AppBar buildDefaultAppBar() {
    return AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              child: Icon(Icons.block,
                  color: isBlock == false ? Colors.grey : Colors.red),
              onTap: () => _handleBlockUser(),
            ),
          ),
          IconButton(
            visualDensity:
                const VisualDensity(horizontal: -4.0, vertical: -4.0),
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.format_list_bulleted, color: Colors.black),
            onPressed: () async {
              this.showLoading();
              Navigator.of(context).pop();
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ConversationInformationScreen(
                      isChatBot: widget.isChatbot,
                      roomData: widget.data,
                      chatMessage: data,
                      groupOwner: null),
                  settings: const RouteSettings(
                      name: 'conversation_information_screen')));
              loadMessages();
              await _getTagList();
              setState(() {});
            },
          )
        ],
        title: SizedBox(
          height: 50.0,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: InkWell(
                  child: const Icon(Icons.arrow_back_ios, color: Colors.black),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                child: widget.data.isGroup == true
                    ? ChatGroupAvatar(
                        people: widget.data.people,
                        size: 50,
                      )
                    : buildAvatar(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: SizedBox(
                    height: !widget.data.isGroup! ? 25.0 : 50.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          !widget.data.isGroup!
                              ? '${data?.room?.owner?.firstName ?? ''} ${data?.room?.owner?.lastName ?? ''}'
                              : widget.data.title ??
                                  data?.room?.roomName ??
                                  '',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        if (widget.data.isGroup!)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3.0),
                            child: AutoSizeText(
                              '${peopleLength != null ? peopleLength! - 1 : ''} '
                              '${AppLocalizations.text(LangKey.members).toLowerCase()}',
                              maxLines: 1,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        leading: Container(),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: false,
        titleSpacing: 0,
        leadingWidth: 0);
  }

  // ── Avatar ─────────────────────────────────────────────────────────────────

  @override
  CircleAvatar buildAvatar({double? width}) {
    double radius = width ?? 25.0;

    if (widget.data.isGroup == false) {
      if (widget.data.people?.first.avatar?.isNotEmpty == true) {
        return CircleAvatar(
          radius: radius,
          backgroundImage:
              CachedNetworkImageProvider(widget.data.people!.first.avatar!),
          backgroundColor: Colors.transparent,
        );
      }
      if (widget.data.owner?.picture == null || widget.data.owner?.picture == '') {
        if (widget.data.owner?.avatar?.isNotEmpty == true) {
          return CircleAvatar(
            radius: radius,
            backgroundImage: CachedNetworkImageProvider(
              '${widget.data.owner?.avatar}',
              headers: {'brand-code': ChatConnection.brandCode!},
            ),
            backgroundColor: Colors.transparent,
          );
        } else {
          return CircleAvatar(
            radius: radius,
            backgroundColor: getAvatarColor(widget.data.owner?.sId),
            child: Text(
              getAvatarName('${widget.data.owner?.firstName ?? ''}',
                  '${widget.data.owner?.lastName ?? ''}'),
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
      } else {
        final sid = widget.data.shieldedID;
        return (sid != null && sid != '')
            ? CircleAvatar(
                radius: radius,
                backgroundImage: CachedNetworkImageProvider(
                  '${HTTPConnection.domain}api/images/$sid/256/${ChatConnection.brandCode!}',
                  headers: {'brand-code': ChatConnection.brandCode!},
                ),
                backgroundColor: Colors.transparent,
              )
            : CircleAvatar(
                radius: radius,
                backgroundColor: getAvatarColor(widget.data.owner?.sId),
                child: Text(
                  getAvatarName('${widget.data.owner?.firstName ?? ''}',
                      '${widget.data.owner?.lastName ?? ''}'),
                  style: const TextStyle(color: Colors.white),
                ),
              );
      }
    } else {
      return widget.data.avatar == null
          ? CircleAvatar(
              radius: radius,
              backgroundColor: getAvatarColor(widget.data.sId),
              child: Text(
                widget.data.getAvatarGroupName(),
                style: const TextStyle(color: Colors.white),
              ),
            )
          : CircleAvatar(
              radius: radius,
              backgroundImage: CachedNetworkImageProvider(
                widget.data.avatar!,
                headers: {'brand-code': ChatConnection.brandCode!},
              ),
              backgroundColor: Colors.transparent,
            );
    }
  }

  // ── Tag area ───────────────────────────────────────────────────────────────

  @override
  Widget buildTagArea() {
    if (tagByUser == null ||
        tagByUser?.data == null ||
        widget.data.isGroup != false) {
      return const SizedBox.shrink();
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: !isShowUserTag
                      ? Container()
                      : Wrap(
                          children: tagByUser!.data!
                              .map((e) => _tagChip(e))
                              .toList()))),
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () => setState(() => isShowUserTag = !isShowUserTag),
              child: Container(
                  color: Colors.white,
                  constraints: const BoxConstraints(minHeight: 30),
                  child: Icon(
                      isShowUserTag
                          ? Icons.remove_red_eye
                          : Icons.remove_red_eye_outlined,
                      color: HexColor.fromHex('#0067AC'))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagChip(Data e) {
    if (e.isActive == false) return Container();
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5.0, bottom: 5.0),
      child: Container(
        height: 30.0,
        decoration: BoxDecoration(
            color: HexColor.fromHex(
                (e.color != null && e.color != 'null') ? e.color : '#0067AC'),
            borderRadius: BorderRadius.circular(10.0)),
        child: Padding(
          padding: const EdgeInsets.only(top: 5.0, left: 5.0, right: 5.0),
          child: AutoSizeText(
            e.name ?? '',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
