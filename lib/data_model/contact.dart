

import 'package:chat/data_model/room.dart';
class Contacts {
  int? limit;
  String? search;
  List<People>? users;

  Contacts({limit, search, users});

  Contacts.fromJson(Map<String, dynamic> json) {
    limit = json['limit'];
    search = json['search'];
    if (json['users'] != null) {
      users = <People>[];
      json['users'].forEach((v) {
        users!.add(People.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['limit'] = limit;
    data['search'] = search;
    if (users != null) {
      data['users'] = users!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
