import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/chat_screen/group_image_item.dart';
import 'package:chat/chat_ui/widgets/link_preview.dart';
import 'package:chat/connection/chat_connection.dart';
import 'package:chat/connection/download.dart';
import 'package:chat/connection/http_connection.dart';
import 'package:chat/localization/app_localizations.dart';
import 'package:chat/localization/lang_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chat/data_model/chat_message.dart' as c;
import 'package:chat/data_model/room.dart' as r;

class BySenderResultScreen extends StatefulWidget {
  final c.ChatMessage? chatMessage;
  final r.Rooms roomData;
  final String? search;
  final int tabbarIndex;
  const BySenderResultScreen(
      {Key? key,
      required this.roomData,
      required this.chatMessage,
      this.search,
      required this.tabbarIndex})
      : super(key: key);
  @override
  _State createState() => _State();
}

class _State extends State<BySenderResultScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  late int _tabIndex;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.tabbarIndex;
    _tabController =
        TabController(length: 3, vsync: this, initialIndex: widget.tabbarIndex);
    _tabController.addListener(() {
      if (_tabIndex != _tabController.index) {
        setState(() => _tabIndex = _tabController.index);
      }
    });
  }

  // Segmented chọn loại (IMAGE/FILE/LINK) — cùng style với ConversationFileScreen.
  Widget _typeSegmented() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        splashBorderRadius: BorderRadius.circular(9),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: const Color(0xff5686E1),
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        unselectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        labelPadding: EdgeInsets.zero,
        tabs: const [
          Tab(
            height: 38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_outlined, size: 16),
                SizedBox(width: 6),
                Text('IMAGE'),
              ],
            ),
          ),
          Tab(
            height: 38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insert_drive_file_outlined, size: 16),
                SizedBox(width: 6),
                Text('FILE'),
              ],
            ),
          ),
          Tab(
            height: 38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.link, size: 16),
                SizedBox(width: 6),
                Text('LINK'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Bottomsheet hiển thị media của một người gửi (thay cho mở màn hình mới).
  void _showSenderSheet(r.People people, List<c.Images> images) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${people.firstName ?? ''} ${people.lastName ?? ''}'
                                .trim(),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text('${images.length}',
                            style: TextStyle(color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  Expanded(child: _sheetBody(images, scrollController)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _sheetBody(List<c.Images> images, ScrollController controller) {
    if (_tabIndex == 0) {
      return GridView.builder(
        controller: controller,
        padding: const EdgeInsets.all(8),
        itemCount: images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
        itemBuilder: (context, i) {
          final content = images[i].content;
          return InkWell(
            onTap: () => openImage(context,
                '${HTTPConnection.domain}api/images/$content/512/${ChatConnection.brandCode}'),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl:
                    '${HTTPConnection.domain}api/images/$content/512/${ChatConnection.brandCode!}',
                httpHeaders: {'brand-code': ChatConnection.brandCode!},
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CupertinoActivityIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          );
        },
      );
    }
    if (_tabIndex == 1) {
      return ListView.builder(
        controller: controller,
        padding: const EdgeInsets.all(8),
        itemCount: images.length,
        itemBuilder: (context, i) {
          final file = images[i].file;
          return ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.blue,
              ),
              child: Image.asset('assets/icon-document.png',
                  color: Colors.white, package: 'chat'),
            ),
            title: Text(file?.name ?? '',
                maxLines: 2, overflow: TextOverflow.ellipsis),
            onTap: () async {
              if (file?.shieldedID == null) return;
              String? result = await download(
                  context,
                  '${HTTPConnection.domain}api/files/${file!.shieldedID}',
                  '${images[i].date}_${file.name}');
              openFile(result, context,
                  file.name ?? AppLocalizations.text(LangKey.file));
            },
          );
        },
      );
    }
    final urlRegExp = RegExp(
        r"((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?");
    final List<String> urls = [];
    for (final e in images) {
      for (final m in urlRegExp.allMatches(e.content ?? '')) {
        urls.add((e.content ?? '').substring(m.start, m.end));
      }
    }
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(10),
      itemCount: urls.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: PreviewLink(content: urls[i]),
      ),
    );
  }

  Widget _searchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() {
          _search = v;
        }),
        decoration: InputDecoration(
          hintText: AppLocalizations.text(LangKey.search),
          prefixIcon: const Icon(Icons.search, size: 20),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }

  // Danh sách media của tab hiện tại (image/file/link).
  List<c.Images> _currentList() =>
      (_tabIndex == 0
          ? widget.chatMessage?.room?.images
          : _tabIndex == 1
              ? widget.chatMessage?.room?.files
              : widget.chatMessage?.room?.links) ??
      <c.Images>[];

  // Chỉ những người thực sự có gửi media ở tab này (đã lọc theo tìm kiếm).
  List<r.People> _sendersWithMedia() {
    final list = _currentList();
    final query = _search.isNotEmpty ? _search : (widget.search ?? '');
    var people = widget.roomData.people ?? <r.People>[];
    if (query.isNotEmpty) {
      people = people
          .where((e) => '${e.firstName} ${e.lastName}'
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
    return people
        .where((e) => list.any((el) => el.author?.sId == e.sId))
        .toList();
  }

  Widget totalText() {
    final count = _sendersWithMedia().length;
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 8.0),
      child: Center(
        child: Text(
            count > 1
                ? '$count ${AppLocalizations.text(LangKey.senders)}'
                : '$count ${AppLocalizations.text(LangKey.sender)}',
            style: TextStyle(
                fontSize: 15.0,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          AppLocalizations.text(LangKey.bySenders),
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: InkWell(
          child: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onTap: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _typeSegmented(),
            _searchField(),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      child: Wrap(
                        children: _listFiltered(),
                      ),
                    ),
                    totalText()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _listFiltered() {
    final listImages = _currentList();
    // Chỉ hiển thị người có gửi media ở tab này để tránh thẻ rỗng/không đồng bộ.
    final listPeople = _sendersWithMedia();
    return listPeople.map((e) {
      final media = listImages.where((el) => el.author?.sId == e.sId).toList();
      return GroupImageItem(
        people: e,
        tabbarIndex: _tabIndex,
        images: media,
        onTap: () => _showSenderSheet(e, media),
      );
    }).toList();
  }
}
