import 'package:flutter/material.dart';

/// NGUỒN DUY NHẤT (đồng bộ) cho màu + chữ viết tắt của MỌI avatar trong app.
/// Mỗi id -> 1 cặp (nền pastel, chữ đậm) cố định qua cùng 1 hàm hash.
///
/// Dùng:
///  - Nền avatar:  [getAvatarColor](id)
///  - Màu chữ:     [getAvatarTextColor](id)  (cũng dùng cho tên hiển thị)
///  - Chữ viết tắt:[getAvatarInitials](firstName, lastName)

/// Bảng màu avatar: [nền pastel, chữ đậm].
const List<List<Color>> avatarPalette = [
  [Color(0xFFE3F2FD), Color(0xFF1565C0)],
  [Color(0xFFE1F5FE), Color(0xFF0277BD)],
  [Color(0xFFE0F7FA), Color(0xFF00838F)],
  [Color(0xFFE0F2F1), Color(0xFF00695C)],
  [Color(0xFFE8F5E9), Color(0xFF2E7D32)],
  [Color(0xFFF1F8E9), Color(0xFF558B2F)],
  [Color(0xFFF9FBE7), Color(0xFF827717)],
  [Color(0xFFFFFDE7), Color(0xFFF9A825)],
  [Color(0xFFFFF8E1), Color(0xFFFF8F00)],
  [Color(0xFFFFF3E0), Color(0xFFEF6C00)],
  [Color(0xFFFBE9E7), Color(0xFFD84315)],
  [Color(0xFFFFEBEE), Color(0xFFC62828)],
  [Color(0xFFFCE4EC), Color(0xFFAD1457)],
  [Color(0xFFF3E5F5), Color(0xFF6A1B9A)],
  [Color(0xFFEDE7F6), Color(0xFF4527A0)],
  [Color(0xFFE8EAF6), Color(0xFF3949AB)],
  [Color(0xFFEFEBE9), Color(0xFF5D4037)],
  [Color(0xFFF5F5F5), Color(0xFF424242)],
  [Color(0xFFECEFF1), Color(0xFF455A64)],
  [Color(0xFFE8F0FE), Color(0xFF1A73E8)],
];

/// Chỉ nền pastel (dùng khi cần danh sách màu nền).
List<Color> get avatarColors =>
    avatarPalette.map((e) => e[0]).toList(growable: false);

/// Hash ổn định theo id -> chỉ số trong [avatarPalette] (cùng 1 hàm cho toàn app).
int avatarIndex(String? id) {
  if (id == null || id.isEmpty) return 0;
  int hash = 0;
  for (final c in id.codeUnits) {
    hash = (hash * 31 + c) & 0x7FFFFFFF;
  }
  return hash % avatarPalette.length;
}

/// Màu nền avatar (pastel).
Color getAvatarColor(String? id) => avatarPalette[avatarIndex(id)][0];

/// Màu chữ avatar / tên hiển thị (đậm, tương phản với nền pastel cùng cặp).
Color getAvatarTextColor(String? id) => avatarPalette[avatarIndex(id)][1];

/// Chữ viết tắt: ký tự đầu firstName + ký tự đầu lastName (bỏ ký tự đặc biệt).
String getAvatarInitials(String? firstName, String? lastName) {
  String pick(String? s) {
    final v = (s ?? '').replaceAll(RegExp('[^A-Za-z0-9]'), '').trim();
    return v.isEmpty ? '' : v[0];
  }

  final initials = '${pick(firstName)}${pick(lastName)}'.toUpperCase();
  return initials.isEmpty ? '?' : initials;
}
