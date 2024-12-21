import 'dart:convert';
import 'dart:io';

import 'package:dupot_easy_flatpak/Domain/Entity/db/application_entity.dart';
import 'package:dupot_easy_flatpak/Domain/Entity/user_settings_entity.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Api/command_api.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Api/localization_api.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Api/recipe_api.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Control/Model/SubView/override_control.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Entity/override_form_control.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Repository/application_repository.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Button/close_subview_button.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Card/card_output_component.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/Theme/theme_button_style.dart';
import 'package:flutter/material.dart';
import 'package:prompt_dialog/prompt_dialog.dart';

class InstallWithRecipeSubview extends StatefulWidget {
  String applicationId;

  Function handleGoToApplication;

  InstallWithRecipeSubview({
    super.key,
    required this.applicationId,
    required this.handleGoToApplication,
  });

  @override
  State<InstallWithRecipeSubview> createState() =>
      _InstallationWithRecipeViewState();
}

class _InstallationWithRecipeViewState extends State<InstallWithRecipeSubview> {
  ApplicationEntity? stateApplicationEntity;
  bool stateIsInstalling = false;
  bool stateDisplayInstallButton = true;
  String stateInstallationOutput = '';

  String applicationId = '';

  String appPath = '';

  List<List<String>> processList = [[]];

  final ScrollController scrollController = ScrollController();

  List<OverrideFormControl> stateOverrideFormControlList = [];

  late OverrideControl overrideControl;

  bool stateIsLoaded = true;

  String stateSubContent = staticSubContentForm;

  static const String staticSubContentForm = 'subContentForm';
  static const String staticSubContentInstall = 'subContentInstall';

  @override
  void initState() {
    RecipeApi();

    super.initState();
  }

  Future<void> loadData() async {
    applicationId = widget.applicationId;
    ApplicationRepository appStreamFactory = ApplicationRepository();

    ApplicationEntity appStream =
        await appStreamFactory.findApplicationEntityById(applicationId);

    await loadApplicationRecipeOverride(applicationId);

    setState(() {
      stateApplicationEntity = appStream;
    });
  }

  Future<void> loadApplicationRecipeOverride(String applicationId) async {
    overrideControl = OverrideControl();
    List<OverrideFormControl> overrideFormControlList = await overrideControl
        .getOverrideControlWithoutConfigList(applicationId);

    setState(() {
      stateOverrideFormControlList = overrideFormControlList;
      stateIsLoaded = false;
    });
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  Future<String> selectDirectory(String label) async {
    String? selectedDirectory = await prompt(context,
        title: Text(label),
        isSelectedInitialValue: false,
        textOK: Text(LocalizationApi().tr('confirm')),
        textCancel: Text(LocalizationApi().tr('cancel')),
        hintText: label, validator: (String? value) {
      if (value == null || value.isEmpty) {
        return LocalizationApi().tr('field_should_not_be_empty');
      }
      return null;
    });

    if (selectedDirectory == null) {
      return "";
    }

    return selectedDirectory;
  }

  Future<void> install() async {
    setState(() {
      stateIsInstalling = true;
    });

    CommandApi command = CommandApi();

    String commandBin = 'flatpak';
    List<String> commandArgList = [
      'install',
      '-y',
      'flathub',
      UserSettingsEntity().getInstallationScope(),
      applicationId
    ];

    String flatpakCommand = 'flatpak';

    Process.start(command.getCommand(commandBin),
            command.getFlatpakSpawnArgumentList(commandBin, commandArgList))
        .then((Process process) {
      process.stdout.transform(utf8.decoder).listen((data) {
        print('STDOUT: $data');
        if (mounted) {
          setState(() {
            stateInstallationOutput = data;
          });
        }
      });

      process.stderr.transform(utf8.decoder).listen((data) {
        print('STDERR: $data');
        setState(() {
          stateInstallationOutput = data;
        });
      });

      process.exitCode.then((exitCode) async {
        print('Exit code: $exitCode');

        await overrideControl.save(applicationId, stateOverrideFormControlList);
        await CommandApi().loadApplicationInstalledList();

        setState(() {
          stateInstallationOutput =
              "$stateInstallationOutput \n ${LocalizationApi().tr('installation_finished')}";
          stateIsInstalling = false;
        });
      });
    }).catchError((e) {
      print('Error starting process: $e');
    });
  }

  Widget getSubContent() {
    if (stateSubContent == staticSubContentForm) {
      return getSubContentForm();
    } else {
      return getSubContentInstall();
    }
  }

  Widget getSubContentForm() {
    return Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 800),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: stateOverrideFormControlList
                    .map((OverrideFormControl stateOverrideFormControlLoop) {
                  if (stateOverrideFormControlLoop.isTypeFileSystem()) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stateOverrideFormControlLoop.label,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        TextField(
                          controller: stateOverrideFormControlLoop
                              .textEditingController,
                        )
                      ],
                    );
                  } else if (stateOverrideFormControlLoop
                          .isTypeInstallFlatpak() ||
                      stateOverrideFormControlLoop.isTypeEnv()) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(stateOverrideFormControlLoop.label,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            Switch(
                              value: stateOverrideFormControlLoop.boolValue,
                              onChanged: (bool value) {
                                stateOverrideFormControlLoop.boolValue = value;

                                List<OverrideFormControl>
                                    tmpOverrideFormControlList =
                                    stateOverrideFormControlList;

                                setState(() {
                                  stateOverrideFormControlList =
                                      tmpOverrideFormControlList;
                                });
                              },
                            ),
                            Text(LocalizationApi().tr('Yes'))
                          ],
                        )
                      ],
                    );
                  } else {
                    return const SizedBox();
                  }
                }).toList()),
          ),
        ));
  }

  Widget getSubContentInstall() {
    return CardOutputComponent(outputString: stateInstallationOutput);
  }

  @override
  Widget build(BuildContext context) {
    return stateApplicationEntity == null
        ? const CircularProgressIndicator()
        : Scrollbar(
            interactive: false,
            thumbVisibility: true,
            controller: scrollController,
            child: ListView(
              controller: scrollController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    getInstallButton(),
                    const SizedBox(width: 20),
                    stateIsInstalling
                        ? const CircularProgressIndicator()
                        : CloseSubViewButton(
                            handle: widget.handleGoToApplication),
                    const SizedBox(width: 20)
                  ],
                ),
                getSubContent()
              ],
            ),
          );
  }

  Widget getInstallButton() {
    if (stateIsInstalling | !stateDisplayInstallButton) {
      return SizedBox();
    }

    return FilledButton.icon(
      style: ThemeButtonStyle(context: context).getButtonStyle(),
      onPressed: () {
        install();
        setState(() {
          stateDisplayInstallButton = false;
          stateSubContent = staticSubContentInstall;
        });
      },
      label: Text(LocalizationApi().tr('install')),
      icon: const Icon(Icons.install_desktop),
    );
  }
}
