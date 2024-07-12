/*
* Created by: nguyenan
* Created at: 2021/07/05 2:12 PM
*/
part of widget;

class CustomIconButton extends StatelessWidget {
  final Function()? onTap;
  final String? icon;
  final Widget? child;
  final Color? color;
  final bool? isText;
  final double? size;
  final Decoration? decoration;

  CustomIconButton(
      {this.child,
        this.icon,
        this.onTap,
        this.color,
        this.isText = false,
        this.decoration,
        this.size});

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      onTap: onTap,
      child: Container(
        width: (isText??false) ? null : (size ?? AppSizes.sizeOnTap),
        height: (size ?? AppSizes.sizeOnTap),
        decoration: decoration,
        padding: EdgeInsets.all((size ?? AppSizes.sizeOnTap) / 5),
        child: Center(
          child: child ??
              CustomImageIcon(
                icon: icon,
                color: color ?? AppColors.primaryColor,
              ),
        ),
      ),
    );
  }
}
