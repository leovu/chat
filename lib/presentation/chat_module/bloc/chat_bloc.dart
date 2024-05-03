
/*
* Created by: nguyenan
* Created at: 2024/05/03 11:16
*/
import 'package:chat/common/base_bloc.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/data_model/response/quota_response_model.dart';

class ChatBloc extends BaseBloc {

  ChatBloc();

  @override
  void dispose() {
  }

  Future<bool> getQuota(String socialChannelId, String userSocialId) async {
    QuotaResponseModel? notes = await ChatConnection.getQuota(socialChannelId, userSocialId);
    if(notes != null){
      return notes!.canSend ?? false;
    }
    return false;
  }
}
