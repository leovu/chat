import 'package:flutter/material.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:url_launcher/url_launcher.dart';

Future<void> openLinkSafely(String url) async {
  var uri = Uri.tryParse(url);
  if (uri == null || uri.scheme.isEmpty) {
    uri = Uri.tryParse('https://$url');
  }
  if (uri == null) return;
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

String normalizeLinkScheme(String text) {
  final urlRegexp =
      RegExp(r'(?:https?://)?\S+\.\S+\.\S+', caseSensitive: false);
  return text.replaceAllMapped(urlRegexp, (m) {
    final match = m[0]!;
    return match.startsWith('http://') || match.startsWith('https://')
        ? match
        : 'https://$match';
  });
}

class PreviewLink extends StatefulWidget {
  final String content;
  final bool transparentBackground;
  final types.PreviewData? previewData;
  final void Function(types.PreviewData)? onPreviewDataFetched;
  final String? header;
  final TextStyle? headerStyle;
  final TextStyle? linkStyle;
  final TextStyle? textStyle;
  final TextStyle? titleStyle;
  final TextStyle? descriptionStyle;
  final Widget? textWidget;

  const PreviewLink({
    Key? key,
    required this.content,
    this.transparentBackground = false,
    this.previewData,
    this.onPreviewDataFetched,
    this.header,
    this.headerStyle,
    this.linkStyle,
    this.textStyle,
    this.titleStyle,
    this.descriptionStyle,
    this.textWidget,
  }) : super(key: key);

  @override
  _PreviewLinkState createState() => _PreviewLinkState();
}

class _PreviewLinkState extends State<PreviewLink>
    with AutomaticKeepAliveClientMixin {
  types.PreviewData? _cachedPreviewData;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
            color: widget.transparentBackground
                ? Colors.transparent
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(15)),
        child: LinkPreview(
          enableAnimation: true,
          header: widget.header,
          headerStyle: widget.headerStyle,
          onLinkPressed: openLinkSafely,
          onPreviewDataFetched: _onPreviewDataFetched,
          previewData: widget.previewData ?? _cachedPreviewData,
          text: normalizeLinkScheme(widget.content),
          textWidget: widget.textWidget,
          linkStyle: widget.linkStyle,
          textStyle: widget.textStyle ?? const TextStyle(fontSize: 16),
          metadataTitleStyle: widget.titleStyle ??
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          metadataTextStyle:
              widget.descriptionStyle ?? const TextStyle(fontSize: 15),
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }

  void _onPreviewDataFetched(types.PreviewData data) {
    widget.onPreviewDataFetched?.call(data);
    if (_cachedPreviewData == null) {
      setState(() {
        _cachedPreviewData = data;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;
}
