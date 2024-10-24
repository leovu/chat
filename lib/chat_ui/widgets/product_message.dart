import 'package:chat/chat_ui/chat_theme.dart';
import 'package:chat/chat_ui/conditional/conditional.dart';
import 'package:chat/chat_ui/widgets/webview_widget.dart';
import 'package:chat/flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter/material.dart';

import '../util.dart';
import 'inherited_chat_theme.dart';


class ProductMessage extends StatefulWidget {
  const ProductMessage(
      {required this.message,
        required this.showUserNameForRepliedMessage,
        required this.onMessageTap,
        super.key});

  /// [types.ProductMessage]
  final types.ProductMessage message;

  /// Show user name for replied message.
  final bool showUserNameForRepliedMessage;

  /// See [Message.onMessageTap]
  final void Function(
      BuildContext context, types.Message, int index, bool isRepliedMessage)? onMessageTap;

  @override
  State<ProductMessage> createState() => _ProductMessageState();
}

class _ProductMessageState extends State<ProductMessage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width * 2;
    return Container(
      color: Colors.white,
      width: _width,
      child: (widget.message.messageItems != null && widget.message.messageItems!.length > 1) ? SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child:  Row(
          children:  widget.message.messageItems != null
              ? widget.message.messageItems!.asMap().entries.map((entry) {
            int index = entry.key; // Get the index
            var item = entry.value; // Get the item
            return Padding(
              padding:  EdgeInsets.symmetric(horizontal: 4.0),
              child: _buildProductCard(
                imageUrl: item.image_urls?.first ?? '',
                title: item.name ?? '',
                description: item.description ?? '',
                price: item.price ?? 'Liên hệ',
                buttonLabel: 'Xem chi tiết',
                onTap: () {
                  // Pass index to onMessageTap callback
                  widget.onMessageTap?.call(context, widget.message, index, false);
                },
                onTapDetail: () {
                  if(item.url != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => WebViewWidget( url: item.url ?? '')),
                    );
                  }
                },
                context: context,
              ),
            );
          }).toList()
              : [],
        )
      ) : _buildProductCard(
        imageUrl: widget.message.messageItems?.first.image_urls?.first ?? '',
        title: widget.message.messageItems?.first.name ?? '',
        description: widget.message.messageItems?.first.description ?? '',
        price: widget.message.messageItems?.first.price ?? 'Liên hệ',
        buttonLabel: 'Xem chi tiết',
        onTap: () {
          // Pass index to onMessageTap callback
          widget.onMessageTap?.call(context, widget.message, 0, false);
        },
        onTapDetail: () {
          if(widget.message.messageItems?.first.url != null) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) =>
                  WebViewWidget(
                      url: widget.message.messageItems!.first.url ?? '')),
            );
          }
        },
        context: context,
      ),
    );
  }

  Widget _buildProductCard({
    required String imageUrl,
    required String title,
    required String description,
    required String price,
    required String buttonLabel,
    required VoidCallback onTap,
    required VoidCallback onTapDetail,
    required BuildContext context,
  }) {
    final theme = InheritedChatTheme.of(context).theme;
    final color =
    getUserAvatarNameColor(widget.message.author, theme.userAvatarNameColors);

    return Container(
      width: 200, // Adjust width for each product card
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                SizedBox(
                  height: 40,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 5),
                // Description
                SizedBox(
                  height: 60, // Default height for description
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 5),
                // Price
                Center(
                  child: SizedBox(
                    height: 20, // Default height for price
                    child: Text(
                      'Giá Bán: $price',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // "See Details" button
                SizedBox(
                  width: double.infinity,
                  child: InkWell(
                    onTap: onTapDetail,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          buttonLabel,
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
