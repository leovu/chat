/*
* Created by: nguyenan
* Created at: 2024/04/26 11:17
*/
part of widget;

class CustomInkWell extends StatelessWidget {

  final Key? key;
  final Widget? child;
  final Function()? onTap;
  final Function()? onLongPress;


  CustomInkWell({this.key, this.child, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        key: key,
        onLongPress: onLongPress,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: child,
        onTap: onTap
    );
  }
}
