import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/data_model/room.dart';
import 'package:chat/presentation/utils/ultility.dart';
import 'package:flutter/material.dart';

class ChatGroupAvatar extends StatelessWidget {
  final List<People>? people;
  final double size;
  final String? groupName;

  const ChatGroupAvatar({Key? key, this.people, this.size = 50, this.groupName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double avatarSize = size * 0.5;
    final Widget stack = SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
              bottom: 0,
              left: (size - avatarSize) / 2,
              child: _member(0, avatarSize)),
          Positioned(top: 0, left: 0, child: _member(1, avatarSize)),
          Positioned(top: 0, right: 0, child: _member(2, avatarSize)),
        ],
      ),
    );
    if (groupName == null) return stack;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        stack,
        const SizedBox(height: 4),
        Text(
          groupName!,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _member(int index, double s) {
    final People? p =
        (people != null && people!.length > index) ? people![index] : null;
    final double radius = s / 2;
    final Widget fallback = CircleAvatar(
      radius: radius,
      backgroundColor: getAvatarColor(p?.sId),
      child: Text(
        p?.getAvatarName() ?? '*',
        style: TextStyle(
            color: getAvatarTextColor(p?.sId), fontSize: radius * 0.8),
      ),
    );

    String? url;
    if (p?.picture?.shieldedID?.isNotEmpty == true) {
      url =
          '${HTTPConnection.domain}api/images/${p!.picture!.shieldedID}/256/${ChatConnection.brandCode ?? ''}';
    } else if (p?.avatar?.isNotEmpty == true) {
      url = p!.avatar;
    }
    if (url == null) return fallback;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: Image(
          image: CachedNetworkImageProvider(url,
              headers: {'brand-code': ChatConnection.brandCode ?? ''}),
          fit: BoxFit.cover,
          width: s,
          height: s,
          errorBuilder: (_, __, ___) => fallback,
        ),
      ),
    );
  }
}

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
            child: _buildCircleAvatar(img1 ?? '', avatarSize),
          ),

          // Ảnh 2 (góc trái dưới)
          Positioned(
            top: 0,
            left: 0,
            child: _buildCircleAvatar(img2 ?? '', avatarSize),
          ),

          // Ảnh 3 (góc phải dưới)
          Positioned(
            top: 0,
            right: 0,
            child: _buildCircleAvatar(img3 ?? '', avatarSize),
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
