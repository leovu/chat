import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_screen/forward_screen.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/chat_ui/widgets/custom_room_avatar.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/room.dart' as r;
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/check_tag.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:chat/presentation/chat_module/ui/chat_screen.dart';
import 'package:chat/presentation/conversation_modules/src/ui/conversation_information_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import '../../../data_model/room.dart';
import '../../utils/ultility.dart';

class InternalChatScreen extends ChatScreenBase {
  const InternalChatScreen({
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
  State<InternalChatScreen> createState() => _InternalChatScreenState();
}

class _InternalChatScreenState extends ChatScreenBaseState<InternalChatScreen> {
  // ── Abstract interface ─────────────────────────────────────────────────────

  @override
  CircleAvatar? get chatAvatar => buildAvatar(width: 15);

  @override
  bool get canSendMessage => true;

  @override
  void onExtraInit() {}

  @override
  List<SheetAction<String>> extraLongPressActions(
      c.Messages? mess, types.Message message) {
    return [
      SheetAction(
        icon: Icons.reply,
        label: AppLocalizations.text(LangKey.reply),
        key: 'Reply',
      ),
      SheetAction(
        icon: Icons.forward,
        label: AppLocalizations.text(LangKey.forward),
        key: 'Forward',
      ),
      if (mess?.author?.sId == ChatConnection.user?.id)
        SheetAction(
          icon: Icons.refresh,
          label: AppLocalizations.text(LangKey.recall),
          key: 'Recall',
        ),
      if (mess?.author?.sId == ChatConnection.user?.id &&
          message.type.name == 'text')
        SheetAction(
          icon: Icons.edit,
          label: AppLocalizations.text(LangKey.edit),
          key: 'Edit',
        ),
      SheetAction(
        icon: Icons.push_pin,
        label: AppLocalizations.text(LangKey.pinMessage),
        key: 'Pin Message',
      ),
      if (_checkAddTaskInstanceAvailable() && message is types.TextMessage)
        SheetAction(
          icon: Icons.add_task,
          label: AppLocalizations.text(LangKey.createTask),
          key: 'Create Task',
        ),
    ];
  }

  @override
  void handleLongPressValue(
      String? value, types.Message message, c.Messages? mess) {
    if (value == 'Reply') {
      chatController.reply(message);
    } else if (value == 'Recall') {
      _recall(message, mess);
    } else if (value == 'Pin Message') {
      _pinMessage(message, mess);
    } else if (value == 'Forward') {
      _forward(message, mess);
    } else if (value == 'Edit') {
      chatController.edit(message, mess);
    } else if (value == 'Create Task') {
      _addTaskInstance((message as types.TextMessage).text);
    }
  }

  // ── Internal-chat-only methods ─────────────────────────────────────────────

  void _addTaskInstance(String textMessage) {
    ChatConnection.addOnModules!.firstWhere((e) => e['key'] == 'create_jobs')[
        'function'](checkTag(textMessage, data?.room?.people));
  }

  bool _checkAddTaskInstanceAvailable() {
    if (ChatConnection.addOnModules != null &&
        ChatConnection.addOnModules!.isNotEmpty) {
      for (var e in ChatConnection.addOnModules!) {
        if (e['key'] == 'create_jobs') return true;
      }
    }
    return false;
  }

  Future<void> _pinMessage(types.Message message, c.Messages? value) async {
    bool result = await ChatConnection.pinMessage(value!.sId, data?.room);
    if (result) {
      setState(() {
        data?.room?.pinMessage = c.PinMessage.fromJson(value.toJson());
      });
    }
  }

  Future<void> _recall(types.Message message, c.Messages? value) async {
    bool result = await ChatConnection.recall(value, data?.room);
    if (result) {
      setState(() {
        if (message is types.ImageMessage) {
          data?.room?.messages?.remove(value);
          messages.remove(message);
        } else if (message is types.TextMessage) {
          value?.content = AppLocalizations.text(LangKey.messageRecalled);
          int index = messages.indexOf(message);
          final textMessage = types.TextMessage(
              author: user,
              createdAt: DateTime.now().millisecondsSinceEpoch,
              id: message.id,
              metadata: const {'recall': 1},
              text: AppLocalizations.text(LangKey.messageRecalled));
          messages[index] = textMessage;
        }
      });
    }
  }

  Future<void> _forward(types.Message message, c.Messages? value) async {
    bool? result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ForwardScreen(message: message, value: value),
        settings: const RouteSettings(name: 'forward_screen')));
    if (result != null && result) {
      await loadMessages();
      itemScrollController.jumpTo(index: 0);
    }
  }

  bool _isFavorite() {
    try {
      r.People? p = widget.data.people
          ?.firstWhere((e) => e.sId == ChatConnection.user?.id);
      return p!.favorites.contains(widget.data.sId);
    } catch (_) {
      return false;
    }
  }

  void _toggleFavorite() {
    try {
      r.People? p = widget.data.people
          ?.firstWhere((e) => e.sId == ChatConnection.user?.id);
      if (p!.favorites.contains(widget.data.sId)) {
        p.favorites.remove(widget.data.sId);
      } else {
        p.favorites.add(widget.data.sId!);
      }
      try {
        ChatConnection.refreshRoom.call();
        ChatConnection.refreshFavorites.call();
      } catch (_) {}
    } catch (_) {}
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  @override
  AppBar buildDefaultAppBar() {
    final isFav = _isFavorite();
    return AppBar(
        actions: <Widget>[
          IconButton(
            visualDensity:
                const VisualDensity(horizontal: -4.0, vertical: -4.0),
            padding: EdgeInsets.zero,
            icon: Icon(
              isFav ? Icons.star : Icons.star_border,
              color: const Color(0xFFE5B80B),
            ),
            onPressed: () async {
              bool result =
                  await ChatConnection.toggleFavorites(widget.data.sId);
              if (result && mounted) {
                setState(() => _toggleFavorite());
              }
            },
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
                      groupOwner: groupOwner1),
                  settings: const RouteSettings(
                      name: 'conversation_information_screen')));
              loadMessages();
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
                    height: widget.data.isGroup != true ? 25.0 : 50.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          widget.data.isGroup != true
                              ? () {
                                  final owner = extractOwner(widget.data);
                                  return '${owner?.firstName ?? ''} ${owner?.lastName ?? ''}'
                                      .trim();
                                }()
                              : widget.data.room_name ??
                                  widget.data.title ??
                                  'Group ${widget.data.owner?.firstName ?? ''} ${widget.data.owner?.lastName ?? ''}'
                                      .trim(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        if (widget.data.isGroup == true)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 3.0),
                            child: AutoSizeText(
                              '${data?.room?.people?.length ?? widget.data.people?.length ?? 0} '
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
    if (!widget.data.isGroup!) {
      final owner = extractOwner(widget.data);
      final isPictureEmpty = owner?.picture == null || owner?.picture == '';
      return isPictureEmpty
          ? CircleAvatar(
              radius: radius,
              backgroundColor: getAvatarColor(owner?.sId),
              child: Text(
                getAvatarName(
                    '${owner?.firstName ?? ''}', '${owner?.lastName ?? ''}'),
                style: const TextStyle(color: Colors.white),
              ),
            )
          : CircleAvatar(
              radius: radius,
              backgroundImage: CachedNetworkImageProvider(
                '${HTTPConnection.domain}api/images/${owner!.picture}/256/${ChatConnection.brandCode!}',
                headers: {'brand-code': ChatConnection.brandCode!},
              ),
              backgroundColor: Colors.transparent,
            );
    } else {
      return widget.data.room_avatar == null
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
                '${HTTPConnection.domain}api/images/${widget.data.room_avatar!.shieldedID}/256/${ChatConnection.brandCode!}',
                headers: {'brand-code': ChatConnection.brandCode!},
              ),
              backgroundColor: Colors.transparent,
            );
    }
  }

  // ── Tag area (no tags in internal chat) ───────────────────────────────────

  @override
  Widget buildTagArea() => const SizedBox.shrink();
}
