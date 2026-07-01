import 'package:flutter/material.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class PreviewLink extends StatefulWidget {
  final String content;
  final bool transparentBackground;
  const PreviewLink(
      {Key? key, required this.content, this.transparentBackground = false})
      : super(key: key);
  @override
  _PreviewLinkState createState() => _PreviewLinkState();
}

class _PreviewLinkState extends State<PreviewLink>
    with AutomaticKeepAliveClientMixin {
  types.PreviewData? previewData;
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
          header: null,
          onPreviewDataFetched: _onPreviewDataFetched,
          previewData: previewData,
          text: widget.content,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }

  void _onPreviewDataFetched(types.PreviewData data) {
    if (previewData == null) {
      setState(() {
        previewData = data;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;
}
