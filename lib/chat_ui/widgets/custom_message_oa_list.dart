import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OaListCard extends StatelessWidget {
  final double width;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? linkUrl;

  const OaListCard({
    Key? key,
    required this.width,
    required this.title,
    this.description,
    this.imageUrl,
    this.linkUrl,
  }) : super(key: key);

  Future<void> _launchUrl(String? url) async {
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
    return Padding(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: () => _launchUrl(linkUrl),
        child: Container(
          width: width * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageUrl != null && imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
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
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(description!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
