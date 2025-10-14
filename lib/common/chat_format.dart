
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

Map<String, Style> htmlTagStyles() {
  return {
    "*": Style(
      fontSize: FontSize(14.0),
      color: Colors.black87,
      margin: Margins.only(top: 0, bottom: 0),
      padding: HtmlPaddings.zero,
    ),
    "p": Style(margin: Margins.only(bottom: 4)),
    "b": Style(fontWeight: FontWeight.bold),
    "i": Style(fontStyle: FontStyle.italic),
    "b i": Style(
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
    ),
    "i b": Style(
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.bold,
    ),
    "u": Style(textDecoration: TextDecoration.underline),
    "a": Style(
      color: Colors.blue,
      textDecoration: TextDecoration.underline,
    ),
    "h1": Style(fontSize: FontSize(22.0), fontWeight: FontWeight.bold),
    "h2": Style(fontSize: FontSize(20.0), fontWeight: FontWeight.bold),
    "h3": Style(fontSize: FontSize(18.0), fontWeight: FontWeight.bold),
    "ul": Style(margin: Margins.symmetric(vertical: 8)),
    "li": Style(margin: Margins.only(bottom: 4)),
    "blockquote": Style(
      fontStyle: FontStyle.italic,
      backgroundColor: Colors.grey.shade100,
      padding: HtmlPaddings.all(8),
      border: const Border(left: BorderSide(color: Colors.grey, width: 3)),
    ),
    "code": Style(
      fontFamily: 'monospace',
      backgroundColor: Colors.grey.shade200,
      padding: HtmlPaddings.all(4),
    ),
  };
}