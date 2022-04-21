import 'package:chat/connection/chat_connection.dart';
import 'package:diffutil_dart/diffutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'inherited_user.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// Animated list which handles automatic animations and pagination
class ChatList extends StatefulWidget {
  /// Creates a chat list widget
  const ChatList({
    Key? key,
    this.isLastPage,
    required this.itemBuilder,
    required this.items,
    this.onEndReached,
    this.onEndReachedThreshold,
    this.scrollPhysics,
    required this.itemScrollController,
    required this.itemPositionsListener,
    this.loadMore
  }) : super(key: key);

  /// Used for pagination (infinite scroll) together with [onEndReached].
  /// When true, indicates that there are no more pages to load and
  /// pagination will not be triggered.
  final bool? isLastPage;

  /// Items to build
  final List<Object> items;

  /// Item builder
  final Widget Function(Object, int? index) itemBuilder;

  /// Used for pagination (infinite scroll). Called when user scrolls
  /// to the very end of the list (minus [onEndReachedThreshold]).
  final Future<void> Function()? onEndReached;

  /// Used for pagination (infinite scroll) together with [onEndReached].
  /// Can be anything from 0 to 1, where 0 is immediate load of the next page
  /// as soon as scroll starts, and 1 is load of the next page only if scrolled
  /// to the very end of the list. Default value is 0.75, e.g. start loading
  /// next page when scrolled through about 3/4 of the available content.
  final double? onEndReachedThreshold;

  /// Determines the physics of the scroll view
  final ScrollPhysics? scrollPhysics;

  final ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener;

  final Function? loadMore;

  @override
  _ChatListState createState() => _ChatListState();
}

/// [ChatList] widget state
class _ChatListState extends State<ChatList>
    with SingleTickerProviderStateMixin {
  bool _isNextPageLoading = false;
  final GlobalKey<SliverAnimatedListState> _listKey =
      GlobalKey<SliverAnimatedListState>();
  late List<Object> _oldData = List.from(widget.items);

  @override
  void initState() {
    super.initState();

    didUpdateWidget(widget);
  }

  @override
  void didUpdateWidget(covariant ChatList oldWidget) {
    super.didUpdateWidget(oldWidget);

    _calculateDiffs(oldWidget.items);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _calculateDiffs(List<Object> oldList) async {
    final diffResult = calculateListDiff<Object>(
      oldList,
      widget.items,
      equalityChecker: (item1, item2) {
        if (item1 is Map<String, Object> && item2 is Map<String, Object>) {
          final message1 = item1['message']! as types.Message;
          final message2 = item2['message']! as types.Message;

          return message1.id == message2.id;
        } else {
          return item1 == item2;
        }
      },
    );

    for (final update in diffResult.getUpdates(batch: false)) {
      update.when(
        insert: (pos, count) {
          _listKey.currentState?.insertItem(pos);
        },
        remove: (pos, count) {
          final item = oldList[pos];
          _listKey.currentState?.removeItem(
            pos,
            (_, animation) => _removedMessageBuilder(item, animation),
          );
        },
        change: (pos, payload) {},
        move: (from, to) {},
      );
    }

    _scrollToBottomIfNeeded(oldList);

    _oldData = List.from(widget.items);
  }

  Widget _newMessageBuilder(int index) {
    try {
      final item = _oldData[index];
      return widget.itemBuilder(item, index);
    } catch (e) {
      return const SizedBox();
    }
  }

  Widget _removedMessageBuilder(Object item, Animation<double> animation) {
    return SizeTransition(
      axisAlignment: -1,
      sizeFactor: animation.drive(CurveTween(curve: Curves.easeInQuad)),
      child: FadeTransition(
        opacity: animation.drive(CurveTween(curve: Curves.easeInQuad)),
        child: widget.itemBuilder(item, null),
      ),
    );
  }

  // Hacky solution to reconsider
  void _scrollToBottomIfNeeded(List<Object> oldList) {
    try {
      // Take index 1 because there is always a spacer on index 0
      final oldItem = oldList[1];
      final item = widget.items[1];

      if (oldItem is Map<String, Object> && item is Map<String, Object>) {
        final oldMessage = oldItem['message']! as types.Message;
        final message = item['message']! as types.Message;
        // Compare items to fire only on newly added messages
        if (oldMessage != message) {
          // Run only for sent message
          if (message.author.id == InheritedUser.of(context).user.id) {
            // Delay to give some time for Flutter to calculate new
            // size after new message was added
            widget.itemScrollController.scrollTo(index: 0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.linear);
          }
        }
      }
    } catch (e) {
      // Do nothing if there are no items
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        double progress = notification.metrics.pixels /
            notification.metrics.maxScrollExtent;
        if(progress >= 0.75) {
          if(widget.loadMore != null && !ChatConnection.isLoadMore) {
            ChatConnection.isLoadMore = true;
            widget.loadMore!();
          }
        }
        if (widget.onEndReached == null || widget.isLastPage == true) {
          return false;
        }
        if (notification.metrics.pixels >=
            (notification.metrics.maxScrollExtent *
                (widget.onEndReachedThreshold ?? 0.75))) {
          if (widget.items.isEmpty || _isNextPageLoading) return false;
          setState(() {
            _isNextPageLoading = true;
          });

          widget.onEndReached!().whenComplete(() {
            setState(() {
              _isNextPageLoading = false;
            });
          });
        }
        return false;
      },
      child: ScrollablePositionedList.builder(
        itemCount: widget.items.length,
        itemScrollController: widget.itemScrollController,
        itemPositionsListener: widget.itemPositionsListener,
        physics: widget.scrollPhysics,
        reverse: true,
        itemBuilder: (context, index) =>_newMessageBuilder(index)
      ),
    );
  }
}
