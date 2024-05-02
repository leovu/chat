/*
* Created by: nguyenan
* Created at: 2024/05/02 09:35
*/
class NotesResponseModel {
  List<Note>? data;

  NotesResponseModel({this.data});

  NotesResponseModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Note>[];
      json['data'].forEach((v) {
        data!.add(new Note.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Note {
  int? iId;
  String? content;
  String? createdAt;

  Note({this.iId, this.content, this.createdAt});

  Note.fromJson(Map<String, dynamic> json) {
    iId = json['_id'];
    content = json['content'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.iId;
    data['content'] = this.content;
    data['createdAt'] = this.createdAt;
    return data;
  }
}