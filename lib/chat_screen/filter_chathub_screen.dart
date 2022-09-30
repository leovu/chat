import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/data_model/chathub_channel.dart';
import 'package:chat/data_model/tag.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FilterChathubScreen extends StatefulWidget {
  final String? status;
  final String? channel;
  final List<String?>? arrLabel;
  const FilterChathubScreen({Key? key, this.status, this.channel , this.arrLabel}) : super(key: key);
  @override
  _FilterChathubScreenState createState() => _FilterChathubScreenState();
}

class _FilterChathubScreenState extends State<FilterChathubScreen> {
  bool isInitScreen = true;
  ChathubChannel? channels;
  String? status;
  String? channel;
  List<String?> arrLabel = [];
  Tag? tag;
  List<String> arrStatus = ['not_seen','seen','replied'];
  @override
  void initState() {
    super.initState();
    status = widget.status;
    channel = widget.channel;
    if(widget.arrLabel != null) {
      arrLabel = widget.arrLabel!;
    }
    _getChannel();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: AutoSizeText(
              AppLocalizations.text(LangKey.filter),
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            leading: InkWell(
              child: Icon(
                  Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
                  color: Colors.black),
              onTap: () => Navigator.of(context).pop(),
            ),
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
          ),
          body: SafeArea(
            child: isInitScreen ? Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator()) :
            Column(
              children: [
                Expanded(child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.all(10.0),
                  children: [
                    Container(height: 15.0,),
                    AutoSizeText(AppLocalizations.text(LangKey.byChannel),style: const TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold),textScaleFactor: 1.15,),
                    Container(height: 15.0,),
                    Wrap(
                      children: channels?.channels == null ? [] : _listChannelWidget(),
                    ),
                    Container(height: 30.0,),
                    AutoSizeText(AppLocalizations.text(LangKey.byStatus),style: const TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold),textScaleFactor: 1.15,),
                    Container(height: 15.0,),
                    Wrap(
                      children: channels?.channels == null ? [] : _listStatusWidget(),
                    ),
                    Container(height: 30.0,),
                    AutoSizeText(AppLocalizations.text(LangKey.byLabel),style: const TextStyle(color: Colors.blueAccent,fontWeight: FontWeight.bold),textScaleFactor: 1.15,),
                    Container(height: 15.0,),
                    Wrap(
                      children: tag?.data == null ? [] : _listLabelWidget(),
                    )
                  ],
                ),),
                Padding(
                  padding: const EdgeInsets.only(bottom: 9.0, top: 15.0),
                  child: SizedBox(
                    height: 41.0,
                    width: MediaQuery.of(context).size.width*0.95,
                    child: MaterialButton(
                      color: const Color(0xFF5686E1),
                      onPressed: () async {
                        Navigator.of(context).pop({
                          'status':status,
                          'channel':channel,
                          'tag_ids': arrLabel.isEmpty ? null : arrLabel
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(AppLocalizations.text(LangKey.accept),style: const TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.w600),),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15.0),
                  child: SizedBox(
                    height: 41.0,
                    width: MediaQuery.of(context).size.width*0.95,
                    child: MaterialButton(
                      color: Colors.white,
                      onPressed: () async {
                        setState(() {
                          status = null;
                          channel = null;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                          side: const BorderSide(color: Color(0xFF5686E1))
                      ),
                      child: Text(AppLocalizations.text(LangKey.delete),style:
                      const TextStyle(color: Color(0xFF5686E1), fontSize: 16,fontWeight: FontWeight.w600),),
                    ),
                  ),
                )
              ],
            )
          )),
    );
  }

  List<Widget> _listLabelWidget() {
    List<Widget> arr = [];
    arr = tag!.data!.map((e) =>
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: InkWell(
            onTap: () {
              if(arrLabel.contains(e.sId)) {
                arrLabel.remove(e.sId);
              }
              else {
                arrLabel.add(e.sId);
              }
              setState(() {});
            },
            child: Chip(label: Text(e.name??'',
              style: TextStyle(color: arrLabel.contains(e.sId) ? Colors.blueAccent : Colors.grey),),
              backgroundColor: arrLabel.contains(e.sId) ? Colors.white :Colors.grey.shade200,
              shape: StadiumBorder(side: BorderSide(color: arrLabel.contains(e.sId) ? Colors.blueAccent : Colors.grey)),),
          ),
        ),).toList();
    arr.insert(0, Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            arrLabel.clear();
          });
        },
        child: Chip(label: Text(AppLocalizations.text(LangKey.all),
          style: TextStyle(color: arrLabel.isEmpty ? Colors.blueAccent : Colors.grey),),
          backgroundColor: arrLabel.isEmpty ? Colors.white :Colors.grey.shade200,
          shape: StadiumBorder(side: BorderSide(color: arrLabel.isEmpty ? Colors.blueAccent : Colors.grey)),),
      ),
    ));
    return arr;
  }

  List<Widget> _listStatusWidget() {
    List<Widget> arr = [];
    arr = arrStatus.map((e) =>
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: InkWell(
            onTap: () {
              setState(() {
                status = e;
              });
            },
            child: Chip(label: Text(AppLocalizations.text(e),
              style: TextStyle(color: status == e ? Colors.blueAccent : Colors.grey),),
              backgroundColor: status == e ? Colors.white :Colors.grey.shade200,
              shape: StadiumBorder(side: BorderSide(color: status == e ? Colors.blueAccent : Colors.grey)),),
          ),
        ),).toList();
    arr.insert(0, Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            status = null;
          });
        },
        child: Chip(label: Text(AppLocalizations.text(LangKey.all),
          style: TextStyle(color: status == null ? Colors.blueAccent : Colors.grey),),
          backgroundColor: status == null ? Colors.white :Colors.grey.shade200,
          shape: StadiumBorder(side: BorderSide(color: status == null ? Colors.blueAccent : Colors.grey)),),
      ),
    ));
    return arr;
  }

  List<Widget> _listChannelWidget() {
    List<Widget> arr = [];
    arr = channels!.channels!.map((e) =>
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: InkWell(
            onTap: () {
              setState(() {
                channel = e.sId??'';
              });
            },
            child: Chip(label: Text(e.nameApp??'',
              style: TextStyle(color: channel == e.sId ? Colors.blueAccent : Colors.grey),),
              backgroundColor: channel == e.sId ? Colors.white :Colors.grey.shade200,
              shape: StadiumBorder(side: BorderSide(color: channel == e.sId ? Colors.blueAccent : Colors.grey)),),
          ),
        ),).toList();
    arr.insert(0, Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            channel = null;
          });
        },
        child: Chip(label: Text(AppLocalizations.text(LangKey.all),
          style: TextStyle(color: channel == null ? Colors.blueAccent : Colors.grey),),
          backgroundColor: channel == null ? Colors.white :Colors.grey.shade200,
          shape: StadiumBorder(side: BorderSide(color: channel == null ? Colors.blueAccent : Colors.grey)),),
      ),
    ));
    return arr;
  }

  void _getChannel() async {
    channels = await ChatConnection.channelList();
    tag = await ChatConnection.getTagList();
    isInitScreen = false;
    setState(() {});
  }

}