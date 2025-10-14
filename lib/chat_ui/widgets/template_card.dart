import 'package:chat/common/chat_format.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class TemplateCard extends StatefulWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final String? linkUrl;

  const TemplateCard({
    super.key,
    required this.title,
    required this.description,
    this.imageUrl,
    this.linkUrl,
  });

  @override
  State<TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<TemplateCard> {
  bool isExpanded = true;

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LangKey.reject_link),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showImagePopup(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasUrl = widget.linkUrl != null && widget.linkUrl!.isNotEmpty;
    final imageUrl = widget.imageUrl;
    return InkWell(
      onTap: hasUrl ? () => _launchUrl(widget.linkUrl!) : null,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: hasUrl ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: GestureDetector(
                  onTap: () => _showImagePopup(imageUrl),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      // height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 150,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: 8,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                widget.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 6),
            if (widget.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedCrossFade(
                      firstChild: ConstrainedBox(
                        constraints: const BoxConstraints(
                            maxHeight: 100), 
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: Html(
                            data: widget.description,
                            style: htmlTagStyles(),
                            onLinkTap: (url, attributes, element) async {
                              if (url != null && url.isNotEmpty) {
                                await _launchUrl(url);
                              }
                            },
                          ),
                        ),
                      ),
                      secondChild: Html(
                        data: widget.description,
                        style: htmlTagStyles(),
                        onLinkTap: (url, attributes, element) async {
                          if (url != null && url.isNotEmpty) {
                            await _launchUrl(url);
                          }
                        },
                      ),
                      crossFadeState: isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),
                    if (widget.description.length > 180)
                      Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () =>
                                setState(() => isExpanded = !isExpanded),
                            child: Text(
                              isExpanded ? '${LangKey.collapse} ▲' : '${LangKey.expand} ▼',
                            ),
                          )),
                  ],
                ),
              ),
            SizedBox(
              height: 8,
            )
          ],
        ),
      ),
    );
  }
}
