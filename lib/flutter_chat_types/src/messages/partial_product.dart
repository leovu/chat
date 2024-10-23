import 'package:chat/data_model/chat_message.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../message.dart';
import 'image_message.dart';

part 'partial_product.g.dart';

/// A class that represents partial image message.
@JsonSerializable()
@immutable
class PartialProduct {
  /// Creates a partial image message with all variables image can have.
  /// Use [ImageMessage] to create a full message.
  /// You can use [ImageMessage.fromPartial] constructor to create a full
  /// message from a partial one.
  const PartialProduct({
    this.height,
    this.metadata,
    required this.name,
    this.repliedMessage,
    required this.size,
    this.width,
    this.messageItems,
  });

  /// Creates a partial image message from a map (decoded JSON).
  factory PartialProduct.fromJson(Map<String, dynamic> json) =>
      _$PartialProductFromJson(json);

  /// Image height in pixels.
  final double? height;

  /// Additional custom metadata or attributes related to the message.
  final Map<String, dynamic>? metadata;

  /// The name of the image.
  final String name;

  /// Message that is being replied to with the current message.
  final Message? repliedMessage;

  /// Size of the image in bytes.
  final num size;

  /// Image width in pixels.
  final double? width;

  final List<MessageItems>? messageItems;

  /// Converts a partial image message to the map representation, encodable to JSON.
  Map<String, dynamic> toJson() => _$PartialProductToJson(this);
}
