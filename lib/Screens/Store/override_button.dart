import 'package:dupot_easy_flatpak/Localizations/app_localizations.dart';
import 'package:dupot_easy_flatpak/Models/Flathub/appstream.dart';
import 'package:dupot_easy_flatpak/Process/commands.dart';
import 'package:flutter/material.dart';

class OverrideButton extends StatelessWidget {
  const OverrideButton(
      {super.key, required this.buttonStyle, required this.stateAppStream});

  final ButtonStyle buttonStyle;
  final AppStream? stateAppStream;

  Future<void> run(String applicationId) async {
    Commands commands = Commands();
    commands.run(applicationId);
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: buttonStyle,
      onPressed: () {
        run(stateAppStream!.id);
      },
      label: Text(AppLocalizations().tr('Edit_override')),
      icon: const Icon(Icons.settings),
    );
  }
}