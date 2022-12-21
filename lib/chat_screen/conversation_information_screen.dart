import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_screen/action_list_user_chathub_screen.dart';
import 'package:chat/chat_screen/chat_group_members_screen.dart';
import 'package:chat/chat_screen/conversation_file_screen.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/customer_account.dart';
import 'package:chat/data_model/room.dart' as r;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ConversationInformationScreen extends StatefulWidget {
  final r.Rooms roomData;
  final c.ChatMessage? chatMessage;
  const ConversationInformationScreen(
      {Key? key, required this.roomData, this.chatMessage})
      : super(key: key);
  @override
  _ConversationInformationScreenState createState() =>
      _ConversationInformationScreenState();
}

class _ConversationInformationScreenState
    extends State<ConversationInformationScreen> {

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool isInitScreen = true;
  CustomerAccount? customerAccount;
  List<CustomerAccount?>? customerAccountSearch;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  void _loadAccount() async {
    if(ChatConnection.isChatHub) {
      r.People info = getPeople(widget.roomData.people);
      customerAccount = await ChatConnection.detect(info.sId??'');
    }
    isInitScreen = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    r.People info = getPeople(widget.roomData.people);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AutoSizeText(
          AppLocalizations.text(LangKey.conversationInformation),
          style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16),
        ),
        leading: InkWell(
          child: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
              color: Colors.black),
          onTap: () => Navigator.of(context).pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: SizedBox(
              width: 24.0,
            ),
          )
        ],
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if(!isInitScreen && customerAccount?.data?.type != null) Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(child: Container()),
                  InkWell(
                    onTap: () async {
                      showLoading();
                      r.People info = getPeople(widget.roomData.people);
                      await ChatConnection.customerUnlink(info.sId??'',
                          customerAccount?.data?.customerId, customerAccount?.data?.customerLeadId);
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
                        padding: const EdgeInsets.symmetric(horizontal: 8.0,vertical: 3.0),
                        child: Row(
                          children: [
                            Container(width: 3.0,),
                            const Icon(Icons.link_off,color: Colors.white,),
                            Container(width: 3.0,),
                            AutoSizeText(AppLocalizations.text(LangKey.removeLink),style: const TextStyle(color: Colors.white),),
                            Container(width: 3.0,),
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
                      ?
                    customerAccount?.data?.type != null? _buildAvatar(
                        customerAccount?.data?.fullName != null ? customerAccount!.data!.getName() : info.getName(),
                        customerAccount?.data?.fullName != null ? customerAccount!.data!.getAvatarName(): info.getAvatarName(),
                        info.picture == null
                            ? null
                            : '${HTTPConnection.domain}api/images/${info.picture!.shieldedID}/256', onTap: () {
                      editName();
                    }) :
                  _buildAvatar(
                    customerAccount?.data?.fullName != null ? customerAccount!.data!.getName() : info.getName(),
                    customerAccount?.data?.fullName != null ? customerAccount!.data!.getAvatarName(): info.getAvatarName(),
                          info.picture == null
                              ? null
                              : '${HTTPConnection.domain}api/images/${info.picture!.shieldedID}/256')
                      : _buildAvatar(
                          widget.roomData.title ?? "",
                          widget.roomData.getAvatarGroupName(),
                          widget.roomData.picture == null
                              ? null
                              : '${HTTPConnection.domain}api/images/${widget.roomData.picture!.shieldedID}/256',
                              onTap: widget.roomData.owner == ChatConnection.user!.id? () async {
                                editName();
                              }: null)),
            ),
            if(!ChatConnection.isChatHub) Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Container(
                height: 1.0,
                color: const Color(0xFFE5E5E5),
              ),
            ),
            if(!ChatConnection.isChatHub) actionView(),
            if(!isInitScreen && customerAccount?.data?.type == null && ChatConnection.isChatHub) Column(
              children: [
                AutoSizeText(AppLocalizations.text(LangKey.unknownCustomer),style: const TextStyle(color: Colors.black),),
                Container(height: 10.0,),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.grey.shade400)
                    ),
                    height: 40.0,
                    width: MediaQuery.of(context).size.width*0.85,
                    child: Row(
                      children: [
                        Container(width: 10.0,),
                        Expanded(child: TextField(
                          decoration: InputDecoration.collapsed(
                            hintText: AppLocalizations.text(LangKey.inputCustomerHint)
                          ),
                          onSubmitted: (value) {
                            searchCustomer(value);
                          },
                          controller: _searchController,
                        )),
                        Container(width: 5.0,),
                        InkWell(
                          onTap: () {
                            searchCustomer(_searchController.text);
                          },
                            child: const Icon(Icons.search_outlined,color: Colors.blue,)),
                        Container(width: 5.0,),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (customerAccountSearch != null) Padding(
              padding: const EdgeInsets.only(bottom: 5.0,top: 20.0,left: 15.0,right: 15.0),
              child: Row(
                children: [
                  Expanded(child: AutoSizeText(AppLocalizations.text(LangKey.searchingResult),style: const TextStyle(fontWeight: FontWeight.bold),textScaleFactor: 1.15,),),
                  InkWell(
                      onTap: () {
                        setState(() {
                          isShowListSearch = !isShowListSearch;});
                      },
                      child: const Center(child: Icon(Icons.arrow_drop_down_outlined,color: Colors.grey,size: 30.0,)))
                ],
              ),
            ),
            if(ChatConnection.isChatHub) isInitScreen ? Expanded(child: Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator())) :
              actionChatHubView(),
          ],
        ),
      ),
    );
  }

  void editName() async {
    _controller.text = widget.roomData.title??customerAccount?.data?.fullName??'';
    final FocusNode _focusNode = FocusNode();
    await showDialog<bool>(
      context: context,
      builder: (context) {
        _focusNode.requestFocus();
        return StatefulBuilder(
            builder: (BuildContext cxtx, StateSetter setState) {
              return CupertinoAlertDialog(
                title:
                Text(AppLocalizations.text(LangKey.members)),
                content: Card(
                  color: Colors.transparent,
                  elevation: 0.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 8.0, bottom: 3.0),
                        child: CupertinoTextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          placeholder: AppLocalizations.text(
                              LangKey.members),
                        ),
                      ),
                      CupertinoButton(
                          child: Text(AppLocalizations.text(
                              LangKey.accept)),
                          onPressed: () async {
                            FocusManager.instance.primaryFocus
                                ?.unfocus();
                            Navigator.of(context).pop();
                            bool result = false;
                            if(ChatConnection.isChatHub) {
                              result = await ChatConnection
                                  .updateNameChatHub(
                                customerAccount?.data?.customerId != null ? customerAccount!.data!.customerId.toString() :
                                customerAccount!.data!.customerLeadId.toString(),
                                  customerAccount?.data?.type??'',
                                  _controller.value.text);
                            }
                            else {
                              result = await ChatConnection
                                  .updateRoomName(
                                  widget.roomData.sId!,
                                  _controller.value.text);
                            }
                            if (result) {
                              FocusManager.instance.primaryFocus
                                  ?.unfocus();
                              if(ChatConnection.isChatHub) {
                                customerAccount?.data?.fullName = _controller.value.text;
                              }
                              else {
                                widget.roomData.title =
                                    _controller.value.text;
                              }
                              reload();
                            } else {
                              errorDialog(content: ChatConnection.isChatHub?LangKey.getFileError:null);
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

  void searchCustomer(String keyword) async {
    if(keyword != '') {
      showLoading();
      customerAccountSearch = await ChatConnection.searchCustomer(keyword);
      Navigator.of(context).pop();
      setState(() {
        isShowListSearch = true;
      });
    }
    else {
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
                child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator(),
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
          if(isShowListSearch) Column(
            children:
            customerAccountSearch == null ? [] :
            customerAccountSearch!.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Container(
                decoration: BoxDecoration(
                    color: const Color(0xFF28A17D),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey)
                ),
                child: Row(
                  children: [
                    Expanded(child: Container(
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
                          Container(height: 10.0,),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(right: 5.0),
                                      child: Icon(Icons.account_circle_rounded,color: Colors.blueAccent,),
                                    ),
                                    Expanded(child: AutoSizeText(e?.data?.fullName??''),
                                    )],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.orangeAccent,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 3.0,horizontal: 8.0),
                                    child: AutoSizeText(AppLocalizations.text(e?.data?.type == 'cpo' ? LangKey.cpo : LangKey.customer),style: const TextStyle(color: Colors.white),),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(height: 8.0,),
                          if((e?.data?.customerCode != null) || (e?.data?.customerLeadCode != null)) Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 5.0),
                                child: Icon(Icons.code,color: Colors.blueAccent,),
                              ),
                              Expanded(child: AutoSizeText(e?.data?.customerCode??e?.data?.customerLeadCode??'',style: const TextStyle(color: Colors.black),),
                              )],
                          ),
                          Container(height: 8.0,),
                          if((e?.data?.phone != null) || (e?.data?.phone2 != null)) Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 5.0),
                                child: Icon(Icons.phone,color: Colors.blueAccent,),
                              ),
                              Expanded(child: AutoSizeText(e?.data?.phone??e?.data?.phone2??''),
                              )],
                          ),
                          Container(height: 8.0,),
                          if((e?.data?.email != null)) Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(right: 5.0),
                                child: Icon(Icons.email,color: Colors.blueAccent,),
                              ),
                              Expanded(child: AutoSizeText(e?.data?.email??''),
                              )],
                          ),
                          Container(height: 8.0,),
                        ],
                      ),
                    )),
                    InkWell(
                      onTap: () async {
                        showLoading();
                        r.People info = getPeople(widget.roomData.people);
                        await ChatConnection.customerLink(info.sId??'',
                            e?.data?.customerId, e?.data?.customerLeadId,
                            e?.data?.type??'',
                            customerAccount?.data?.mappingId??'');
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
                          padding: EdgeInsets.symmetric(horizontal: 8.0,vertical: 3.0),
                          child:
                          Icon(Icons.link_outlined,color: Colors.white,),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )).toList(),
          )
        ],
      ),
    );
  }

  Widget actionChatHubView() {
    return Expanded(child: ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      physics: const ClampingScrollPhysics(),
      children: [
        Container(height: 10.0,),
        if (customerAccount?.data != null) _customerAccount(),
        listCustomerSearch(),
        Padding(
          padding: const EdgeInsets.only(bottom: 15.0),
          child: Container(
            height: 1.0,
            color: const Color(0xFFE5E5E5),
          ),
        ),
        InkWell(
          onTap: () {
            if(ChatConnection.searchProducts != null) {
              ChatConnection.searchProducts!();
            }
          },
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.grey.shade400)
              ),
              height: 40.0,
              width: MediaQuery.of(context).size.width*0.85,
              child: Row(
                children: [
                  Container(width: 5.0,),
                  const Icon(Icons.search_outlined,color: Colors.blue,),
                  Container(width: 5.0,),
                  Expanded(child: AutoSizeText(AppLocalizations.text(LangKey.productSearch)))
                ],
              ),
            ),
          ),
        ),
        Container(height: 10.0,),
        InkWell(
          onTap: () {
            if(ChatConnection.searchOrders != null) {
              ChatConnection.searchOrders!();
            }},
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey.shade400)
              ),
              height: 40.0,
              width: MediaQuery.of(context).size.width*0.85,
              child: Row(
                children: [
                  Container(width: 5.0,),
                  const Icon(Icons.search_outlined,color: Colors.blue,),
                  Container(width: 5.0,),
                  Expanded(child: AutoSizeText(AppLocalizations.text(LangKey.orderSearch)))
                ],
              ),
            ),
          ),
        ),
        Container(height: 10.0,),
        InkWell(
          onTap: () async {
            r.People info = getPeople(widget.roomData.people);
            Map<String,dynamic>? result = await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
              return ActionListUserChathubScreen(data: info, customerAccount: customerAccount);
            }));
            if(result != null) {
              showLoading();
              r.People info = getPeople(widget.roomData.people);
              await ChatConnection.customerLink(info.sId??'',
                  result['customerId'], result['customerLeadId'],
                  result['type'],
                  customerAccount?.data?.mappingId??'');
              Navigator.of(context).pop();
              isShowListSearch = false;
              customerAccountSearch = null;
              _loadAccount();
            }
          },
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.grey.shade400)
              ),
              height: 40.0,
              width: MediaQuery.of(context).size.width*0.85,
              child: Row(
                children: [
                  Container(width: 5.0,),
                  const Icon(Icons.accessibility,color: Colors.blue,),
                  Container(width: 5.0,),
                  Expanded(child: AutoSizeText(AppLocalizations.text(LangKey.actions)))
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }

  Widget _customerAccount() {
    return customerAccount!.data!.type == null ? Container() :
      Column(
      children: [
        if((customerAccount!.data!.customerCode??customerAccount!.data!.customerLeadCode??'') != '') SizedBox(
          width: MediaQuery.of(context).size.width*0.65,
          child: Row(
            children: [
              const Icon(Icons.account_box,color: Colors.blueAccent,),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: AutoSizeText(customerAccount!.data!.customerCode??customerAccount!.data!.customerLeadCode??'',overflow: TextOverflow.ellipsis,),
              )),
            ],
          ),
        ),
        if((customerAccount!.data!.phone??customerAccount!.data!.phone2??'') != '') Container(height: 8.0,),
        if((customerAccount!.data!.phone??customerAccount!.data!.phone2??'') != '') SizedBox(
          width: MediaQuery.of(context).size.width*0.65,
          child: Row(
            children: [
              const Icon(Icons.phone,color: Colors.blueAccent,),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: AutoSizeText(customerAccount!.data!.phone??customerAccount!.data!.phone2??'',overflow: TextOverflow.ellipsis,),
              )),
            ],
          ),
        ),
        if((customerAccount!.data!.email??'') != '') Container(height: 8.0,),
        if((customerAccount!.data!.email??'') != '')SizedBox(
          width: MediaQuery.of(context).size.width*0.65,
          child: Row(
            children: [
              const Icon(Icons.email,color: Colors.blueAccent,),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: AutoSizeText(customerAccount!.data!.email??'',overflow: TextOverflow.ellipsis,),
              )),
            ],
          ),
        ),
        if((customerAccount!.data!.fullAddress??'') != '') Container(height: 8.0,),
        if((customerAccount!.data!.fullAddress??'') != '') SizedBox(
          width: MediaQuery.of(context).size.width*0.65,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_pin,color: Colors.blueAccent,),
              Expanded(child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: AutoSizeText(customerAccount!.data!.fullAddress??''),
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
                    if(ChatConnection.viewProfileChatHub != null) {
                      ChatConnection.viewProfileChatHub!(
                          customerAccount?.data?.type == 'customer' ? customerAccount?.data?.customerId : customerAccount?.data?.customerLeadId,
                          customerAccount?.data?.type == 'customer' ? customerAccount?.data?.customerCode : customerAccount?.data?.customerLeadCode,
                          customerAccount?.data?.type
                      );
                    }
                  },
                    child: AutoSizeText(AppLocalizations.text(LangKey.viewDetail),style: const TextStyle(color: Colors.blue,fontWeight: FontWeight.w600),))),
          ),
        ),
      ],
    );
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
                size: 35,
              ),
              AppLocalizations.text(LangKey.file), () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ConversationFileScreen(
                  roomData: widget.roomData,
                  chatMessage: widget.chatMessage,
                )));
          }),
          if (widget.roomData.isGroup!)
            Padding(
              padding: const EdgeInsets.only(
                  left: 50.0, right: 50.0, top: 13.0),
              child: Container(
                height: 1.0,
                color: const Color(0xFFE5E5E5),
              ),
            ),
          if (widget.roomData.isGroup!)
            _section(
                const Icon(
                  Icons.group,
                  color: Color(0xff5686E1),
                  size: 35,
                ),
                AppLocalizations.text(LangKey.viewMembers), () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChatGroupMembersScreen(
                      roomData: widget.roomData)));
            }),
          if (widget.roomData.isGroup!)
            Padding(
              padding: const EdgeInsets.only(
                  left: 50.0, right: 50.0, top: 13.0),
              child: Container(
                height: 1.0,
                color: const Color(0xFFE5E5E5),
              ),
            ),
          if (widget.roomData.isGroup!)
            _section(
                const Icon(
                  Icons.remove_circle,
                  color: Color(0xff5686E1),
                  size: 35,
                ),
                AppLocalizations.text(LangKey.leaveConversation), () {
              _leaveRoom(widget.roomData.sId!);
            }, textColor: Colors.black),
          if (!widget.roomData.isGroup! ||
              (widget.roomData.owner == ChatConnection.user!.id &&
                  widget.roomData.isGroup!))
            Padding(
              padding: const EdgeInsets.only(
                  left: 50.0, right: 50.0, top: 13.0),
              child: Container(
                height: 1.0,
                color: const Color(0xFFE5E5E5),
              ),
            ),
          if (!widget.roomData.isGroup! ||
              (widget.roomData.owner == ChatConnection.user!.id &&
                  widget.roomData.isGroup!))
            _section(
                const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 35,
                ),
                AppLocalizations.text(LangKey.deleteConversation), () {
              !widget.roomData.isGroup! ? _removeLeaveRoom(widget.roomData.sId!) :
              _removeRoom(widget.roomData.sId!);
            }, textColor: Colors.red)
        ],
      ),
    );
  }

  void errorDialog({String? content}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.text(LangKey.warning)),
        content: Text(content ?? AppLocalizations.text(LangKey.changeGroupNameError)),
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

  Widget _buildAvatar(String name, String avatarName, String? url, {Function()? onTap}) {
    Widget child;
    double radius = MediaQuery.of(context).size.width * 0.125;
    if (url != null) {
      child = CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider('$url/${ChatConnection.brandCode!}',headers: {'brand-code':ChatConnection.brandCode!}),
        backgroundColor: Colors.transparent,
      );
    }
    else {
      child = CircleAvatar(
        radius: radius,
        child: Text(avatarName,
            style: const TextStyle(color: Colors.white),
            maxLines: 1,
            textScaleFactor: 1.75),
      );
    }

    return Column(
      children: [
        child,
        Container(height: 10.0,),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0
                  ),
                )),
                if(onTap != null)
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
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 23.0, right: 10),
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
                padding: EdgeInsets.only(left: 5.0, right: 23.0),
                child: Icon(
                  Icons.navigate_next_outlined,
                  color: Color(0xFFE5E5E5),
                ),
              ),
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
                ChatConnection.leaveRoom(
                    roomId, ChatConnection.user?.id).then((value) {
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
}
