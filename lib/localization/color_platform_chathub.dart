import 'dart:math';
import 'package:flutter/material.dart';

class RandomHexColor {
  static final random = Random();
  static List<Color> hexColor = [Colors.red, Colors.purple, Colors.indigo, Colors.blue, Colors.cyan, Colors.teal, Colors.deepOrange, Colors.brown];
  static Map<String,dynamic> colors = {};
  Color colorRandom(String key) {
    if(hexColor.isEmpty) {
      hexColor = [Colors.red, Colors.purple, Colors.indigo, Colors.blue, Colors.cyan, Colors.teal, Colors.deepOrange, Colors.brown];
    }
    if(!colors.containsKey(key)) {
      colors[key] = hexColor[random.nextInt(hexColor.length)];
      hexColor.remove(colors[key]);
    }
    return colors[key];
  }
}