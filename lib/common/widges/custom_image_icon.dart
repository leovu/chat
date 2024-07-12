/*
* Created by: nguyenan
* Created at: 2024/04/26 11:15
*/
part of widget;

class CustomImageIcon extends StatelessWidget {
  final Widget? child;
  final String? icon;
  final Color? color;
  final double? size;

  CustomImageIcon({
    this.icon,
    this.color,
    this.size, this.child
  });

  @override
  Widget build(BuildContext context) {
    return child??(icon!=null?ImageIcon(
      AssetImage(icon!),
      color: color??AppColors.primaryColor,
      size: size??AppSizes.iconSize,
    ):const SizedBox());
  }
}
