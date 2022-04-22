/*
* Created by: nguyenan
* Created at: 2022/04/22 2:04 PM
*/
/*
* Created by: nguyenan
* Created at: 2021/07/24 7:34 PM
*/
import 'package:chat/common/theme.dart';
import 'package:flutter/material.dart';

class CustomSearchTextField extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController controller;
  final String hintText;
  final bool customForMap;
  final bool ignore;
  CustomSearchTextField(
      this.focusNode, this.controller, this.hintText,
      {this.customForMap = false, this.ignore = false
      });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: ignore,
      child: InkWell(
        onTap: () => FocusScope.of(context).requestFocus(focusNode),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0,vertical: 10.0),
          child: Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
                color: const Color(0xFFE7EAEF), borderRadius: BorderRadius.circular(5)),
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Center(
                    child: Icon(
                      Icons.search,
                    ),
                  ),
                ),
                Expanded(child: TextField(
                  focusNode: focusNode,
                  controller: controller,
                  decoration: const InputDecoration.collapsed(
                    hintText: "Tìm ảnh, bộ sưu tạp, files, links",
                  ),
                )),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(5),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Center(
                        child: Icon(
                          Icons.close,
                        ),
                      ),
                    ),
                    onTap: (){
                      controller.text = '';
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

