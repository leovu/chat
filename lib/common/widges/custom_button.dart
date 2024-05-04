/*
* Created by: nguyenan
* Created at: 2024/05/02 08:44
*/
part of widget;

class CustomButton extends StatelessWidget {
  final Color? backgroundColor;
  final Color? borderColor;
  final String? icon;
  final String? text;
  final TextStyle? style;
  final Function()? onTap;
  final bool? isExpand;
  final bool? isIcon;
  final Color? iconColor;
  final bool? enable;
  final double? heightButton;
  final double? marginHorizontal;
  final double? marginVertical;
  final double? heightIcon;
  final double? widthIcon;
  final double? radius;

  const CustomButton(
      {super.key,
        this.backgroundColor,
        this.borderColor,
        this.icon,
        this.text,
        this.style,
        this.onTap,
        this.isExpand = true,
        this.isIcon = false,
        this.iconColor,
        this.enable = true,
        this.heightButton,
        this.marginHorizontal = 0.0,
        this.marginVertical = 0.0,
        this.heightIcon = 20.0,
        this.widthIcon = 20.0,
        this.radius=8.0});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        key: key,
        onTap: (enable??true) ? onTap : null,
        child: Container(
          margin: EdgeInsets.symmetric(
              horizontal: marginHorizontal??0.0, vertical: marginVertical??0.0),
          decoration: BoxDecoration(
              color: (enable??true)
                  ? (backgroundColor ?? AppColors.primaryColor)
                  : (backgroundColor ?? AppColors.primaryColor)
                  .withOpacity(0.3),
              borderRadius: BorderRadius.all(Radius.circular(radius??8.0)),
              border: (borderColor == null)
                  ? null
                  : Border.all(
                  color: borderColor!,
                  width: 1.0,
                  style: BorderStyle.solid)),
          height: heightButton ?? 40.0,
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(icon!=null) Container(
                width: widthIcon,
                height: heightIcon,
                margin: const EdgeInsets.only(right: 10.0),
                child: (isIcon??false)
                    ? CustomImageIcon(
                  icon: icon,
                  color: iconColor ?? AppColors.white,
                  size: 20.0,
                )
                    : Image.asset(
                  icon!,
                  width: 20,
                ),
              ),
              (isExpand??true)
                  ? Flexible(
                  fit: FlexFit.loose,
                  child: AutoSizeText(
                    text??"",
                    style: style ??
                        AppTextStyles.style15WhiteNormal
                            .copyWith(color: AppColors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    minFontSize: 1,
                  ))
                  : Text(
                text??"",
                style: style ??
                    AppTextStyles.style15WhiteNormal
                        .copyWith(color: AppColors.white),)
            ],
          ),
        ));
  }
}
