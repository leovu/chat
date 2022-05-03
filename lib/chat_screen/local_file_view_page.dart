import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_view/flutter_file_view.dart';

class LocalFileViewerPage extends StatefulWidget {
  final String filePath;
  final String title;

  const LocalFileViewerPage({
    Key? key,
    required this.filePath,
    required this.title,
  }) : super(key: key);

  @override
  _LocalFileViewerPageState createState() => _LocalFileViewerPageState();
}

class _LocalFileViewerPageState extends State<LocalFileViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.title,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: InkWell(
          child: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
              color: Colors.black),
          onTap: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SafeArea(child: LocalFileViewer(filePath: widget.filePath)),
    );
  }
}