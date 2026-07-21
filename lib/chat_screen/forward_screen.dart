import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_ui/util.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:chat/presentation/utils/ultility.dart'
    show getAvatarColor, getAvatarTextColor;
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
    String val = _controllerSearch.value.text.toLowerCase();
    if (val != '') {
      roomListVisible!.rooms = roomListVisible!.rooms!.where((element) {
        try {
          People p = element.people!
              .firstWhere((e) => e.sId != ChatConnection.user!.id);
          if (!element.isGroup!
              ? ('${p.firstName} ${p.lastName}'.toLowerCase()).contains(val)
              : element.title!.toLowerCase().contains(val)) {
            return true;
          }
          return false;
        } catch (e) {
          return false;
        }
      }).toList();
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
          appBar: AppBar(
            title: AutoSizeText(
              AppLocalizations.text(LangKey.forwardMessage),
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            leading: InkWell(
              child: Icon(
                  Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                  color: Colors.black),
              onTap: () => Navigator.of(context).pop(_isSentCurrentChatRoom),
            ),
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFFE7EAEF),
                        borderRadius: BorderRadius.circular(5)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Icon(
                                Icons.format_quote,
                                color: Colors.black,
                                size: 15.0,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: _buildMessagePreview(context),
                              ),
                            )
                          ],
                        ),
                        Container(height: 1.0, color: Colors.grey.shade500),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: SizedBox(
                            child: TextField(
                              focusNode: _focusContent,
                              controller: _controllerContent,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: InputDecoration.collapsed(
                                hintText: AppLocalizations.text(
                                    LangKey.inputMessageOptional),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                        color: const Color(0xFFE7EAEF),
                        borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Center(
                            child: Icon(
                              Icons.search,
                            ),
                          ),
                        ),
                        Expanded(
                            child: TextField(
                          focusNode: _focusSearch,
                          controller: _controllerSearch,
                          onChanged: (_) {
                            setState(() {
                              _getRoomVisible();
                            });
                          },
                          decoration: InputDecoration.collapsed(
                            hintText: AppLocalizations.text(
                                LangKey.searchUserAndGroup),
                          ),
                        )),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(5),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Center(
                                child: Icon(
                                  Icons.close,
                                ),
                              ),
                            ),
                            onTap: () {
                              _controllerSearch.text = '';
                              FocusManager.instance.primaryFocus?.unfocus();
                              _getRoomVisible();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                    child: roomListVisible != null
                        ? ListView.builder(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            itemCount: roomListVisible!.rooms?.length ?? 0,
                            itemBuilder: (BuildContext context, int position) {
                              return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: _room(
                                      roomListVisible!.rooms![position],
                                      position ==
                                          roomListVisible!.rooms!.length - 1));
                            })
                        : Container())
              ],
            ),
          )),
    );
  }

  // Họ + tên người gửi gốc của tin đang forward (ưu tiên data server c.Messages).
  String _senderName() {
    final a = widget.value?.author;
    final first = a?.firstName ?? widget.message.author.firstName ?? '';
    final last = a?.lastName ?? widget.message.author.lastName ?? '';
    return '$first $last'.trim();
  }

  // Chọn preview theo đúng kiểu message, KHÔNG cast mù sang FileMessage.
  // (CustomMessage: sticker/video/link/system/products... trước đây bị ép kiểu -> crash)
  Widget _buildMessagePreview(BuildContext context) {
    final message = widget.message;
    Widget content;
    if (message is types.TextMessage) {
      content = checkTag(message.text);
    } else if (message is types.ImageMessage) {
      content = _imagePreview(message.uri);
    } else if (message is types.FileMessage) {
      content = _filePreview(
        message.name,
        formatBytes(message.size.truncate()),
      );
    } else if (message is types.CustomMessage) {
      content = _customPreview(message);
    } else {
      content = _filePreview(AppLocalizations.text(LangKey.file), null);
    }

    final name = _senderName();
    if (name.isEmpty) return content;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff5686E1),
          ),
        ),
        const SizedBox(height: 4),
        content,
      ],
    );
  }

  Widget _imagePreview(String uri) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.15,
            height: MediaQuery.of(context).size.width * 0.25,
            child: CachedNetworkImage(
              imageUrl: '$uri/${ChatConnection.brandCode!}',
              httpHeaders: {'brand-code': ChatConnection.brandCode!},
              placeholder: (context, url) => const CupertinoActivityIndicator(),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.image_not_supported, color: Colors.grey),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget _filePreview(String title, String? subtitle, {IconData? icon}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(21),
          ),
          height: 42,
          width: 42,
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, color: Colors.grey)
              : Image.asset(
                  'assets/icon-document.png',
                  color: Colors.grey,
                  package: 'chat',
                ),
        ),
        Flexible(
          child: Container(
            margin: const EdgeInsetsDirectional.only(start: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  textWidthBasis: TextWidthBasis.longestLine,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (subtitle != null && subtitle.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    child: Text(subtitle),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _customPreview(types.CustomMessage message) {
    final meta = message.metadata ?? const {};
    final type = meta['custom_type'] as String?;
    if (type == 'recalled') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          AppLocalizations.text(LangKey.messageRecalled),
          style: TextStyle(
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    final rawLabel =
        (meta['title'] ?? meta['text'] ?? meta['description'] ?? meta['name'])
            ?.toString()
            .trim();
    final isMedia = type == 'image_url' || type == 'video' || type == 'sticker';
    return _filePreview(
      rawLabel != null && rawLabel.isNotEmpty
          ? rawLabel
          : AppLocalizations.text(LangKey.file),
      null,
      icon: isMedia ? Icons.perm_media : Icons.description,
    );
  }

  Widget checkTag(String message) {
    Widget _widget;
    List<InlineSpan> _arr = [];
    List<String> contents = message.split(' ');
    for (int i = 0; i < contents.length; i++) {
      var element = contents[i];
      if (element == '@all-all@') {
        element = '@${AppLocalizations.text(LangKey.all)}';
        _arr.add(TextSpan(
            text: '$element ',
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)));
      } else {
        try {
          if (element[element.length - 1] == '@' && element.contains('-')) {
            element = element.split('-').first;
            _arr.add(TextSpan(
                text: '$element ',
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)));
          } else {
            _arr.add(TextSpan(
                text: i == contents.length - 1 ? element : '$element ',
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.normal)));
          }
        } catch (_) {
          _arr.add(TextSpan(
              text: i == contents.length - 1 ? element : '$element ',
              style: TextStyle(
                  color: Colors.grey.shade700, fontWeight: FontWeight.normal)));
        }
      }
    }
    _widget = Text.rich(
      TextSpan(
        children: _arr,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
    return _widget;
  }

  Widget _room(Rooms data, bool isLast) {
    People info = getPeople(data.people);
    return Column(
      children: [
        SizedBox(
          child: SizedBox(
            height: 40.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  !data.isGroup!
                      ? info.picture == null
                          ? CircleAvatar(
                              radius: 16.0,
                              backgroundColor: getAvatarColor(info.sId),
                              child: Text(
                                info.getAvatarName(),
                                style: TextStyle(
                                    color: getAvatarTextColor(info.sId),
                                    fontSize: 12),
                              ),
                            )
                          : CircleAvatar(
                              radius: 16.0,
                              backgroundImage: CachedNetworkImageProvider(
                                  '${HTTPConnection.domain}api/images/${info.picture!.shieldedID}/256/${ChatConnection.brandCode!}',
                                  headers: {
                                    'brand-code': ChatConnection.brandCode!
                                  }),
                              backgroundColor: Colors.transparent,
                            )
                      : data.room_avatar == null
                          ? CircleAvatar(
                              radius: 16.0,
                              backgroundColor: getAvatarColor(data.sId),
                              child: Text(
                                data.getAvatarGroupName(),
                                style: TextStyle(
                                    color: getAvatarTextColor(data.sId),
                                    fontSize: 12),
                              ),
                            )
                          : CircleAvatar(
                              radius: 16.0,
                              backgroundImage: CachedNetworkImageProvider(
                                  '${HTTPConnection.domain}api/images/${data.room_avatar!.shieldedID}/256/${ChatConnection.brandCode!}',
                                  headers: {
                                    'brand-code': ChatConnection.brandCode!
                                  }),
                              backgroundColor: Colors.transparent,
                            ),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.only(
                        top: 2.0, bottom: 2.0, left: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Row(
                          children: [
                            Expanded(
                              child: AutoSizeText(
                                  !data.isGroup!
                                      ? '${info.firstName} ${info.lastName}'
                                      : data.title ??
                                          '${AppLocalizations.text(LangKey.group)} ${info.firstName} ${info.lastName}',
                                  overflow: TextOverflow.ellipsis),
                            ),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(4.0),
                                onTap: () async {
                                  if (!idSent.contains(data.sId)) {
                                    bool result =
                                        await ChatConnection.forwardMessage(
                                            _controllerContent.text,
                                            c.Room.fromJson(data.toJson()),
                                            ChatConnection.user!.id,
                                            widget.message.id);
                                    if (result) {
                                      idSent.add(data.sId);
                                      if (data.sId == ChatConnection.roomId) {
                                        _isSentCurrentChatRoom = true;
                                      }
                                      setState(() {});
                                    }
                                  }
                                },
                                child: Container(
                                  constraints:
                                      const BoxConstraints(minWidth: 50.0),
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 4.0),
                                  decoration: BoxDecoration(
                                    color: idSent.contains(data.sId)
                                        ? Colors.grey
                                        : Colors.blue,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: AutoSizeText(
                                    idSent.contains(data.sId)
                                        ? AppLocalizations.text(LangKey.sent)
                                        : AppLocalizations.text(LangKey.send),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: idSent.contains(data.sId)
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )),
                        Container(
                          height: 5.0,
                        ),
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
            : Container()
      ],
    );
  }

  People getPeople(List<People>? people) {
    return people!.first.sId != ChatConnection.user!.id
        ? people.first
        : people.last;
  }
}
