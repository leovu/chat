import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FileMessageCard extends StatelessWidget {
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final double? width;

  const FileMessageCard({
    Key? key,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.width,
  }) : super(key: key);

  String get fileSizeText => '${(fileSize ?? 0 / 1024).toStringAsFixed(2)} KB';

  Future<void> _launchUrl() async {
    try {
      final uri = Uri.tryParse(fileUrl ?? '');
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          children: [
            const Icon(
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
                    fileName ?? 'UNKNOW',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text(
                    fileSizeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: _launchUrl,
            ),
          ],
        ),
      ),
    );
  }
}
