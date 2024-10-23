// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partial_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PartialProduct _$PartialProductFromJson(Map<String, dynamic> json) => PartialProduct(
  height: (json['height'] as num?)?.toDouble(),
  metadata: json['metadata'] as Map<String, dynamic>?,
  name: json['name'] as String,
  repliedMessage: json['repliedMessage'] == null
      ? null
      : Message.fromJson(json['repliedMessage'] as Map<String, dynamic>),
  size: json['size'] as num,
  width: (json['width'] as num?)?.toDouble(),
  messageItems: json['message_items'] == null
      ? null
      : (json['message_items'] as List).map((item) => MessageItems.fromJson(item)).toList(),
);

Map<String, dynamic> _$PartialProductToJson(PartialProduct instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('height', instance.height);
  writeNotNull('metadata', instance.metadata);
  val['name'] = instance.name;
  writeNotNull('repliedMessage', instance.repliedMessage?.toJson());
  val['size'] = instance.size;
  writeNotNull('width', instance.width);
  val['message_items'] = instance.messageItems == null
      ? null
      : instance.messageItems!.map((item) => item.toJson()).toList();
  return val;
}
