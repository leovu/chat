// TODO: Model này đang trong quá trình phát triển.
// Cập nhật các key parse (id, name, phone, avatar, data list key...)
// khi API /api/whatsapp/get-contacts hoàn thiện và có response chính thức.

class WhatsAppContactsResponse {
  final List<WhatsAppMember>? members;

  WhatsAppContactsResponse({this.members});

  factory WhatsAppContactsResponse.fromJson(Map<String, dynamic> json) {
    // TODO: Điều chỉnh key list theo response thực tế (hiện dùng 'data')
    final list = json['data'] as List?;
    return WhatsAppContactsResponse(
      members: list?.map((e) => WhatsAppMember.fromJson(e)).toList(),
    );
  }
}

class WhatsAppMember {
  final String? id;
  final String? name;
  final String? phone;
  final String? avatar;

  WhatsAppMember({this.id, this.name, this.phone, this.avatar});

  factory WhatsAppMember.fromJson(Map<String, dynamic> json) {
    // TODO: Điều chỉnh key theo response thực tế của API
    return WhatsAppMember(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }
}
