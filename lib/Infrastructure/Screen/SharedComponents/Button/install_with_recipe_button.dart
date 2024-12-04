import 'package:dupot_easy_flatpak/Domain/Entity/db/application_entity.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Api/localization_api.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Button/dialog_cancel_button.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Button/dialog_confirm_button.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/Theme/theme_button_style.dart';
import 'package:flutter/material.dart';

class InstallWithRecipeButton extends StatelessWidget {
  InstallWithRecipeButton(
      {super.key, required this.applicationEntity, required this.handle});

  ApplicationEntity applicationEntity;
  Function handle;

  @override
  Widget build(BuildContext context) {
    ThemeButtonStyle themeButtonStyle = ThemeButtonStyle(context: context);

    return FilledButton.icon(
      style: themeButtonStyle.getButtonStyle(),
      onPressed: () {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  backgroundColor: Theme.of(context).primaryColorLight,
                  buttonPadding: const EdgeInsets.all(10),
                  actions: [
                    const DialogCancelButton(),
                    DialogConfirmButton(onPressedFunction: () {
                      Navigator.of(context).pop();

                      handle(applicationEntity.id);
                    })
                  ],
                  title: Text(LocalizationApi().tr('confirmation_title')),
                  contentPadding: const EdgeInsets.all(20.0),
                  content: Text(
                      '${LocalizationApi().tr('do_you_confirm_installation_of')} ${applicationEntity.name} ?'),
                ));
      },
      label: Text(LocalizationApi().tr('install_with_recipe')),
      icon: const Icon(Icons.install_desktop),
    );
  }
}