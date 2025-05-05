import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_ui/hex_color.dart';
import 'package:chat/common/constant.dart';
import 'package:chat/common/theme.dart';
import 'package:chat/common/widges/widget.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/customer_account.dart';
import 'package:chat/data_model/room.dart' as r;
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:chat/presentation/conversation_modules/bloc/conversation_bloc.dart';
import 'package:chat/presentation/utils/media_query.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../chat_screen/chat_group_members_screen.dart';
import '../../../chat_screen/conversation_file_screen.dart';
import '../../../data_model/room.dart';
import '../../../data_model/session.dart';
import '../../note_modules/ui/create_note_screen.dart';
import '../../utils/dialog.dart';
import '../../utils/formatter.dart';
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

  @override
  void initState() {
    super.initState();
    _bloc = ConversationBloc();
    _loadAccount();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (ChatConnection.isChatHub) {
        _bloc.getNotes(widget.roomData.sId!);
      }
    });
    _bloc.getSession(widget.roomData.sId!);
  }

  void _loadAccount() async {
    if (ChatConnection.isChatHub) {
      customerAccount = await ChatConnection.detect(widget.roomData.sId ?? '');
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

  @override
  Widget build(BuildContext context) {
    String url =
        '${HTTPConnection.domain}api/images/${widget.roomData.picture?.shieldedID ?? widget.roomData.shieldedID ?? widget.roomData.owner?.picture}/256';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AutoSizeText(
          AppLocalizations.text(LangKey.conversationInformation),
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: InkWell(
          child: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
              color: Colors.black),
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
            if (!isInitScreen && customerAccount?.data?.type != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(child: Container()),
                    InkWell(
                      onTap: () async {
                        showLoading();
                        // r.People info = getPeople(widget.roomData.people);
                        await ChatConnection.customerUnlink(
                            widget.roomData.sId ?? '',
                            customerAccount?.data?.customerId,
                            customerAccount?.data?.customerLeadId);
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
              padding: const EdgeInsets.symmetric(vertical: 17.0),
              child: Center(
                  child: !widget.roomData.isGroup!
                      ? customerAccount?.data?.type != null
                          ? _buildAvatar(
                              customerAccount?.data?.fullName != null
                                  ? customerAccount!.data!.getName()
                                  : widget.roomData.owner!.getName(),
                              customerAccount?.data?.fullName != null
                                  ? customerAccount!.data!.getAvatarName()
                                  : widget.roomData.owner!.getAvatarName(),
                              widget.roomData.picture == null
                                  ? null
                                  : '${HTTPConnection.domain}api/images/${widget.roomData.shieldedID}/256',
                              onTap: () => editName(),
                            )
                          : _buildAvatar(
                              customerAccount?.data?.fullName != null
                                  ? customerAccount!.data!.getName()
                                  : widget.roomData.owner!.getName(),
                              customerAccount?.data?.fullName != null
                                  ? customerAccount!.data!.getAvatarName()
                                  : widget.roomData.owner!.getAvatarName(),
                              (widget.roomData.picture == null &&
                                      widget.roomData.owner?.picture == null)
                                  ? null
                                  : url)
                      : _buildAvatar(
                          widget.roomData.title ?? "",
                          widget.roomData.getAvatarGroupName(),
                          widget.roomData.picture == null
                              ? null
                              : '${HTTPConnection.domain}api/images/${widget.roomData.picture!.shieldedID}/256',
                          onTap: widget.roomData.owner?.sId ==
                                  ChatConnection.user!.id
                              ? () async {
                                  editName();
                                }
                              : null)),
            ),
            if (!ChatConnection.isChatHub)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Container(
                  height: 1.0,
                  color: const Color(0xFFE5E5E5),
                ),
              ),
            if (!isInitScreen &&
                customerAccount?.data?.type == null &&
                ChatConnection.isChatHub)
              Column(
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
                          border: Border.all(color: Colors.grey.shade400)),
                      height: 40.0,
                      width: MediaQuery.of(context).size.width * 0.85,
                      child: Row(
                        children: [
                          Container(
                            width: 10.0,
                          ),
                          Expanded(
                              child: TextField(
                            decoration: InputDecoration.collapsed(
                                hintText: AppLocalizations.text(
                                    LangKey.inputCustomerHint)),
                            onSubmitted: (value) {
                              searchCustomer(value);
                            },
                            controller: _searchController,
                          )),
                          Container(
                            width: 5.0,
                          ),
                          InkWell(
                              onTap: () {
                                searchCustomer(_searchController.text);
                              },
                              child: const Icon(
                                Icons.search_outlined,
                                color: Colors.blue,
                              )),
                          Container(
                            width: 5.0,
                          ),
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
            isInitScreen
                ? Expanded(
                    child: Center(
                        child: Platform.isAndroid
                            ? const CircularProgressIndicator()
                            : const CupertinoActivityIndicator()))
                : actionChatHubView(),
          ],
        ),
      ),
    );
  }

  void editName() async {
    if (ChatConnection.isChatHub) {
      if (ChatConnection.editCustomerLead != null) {
        await ChatConnection.editCustomerLead!(
            customerAccount?.data?.type == 'customer'
                ? customerAccount?.data?.customerCode
                : customerAccount?.data?.customerLeadCode,
            customerAccount?.data?.type,
            customerAccount?.data?.customerId);
        _loadAccount();
      }
    } else {
      _controller.text =
          widget.roomData.title ?? customerAccount?.data?.fullName ?? '';
      final FocusNode _focusNode = FocusNode();
      await showDialog<bool>(
        context: context,
        builder: (context) {
          _focusNode.requestFocus();
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
                        controller: _controller,
                        focusNode: _focusNode,
                        placeholder: AppLocalizations.text(LangKey.members),
                      ),
                    ),
                    CupertinoButton(
                        child: Text(AppLocalizations.text(LangKey.accept)),
                        onPressed: () async {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.of(context).pop();
                          bool result = false;
                          if (ChatConnection.isChatHub) {
                            result = await ChatConnection.updateNameChatHub(
                                customerAccount?.data?.customerId != null
                                    ? customerAccount!.data!.customerId
                                        .toString()
                                    : customerAccount!.data!.customerLeadId
                                        .toString(),
                                customerAccount?.data?.type ?? '',
                                _controller.value.text);
                          } else {
                            result = await ChatConnection.updateRoomName(
                                widget.roomData.sId!, _controller.value.text);
                          }
                          if (result) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            if (ChatConnection.isChatHub) {
                              customerAccount?.data?.fullName =
                                  _controller.value.text;
                            } else {
                              widget.roomData.title = _controller.value.text;
                            }
                            reload();
                          } else {
                            errorDialog(
                                content: ChatConnection.isChatHub
                                    ? LangKey.getFileError
                                    : null);
                          }
                        }),
                  ],
                ),
              ),
            );
          });
        },
      );
    }
  }

  void searchCustomer(String keyword) async {
    if (keyword != '') {
      showLoading();
      customerAccountSearch = await ChatConnection.searchCustomer(keyword);
      Navigator.of(context).pop();
      setState(() {
        isShowListSearch = true;
      });
    } else {
      errorDialog(content: AppLocalizations.text(LangKey.notInputSearch));
    }
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

  bool isShowListSearch = false;

  Widget listCustomerSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isShowListSearch)
            Column(
              children: customerAccountSearch == null
                  ? []
                  : customerAccountSearch!
                      .map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: const Color(0xFF28A17D),
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(color: Colors.grey)),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          height: 10.0,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                        right: 5.0),
                                                    child: Icon(
                                                      Icons
                                                          .account_circle_rounded,
                                                      color: Colors.blueAccent,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: AutoSizeText(
                                                        e?.data?.fullName ??
                                                            ''),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.orangeAccent,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 3.0,
                                                      horizontal: 8.0),
                                                  child: AutoSizeText(
                                                    AppLocalizations.text(
                                                        e?.data?.type == 'cpo'
                                                            ? LangKey.cpo
                                                            : LangKey.customer),
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          height: 8.0,
                                        ),
                                        if ((e?.data?.customerCode != null) ||
                                            (e?.data?.customerLeadCode != null))
                                          Row(
                                            children: [
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(right: 5.0),
                                                child: Icon(
                                                  Icons.code,
                                                  color: Colors.blueAccent,
                                                ),
                                              ),
                                              Expanded(
                                                child: AutoSizeText(
                                                  e?.data?.customerCode ??
                                                      e?.data
                                                          ?.customerLeadCode ??
                                                      '',
                                                  style: const TextStyle(
                                                      color: Colors.black),
                                                ),
                                              )
                                            ],
                                          ),
                                        Container(
                                          height: 8.0,
                                        ),
                                        if ((e?.data?.phone != null) ||
                                            (e?.data?.phone2 != null))
                                          Row(
                                            children: [
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(right: 5.0),
                                                child: Icon(
                                                  Icons.phone,
                                                  color: Colors.blueAccent,
                                                ),
                                              ),
                                              Expanded(
                                                child: AutoSizeText(
                                                    e?.data?.phone ??
                                                        e?.data?.phone2 ??
                                                        ''),
                                              )
                                            ],
                                          ),
                                        Container(
                                          height: 8.0,
                                        ),
                                        if ((e?.data?.email != null))
                                          Row(
                                            children: [
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(right: 5.0),
                                                child: Icon(
                                                  Icons.email,
                                                  color: Colors.blueAccent,
                                                ),
                                              ),
                                              Expanded(
                                                child: AutoSizeText(
                                                    e?.data?.email ?? ''),
                                              )
                                            ],
                                          ),
                                        Container(
                                          height: 8.0,
                                        ),
                                      ],
                                    ),
                                  )),
                                  InkWell(
                                    onTap: () async {
                                      showLoading();
                                      // r.People info = getPeople(widget.roomData.people);
                                      await ChatConnection.customerLink(
                                          widget.roomData.sId ?? '',
                                          e?.data?.customerId,
                                          e?.data?.customerLeadId,
                                          e?.data?.type ?? '',
                                          customerAccount?.data?.mappingId ??
                                              '');
                                      Navigator.of(context).pop();
                                      isShowListSearch = false;
                                      customerAccountSearch = null;
                                      _loadAccount();
                                    },
                                    child: Container(
                                      width: 70,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF28A17D),
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 3.0),
                                        child: Icon(
                                          Icons.link_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ))
                      .toList(),
            )
        ],
      ),
    );
  }

  Widget actionChatHubView() {
    return Expanded(
      child: DefaultTabController(
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
                children: [_chatFunction(), _chatInfo(), _chatNote()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chatNote() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _section(
              const Icon(
                Icons.note_add,
                color: Color(0xff5686E1),
                size: 35,
              ),
              AppLocalizations.text(LangKey.create_note),
              () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CreateNoteScreen(
                    roomData: widget.roomData,
                    chatMessage: widget.chatMessage,
                  ),
                ));
                _bloc.getNotes(widget.roomData.sId!);
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: HexColor.fromHex('#0067AC'),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(10),
                            topLeft: Radius.circular(10))),
                    width: ScreenInfo.width! * 0.95,
                    height: 35,
                    child: Center(
                      child: Text(
                        AppLocalizations.text(LangKey.note_content),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: ScreenInfo.width! * 0.95,
                    child: StreamBuilder(
                      stream: _bloc.outputNotes,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _bloc.notesValue.data!.length,
                            itemBuilder: (context, index) {
                              final note = _bloc.notesValue.data![index];
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15,
                                        bottom: 5,
                                        left: 10,
                                        right: 10),
                                    child: Row(
                                      children: [
                                        AutoSizeText(
                                            '${calculateTimeDiff(note.updatedAt!)} ${AppLocalizations.text(LangKey.note_by)} ${note.createdByStaff!.fullName}'),
                                        Spacer(),
                                        InkWell(
                                          child: Icon(
                                              Icons.mode_edit_outline_outlined),
                                          onTap: () async {
                                            await Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CreateNoteScreen(
                                                          note: note,
                                                          roomData:
                                                              widget.roomData,
                                                          chatMessage: widget
                                                              .chatMessage,
                                                        )));
                                            _bloc
                                                .getNotes(widget.roomData.sId!);
                                          },
                                        ),
                                        Container(
                                          width: 5,
                                        ),
                                        InkWell(
                                          child: Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),
                                          onTap: () async {
                                            await showInfoDialog(
                                              context,
                                              AppLocalizations.text(
                                                  LangKey.notifications),
                                              content:
                                                  '${AppLocalizations.text(LangKey.confirm_delete_message)}',
                                              () async {
                                                await _bloc.deleteNotes(
                                                    widget.roomData.sId!,
                                                    note.id!);
                                                _bloc.getNotes(
                                                    widget.roomData.sId!);
                                              },
                                              onCancel: () {},
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 5, left: 10, right: 10),
                                    child: Align(
                                      child: Container(
                                        child: AutoSizeText(note.content!),
                                        decoration: BoxDecoration(
                                            color: HexColor.fromHex('#E8EBFA'),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 5,
                                            bottom: 5),
                                      ),
                                      alignment: Alignment.centerLeft,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: List.generate(20, (_) {
                                        return Container(
                                          width: 12,
                                          height: 0.5,
                                          color: Colors.grey,
                                        );
                                      }),
                                    ),
                                    width: ScreenInfo.width! * 0.95,
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          return Center(
                              child: Text(
                                  AppLocalizations.text(LangKey.no_title)));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
                  showDialog(
                    context: context,
                    builder: (context) =>
                        buildChatSessionDialog(session: session, index: index),
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

  Widget buildChatSessionDialog({
    required SessionModel session,
    required int? index,
  }) {
    return StreamBuilder(
      stream: _bloc.sessionStream,
      builder: (context, summarySnapshot) {
        return Dialog(
          key: const Key('chat_session_dialog'),
          insetPadding: const EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: DefaultTabController(
            length: 2,
            child: StatefulBuilder(
              builder: (context, setState) {
                String summaryText =
                    summarySnapshot.data![index!].summary ?? '';
                // Nội dung tab tóm tắt
                final summaryContent = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (summarySnapshot.hasError)
                      Text(
                        AppLocalizations.text(LangKey.load_summary_error),
                        style: TextStyle(color: Colors.red),
                      )
                    else if (summaryText.trim().isNotEmpty)
                      Column(
                        children: extractSummaryWidgetsFromHtml(summaryText),
                      ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: InkWell(
                        onTap: () async {
                          showLoading();
                          try {
                            // Gọi API để lấy tóm tắt
                            await _bloc.getSummary(session.id!);
                            await _bloc.getSession(widget.roomData.sId!);
                            Navigator.pop(context);
                          } catch (e) {
                            // Hiển thị thông báo lỗi
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${AppLocalizations.text(LangKey.load_summary_failed)} $e')),
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white70,
                            border: Border.all(color: Colors.blue),
                          ),
                          width: MediaQuery.of(context).size.width * 0.4,
                          height: 35,
                          child: Center(
                            child: Text(
                              AppLocalizations.text(LangKey.summary),
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );

                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Center(
                          child: Text(
                            AppLocalizations.text(LangKey.chat_session_info),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: summaryContent,
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              AppLocalizations.text(LangKey.close),
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _chatFunction() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),

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
              Map<String, dynamic>? result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => Container()),
                // Lưu ý: Bạn có thể đổi lại thành màn hình ActionListUserChathubScreen sau.
              );
              if (result != null) {
                showLoading();
                await ChatConnection.customerLink(
                  widget.roomData.sId ?? '',
                  result['customerId'],
                  result['customerLeadId'],
                  result['type'],
                  customerAccount?.data?.mappingId ?? '',
                );
                Navigator.of(context).pop();
                isShowListSearch = false;
                customerAccountSearch = null;
                _loadAccount();
              }
            },
            iconData: Icons.accessibility,
            title: AppLocalizations.text(LangKey.actions),
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
          if (widget.roomData.isGroup!)
            Visibility(
              visible: ChatConnection.isChatHub,
              child: _actionButtonTile(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          ChatGroupMembersScreen(roomData: widget.roomData)));
                },
                iconData: Icons.group,
                iconColor: const Color(0xff5686E1),
                title: AppLocalizations.text(LangKey.viewMembers),
              ),
            ),

          /// Rời nhóm
          if (widget.roomData.isGroup!)
            Visibility(
              visible: ChatConnection.isChatHub,
              child: _actionButtonTile(
                onTap: () {
                  _leaveRoom(widget.roomData.sId!);
                },
                iconData: Icons.remove_circle,
                iconColor: const Color(0xff5686E1),
                title: AppLocalizations.text(LangKey.leaveConversation),
              ),
            ),

          ///Xóa cuộc trò chuyện
          if (!widget.roomData.isGroup! || ChatConnection.isChatHub
              ? (widget.roomData.owner!.sId == ChatConnection.user!.id &&
                  widget.roomData.isGroup!)
              : widget.groupOwner!.sId == ChatConnection.user!.id &&
                  widget.roomData.isGroup!)
            Visibility(
              visible: ChatConnection.isChatHub,
              child: _actionButtonTile(
                onTap: () {
                  !widget.roomData.isGroup!
                      ? _removeLeaveRoom(widget.roomData.sId!)
                      : _removeRoom(widget.roomData.sId!);
                },
                iconData: Icons.delete,
                iconColor: Colors.red,
                title: AppLocalizations.text(LangKey.deleteConversation),
                textColor: Colors.red,
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: socialInformation(),
          ),
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
              width: MediaQuery.of(context).size.width * 0.85,
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

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 13.0),
      child: Container(height: 1.0, color: const Color(0xFFE5E5E5)),
    );
  }

  /// DEV
  Widget socialInformation() {
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(color: Colors.grey.shade400)),
      padding: EdgeInsets.only(left: 5, right: 20),
      width: MediaQuery.of(context).size.width * 0.85,
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
          CustomLine(),
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
            content: widget.roomData.channel!.nameApp,
          ),
          CustomRowInformation(
            title: widget.roomData.source == facebookConst
                ? 'Link Fanpage'
                : 'Link OA',
            content: widget.roomData.source == facebookConst
                ? '$httpFacebook${widget.roomData.channel!.socialChanelId}'
                : '$httpOA${widget.roomData.channel!.socialChanelId}',
            contentStyle: AppTextStyles.style13BlackWeight400
                .copyWith(color: AppColors.primaryColor),
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

  Widget _buildAvatar(String name, String avatarName, String? url,
      {Function()? onTap}) {
    Widget child;
    double radius = MediaQuery.of(context).size.width * 0.125;
    if (url != null) {
      child = CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(
            '$url/${ChatConnection.brandCode!}',
            headers: {'brand-code': ChatConnection.brandCode!}),
        backgroundColor: Colors.transparent,
      );
    } else {
      child = CircleAvatar(
        radius: radius,
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
                if (onTap != null)
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
          onTap: onTap,
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
      padding: const EdgeInsets.only(top: 15.0),
      child: InkWell(
        onTap: () {
          function();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10),
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
                    padding: EdgeInsets.only(left: 5.0, right: 10.0),
                    child: Icon(
                      Icons.navigate_next_outlined,
                      color: Color(0xFFE5E5E5),
                    ),
                  ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
              child: CustomLine(),
            )
          ],
        ),
      ),
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
}
