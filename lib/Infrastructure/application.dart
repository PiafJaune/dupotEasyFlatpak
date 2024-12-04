import 'package:dupot_easy_flatpak/Infrastructure/Entity/navigation_entity.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/Layout/only_content_layout.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/Layout/side_menu_with_content.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/Layout/side_menu_with_content_and_subcontent.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SubView/install_subview.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SubView/uninstall_subview.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/View/application_view.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/View/category_view.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/View/home_view.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/View/loading_view.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/View/side_menu_view.dart';
import 'package:flutter/material.dart';

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  _ApplicationState createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  static const String constOnlyContent = 'onlyContent';
  static const String constSideMenuWithContent = 'sideMenuWithContent';
  static const String constSideMenuWithContentAndSubContent =
      'sideMenuWithContentAndSubContent';

  static const Map<String, List<String>> layoutSetupList = {
    constOnlyContent: [NavigationEntity.pageLoading],
    constSideMenuWithContent: [
      //NavigationEntity.pageHome,
      NavigationEntity.pageCategory,
      NavigationEntity.pageApplication
    ],
    constSideMenuWithContentAndSubContent: [
      NavigationEntity.argumentSubPageInstall,
      NavigationEntity.argumentSubPageInstallWithRecipe,
      NavigationEntity.argumentSubPageOverride,
      NavigationEntity.argumentSubPageUninstall,
      NavigationEntity.argumentSubPageUpdate
    ]
  };

  String statePage = NavigationEntity.pageLoading;
  Map<String, String> stateArgumentMap = {};

  @override
  void initState() {
    print('init application');
    print('statePage: $statePage');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Navigator(
      pages: [
        if (statePage == NavigationEntity.pageLoading)
          MaterialPage(
              key: const ValueKey(NavigationEntity.pageHome),
              child: OnlyContentLayout(
                  handleGoTo: goTo,
                  content: LoadingView(handle: () {
                    NavigationEntity.goToHome(handleGoTo: goTo);
                  })))
        else
          MaterialPage(
              key: const ValueKey(NavigationEntity.pageHome),
              child: SideMenuWithContentLayout(
                  menu: getSideMenuView(),
                  content: getContentView(NavigationEntity.pageHome, true))),
        if (layoutSetupList[constSideMenuWithContent]!.contains(statePage))
          MaterialPage(
              key: ValueKey(statePage),
              child: SideMenuWithContentLayout(
                  menu: getSideMenuView(),
                  content: getContentView(statePage, true))),
        if (stateArgumentMap.containsKey(NavigationEntity.argumentSubPage) &&
            layoutSetupList[constSideMenuWithContentAndSubContent]!.contains(
                NavigationEntity.extractArgumentSubPage(stateArgumentMap)))
          MaterialPage(
              key: ValueKey(
                  NavigationEntity.extractArgumentSubPage(stateArgumentMap)),
              child: SideMenuWithContentAndSubContentLayout(
                menu: getSideMenuView(),
                content: getContentView(statePage, false),
                subContent: getSubContentView(),
              ))
      ],
      onDidRemovePage: (page) => true,
    ));
  }

  Widget getSideMenuView() {
    return SideMenuView(
      pageSelected: statePage,
      argumentMapSelected: stateArgumentMap,
      handleGoTo: goTo,
    );
  }

  Widget getContentView(String pageToLoad, bool isMain) {
    if (pageToLoad == NavigationEntity.pageHome) {
      return HomeView(handleGoTo: goTo);
    } else if (pageToLoad == NavigationEntity.pageCategory) {
      String newCategoryId =
          NavigationEntity.extractArgumentCategoryId(stateArgumentMap);

      return CategoryView(
        handleGoTo: goTo,
        categoryIdSelected: newCategoryId,
      );
    } else if (pageToLoad == NavigationEntity.pageApplication) {
      String newAppId =
          NavigationEntity.extractArgumentApplicationId(stateArgumentMap);

      return ApplicationView(
        handleGoTo: goTo,
        applicationIdSelected: newAppId,
        isMain: isMain,
      );
    }
    throw new Exception('missing content view for statePage $statePage');
  }

  Widget getSubContentView() {
    String subPageToLoad = stateArgumentMap[NavigationEntity.argumentSubPage]!;

    if (subPageToLoad == NavigationEntity.argumentSubPageInstall) {
      String applicationId =
          NavigationEntity.extractArgumentApplicationId(stateArgumentMap);
      return InstallSubview(
          applicationId: applicationId,
          handleGoToApplication: () => NavigationEntity.gotToApplicationId(
              handleGoTo: goTo, applicationId: applicationId));
    } else if (subPageToLoad == NavigationEntity.argumentSubPageUninstall) {
      String applicationId =
          NavigationEntity.extractArgumentApplicationId(stateArgumentMap);

      bool willDeleteAppData = false;
      if (stateArgumentMap.containsKey('willDeleteAppData')) {
        willDeleteAppData = true;
      }

      return UninstallSubview(
        applicationId: applicationId,
        handleGoToApplication: () => NavigationEntity.gotToApplicationId(
            handleGoTo: goTo, applicationId: applicationId),
        willDeleteAppData: willDeleteAppData,
      );
    }
    throw new Exception(
        'missing content sub view for subPageToLoad $subPageToLoad');
  }

  void goTo({required String page, required Map<String, String> argumentMap}) {
    setState(() {
      statePage = page;
      stateArgumentMap = argumentMap;
    });
  }
}
