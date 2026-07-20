import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/chat_ui/widgets/link_preview.dart';
import 'package:chat/chat_ui/widgets/custom_message_generic.dart';
import 'package:chat/chat_ui/widgets/message.dart';
import 'package:chat/chat_ui/widgets/custom_message_template_card.dart';
import 'package:chat/common/theme.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:chat/chat_ui/widgets/inherited_user.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../connection/http_connection.dart';
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
      this.isView = false,
      this.isActive = true})
      : super(key: key);

  final bool isActive;
  final List<r.People>? people;
  final bool? isView;

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

    final bool _closable = isView ?? false; //onCancelReplyPressed != null;
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
          // _text = fileMessage.name;
          _isFile = true;
          break;
        case types.MessageType.image:
          final imageMessage = repliedMessage as types.ImageMessage;
          // _text =  AppLocalizations.text(LangKey.photo);
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

    String _buildFallbackImageUri(String original) {
      final uri = Uri.parse(original);
      final domain = "${HTTPConnection.domain}";

      final lastSegment =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.last : "";
      final shieldedId = lastSegment.replaceAll('.jpg', '');

      final size = uri.pathSegments.length > 1
          ? uri.pathSegments[uri.pathSegments.length - 2]
          : "512";

      return "${domain}api/images/$shieldedId/$size/${ChatConnection.brandCode}";
    }

    Widget _buildImageWidget() {
      final fallbackUri = _buildFallbackImageUri(_imageUri!);

      if (isView == true)
        return Container(
          margin: _theme.repliedMessageImageMargin,
          decoration: BoxDecoration(
            color: Colors.transparent,
            // border: BoxBorder.fromLTRB(
            //   left: BorderSide(color: Colors.amber, width: 3),
            // )
          ),
          height: 80,
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _imageUri!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    fallbackUri,
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),
          ),
        );
      else
        return Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.transparent,
            // border: BoxBorder.fromLTRB(
            //   left: BorderSide(color: Colors.amber, width: 3),
            // )
          ),
          margin: _theme.repliedMessageImageMargin,
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _imageUri!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.network(
                    fallbackUri,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
        );
    }

    Widget _buildFileWidget() {
      // Get file info from repliedMessage
      String fileName = _text;
      String fileSize = '';

      if (repliedMessage is types.FileMessage) {
        final fileMessage = repliedMessage as types.FileMessage;
        fileName = fileMessage.name;

        // Format file size
        if (fileMessage.size != null && fileMessage.size > 0) {
          final sizeInBytes = fileMessage.size;
          if (sizeInBytes < 1024) {
            fileSize = '${sizeInBytes} B';
          } else if (sizeInBytes < 1024 * 1024) {
            fileSize = '${(sizeInBytes / 1024).toStringAsFixed(1)} KB';
          } else {
            fileSize = '${(sizeInBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
          }
        }
      }

      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.insert_drive_file,
                size: 24,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  if (fileSize.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        fileSize,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
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
            Icons.play_circle,
            size: 16,
            color: AppColors.bluePrimary,
          ),
        ),
      );
    }

    Widget _buildStickerWidget() {
      if (repliedMessage?.metadata != null) {
        final metadata = repliedMessage?.metadata;
        final stickerUrl = metadata?['url'];
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
      return const SizedBox.shrink();
    }

    Widget _buildProductsWidget() {
      if (repliedMessage?.metadata != null) {
        final metadata = repliedMessage!.metadata;
        final products = metadata?['items'];

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
      return const SizedBox.shrink();
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

        return InkWell(
          onTap: () async {
            final uri = Uri.tryParse(text);
            if (uri == null) return;
            try {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } catch (_) {
              try {
                await launchUrl(uri, mode: LaunchMode.platformDefault);
              } catch (_) {}
            }
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
        if (uri == null) return;
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (_) {
          try {
            await launchUrl(uri, mode: LaunchMode.platformDefault);
          } catch (_) {}
        }
      }

      final canTap = href.isNotEmpty && Uri.tryParse(href) != null;
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: messageWidth.toDouble()),
        child: InkWell(
          onTap: canTap ? () => _openUrl(href) : null,
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
      );
    }

    Widget _buildGenericWidget() {
      if (repliedMessage?.metadata != null) {
        final metadata = repliedMessage!.metadata;
        final elements = metadata?['elements'];

        if (elements != null && elements.isNotEmpty) {
          final element = elements[0];
          _imageUri = element['image_url']?.toString();

          return GenericElementCardReply(
            imageUrl: element['image_url']?.toString(),
            title: element['title']?.toString() ?? '',
            subtitle: element['subtitle']?.toString(),
            closable: _closable,
            width: MediaQuery.sizeOf(context).width,
          );
        }
      }
      return const SizedBox.shrink();
    }

    Widget _buildOaTemplateWidget() {
      return Text(AppLocalizations.text(LangKey.oa_template_message));
    }

    Widget _buildTemplateWidget() {
      final metadata = repliedMessage?.metadata;

      final title = metadata?['template_title'] as String? ?? 'Template';
      final desc = metadata?['template_description'].toString();
      final linkUrl = metadata?['template_url'].toString();
      final imageUrl = metadata?['template_image'] as String?;

      return isView == false
          ? TemplateCard(
              title: title,
              description: desc ?? '',
              imageUrl: imageUrl,
              linkUrl: linkUrl,
            )
          : ReplyMessageCard(
              title: title,
              description: desc ?? '',
              imageUrl: imageUrl,
              linkUrl: linkUrl,
            );
    }

    Widget _buildLinkWidget(Map<String, dynamic> metadata) {
      final url = metadata['url'] as String?;
      final text = metadata['text'] as String? ?? 'Link';

      if (url == null) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              final uri = Uri.tryParse(url);
              if (uri == null) return;
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (_) {
                try {
                  await launchUrl(uri, mode: LaunchMode.platformDefault);
                } catch (_) {}
              }
            },
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                text,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          // Reply tin link -> hiển thị review; KHÔNG hiện ở ô nhập chữ (isView).
          if (isView != true)
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.6),
              child: PreviewLink(
                content: url,
                showText: false,
                showBackground: false,
                compact: true,
              ),
            ),
        ],
      );
    }

    Widget _buildCustom() {
      if (repliedMessage?.metadata == null) {
        return const SizedBox.shrink();
      }

      final metadata = repliedMessage?.metadata;

      switch (metadata?['custom_type']) {
        case 'sticker':
          return _buildStickerWidget();
        case 'products':
          return _buildProductsWidget();
        case 'generic':
          return _buildGenericWidget();
        case 'oa_template':
          return _buildOaTemplateWidget();
        case 'zp_list':
          return _buildZpListWidget(
              messageWidth: MediaQuery.sizeOf(context).width * 0.4);
        case 'link':
          return _buildLinkWidget(metadata ?? {});
        case 'template':
          return _buildTemplateWidget();

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
      return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (repliedMessage?.author.firstName != null && showUserNames)
              AutoSizeText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                closable
                    ? '${AppLocalizations.text(LangKey.replying)} ${repliedMessage?.author.firstName ?? ''} ${repliedMessage?.author.lastName ?? ''}'
                    : '${repliedMessage?.author.firstName ?? ''} ${repliedMessage?.author.lastName ?? ''}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            // Show preview text for all message types
            if (text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: AutoSizeText(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
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
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
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
        ),
      );
    }

    return InkWell(
      onTap: () {
        // Tap tin được trả lời -> để màn chat xử lý (scroll tới / tải thêm / popup).
        if (repliedMessage != null && onMessageTap != null && isActive) {
          onMessageTap!(context, repliedMessage!, true);
        }
      },
      child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(10.0),
              bottom: Radius.circular(10.0),
            ),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 8, right: 4, top: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: BoxBorder.fromLTRB(
                      left: BorderSide(color: Colors.amber, width: 3),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPreview(),
                      _buildReplyInfoSection(
                        closable: _closable,
                        isCurrentUser: _isCurrentUser,
                        text: _text,
                        repliedMessage: repliedMessage,
                        showUserNames: true,
                      ),
                    ],
                  ),
                ),
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
  sticker,
  products,
  generic,
  system,
  zp_list,
  oa_template,
  oa_list
}
