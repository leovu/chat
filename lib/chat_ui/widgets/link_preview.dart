import 'package:flutter/material.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class PreviewLink extends StatefulWidget {
  final String content;
  // showText: hiển thị dòng link bên trong preview. showBackground: nền xám + padding.
  final bool showText;
  final bool showBackground;
  // compact: thu nhỏ (giới hạn chiều cao ảnh + font nhỏ) cho review trong tin nhắn.
  final bool compact;
  const PreviewLink({
    Key? key,
    required this.content,
    this.showText = true,
    this.showBackground = true,
    this.compact = false,
  }) : super(key: key);
  @override
  _PreviewLinkState createState() => _PreviewLinkState();
}

class _PreviewLinkState extends State<PreviewLink>
    with AutomaticKeepAliveClientMixin {
  // Cache theo URL để giữ preview qua các lần rebuild (vd: khi gửi tin mới),
  // tránh mất review khi State bị tạo lại.
  static final Map<String, types.PreviewData> _cache = {};
  types.PreviewData? previewData;

  @override
  void initState() {
    super.initState();
    previewData = _cache[widget.content];
  }

  @override
  void didUpdateWidget(covariant PreviewLink oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content != widget.content) {
      previewData = _cache[widget.content];
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final preview = LinkPreview(
      enableAnimation: true,
      header: null,
      onPreviewDataFetched: _onPreviewDataFetched,
      previewData: previewData,
      text: widget.content,
      width: MediaQuery.of(context).size.width,
      textWidget: widget.showText ? null : const SizedBox.shrink(),
      padding: widget.showBackground ? null : EdgeInsets.zero,
      metadataTitleStyle: widget.compact
          ? const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)
          : null,
      metadataTextStyle: widget.compact ? const TextStyle(fontSize: 11) : null,
      imageBuilder: widget.compact
          ? (url) => ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              )
          : null,
    );
    if (!widget.showBackground) {
      return preview;
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
        ),
        child: preview,
      ),
    );
  }

  void _onPreviewDataFetched(types.PreviewData data) {
    _cache[widget.content] = data;
    if (mounted && previewData == null) {
      setState(() {
        previewData = data;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;
}
