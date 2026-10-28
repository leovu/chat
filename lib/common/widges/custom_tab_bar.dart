/*
* Created by: nguyenan
* Created at: 2021/07/05 2:09 PM
*/
part of widget;

class CustomTabBar extends StatelessWidget {
  final bool isExpanded;
  final List<CustomModelTabBar>? tabs;
  final AutoSizeGroup? group;
  final TabController? controller;
  final Function(int index)? onTap;
  final bool isBorder;

  const CustomTabBar(
      {super.key, this.tabs,
        this.group,
        this.controller,
        this.isExpanded = true,
        this.onTap,
        this.isBorder = false});

  Widget _buildTitle(CustomModelTabBar model) {
    return AutoSizeText(
      model.name ?? "",
      maxLines: 1,
      group: group ?? AutoSizeGroup(),
      minFontSize: 6.0,
      textAlign: TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    if ((tabs ?? []).isEmpty) {
      return const SizedBox();
    }

    if (isBorder) {
      return Stack(
        children: [
          Positioned.fill(
              child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.primaryColorMix,
                        width: 2.0,
                      ),
                    ),
                  ))),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.maxPadding),
            child: TabBar(
              labelColor: AppColors.primaryColor,
              unselectedLabelColor: AppColors.textSecondaryColor,
              indicatorWeight: 2.0,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorColor: AppColors.primaryColor,
              isScrollable: true,
              dividerColor: Colors.transparent,
              dividerHeight: 0,
              tabAlignment: TabAlignment.start,
              onTap: onTap,
              unselectedLabelStyle: AppTextStyles.style14PrimaryWeight400
                  .copyWith(color: AppColors.textSecondaryColor),
              labelStyle: AppTextStyles.style14BlackBold
                  .copyWith(color: AppColors.primaryColor),
              labelPadding: EdgeInsets.symmetric(
                  horizontal: isExpanded ? 0.0 : AppSizes.minPadding / 2),
              tabs: (tabs ?? []).map((model) {
                return Tab(
                    child: SizedBox(
                      width: isExpanded
                          ? (AppSizes.maxWidth - AppSizes.maxPadding * 2) /
                          (tabs ?? []).length
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isExpanded
                              ? Flexible(
                              fit: FlexFit.loose, child: _buildTitle(model))
                              : _buildTitle(model)
                        ],
                      ),
                    ));
              }).toList(),
              controller: controller,
            ),
          )
        ],
      );
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSizes.maxPadding),
      padding: const EdgeInsets.all(3.0),
      decoration: AppGlass.pill(color: AppGlass.surfaceLight),
      child: TabBar(
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.textSecondaryColor,
        indicator: BoxDecoration(
          gradient: AppGlass.activeGradient,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: AppGlass.buttonShadow,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        isScrollable: true,
        dividerColor: Colors.transparent,
        dividerHeight: 0,
        tabAlignment: TabAlignment.start,
        onTap: onTap,
        unselectedLabelStyle: AppTextStyles.style14Black50Weight400
            .copyWith(color: AppColors.textSecondaryColor),
        labelStyle: AppTextStyles.style14WhiteWeight600,
        labelPadding: EdgeInsets.symmetric(
            horizontal: isExpanded ? 0.0 : AppSizes.minPadding / 2),
        tabs: (tabs ?? []).map((model) {
          return Tab(
              height: 38.0,
              child: SizedBox(
                width: isExpanded
                    ? (AppSizes.maxWidth - AppSizes.maxPadding * 2 - 6.0) /
                    (tabs ?? []).length
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isExpanded
                        ? Flexible(fit: FlexFit.loose, child: _buildTitle(model))
                        : _buildTitle(model)
                  ],
                ),
              ));
        }).toList(),
        controller: controller,
      ),
    );
  }
}

class CustomTabBarView extends StatelessWidget {
  final List<CustomModelTabBar>? tabs;
  final TabController? controller;
  final ScrollPhysics? physics;

  const CustomTabBarView({super.key, this.tabs, this.controller, this.physics});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
        controller: controller,
        physics: physics,
        children:
        (tabs ?? []).map((model) => model.child ?? const SizedBox()).toList());
  }
}

class CustomModelTabBar {
  String? name;
  final Widget? child;
  bool? isSelected;
  final int? id;
  int? count;

  CustomModelTabBar(
      {this.name, this.child, this.isSelected, this.id, this.count});
}
