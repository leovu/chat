part of widget;

class CustomAlertDialog extends StatefulWidget {
  final String? title;
  final String? content;
  final String? textSubmitted;
  final Function()? onSubmitted;
  final String? textSubSubmitted;
  final Function()? onSubSubmitted;
  final bool enableCancel;
  final String? titleHeader;
  final String? iconCenter;
  final bool? enableSubmitted;
  final bool? enableSubSubmitted;
  final bool isProgress;
  final Widget? widgetCopy;

  CustomAlertDialog({
    this.title,
    this.content,
    this.onSubmitted,
    this.textSubmitted,
    this.onSubSubmitted,
    this.textSubSubmitted,
    this.enableCancel = true,
    this.iconCenter,
    this.titleHeader,
    this.enableSubmitted,
    this.enableSubSubmitted,
    this.isProgress = false,
    this.widgetCopy,
  });

  @override
  _CustomAlertDialogState createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.enableCancel,
      child: Stack(alignment: Alignment.center, children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            // if (constraints.maxWidth > 1200) {
            //   AppSizes.avatarSize = constraints.maxWidth / 8;
            // } else if (constraints.maxWidth <= 1200 &&
            //     constraints.maxWidth >= 800) {
            //   AppSizes.avatarSize = constraints.maxWidth / 6;
            // } else {
            //   AppSizes.avatarSize = constraints.maxWidth / 6;
            // }
            return Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                margin: widget.iconCenter != null
                    ? EdgeInsets.all(20)
                    : EdgeInsets.all(0),
                padding: EdgeInsets.symmetric(
                    vertical: (widget.enableCancel)
                        ? 10.0
                        : 20.0,
                    horizontal: 20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        if (widget.enableCancel)
                          CustomIconButton(
                            color: AppColors.dark,
                            onTap: () => CustomNavigator.pop(context),
                          ),
                        if (widget.titleHeader != null)
                          Expanded(
                            child: Text(
                              widget.titleHeader ?? "",
                              style: AppTextStyles.style16BlackWeight700,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (widget.enableCancel)
                          Container(
                            width: 40.0,
                          )
                      ],
                    ),
                    if (widget.isProgress)
                      Center(child: CircularProgressIndicator())
                    else if (widget.iconCenter != null)
                      Center(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 20.0),
                          height: 50.0,
                          width: 50.0,
                          alignment: Alignment.center,
                          child: Image.asset(
                              widget.iconCenter ?? Assets.iconWarning),
                        ),
                      ),
                    if (widget.title != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.0),
                        child: SelectableText(
                          widget.title ?? "",
                          contextMenuBuilder: (context, editableTextState) {
                            final List<ContextMenuButtonItem> buttonItems =
                                editableTextState.contextMenuButtonItems;
                            buttonItems.removeWhere(
                                    (ContextMenuButtonItem buttonItem) {
                                  return buttonItem.type ==
                                      ContextMenuButtonType.cut;
                                });
                            buttonItems.removeWhere(
                                    (ContextMenuButtonItem buttonItem) {
                                  return buttonItem.type ==
                                      ContextMenuButtonType.paste;
                                });
                            buttonItems.removeWhere(
                                    (ContextMenuButtonItem buttonItem) {
                                  return buttonItem.type ==
                                      ContextMenuButtonType.custom;
                                });
                            buttonItems.removeWhere(
                                    (ContextMenuButtonItem buttonItem) {
                                  return buttonItem.type ==
                                      ContextMenuButtonType.delete;
                                });
                            return AdaptiveTextSelectionToolbar.buttonItems(
                              anchors: editableTextState.contextMenuAnchors,
                              buttonItems: buttonItems,
                            );
                          },
                          style: AppTextStyles.style16BlackWeight700,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (widget.widgetCopy != null)
                      Container(
                        padding:
                        EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: SelectableText(
                                widget.content ?? "",
                                contextMenuBuilder: (context, editableTextState) {
                                  final List<ContextMenuButtonItem>
                                  buttonItems =
                                      editableTextState.contextMenuButtonItems;
                                  buttonItems.removeWhere(
                                          (ContextMenuButtonItem buttonItem) {
                                        return buttonItem.type ==
                                            ContextMenuButtonType.cut;
                                      });
                                  buttonItems.removeWhere(
                                          (ContextMenuButtonItem buttonItem) {
                                        return buttonItem.type ==
                                            ContextMenuButtonType.paste;
                                      });
                                  buttonItems.removeWhere(
                                          (ContextMenuButtonItem buttonItem) {
                                        return buttonItem.type ==
                                            ContextMenuButtonType.custom;
                                      });
                                  buttonItems.removeWhere(
                                          (ContextMenuButtonItem buttonItem) {
                                        return buttonItem.type ==
                                            ContextMenuButtonType.delete;
                                      });
                                  return AdaptiveTextSelectionToolbar
                                      .buttonItems(
                                    anchors:
                                    editableTextState.contextMenuAnchors,
                                    buttonItems: buttonItems,
                                  );
                                },
                                style: AppTextStyles.style15Grey600Normal,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            widget.widgetCopy!
                          ],
                        ),
                      )
                    else
                      Container(
                        padding:
                        EdgeInsets.symmetric(vertical: 10.0),
                        child: SelectableText(
                          widget.content ?? "",
                          contextMenuBuilder: (context, editableTextState) {
                            final List<ContextMenuButtonItem> buttonItems =
                                editableTextState.contextMenuButtonItems;
                            buttonItems.removeWhere(
                                    (ContextMenuButtonItem buttonItem) {
                                  return buttonItem.type ==
                                      ContextMenuButtonType.cut;
                                });
                            buttonItems.removeWhere(
                                    (ContextMenuButtonItem buttonItem) {
                                  return buttonItem.type ==
                                      ContextMenuButtonType.paste;
                                });
                            buttonItems.removeWhere(
                                    (ContextMenuButtonItem buttonItem) {
                                  return buttonItem.type ==
                                      ContextMenuButtonType.custom;
                                });
                            buttonItems.removeWhere(
                                    (ContextMenuButtonItem buttonItem) {
                                  return buttonItem.type ==
                                      ContextMenuButtonType.delete;
                                });
                            return AdaptiveTextSelectionToolbar.buttonItems(
                              anchors: editableTextState.contextMenuAnchors,
                              buttonItems: buttonItems,
                            );
                          },
                          style: AppTextStyles.style15Grey600Normal,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (!(widget.isProgress))
                      Row(
                        children: [
                          if (widget.textSubSubmitted != null)
                            Expanded(
                              child: Container(
                                  padding: EdgeInsets.only(
                                      right: 10.0),
                                  child: CustomButton(
                                    text: widget.textSubSubmitted,
                                    backgroundColor:
                                    (widget.enableSubSubmitted ?? true)
                                        ? AppColors.black50Color
                                        : AppColors.black50Color
                                        .withOpacity(0.3),
                                    onTap: widget.onSubSubmitted ??
                                            () => CustomNavigator.pop(context),
                                  )),
                            ),
                          Expanded(
                            child: CustomButton(
                              text: widget.textSubmitted ??
                                  AppLocalizations.text(LangKey.confirm),
                              backgroundColor: (widget.enableSubmitted ?? true)
                                  ? Colors.blue
                                  : Colors.blue.withOpacity(0.3),
                              onTap: widget.onSubmitted ??
                                      () => CustomNavigator.pop(context),
                            ),
                          ),
                        ],
                      ),
                    if (widget.enableCancel)
                      Container(
                        height: 10.0 / 2,
                      ),
                  ],
                ));
          },
        )
      ]),
    );
  }
}
