import 'dart:io';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/chat_ui/hex_color.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/data_model/customer_account.dart';
import 'package:chat/data_model/tag.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/room.dart' as r;

class TagListScreen extends StatefulWidget {
  final r.People data;
  final CustomerAccount? customerAccount;
  const TagListScreen({Key? key, required this.data, required this.customerAccount}) : super(key: key);
  @override
  _State createState() => _State();
}

class _State extends State<TagListScreen> {
  bool isInitScreen = true;
  Tag? tag;
  Color color = Colors.red;
  final TextEditingController _controller = TextEditingController();
  @override

  void initState() {
    super.initState();
    _getTagList();
  }
  void _getTagList() async {
    tag = await ChatConnection.getTagList();
    if(tag?.data != null && widget.data.userTag != null) {
      for (var e in tag!.data!) {
        if(widget.data.userTag!.contains(e.sId)) {
          e.isSelected = true;
        }
      }
    }
    setState(() {
      isInitScreen = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            AppLocalizations.text(LangKey.addLabel),
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
        body: SafeArea(child:
        isInitScreen ? Center(child: Platform.isAndroid ? const CircularProgressIndicator() : const CupertinoActivityIndicator()) :
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(child: Container(
                    height: 37.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey.shade400)
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            bool result = await colorPickerDialog();
                            if(result) {
                              setState(() {
                                color = tempColorPick!;
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                child: AutoSizeText(AppLocalizations.text(LangKey.change),style: TextStyle(color: HexColor.fromHex('#0067AC'),fontWeight: FontWeight.bold),),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Container(decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(5.0)
                                  ),height: 10.0,width: 10.0,)
                              ),
                              Container(width: 1.0,color: Colors.grey,),
                            ],
                          ),
                        ),
                        Expanded(child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: TextField(
                            decoration: InputDecoration.collapsed(
                                hintText: AppLocalizations.text(LangKey.inputNewLabel)
                            ),
                            controller: _controller,
                          ),
                        ))
                      ],
                    ),
                  )),
                  Container(width: 15.0),
                  ElevatedButton(onPressed: () async {
                    if(_controller.value.text == '') {
                      return;
                    }
                    showLoading();
                    bool result = await ChatConnection.createTag(_controller.value.text, color.toHex());
                    Navigator.of(context).pop();
                    if(result) {
                      _getTagList();
                    }
                  },child: AutoSizeText(AppLocalizations.text(LangKey.create),style: TextStyle(color: _controller.value.text != '' ? Colors.white : Colors.black),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _controller.value.text != '' ? const Color(0xFF5686E1) : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),)
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 5.0),
              child: Container(height: 1.0,color: Colors.grey.shade400,),
            ),
            if(tag?.data != null) Expanded(child: ListView(
              padding: const EdgeInsets.only(left: 15.0,right: 15.0),
              physics: const ClampingScrollPhysics(),
              children: tag!.data!.map((e) => Column(
                children: [
                  Row(
                    children: [
                      Checkbox(value: e.isSelected, onChanged: (value) {
                        setState(() {
                          e.isSelected = !e.isSelected;
                        });
                      }),
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Container(decoration: BoxDecoration(
                            color: HexColor.fromHex(e.color??''),
                            borderRadius: BorderRadius.circular(5.0)
                        ),height: 10.0,width: 10.0,),
                      ),
                      Expanded(child: AutoSizeText(e.name??''),),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: InkWell(
                          onTap: () async {
                            showLoading();
                            bool result = await ChatConnection.removeTag(e.sId??'',widget.data.sId??'');
                            Navigator.of(context).pop();
                            if(result) {
                              _getTagList();
                              widget.data.userTag?.remove(e.sId??'');
                              widget.data.isUpdateTagList = true;
                            }
                          },
                          child: const SizedBox(
                              height: 40.0,
                              child: Icon(Icons.close,size: 15.0,)),
                        ),
                      ),
                    ],
                  ),
                  Container(height: 1.0,color: Colors.grey.shade400,)
                ],
              )).toList(),
            )),
            SizedBox(
              height: 49.0,
              width: MediaQuery.of(context).size.width*0.85,
              child: MaterialButton(
                color: const Color(0xFF5686E1),
                onPressed: () async {
                  List<String> arr = [];
                  if(tag?.data!=null) {
                    for (var e in tag!.data!) {
                      if(e.isSelected) {
                        arr.add(e.sId??'');
                      }
                    }
                  }
                  if(arr.isNotEmpty) {
                    showLoading();
                    bool result = await ChatConnection.updateTag(arr, widget.data.sId??'');
                    Navigator.of(context).pop();
                    if(result) {
                      widget.data.userTag = arr;
                      widget.data.isUpdateTagList = true;
                    }
                    Navigator.of(context).pop();
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(AppLocalizations.text(LangKey.saveLabel),style: const TextStyle(color: Colors.white, fontSize: 16,fontWeight: FontWeight.w600),),
              ),
            )
          ],
        ),)
    );
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
  Color? tempColorPick;
  Future<bool> colorPickerDialog() async {
    return ColorPicker(
      color: color,
      onColorChanged: (Color color) =>
          setState(() => tempColorPick = color),
      width: 40,
      height: 40,
      borderRadius: 4,
      spacing: 5,
      runSpacing: 5,
      wheelDiameter: 155,
      heading: Text(
        'Select color',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      subheading: Text(
        'Select color shade',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      wheelSubheading: Text(
        'Selected color and its shades',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      showMaterialName: true,
      showColorName: true,
      showColorCode: true,
      copyPasteBehavior: const ColorPickerCopyPasteBehavior(
        longPressMenu: true,
      ),
      materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
      colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
      pickersEnabled: const <ColorPickerType, bool>{
        ColorPickerType.both: false,
        ColorPickerType.primary: true,
        ColorPickerType.accent: true,
        ColorPickerType.bw: false,
        ColorPickerType.custom: true,
        ColorPickerType.wheel: true,
      },
    ).showPickerDialog(
      context,
      constraints:
      const BoxConstraints(minHeight: 460, minWidth: 300, maxWidth: 320),
    );
  }
}