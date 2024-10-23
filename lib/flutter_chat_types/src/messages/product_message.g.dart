// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductMessage _$ProductMessageFromJson(Map<String, dynamic> json) => ProductMessage(
  author: User.fromJson(json['author'] as Map<String, dynamic>),
  createdAt: json['createdAt'] as int?,
  height: (json['height'] as num?)?.toDouble(),
  id: json['id'] as String,
  metadata: json['metadata'] as Map<String, dynamic>?,
  name: json['name'] as String,
  remoteId: json['remoteId'] as String?,
  repliedMessage: json['repliedMessage'] == null
      ? null
      : Message.fromJson(json['repliedMessage'] as Map<String, dynamic>),
  roomId: json['roomId'] as String?,
  showStatus: json['showStatus'] as bool?,
  size: json['size'] as num,
  status: $enumDecodeNullable(_$StatusEnumMap, json['status']),
  type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']),
  updatedAt: json['updatedAt'] as int?,
  width: (json['width'] as num?)?.toDouble(),
  messageItems: json['message_items'] == null
      ? null
      : (json['message_items'] as List).map((item) => MessageItems.fromJson(item)).toList(),
);

Map<String, dynamic> _$ProductMessageToJson(ProductMessage instance) {
  final val = <String, dynamic>{
    'author': instance.author.toJson(),
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('createdAt', instance.createdAt);
  val['id'] = instance.id;
  writeNotNull('metadata', instance.metadata);
  writeNotNull('remoteId', instance.remoteId);
  writeNotNull('repliedMessage', instance.repliedMessage?.toJson());
  writeNotNull('roomId', instance.roomId);
  writeNotNull('showStatus', instance.showStatus);
  writeNotNull('status', _$StatusEnumMap[instance.status]);
  val['type'] = _$MessageTypeEnumMap[instance.type]!;
  writeNotNull('updatedAt', instance.updatedAt);
  writeNotNull('height', instance.height);
  val['name'] = instance.name;
  val['size'] = instance.size;
  writeNotNull('width', instance.width);
  val['message_items'] = instance.messageItems == null
      ? null
      : instance.messageItems!.map((item) => item.toJson()).toList();
  return val;
}

const _$StatusEnumMap = {
  Status.delivered: 'delivered',
  Status.error: 'error',
  Status.seen: 'seen',
  Status.sending: 'sending',
  Status.sent: 'sent',
};

const _$MessageTypeEnumMap = {
  MessageType.audio: 'audio',
  MessageType.custom: 'custom',
  MessageType.file: 'file',
  MessageType.image: 'image',
  MessageType.system: 'system',
  MessageType.text: 'text',
  MessageType.unsupported: 'unsupported',
  MessageType.video: 'video',
  MessageType.products: 'products',
};
