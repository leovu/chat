import 'dart:convert';
import 'package:chat/chat_ui/widgets/custom_message_file.dart';
import 'package:chat/chat_ui/widgets/custom_message_generic.dart';
import 'package:chat/chat_ui/widgets/custom_message_oa_list.dart';
import 'package:chat/chat_ui/widgets/custom_message_template_card.dart';
import 'package:chat/chat_ui/widgets/custom_message_template_video.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:chat/presentation/utils/parse_html.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:url_launcher/url_launcher.dart';

Widget customMessageBuilder(types.CustomMessage message,
    {required int messageWidth}) {
  final customType = message.metadata?['custom_type'] as String?;

  switch (customType) {
    case 'image_url':
      return buildImageUrlWidget(message, messageWidth);

    case 'sticker':
      return buildStickerWidget(message);

    case 'system':
      return buildSystemMessageWidget(message);

    case 'products':
      return buildProductWidget(message, messageWidth);

    case 'generic':
      return buildGenericTemplateWidget(message, messageWidth);

    case 'oa_list':
      return buildOaListWidget(message, messageWidth);

    case 'oa_template':
      return buildHtmlTemplateWidget(message);

    case 'zp_list':
      return buildZpListWidget(message, messageWidth);

    case 'link':
      return buildLinkWidget(message, messageWidth);

    case 'template':
      return buildTemplateWidget(message, messageWidth);

    case 'video':
      return buildCustomMessageWidget(message, messageWidth);

    default:
      return const SizedBox.shrink();
  }
}

/// WIDGET CON: Hiển thị Sticker
Widget buildStickerWidget(types.CustomMessage message) {
  final url = message.metadata?['url'] as String?;
  if (url == null || url.isEmpty) return const SizedBox.shrink();

  return Container(
    constraints: const BoxConstraints(maxWidth: 130, maxHeight: 130),
    child: Image.network(url, fit: BoxFit.contain),
  );
}

/// WIDGET CON: Hiển thị Tin nhắn hệ thống
Widget buildSystemMessageWidget(types.CustomMessage message) {
  final text = message.metadata?['text'] as String?;
  if (text == null || text.isEmpty) return const SizedBox.shrink();

  return Container(
    alignment: Alignment.center,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: Text(
      text,
      style: const TextStyle(
          color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 12),
      textAlign: TextAlign.center,
    ),
  );
}

/// WIDGET CON: Hiển thị danh sách Sản phẩm
Widget buildProductWidget(types.CustomMessage message, int messageWidth) {
  final items = message.metadata?['items'] as List<dynamic>? ?? [];
  if (items.isEmpty) return const SizedBox.shrink();

  return Container(
    width: messageWidth.toDouble(),
    child: Column(
      children: items.map((item) {
        final Map<String, dynamic> product = item as Map<String, dynamic>;
        final imageUrl =
            (product['image_urls'] as List<dynamic>?)?.first as String?;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: imageUrl != null
                ? Image.network(imageUrl,
                    width: 50, height: 50, fit: BoxFit.cover)
                : const SizedBox(
                    width: 50, height: 50, child: Icon(Icons.shopping_bag)),
            title: Text(product['name'] ?? ''),
            subtitle: Text(product['description'] ?? '',
                maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Text(product['price'] ?? ''),
            onTap: () {/* TODO: Xử lý sự kiện nhấn vào sản phẩm */},
          ),
        );
      }).toList(),
    ),
  );
}

/// WIDGET CON: Hiển thị template generic
Widget buildGenericTemplateWidget(
    types.CustomMessage message, int messageWidth) {
  final rawElements = message.metadata?['elements'];
  final elements =
      (rawElements is List) ? rawElements.whereType<Map>().toList() : <Map>[];
  if (elements.isEmpty) return const SizedBox.shrink();

  final element = elements.first;
  final rawButtons = element['buttons'];
  final buttons =
      (rawButtons is List) ? rawButtons.whereType<Map>().toList() : <Map>[];

  final imageUrl = element['image_url'] as String?;
  final title = (element['title'] ?? '').toString();
  final subtitle = (element['subtitle'] ?? '').toString();

  return GenericTemplateWidget(
    width: messageWidth.toDouble(),
    imageUrl: imageUrl,
    title: title,
    subtitle: subtitle,
    buttons: buttons,
  );
}

/// WIDGET CON: Hiển thị Link Zalo OA
Widget buildOaListWidget(types.CustomMessage message, int messageWidth) {
  final payload = message.metadata?['data'] as Map<String, dynamic>?;
  if (payload == null) return const SizedBox.shrink();

  final title = payload['title'] ?? LangKey.view_detail;
  final description = payload['description'] ?? '';
  final imgUrl = payload['thumbnail'] as String?;
  final linkUrl = payload['url'] as String?;

  return OaListCard(
    width: messageWidth.toDouble(),
    title: title,
    description: description,
    imageUrl: imgUrl,
    linkUrl: linkUrl,
  );
}

/// WIDGET CON: Hiển thị file
Widget buildFileWidget(types.FileMessage fileMessage,
    {required int messageWidth}) {
  return FileMessageCard(
    fileName: fileMessage.name,
    fileSize: int.tryParse(fileMessage.size.toString()) ?? 1,
    fileUrl: fileMessage.uri,
    width: messageWidth.toDouble(),
  );
}

/// WIDGET CON: Hiển thị zalo persional
Widget buildZpListWidget(types.CustomMessage message, int messageWidth) {
  final metadata = message.metadata ?? {};
  List<dynamic> items = [];

  try {
    final rawItems = metadata['zp_list_items'];
    if (rawItems is String && rawItems.isNotEmpty) {
      items = jsonDecode(rawItems) as List<dynamic>;
    } else if (rawItems is List) {
      items = rawItems;
    }
  } catch (e) {
    // Nếu parse lỗi thì để trống
    items = [];
  }

  if (items.isEmpty) {
    return const SizedBox();
  }

  final firstItem = items.first;
  final title = firstItem['title'] ?? '';
  final description = firstItem['description'] ?? '';
  final href = firstItem['href'] ?? '';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  return InkWell(
    onTap: () => _openUrl(href),
    child: Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(description),
        ],
      ),
    ),
  );
}

/// WIDGET CON: Hiển thị hình ảnh
Widget buildImageUrlWidget(types.CustomMessage message, int messageWidth) {
  final imageUrl = message.metadata?['content'] as String? ??
      message.metadata?['url'] as String? ??
      '';

  if (imageUrl.isEmpty) return const SizedBox.shrink();

  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image.network(
      imageUrl,
      width: messageWidth.toDouble() * 0.7,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: messageWidth.toDouble() * 0.7,
        height: 100,
        child: const Icon(Icons.broken_image, size: 100, color: Colors.grey),
      ),
    ),
  );
}

/// WIDGET CON: Hiển thị link
Widget buildLinkWidget(types.CustomMessage message, int messageWidth) {
  final text = message.metadata?['text'] as String? ?? '';
  if (text.isEmpty) return const SizedBox.shrink();

  final links = extractAllUrls(text);
  final spans = <TextSpan>[];

  if (links.isEmpty) {
    spans.add(TextSpan(text: text));
  } else {
    int lastIndex = 0;
    for (final match in links) {
      final start = match.start;
      final end = match.end;
      if (start > lastIndex) {
        spans.add(TextSpan(text: text.substring(lastIndex, start)));
      }
      final linkText = text.substring(start, end);
      spans.add(
        TextSpan(
          text: linkText,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              var url = linkText;
              if (!url.startsWith('http')) url = 'https://$url';
              final uri = Uri.tryParse(url);
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
        ),
      );
      lastIndex = end;
    }
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }
  }

  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 15),
        children: spans,
      ),
    ),
  );
}

/// WIDGET CON: Hiển thị template html css
Widget buildTemplateWidget(types.CustomMessage message, int messageWidth) {
  final metadata = message.metadata;
  final title = metadata?['template_title'] as String? ?? 'Template';
  final description = metadata?['template_description'] as String? ?? '';
  final imageUrl = metadata?['template_image'] as String?;
  final url = metadata?['template_url'] as String?;
  return TemplateCard(
    title: title,
    description: description,
    imageUrl: imageUrl,
    linkUrl: url,
  );
}

/// WIDGET CON: Hiển thị video
Widget buildCustomMessageWidget(types.CustomMessage message, int messageWidth) {
  final metadata = message.metadata ?? {};

  final title = metadata['title'] ?? '';
  final description = metadata['description'] ?? '';
  final thumbUrl = metadata['thumb'] ?? '';
  final videoUrl = metadata['href'] ?? '';

  return VideoMessageWidget(
    title: title,
    // description: description,
    thumbUrl: thumbUrl,
    videoUrl: videoUrl,
    // messageWidth: double.tryParse(messageWidth.toString()),
  );
}

List<RegExpMatch> extractAllUrls(String text) {
  final urlPattern = RegExp(
    r'((?:https?|ftp):\/\/[a-zA-Z0-9\-_~%+.:@#?&//=]+)',
    caseSensitive: false,
  );

  return urlPattern.allMatches(text).toList();
}
