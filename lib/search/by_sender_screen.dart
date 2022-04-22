import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/search/group_image_item.dart';
import 'package:flutter/material.dart';

class BySenderResultScreen extends StatefulWidget {
  const BySenderResultScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<BySenderResultScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget totalText(){
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.only(top: 8.0),
      child: Center(
        child: Text(
          "4 senders", style: TextStyle(fontSize: 15.0, color: Colors.grey.shade600, fontWeight: FontWeight.w500)
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoSizeText(
          'By Senders',
          style: TextStyle(
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
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: Wrap(
                children: const <Widget> [
                  GroupImageItem(),
                  GroupImageItem(),
                  GroupImageItem(),
                  GroupImageItem(),
                ],
              ),
            ),
            totalText()
          ],
        ),
      ),
    );
  }
}
