/*
* Created by: nguyenan
* Created at: 2024/05/02 10:06
*/
import 'package:chat/common/base_bloc.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/data_model/response/notes_response_model.dart';
import 'package:rxdart/rxdart.dart';

class ConversationBloc extends BaseBloc {

  final notes = BehaviorSubject<NotesResponseModel>();
  ValueStream<NotesResponseModel> get outputNotes => notes.stream;
  setNotes(NotesResponseModel event) => set(notes, event);

  getNotes(String roomId) async {
    NotesResponseModel? notes = await ChatConnection.notes(roomId);
    if(notes != null){
      setNotes(notes);
    }
  }

  Future<bool?> deleteNotes(String roomId, int noteId) async {
    bool? check = await ChatConnection.deleteNotes(roomId, noteId);
    return check;
  }
}