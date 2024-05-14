/*
* Created by: nguyenan
* Created at: 2024/05/03 10:41
*/
class QuotaResponseModel {
  bool? canSend;

  QuotaResponseModel({this.canSend});

  QuotaResponseModel.fromJson(Map<String, dynamic> json) {
    try{
      canSend = json['data']['can_send'];
    } catch(e){}
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['can_send'] = this.canSend;
    return data;
  }
}