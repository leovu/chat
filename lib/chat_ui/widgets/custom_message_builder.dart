import 'dart:convert';
import 'package:chat/common/theme.dart';
import 'package:chat/common/widges/widget.dart';
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
    // return Text('return buildZpListWidget(message, messageWidth);');

    case 'link':
      return buildLinkWidget(message, messageWidth);

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
            title: Text(product['name'] ?? 'Sản phẩm'),
            subtitle: Text(product['description'] ?? '',
                maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Text(product['price'] ?? 'Liên hệ'),
            onTap: () {/* TODO: Xử lý sự kiện nhấn vào sản phẩm */},
          ),
        );
      }).toList(),
    ),
  );
}

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

  final img = element['image_url'] as String?;
  final hasImage = (img != null && img.isNotEmpty);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
    child: SizedBox(
      width: messageWidth * 0.8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            InkWell(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12), // giá trị bo góc
                child: Image.network(
                  img,
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
                  (element['title'] ?? '').toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if ((element['subtitle'] as String?)?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Text(element['subtitle'].toString()),
                ],
                const SizedBox(height: 12),
                ...buttons.map((button) {
                  final title = (button['title'] ?? 'Button').toString();
                  // final payload = button['payload'];
                  final url = button['url'];
                  return SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      onTap: () async {
                        await launchUrl(Uri.parse(url),
                            mode: LaunchMode.externalApplication);
                      },
                      child: CustomButton(
                        backgroundColor: AppColors.blueColor,
                        text: title,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

/// WIDGET CON: Hiển thị Link Zalo OA
Widget buildOaListWidget(types.CustomMessage message, int messageWidth) {
  final payload = message.metadata?['data'] as Map<String, dynamic>?;
  if (payload == null) return const SizedBox.shrink();

  final Uri? url = Uri.tryParse(payload['url'] ?? '');
  final imgUrl = payload['thumbnail'] as String?;
  final title = payload['title'] ?? 'Xem chi tiết';
  final description = payload['description'] ?? '';

  return Padding(
    padding: const EdgeInsets.all(12),
    child: InkWell(
      onTap: url == null
          ? null
          : () async {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            },
      child: Container(
        width: messageWidth.toDouble() * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imgUrl != null && imgUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12), // Bo góc ảnh
                child: Image.network(
                  imgUrl,
                  width: double.infinity,
                  height: 150, // bạn có thể chỉnh chiều cao
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                description,
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

Widget buildFileWidget(types.FileMessage fileMessage,
    {required int messageWidth}) {
  return Padding(
    padding: const EdgeInsets.only(right: 8.0),
    child: Container(
      width: double.tryParse(messageWidth.toString()),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        children: [
          Icon(
            Icons.insert_drive_file,
            size: 30,
            color: Colors.blueAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  fileMessage.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  '${(fileMessage.size / 1024).toStringAsFixed(2)} KB',
                  style: TextStyle(
                    color: Colors.black.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () {
              print('Download file from ${fileMessage.uri}');
            },
          ),
        ],
      ),
    ),
  );
}

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
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
      // Thêm phần text trước link
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
    // Phần còn lại sau link cuối
    if (lastIndex < text.length) {
      spans.add(TextSpan(text: text.substring(lastIndex)));
    }
  }

  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
    ),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 14),
        children: spans,
      ),
    ),
  );
}

List<RegExpMatch> extractAllUrls(String text) {
  final urlPattern = RegExp(
    r'((?:https?|ftp):\/\/[a-zA-Z0-9\-_~%+.:@#?&//=]+)',
    caseSensitive: false,
  );

  return urlPattern.allMatches(text).toList();
}
