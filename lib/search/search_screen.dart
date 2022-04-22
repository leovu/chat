import 'package:flutter/material.dart';


class StickyPageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery
        .of(context)
        .size;

    return Column(
      children: [
        Container(
          height: 20.0,
          width: 20.0,
          color: Colors.red,
        ),
        Positioned(
          left: 0,
          bottom: 0,
          child: Hero(
            tag: 'bottom_sheet',
            child: Container(
              color: Colors.orange,
              height: size.height / 4,
              width: size.width,
            ),
          ),
        )
      ],
    );
  }
}