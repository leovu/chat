import 'package:chat/data_model/chat_message.dart';
import 'package:chat/flutter_chat_types/src/messages/partial_product.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../message.dart';
import '../user.dart' show User;

part 'product_message.g.dart';

/// A class that represents image message.
@JsonSerializable()
@immutable
abstract class ProductMessage extends Message {
  /// Creates an image message.
  const ProductMessage._({
    required super.author,
    super.createdAt,
    this.height,
    required super.id,
    super.metadata,
    required this.name,
    super.remoteId,
    super.repliedMessage,
    super.roomId,
    super.showStatus,
    required this.size,
    super.status,
    MessageType? type,
    super.updatedAt,
    this.width,
    required this.messageItems
  }) : super(type: type ?? MessageType.products);

  const factory ProductMessage({
    required User author,
    int? createdAt,
    double? height,
    required String id,
    Map<String, dynamic>? metadata,
    required String name,
    String? remoteId,
    Message? repliedMessage,
    String? roomId,
    bool? showStatus,
    required num size,
    Status? status,
    MessageType? type,
    int? updatedAt,
    double? width,
    required List<MessageItems>? messageItems
  }) = _ProductMessage;

  /// Creates an image message from a map (decoded JSON).
  factory ProductMessage.fromJson(Map<String, dynamic> json) =>
      _$ProductMessageFromJson(json);

  /// Creates a full image message from a partial one.
  factory ProductMessage.fromPartial({
    required User author,
    int? createdAt,
    required String id,
    required PartialProduct partialProduct,
    String? remoteId,
    String? roomId,
    bool? showStatus,
    Status? status,
    int? updatedAt,
    List<MessageItems>? messageItems
  }) =>
      _ProductMessage(
        author: author,
        createdAt: createdAt,
        height: partialProduct.height,
        id: id,
        metadata: partialProduct.metadata,
        name: partialProduct.name,
        remoteId: remoteId,
        repliedMessage: partialProduct.repliedMessage,
        roomId: roomId,
        showStatus: showStatus,
        size: partialProduct.size,
        status: status,
        type: MessageType.image,
        updatedAt: updatedAt,
        width: partialProduct.width,
        messageItems: partialProduct.messageItems
      );

  /// Image height in pixels.
  final double? height;

  /// The name of the image.
  final String name;

  /// Size of the image in bytes.
  final num size;

  /// Image width in pixels.
  final double? width;

  final List<MessageItems>? messageItems;

  /// Equatable props.
  @override
  List<Object?> get props => [
    author,
    createdAt,
    height,
    id,
    metadata,
    name,
    remoteId,
    repliedMessage,
    roomId,
    showStatus,
    size,
    status,
    updatedAt,
    width,
    messageItems
  ];

  @override
  Message copyWith({
    User? author,
    int? createdAt,
    double? height,
    String? id,
    Map<String, dynamic>? metadata,
    String? name,
    String? remoteId,
    Message? repliedMessage,
    String? roomId,
    bool? showStatus,
    num? size,
    Status? status,
    int? updatedAt,
    double? width,
    List<MessageItems>? messageItems
  });

  /// Converts an image message to the map representation, encodable to JSON.
  @override
  Map<String, dynamic> toJson() => _$ProductMessageToJson(this);
}

/// A utility class to enable better copyWith.
class _ProductMessage extends ProductMessage {
  const _ProductMessage({
    required super.author,
    super.createdAt,
    super.height,
    required super.id,
    super.metadata,
    required super.name,
    super.remoteId,
    super.repliedMessage,
    super.roomId,
    super.showStatus,
    required super.size,
    super.status,
    super.type,
    super.updatedAt,
    super.width,
    required super.messageItems
  }) : super._();

  @override
  Message copyWith({
    User? author,
    dynamic createdAt = _Unset,
    dynamic height = _Unset,
    String? id,
    dynamic metadata = _Unset,
    String? name,
    dynamic remoteId = _Unset,
    dynamic repliedMessage = _Unset,
    dynamic roomId = _Unset,
    dynamic showStatus = _Unset,
    num? size,
    dynamic status = _Unset,
    dynamic updatedAt = _Unset,
    dynamic width = _Unset,
    List<MessageItems>? messageItems
  }) =>
      _ProductMessage(
        author: author ?? this.author,
        createdAt: createdAt == _Unset ? this.createdAt : createdAt as int?,
        height: height == _Unset ? this.height : height as double?,
        id: id ?? this.id,
        metadata: metadata == _Unset
            ? this.metadata
            : metadata as Map<String, dynamic>?,
        name: name ?? this.name,
        remoteId: remoteId == _Unset ? this.remoteId : remoteId as String?,
        repliedMessage: repliedMessage == _Unset
            ? this.repliedMessage
            : repliedMessage as Message?,
        roomId: roomId == _Unset ? this.roomId : roomId as String?,
        showStatus:
        showStatus == _Unset ? this.showStatus : showStatus as bool?,
        size: size ?? this.size,
        status: status == _Unset ? this.status : status as Status?,
        updatedAt: updatedAt == _Unset ? this.updatedAt : updatedAt as int?,
        width: width == _Unset ? this.width : width as double?,
        messageItems: messageItems ?? this.messageItems
      );
}

class _Unset {}
