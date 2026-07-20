import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/presentation/chat_module/ui/chat_screen.dart';
import 'package:chat/presentation/utils/ultility.dart' show getAvatarColor;
import 'package:chat/chat_ui/vietnamese_text.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/contact.dart';
import 'package:chat/data_model/room.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/room.dart' as r;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/connection/app_lifecycle.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);
  @override
  _CreateGroupScreenState createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends AppLifeCycle<CreateGroupScreen> {
  final _focusSearch = FocusNode();
  final _controllerSearch = TextEditingController();
  final _focusGroupName = FocusNode();
  final _controllerGroupName = TextEditingController();
  final Set<String> _selectedIds = {};
  Contacts? contactsListVisible;
  Contacts? contactsListData;
  bool isInitScreen = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getContacts();
      isInitScreen = false;
    });
  }

  _getContacts() async {
    contactsListData = await ChatConnection.contactsList();
    _getContactsVisible();
    setState(() {});
  }

  _getContactsVisible() {
    String val = _controllerSearch.value.text.toLowerCase().removeAccents();
    if (val != '') {
      contactsListVisible!.users = contactsListVisible!.users!.where((element) {
        try {
          if (('${element.firstName} ${element.lastName}'
                  .toLowerCase()
                  .removeAccents())
              .contains(val)) {
            return true;
          }
          if (element.username?.toLowerCase().contains(val) ?? false) {
            return true;
          }
          return false;
        } catch (e) {
          return false;
        }
      }).toList();
    } else {
      contactsListVisible = Contacts();
      contactsListVisible?.limit = contactsListData?.limit;
      contactsListVisible?.search = contactsListData?.search;
      try {
        contactsListVisible?.users = <r.People>[
          ...contactsListData!.users!.toList()
        ];
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
        color: Colors.white,
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 30.0,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 5.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const SizedBox(
                                      width: 30.0,
                                      child: Icon(Icons.arrow_back_ios,
                                          color: Colors.black)),
                                ),
                              ],
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 3.0,
                                  left: 10.0,
                                  right: 10.0,
                                  top: 2.0),
                              child: Text(
                                  AppLocalizations.text(LangKey.newGroupChat),
                                  style: const TextStyle(
                                      fontSize: 22.0, color: Colors.black)),
                            ),
                          )
                        ],
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
                                    _getContactsVisible();
                                  });
                                },
                                decoration: InputDecoration.collapsed(
                                  hintText:
                                      AppLocalizations.text(LangKey.search),
                                ),
                              )),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(5),
                                  child: const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Center(
                                      child: Icon(
                                        Icons.close,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    _controllerSearch.text = '';
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    _getContactsVisible();
                                  },
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  Expanded(
                    child: isInitScreen
                        ? Center(
                            child: Platform.isAndroid
                                ? const CircularProgressIndicator()
                                : const CupertinoActivityIndicator())
                        : contactsListVisible != null
                            ? ListView.builder(
                                keyboardDismissBehavior:
                                    ScrollViewKeyboardDismissBehavior.onDrag,
                                itemCount:
                                    contactsListVisible!.users?.length ?? 0,
                                itemBuilder:
                                    (BuildContext context, int position) {
                                  return InkWell(
                                      onTap: () async {
                                        final id = contactsListVisible!
                                            .users![position].sId;
                                        if (id == null) return;
                                        setState(() {
                                          if (_selectedIds.contains(id)) {
                                            _selectedIds.remove(id);
                                          } else {
                                            _selectedIds.add(id);
                                          }
                                        });
                                      },
                                      child: _contacts(
                                          contactsListVisible!.users![position],
                                          position ==
                                              contactsListVisible!
                                                      .users!.length -
                                                  1));
                                })
                            : Container(),
                  ),
                  _selectedIds.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: SizedBox(
                            height: 49.0,
                            width: MediaQuery.of(context).size.width * 0.85,
                            child: MaterialButton(
                              color: const Color(0xFF5686E1),
                              onPressed: () {
                                if (_selectedIds.isEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text(AppLocalizations.text(
                                          LangKey.warning)),
                                      content: Text(AppLocalizations.text(
                                          LangKey.selectAtleastOneUser)),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(AppLocalizations.text(
                                                LangKey.accept)))
                                      ],
                                    ),
                                  );
                                  return;
                                }
                                _showGroupNameSheet();
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Text(
                                AppLocalizations.text(LangKey.createGroup),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        )
                      : Container()
                ],
              ),
            ),
          ),
        ));
  }

  // Bottomsheet nhập tên nhóm khi bấm "Tạo nhóm".
  void _showGroupNameSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  AppLocalizations.text(LangKey.groupName),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey, width: 1.0),
                  ),
                  child: Center(
                    child: TextField(
                      focusNode: _focusGroupName,
                      controller: _controllerGroupName,
                      autofocus: true,
                      decoration: InputDecoration.collapsed(
                        hintText: AppLocalizations.text(LangKey.groupName),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: MaterialButton(
                    color: const Color(0xFF5686E1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    onPressed: () {
                      if (_controllerGroupName.value.text.trim().isEmpty) {
                        return;
                      }
                      Navigator.of(ctx).pop();
                      _createGroup();
                    },
                    child: Text(
                      AppLocalizations.text(LangKey.createGroup),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _createGroup() async {
    final List<String> people = List.from(_selectedIds);
    if (people.isEmpty) return;
    people.add(ChatConnection.user!.id);
    r.Rooms? rooms = await ChatConnection.createGroup(
        _controllerGroupName.text.trim(), people, ChatConnection.user!.id);
    if (rooms == null) return;
    await Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(
          builder: (context) => ChatScreen(data: rooms),
          settings: const RouteSettings(name: 'chat_screen')),
    );
    try {
      ChatConnection.refreshRoom.call();
      ChatConnection.refreshFavorites.call();
    } catch (_) {}
  }

  bool isSelectedMember(List<People>? data) {
    return _selectedIds.isNotEmpty;
  }

  Widget _contacts(People data, bool isLast) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [
          SizedBox(
            child: SizedBox(
              height: 50.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    data.picture == null
                        ? CircleAvatar(
                            radius: 25.0,
                            backgroundColor: getAvatarColor(data.sId),
                            child: Text(data.getAvatarName(),
                                style: const TextStyle(color: Colors.white)),
                          )
                        : CircleAvatar(
                            radius: 25.0,
                            backgroundImage: CachedNetworkImageProvider(
                                '${HTTPConnection.domain}api/images/${data.picture!.shieldedID}/256/${ChatConnection.brandCode!}',
                                headers: {
                                  'brand-code': ChatConnection.brandCode!
                                }),
                            backgroundColor: Colors.transparent,
                          ),
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
                                '${data.firstName} ${data.lastName}'),
                          ),
                          Container(
                            height: 5.0,
                          ),
                          Expanded(
                              child: AutoSizeText(
                            '@${data.username}',
                            overflow: TextOverflow.ellipsis,
                          ))
                        ],
                      ),
                    )),
                    SizedBox(
                      height: 30.0,
                      width: 30.0,
                      child: _selectedIds.contains(data.sId)
                          ? const Icon(Icons.radio_button_checked,
                              size: 25.0, color: Color(0xff0021F5))
                          : const Icon(Icons.radio_button_off,
                              size: 25.0, color: Color(0xff0021F5)),
                    )
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
}
