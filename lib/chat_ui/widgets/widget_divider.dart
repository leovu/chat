import 'package:auto_size_text/auto_size_text.dart';
import 'package:chat/common/theme.dart';
import 'package:flutter/material.dart';

Widget customDivider(String text, {TextStyle? textStyle}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 7),
    child: Row(
      children: [
        Expanded(
            child: Divider(
          color: AppColors.colorDot,
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: AutoSizeText(
            text,
            minFontSize: 8,
            maxFontSize: 20,
            maxLines: 1,
            style: textStyle != null
                ? textStyle
                : TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        Expanded(
            child: Divider(
          color: AppColors.grey,
        )),
      ],
    ),
  );
}
