/*
* Created by: nguyenan
* Created at: 2024/05/13 10:06
*/
class CheckUserTokenResponseModel {
  UserTokenModel? user;
  String? token;

  CheckUserTokenResponseModel({this.user, this.token});

  CheckUserTokenResponseModel.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? new UserTokenModel.fromJson(json['user']) : null;
    token = json['token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.user != null) {
      data['user'] = this.user!.toJson();
    }
    data['token'] = this.token;
    return data;
  }
}

class UserTokenModel {
  String? level;
  // List<Null>? favorites;
  // List<Null>? userTag;
  String? tagLine;
  int? isFollowed;
  bool? isBlocked;
  bool? isIncognito;
  String? sId;
  String? username;
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  int? iV;
  String? lastOnline;
  // Null? cpoCustomerCode;
  // Null? cpoCustomerId;
  // Null? customerCode;
  // Null? customerId;
  // List<Null>? tags;
  String? createdAt;

  UserTokenModel(
      {this.level,
        // this.favorites,
        // this.userTag,
        this.tagLine,
        this.isFollowed,
        this.isBlocked,
        this.isIncognito,
        this.sId,
        this.username,
        this.email,
        this.password,
        this.firstName,
        this.lastName,
        this.iV,
        this.lastOnline,
        // this.cpoCustomerCode,
        // this.cpoCustomerId,
        // this.customerCode,
        // this.customerId,
        // this.tags,
        this.createdAt});

  UserTokenModel.fromJson(Map<String, dynamic> json) {
    level = json['level'];
    // if (json['favorites'] != null) {
    //   favorites = <Null>[];
    //   json['favorites'].forEach((v) {
    //     favorites!.add(new Null.fromJson(v));
    //   });
    // }
    // if (json['userTag'] != null) {
    //   userTag = <Null>[];
    //   json['userTag'].forEach((v) {
    //     userTag!.add(new Null.fromJson(v));
    //   });
    // }
    tagLine = json['tagLine'];
    isFollowed = json['isFollowed'];
    isBlocked = json['isBlocked'];
    isIncognito = json['isIncognito'];
    sId = json['_id'];
    username = json['username'];
    email = json['email'];
    password = json['password'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    iV = json['__v'];
    lastOnline = json['lastOnline'];
    // cpoCustomerCode = json['cpoCustomerCode'];
    // cpoCustomerId = json['cpoCustomerId'];
    // customerCode = json['customerCode'];
    // customerId = json['customerId'];
    // if (json['tags'] != null) {
    //   tags = <Null>[];
    //   json['tags'].forEach((v) {
    //     tags!.add(new Null.fromJson(v));
    //   });
    // }
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['level'] = this.level;
    // if (this.favorites != null) {
    //   data['favorites'] = this.favorites!.map((v) => v.toJson()).toList();
    // }
    // if (this.userTag != null) {
    //   data['userTag'] = this.userTag!.map((v) => v.toJson()).toList();
    // }
    data['tagLine'] = this.tagLine;
    data['isFollowed'] = this.isFollowed;
    data['isBlocked'] = this.isBlocked;
    data['isIncognito'] = this.isIncognito;
    data['_id'] = this.sId;
    data['username'] = this.username;
    data['email'] = this.email;
    data['password'] = this.password;
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['__v'] = this.iV;
    data['lastOnline'] = this.lastOnline;
    // data['cpoCustomerCode'] = this.cpoCustomerCode;
    // data['cpoCustomerId'] = this.cpoCustomerId;
    // data['customerCode'] = this.customerCode;
    // data['customerId'] = this.customerId;
    // if (this.tags != null) {
    //   data['tags'] = this.tags!.map((v) => v.toJson()).toList();
    // }
    data['createdAt'] = this.createdAt;
    return data;
  }
}