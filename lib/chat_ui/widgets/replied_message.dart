
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/chat_ui/widgets/message.dart';
import 'package:chat/common/theme.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:chat/chat_ui/widgets/inherited_user.dart';
import 'package:url_launcher/url_launcher.dart';
import 'inherited_chat_theme.dart';
import '../../data_model/room.dart' as r;

class RepliedMessage extends StatelessWidget {
  const RepliedMessage(
      {Key? key,
      this.onCancelReplyPressed,
      this.messageAuthorId,
      required this.repliedMessage,
      this.showUserNames = false,
      required this.onMessageTap,
      required this.people,
      this.isActive = true})
      : super(key: key);

  final bool isActive;
  final List<r.People>? people;

  /// Called when user presses cancel reply button
  final void Function()? onCancelReplyPressed;

  /// Current message author id
  final String? messageAuthorId;

  /// Message that is being replied to by current message
  final types.Message? repliedMessage;

  /// Show user names for replied messages.
  final bool showUserNames;

  /// See [Message.onMessageTap]
  final void Function(
      BuildContext context, types.Message, bool isRepliedMessage)? onMessageTap;

  @override
  Widget build(BuildContext context) {
    String _text = '';
    String? _imageUri;
    bool _isFile = false;
    bool _isAudio = false;
    bool _isVideo = false;
    bool _isCustome = false;

    types.CustomMessage _customMessage;

    final bool _closable = onCancelReplyPressed != null;
    final bool _isCurrentUser =
        messageAuthorId == InheritedUser.of(context).user.id;
    final _theme = InheritedChatTheme.of(context).theme;

    ReplyType _getReplyType() {
      if (_imageUri != null) return ReplyType.image;
      if (_isFile) return ReplyType.file;
      if (_isAudio) return ReplyType.audio;
      if (_isVideo) return ReplyType.video;
      if (_isCustome) return ReplyType.custom;
      return ReplyType.none;
    }

    if (repliedMessage != null) {
      switch (repliedMessage!.type) {
        case types.MessageType.file:
          final fileMessage = repliedMessage as types.FileMessage;
          _text = fileMessage.name;
          _isFile = true;
          break;
        case types.MessageType.image:
          final imageMessage = repliedMessage as types.ImageMessage;
          _text = AppLocalizations.text(LangKey.photo);
          _imageUri = imageMessage.uri;
          break;
        case types.MessageType.text:
          final textMessage = repliedMessage as types.TextMessage;
          _text = textMessage.text;
          break;
        case types.MessageType.audio:
          _isAudio = true;
          break;
        case types.MessageType.video:
          _isVideo = true;
          break;
        case types.MessageType.custom:
          final customMessage = repliedMessage as types.CustomMessage;
          _customMessage = customMessage;
          _isCustome = true;
          break;
        default:
          break;
      }
      // _text = checkTag(_text, people);
    }

    // ---------- Helpers ----------

    Widget _buildImageWidget() {
      return Container(
        width: 44,
        height: 44,
        margin: _theme.repliedMessageImageMargin,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            _imageUri!,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    Widget _buildFileWidget() {
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Container(
          width: 44,
          height: 44,
          child: Icon(
            Icons.insert_drive_file,
            size: 30,
            color: Colors.blueAccent,
          ),
        ),
      );
    }

    Widget _buildAudioWidget() {
      return SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Icon(
            Icons.play_circle_filled,
            size: 16,
            color: AppColors.bluePrimary,
          ),
        ),
      );
    }

    Widget _buildVideoWidget() {
      return SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: Icon(
            Icons.play_circle, // hoặc Icons.play_arrow
            size: 16,
            color: AppColors.bluePrimary,
          ),
        ),
      );
    }

    Widget _buildStickerWidget() {
      // Kiểm tra xem repliedMessage có metadata và custom_type không
      if (repliedMessage?.metadata != null) {
        final metadata = repliedMessage?.metadata;
        final stickerUrl = metadata?['url']; // Lấy sticker từ metadata
        if (stickerUrl != null) {
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Image.network(
                      stickerUrl,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              );
            },
            child: SizedBox(
              width: 44,
              height: 44,
              child: Image.network(
                stickerUrl,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      }
      return const SizedBox
          .shrink(); // Nếu không có sticker, trả về SizedBox trống
    }

    Widget _buildProductsWidget() {
      if (repliedMessage?.metadata != null) {
        final metadata = repliedMessage!.metadata;
        final products = metadata?['items']; // Lấy sản phẩm từ metadata

        if (products != null) {
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final item = products[index];
              return ListTile(
                leading:
                    Image.network(item['image_urls'][0], width: 40, height: 40),
                title: Text(item['name']),
              );
            },
          );
        }
      }
      return const SizedBox
          .shrink(); // Nếu không có sản phẩm, trả về SizedBox trống
    }

    Widget _buildZpListWidget({required double messageWidth}) {
      final metadata = repliedMessage?.metadata;
      if (metadata == null) return const SizedBox.shrink();

      final rawItems = metadata['items'];
      final List<Map<String, dynamic>> items =
          (rawItems is List) ? rawItems.cast<Map<String, dynamic>>() : const [];

      if (items.isEmpty) {
        final text = (metadata['text'] as String?) ?? '';
        if (text.isEmpty) return const SizedBox.shrink();

        return Expanded(
          child: InkWell(
            onTap: () async {
              final uri = Uri.tryParse(text);
              if (uri != null && await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            child: Container(
              // width: messageWidth,
              padding: const EdgeInsets.all(8),
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      }

      final first = items.first;
      final title = (first['title'] as String? ?? '').trim();
      final description = (first['description'] as String? ?? '').trim();
      final href = (first['href'] as String? ?? '').trim();
      Future<void> _openUrl(String url) async {
        final uri = Uri.tryParse(url);
        if (uri != null && await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }

      final canTap = href.isNotEmpty && Uri.tryParse(href) != null;
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: messageWidth.toDouble()),
        child: InkWell(
          onTap: canTap ? () => _openUrl(href) : null,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty) ...[
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (description.isNotEmpty) const SizedBox(height: 4),
                ],
                if (description.isNotEmpty)
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (href.isNotEmpty && title.isEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    href,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildGenericWidget() {
      if (repliedMessage?.metadata != null) {
        final metadata = repliedMessage!.metadata;
        final elements = metadata?['elements'];

        _imageUri = elements[0]['image_url'].toString();

        if (elements != null && elements.isNotEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        elements[0]['image_url'].toString(),
                        width: double.infinity,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (elements[0]['title'] ?? '').toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if ((elements[0]['subtitle'] as String?)?.isNotEmpty ??
                            false) ...[
                          const SizedBox(height: 8),
                          Text(elements[0]['subtitle'].toString()),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
      return const SizedBox.shrink();
    }

    Widget _buildOaTemplateWidget() {
      return Icon(
        Icons.file_copy, // Biểu tượng tượng trưng cho template
        size: 40,
        color: AppColors.bluePrimary,
      );
    }

    Widget _buildCustom() {
      if (repliedMessage?.metadata == null) {
        return const SizedBox.shrink();
      }

      final metadata = repliedMessage?.metadata;

      switch (metadata?['custom_type']) {
        case 'sticker':
          return _buildStickerWidget(); // Hiển thị sticker nếu custom_type là 'sticker'
        case 'products':
          return _buildProductsWidget(); // Hiển thị danh sách sản phẩm nếu custom_type là 'products'
        case 'generic':
          return _buildGenericWidget(); // Hiển thị generic nếu custom_type là 'generic'
        case 'oa_template':
          return _buildOaTemplateWidget(); // Hiển thị OA template nếu custom_type là 'oa_template'
        case 'zp_list':
          return _buildZpListWidget(
              messageWidth: MediaQuery.sizeOf(context).width *
                  0.4); // Hiển thị ZP list nếu custom_type là 'zp_list'
        default:
          return const SizedBox.shrink();
      }
    }

    Widget _buildPreview() {
      switch (_getReplyType()) {
        case ReplyType.image:
          return _buildImageWidget();
        case ReplyType.file:
          return _buildFileWidget();
        case ReplyType.audio:
          return _buildAudioWidget();
        case ReplyType.video:
          return _buildVideoWidget();
        case ReplyType.custom:
          return _buildCustom();
        default:
          return const SizedBox.shrink();
      }
    }

    Widget _buildReplyInfoSection({
      required bool closable,
      required bool isCurrentUser,
      required String text,
      required types.Message? repliedMessage,
      required bool showUserNames,
    }) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (repliedMessage?.author.firstName != null && showUserNames)
              AutoSizeText(
                closable
                    ? '${AppLocalizations.text(LangKey.replying)} ${repliedMessage?.author.firstName ?? ''} ${repliedMessage?.author.lastName ?? ''}'
                    : text,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
            Text(
              closable
                  ? text
                  : '${repliedMessage?.author.firstName ?? ''} ${repliedMessage?.author.lastName ?? ''}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: closable
                    ? Colors.grey
                    : isCurrentUser
                        ? Colors.grey.shade600
                        : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            if (!closable)
              const Padding(
                padding: EdgeInsets.only(top: 1.0),
                child: SizedBox(
                  height: 1.0,
                  child: ColoredBox(color: Colors.grey),
                ),
              ),
          ],
        ),
      );
    }

    Widget _buildCloseReplyButton({
      required EdgeInsets margin,
      required VoidCallback? onCancel,
    }) {
      return Container(
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        height: 20,
        width: 20,
        child: IconButton(
          icon: const Icon(
            Icons.close,
            color: Colors.white,
            size: 15.0,
          ),
          onPressed: () => onCancel?.call(),
          padding: EdgeInsets.zero,
        ),
      );
    }

    // ---------- End helpers ----------

    return InkWell(
      onTap: () {
        if ((_imageUri != null || _isFile) &&
            repliedMessage != null &&
            onMessageTap != null) {
          if (isActive) {
            onMessageTap!(context, repliedMessage!, true);
          }
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text(_text),
            ),
          );
        }
      },
      child: Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.only(bottom: _closable ? 0 : 8),
          padding: _closable
              ? _theme.closableRepliedMessagePadding
              : const EdgeInsets.fromLTRB(0, 0, 0, 0),
          decoration: BoxDecoration(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(30.0)),
            color: _closable ? Colors.grey.shade50 : Colors.transparent,
          ),
          child: Row(
            children: [
              _buildPreview(),
              _buildReplyInfoSection(
                closable: _closable,
                isCurrentUser: _isCurrentUser,
                text: _text,
                repliedMessage: repliedMessage,
                showUserNames: showUserNames,
              ),
              if (_closable)
                _buildCloseReplyButton(
                  margin: _theme.closableRepliedMessageImageMargin,
                  onCancel: onCancelReplyPressed,
                ),
            ],
          )),
    );
  }
}

enum ReplyType {
  image,
  file,
  audio,
  video,
  none,
  custom,
  sticker, // Thêm sticker
  products, // Thêm products
  generic, // Thêm generic
  system, // Thêm system
  zp_list, // Thêm zp_list
  oa_template, // Thêm oa_template
  oa_list // Thêm oa_list
}
