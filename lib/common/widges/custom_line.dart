/*
* Created by: nguyenan
* Created at: 2024/04/26 09:40
*/
part of widget;


class CustomLine extends StatelessWidget {
  final bool isVertical;
  final double size;
  final Color? color;
  final bool isMargin;

  const CustomLine({
    this.isVertical = true,
    this.size = 0.5,
    this.color,
    this.isMargin = false,
  });

  @override
  Widget build(BuildContext context) {
    return isVertical
        ? Container(
        margin: EdgeInsets.symmetric(
            vertical: isMargin ? AppSizes.minPadding : 0.0),
        color: color ?? AppColors.lineColor,
        height: size)
        : Container(
      margin: EdgeInsets.symmetric(
          horizontal: isMargin ? AppSizes.minPadding : 0.0),
      color: color ?? AppColors.lineColor,
      width: size,
      height: 2,
    );
  }
}