import 'dart:ui';
extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) {
    final hexA = (a * 255).round().toRadixString(16).padLeft(2, '0');
    final hexR = (r * 255).round().toRadixString(16).padLeft(2, '0');
    final hexG = (g * 255).round().toRadixString(16).padLeft(2, '0');
    final hexB = (b * 255).round().toRadixString(16).padLeft(2, '0');

    return '${leadingHashSign ? '#' : ''}$hexA$hexR$hexG$hexB';
  }
}