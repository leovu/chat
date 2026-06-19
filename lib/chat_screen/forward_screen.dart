import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_ui/util.dart';
import 'package:chat/chat_ui/widgets/custom_room_avatar.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:chat/presentation/utils/ultility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:chat/data_model/room.dart';

class ForwardScreen extends StatefulWidget {
  final types.Message message;
  final c.Messages? value;
  const ForwardScreen({Key? key, required this.message, required this.value})
      : super(key: key);
  @override
  ForwardScreenState createState() => ForwardScreenState();
}

class ForwardScreenState extends State<ForwardScreen> {
  final _controllerSearch = TextEditingController();
  final _focusSearch = FocusNode();
  final _controllerContent = TextEditingController();
  final _focusContent = FocusNode();
  Room? roomListVisible;
  Room? roomListData;
  bool _isSentCurrentChatRoom = false;
  List<String?> idSent = [];

  @override
  void initState() {
    super.initState();
    _getRooms();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      _focusContent.requestFocus();
    });
  }

  @override
  void dispose() {
    _controllerSearch.dispose();
    _controllerContent.dispose();
    _focusSearch.dispose();
    _focusContent.dispose();
    super.dispose();
  }

  _getRooms() async {
    if (mounted) {
      roomListData = await ChatConnection.roomList();
      _getRoomVisible();
      setState(() {});
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        roomListData = await ChatConnection.roomList();
        _getRoomVisible();
        setState(() {});
      });
    }
  }

  _getRoomVisible() {
    final val = _controllerSearch.value.text.toLowerCase().trim();
    if (val.isNotEmpty) {
      roomListVisible = Room();
      roomListVisible?.rooms = roomListData?.rooms?.where((element) {
            try {
              if (element.isGroup == true) {
                return (element.title ?? '').toLowerCase().contains(val);
              }
              final p = element.people!
                  .firstWhere((e) => e.sId != ChatConnection.user!.id);
              return '${p.firstName} ${p.lastName}'.toLowerCase().contains(val);
            } catch (_) {
              return false;
            }
          }).toList() ??
          [];
    } else {
      roomListVisible = Room();
      roomListVisible?.limit = roomListData?.limit;
      try {
        roomListVisible?.rooms = <Rooms>[...roomListData!.rooms!.toList()];
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
            onPressed: () => Navigator.of(context).pop(_isSentCurrentChatRoom),
          ),
          title: Text(
            AppLocalizations.text(LangKey.forwardMessage),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 17,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFE7EAEF)),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildMessagePreview(),
              _buildSearchBar(),
              Expanded(child: _buildRoomList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagePreview() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E3E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildForwardedContent(),
          const Divider(height: 1, color: Color(0xFFE0E3E8)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: TextField(
              focusNode: _focusContent,
              controller: _controllerContent,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration.collapsed(
                hintText: AppLocalizations.text(LangKey.inputMessageOptional),
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForwardedContent() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 3,
            decoration: const BoxDecoration(
              color: Color(0xFF2196F3),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: _buildMessageContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    final msg = widget.message;
    if (msg is types.TextMessage) {
      return Text(
        msg.text,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
      );
    }
    if (msg is types.ImageMessage) {
      return SizedBox(
        height: 72,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: '${msg.uri}/${ChatConnection.brandCode ?? ''}',
                httpHeaders: {'brand-code': ChatConnection.brandCode ?? ''},
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                placeholder: (_, __) => const CupertinoActivityIndicator(),
                errorWidget: (_, __, ___) =>
                    const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }
    if (msg is types.FileMessage) {
      return Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.insert_drive_file,
                color: Colors.grey, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  formatBytes(msg.size.truncate()),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.search, color: Colors.grey, size: 20),
            ),
            Expanded(
              child: TextField(
                focusNode: _focusSearch,
                controller: _controllerSearch,
                style: const TextStyle(fontSize: 14),
                onChanged: (_) => setState(() => _getRoomVisible()),
                decoration: InputDecoration.collapsed(
                  hintText: AppLocalizations.text(LangKey.searchUserAndGroup),
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            ),
            if (_controllerSearch.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _controllerSearch.clear();
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() => _getRoomVisible());
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.close, color: Colors.grey, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomList() {
    final rooms = roomListVisible?.rooms;
    if (rooms == null) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (rooms.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.text(LangKey.searchChats),
          style: const TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: rooms.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 62,
        endIndent: 0,
        color: Color(0xFFF0F2F5),
      ),
      itemBuilder: (context, index) => _buildRoomItem(rooms[index]),
    );
  }

  Widget _buildRoomItem(Rooms data) {
    final info = getPeople(data.people);
    final sent = idSent.contains(data.sId);
    final name = data.isGroup == true
        ? data.title ??
            '${AppLocalizations.text(LangKey.group)} ${info.firstName ?? ''} ${info.lastName ?? ''}'
        : '${info.firstName ?? ''} ${info.lastName ?? ''}'.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          _buildAvatar(data, info),
          const SizedBox(width: 12),
          Expanded(
            child: AutoSizeText(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildSendButton(data, sent),
        ],
      ),
    );
  }

  Widget _buildAvatar(Rooms data, People info) {
    const double radius = 22;
    if (data.isGroup == true) {
      return data.room_avatar != null
          ? CircleAvatar(
              radius: radius,
              backgroundImage: CachedNetworkImageProvider(
                '${HTTPConnection.domain}api/images/${data.room_avatar!.shieldedID}/256/${ChatConnection.brandCode ?? ''}',
                headers: {'brand-code': ChatConnection.brandCode ?? ''},
              ),
              backgroundColor: Colors.transparent,
            )
          : ChatGroupAvatar(people: data.people, size: radius * 2);
    }
    if (info.picture != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(
          '${HTTPConnection.domain}api/images/${info.picture!.shieldedID}/256/${ChatConnection.brandCode ?? ''}',
          headers: {'brand-code': ChatConnection.brandCode ?? ''},
        ),
        backgroundColor: Colors.transparent,
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: getAvatarColor(info.sId),
      child: Text(
        getAvatarName(info.firstName, info.lastName),
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildSendButton(Rooms data, bool sent) {
    return SizedBox(
      height: 34,
      child: OutlinedButton(
        onPressed: sent
            ? null
            : () async {
                final result = await ChatConnection.forwardMessage(
                  _controllerContent.text,
                  c.Room.fromJson(data.toJson()),
                  ChatConnection.user!.id,
                  widget.message.id,
                );
                if (result) {
                  idSent.add(data.sId);
                  if (data.sId == ChatConnection.roomId) {
                    _isSentCurrentChatRoom = true;
                  }
                  setState(() {});
                }
              },
        style: OutlinedButton.styleFrom(
          foregroundColor: sent ? Colors.grey : const Color(0xFF2196F3),
          side: BorderSide(
            color: sent ? Colors.grey.shade300 : const Color(0xFF2196F3),
          ),
          backgroundColor: sent ? Colors.grey.shade100 : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        child: Text(
          sent
              ? AppLocalizations.text(LangKey.sent)
              : AppLocalizations.text(LangKey.send),
        ),
      ),
    );
  }

  People getPeople(List<People>? people) {
    if (people == null || people.isEmpty) return People();
    return people.first.sId != ChatConnection.user!.id
        ? people.first
        : people.last;
  }
}
