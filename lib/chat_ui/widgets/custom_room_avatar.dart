import 'package:flutter/material.dart';

class GroupAvatar extends StatelessWidget {
  final String? img1;
  final String? img2;
  final String? img3;
  final double size;

  const GroupAvatar({
    Key? key,
    this.img1,
    this.img2,
    this.img3,
    this.size = 80, // đường kính toàn bộ widget
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double avatarSize = size * 0.5; // kích thước từng avatar
    final double offset = size * 0.25; // khoảng cách tam giác

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Ảnh 1 (trên cùng)
          Positioned(
            bottom: 0,
            left: (size - avatarSize) / 2,
            child: _buildCircleAvatar(img1??'', avatarSize),
          ),

          // Ảnh 2 (góc trái dưới)
          Positioned(
            top: 0,
            left: 0,
            child: _buildCircleAvatar(img2??'', avatarSize),
          ),

          // Ảnh 3 (góc phải dưới)
          Positioned(
            top: 0,
            right: 0,
            child: _buildCircleAvatar(img3??'', avatarSize),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleAvatar(String url, double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent, // nền trong suốt
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.grey.shade300,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
