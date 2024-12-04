import 'dart:io';

import 'package:dupot_easy_flatpak/Domain/Entity/db/application_entity.dart';
import 'package:dupot_easy_flatpak/Domain/Entity/user_settings_entity.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Api/localization_api.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Control/Model/View/application_view_model.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Entity/navigation_entity.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Button/install_button.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Button/install_with_recipe_button.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Button/override_button.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Button/run_button.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Button/uninstall_button.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Button/update_button.dart';
import 'package:flutter/material.dart';

import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationView extends StatefulWidget {
  String applicationIdSelected;

  Function handleGoTo;

  ApplicationView({
    super.key,
    required this.applicationIdSelected,
    required this.handleGoTo,
  });

  void goToInstallation() {
    NavigationEntity.goToApplicationInstall(
        handleGoTo: handleGoTo, applicationId: applicationIdSelected);
  }

  void goToInstallationWithRecipe() {
    NavigationEntity.goToApplicationInstallWithRecipe(
        handleGoTo: handleGoTo, applicationId: applicationIdSelected);
  }

  void goToUninstallation() {
    NavigationEntity.goToApplicationUninstall(
        handleGoTo: handleGoTo, applicationId: applicationIdSelected);
  }

  void goToUpdate() {
    NavigationEntity.goToApplicationUpdate(
        handleGoTo: handleGoTo, applicationId: applicationIdSelected);
  }

  void goToOverride() {
    NavigationEntity.goToApplicationOverride(
        handleGoTo: handleGoTo, applicationId: applicationIdSelected);
  }

  @override
  State<ApplicationView> createState() => _ApplicationViewState();
}

class _ApplicationViewState extends State<ApplicationView> {
  ApplicationEntity? stateAppStream;
  bool stateIsAlreadyInstalled = false;
  bool stateHasRecipe = false;

  bool stateIsOverrided = false;

  String applicationIdSelected = '';

  String appPath = '';

  final ScrollController scrollController = ScrollController();

  final ScrollController scrollControllerScreenshot = ScrollController();

  @override
  void initState() {
    loadData();

    super.initState();
  }

  Future<void> loadData() async {
    applicationIdSelected = widget.applicationIdSelected;

    ApplicationEntity appStream = await ApplicationViewModel()
        .getApplicationEntity(applicationIdSelected);

    setState(() {
      stateAppStream = appStream;
    });
  }

  ButtonStyle getButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        padding: const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        textStyle: const TextStyle(fontSize: 14, color: Colors.white));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Theme.of(context).cardColor,
        child: stateAppStream == null
            ? const CircularProgressIndicator()
            : Scrollbar(
                interactive: false,
                thumbVisibility: true,
                controller: scrollController,
                child: ListView(
                  controller: scrollController,
                  children: [
                    Row(
                      children: [
                        if (stateAppStream!.hasAppIcon())
                          Padding(
                              padding: const EdgeInsets.all(20),
                              child: Image.file(File(
                                  '${UserSettingsEntity().getApplicationIconsPath()}/${stateAppStream!.getAppIcon()}'))),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                stateAppStream!.name,
                                style: const TextStyle(
                                    fontSize: 35, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                '${LocalizationApi().tr('By')} ${stateAppStream!.developer_name}',
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic, fontSize: 15),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (stateAppStream!.projectLicense.isNotEmpty)
                                Text(
                                    '${LocalizationApi().tr('License')}: ${stateAppStream!.projectLicense}'),
                              const SizedBox(
                                height: 10,
                              ),
                              if (stateAppStream!.isVerified())
                                TextButton.icon(
                                    style: TextButton.styleFrom(
                                        padding: const EdgeInsets.only(
                                            top: 5,
                                            bottom: 5,
                                            right: 5,
                                            left: 0),
                                        alignment:
                                            AlignmentDirectional.topStart),
                                    icon: const Icon(Icons.verified),
                                    onPressed: () {
                                      String verifiedUrl =
                                          stateAppStream!.getVerifiedUrl();
                                      if (verifiedUrl.isNotEmpty) {
                                        launchUrl(Uri.parse(verifiedUrl));
                                      }
                                    },
                                    label: Text(
                                        stateAppStream!.getVerifiedLabel())),
                            ],
                          ),
                        ),
                        getOverrideButton(stateAppStream!.isOverrided),
                        const SizedBox(width: 5),
                        getInstallButton(stateAppStream!.isAlreadyInstalled,
                            stateAppStream!.hasRecipe),
                        const SizedBox(width: 5),
                        getRunButton(stateAppStream!.isAlreadyInstalled),
                        const SizedBox(width: 5),
                        getUpdateButton(),
                        const SizedBox(width: 10)
                      ],
                    ),
                    if (stateAppStream!.screenshotObjList.isNotEmpty)
                      ListTile(
                        title: Text(LocalizationApi().tr('Screenshots'),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .headlineLarge!
                                    .color)),
                      ),
                    if (stateAppStream!.screenshotObjList.isNotEmpty)
                      Padding(
                          padding: const EdgeInsets.all(20),
                          child: Scrollbar(
                              interactive: false,
                              thumbVisibility: true,
                              controller: scrollControllerScreenshot,
                              child: SingleChildScrollView(
                                  controller: scrollControllerScreenshot,
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                      children: stateAppStream!
                                          .screenshotObjList
                                          .map((screenshotLoop) {
                                    return IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                  buttonPadding:
                                                      const EdgeInsets.all(0),
                                                  content: Image.network(
                                                      screenshotLoop[
                                                          'large'])));
                                        },
                                        icon: Image.network(
                                            screenshotLoop['preview']));
                                  }).toList())))),
                    Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stateAppStream!.summary,
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .headlineLarge!
                                      .color),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            HtmlWidget(
                              stateAppStream!.description,
                            ),
                          ],
                        )),
                    ListTile(
                        title: Text(
                      LocalizationApi().tr('Last_releases'),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).textTheme.headlineLarge!.color),
                    )),
                    Padding(
                        padding: const EdgeInsets.only(
                            top: 5, bottom: 5, right: 5, left: 25),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: stateAppStream!
                                .getReleaseObjList()
                                .map((realeaseObjLoop) {
                              DateTime dateVersion =
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(realeaseObjLoop['timestamp']) *
                                          1000);

                              return Row(children: [
                                Text(DateFormat('dd/MM/yyyy')
                                    .format(dateVersion)),
                                const SizedBox(width: 2),
                                const Text(':'),
                                const SizedBox(width: 10),
                                Text(realeaseObjLoop['version'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold))
                              ]);
                            }).toList())),
                    ListTile(
                        title: Text(
                      LocalizationApi().tr('Links'),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:
                              Theme.of(context).textTheme.headlineLarge!.color),
                    )),
                    Padding(
                        padding: const EdgeInsets.only(
                            top: 5, bottom: 5, right: 5, left: 10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: stateAppStream!
                                .getUrlObjList()
                                .map((urlObjLoop) {
                              String url = urlObjLoop['value'].toString();

                              return TextButton.icon(
                                icon: getIcon(urlObjLoop['key'].toString()),
                                onPressed: () {
                                  launchUrl(Uri.parse(url));
                                },
                                label: Text(url),
                              );
                            }).toList()))
                  ],
                ),
              ));
  }

  Widget getOverrideButton(bool isOverrided) {
    return isOverrided
        ? OverrideButton(
            applicationEntity: stateAppStream!, handle: widget.handleGoTo)
        : SizedBox();
  }

  Widget getInstallButton(bool isAlreadyInstalled, bool hasRecipe) {
    if (isAlreadyInstalled) {
      return UninstallButton(
          applicationEntity: stateAppStream!, handle: widget.handleGoTo);
    }

    if (hasRecipe) {
      return InstallWithRecipeButton(
          applicationEntity: stateAppStream!, handle: widget.handleGoTo);
    } else {
      return InstallButton(
          applicationEntity: stateAppStream!, handle: widget.handleGoTo);
    }
  }

  Widget getRunButton(bool isAlreadyInstalled) {
    return isAlreadyInstalled
        ? RunButton(
            applicationEntity: stateAppStream!,
          )
        : SizedBox();
  }

  Widget getUpdateButton() {
    if (stateAppStream!.hasUpdate) {
      return UpdateButton(
          applicationEntity: stateAppStream!, handle: widget.handleGoTo);
    }

    return SizedBox();
  }

  Widget getIcon(String type) {
    if (type == 'homepage') {
      return const Icon(Icons.home);
    } else if (type == 'bugtracker') {
      return const Icon(Icons.bug_report);
    }
    return const Icon(Icons.ac_unit);
  }
}
