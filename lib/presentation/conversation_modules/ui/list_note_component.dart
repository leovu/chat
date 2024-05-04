/*
* Created by: nguyenan
* Created at: 2024/05/02 10:25
*/
import 'package:chat/common/custom_navigator.dart';
import 'package:chat/common/theme.dart';
import 'package:chat/common/widges/widget.dart';
import 'package:chat/data_model/response/notes_response_model.dart';
import 'package:chat/data_model/room.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:chat/presentation/conversation_modules/bloc/conversation_bloc.dart';
import 'package:chat/presentation/note_modules/ui/create_note_screen.dart';
import 'package:flutter/material.dart';

class ListNoteComponent extends StatefulWidget {
  ConversationBloc bloc;
  Function refreshFunc;
  Rooms roomData;
  ListNoteComponent(this.bloc, this.refreshFunc, this.roomData, {super.key});

  @override
  _State createState() => _State();
}

class _State extends State<ListNoteComponent> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.bloc.outputNotes,
        initialData: NotesResponseModel(data: []),
        builder: (_, snapshot){
          NotesResponseModel? notes = snapshot.data;
          return notes!.data!.isNotEmpty ? Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20.0, left: 20.0, bottom: 10.0),
                child: Text(
                  AppLocalizations.text(LangKey.note),
                ),
              ),
              Column(
                children: notes!.data!.map((e) => noteItem(e)).toList(),
              )
            ],
          ) : Container();
    });
  }

  Widget noteItem(Note note){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomLine(),
          Container(height: 10.0,),
          Row(
            children: [
              Expanded(child: Text(
                note.createdAt ?? ""
              )),
              InkWell(
                onTap: () async {
                   await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => CreateNoteScreen(roomData: widget.roomData, note: note,),
                          settings:const RouteSettings(name: 'create_note_screen')));
                    widget.refreshFunc();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: AppSizes.minPadding),
                  height: 30.0,
                  width: 30.0,
                  child: const Icon(Icons.edit_note_outlined, color: AppColors.grayBackGround,),
                ),
              ),
              InkWell(
                onTap: () async {
                  CustomNavigator.showCustomAlertDialog(context, null,
                      AppLocalizations.text(LangKey.delete_note_des),
                      titleHeader:
                      AppLocalizations.text(LangKey.warning),
                      enableCancel: true,
                      textSubSubmitted:
                      AppLocalizations.text(LangKey.cancel),
                      textSubmitted: AppLocalizations.text(LangKey.confirm),
                      onSubmitted: () async {
                        CustomNavigator.pop(context);
                        bool? check = await widget.bloc.deleteNotes(widget.roomData.sId!, note.iId!);
                        if(check != null) if(check) widget.refreshFunc();
                      });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: AppSizes.minPadding),
                  height: 30.0,
                  width: 30.0,
                  child: const Icon(Icons.delete_forever, color: AppColors.redColor,),
                ),
              )
            ],
          ),
          Container(
            child: Text(
                note.content ?? "",
            ),
          )
        ],
      ),
    );
  }
}