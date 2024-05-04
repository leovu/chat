/*
* Created by: nguyenan
* Created at: 2021/07/05 2:04 PM
*/
part of widget;

class CustomAppBar extends StatelessWidget {
  final String? title;
  final List<CustomOptionAppBar>? options;
  final String? icon;
  final Function()? onWillPop;
  final bool isPrimary;
  final Alignment alignmentTitle;
  final TextStyle? textStyleTitle;
  final bool allowPop;
  final Widget? rightWidget;

  const CustomAppBar(
      {super.key, this.title,
        this.options,
        this.icon,
        this.onWillPop,
        this.isPrimary = false,
        this.alignmentTitle = Alignment.center,
        this.textStyleTitle,
        this.allowPop = true,
        this.rightWidget});

  Widget _buildIcon(int index, Color color) {
    CustomOptionAppBar model = options![index];
    return CustomIconButton(
        onTap: model.onTap,
        icon: model.icon,
        isText: model.text != null,
        color: color,
        child: model.text == null
            ? null
            : Text(
          model.text ?? "",
          style: AppTextStyles.style15PrimaryNormal,
        ));
  }

  @override
  Widget build(BuildContext context) {
    bool canPop = CustomNavigator.canPop(context);
    Color color = isPrimary ? AppColors.white : AppColors.black;
    return Stack(fit: StackFit.expand, children: [
      Container(
        alignment: alignmentTitle,
        padding: allowPop
            ? EdgeInsets.symmetric(
            horizontal: AppSizes.minPadding +
                ((options ?? []).isEmpty
                    ? (canPop ? AppSizes.sizeOnTap : 0.0)
                    : (options!.length * AppSizes.sizeOnTap)))
            : EdgeInsets.only(left: AppSizes.minPadding),
        child: Text(
          title ?? "",
          style: textStyleTitle ?? AppTextStyles.style16BlackWeight500.copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Row(
        children: [
          if (allowPop) Opacity(
            opacity: canPop ? 1.0 : 0.0,
            child: InkWell(
              onTap: canPop
                  ? (onWillPop ?? () => CustomNavigator.pop(context))
                  : null,
              child: Container(
                width: AppSizes.sizeOnTap,
                height: AppSizes.sizeOnTap,
                padding: EdgeInsets.only(left: AppSizes.maxPadding),
                child: CustomImageIcon(
                  // icon: icon ?? Assets.iconBack,
                  color: color,
                  size: 15.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          if (rightWidget != null)
            rightWidget!
          else if ((options ?? []).isNotEmpty)
            Container(
                height: AppSizes.sizeOnTap,
                margin: EdgeInsets.only(right: AppSizes.minPadding),
                child: ListView.builder(
                    padding:
                    EdgeInsets.symmetric(horizontal: AppSizes.minPadding),
                    itemCount: options!.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, index) =>
                    options![index].child ?? _buildIcon(index, color)))
        ],
      )
    ]);
  }
}

class CustomOptionAppBar {
  final String? icon;
  final Function()? onTap;
  final bool? showIcon;
  final Widget? child;
  final String? text;

  const CustomOptionAppBar(
      {this.icon, this.showIcon = true, this.onTap, this.child, this.text});
}
