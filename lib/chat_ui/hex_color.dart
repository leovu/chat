// import 'dart:ui';
// extension HexColor on Color {
//   /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
//   static Color fromHex(String hexString) {
//     final buffer = StringBuffer();
//     if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
//     buffer.write(hexString.replaceFirst('#', ''));
//     return Color(int.parse(buffer.toString(), radix: 16));
//   }
//
//   /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
//   String toHex({bool leadingHashSign = true}) {
//     final hexA = (a * 255).round().toRadixString(16).padLeft(2, '0');
//     final hexR = (r * 255).round().toRadixString(16).padLeft(2, '0');
//     final hexG = (g * 255).round().toRadixString(16).padLeft(2, '0');
//     final hexB = (b * 255).round().toRadixString(16).padLeft(2, '0');
//
//     return '${leadingHashSign ? '#' : ''}$hexA$hexR$hexG$hexB';
//   }
// }
import 'dart:ui';

extension HexColor on Color {
  static Color fromHex(String? hexString) {
    if (hexString == null || hexString.trim().isEmpty || hexString == 'null') {
      hexString = '#000000'; // fallback màu đen nếu không hợp lệ
    }

    hexString = hexString.trim().replaceFirst('#', '').toUpperCase();

    final buffer = StringBuffer();
    if (hexString.length == 6) {
      buffer.write('FF'); // Thêm alpha nếu không có
    } else if (hexString.length == 8) {
    } else {
      print('⚠️ Hex string invalid length: $hexString');
      return const Color(0xFFFFFFFF); // fallback
    }

    buffer.write(hexString);

    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      print('❌ Error parsing color: $e');
      return const Color(0xFFFFFFFF); // fallback
    }
  }

  String toHex({bool leadingHashSign = true}) {
    final hexA = (a * 255).round().toRadixString(16).padLeft(2, '0');
    final hexR = (r * 255).round().toRadixString(16).padLeft(2, '0');
    final hexG = (g * 255).round().toRadixString(16).padLeft(2, '0');
    final hexB = (b * 255).round().toRadixString(16).padLeft(2, '0');

    return '${leadingHashSign ? '#' : ''}$hexA$hexR$hexG$hexB';
  }
}
