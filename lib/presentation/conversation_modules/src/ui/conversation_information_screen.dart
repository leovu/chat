import 'dart:io';
import 'package:chat/chat_ui/flutter_chat_ui.dart';
import 'package:chat/chat_ui/widgets/custom_message_builder.dart';
import 'package:chat/connection/download.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_screen/action_list_user_chathub_screen.dart';
import 'package:chat/chat_ui/widgets/custom_room_avatar.dart';
import 'package:chat/chat_ui/hex_color.dart';
import 'package:chat/common/constant.dart';
import 'package:chat/common/theme.dart';
import 'package:chat/common/widges/widget.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/customer_account.dart';
import 'package:chat/data_model/response/notes_response_model.dart';
import 'package:chat/data_model/room.dart' as r;
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:chat/presentation/conversation_modules/src/bloc/conversation_bloc.dart';
import 'package:chat/presentation/utils/media_query.dart';
import 'package:chat/presentation/utils/ultility.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../module/group_member/ui/chat_group_members_screen.dart';
import '../../../../chat_screen/conversation_file_screen.dart';
import '../../../../data_model/room.dart';
import '../../../../data_model/session.dart';
import '../../../chat_module/ui/chat_screen.dart';
import '../../../note_modules/ui/create_note_screen.dart';
import '../../../utils/dialog.dart';
import '../../../utils/formatter.dart';
import '../bloc/chatbot_bloc.dart';
import 'list_note_component.dart';

class ConversationInformationScreen extends StatefulWidget {
  final r.Rooms roomData;
  final c.ChatMessage? chatMessage;
  final bool? isChatBot;
  final Owner? groupOwner;

  const ConversationInformationScreen({
    Key? key,
    required this.roomData,
    this.chatMessage,
    this.isChatBot,
    this.groupOwner,
  }) : super(key: key);

  @override
  _ConversationInformationScreenState createState() =>
      _ConversationInformationScreenState();
}

class _ConversationInformationScreenState
    extends State<ConversationInformationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool isInitScreen = true;
  CustomerAccount? customerAccount;
  List<CustomerAccount?>? customerAccountSearch;
  bool expandedSocialInfo = false;
  late ConversationBloc _bloc;
  final chatbotService = ChatbotService();
  late Future<dynamic> customerFuture;
  bool isShowListSearch = false;

  void errorDialog({String? content}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.warning)),
        content: Text(
            content ?? AppLocalizations.text(LangKey.changeGroupNameError)),
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

  reload() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _bloc = ConversationBloc();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadAccount();
      if (ChatConnection.isChatHub) {
        _bloc.getNotes(widget.roomData.sId!);

        _bloc.getSession(widget.roomData.sId!);
      }
    });
  }

  void _loadAccount() async {
    if (ChatConnection.isChatHub) {
      String id = widget.chatMessage?.room?.owner?.sId ?? '';

      customerAccount = await ChatConnection.detect(id);
    }
    isInitScreen = false;
    setState(() {});
  }

  void _clearChat() async {
    final roomId = widget.roomData.sId;
    final fullName =
        '${widget.roomData.owner!.firstName} ${widget.roomData.owner!.lastName}';
    await showInfoDialog(
      context,
      AppLocalizations.text(LangKey.notifications),
      content:
          '${AppLocalizations.text(LangKey.confirm_delete_message)} $fullName',
      () async {
        await ChatConnection.clearChat(roomId!);
        Navigator.of(context, rootNavigator: true).pop();
      },
      onCancel: () async {
        Navigator.of(context).pop();
      },
    );
  }

  void _leaveRoom(String roomId) {
    showDialog(
      context: context,
      builder: (cxt) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.leaveConversation)),
        content: Text(AppLocalizations.text(LangKey.leaveConfirm)),
        actions: [
          ElevatedButton(
              onPressed: () async {
                bool value = await ChatConnection.leaveRoom(
                    roomId, ChatConnection.user?.id);
                Navigator.of(cxt).pop();
                if (value) {
                  try {
                    ChatConnection.refreshRoom.call();
                    ChatConnection.refreshFavorites.call();
                  } catch (_) {}
                  Navigator.of(context).popUntil(
                      (route) => route.settings.name == "chat_screen");
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (cxxt) => AlertDialog(
                      title: Text(AppLocalizations.text(LangKey.warning)),
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
              },
              child: Text(AppLocalizations.text(LangKey.leave))),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(cxt);
              },
              child: Text(AppLocalizations.text(LangKey.cancel))),
        ],
      ),
    );
  }

  void _removeLeaveRoom(String roomId) {
    showDialog(
      context: context,
      builder: (cxt) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.deleteConversation)),
        content: Text(AppLocalizations.text(LangKey.deleteConfirm)),
        actions: [
          ElevatedButton(
              onPressed: () {
                ChatConnection.leaveRoom(roomId, ChatConnection.user?.id)
                    .then((value) {
                  Navigator.of(cxt).pop();
                  if (value) {
                    try {
                      ChatConnection.refreshRoom.call();
                      ChatConnection.refreshFavorites.call();
                    } catch (_) {}
                    Navigator.of(context).popUntil(
                        (route) => route.settings.name == "chat_screen");
                    Navigator.of(context).pop();
                  } else {
                    showDialog(
                      context: context,
                      builder: (cxxt) => AlertDialog(
                        title: Text(AppLocalizations.text(LangKey.warning)),
                        content:
                            Text(AppLocalizations.text(LangKey.deleteError)),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(cxxt);
                              },
                              child:
                                  Text(AppLocalizations.text(LangKey.accept)))
                        ],
                      ),
                    );
                  }
                });
              },
              child: Text(AppLocalizations.text(LangKey.delete))),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(cxt);
              },
              child: Text(AppLocalizations.text(LangKey.cancel))),
        ],
      ),
    );
  }

  void _removeRoom(String roomId) {
    showDialog(
      context: context,
      builder: (cxt) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.deleteConversation)),
        content: Text(AppLocalizations.text(LangKey.deleteConfirm)),
        actions: [
          ElevatedButton(
              onPressed: () {
                ChatConnection.removeRoom(roomId).then((value) {
                  Navigator.of(cxt).pop();
                  if (value) {
                    try {
                      ChatConnection.refreshRoom.call();
                      ChatConnection.refreshFavorites.call();
                    } catch (_) {}
                    Navigator.of(context).popUntil(
                        (route) => route.settings.name == "chat_screen");
                    Navigator.of(context).pop();
                  } else {
                    showDialog(
                      context: context,
                      builder: (cxxt) => AlertDialog(
                        title: Text(AppLocalizations.text(LangKey.warning)),
                        content:
                            Text(AppLocalizations.text(LangKey.deleteError)),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(cxxt);
                              },
                              child:
                                  Text(AppLocalizations.text(LangKey.accept)))
                        ],
                      ),
                    );
                  }
                });
              },
              child: Text(AppLocalizations.text(LangKey.delete))),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(cxt);
              },
              child: Text(AppLocalizations.text(LangKey.cancel))),
        ],
      ),
    );
  }

  void editName() async {
    if (ChatConnection.editCustomerLead != null &&
        (customerAccount?.data?.type == 'customer' ||
            customerAccount?.data?.type == 'customerLead')) {
      await ChatConnection.editCustomerLead!(
          customerAccount?.data?.type == 'customer'
              ? customerAccount?.data?.customerCode
              : customerAccount?.data?.customerLeadCode,
          customerAccount?.data?.type,
          customerAccount?.data?.customerId);
      _loadAccount();
    } else {
      final FocusNode _focusNode = FocusNode();

      await showEditNameDialog(
        context: context,
        controller: _controller,
        focusNode: _focusNode,
        apiCall: (newName) async {
          if (ChatConnection.isChatHub) {
            return await ChatConnection.updateUserInfo(
                  widget.chatMessage?.room?.owner?.sId ?? '',
                  newName,
                  '',
                ) ??
                false;
          } else {
            return await ChatConnection.updateRoomName(
              widget.roomData.sId!,
              newName,
            );
          }
        },
        isChatHub: ChatConnection.isChatHub,
        onSuccess: () {
          if (ChatConnection.isChatHub) {
            customerAccount?.data?.fullName = _controller.value.text;
          } else {
            widget.roomData.title = _controller.value.text;
          }
          reload();
        },
        onError: () {
          errorDialog(
            content: ChatConnection.isChatHub
                ? LangKey.getFileError
                : AppLocalizations.text(LangKey.changeGroupNameError),
          );
        },
      );
    }
  }

  Future<void> showEditNameDialog({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Future<bool> Function(String newName) apiCall, // Hàm gọi API
    required bool isChatHub, // Điều kiện true/false
    required VoidCallback onSuccess, // Hàm callback khi thành công
    required VoidCallback onError, // Hàm callback khi thất bại
  }) async {
    controller.text = controller.text.isNotEmpty ? controller.text : '';
    focusNode.requestFocus();

    await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext cxtx, StateSetter setState) {
            return CupertinoAlertDialog(
              title: Text(AppLocalizations.text(LangKey.members)),
              content: Card(
                color: Colors.transparent,
                elevation: 0.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 3.0),
                      child: CupertinoTextField(
                        controller: controller,
                        focusNode: focusNode,
                        placeholder: AppLocalizations.text(LangKey.members),
                      ),
                    ),
                    CupertinoButton(
                      child: Text(AppLocalizations.text(LangKey.accept)),
                      onPressed: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.of(context).pop();

                        bool result = await apiCall(controller.value.text);

                        if (result) {
                          onSuccess(); // Gọi callback khi thành công
                        } else {
                          onError(); // Gọi callback khi thất bại
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void searchCustomer(String keyword) async {
    if (keyword.isNotEmpty) {
      showLoading(context);

      var customerFuture = ChatConnection.searchCustomer(keyword);

      customerFuture.then((result) {
        Navigator.of(context).pop();
        customerAccountSearch = result;
        isShowListSearch = true;
        setState(() {});
      }).catchError((e) {
        Navigator.of(context).pop();
      });
    } else {
      errorDialog(content: AppLocalizations.text(LangKey.notInputSearch));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AutoSizeText(
          AppLocalizations.text(LangKey.conversationInformation),
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: InkWell(
          child: Icon(Icons.arrow_back_ios, color: Colors.black),
          onTap: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (ChatConnection.isChatHub)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: InkWell(
                onTap: () {
                  _clearChat();
                },
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
            ),
        ],
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            buildTop(),
            buildBody(),
            Expanded(
              child: buildBottom(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTop() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!isInitScreen && customerAccount?.data?.type != null)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                InkWell(
                  onTap: () async {
                    showLoading(context);
                    await ChatConnection.customerUnlink(
                        widget.roomData.owner!.sId!,
                        customerAccount!.data!.customerId);
                    Navigator.of(context).pop();
                    isShowListSearch = false;
                    customerAccountSearch = null;
                    _loadAccount();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 3.0),
                      child: Row(
                        children: [
                          Container(
                            width: 3.0,
                          ),
                          const Icon(
                            Icons.link_off,
                            color: Colors.white,
                          ),
                          Container(
                            width: 3.0,
                          ),
                          AutoSizeText(
                            AppLocalizations.text(LangKey.removeLink),
                            style: const TextStyle(color: Colors.white),
                          ),
                          Container(
                            width: 3.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: _buildAppropriateAvatar(),
            )),
        (widget.chatMessage?.room?.roomLink != null &&
                widget.chatMessage?.room?.roomLink != '')
            ? InkWell(
                onTap: () {
                  _bloc.copyTextToClipboard(
                      context, widget.chatMessage?.room?.roomLink ?? '');
                },
                // onTap: () {
                //   _bloc.openUrl(widget.chatMessage?.room?.roomLink ?? '');
                // },

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.link,
                      color: AppColors.primaryColor,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      widget.chatMessage?.room?.roomLink ?? '',
                      style: TextStyle(color: AppColors.colorBlue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ],
                ),
              )
            : SizedBox(),
        if (!ChatConnection.isChatHub)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              height: 1.0,
              color: const Color(0xFFE5E5E5),
            ),
          ),
      ],
    );
  }

  Widget buildBody() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!widget.roomData.isGroup!) ...[
          if (!isInitScreen &&
              customerAccount?.data?.type == null &&
              ChatConnection.isChatHub)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AutoSizeText(
                  AppLocalizations.text(LangKey.unknownCustomer),
                  style: const TextStyle(color: Colors.black),
                ),
                Container(
                  height: 10.0,
                ),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    height: 40.0,
                    width: MediaQuery.of(context).size.width * 0.85,
                    child: Row(
                      children: [
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: TextField(
                            onTap: () {
                              setState(() {
                                isShowListSearch = false;
                              });
                            },
                            decoration: InputDecoration.collapsed(
                              hintText: AppLocalizations.text(
                                  LangKey.inputCustomerHint),
                            ),
                            onSubmitted: (value) {
                              searchCustomer(value);
                            },
                            controller: _searchController,
                          ),
                        ),
                        const SizedBox(width: 5.0),
                        InkWell(
                          onTap: () {
                            searchCustomer(_searchController.text);
                          },
                          child: const Icon(Icons.search_outlined,
                              color: Colors.blue),
                        ),
                        const SizedBox(width: 5.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          if (customerAccountSearch != null)
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 5.0, top: 20.0, left: 15.0, right: 15.0),
              child: Row(
                children: [
                  Expanded(
                    child: AutoSizeText(
                      AppLocalizations.text(LangKey.searchingResult),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textScaleFactor: 1.15,
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        setState(() {
                          isShowListSearch = !isShowListSearch;
                        });
                      },
                      child: const Center(
                          child: Icon(
                        Icons.arrow_drop_down_outlined,
                        color: Colors.grey,
                        size: 30.0,
                      )))
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget buildBottom() {
    return isInitScreen
        ? Center(
            child: Platform.isAndroid
                ? const CircularProgressIndicator()
                : const CupertinoActivityIndicator())
        : ChatConnection.isChatHub
            ? actionChatHubView()
            : actionView();
  }

  Widget actionView() {
    return Expanded(
      child: ListView(
        physics: const ClampingScrollPhysics(),
        children: [
          _section(
              const Icon(
                Icons.folder,
                color: Color(0xff5686E1),
                size: 30,
              ),
              AppLocalizations.text(LangKey.file), () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ConversationFileScreen(
                      roomData: widget.roomData,
                      chatMessage: widget.chatMessage,
                    )));
          }),

          /// NOTE
          // _section(
          //     const Icon(
          //       Icons.note_add,
          //       color: Color(0xff5686E1),
          //       size: 30,
          //     ),
          //     AppLocalizations.text(LangKey.create_note), () async {
          //   await Navigator.of(context).push(MaterialPageRoute(
          //       builder: (context) => CreateNoteScreen(
          //             roomData: widget.roomData,
          //             chatMessage: widget.chatMessage,
          //           )));
          //   _bloc.getNotes(widget.roomData.sId!);
          // }),
          ListNoteComponent(_bloc, () => _bloc.getNotes(widget.roomData.sId!),
              widget.roomData),

          if (widget.roomData.isGroup!)
            _section(
                const Icon(
                  Icons.group,
                  color: Color(0xff5686E1),
                  size: 30,
                ),
                AppLocalizations.text(LangKey.viewMembers), () async {
              await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChatGroupMembersScreen(
                      chatMessage: widget.chatMessage!,
                      channelSocialId:
                          widget.roomData.channel?.socialChanelId)));
              setState(() {});
            }),
          if (widget.roomData.isGroup!)

            //Rời cuộc trò chuyện
            if (widget.roomData.isGroup!)
              _section(
                  const Icon(
                    Icons.remove_circle,
                    color: Color(0xff5686E1),
                    size: 30,
                  ),
                  AppLocalizations.text(LangKey.leaveConversation), () {
                _leaveRoom(widget.roomData.sId!);
              }, textColor: Colors.black),
          if (!widget.roomData.isGroup! ||
              (widget.roomData.owner?.sId == ChatConnection.user!.id &&
                  widget.roomData.isGroup!))

            /// CHƯA CHECK ĐIỀU KIỆN HIỂN THỊ
            ChatConnection.isChatHub ? socialInformation() : Container(),
          if (!widget.roomData.isGroup! ||
              (widget.roomData.owner?.sId == ChatConnection.user!.id &&
                  widget.roomData.isGroup!))
            _section(
                const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 30,
                ),
                AppLocalizations.text(LangKey.deleteConversation), () {
              !widget.roomData.isGroup!
                  ? _removeLeaveRoom(widget.roomData.sId!)
                  : _removeRoom(widget.roomData.sId!);
            }, textColor: Colors.red)
        ],
      ),
    );
  }

  Widget listCustomerSearch() {
    if (!isShowListSearch || customerAccountSearch == null) return SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Container(
        height: 300,
        // Hoặc MediaQuery.of(context).size.height * 0.5 để phù hợp với màn hình
        child: ListView.builder(
          itemCount: customerAccountSearch!.length,
          itemBuilder: (context, index) {
            final e = customerAccountSearch![index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF28A17D),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10.0),
                            Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(right: 5.0),
                                  child: Icon(Icons.account_circle_rounded,
                                      color: Colors.blueAccent),
                                ),
                                Expanded(
                                  child: AutoSizeText(e?.data?.fullName ?? ''),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            if (e?.data?.customerCode != null ||
                                e?.data?.customerLeadCode != null)
                              Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 5.0),
                                    child: Icon(Icons.code,
                                        color: Colors.blueAccent),
                                  ),
                                  Expanded(
                                    child: AutoSizeText(
                                      e?.data?.customerCode ??
                                          e?.data?.customerLeadCode ??
                                          '',
                                    ),
                                  ),
                                ],
                              ),
                            SizedBox(height: 8.0),
                            if (e?.data?.phone != null ||
                                e?.data?.phone2 != null)
                              Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 5.0),
                                    child: Icon(Icons.phone,
                                        color: Colors.blueAccent),
                                  ),
                                  Expanded(
                                    child: AutoSizeText(e?.data?.phone ??
                                        e?.data?.phone2 ??
                                        ''),
                                  ),
                                ],
                              ),
                            SizedBox(height: 8.0),
                            if (e?.data?.email != null)
                              Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.only(right: 5.0),
                                    child: Icon(Icons.email,
                                        color: Colors.blueAccent),
                                  ),
                                  Expanded(
                                    child: AutoSizeText(e?.data?.email ?? ''),
                                  ),
                                ],
                              ),
                            SizedBox(height: 8.0),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 3.0, horizontal: 8.0),
                                child: AutoSizeText(
                                  AppLocalizations.text(
                                    e?.data?.type == 'cpo'
                                        ? LangKey.cpo
                                        : LangKey.customer,
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        showLoading(context);
                        bool? success = false;
                        if (widget.chatMessage!.room!.owner!.sId != null &&
                            widget.chatMessage!.room!.owner!.source != null &&
                            widget.chatMessage!.room!.owner!.userSocialId !=
                                null) {
                          success = await ChatConnection.customerLink(
                            widget.chatMessage!.room!.owner!.sId!,
                            e?.data?.customerId,
                            e?.data!.type!,
                            customerAccount!.data!.mappingId!,
                            widget.chatMessage!.room!.owner!.source,
                            widget.chatMessage!.room!.owner!.userSocialId,
                          );
                        } else {
                          success = await ChatConnection.customerLink(
                            widget.roomData.owner!.sId!,
                            e?.data?.customerId,
                            e?.data!.type!,
                            customerAccount!.data!.mappingId!,
                            widget.roomData.channel!.source,
                            widget.roomData.channel!.socialChanelId,
                          );
                        }

                        if (success) {
                          isShowListSearch = false;
                          customerAccountSearch = null;
                          _loadAccount();
                        }
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 70,
                        color: const Color(0xFF28A17D),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 3.0),
                        child: const Icon(Icons.link_outlined,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build avatar widget - đồng bộ với room_list_screen.dart
  Widget _buildAppropriateAvatar() {
    final roomData = widget.roomData;
    final owner = extractOwner(roomData);

    final isGroup = roomData.isGroup ?? false;
    final isChatHub = ChatConnection.isChatHub;

    final domain = HTTPConnection.domain;
    final brandCode = ChatConnection.brandCode!;

    String? avatarUrl;
    String avatarName = '';
    String displayName = '';

    if (!isChatHub) {
      // ===== NON CHAT HUB (giống roomWidget trong room_list_screen.dart) =====
      if (!isGroup) {
        // Private chat: sử dụng people.picture
        final isPictureEmpty = owner?.picture == null || owner?.picture == "";
        avatarName = getAvatarName(
            '${owner?.firstName ?? ''}', '${owner?.lastName ?? ''}');
        displayName =
            '${owner?.firstName ?? 'Unknown'} ${owner?.lastName ?? 'User'}';

        avatarUrl = isPictureEmpty
            ? null
            : '${domain}api/images/${owner!.picture}/256/$brandCode';
      } else {
        // Group: đồng bộ cấu trúc avatar nhóm giống ChatHub
        displayName = roomData.title ??
            '${owner?.firstName ?? ''} ${owner?.lastName ?? ''}';
        return _buildGroupAvatarWithName(roomData, displayName);
      }
    } else {
      // ===== CHAT HUB (giống roomChatHubWidget trong room_list_screen.dart) =====
      if (!isGroup) {
        // Private chat
        displayName =
            '${roomData.owner?.firstName ?? ''} ${roomData.owner?.lastName ?? ''}';
        avatarName = getAvatarName(
            '${owner?.firstName ?? ''}', '${owner?.lastName ?? ''}');

        // Priority 1: URL trực tiếp từ external platform (Facebook, Zalo, WhatsApp)
        if (roomData.people?.first.avatar?.isNotEmpty == true) {
          avatarUrl = roomData.people!.first.avatar;
        } else if (roomData.owner?.picture == null) {
          // Priority 2: owner.avatar
          avatarUrl = roomData.owner?.avatar;
        } else {
          // Priority 3: shieldedID
          final sid = roomData.shieldedID;
          avatarUrl = (sid != null && sid.isNotEmpty)
              ? '${domain}api/images/$sid/256/$brandCode'
              : null;
        }
      } else {
        // Group
        avatarName = roomData.getAvatarGroupName();
        displayName = roomData.room_name ??
            roomData.title ??
            'Group ${roomData.owner?.firstName ?? ''} ${roomData.owner?.lastName ?? ''}';

        return _buildGroupAvatarWithName(roomData, displayName);
      }
    }

    return _buildAvatar(displayName, avatarName, avatarUrl,
        colorId: owner?.sId);
  }

  Widget actionChatHubView() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          if (ChatConnection.isChatHub) const SizedBox(height: 10.0),
          if (customerAccount?.data != null) _customerAccount(),
          listCustomerSearch(),
          const Padding(
            padding: EdgeInsets.only(bottom: 5.0),
            child: Divider(height: 1, color: Color(0xFFE5E5E5)),
          ),
          Container(
            height: 40.0,
            width: MediaQuery.of(context).size.width * 0.95,
            child: TabBar(
              labelColor: HexColor.fromHex('#0067AC'),
              dividerColor: Colors.white,
              dividerHeight: 0,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(
                  child: AutoSizeText(
                    AppLocalizations.text(LangKey.note_function),
                    minFontSize: 10,
                    maxFontSize: 20,
                  ),
                ),
                Tab(
                  child: AutoSizeText(
                    AppLocalizations.text(LangKey.note_info),
                    minFontSize: 10,
                    maxFontSize: 20,
                  ),
                ),
                Tab(
                  child: AutoSizeText(
                    AppLocalizations.text(LangKey.note),
                    minFontSize: 10,
                    maxFontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _chatFunction(),
                _chatInfo(),
                _ChatNoteTab(
                  bloc: _bloc,
                  roomData: widget.roomData,
                  chatMessage: widget.chatMessage,
                  reloadNotes: () => _bloc.getNotes(widget.roomData.sId!),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _ChatNoteTab({
    required ConversationBloc bloc,
    required r.Rooms roomData,
    required c.ChatMessage? chatMessage,
    required VoidCallback reloadNotes,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _section(
              const Icon(Icons.note_add, color: Color(0xff5686E1), size: 30),
              AppLocalizations.text(LangKey.create_note),
              () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CreateNoteScreen(
                    roomData: roomData,
                    chatMessage: chatMessage,
                  ),
                ));
                reloadNotes();
              },
            ),
            StreamBuilder(
              stream: bloc.outputNotes,
              builder: (context, snapshot) {
                if ((bloc.notesValue.data?.length ?? 0) > 0)
                  return Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: HexColor.fromHex('#0067AC'),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          width: ScreenInfo.width! * 0.95,
                          height: 35,
                          child: Center(
                            child: Text(
                              AppLocalizations.text(LangKey.note_content),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: ScreenInfo.width! * 0.95,
                          child:
                              // (snapshot.hasData &&
                              //         bloc.notesValue.data != null)
                              (bloc.notesValue.data?.length ?? 0) > 0
                                  ? ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: bloc.notesValue.data!.length,
                                      itemBuilder: (context, index) {
                                        final note =
                                            bloc.notesValue.data![index];
                                        return _NoteItem(
                                          note: note,
                                          bloc: bloc,
                                          roomData: roomData,
                                          chatMessage: chatMessage,
                                          reloadNotes: reloadNotes,
                                          context: context,
                                        );
                                      },
                                    )
                                  : Center(
                                      child: Text(
                                        AppLocalizations.text(LangKey.no_title),
                                      ),
                                    ),
                        ),
                      ],
                    ),
                  );
                else
                  return Container();
              },
            )
            // Padding(
            //   padding: const EdgeInsets.only(top: 10, bottom: 10),
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Container(
            //         decoration: BoxDecoration(
            //             color: HexColor.fromHex('#0067AC'),
            //             borderRadius: const BorderRadius.only(
            //                 topRight: Radius.circular(10),
            //                 topLeft: Radius.circular(10))),
            //         width: ScreenInfo.width! * 0.95,
            //         height: 35,
            //         child: Center(
            //           child: Text(
            //             AppLocalizations.text(LangKey.note_content),
            //             style: const TextStyle(color: Colors.white),
            //           ),
            //         ),
            //       ),
            //       SizedBox(
            //         width: ScreenInfo.width! * 0.95,
            //         child: StreamBuilder(
            //           stream: bloc.outputNotes,
            //           builder: (context, snapshot) {
            //             if (snapshot.hasData && bloc.notesValue.data != null) {
            //               return
            //                ListView.builder(
            //                 shrinkWrap: true,
            //                 physics: const NeverScrollableScrollPhysics(),
            //                 itemCount: bloc.notesValue.data!.length,
            //                 itemBuilder: (context, index) {
            //                   final note = bloc.notesValue.data![index];
            //                   return _NoteItem(
            //                     note: note,
            //                     bloc: bloc,
            //                     roomData: roomData,
            //                     chatMessage: chatMessage,
            //                     reloadNotes: reloadNotes,
            //                     context: context,
            //                   );
            //                 },
            //               );
            //             } else {
            //               return Center(
            //                   child: Text(
            //                       AppLocalizations.text(LangKey.no_title)));
            //             }
            //           },
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _NoteItem({
    required Note note,
    required ConversationBloc bloc,
    required r.Rooms roomData,
    required c.ChatMessage? chatMessage,
    required VoidCallback reloadNotes,
    required BuildContext context,
  }) {
    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(top: 15, bottom: 5, left: 10, right: 10),
          child: Row(
            children: [
              Expanded(
                child: AutoSizeText(
                  '${calculateTimeDiff(note.updatedAt ?? note.createdAt!)} ${AppLocalizations.text(LangKey.note_by)} ${note.createdByStaff?.fullName ?? ""}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                child: const Icon(Icons.mode_edit_outline_outlined),
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CreateNoteScreen(
                      note: note,
                      roomData: roomData,
                      chatMessage: chatMessage,
                    ),
                  ));
                  reloadNotes();
                },
              ),
              const SizedBox(width: 5),
              InkWell(
                child: const Icon(Icons.delete_outline, color: Colors.red),
                onTap: () async {
                  await showInfoDialog(
                    context,
                    AppLocalizations.text(LangKey.notifications),
                    content:
                        AppLocalizations.text(LangKey.confirm_delete_message),
                    () async {
                      await bloc.deleteNotes(roomData.sId!, note.id!);
                      reloadNotes();
                    },
                    onCancel: () {},
                  );
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 5, left: 10, right: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: HexColor.fromHex('#E8EBFA'),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: AutoSizeText(note.content ?? ''),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: ScreenInfo.width! * 0.95,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(20, (_) {
              return Container(
                width: 12,
                height: 0.5,
                color: Colors.grey,
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _chatInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
      child: StreamBuilder<List<SessionModel>>(
        stream: _bloc.sessionStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Text(AppLocalizations.text(LangKey.no_summary)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
                child: Text(AppLocalizations.text(LangKey.no_chat_session)));
          }

          final sessions = snapshot.data!;

          return ListView.builder(
            key: const Key('chat_info_listview'),
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _itemChatInfo(
                session,
                () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _ChatSessionBottomSheet(
                      session: session,
                      index: index,
                      bloc: _bloc,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _itemChatInfo(SessionModel data, VoidCallback onTap) {
    final day = extractDayAndMonth(
        formatDateByISO(data.createdAt ?? DateTime.now().toIso8601String()));
    return InkWell(
      key: const Key('item_chat_info'),
      onTap: onTap,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: HexColor.fromHex('#F0F3FB'),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${day['day'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.black),
                        ),
                        Text(
                          '${day['month'] ?? 'N/A'}',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 30,
                    color: HexColor.fromHex('#F0F3FB'),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.sessionTitle ??
                          AppLocalizations.text(LangKey.no_title),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        if (data.startTime != null && data.closed_at != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${calculateHoursFromISO(data.startTime!, data.closed_at!)}h',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                formatDateTime(data.startTime ??
                                    DateTime.now().toIso8601String()),
                                style: const TextStyle(fontSize: 12),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: Icon(
                                  Icons.arrow_forward,
                                  color: Colors.lightGreen,
                                  size: 14,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  data.closed_at != null
                                      ? formatDateTime(data.closed_at!)
                                      : '...',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: 2,
                width: MediaQuery.of(context).size.width * 0.7,
                color: HexColor.fromHex('#F0F3FB'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatFunction() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 8,
          ),

          /// Tập tin
          Visibility(
            visible: !ChatConnection.isChatHub,
            child: _actionButtonTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ConversationFileScreen(
                      roomData: widget.roomData,
                      chatMessage: widget.chatMessage,
                    ),
                  ),
                );
              },
              iconData: Icons.folder,
              iconColor: const Color(0xff5686E1),
              title: AppLocalizations.text(LangKey.file),
            ),
          ),

          ///Xem thành viên
          if (widget.chatMessage?.room?.isGroup == true ||
              widget.roomData.isGroup == true)
            Visibility(
              visible: ChatConnection.isChatHub,
              child: _actionButtonTile(
                onTap: () async {
                  await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatGroupMembersScreen(
                          chatMessage: widget.chatMessage!,
                          channelSocialId:
                              widget.roomData.channel?.socialChanelId)));
                  setState(() {});
                },
                iconData: Icons.group,
                iconColor: const Color(0xff5686E1),
                title: AppLocalizations.text(LangKey.viewMembers),
              ),
            ),

          if (widget.chatMessage?.room?.isGroup == false ||
              widget.roomData.isGroup == false) ...[
            ///Tra cứu sản phẩm
            _actionButtonTile(
              onTap: () {
                if (ChatConnection.searchProducts != null) {
                  ChatConnection.searchProducts!();
                }
              },
              iconData: Icons.search_outlined,
              title: AppLocalizations.text(LangKey.productSearch),
            ),

            /// Tra cứu đơn hàng
            _actionButtonTile(
              onTap: () {
                if (ChatConnection.searchOrders != null) {
                  ChatConnection.searchOrders!();
                }
              },
              iconData: Icons.search_outlined,
              title: AppLocalizations.text(LangKey.orderSearch),
            ),

            ///Các thao tác
            _actionButtonTile(
              onTap: () async {
                r.People info = getPeople(widget.chatMessage?.room?.people);
                Map<String, dynamic>? result = await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (ctx) {
                  return ActionListUserChathubScreen(
                    data: info,
                    customerAccount: customerAccount,
                    isGroup: widget.chatMessage?.room?.isGroup ?? false,
                    roomData: widget.roomData,
                  );
                }));
                if (result != null) {
                  showLoading(context);
                  try {
                    // Khách hàng tiềm năng (customerLeadId) đã được link + detect
                    // ngay trong ActionListUserChathubScreen, ở đây chỉ refresh.
                    if (result['customerLeadId'] == null) {
                      await ChatConnection.customerLink(
                          widget.roomData.sId ?? '',
                          result['customerId'],
                          result['type'],
                          customerAccount?.data?.mappingId ?? '',
                          widget.roomData.channel?.source,
                          widget.roomData.owner?.sId,
                          customerLeadId: result['customerLeadId'] ?? '');
                    }
                    isShowListSearch = false;
                    customerAccountSearch = null;
                    _loadAccount();
                  } finally {
                    Navigator.of(context).pop();
                  }
                }
              },
              iconData: Icons.accessibility,
              title: AppLocalizations.text(LangKey.actions),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: socialInformation(),
            ),
          ],

          SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }

  Widget _actionButtonTile({
    required VoidCallback onTap,
    required IconData iconData,
    required String title,
    Color iconColor = Colors.blue,
    Color? textColor,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.grey.shade400),
              ),
              height: 40.0,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(
                children: [
                  const SizedBox(width: 5.0),
                  Icon(iconData, color: iconColor),
                  const SizedBox(width: 5.0),
                  Expanded(
                    child: AutoSizeText(
                      title,
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10.0),
      ],
    );
  }

  Widget _customerAccount() {
    return customerAccount!.data!.type == null
        ? Container()
        : Column(
            children: [
              if ((customerAccount!.data!.customerCode ??
                      customerAccount!.data!.customerLeadCode ??
                      '') !=
                  '')
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.account_box,
                        color: Colors.blueAccent,
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: AutoSizeText(
                          customerAccount!.data!.customerCode ??
                              customerAccount!.data!.customerLeadCode ??
                              '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                    ],
                  ),
                ),
              if ((customerAccount!.data!.phone ??
                      customerAccount!.data!.phone2 ??
                      '') !=
                  '')
                Container(
                  height: 8.0,
                ),
              if ((customerAccount!.data!.phone ??
                      customerAccount!.data!.phone2 ??
                      '') !=
                  '')
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.phone,
                        color: Colors.blueAccent,
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: AutoSizeText(
                          customerAccount!.data!.phone ??
                              customerAccount!.data!.phone2 ??
                              '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                    ],
                  ),
                ),
              if ((customerAccount!.data!.email ?? '') != '')
                Container(
                  height: 8.0,
                ),
              if ((customerAccount!.data!.email ?? '') != '')
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.email,
                        color: Colors.blueAccent,
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: AutoSizeText(
                          customerAccount!.data!.email ?? '',
                          overflow: TextOverflow.ellipsis,
                        ),
                      )),
                    ],
                  ),
                ),
              if ((customerAccount!.data!.fullAddress ?? '') != '')
                Container(
                  height: 8.0,
                ),
              if ((customerAccount!.data!.fullAddress ?? '') != '')
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_pin,
                        color: Colors.blueAccent,
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: AutoSizeText(
                            customerAccount!.data!.fullAddress ?? ''),
                      )),
                    ],
                  ),
                ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: SizedBox(
                      height: 40.0,
                      child: InkWell(
                          onTap: () {
                            if (ChatConnection.viewProfileChatHub != null) {
                              ChatConnection.viewProfileChatHub!(
                                  customerAccount?.data?.type == 'customer'
                                      ? customerAccount?.data?.customerId
                                      : customerAccount?.data?.customerLeadId,
                                  customerAccount?.data?.type == 'customer'
                                      ? customerAccount?.data?.customerCode
                                      : customerAccount?.data?.customerLeadCode,
                                  customerAccount?.data?.type);
                            }
                          },
                          child: AutoSizeText(
                            AppLocalizations.text(LangKey.viewDetail),
                            style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600),
                          ))),
                ),
              ),
            ],
          );
  }

  /// DEV
  Widget socialInformation() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey.shade400)),
      padding: EdgeInsets.only(left: 5, right: 20),
      width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() {
              expandedSocialInfo = !expandedSocialInfo;
            }),
            child: Container(
              height: 40.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.social_distance_outlined,
                    color: Color(0xff5686E1),
                  ),
                  Container(
                    width: 5,
                  ),
                  Expanded(
                    child: Text(
                      AppLocalizations.text(LangKey.socialInformation),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 10.0),
                    height: 50.0,
                    width: AppSizes.iconSize,
                    child: Icon(expandedSocialInfo
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down),
                  )
                ],
              ),
            ),
          ),
          // CustomLine(),
          // SizedBox(
          //   height: 8.0,
          // ),
          expandedSocialInfo ? socialInfoTable() : Container()
        ],
      ),
    );
  }

  Widget socialInfoTable() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      margin: EdgeInsets.symmetric(vertical: AppSizes.maxPadding),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: AppColors.lineColor)),
      child: Column(
        children: [
          Container(
            height: 70.0,
            padding: EdgeInsets.all(AppSizes.maxPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    height: 50.0,
                    width: 50.0,
                    margin: EdgeInsets.only(left: AppSizes.minPadding),
                    padding: EdgeInsets.all(AppSizes.minPadding),
                    child: CommonAvatar(widget.roomData)),
                Container(
                  width: 10.0,
                ),
                Expanded(child: Text(widget.roomData.owner!.getName()))
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.symmetric(vertical: AppSizes.minPadding),
              child: CustomLine()),
          Container(
            height: 20.0,
          ),
          CustomRowInformation(
            title: widget.roomData.source == facebookConst ? 'PSI' : 'UID',
            content: widget.roomData.owner!.userSocialId,
            contentStyle: AppTextStyles.style13BlackWeight400
                .copyWith(color: AppColors.primaryColor),
          ),
          CustomRowInformation(
            title: widget.roomData.source == facebookConst ? 'Fanpage' : 'OA',
            content: widget.chatMessage?.room?.channel!.nameApp,
          ),
          GestureDetector(
            onTap: () {
              final link = widget.roomData.source == facebookConst
                  ? '$httpFacebook${widget.roomData.channel!.socialChanelId}'
                  : '$httpOA${widget.roomData.channel!.socialChanelId}';
              final uri = Uri.tryParse(link);
              if (uri != null)
                launchUrl(uri, mode: LaunchMode.externalApplication);
            },
            child: CustomRowInformation(
              title: widget.roomData.source == facebookConst
                  ? 'Link Fanpage'
                  : 'Link OA',
              content: widget.roomData.source == facebookConst
                  ? '$httpFacebook${widget.roomData.channel!.socialChanelId}'
                  : '$httpOA${widget.roomData.channel!.socialChanelId}',
              contentStyle: AppTextStyles.style13BlackWeight400
                  .copyWith(color: AppColors.primaryColor),
            ),
          ),
          widget.roomData.source == zaloConst
              ? CustomRowInformation(
                  title: AppLocalizations.text(LangKey.status),
                  content: widget.roomData.owner!.isFollowed == 1
                      ? AppLocalizations.text(LangKey.follow_oa)
                      : AppLocalizations.text(LangKey.not_follow_oa),
                )
              : Container(),
          CustomRowInformation(
            title: AppLocalizations.text(LangKey.createDate),
            content: widget.roomData.createdAt,
          ),
          Container(
            height: 10.0,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupAvatarWithName(r.Rooms roomData, String displayName) {
    final isOwner = roomData.owner?.sId == ChatConnection.user?.id;
    return Column(
      children: [
        ChatGroupAvatar(
          people: roomData.people,
          size: 50,
        ),
        // const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                displayName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ),
            if (isOwner)
              GestureDetector(
                onTap: _showRenameGroupBottomSheet,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child:
                      Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showRenameGroupBottomSheet() {
    final controller = TextEditingController(
      text: widget.roomData.room_name ?? widget.roomData.title ?? '',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Đổi tên nhóm',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Nhập tên nhóm',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xff5686E1), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  final newName = controller.text.trim();
                  if (newName.isEmpty) return;
                  Navigator.of(ctx).pop();
                  final result = await ChatConnection.updateRoomName(
                      widget.roomData.sId!, newName);
                  if (result && mounted) {
                    setState(() {
                      widget.roomData.title = newName;
                      widget.roomData.room_name = newName;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff5686E1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Lưu',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String name, String avatarName, String? url,
      {String? colorId}) {
    Widget child;
    double radius = MediaQuery.of(context).size.width * 0.125;
    if (url != null && url != '') {
      child = CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(url,
            headers: {'brand-code': ChatConnection.brandCode!}),
        backgroundColor: Colors.transparent,
      );
    } else {
      child = CircleAvatar(
        radius: radius,
        backgroundColor: getAvatarColor(colorId),
        child: Text(avatarName,
            style: const TextStyle(color: Colors.white),
            maxLines: 1,
            textScaler: TextScaler.linear(1.75)),
      );
    }

    return Column(
      children: [
        child,
        Container(
          height: 10.0,
        ),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                    child: Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20.0),
                )),
                // if (customerAccount?.data?.type == 'customer')
                if (!widget.roomData.isGroup!)
                  const Padding(
                    padding: EdgeInsets.only(left: 10.0),
                    child: Icon(
                      Icons.edit_outlined,
                      color: Colors.grey,
                      size: 20.0,
                    ),
                  )
              ],
            ),
          ),
          onTap: () {
            editName();
          },
        )
      ],
    );
  }

  r.People getPeople(List<r.People>? people) {
    return people!.first.sId != ChatConnection.user!.id
        ? people.first
        : people.last;
  }

  Widget _section(Icon icon, String name, Function function,
      {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: const Color(0xFFE5E5E5)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: () {
            function();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8),
                      child: icon,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: AutoSizeText(
                          name,
                          maxLines: 1,
                          textScaleFactor: 1.2,
                          style: TextStyle(color: textColor ?? Colors.black),
                        ),
                      ),
                    ),
                    if (textColor == null)
                      const Padding(
                        padding: EdgeInsets.only(left: 5.0, right: 8.0),
                        child: Icon(
                          Icons.navigate_next_outlined,
                          color: Color(0xFFE5E5E5),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<Widget> extractSummaryWidgetsFromHtml(String input) {
  // 1. Xử lý sơ bộ HTML
  input = input.replaceAll(RegExp(r'<h1[^>]*>.*?</h1>', dotAll: true), '');

  input = input.replaceAllMapped(
    RegExp(r'<h2[^>]*>(.*?)<\/h2>', dotAll: true),
    (match) => '\n${match.group(1)?.trim()}:',
  );

  input = input.replaceAllMapped(
    RegExp(r'<li[^>]*>(.*?)<\/li>', dotAll: true),
    (match) => '- ${match.group(1)?.trim()}\n',
  );

  input = input.replaceAll(
      RegExp(r'<\/?(ul|ol|p)[^>]*>', caseSensitive: false), '');
  input = input.replaceAll(RegExp(r'<[^>]+>'), '');
  input = input.trim();

  // 2. Giải mã một số HTML entity đơn giản bằng tay (ví dụ: &gt; -> >)
  input = input.replaceAll('&gt;', '>');
  input = input.replaceAll('&lt;', '<');
  input = input.replaceAll('&amp;', '&');
  input = input.replaceAll('&quot;', '"');
  input = input.replaceAll('&#39;', "'");
  input = input.replaceAll('-', "");

  // 3. Xử lý dấu ::: về :
  input = input.replaceAll(RegExp(r':{2,}'), ':');

  // 4. Tách dòng
  final lines = input.split('\n');

  // 5. Tạo danh sách Widget từ từng dòng
  return lines.where((line) => line.trim().isNotEmpty).map((line) {
    final trimmed = line.trim();
    final isTitle = RegExp(r'^[IVXLCDM]+\.\s').hasMatch(trimmed);

    return Padding(
      padding: EdgeInsets.only(
        top: isTitle ? 10 : 0,
        left: isTitle ? 0 : 15.0,
        bottom: 6.0,
      ),
      child: Align(
        alignment: Alignment.centerLeft, // Giúp text căn trái
        child: AutoSizeText(
          trimmed,
          minFontSize: isTitle ? 16 : 12,
          maxFontSize: isTitle ? 20 : 16,
          style: TextStyle(
            fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
            color: isTitle ? const Color(0xFF007BFF) : Colors.black,
          ),
        ),
      ),
    );
  }).toList();
}

// ── Session bottom sheet ─────────────────────────────────────────────────────

class _ChatSessionBottomSheet extends StatefulWidget {
  final SessionModel session;
  final int? index;
  final ConversationBloc bloc;

  const _ChatSessionBottomSheet({
    required this.session,
    required this.index,
    required this.bloc,
  });

  @override
  State<_ChatSessionBottomSheet> createState() =>
      _ChatSessionBottomSheetState();
}

class _ChatSessionBottomSheetState extends State<_ChatSessionBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<types.Message> _typesMessages = [];
  bool _loadingMessages = false;
  String? _summary;

  final _searchController = TextEditingController();

  // Controllers required by the Chat widget (read-only replay)
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  final ChatController _chatController = ChatController();
  final Map<String, int> _listIdMessages = {};

  late types.User _currentUser;

  @override
  void initState() {
    super.initState();
    _summary = widget.session.summary;
    final u = ChatConnection.checkUserTokenResponseModel?.user;
    _currentUser = types.User(
      id: u?.sId ?? '',
      firstName: u?.firstName ?? '',
      lastName: u?.lastName ?? '',
    );
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 &&
          _typesMessages.isEmpty &&
          !_loadingMessages) {
        _fetchMessages();
      }
    });
    widget.bloc.sessionStream.listen((sessions) {
      if (mounted && widget.index != null && sessions.length > widget.index!) {
        setState(() => _summary =
            sessions[widget.index!].summary ?? widget.session.summary);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    if (widget.session.messageIds == null || widget.session.messageIds!.isEmpty)
      return;
    setState(() => _loadingMessages = true);
    final rawMsgs =
        await ChatConnection.getSessionMessages(widget.session.messageIds!);
    final List<types.Message> converted = [];
    for (final m in rawMsgs) {
      if (m.author?.sId != null && m.sId != null) {
        try {
          converted.add(types.Message.fromJson(m.toMessageJson()));
        } catch (_) {}
      }
    }
    if (mounted)
      setState(() {
        _typesMessages = List.from(converted.reversed);
        _loadingMessages = false;
      });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.85;
    final msgCount = widget.session.messageIds?.length ?? 0;
    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // drag handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              AppLocalizations.text(LangKey.chat_session_info),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(text: AppLocalizations.text(LangKey.summary)),
              Tab(text: 'Tin nhắn phiên chat ($msgCount)'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSummaryTab(),
                _buildMessagesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTab() {
    final summaryText = _summary ?? '';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summaryText.trim().isNotEmpty)
            ...extractSummaryWidgetsFromHtml(summaryText)
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  AppLocalizations.text(LangKey.no_chat_session),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Center(
            child: InkWell(
              onTap: () async {
                showLoading(context);
                try {
                  await widget.bloc.getSummary(widget.session.id!);
                  await widget.bloc.getSession(widget.session.room ?? '');
                  if (mounted) Navigator.pop(context);
                } catch (_) {
                  if (mounted) Navigator.pop(context);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(color: Colors.blue),
                ),
                width: MediaQuery.of(context).size.width * 0.4,
                height: 36,
                child: Center(
                  child: Text(
                    AppLocalizations.text(LangKey.summary),
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMessagesTab() {
    if (_loadingMessages) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_typesMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.text(LangKey.no_chat_session),
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchMessages,
              child: const Text('Tải tin nhắn'),
            ),
          ],
        ),
      );
    }
    // Render với widget Chat giống chat_screen.dart.
    // isSearchChat: true => ẩn ô nhập liệu (đây là phần xem lại tin nhắn của phiên).
    return Chat(
      messages: _typesMessages,
      user: _currentUser,
      isSearchChat: true,
      canSend: true,
      isGroup: false,
      people: const [],
      roomData: r.Rooms(),
      showUserAvatars: true,
      showUserNames: true,
      scrollPhysics: const ClampingScrollPhysics(),
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      listIdMessages: _listIdMessages,
      searchController: _searchController,
      chatController: _chatController,
      imageMessageBuilder: (message, {required int messageWidth}) =>
          _buildSessionImage(message, messageWidth),
      fileMessageBuilder: buildFileWidget,
      customMessageBuilder: customMessageBuilder,
      onMessageTap: (ctx, message, isRepliedMessage) async {
        if (message is types.ImageMessage) {
          openImage(ctx, message.uri);
        } else if (message is types.FileMessage) {
          showLoading(ctx);
          final result = await download(
              ctx, message.uri, '${message.createdAt}_${message.name}');
          if (mounted) Navigator.of(ctx).pop();
          openFile(result, ctx, message.name);
        }
      },
      progressUpdate: (_) {},
      onStickerPressed: (_) {},
      onSendPressed: (_, {repliedMessage, isEdit}) {},
      builder: (_, __) {},
    );
  }

  Widget _buildSessionImage(types.ImageMessage message, int messageWidth) {
    final uri = message.uri;
    final w = messageWidth.toDouble() * 0.7;
    return GestureDetector(
      onTap: () => openImage(context, uri),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: uri,
          width: w,
          fit: BoxFit.cover,
          httpHeaders: ChatConnection.brandCode != null
              ? {'brand-code': ChatConnection.brandCode!}
              : null,
          placeholder: (_, __) => SizedBox(
              width: w,
              height: 120,
              child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2))),
          errorWidget: (_, __, ___) => SizedBox(
              width: w,
              height: 120,
              child: const Icon(Icons.broken_image, color: Colors.grey)),
        ),
      ),
    );
  }
}
