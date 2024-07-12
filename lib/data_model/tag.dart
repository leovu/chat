class Tag {
  int? error;
  List<Data>? data;

  Tag({error, data});

  Tag.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Tag.fromListJson(List<dynamic> json) {
    if (json.isNotEmpty) {
      data = <Data>[];
      for(var e in json) {
        data!.add(Data.fromJson(e));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  bool? status;
  String? sId;
  String? name;
  String? color;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? isActive;
  bool isSelected = false;

  Data(
      {status,
        sId,
        name,
        color,
        createdAt,
        updatedAt,
        isActive,
        iV});

  Data.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    sId = json['_id'];
    name = json['name'];
    color = json['color'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    isActive = json['isActive'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['_id'] = sId;
    data['name'] = name;
    data['color'] = color;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    data['isActive'] = isActive;
    return data;
  }
}