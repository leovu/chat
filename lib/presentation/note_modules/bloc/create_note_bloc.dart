/*
* Created by: nguyenan
* Created at: 2024/05/02 11:23
*/
import 'package:chat/common/base_bloc.dart';
import 'package:chat/common/custom_navigator.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/data_model/response/notes_response_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

class CreateNoteBloc extends BaseBloc {

  final notes = BehaviorSubject<NotesResponseModel>();
  ValueStream<NotesResponseModel> get outputNotes => notes.stream;
  setNotes(NotesResponseModel event) => set(notes, event);

  createNote(BuildContext context, String roomId, String content) async {
    bool? notes = await ChatConnection.createNotes(roomId, content);
    if(notes) CustomNavigator.pop(context);
    else return false;
  }

  updateNote(BuildContext context, String roomId, String content, int noteId) async {
    bool? notes = await ChatConnection.updateNotes(roomId, content, noteId);
    if(notes) CustomNavigator.pop(context);
    else return false;
  }
}