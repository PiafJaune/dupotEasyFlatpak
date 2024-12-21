import 'package:dupot_easy_flatpak/Infrastructure/Api/localization_api.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Control/Model/View/side_menu_view_model.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Entity/menu_item_entity.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Entity/navigation_entity.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/Theme/theme_text_style.dart';
import 'package:flutter/material.dart';

class SideMenuView extends StatefulWidget {
  String pageSelected;
  Map<String, String> argumentMapSelected;
  Function handleGoTo;
  List<String> applicationIdListInCart;

  int interfaceVersion = 0;

  SideMenuView(
      {super.key,
      required this.pageSelected,
      required this.argumentMapSelected,
      required this.handleGoTo,
      required this.interfaceVersion,
      required this.applicationIdListInCart});

  @override
  State<SideMenuView> createState() => _SideMenuViewState();
}

class _SideMenuViewState extends State<SideMenuView> {
  List<MenuItemEntity> stateCategoryMenuItemList = [];
  List<MenuItemEntity> stateBottomMenuItemList = [];

  List<MenuItemEntity> stateCartMenuItemList = [];

  String statePageSelected = '';
  String stateCategoryIdSelected = '';

  ScrollController scrollController = ScrollController();

  late ThemeTextStyle themeTextStyle;

  @override
  void initState() {
    loadData(true);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant SideMenuView oldWidget) {
    if (oldWidget.pageSelected != widget.pageSelected ||
        (oldWidget.pageSelected == widget.pageSelected &&
            oldWidget.pageSelected == NavigationEntity.pageCategory &&
            oldWidget.argumentMapSelected![
                    NavigationEntity.argumentCategoryId]! !=
                widget.argumentMapSelected![
                    NavigationEntity.argumentCategoryId])) {
      loadData(false);
    } else if (oldWidget.interfaceVersion != widget.interfaceVersion) {
      loadData(false);
    } else if (stateCartMenuItemList.length !=
        widget.applicationIdListInCart.length) {
      loadData(false);
    }

    super.didUpdateWidget(oldWidget);
  }

  void loadData(bool shouldCheckUpdates) async {
    List<MenuItemEntity> categoryMenuItemList =
        await SideMenuViewModel(handleGoTo: widget.handleGoTo)
            .getCategoryMenuItemEntityList();

    if (widget.pageSelected == NavigationEntity.pageCategory) {
      setState(() {
        statePageSelected = widget.pageSelected;
        stateCategoryIdSelected =
            widget.argumentMapSelected[NavigationEntity.argumentCategoryId]!;
      });
    } else {
      setState(() {
        statePageSelected = widget.pageSelected;
      });
    }

    setState(() {
      stateCategoryMenuItemList = categoryMenuItemList;
    });

    List<MenuItemEntity> cartMenuItemList =
        SideMenuViewModel(handleGoTo: widget.handleGoTo)
            .getCartMenuItemEntyList(widget.applicationIdListInCart);
    setState(() {
      stateCartMenuItemList = cartMenuItemList;
    });

    List<MenuItemEntity> bottomMenuItemList =
        await SideMenuViewModel(handleGoTo: widget.handleGoTo)
            .getBottomMenuItemEntityList(shouldCheckUpdates);

    setState(() {
      stateBottomMenuItemList = bottomMenuItemList;
    });
  }

  @override
  Widget build(BuildContext context) {
    themeTextStyle = ThemeTextStyle(context: context);

    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        Column(
          children: stateCategoryMenuItemList
              .map((menuItemLoop) => getMenuLine(menuItemLoop))
              .toList(),
        ),
        if (stateCartMenuItemList.isNotEmpty)
          SizedBox(
            height: 28,
            child: ColoredBox(
              color: Theme.of(context).primaryColorLight,
            ),
          ),
        if (stateCartMenuItemList.isNotEmpty)
          Column(
              children: stateCartMenuItemList
                  .map((menuItemLoop) => getMenuLine(menuItemLoop))
                  .toList()),
        SizedBox(
          height: 28,
          child: ColoredBox(
            color: Theme.of(context).primaryColorLight,
          ),
        ),
        Column(
          children: stateBottomMenuItemList
              .map((menuItemLoop) => getMenuLine(menuItemLoop))
              .toList(),
        ),
      ],
    );
  }

  Widget getMenuLine(MenuItemEntity menuItemLoop) {
    bool isSelected = false;
    if (menuItemLoop.isCategory() &&
        menuItemLoop.pageSelected == statePageSelected &&
        menuItemLoop.categoryIdSelected == stateCategoryIdSelected) {
      isSelected = true;
    } else if (!menuItemLoop.isCategory() &&
        menuItemLoop.pageSelected == statePageSelected) {
      isSelected = true;
    }

    return InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          menuItemLoop.action();
        },
        child: Card(
            color: themeTextStyle.getHeadlineBackgroundColor(isSelected),
            child: Row(
              children: [
                menuItemLoop.badge.isNotEmpty
                    ? IconButton(
                        padding: const EdgeInsets.all(0),
                        icon: Badge(
                            label: Text(menuItemLoop.badge),
                            backgroundColor: Colors.blueAccent,
                            child: Icon(menuItemLoop.icon,
                                color: themeTextStyle
                                    .getHeadlineTextColor(isSelected))),
                        onPressed: null)
                    : IconButton(
                        padding: const EdgeInsets.all(0),
                        icon: Icon(menuItemLoop.icon,
                            color: themeTextStyle
                                .getHeadlineTextColor(isSelected)),
                        onPressed: null,
                      ),
                const SizedBox(width: 8),
                Text(
                  LocalizationApi().tr(menuItemLoop.label),
                  style: isSelected
                      ? TextStyle(
                          backgroundColor: Theme.of(context)
                              .textSelectionTheme
                              .selectionHandleColor)
                      : null,
                ),
              ],
            )));
  }
}
