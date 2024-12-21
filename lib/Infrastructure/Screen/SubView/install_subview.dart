import 'dart:convert';
import 'dart:io';

import 'package:dupot_easy_flatpak/Domain/Entity/db/application_entity.dart';
import 'package:dupot_easy_flatpak/Domain/Entity/user_settings_entity.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Api/command_api.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Api/localization_api.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Entity/navigation_entity.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Repository/application_repository.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Button/close_subview_button.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Card/card_output_component.dart';
import 'package:flutter/material.dart';

class InstallSubview extends StatefulWidget {
  String applicationId;

  Function handleGoToApplication;

  InstallSubview({
    super.key,
    required this.applicationId,
    required this.handleGoToApplication,
  });

  @override
  State<InstallSubview> createState() => _InstallSubviewState();
}

class _InstallSubviewState extends State<InstallSubview> {
  bool stateIsInstalling = true;
  String stateInstallationOutput = '';

  String applicationIdSelected = '';

  String appPath = '';

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    install();
  }

  Future<void> install() async {
    applicationIdSelected = widget.applicationId;

    CommandApi command = CommandApi();

    String commandBin = 'flatpak';
    List<String> commandArgList = [
      'install',
      '-y',
      'flathub',
      UserSettingsEntity().getInstallationScope(),
      applicationIdSelected
    ];

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

      process.exitCode.then((exitCode) {
        print('Exit code: $exitCode');
        CommandApi().loadApplicationInstalledList();

        setState(() {
          stateIsInstalling = false;
        });
      });
    }).catchError((e) {
      print('Error starting process: $e');
    });
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle outputTextStyle =
        TextStyle(color: Colors.white, fontSize: 14.0);

    return Scrollbar(
      interactive: false,
      thumbVisibility: true,
      controller: scrollController,
      child: ListView(
        controller: scrollController,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(width: 20),
              stateIsInstalling
                  ? const CircularProgressIndicator()
                  : CloseSubViewButton(handle: widget.handleGoToApplication),
              const SizedBox(width: 20)
            ],
          ),
          CardOutputComponent(outputString: stateInstallationOutput),
          const SizedBox(
            height: 10,
          ),
          if (!stateIsInstalling)
            Center(child: Text(LocalizationApi().tr('installation_finished')))
        ],
      ),
    );
  }
}
