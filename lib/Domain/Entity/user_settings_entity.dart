import 'dart:convert';
import 'dart:io';

class UserSettingsEntity {
  int version = 1;

  String jsonUserSettingsPath = '';

  String applicationDataPath = '';
  String applicationIconPath = '';

  //language
  bool userOverrideLanguageCode = false; //if not: system
  String languageCode = 'en';

  //darkmode
  bool userOverrideDarkModeEnabled = false; //if not: system
  bool darkModeEnabled = false;

  //installation scope
  bool userInstallationScopeEnabled = false; //scope user/system

  //installed app
  bool displayApplicationInstalledNumberInSideMenu = false;
  bool displayApplicationInstalledNumberInPage = false;

  static final UserSettingsEntity _singleton = UserSettingsEntity._internal();

  factory UserSettingsEntity([String? newJsonUserSettingsPath]) {
    if (newJsonUserSettingsPath != null && newJsonUserSettingsPath.isNotEmpty) {
      _singleton.jsonUserSettingsPath = newJsonUserSettingsPath;
      File jsonParametersFile = File(_singleton.jsonUserSettingsPath);
      if (jsonParametersFile.existsSync()) {
        String jsonParameterString = jsonParametersFile.readAsStringSync();
        Map<String, dynamic> jsonParameterObj = jsonDecode(jsonParameterString);
        for (String mandatoryFieldLoop in [
          'version',
          'userOverrideLanguageCode',
          'languageCode',
          'userOverrideDarkModeEnabled',
          'darkModeEnabled',
          'userInstallationScopeEnabled',
          'displayApplicationInstalledNumberInSideMenu',
          'displayApplicationInstalledNumberInPage'
        ]) {
          if (!jsonParameterObj.containsKey(mandatoryFieldLoop)) {
            throw Exception(
                'Missing mandatory userSettings $mandatoryFieldLoop field in $newJsonUserSettingsPath');
          }
        }
        _singleton.version = jsonParameterObj['version'];
        _singleton.applicationDataPath =
            jsonParameterObj.containsKey('applicationDataPath')
                ? jsonParameterObj['applicationDataPath']
                : '';
        _singleton.userOverrideLanguageCode =
            jsonParameterObj['userOverrideLanguageCode'];
        _singleton.userOverrideDarkModeEnabled =
            jsonParameterObj['userOverrideDarkModeEnabled'];

        if (_singleton.userOverrideLanguageCode) {
          _singleton.languageCode = jsonParameterObj['languageCode'];
        }

        if (_singleton.userOverrideDarkModeEnabled) {
          _singleton.darkModeEnabled = jsonParameterObj['darkModeEnabled'];
        }

        _singleton.userInstallationScopeEnabled =
            jsonParameterObj['userInstallationScopeEnabled'];

        _singleton.displayApplicationInstalledNumberInSideMenu =
            jsonParameterObj['displayApplicationInstalledNumberInSideMenu'];

        _singleton.displayApplicationInstalledNumberInPage =
            jsonParameterObj['displayApplicationInstalledNumberInPage'];
      }
    }
    return _singleton;
  }

  UserSettingsEntity._internal();

  void setApplicationDataPath(String newApplicationDataPath) {
    applicationDataPath = newApplicationDataPath;
    applicationIconPath = "$applicationDataPath/icons";
  }

  String getApplicationDataPath() {
    return applicationDataPath;
  }

  String getApplicationIconsPath() {
    return applicationIconPath;
  }

  void setSystemDarkModeEnabled(bool newDarkModeEnabled) {
    if (!userOverrideDarkModeEnabled) {
      darkModeEnabled = newDarkModeEnabled;
    }
  }

  Future<void> setLanguageCode(String newLanguageCode) async {
    languageCode = newLanguageCode;
    await save();
  }

  Future<void> setDarkModeEnabled(bool newDarkModeEnabled) async {
    darkModeEnabled = newDarkModeEnabled;
    await save();
  }

  Future<void> setUserOverrideLanguageCode(
      bool userOverrideLanguageCode) async {
    this.userOverrideLanguageCode = userOverrideLanguageCode;
    await save();
  }

  Future<void> setUserOverrideDarkMode(bool userOverrideDarkModeEnabled) async {
    this.userOverrideDarkModeEnabled = userOverrideDarkModeEnabled;
    await save();
  }

  Future<void> setUserInstallationScopeEnabled(
      bool newUserInstallationScopeEnabled) async {
    userInstallationScopeEnabled = newUserInstallationScopeEnabled;
    await save();
  }

  Future<void> setDisplayApplicationInstalledNumberInSideMenu(
      bool displayApplicationInstalledNumberInSideMenu) async {
    this.displayApplicationInstalledNumberInSideMenu =
        displayApplicationInstalledNumberInSideMenu;
    await save();
  }

  Future<void> setDisplayApplicationInstalledNumberInPage(
      bool displayApplicationInstalledNumberInPage) async {
    this.displayApplicationInstalledNumberInPage =
        displayApplicationInstalledNumberInPage;
    await save();
  }

  String getActiveLanguageCode() {
    return getUserLanguageCode();
  }

  String getUserLanguageCode() {
    return languageCode;
  }

  bool getActiveDarkModeEnabled() {
    return getUserDarkModeEnabled();
  }

  bool getUserDarkModeEnabled() {
    return darkModeEnabled;
  }

  bool getUserInstallationScopeEnabled() {
    return userInstallationScopeEnabled;
  }

  String getInstallationScope() {
    if (userInstallationScopeEnabled) {
      return '--user';
    }
    return '--system';
  }

  bool getDisplayApplicationInstalledNumberInSideMenu() {
    return displayApplicationInstalledNumberInSideMenu;
  }

  bool getDisplayApplicationInstalledNumberInPage() {
    return displayApplicationInstalledNumberInPage;
  }

  Future<void> save() async {
    Map<String, dynamic> jsonParameterObj = {
      'version': version,
      'userOverrideLanguageCode': userOverrideLanguageCode,
      'languageCode': languageCode,
      'userOverrideDarkModeEnabled': userOverrideDarkModeEnabled,
      'darkModeEnabled': darkModeEnabled,
      'userInstallationScopeEnabled': userInstallationScopeEnabled,
      'displayApplicationInstalledNumberInSideMenu':
          displayApplicationInstalledNumberInSideMenu,
      'displayApplicationInstalledNumberInPage':
          displayApplicationInstalledNumberInPage
    };

    File jsonParameterFile = File(jsonUserSettingsPath);
    JsonEncoder encoder = JsonEncoder.withIndent('  ');
    jsonParameterFile.writeAsStringSync(encoder.convert(
      jsonParameterObj,
    ));
  }
}
