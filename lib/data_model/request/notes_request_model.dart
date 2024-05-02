/*
* Created by: nguyenan
* Created at: 2024/05/02 09:31
*/
class NotesRequestModel {
  String? roomId;
  int? limit;
  int? offset;

  NotesRequestModel({roomId, limit, offset});

  NotesRequestModel.fromJson(Map<String, dynamic> json) {
    roomId = json['roomId'];
    limit = json['limit'];
    offset = json['offset'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['roomId'] = roomId;
    data['limit'] = limit;
    data['offset'] = offset;
    return data;
  }
}