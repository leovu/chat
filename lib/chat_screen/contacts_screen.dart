import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/chat_screen/home_screen.dart';
import 'package:chat/chat_ui/vietnamese_text.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/contact.dart';
import 'package:chat/data_model/room.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/room.dart' as r;
import 'chat_screen.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ContactsScreen extends StatefulWidget {
  final RefreshBuilder builder;
  const ContactsScreen({Key? key, required this.builder,}) : super(key: key);
  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> with AutomaticKeepAliveClientMixin {
  final _focusSearch = FocusNode();
  final _controllerSearch = TextEditingController();

  Contacts? contactsListVisible;
  Contacts? contactsListData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _getContacts();
    });
  }
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  void _onRefresh() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    await _getContacts();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async{
    await Future.delayed(const Duration(milliseconds: 1000));
    await _getContacts();
    _refreshController.loadComplete();
  }
  _getContacts() async {
    if(mounted) {
      contactsListData = await ChatConnection.contactsList();
      _getContactsVisible();
      setState(() {});
    }
    else {
      WidgetsBinding.instance?.addPostFrameCallback((_) async {
        contactsListData = await ChatConnection.contactsList();
        _getContactsVisible();
        setState(() {});
      });
    }
  }

  _getContactsVisible() {
    String val = _controllerSearch.value.text.toLowerCase().removeAccents();
    if(val != '') {
      contactsListVisible!.users = contactsListData!.users!.where((element) {
        try {
          if(
          ('${element.firstName} ${element.lastName}'.toLowerCase().removeAccents()).contains(val)) {
            return true;
          }
          return false;
        }catch(e){
          return false;
        }
      }).toList();
    }
    else {
      contactsListVisible = Contacts();
      contactsListVisible?.limit = contactsListData?.limit;
      contactsListVisible?.search = contactsListData?.search;
      contactsListVisible?.users = <r.People>[...contactsListData!.users!.toList()];
    }
  }
  @override
  Widget build(BuildContext context) {
    widget.builder.call(context, _getContacts);
    super.build(context);
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Column(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 30.0,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.of(ChatConnection.buildContext).pop();
                        },
                        child: SizedBox(
                            width:30.0,
                            child: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.black)),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 3.0,left: 10.0,right: 10.0),
                  child: Text('Contacts',style: TextStyle(fontSize: 25.0,color: Colors.black)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                        color: const Color(0xFFE7EAEF), borderRadius: BorderRadius.circular(5)),
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
                        Expanded(child: TextField(
                          focusNode: _focusSearch,
                          controller: _controllerSearch,
                          onChanged: (_) {
                            setState(() {
                              _getContactsVisible();
                            });
                          },
                          decoration: const InputDecoration.collapsed(
                            hintText: 'Search Contacts',
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
                            onTap: (){
                              _controllerSearch.text = '';
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() {
                                _getContactsVisible();
                              });
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
              child: contactsListVisible != null ? SmartRefresher(
                enablePullDown: true,
                enablePullUp: false,
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                header: const WaterDropHeader(),
                child: ListView.builder(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: contactsListVisible!.users?.length,
                    itemBuilder: (BuildContext context, int position) {
                      return InkWell(
                          onTap: () async {
                            r.Rooms? rooms = await ChatConnection.createRoom(contactsListVisible!.users![position].sId);
                            await Navigator.of(context,rootNavigator: true).push(
                              MaterialPageRoute(builder: (context) => ChatScreen(data: rooms!),settings:const RouteSettings(name: 'chat_screen')),
                            );
                            _getContacts();
                            try{
                              ChatConnection.refreshRoom.call();
                              ChatConnection.refreshFavorites.call();
                            }catch(_){}
                          },
                          child: _contacts(contactsListVisible!.users![position], position == contactsListVisible!.users!.length-1));
                    }),
              ) : Container(),
            )
          ],),
        ),
      ),
    );
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
                    data.picture == null ? CircleAvatar(
                      radius: 25.0,
                      child: Text(data.getAvatarName()),
                    ) : CircleAvatar(
                      radius: 25.0,
                      backgroundImage:
                      CachedNetworkImageProvider('${HTTPConnection.domain}api/images/${data.picture!.shieldedID}/256'),
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
  @override
  bool get wantKeepAlive => true;

}