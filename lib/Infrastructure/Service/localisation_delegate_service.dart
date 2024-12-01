import 'package:dupot_easy_flatpak/Infrastructure/Api/localization_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LocalisationDelegateService
    extends LocalizationsDelegate<LocalizationApi> {
  const LocalisationDelegateService();

  @override
  bool isSupported(Locale locale) =>
      LocalizationApi.languages().contains(locale.languageCode);

  @override
  Future<LocalizationApi> load(Locale locale) {
    // Returning a SynchronousFuture here because an async "load" operation
    // isn't needed to produce an instance of AppLocalizations.

    return SynchronousFuture<LocalizationApi>(
        LocalizationApi(newLanguageCode: locale.languageCode));
  }

  @override
  bool shouldReload(LocalisationDelegateService old) => false;
}
