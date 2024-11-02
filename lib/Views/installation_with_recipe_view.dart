import 'dart:convert';
import 'dart:io';

import 'package:dupot_easy_flatpak/Localizations/app_localizations.dart';
import 'package:dupot_easy_flatpak/Models/Flathub/appstream.dart';
import 'package:dupot_easy_flatpak/Models/Flathub/appstream_factory.dart';
import 'package:dupot_easy_flatpak/Models/permission.dart';
import 'package:dupot_easy_flatpak/Models/recipe.dart';
import 'package:dupot_easy_flatpak/Models/recipe_factory.dart';
import 'package:dupot_easy_flatpak/Models/settings.dart';
import 'package:dupot_easy_flatpak/Process/commands.dart';
import 'package:dupot_easy_flatpak/Screens/Store/block.dart';
import 'package:dupot_easy_flatpak/Screens/Store/install_button.dart';
import 'package:dupot_easy_flatpak/Screens/Store/install_button_with_recipe.dart';
import 'package:dupot_easy_flatpak/Screens/Store/uninstall_button.dart';
import 'package:flutter/material.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

class InstallationWithRecipeView extends StatefulWidget {
  String applicationIdSelected;

  Function handleGoToApplication;

  InstallationWithRecipeView({
    super.key,
    required this.applicationIdSelected,
    required this.handleGoToApplication,
  });

  @override
  State<InstallationWithRecipeView> createState() =>
      _InstallationWithRecipeViewState();
}

class _InstallationWithRecipeViewState
    extends State<InstallationWithRecipeView> {
  AppStream? stateAppStream;
  bool stateIsInstalling = true;
  String stateInstallationOutput = '';

  String applicationIdSelected = '';

  String appPath = '';

  List<List<String>> processList = [[]];

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    loadSetupThenInstall();
  }

  Future<Recipe> getRecipe(String applicationId) async {
    Recipe recipe = await RecipeFactory().getApplication(applicationId);
    return recipe;
  }

  Future<bool> loadSetup(Recipe recipe) async {
    List<Permission> flatpakPermissionList =
        recipe.getFlatpakPermissionToOverrideList();

    for (Permission permissionLoop in flatpakPermissionList) {
      if (permissionLoop.isFileSystem()) {
        String directoryPath = await selectDirectory(permissionLoop.label);

        if (directoryPath.length < 2) {
          return false;
        }

        List<String> argList = [
          'override',
          '--user',
        ];
        argList.add(permissionLoop.getFlatpakOverrideType() + directoryPath);

        argList.add(recipe.id);

        processList.add(argList);
      } else if (permissionLoop.isFileSystemNoPrompt()) {
        String directoryPath = 'home';

        List<String> argList = [
          'override',
          '--user',
        ];
        argList.add(permissionLoop.getFlatpakOverrideType() + directoryPath);

        argList.add(recipe.id);

        processList.add(argList);
      }
    }

    return true;
  }

  Future<String> selectDirectory(String label) async {
    String? selectedDirectory = await prompt(context,
        title: Text(label),
        isSelectedInitialValue: false,
        textOK: Text(AppLocalizations().tr('confirm')),
        textCancel: Text(AppLocalizations().tr('cancel')),
        hintText: label, validator: (String? value) {
      if (value == null || value.isEmpty) {
        return AppLocalizations().tr('field_should_not_be_empty');
      }
      return null;
    });

    if (selectedDirectory == null) {
      return "";
    }

    return selectedDirectory;
  }

  void loadSetupThenInstall() async {
    applicationIdSelected = widget.applicationIdSelected;

    AppStreamFactory appStreamFactory = AppStreamFactory();
    appPath = await appStreamFactory.getPath();

    AppStream appStream =
        await appStreamFactory.findAppStreamById(applicationIdSelected);

    setState(() {
      stateAppStream = appStream;
    });

    Recipe recipe = await getRecipe(applicationIdSelected);

    loadSetup(recipe).then((isSetupOk) {
      if (isSetupOk) {
        install();
      }
    });
  }

  Future<void> install() async {
    Commands command = Commands();

    String commandBin = 'flatpak';
    List<String> commandArgList = [
      'install',
      '-y',
      '--system',
      applicationIdSelected
    ];

    String flatpakCommand = 'flatpak';

    Process.start(command.getCommand(commandBin),
            command.getFlatpakSpawnArgumentList(commandBin, commandArgList))
        .then((Process process) {
      process.stdout.transform(utf8.decoder).listen((data) {
        print('STDOUT: $data');
        setState(() {
          stateInstallationOutput = data;
        });
      });

      process.stderr.transform(utf8.decoder).listen((data) {
        print('STDERR: $data');
        setState(() {
          stateInstallationOutput = data;
        });
      });

      process.exitCode.then((exitCode) async {
        print('Exit code: $exitCode');

        for (List<String> argListLoop in processList) {
          await command.runProcess(flatpakCommand, argListLoop);
        }
        await Commands().loadApplicationInstalledList();

        setState(() {
          stateInstallationOutput =
              "$stateInstallationOutput \n ${AppLocalizations().tr('installation_finished')}";
          stateIsInstalling = false;
        });
      });
    }).catchError((e) {
      print('Error starting process: $e');
    });

    setState(() {
      stateInstallationOutput =
          "$stdout \n ${AppLocalizations().tr('installation_finished')}";
      stateIsInstalling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    RecipeFactory(context);

    const TextStyle outputTextStyle =
        TextStyle(color: Colors.white, fontSize: 14.0);

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
                          Image.file(
                              File('$appPath/${stateAppStream!.getAppIcon()}')),
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
                                style: const TextStyle(
                                    fontStyle: FontStyle.italic),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              stateAppStream!.isVerified()
                                  ? TextButton.icon(
                                      style: TextButton.styleFrom(
                                          padding: const EdgeInsets.only(
                                              top: 5,
                                              bottom: 5,
                                              right: 5,
                                              left: 0),
                                          alignment:
                                              AlignmentDirectional.topStart),
                                      icon: const Icon(Icons.verified),
                                      onPressed: () {},
                                      label: Text(
                                          stateAppStream!.getVerifiedLabel()))
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                        stateIsInstalling
                            ? const CircularProgressIndicator()
                            : getButton()
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                          constraints: const BoxConstraints(minHeight: 800),
                          decoration:
                              const BoxDecoration(color: Colors.blueGrey),
                          child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: RichText(
                                overflow: TextOverflow.clip,
                                text: TextSpan(
                                  style: outputTextStyle,
                                  children: <TextSpan>[
                                    TextSpan(text: stateInstallationOutput),
                                  ],
                                ),
                              ))),
                    ),
                  ],
                ),
              ));
  }

  Widget getButton() {
    ButtonStyle buttonStyle = ElevatedButton.styleFrom(
        backgroundColor: Colors.blueGrey,
        padding: const EdgeInsets.all(20),
        textStyle: const TextStyle(fontSize: 14));

    return FilledButton.icon(
      style: buttonStyle,
      onPressed: () {
        widget.handleGoToApplication(widget.applicationIdSelected);
      },
      label: Text(AppLocalizations().tr('close')),
      icon: const Icon(Icons.close),
    );
  }
}
