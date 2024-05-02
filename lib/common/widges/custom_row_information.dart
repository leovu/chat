/*
* Created by: nguyenan
* Created at: 2024/04/26 11:13
*/
part of widget;

class CustomRowInformation extends StatelessWidget {
  final String? title;
  final String? content;
  final bool boldTitle;
  final bool boldContent;
  final bool paddingHorizontal;
  final bool textAlignEnd;
  final String? icon;
  final bool isAlignCenter;
  final AppTextStyles? contentStyle;
  CustomRowInformation(
      {this.title,
        this.content,
        this.boldTitle = false,
        this.boldContent = false,
        this.paddingHorizontal = false,
        this.textAlignEnd = true,
        this.icon,
        this.isAlignCenter = false, this.contentStyle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          top: 10.0,
          right: paddingHorizontal ? AppSizes.minPadding : 0.0,
          left: paddingHorizontal ? AppSizes.minPadding : 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: !isAlignCenter
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          icon == null
              ? Container(
            margin: EdgeInsets.only(right: AppSizes.minPadding),
            child: Text(
              title ?? "",
              style: !boldTitle
                  ? AppTextStyles.style13GrayWeight400
                  : AppTextStyles.style13BlackWeight600,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
              : Container(
            margin: EdgeInsets.only(right: AppSizes.minPadding),
            height: AppSizes.iconSize,
            width: AppSizes.iconSize,
            child: Image.asset(
              icon!,
              color: AppColors.black,
            ),
          ),
          Expanded(
              child: Text(
                content ?? "",
                style: !boldContent
                    ? AppTextStyles.style13BlackWeight400
                    : AppTextStyles.style13BlackWeight600,
                textAlign: textAlignEnd ? TextAlign.end : TextAlign.start,
              ))
        ],
      ),
    );
  }
}

class CustomRowInformation1 extends StatelessWidget {
  final String? title;
  final String? content;
  final Function()? onTap;

  const CustomRowInformation1({Key? key, this.title, this.content, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomInkWell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Text(
                title ?? "",
                style: AppTextStyles.style13Grey500Weight400,
              )),
          SizedBox(
            width: AppSizes.minPadding,
          ),
          Expanded(
              child: Text(
                content?? "--",
                style: onTap == null
                    ? AppTextStyles.style13BlackWeight400
                    : AppTextStyles.style13BlueUnderlineWeight400,
                textAlign: TextAlign.right,
              )),
        ],
      ),
      onTap: onTap,
    );
  }
}

class CustomRichTextInformation extends StatelessWidget {
  final String? title;
  final String? content;
  final TextStyle? titleStyle;
  final Function()? onTap;

  const CustomRichTextInformation(
      {Key? key, this.title, this.content, this.titleStyle, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: RichText(
        text: TextSpan(
            text: "${title ?? ""}: ",
            style: titleStyle ?? AppTextStyles.style13Grey500Weight400,
            children: [
              TextSpan(
                text: content ?? "",
                style: onTap == null
                    ? AppTextStyles.style13BlackWeight400
                    : AppTextStyles.style13BlueUnderlineWeight400,
              )
            ]),
      ),
      onTap: onTap,
    );
  }
}

class CustomRowIconInformation extends StatelessWidget {
  final String? icon;
  final String? text;
  final TextStyle? style;
  final Function()? onTap;
  final bool isRight;

  const CustomRowIconInformation(
      {Key? key,
        this.icon,
        this.text,
        this.style,
        this.onTap,
        this.isRight = false})
      : super(key: key);

  Widget _buildText() {
    return Text(
      text ?? "",
      style: style ??
          (onTap == null
              ? AppTextStyles.style13BlackWeight400
              : AppTextStyles.style13BlueUnderlineWeight400),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
        isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          CustomImageIcon(
            icon: icon,
            color: AppColors.colorTabUnselected,
            size: 18.0,
          ),
          SizedBox(
            width: AppSizes.minPadding,
          ),
          if (isRight)
            Flexible(child: _buildText())
          else
            Expanded(child: _buildText())
        ],
      ),
      onTap: onTap,
    );
  }
}

class CustomRowExpandTitleInformation extends StatelessWidget {
  final String? title;
  final String? content;
  final TextStyle? titleStyle;

  const CustomRowExpandTitleInformation(
      {Key? key, this.title, this.content, this.titleStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(
            "${title ?? ""}:",
            style: titleStyle ?? AppTextStyles.style13Grey500Weight400,
          ),
        ),
        SizedBox(
          width: AppSizes.minPadding,
        ),
        Expanded(
          flex: 2,
          child: Text(
            content ?? "",
            style: AppTextStyles.style13BlackWeight400,
          ),
        )
      ],
    );
  }
}
