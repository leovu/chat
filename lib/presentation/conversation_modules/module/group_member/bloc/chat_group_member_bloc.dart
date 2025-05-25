import 'package:chat/common/base_bloc.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/data_model/response/group_member_response_model.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatGroupMemberBloc extends BaseBloc {
  final listMemberZalo = BehaviorSubject<MemberListData>();
  int countPeople = 0;

  @override
  void dispose() {
    super.dispose();
    listMemberZalo.close();
  }

  onGetMemberInfo(String channelZaloId, String id) async {
    final respose = await ChatConnection.getMemberInfo(channelZaloId, id);
    if (respose != null) {
      listMemberZalo.add(respose);
    }
  }

  onAcceptPending(
      String chanelId, String groupId, List<String> memeberUserIds) async {
    final response = await ChatConnection.acceptPendingInvite(
        chanelId, groupId, memeberUserIds);
    if (response == false)
      showDialog(
        context: context,
        builder: (cxt) => AlertDialog(
          title: Text(AppLocalizations.text(LangKey.notifications)),
          content: Text(response?.message ?? ''),
        ),
      );
  }

  onRejectPending(
      String chanelId, String groupId, List<String> memeberUserIds) async {
    final response = await ChatConnection.rejectPendingInvite(
        chanelId, groupId, memeberUserIds);
    if (response == false)
      showDialog(
        context: context,
        builder: (cxt) => AlertDialog(
          title: Text(AppLocalizations.text(LangKey.notifications)),
          content: Text(response?.message ?? ''),
        ),
      );
  }
  openUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}
}
