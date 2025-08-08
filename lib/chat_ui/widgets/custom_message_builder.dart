import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart'; 

Widget customMessageBuilder(types.CustomMessage message, {required int messageWidth}) {
  final customType = message.metadata?['custom_type'] as String?;

  switch (customType) {
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
      style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 12),
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
              final imageUrl = (product['image_urls'] as List<dynamic>?)?.first as String?;

              return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                      leading: imageUrl != null 
                          ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover) 
                          : const SizedBox(width: 50, height: 50, child: Icon(Icons.shopping_bag)),
                      title: Text(product['name'] ?? 'Sản phẩm'),
                      subtitle: Text(product['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: Text(product['price'] ?? 'Liên hệ'),
                      onTap: () { /* TODO: Xử lý sự kiện nhấn vào sản phẩm */ },
                  ),
              );
          }).toList(),
      ),
    );
}

/// WIDGET CON: Hiển thị Mẫu chung (Facebook Generic Template)
Widget buildGenericTemplateWidget(types.CustomMessage message, int messageWidth) {
  final elements = message.metadata?['elements'] as List<dynamic>? ?? [];
  if (elements.isEmpty) return const SizedBox.shrink();
  
  final element = elements.first as Map<String, dynamic>;
  final buttons = element['buttons'] as List<dynamic>? ?? [];

  return Card(
    clipBehavior: Clip.antiAlias,
    margin: const EdgeInsets.all(4),
    child: Container(
      width: messageWidth.toDouble() * 0.8, // Cho card nhỏ hơn một chút
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (element['image_url'] != null) 
            Image.network(element['image_url'], width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(element['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (element['subtitle'] != null) ...[
                  const SizedBox(height: 4),
                  Text(element['subtitle']),
                ],
                const SizedBox(height: 8),
                ...buttons.map((buttonData) {
                    final button = buttonData as Map<String, dynamic>;
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 4),
                      child: ElevatedButton(
                          onPressed: () { print('Button Payload: ${button['payload']}'); },
                          child: Text(button['title'] ?? 'Button'),
                      ),
                    );
                }).toList(),
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

  return Card(
    margin: const EdgeInsets.all(4),
    child: InkWell(
      onTap: url == null ? null : () async {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        width: messageWidth.toDouble() * 0.8,
        child: ListTile(
          leading: payload['thumbnail'] != null 
            ? Image.network(payload['thumbnail'], width: 50, height: 50, fit: BoxFit.cover)
            : null,
          title: Text(payload['title'] ?? 'Xem chi tiết'),
          subtitle: Text(payload['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      ),
    ),
  );
}


/// WIDGET CON: Hiển thị HTML
Widget buildHtmlTemplateWidget(types.CustomMessage message) {
    final html = message.metadata?['html'] as String?;
    if (html == null || html.isEmpty) return const SizedBox.shrink();
    
    // Yêu cầu package: flutter_widget_from_html
    return HtmlWidget(html);
}