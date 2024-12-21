import 'dart:io';

import 'package:dupot_easy_flatpak/Domain/Entity/db/application_entity.dart';
import 'package:dupot_easy_flatpak/Domain/Entity/user_settings_entity.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Api/recipe_api.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Entity/navigation_entity.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Repository/application_repository.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Button/install_all_button.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Button/override_button.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Button/remove_from_cart_button.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Button/update_all_button.dart';
import 'package:flutter/material.dart';

class CartView extends StatefulWidget {
  Function handleGoTo;
  List<String> applicationIdListInCart;
  bool isMain;
  Function handleRemoveFromCart;

  CartView(
      {super.key,
      required this.handleGoTo,
      required this.isMain,
      required this.applicationIdListInCart,
      required this.handleRemoveFromCart});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  List<ApplicationEntity> stateApplicationEntityList = [];
  List<String> stateApplicationRecipeIdList = [];

  Map<String, bool> stateCheckboxList = {};

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    loadData();

    super.initState();
  }

  @override
  void didUpdateWidget(CartView oldWidget) {
    if (stateApplicationEntityList.length !=
        widget.applicationIdListInCart.length) {
      loadData();
    }

    super.didUpdateWidget(oldWidget);
  }

  Future<void> loadData() async {
    Map<String, bool> checkboxList = {};

    List<String> distinctApplicationIdList = [];

    List<String> applicationRecipeIdList =
        await RecipeApi().getRecipeApplicationIdList();

    List<String> applicationUpdateIdList = [];
    for (String applicationIdLoop in widget.applicationIdListInCart) {
      if (!distinctApplicationIdList.contains(applicationIdLoop)) {
        checkboxList[applicationIdLoop] = false;

        distinctApplicationIdList.add(applicationIdLoop);
      }
    }

    List<ApplicationEntity> applicationEntityList =
        await ApplicationRepository()
            .findListApplicationEntityByIdList(distinctApplicationIdList);

    setState(() {
      stateCheckboxList = checkboxList;

      stateApplicationEntityList = applicationEntityList;

      stateApplicationRecipeIdList = applicationRecipeIdList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        interactive: false,
        thumbVisibility: true,
        controller: scrollController,
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  getInstallAllButton(),
                ],
              )),
          Expanded(
              child: ListView(
                  controller: scrollController,
                  children: stateApplicationEntityList
                      .map((ApplicationEntity applicationEntity) =>
                          getLine(applicationEntity))
                      .toList()))
        ]));
  }

  ApplicationEntity? getApplicationEntity(String id) {
    for (ApplicationEntity appLoop in stateApplicationEntityList) {
      if (appLoop.id.toLowerCase() == id.toLowerCase()) {
        return appLoop;
      }
    }
    return null;
  }

  Widget getLine(ApplicationEntity applicationEntity) {
    return Card(
        color: Theme.of(context).primaryColorLight,
        child: ListTile(
          title: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 10),
                  !applicationEntity.hasAppIcon()
                      ? Image.asset('assets/images/no-image.png', height: 60)
                      : Image.file(
                          height: 60,
                          File(
                              '${UserSettingsEntity().getApplicationIconsPath()}/${applicationEntity.getAppIcon()}')),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          applicationEntity.name,
                          style: TextStyle(
                              fontSize: 26,
                              color: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .color),
                        ),
                        Text(applicationEntity.summary),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (stateApplicationRecipeIdList
                          .contains(applicationEntity.id))
                        OverrideButton(
                            applicationEntity: applicationEntity,
                            handle: () {},
                            isActive: widget.isMain),
                      RemoveFromCartButton(
                          applicationEntity: applicationEntity,
                          handle: () {
                            widget.handleRemoveFromCart(applicationEntity.id);
                          },
                          isActive: widget.isMain)
                    ],
                  )
                ],
              ),
            ],
          ),
        ));
  }

  Widget getInstallAllButton() {
    return InstallAllButton(
      isActive: widget.isMain,
      handle: () {
        NavigationEntity.goToUpdatesAvailablesPocessingAll(
          handleGoTo: widget.handleGoTo,
        );
      },
    );
  }
}
