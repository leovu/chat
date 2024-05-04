/*
* Created by: nguyenan
* Created at: 2021/07/05 1:59 PM
*/
part of widget;

class CustomScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final List<CustomOptionAppBar>? options;
  final bool isShadow;
  final bool isBorder;
  final double borderWidth;
  final CustomRefreshCallback? onRefresh;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final List<KeyboardActionsItem>? actions;
  final bool isPrimary;
  final String? icon;
  final List<CustomModelTabBar>? tabs;
  final TabController? tabController;
  final Function()? onWillPop;
  final bool isBottomBar;
  final bool isBottomSheet;
  final Alignment alignmentTitle;
  final TextStyle? textStyleTitle;
  final bool allowPop;
  final Widget? rightWidget;

  const CustomScaffold(
      {required this.body,
        this.title,
        this.options,
        this.isShadow = true,
        this.onRefresh,
        this.backgroundColor,
        this.floatingActionButton,
        this.actions,
        this.isPrimary = false,
        this.icon,
        this.tabs,
        this.tabController,
        this.onWillPop,
        this.isBottomBar = false,
        this.isBottomSheet = false,
        this.isBorder = false,
        this.alignmentTitle = Alignment.center,
        this.textStyleTitle,
        this.allowPop = true,
        this.borderWidth = 6,
        this.rightWidget});

  Widget _buildBody(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop)async{
        if (didPop) {
          return;
        }
        print("didPop:"+didPop.toString());
        if (allowPop) {
          if (onWillPop != null) {
            onWillPop!();
          } else {
            if (CustomNavigator.canPop(context)) {
              CustomNavigator.pop(context);
            }
          }
        }
        return Future.value(allowPop);

      },

      // onWillPop: () async {
      //   if (allowPop) {
      //     if (onWillPop != null) {
      //       onWillPop!();
      //     } else {
      //       if (CustomNavigator.canPop(context)) {
      //         CustomNavigator.pop(context);
      //       }
      //     }
      //   }
      //   return allowPop;
      // },
      child: Scaffold(
          backgroundColor: backgroundColor ?? AppColors.white,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                    left: 0.0,
                    right: 0.0,
                    bottom: 0.0,
                    top: 0.0,
                    child: Column(
                      children: [
                        Expanded(
                            child: Container(
                                padding: EdgeInsets.only(
                                    top: title != null
                                        ? (AppSizes.sizeAppBar +
                                        (tabs != null
                                            ? AppSizes.tabBarHeight
                                            : 0.0))
                                        : 0.0),
                                child: tabs == null
                                    ? onRefresh == null
                                    ? body
                                    : RefreshIndicator(
                                    color: AppColors.primaryColor,
                                    backgroundColor: AppColors.white,
                                    child: body, onRefresh: onRefresh!)
                                    : CustomTabBarView(
                                  controller: tabController,
                                  tabs: tabs,
                                ))),
                        if (!isBottomBar) Container(
                          height: AppSizes.bottomHeight,
                          color: AppColors.white,
                        )
                      ],
                    )),
                if (title != null) Container(
                  height: AppSizes.sizeAppBar +
                      (tabs != null ? AppSizes.tabBarHeight : 0),
                  decoration: BoxDecoration(
                      color: isPrimary
                          ? AppColors.primaryColor
                          : AppColors.white,
                      // borderRadius: BorderRadius.vertical(bottom: Radius.circular(8.0)),
                      // boxShadow: isShadow ? AppBoxShadow.boxShadow : null,
                      border: Border(
                          bottom: isBorder
                              ? BorderSide(
                              color: AppColors.colorLine,
                              width: borderWidth)
                              : BorderSide.none)),
                  padding: EdgeInsets.only(top: AppSizes.statusBarHeight),
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomAppBar(
                          title: title,
                          options: options,
                          icon: icon,
                          onWillPop: onWillPop,
                          isPrimary: isPrimary,
                          alignmentTitle: alignmentTitle,
                          textStyleTitle: textStyleTitle,
                          allowPop: allowPop,
                          rightWidget: rightWidget,
                        ),
                      ),
                      CustomTabBar(
                        tabs: tabs,
                        group: AutoSizeGroup(),
                        controller: tabController,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: floatingActionButton,
          resizeToAvoidBottomInset: !isBottomSheet),
    );
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardActions(
      config: configKeyboardActions(actions ?? []),
      disableScroll: true,
      // enable: PlatformCheck.isIOS || PlatformCheck.isMacOS,
      child: _buildBody(context),
    );
  }
}
