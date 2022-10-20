class CustomerAccount {
  int? error;
  Data? data;

  CustomerAccount({error, data});

  CustomerAccount.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['error'] = error;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? customerId;
  String? customerCode;
  String? fullName;
  String? phone;
  String? phone2;
  String? address;
  String? fullAddress;
  String? email;
  String? mappingId;
  int? customerLeadId;
  String? customerLeadCode;
  String? type;

  Data(
      {customerId,
        customerCode,
        fullName,
        phone,
        phone2,
        address,
        fullAddress,
        email,
        mappingId,
        customerLeadId,
        customerLeadCode,
        type});

  Data.fromJson(Map<String, dynamic> json) {
    customerId = int.tryParse(json['customer_id'].toString());
    customerCode = json['customer_code'];
    fullName = json['full_name'];
    phone = json['phone'];
    phone2 = json['phone2'];
    address = json['address'];
    fullAddress = json['full_address'];
    email = json['email'];
    mappingId = json['mapping_id'];
    customerLeadId = json['customer_lead_id'];
    customerLeadCode = json['customer_lead_code'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customer_id'] = customerId;
    data['customer_code'] = customerCode;
    data['full_name'] = fullName;
    data['phone'] = phone;
    data['phone2'] = phone2;
    data['address'] = address;
    data['full_address'] = fullAddress;
    data['email'] = email;
    data['mapping_id'] = mappingId;
    data['customer_lead_id'] = customerLeadId;
    data['customer_lead_code'] = customerLeadCode;
    data['type'] = type;
    return data;
  }

  String getName(){
    return fullName??"";
  }

  String getAvatarName() {
    String avatarName = '';
    if(fullName != null) {
      avatarName += fullName![0];
      if(fullName!.contains(' ')) {
        final splits = fullName!.split(' ');
        avatarName += splits[1][0];
      }
      else {
        if(fullName!.length >= 2) {
          avatarName += fullName![1];
        }
      }
    }
    return avatarName;
  }
}