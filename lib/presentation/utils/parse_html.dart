import 'dart:convert';

import 'package:chat/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;

import '../../localization/lang_key.dart';

Widget buildHtmlTemplateWidget(types.CustomMessage message) {
  final html = message.metadata?['html'] as String?;
  if (html == null || html.isEmpty) {
    return const SizedBox.shrink();
  }

  final templateData = _parseOaTemplateHtml(html);
  if (templateData == null) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        '[${AppLocalizations.text(LangKey.content_not_displayed)}]',
        style:
            TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.all(4.0),
    child: _buildBeautifulOaTemplateWidget(templateData),
  );
}

Map<String, dynamic>? _parseOaTemplateHtml(String htmlString) {
  try {
    final dom.Document document = parser.parse(htmlString);

    final String bannerUrl =
        document.querySelector('.oam_banner_img')?.attributes['src'] ?? '';

    final String tag =
        document.querySelector('.oam_banner_btn_text')?.text.trim() ??
            'THÔNG BÁO';
    final tagIconElement = document.querySelector('.oam_banner_btn_icon');
    String tagIconUrl = '';
    if (tagIconElement != null) {
      final style = tagIconElement.attributes['style'];
      final regex = RegExp(r'url\((.*?)\)');
      final match = regex.firstMatch(style ?? '');
      if (match != null && match.groupCount > 0) {
        tagIconUrl = match.group(1)!;
      }
    }

    final String title = document
            .querySelector('.oam_banner_title_2, .oam_banner_title_1')
            ?.text
            .trim() ??
        'Tiêu đề';

    final List<Map<String, String>> details = [];
    final detailRows = document.querySelectorAll('.oam_map_info_row_wrapper');
    for (var row in detailRows) {
      final key =
          row.querySelector('[class*="oam_map_info_key_title"]')?.text.trim();
      final value =
          row.querySelector('[class*="oam_map_info_value_title"]')?.text.trim();
      if (key != null && value != null && key.isNotEmpty) {
        details.add({'key': key, 'value': value});
      }
    }

    final String description = document
            .querySelector('.oam_banner_title_4, .oam_banner_title_3')
            ?.text
            .trim() ??
        '';

    final buttonText =
        document.querySelector('.oam_button_primary')?.text.trim() ?? '';
    final buttonIcon = document
            .querySelector('.oam_button_secondary_icon')
            ?.attributes['src'] ??
        '';
    final buttonArrowIcon = document
            .querySelector('.oam_button_secondary_icon_arrow')
            ?.attributes['src'] ??
        '';

    final buttonElement = document.querySelector('.oam_button_primary_wrapper');
    final String buttonAction =
        buttonElement?.attributes['data-click-action'] ?? '';
    final String buttonActionData =
        buttonElement?.attributes['data-click-data'] ?? '';
    return {
      "banner_url": bannerUrl,
      "tag": tag,
      "tag_icon": tagIconUrl,
      "title": title,
      "details": details,
      "description": description,
      "button": {
        "text": buttonText,
        "icon": buttonIcon,
        "arrow_icon": buttonArrowIcon,
        "action": buttonAction,
        "action_data": buttonActionData,
      }
    };
  } catch (e) {
    print('Lỗi khi parse HTML: $e');
    return null;
  }
}

Widget _buildBeautifulOaTemplateWidget(Map<String, dynamic> templateData) {
  return Container(
    constraints: const BoxConstraints(maxWidth: 320),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (templateData['banner_url'] != null &&
              templateData['banner_url'].isNotEmpty)
            Image.network(
              templateData['banner_url'],
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTag(templateData['tag'], templateData['tag_icon']),
                const SizedBox(height: 12),
                Text(
                  templateData['title'],
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 12),
                ..._buildDetails(templateData['details']),
                if (templateData['description'] != null &&
                    templateData['description'].isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      templateData['description'],
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.4),
                    ),
                  ),
              ],
            ),
          ),
          if (templateData['button'] != null &&
              templateData['button']['text'].isNotEmpty)
            _buildButton(templateData['button']),
        ],
      ),
    ),
  );
}

Widget _buildTag(String text, String iconUrl) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: Colors.grey.shade300, width: 0.5),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (iconUrl.isNotEmpty) ...[
          Image.network(iconUrl,
              width: 13,
              height: 13,
              errorBuilder: (c, e, s) => const Icon(Icons.label, size: 13)),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
      ],
    ),
  );
}

List<Widget> _buildDetails(List<dynamic> details) {
  if (details.isEmpty) return [const SizedBox.shrink()];

  return (details as List<Map<String, String>>).map((detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              detail['key']!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              detail['value']!,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }).toList();
}

Widget _buildButton(Map<String, dynamic> buttonData) {
  final String action = buttonData['action'] ?? '';
  final String actionData = buttonData['action_data'] ?? '';

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {
        print('Button "${buttonData['text']}" clicked!');

        final String action = buttonData['action'] ?? '';
        final String actionData = buttonData['action_data'] ?? '';

        if (action.isNotEmpty) {
          if (action == 'action.request.multiaction') {
            try {
              final Map<String, dynamic> decodedData = jsonDecode(actionData);
              final List<dynamic>? actionList = decodedData['actionLists'];

              if (actionList != null) {
                for (var subActionMap in actionList) {
                  final String subActionType = subActionMap['action'] ?? '';
                  final dynamic subActionData = subActionMap['data'];

                  print('Executing sub-action: $subActionType');
                  switch (subActionType) {
                    case 'action.query.show':
                      break;

                    case 'action.query.hide.v2':
                      break;

                    default:
                      print('Unknown sub-action type: $subActionType');
                  }
                }
              }
            } catch (e) {}
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        ),
        child: Row(
          children: [
            if (buttonData['icon'] != null &&
                buttonData['icon'].isNotEmpty) ...[
              Image.network(buttonData['icon']!, width: 24, height: 24),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                buttonData['text']!,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500),
              ),
            ),
            if (buttonData['arrow_icon'] != null &&
                buttonData['arrow_icon'].isNotEmpty)
              Image.network(buttonData['arrow_icon']!, width: 24, height: 24),
          ],
        ),
      ),
    ),
  );
}
