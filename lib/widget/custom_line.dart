/*
* Created by: nguyenan
* Created at: 2022/04/22 2:35 PM
*/
part of widget;

class CustomLine extends StatelessWidget{

  final bool isVertical;
  final double size;
  final Color color;
  final bool isMargin;

  CustomLine({
    this.isVertical = true,
    this.size = 0.5,
    this.color = AppColors.dark,
    this.isMargin = false,
  }):assert(isVertical != null && size != null);

  @override
  Widget build(BuildContext context) {
    return isVertical?Container(
        margin: EdgeInsets.symmetric(vertical: isMargin ? 4.0 : 0.0),
        color: color ?? AppColors.lineColor,
        height: size
    ):Container(
        margin: EdgeInsets.symmetric(horizontal: isMargin ? 4.0 : 0.0),
        color: color ?? AppColors.lineColor,
        width: size
    );
  }
}