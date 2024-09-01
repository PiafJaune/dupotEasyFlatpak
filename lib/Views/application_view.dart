import 'dart:io';

import 'package:dupot_easy_flatpak/Models/Flathub/appstream.dart';
import 'package:dupot_easy_flatpak/Models/Flathub/appstream_factory.dart';
import 'package:dupot_easy_flatpak/Models/recipe_factory.dart';
import 'package:dupot_easy_flatpak/Models/settings.dart';
import 'package:dupot_easy_flatpak/Process/commands.dart';
import 'package:dupot_easy_flatpak/Screens/Store/block.dart';
import 'package:dupot_easy_flatpak/Screens/Store/install_button.dart';
import 'package:dupot_easy_flatpak/Screens/Store/install_button_with_recipe.dart';
import 'package:dupot_easy_flatpak/Screens/Store/uninstall_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

class ApplicationView extends StatefulWidget {
  String applicationIdSelected;

  Function handleGoToInstallation;
  Function handleGoToInstallationWithRecipe;
  Function handleGoToUninstallation;

  ApplicationView({
    super.key,
    required this.applicationIdSelected,
    required this.handleGoToInstallation,
    required this.handleGoToInstallationWithRecipe,
    required this.handleGoToUninstallation,
  });

  @override
  State<ApplicationView> createState() => _ApplicationViewState();
}

class _ApplicationViewState extends State<ApplicationView> {
  AppStream? stateAppStream;
  bool stateIsAlreadyInstalled = false;
  bool stateHasRecipe = false;

  String applicationIdSelected = '';

  String appPath = '';

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    applicationIdSelected = widget.applicationIdSelected;
    AppStreamFactory appStreamFactory = AppStreamFactory();
    appPath = await appStreamFactory.getPath();

    AppStream appStream =
        await appStreamFactory.findAppStreamById(applicationIdSelected);

    checkAlreadyInstalled(context, applicationIdSelected);

    checkHasRecipe(applicationIdSelected, context);

    setState(() {
      stateAppStream = appStream;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (applicationIdSelected != widget.applicationIdSelected) {
      loadData();
    }

    return Card(
      child: stateAppStream == null
          ? const CircularProgressIndicator()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (stateAppStream!.icon.length > 10)
                      Image.file(File('$appPath/${stateAppStream!.getIcon()}')),
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
                            stateAppStream!.developer_name,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (stateAppStream!.isVerified())
                            TextButton.icon(
                                style: TextButton.styleFrom(
                                    padding: const EdgeInsets.only(
                                        top: 5, bottom: 5, right: 5, left: 0),
                                    alignment: AlignmentDirectional.topStart),
                                icon: const Icon(Icons.verified),
                                onPressed: () {},
                                label: Text(stateAppStream!.getVerifiedLabel()))
                        ],
                      ),
                    ),
                    getButton()
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stateAppStream!.summary,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        HtmlWidget(
                          stateAppStream!.description,
                        ),
                      ],
                    )),
                const ListTile(
                    title: Text(
                  'Links',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
                Padding(
                    padding: const EdgeInsets.only(
                        top: 5, bottom: 5, right: 5, left: 10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            stateAppStream!.getUrlObjList().map((urlObjLoop) {
                          return TextButton.icon(
                            icon: getIcon(urlObjLoop['key'].toString()),
                            onPressed: () {},
                            label: Text(urlObjLoop['value'].toString()),
                          );
                        }).toList()))
              ],
            ),
    );
  }

  Widget getButton() {
    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
        padding: const EdgeInsets.all(20),
        textStyle: const TextStyle(fontSize: 14));

    final ButtonStyle dialogButtonStyle = FilledButton.styleFrom(
        backgroundColor: Colors.grey,
        padding: const EdgeInsets.all(20),
        textStyle: const TextStyle(fontSize: 14));

    if (stateIsAlreadyInstalled) {
      return UninstallButton(
          buttonStyle: buttonStyle,
          dialogButtonStyle: dialogButtonStyle,
          stateAppStream: stateAppStream,
          handle: widget.handleGoToUninstallation);
    } else if (stateHasRecipe) {
      return InstallWithRecipeButton(
          buttonStyle: buttonStyle,
          dialogButtonStyle: dialogButtonStyle,
          stateAppStream: stateAppStream,
          handle: widget.handleGoToInstallationWithRecipe);
    }

    return InstallButton(
      buttonStyle: buttonStyle,
      dialogButtonStyle: dialogButtonStyle,
      stateAppStream: stateAppStream,
      handle: widget.handleGoToInstallation,
    );
  }

  Widget getIcon(String type) {
    if (type == 'homepage') {
      return Icon(Icons.home);
    } else if (type == 'bugtracker') {
      return Icon(Icons.bug_report);
    }
    return Icon(Icons.ac_unit);
  }

  void checkHasRecipe(String applicationId, context) async {
    List<String> recipeList = await RecipeFactory.getApplicationList(context);
    if (recipeList.contains(applicationId.toLowerCase())) {
      setState(() {
        stateHasRecipe = true;
      });
    }
  }

  void checkAlreadyInstalled(BuildContext context, String applicationId) async {
    Settings settingsObj = Settings(context: context);
    await settingsObj.load();

    Commands(settingsObj: settingsObj)
        .isApplicationAlreadyInstalled(applicationId)
        .then((flatpakApplication) {
      setState(() {
        stateIsAlreadyInstalled = flatpakApplication.isInstalled;
      });
    });
  }
}