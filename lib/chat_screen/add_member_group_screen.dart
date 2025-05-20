import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
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

import '../data_model/chat_message.dart';
import '../data_model/response/friend_response_model.dart';
import '../data_model/response/group_member_response_model.dart';

class AddMemberGroupScreen extends StatefulWidget {
  final r.Rooms roomData;
  final String? chanel_id;
  final ChatMessage chatMessage;

  const AddMemberGroupScreen(
      {Key? key,
      required this.roomData,
      this.chanel_id,
      required this.chatMessage})
      : super(key: key);
  @override
  _AddMemberGroupScreenState createState() => _AddMemberGroupScreenState();
}

class _AddMemberGroupScreenState extends AppLifeCycle<AddMemberGroupScreen> {
  final _focusSearch = FocusNode();
  final _controllerSearch = TextEditingController();
  FriendListResponse? contactsListVisible;
  FriendListResponse? contactsListData;
  Contacts? contactsListDataChat;
  Contacts? contactsListDataChatVisible;
  UserZaloOAList? userZaloOAList;
  UserZaloOAList? userZaloOAListVisible;
  bool isInitScreen = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (mounted) {
        ChatConnection.isChatHub
            ? await _getContacts()
            : await _getContactsChat();
      }
      isInitScreen = false;
    });
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
                                child: SizedBox(
                                    width: 30.0,
                                    child: Icon(
                                        Platform.isIOS
                                            ? Icons.arrow_back_ios
                                            : Icons.arrow_back,
                                        color: Colors.black)),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 3.0, left: 10.0, right: 10.0, top: 2.0),
                            child: Text(
                                AppLocalizations.text(LangKey.addMember),
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
                                hintText: AppLocalizations.text(LangKey.search),
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
                ChatConnection.isChatHub
                    ? widget.roomData.channel?.source == 'zalo'
                        ? Expanded(
                            child: isInitScreen
                                ? Center(
                                    child: Platform.isAndroid
                                        ? const CircularProgressIndicator()
                                        : const CupertinoActivityIndicator())
                                : userZaloOAListVisible != null
                                    ? ListView.builder(
                                        keyboardDismissBehavior:
                                            ScrollViewKeyboardDismissBehavior
                                                .onDrag,
                                        itemCount: userZaloOAListVisible!
                                                .users?.length ??
                                            0,
                                        itemBuilder: (BuildContext context,
                                            int position) {
                                          return InkWell(
                                              onTap: () async {
                                                userZaloOAListVisible!
                                                        .users![position]
                                                        .isSelected =
                                                    !userZaloOAListVisible!
                                                        .users![position]
                                                        .isSelected;

                                                setState(() {});
                                              },
                                              child: _contactsZaloOA(
                                                  userZaloOAListVisible!
                                                      .users![position],
                                                  position ==
                                                      userZaloOAListVisible!
                                                              .users!.length -
                                                          1));
                                        })
                                    : Container(),
                          )
                        : Expanded(
                            child: isInitScreen
                                ? Center(
                                    child: Platform.isAndroid
                                        ? const CircularProgressIndicator()
                                        : const CupertinoActivityIndicator())
                                : contactsListVisible != null
                                    ? ListView.builder(
                                        keyboardDismissBehavior:
                                            ScrollViewKeyboardDismissBehavior
                                                .onDrag,
                                        itemCount: contactsListVisible!
                                                .friends?.length ??
                                            0,
                                        itemBuilder: (BuildContext context,
                                            int position) {
                                          return InkWell(
                                              onTap: () async {
                                                setState(() {
                                                  if (contactsListVisible!
                                                          .friends![position]
                                                          .isSelected !=
                                                      null) {
                                                    contactsListVisible!
                                                            .friends![position]
                                                            .isSelected =
                                                        !contactsListVisible!
                                                            .friends![position]
                                                            .isSelected!;
                                                  } else {
                                                    contactsListVisible!
                                                        .friends![position]
                                                        .isSelected = true;
                                                  }
                                                });
                                              },
                                              child: _contacts(
                                                  contactsListVisible!
                                                      .friends![position],
                                                  position ==
                                                      contactsListVisible!
                                                              .friends!.length -
                                                          1));
                                        })
                                    : Container(),
                          )
                    : Expanded(
                        child: isInitScreen
                            ? Center(
                                child: Platform.isAndroid
                                    ? const CircularProgressIndicator()
                                    : const CupertinoActivityIndicator())
                            : contactsListDataChatVisible != null
                                ? ListView.builder(
                                    keyboardDismissBehavior:
                                        ScrollViewKeyboardDismissBehavior
                                            .onDrag,
                                    itemCount: contactsListDataChatVisible!
                                            .users?.length ??
                                        0,
                                    itemBuilder:
                                        (BuildContext context, int position) {
                                      return InkWell(
                                          onTap: () async {
                                            setState(() {
                                              if (contactsListDataChatVisible!
                                                      .users![position]
                                                      .isSelected !=
                                                  null) {
                                                contactsListDataChatVisible!
                                                        .users![position]
                                                        .isSelected =
                                                    !contactsListDataChatVisible!
                                                        .users![position]
                                                        .isSelected!;
                                              } else {
                                                contactsListDataChatVisible!
                                                    .users![position]
                                                    .isSelected = true;
                                              }
                                            });
                                          },
                                          child: _contactChat(
                                              contactsListDataChatVisible!
                                                  .users![position],
                                              position ==
                                                  contactsListDataChatVisible!
                                                          .users!.length -
                                                      1));
                                    })
                                : Container(),
                      ),
                ((contactsListVisible != null &&
                            isSelectedMember(contactsListVisible?.friends)) ||
                        (contactsListDataChatVisible != null &&
                            isSelectedMemberChat(
                                contactsListDataChatVisible?.users)) ||
                        (userZaloOAListVisible != null &&
                            isSelectedMemberZaloOA(
                                userZaloOAListVisible?.users)))
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: SizedBox(
                          height: 49.0,
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: MaterialButton(
                            color: const Color(0xFF5686E1),
                            onPressed: () async {
                              ChatConnection.isChatHub
                                  ? widget.roomData.channel?.source == 'zalo'
                                      ? addMemberZaloOA()
                                      : addMember()
                                  : addMemberChat();
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(
                              AppLocalizations.text(LangKey.addMember),
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
      ),
    );
  }

  _getContactsChat() async {
    contactsListDataChat = await ChatConnection.contactsList();
    widget.roomData.people?.forEach((e) {
      try {
        People? user = contactsListDataChat?.users
            ?.firstWhere((element) => e.sId == element.sId);
        if (user != null) {
          contactsListDataChat?.users?.remove(user);
        }
      } catch (_) {}
    });
    _getContactsVisibleChat();
    setState(() {});
  }

  _getContacts() async {
    if (widget.roomData.channel?.source == 'zalo') {
      userZaloOAList = await ChatConnection.getListUserZaloOA(
          source: widget.roomData.source ?? 'zalo',
          search: _controllerSearch.text);
      _getContactsVisibleZaloOA();
    } else {
      contactsListData =
          await ChatConnection.getListFriend(widget.chanel_id ?? '');
      _getContactsVisible();
    }

    setState(() {});
  }

  _getContactsVisibleZaloOA() {
    String val = _controllerSearch.value.text.toLowerCase().removeAccents();
    if (val != '') {
      userZaloOAListVisible?.users =
          userZaloOAListVisible!.users?.where((element) {
        try {
          if (('${element.username} ' //${element.lastName}'
                  .toLowerCase()
                  .removeAccents())
              .contains(val)) {
            return true;
          }
          return false;
        } catch (e) {
          return false;
        }
      }).toList();
    } else {
      userZaloOAListVisible = r.UserZaloOAList();
      userZaloOAListVisible = userZaloOAList;
      try {
        userZaloOAListVisible?.users = <UserZaloOA>[
          ...userZaloOAListVisible!.users!.toList()
        ];
      } catch (_) {}
    }
  }

  _getContactsVisibleChat() {
    String val = _controllerSearch.value.text.toLowerCase().removeAccents();
    if (val != '') {
      contactsListDataChatVisible!.users =
          contactsListDataChatVisible!.users!.where((element) {
        try {
          if (('${element.firstName} ${element.lastName}'
                  .toLowerCase()
                  .removeAccents())
              .contains(val)) {
            return true;
          }
          return false;
        } catch (e) {
          return false;
        }
      }).toList();
    } else {
      contactsListDataChatVisible = Contacts();
      contactsListDataChatVisible?.limit = contactsListDataChat?.limit;
      contactsListDataChatVisible?.search = contactsListDataChat?.search;
      try {
        contactsListDataChatVisible?.users = <r.People>[
          ...contactsListDataChat!.users!.toList()
        ];
      } catch (_) {}
    }
  }

  _getContactsVisible() {
    String val = _controllerSearch.value.text.toLowerCase().removeAccents();
    if (val != '') {
      contactsListVisible?.friends =
          contactsListVisible!.friends?.where((element) {
        try {
          if (('${element.username} ' //${element.lastName}'
                  .toLowerCase()
                  .removeAccents())
              .contains(val)) {
            return true;
          }
          return false;
        } catch (e) {
          return false;
        }
      }).toList();
    } else {
      contactsListVisible = FriendListResponse();
      contactsListVisible = contactsListData;
      try {
        contactsListVisible?.friends = <FriendModel>[
          ...contactsListData!.friends!.toList()
        ];
      } catch (_) {}
    }
  }

  void addMemberZaloOA() async {
    List<String> people = [];
    try {
      userZaloOAList?.users?.forEach((element) {
        if (element.isSelected != null && element.isSelected == true) {
          people.add(element.userSocialId);
        }
      });
    } catch (_) {}

    if (people.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.text(LangKey.warning)),
          content: Text(AppLocalizations.text(LangKey.selectAtleastOneUser)),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.text(LangKey.accept)))
          ],
        ),
      );
    } else {
      final result = await ChatConnection.inviteMember(
        widget.chatMessage.room?.oa_group_id,
        people,
        widget.roomData.channel!.sId!,
      );
      if (result!.isSuccess) {
        Navigator.of(context).pop();
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.text(LangKey.warning)),
            content: Text(result.message),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.text(LangKey.accept)))
            ],
          ),
        );
      }
    }
  }

  bool isSelectedMemberZaloOA(List<UserZaloOA>? data) {
    try {
      data?.firstWhere((element) => element.isSelected == true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Widget _contactsZaloOA(UserZaloOA data, bool isLast) {
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
                    if (data.picture != null)
                      CircleAvatar(
                        radius: 25.0,
                        backgroundImage: CachedNetworkImageProvider(
                            '${HTTPConnection.domain}api/images/${data.picture!.shieldedID}/256/${ChatConnection.brandCode!}',
                            headers: {'brand-code': ChatConnection.brandCode!}),
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
                              '${data.fullName}',
                              maxLines: 1,
                            ),
                          ),
                          Container(
                            height: 5.0,
                          ),
                          Expanded(
                              child: AutoSizeText(
                            '@${data.id}',
                            overflow: TextOverflow.ellipsis,
                          ))
                        ],
                      ),
                    )),
                    SizedBox(
                      height: 30.0,
                      width: 30.0,
                      child: data.isSelected != null && data.isSelected!
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

  void addMember() async {
    List<String> people = [];
    try {
      contactsListData?.friends?.forEach((element) {
        if (element.isSelected != null && element.isSelected == true) {
          people.add(element.userId);
        }
      });
    } catch (_) {}

    if (people.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.text(LangKey.warning)),
          content: Text(AppLocalizations.text(LangKey.selectAtleastOneUser)),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.text(LangKey.accept)))
          ],
        ),
      );
    } else {
      final result = await ChatConnection.addUserGroup(people,
          widget.chanel_id ?? '', widget.chatMessage.room?.oa_group_id ?? '');
      // await ChatConnection.addMemberGroup(people, widget.roomData.sId!);
      if (result.isSuccess) {
        try {
          contactsListData?.friends?.forEach((element) {
            if (element.isSelected != null && element.isSelected == true) {
              // widget.roomData.people?.add(element);
            }
          });
        } catch (_) {}
        Navigator.of(context).pop();
        try {
          ChatConnection.refreshRoom.call();
          ChatConnection.refreshFavorites.call();
        } catch (_) {}
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.text(LangKey.warning)),
            content: Text(result.message),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.text(LangKey.accept)))
            ],
          ),
        );
      }
    }
  }

  void addMemberChat() async {
    List<String> people = [];
    try {
      contactsListDataChat?.users?.forEach((element) {
        if (element.isSelected != null && element.isSelected == true) {
          people.add(element.sId!);
        }
      });
    } catch (_) {}
    if (people.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(AppLocalizations.text(LangKey.warning)),
          content: Text(AppLocalizations.text(LangKey.selectAtleastOneUser)),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.text(LangKey.accept)))
          ],
        ),
      );
    } else {
      bool result =
          await ChatConnection.addMemberGroup(people, widget.roomData.sId!);
      if (result) {
        try {
          contactsListDataChat?.users?.forEach((element) {
            if (element.isSelected != null && element.isSelected == true) {
              widget.roomData.people?.add(element);
            }
          });
        } catch (_) {}
        Navigator.of(context).pop();
        try {
          ChatConnection.refreshRoom.call();
          ChatConnection.refreshFavorites.call();
        } catch (_) {}
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppLocalizations.text(LangKey.warning)),
            content: Text(AppLocalizations.text(LangKey.addMemberFailed)),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.text(LangKey.accept)))
            ],
          ),
        );
      }
    }
  }

  bool isSelectedMember(List<FriendModel>? data) {
    try {
      data?.firstWhere((element) => element.isSelected == true);
      return true;
    } catch (_) {
      return false;
    }
  }

  bool isSelectedMemberChat(List<People>? data) {
    try {
      data?.firstWhere((element) => element.isSelected == true);
      return true;
    } catch (_) {
      return false;
    }
  }

  Widget _contacts(FriendModel data, bool isLast) {
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
                    if (data.avatar.isNotEmpty)
                      CircleAvatar(
                        radius: 25.0,
                        child: Image.network(data.avatar),
                        // child: Text(data.getAvatarName()),
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
                              '${data.displayName}',
                              maxLines: 1,
                            ),
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
                      child: data.isSelected != null && data.isSelected!
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

  Widget _contactChat(People data, bool isLast) {
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
                            child: Text(data.getAvatarName()),
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
                              '${data.firstName} ${data.lastName}',
                              maxLines: 1,
                            ),
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
                      child: data.isSelected != null && data.isSelected!
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
