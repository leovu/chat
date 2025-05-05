import 'package:flutter/material.dart';

class ScreenInfo {
  static double? width;
  static double? height;
  static double? paddingTop;
  static double? paddingBottom;
  static double? paddingLeft;
  static double? paddingRight;
  static double? safeAreaTop;
  static double? safeAreaBottom;
  static double? safeAreaLeft;
  static double? safeAreaRight;

  static void initialize(MediaQueryData mediaQuery) {
    width = mediaQuery.size.width;
    height = mediaQuery.size.height;
    paddingTop = mediaQuery.padding.top;
    paddingBottom = mediaQuery.padding.bottom;
    paddingLeft = mediaQuery.padding.left;
    paddingRight = mediaQuery.padding.right;
    safeAreaTop = mediaQuery.viewPadding.top;
    safeAreaBottom = mediaQuery.viewPadding.bottom;
    safeAreaLeft = mediaQuery.viewPadding.left;
    safeAreaRight = mediaQuery.viewPadding.right;
  }
}
