import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_screen/chat_screen.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/contact.dart';
import 'package:chat/data_model/room.dart';
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
  Contacts? contactsListVisible;
  Contacts? contactsListData;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await _getContacts();
    });

  }
  _getContacts() async {
    contactsListData = await ChatConnection.contactsList();
    _getContactsVisible();
    setState(() {});
  }

  _getContactsVisible() {
    String val = _controllerSearch.value.text.toLowerCase();
    if(val != '') {
      contactsListVisible!.users = contactsListVisible!.users!.where((element) {
        try {
          if(
          ('${element.firstName} ${element.lastName}'.toLowerCase()).contains(val)) {
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
      try{
        contactsListVisible?.users = <r.People>[...contactsListData!.users!.toList()];
      }catch(_) {}
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(color: Colors.white,
    child:
    GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Column(children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
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
                              Navigator.of(context).pop();
                            },
                            child: SizedBox(
                                width:30.0,
                                child: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back, color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                    const Center(
                      child:
                      Padding(
                        padding: EdgeInsets.only(bottom: 3.0,left: 10.0,right: 10.0,top: 2.0),
                        child: Text('New Group Chat',style: TextStyle(fontSize: 22.0,color: Colors.black)),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0,right: 10.0,top: 10.0),
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.grey,width: 1.0)),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        Expanded(child: TextField(
                          focusNode: _focusGroupName,
                          controller: _controllerGroupName,
                          onChanged: (_) {
                            setState(() {
                              _getContactsVisible();
                            });
                          },
                          decoration: const InputDecoration.collapsed(
                            hintText: 'Group name',
                          ),
                        )),
                      ],
                    ),
                  ),
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
                            hintText: 'Search',
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
              child: contactsListVisible != null ? ListView.builder(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: contactsListVisible!.users?.length,
                  itemBuilder: (BuildContext context, int position) {
                    return InkWell(
                        onTap: () async {
                          setState(() {
                            if(contactsListVisible!.users![position].isSelected != null) {
                              contactsListVisible!.users![position].isSelected = !contactsListVisible!.users![position].isSelected!;
                            }
                            else {
                              contactsListVisible!.users![position].isSelected = true;
                            }
                          });
                        },
                        child: _contacts(contactsListVisible!.users![position], position == contactsListVisible!.users!.length-1));
                  }) : Container(),
            ),
            contactsListVisible != null && isSelectedMember(contactsListVisible?.users) ? Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: SizedBox(
                height: 49.0,
                width: MediaQuery.of(context).size.width*0.85,
                child: MaterialButton(
                  color: const Color(0xFF5686E1),
                  onPressed: () async {
                    List<String> people = [];
                    try{
                      contactsListData?.users?.forEach((element) {
                        if(element.isSelected != null && element.isSelected == true) {
                          people.add(element.sId!);
                        }
                      });
                    }catch(_){}
                    if(people.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Warning'),
                          content: const Text('Select at least one user'),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Accept'))
                          ],
                        ),
                      );
                    }
                    else if(_controllerGroupName.value.text == '') {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Warning'),
                          content: const Text('Must have group name'),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Accept'))
                          ],
                        ),
                      );
                    }
                    else {
                      people.add(ChatConnection.user!.id);
                      r.Rooms? rooms = await ChatConnection.createGroup(_controllerGroupName.text,people);
                      await Navigator.of(context,rootNavigator: true).pushReplacement(
                        MaterialPageRoute(builder: (context) => ChatScreen(data: rooms!),settings:const RouteSettings(name: 'chat_screen')),
                      );
                      try{
                        ChatConnection.refreshRoom.call();
                        ChatConnection.refreshFavorites.call();
                      }catch(_){}
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Text('Create Group',style: TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.w600),),
                ),
              ),
            ) : Container()
          ],),
        ),
      ),
    ));
  }
  bool isSelectedMember(List<People>? data) {
    try {
      data?.firstWhere((element) => element.isSelected == true);
      return true;
    }catch(_){
      return false;
    }
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
                    )),
                    SizedBox(
                      height: 30.0,
                      width: 30.0,
                      child: data.isSelected != null && data.isSelected! ? const Icon(Icons.radio_button_checked,size: 25.0,color: Color(0xff0021F5))
                          : const Icon(Icons.radio_button_off,size: 25.0,color: Color(0xff0021F5)),
                    )
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

}