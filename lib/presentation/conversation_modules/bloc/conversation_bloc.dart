/*
* Created by: nguyenan
* Created at: 2024/05/02 10:06
*/
import 'package:chat/common/base_bloc.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/data_model/response/notes_response_model.dart';
import 'package:chat/data_model/response/quota_response_model.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data_model/session.dart';
import '../../../data_model/summary.dart';

class ConversationBloc extends BaseBloc {
  final notes = BehaviorSubject<NotesResponseModel>();
  final BehaviorSubject<List<SessionModel>> _session =
      BehaviorSubject<List<SessionModel>>.seeded([]);
  final BehaviorSubject<ConversationSummaryModel> _summary =
      BehaviorSubject<ConversationSummaryModel>();

  ValueStream<NotesResponseModel> get outputNotes => notes.stream;
  NotesResponseModel get notesValue => notes.value;
  setNotes(NotesResponseModel event) => set(notes, event);

  Stream<List<SessionModel>> get sessionStream => _session.stream;
  List<SessionModel> get session => _session.value;

  Stream<ConversationSummaryModel> get summaryStream => _summary.stream;
  ConversationSummaryModel get summary => _summary.value;

  getNotes(String roomId) async {
    NotesResponseModel? notes = await ChatConnection.notes(roomId);
    if (notes != null) {
      setNotes(notes);
    }
  }

  Future<bool?> getQuota(String socialChannelId, String userSocialId) async {
    QuotaResponseModel? notes =
        await ChatConnection.getQuota(socialChannelId, userSocialId);
    if (notes != null) {
      return notes.canSend;
    }
    return false;
  }

  Future<bool?> deleteNotes(String roomId, String noteId) async {
    bool? check = await ChatConnection.deleteNotes(roomId, noteId);
    return check;
  }

  Future<void> getSession(String roomId,
      {int offset = 0, int limit = 5}) async {
    try {
      final response =
          await ChatConnection.getSession(roomId, limit: limit, offset: offset);
      _session.sink.add(response);
    } catch (_) {}
  }

  Future<void> getSummary(String sessionId) async {
    try {
      final response = await ChatConnection.getSummary(sessionId);
      if (response != null) {
        _summary.sink.add(response);
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _session.close();
    super.dispose();
  }
}
