import 'package:chat/common/theme.dart';
import 'package:chat/common/widges/widget.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GenericTemplateWidget extends StatelessWidget {
  final double width;
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final List<Map<dynamic, dynamic>> buttons;

  const GenericTemplateWidget({
    Key? key,
    required this.width,
    this.imageUrl,
    required this.title,
    this.subtitle,
    required this.buttons,
  }) : super(key: key);

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    try {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: width * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage)
              InkWell(
                onTap: () => _openUrl(imageUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.grey[100],
                      child: const Icon(
                        Icons.broken_image,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 8,
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(subtitle!),
                ],
                const SizedBox(height: 12),
                ...buttons.map((button) {
                  final btnTitle = (button['title'] ?? 'Button').toString();
                  final btnUrl = button['url']?.toString();

                  return SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      onTap: () => _openUrl(btnUrl),
                      child: CustomButton(
                        backgroundColor: AppColors.blueColor,
                        text: btnTitle,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GenericElementCardReply extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final bool closable;
  final double width;

  const GenericElementCardReply({
    Key? key,
    this.imageUrl,
    required this.title,
    this.subtitle,
    this.closable = false,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: closable
          ? Row(
              children: [
                if (hasImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 40,
                        height: 40,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            )
          : SizedBox(
              width: width * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasImage)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl!,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: double.infinity,
                          height: 150,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.broken_image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(subtitle!),
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