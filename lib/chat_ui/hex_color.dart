import 'dart:ui';

extension HexColor on Color {
  static Color fromHex(String? hexString) {
    if (hexString == null || hexString.trim().isEmpty || hexString == 'null') {
      hexString = '#000000'; 
    }

    hexString = hexString.trim().replaceFirst('#', '').toUpperCase();

    final buffer = StringBuffer();
    if (hexString.length == 6) {
      buffer.write('FF'); 
    } else if (hexString.length == 8) {
    } else {
      // print('⚠️ Hex string invalid length: $hexString');
      return const Color(0xFFFFFFFF);
    }

    buffer.write(hexString);

    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      // print('❌ Error parsing color: $e');
      return const Color(0xFFFFFFFF); 
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
