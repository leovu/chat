import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/download.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

enum _Tool { pen, rect }

class _Stroke {
  final _Tool tool;
  final Color color;
  final double strokeWidth;
  final List<Offset> points;
  Rect? rect;

  _Stroke({
    required this.tool,
    required this.color,
    required this.strokeWidth,
    List<Offset>? points,
    this.rect,
  }) : points = points ?? [];
}

class ImageAnnotationScreen extends StatefulWidget {
  /// Network url hoặc đường dẫn file local.
  final String imageUrl;

  /// Gửi lại ảnh đã chỉnh vào cuộc trò chuyện. Null => ẩn nút Resend.
  final Future<void> Function(File editedImage)? onResend;

  const ImageAnnotationScreen({
    Key? key,
    required this.imageUrl,
    this.onResend,
  }) : super(key: key);

  @override
  State<ImageAnnotationScreen> createState() => _ImageAnnotationScreenState();
}

class _ImageAnnotationScreenState extends State<ImageAnnotationScreen> {
  final GlobalKey _repaintKey = GlobalKey();

  static const List<Color> _colors = [
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.black,
    Colors.white,
  ];

  final List<_Stroke> _strokes = [];
  _Stroke? _active;

  _Tool _tool = _Tool.pen;
  Color _color = Colors.red;
  final double _strokeWidth = 4.0;

  ImageProvider? _provider;
  double? _aspectRatio;
  bool _loadError = false;
  bool _exporting = false;

  bool get _isNetwork =>
      widget.imageUrl.startsWith('http://') ||
      widget.imageUrl.startsWith('https://');

  @override
  void initState() {
    super.initState();
    _provider = _isNetwork
        ? NetworkImage(widget.imageUrl,
                headers: {'brand-code': ChatConnection.brandCode ?? ''})
            as ImageProvider
        : FileImage(File(widget.imageUrl));
    _resolveImageSize();
  }

  void _resolveImageSize() {
    final stream = _provider!.resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener((ImageInfo info, bool _) {
      if (!mounted) return;
      setState(() {
        _aspectRatio = info.image.width / info.image.height;
      });
      stream.removeListener(listener);
    }, onError: (Object e, StackTrace? s) {
      if (!mounted) return;
      setState(() {
        _loadError = true;
      });
      stream.removeListener(listener);
    });
    stream.addListener(listener);
  }

  void _onPanStart(DragStartDetails d) {
    final pos = d.localPosition;
    final stroke = _Stroke(
      tool: _tool,
      color: _color,
      strokeWidth: _strokeWidth,
      points: _tool == _Tool.pen ? [pos] : null,
      rect: _tool == _Tool.rect ? Rect.fromPoints(pos, pos) : null,
    );
    setState(() {
      _strokes.add(stroke);
      _active = stroke;
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_active == null) return;
    final pos = d.localPosition;
    setState(() {
      if (_active!.tool == _Tool.pen) {
        _active!.points.add(pos);
      } else {
        final start = _active!.points.isNotEmpty
            ? _active!.points.first
            : _active!.rect?.topLeft ?? pos;
        _active!.rect = Rect.fromPoints(start, pos);
      }
    });
  }

  void _onPanStartRect(DragStartDetails d) {
    final pos = d.localPosition;
    final stroke = _Stroke(
      tool: _Tool.rect,
      color: _color,
      strokeWidth: _strokeWidth,
      points: [pos],
      rect: Rect.fromPoints(pos, pos),
    );
    setState(() {
      _strokes.add(stroke);
      _active = stroke;
    });
  }

  void _onPanEnd(DragEndDetails d) {
    _active = null;
  }

  void _undo() {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes.removeLast();
    });
  }

  void _clear() {
    if (_strokes.isEmpty) return;
    setState(() {
      _strokes.clear();
    });
  }

  Future<File?> _captureToFile() async {
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      // Xuất ở độ phân giải gần với ảnh gốc.
      double pixelRatio = 3.0;
      if (_aspectRatio != null && boundary.size.width > 0) {
        // Giữ trong khoảng hợp lý để tránh tràn bộ nhớ.
        pixelRatio =
            (MediaQuery.of(context).devicePixelRatio * 2).clamp(2.0, 5.0);
      }
      final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;
      final Uint8List bytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(path);
      await file.writeAsBytes(bytes);
      return file;
    } catch (_) {
      return null;
    }
  }

  /// Đóng màn chỉnh sửa + màn xem ảnh, trở về màn trước đó (chat).
  void _closeEditorAndViewer() {
    final navigator = Navigator.of(context);
    navigator.pop(); // đóng màn chỉnh sửa
    if (navigator.canPop()) {
      navigator.pop(); // đóng màn hiển thị hình ảnh (PhotoScreen)
    }
  }

  Future<void> _download() async {
    setState(() => _exporting = true);
    final file = await _captureToFile();
    if (!mounted) return;
    setState(() => _exporting = false);
    if (file == null) {
      _showSnack(AppLocalizations.text(LangKey.downloadFailed));
      return;
    }
    saveGallery(file.path, file.path.split('/').last);
    _closeEditorAndViewer();
  }

  Future<void> _resend() async {
    if (widget.onResend == null) return;
    setState(() => _exporting = true);
    final file = await _captureToFile();
    if (file == null) {
      if (mounted) setState(() => _exporting = false);
      _showSnack(AppLocalizations.text(LangKey.downloadFailed));
      return;
    }
    await widget.onResend!(file);
    if (!mounted) return;
    setState(() => _exporting = false);
    _closeEditorAndViewer();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const CloseButton(color: Colors.white),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          AppLocalizations.text(LangKey.edit),
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: Colors.white),
            onPressed: _undo,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: _clear,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: Center(child: _buildCanvas())),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    if (_loadError) {
      return const Icon(Icons.broken_image_outlined,
          color: Colors.white54, size: 64);
    }
    if (_aspectRatio == null || _provider == null) {
      return const CircularProgressIndicator();
    }
    return AspectRatio(
      aspectRatio: _aspectRatio!,
      child: RepaintBoundary(
        key: _repaintKey,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image(image: _provider!, fit: BoxFit.fill),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanStart: _tool == _Tool.pen ? _onPanStart : _onPanStartRect,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              child: CustomPaint(
                painter: _AnnotationPainter(_strokes),
                size: Size.infinite,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return SafeArea(
      top: false,
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _toolButton(Icons.edit, _Tool.pen),
                const SizedBox(width: 8),
                _toolButton(Icons.crop_square, _Tool.rect),
                const SizedBox(width: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _colors.map(_colorDot).toList(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _exporting ? null : _download,
                    icon: const Icon(Icons.download_rounded,
                        color: Colors.white),
                    label: Text(
                      AppLocalizations.text(LangKey.download),
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (widget.onResend != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _exporting ? null : _resend,
                      icon: _exporting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      label: Text(
                        AppLocalizations.text(LangKey.resend),
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolButton(IconData icon, _Tool tool) {
    final selected = _tool == tool;
    return InkWell(
      onTap: () => setState(() => _tool = tool),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: selected ? Colors.white : Colors.white38, width: 1),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }

  Widget _colorDot(Color color) {
    final selected = _color == color;
    return GestureDetector(
      onTap: () => setState(() => _color = color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.white : Colors.white24,
            width: selected ? 3 : 1,
          ),
        ),
      ),
    );
  }
}

class _AnnotationPainter extends CustomPainter {
  final List<_Stroke> strokes;

  _AnnotationPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (stroke.tool == _Tool.pen) {
        if (stroke.points.length == 1) {
          canvas.drawPoints(ui.PointMode.points, stroke.points, paint);
        } else if (stroke.points.length > 1) {
          final path = Path()
            ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
          for (var i = 1; i < stroke.points.length; i++) {
            path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
          }
          canvas.drawPath(path, paint);
        }
      } else if (stroke.rect != null) {
        canvas.drawRect(stroke.rect!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AnnotationPainter oldDelegate) => true;
}
