/*
* Created by: nguyenan
* Created at: 2024/05/02 09:35
*/
import '../session.dart';

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
  String? id;
  String? content;
  String? room;
  String? createdStaffId;
  String? updatedStaffId;
  String? createdBy;
  String? updatedBy;
  StaffInfo? createdByStaff;
  String? createdAt;
  String? updatedAt;
  int? v;

  Note({
    this.id,
    this.content,
    this.room,
    this.createdStaffId,
    this.updatedStaffId,
    this.createdBy,
    this.updatedBy,
    this.createdByStaff,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['_id'],
      content: json['content'],
      room: json['room'],
      createdStaffId: json['created_staff_id'],
      updatedStaffId: json['updated_staff_id'],
      createdBy: json['createdBy'],
      updatedBy: json['updatedBy'],
      createdByStaff: json['created_by_staff'] != null
          ? StaffInfo.fromJson(json['created_by_staff'])
          : null,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'content': content,
      'room': room,
      'created_staff_id': createdStaffId,
      'updated_staff_id': updatedStaffId,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'created_by_staff': createdByStaff?.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}
