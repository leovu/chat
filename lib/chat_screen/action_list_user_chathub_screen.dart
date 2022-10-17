import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/chat_screen/tag_list_screen.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/data_model/customer_account.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/room.dart' as r;
// ignore: import_of_legacy_library_into_null_safe
import 'package:lead_plugin_epoint/lead_plugin_epoint.dart';

class ActionListUserChathubScreen extends StatefulWidget {
  final r.People data;
  final CustomerAccount? customerAccount;
  const ActionListUserChathubScreen({Key? key, required this.data, required this.customerAccount}) : super(key: key);
  @override
  _State createState() => _State();
}

class _State extends State<ActionListUserChathubScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            AppLocalizations.text(LangKey.actions),
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          leading: InkWell(
            child: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                color: Colors.black),
            onTap: () => Navigator.of(context).pop(),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
        ),
        body: SafeArea(child: ListView(
          padding: const EdgeInsets.only(top: 20.0),
          physics: const ClampingScrollPhysics(),
          children: [
            if(widget.customerAccount?.data?.type == null) _action(AppLocalizations.text(LangKey.addCustomer), Icons.people, () async {
              if(ChatConnection.addCustomer != null) {
                Map<String,dynamic>? addCustomer = await ChatConnection.addCustomer!();
                if(addCustomer != null) {
                  Navigator.of(context).pop(addCustomer);
                }
              }
            }),
            if(widget.customerAccount?.data?.type == null) Container(height: 15.0,),
            if(widget.customerAccount?.data?.type == null) _action(AppLocalizations.text(LangKey.addCustomerPotential), Icons.emoji_people,  () async {
              LeadPluginEpoint.open(context, ChatConnection.locale, ChatConnection.productToken, 0, domain: ChatConnection.productDomain?.substring(0, ChatConnection.productDomain?.length??1 - 1),
                  brandCode: ChatConnection.brandCode, action: addPotentialCustomer);
            }),
            if(widget.customerAccount?.data?.type == null) Container(height: 15.0,),
            _action(AppLocalizations.text(LangKey.addLabel), Icons.label_important_outline, () {
              Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                return TagListScreen(data: widget.data, customerAccount: widget.customerAccount);
              }));
            }),
            Container(height: 15.0,),
            _action(AppLocalizations.text(LangKey.createOrder), Icons.backpack_outlined, ChatConnection.createOrder),
            Container(height: 15.0,),
            _action(AppLocalizations.text(LangKey.createAppointment), Icons.calendar_today_outlined, ChatConnection.createAppointment),
            Container(height: 15.0,),
            _action(AppLocalizations.text(LangKey.createDeal), Icons.star_border, ChatConnection.createDeal),
            Container(height: 15.0,),
            _action(AppLocalizations.text(LangKey.createTask), Icons.add_task, ChatConnection.createTask),
            Container(height: 15.0,),
          ],
        ),)
    );
  }

  void addPotentialCustomer(Map<String,dynamic> addCustomer) {
    Navigator.of(context).pop(addCustomer);
  }
  
  Widget _action(String title, IconData icon, Function? action) {
    return
      InkWell(
        onTap: () {
          if(action!=null) {
            action();
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
                Container(width: 10.0,),
                Icon(icon,color: Colors.blue,),
                Container(width: 10.0,),
                Expanded(child: AutoSizeText(title))
              ],
            ),
          ),
        ),
      );
  }
  
}