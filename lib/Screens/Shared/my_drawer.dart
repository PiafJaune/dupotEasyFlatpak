import 'package:dupot_easy_flatpak/Localizations/app_localizations.dart';
import 'package:dupot_easy_flatpak/Process/parameters.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer(
      {super.key,
      required this.version,
      required this.handleSetLocale,
      required this.handleSetUserScopeInstallation});

  final String version;
  Function handleSetLocale;
  Function handleSetUserScopeInstallation;

  @override
  Widget build(BuildContext context) {
    return Drawer(
        backgroundColor: Theme.of(context).primaryColorLight,
        child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Image.asset('assets/logos/512x512.png'),
              ),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    ListTile(
                      title: Text(
                        AppLocalizations().tr('Language'),
                        style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .color),
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        ListTile(
                          titleTextStyle: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .color),
                          title: Text(AppLocalizations().tr('English')),
                          leading: Radio<String>(
                            value: 'en',
                            groupValue: AppLocalizations().getLanguageCode(),
                            onChanged: (String? value) {
                              handleSetLocale('en');
                            },
                          ),
                        ),
                        ListTile(
                          titleTextStyle: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .color),
                          title: Text(AppLocalizations().tr('French')),
                          leading: Radio<String>(
                            value: 'fr',
                            groupValue: AppLocalizations().getLanguageCode(),
                            onChanged: (String? value) {
                              handleSetLocale('fr');
                            },
                          ),
                        ),
                        ListTile(
                          titleTextStyle: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .color),
                          title: Text(AppLocalizations().tr('Italian')),
                          leading: Radio<String>(
                            value: 'it',
                            groupValue: AppLocalizations().getLanguageCode(),
                            onChanged: (String? value) {
                              handleSetLocale('it');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListTile(
                      title: Text(
                        AppLocalizations().tr('Installation_scope'),
                        style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .color),
                      ),
                    ),
                    Column(children: <Widget>[
                      ListTile(
                        titleTextStyle: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .color),
                        title: Text(AppLocalizations().tr('scopeSystem')),
                        leading: Radio<bool>(
                          value: false,
                          groupValue:
                              Parameters().getUserInstallationScopeEnabled(),
                          onChanged: (bool? value) {
                            handleSetUserScopeInstallation(false);
                          },
                        ),
                      ),
                      ListTile(
                        titleTextStyle: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .textTheme
                                .headlineLarge!
                                .color),
                        title: Text(AppLocalizations().tr('scopeUser')),
                        leading: Radio<bool>(
                          value: true,
                          groupValue:
                              Parameters().getUserInstallationScopeEnabled(),
                          onChanged: (bool? value) {
                            handleSetUserScopeInstallation(true);
                          },
                        ),
                      ),
                    ]),
                    const SizedBox(height: 50),
                    Text(
                        '${AppLocalizations().tr('Author')}: Michael Bertocchi'),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      child: Text(
                          '${AppLocalizations().tr('Website')}: www.dupot.org'),
                      onPressed: () {
                        launchUrl(Uri.parse('https://www.dupot.org'));
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text('${AppLocalizations().tr('License')}:  LGPL-2.1'),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(version),
                  ]))
            ]) // Populate the Drawer in the next step.
        );
  }
}
