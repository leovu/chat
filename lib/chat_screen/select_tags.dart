import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../chat_ui/hex_color.dart';
import '../data_model/tag.dart';
import '../localization/app_localizations.dart';
import '../localization/lang_key.dart';

class SelectTagsScreen extends StatefulWidget {
  final List<Data> items;
  final Future<void> Function(List<Data>) onSave;

  const SelectTagsScreen({Key? key, required this.items, required this.onSave})
      : super(key: key);

  @override
  _SelectTagsScreenState createState() => _SelectTagsScreenState();
}

class _SelectTagsScreenState extends State<SelectTagsScreen> {
  @override
  void initState() {
    super.initState();
    // Clone danh sách để không thay đổi dữ liệu gốc
    // items = widget.items.map((e) => e.copyWith()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: AutoSizeText(
          AppLocalizations.text(LangKey.select_tags),
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        leading: InkWell(
          child: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
              color: Colors.black),
          onTap: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
                child: Wrap(
              spacing: 8, // khoảng cách giữa các phần tử ngang
              runSpacing: 8, // khoảng cách giữa các dòng
              children: widget.items.map((item) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      item.isActive = !item.isActive;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: HexColor.fromHex('#0067AC')),
                      color: item.isActive
                          ? HexColor.fromHex('#0067AC')
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.name ?? '',
                      style: TextStyle(
                        color: item.isActive
                            ? Colors.white
                            : HexColor.fromHex('#0067AC'),
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: 40,
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: HexColor.fromHex('#0067AC')),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.text(LangKey.close),
                          style: TextStyle(
                            color: HexColor.fromHex('#0067AC'),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () async {
                    showLoading(); // Nếu bạn có hàm này
                    final selectedItems =
                        widget.items.where((e) => e.isActive).toList();
                    await widget.onSave(selectedItems);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: 40,
                      padding: const EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: HexColor.fromHex('#0067AC'),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.text(LangKey.update),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future showLoading() async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            children: <Widget>[
              Center(
                child: Platform.isAndroid
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const CupertinoActivityIndicator(
                        color: Colors.white,
                      ),
              )
            ],
          );
        });
  }
}
