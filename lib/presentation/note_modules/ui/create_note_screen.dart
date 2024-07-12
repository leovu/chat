import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/common/custom_navigator.dart';
import 'package:chat/common/theme.dart';
import 'package:chat/data_model/response/notes_response_model.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:chat/presentation/note_modules/bloc/create_note_bloc.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/room.dart' as r;

class CreateNoteScreen extends StatefulWidget {
  final c.ChatMessage? chatMessage;
  final r.Rooms roomData;
  final Note? note;
  const CreateNoteScreen(
      {Key? key, required this.roomData, this.chatMessage, this.note})
      : super(key: key);
  @override
  _ConversationFileScreenState createState() => _ConversationFileScreenState();
}

class _ConversationFileScreenState extends State<CreateNoteScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteNode = FocusNode();
  late CreateNoteBloc _bloc;
  @override
  void initState() {
    super.initState();
    _bloc = CreateNoteBloc();
    setState(() {
      if(widget.note != null) _noteController.text = widget.note!.content ?? '';
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.note != null ? AppLocalizations.text(LangKey.update_note) : AppLocalizations.text(LangKey.create_note),
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
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(20.0),
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: AppColors.grayBackGround.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.0)
              ),
              child: TextField(
                controller: _noteController,
                focusNode: _noteNode,
                maxLines: 8, //or null
                decoration: InputDecoration.collapsed(hintText: AppLocalizations.text(LangKey.input_note_hint)),
              ),
            ),
            Expanded(child: Container()),
            Container(
              padding: EdgeInsets.all(AppSizes.minPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: ()=> CustomNavigator.pop(context),
                    child: Container(
                        height: 40.0,
                        width: MediaQuery.of(context).size.width / 2 - 20.0,
                        color: AppColors.grayBackGround,
                        child: Center(child: Text( AppLocalizations.text(LangKey.cancel),style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),))),
                  ),
                  // Container(width: 20,),
                  InkWell(
                    onTap: (){
                      if(widget.note == null) _bloc.createNote(context, widget.roomData.sId!, _noteController.text.trim());
                      else _bloc.updateNote(context, widget.roomData.sId!, _noteController.text.trim(), widget.note!.iId!);
                    },
                    child: Container(
                        height: 40.0,
                        width: MediaQuery.of(context).size.width / 2 - 20.0,
                        color: Colors.blue,
                        child: Center(child: Text( AppLocalizations.text(LangKey.confirm),style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),))),
                  )
                ],
              ),
            ),
            Container(height: 20.0,)
          ],
        ),
      ),
    );
  }
}