class NavigationEntity {
  static const String pageLoading = 'loading';
  static const String pageHome = 'home';
  static const String pageCategory = 'category';
  static const String pageApplication = 'application';
  static const String pageInstalledApplication = 'installedApps';
  static const String pageSearch = 'search';

  static const String argumentApplicationId = 'applicationId';
  static const String argumentCategoryId = 'categoryId';

  static const String argumentSubPage = 'subPage';

  static const String argumentSubPageInstall = 'application_install';
  static const String argumentSubPageInstallWithRecipe =
      'application_installWithRecipe';
  static const String argumentSubPageUninstall = 'application_uninstall';
  static const String argumentSubPageUpdate = 'application_update';
  static const String argumentSubPageOverride = 'application_override';

  static const String argumentSearch = 'search';

  static goToHome({required Function handleGoTo}) {
    handleGoTo(page: pageHome, argumentMap: {'': ''});
  }

  static goToSearch({required Function handleGoTo, required String search}) {
    handleGoTo(page: pageSearch, argumentMap: {argumentSearch: search});
  }

  static goToInstalledApplications({required Function handleGoTo}) {
    handleGoTo(page: pageInstalledApplication, argumentMap: {'': ''});
  }

  static extractArgumentApplicationId(Map<String, String> argumentMap) {
    return argumentMap[argumentApplicationId];
  }

  static extractArgumentCategoryId(Map<String, String> argumentMap) {
    return argumentMap[argumentCategoryId];
  }

  static extractArgumentSubPage(Map<String, String> argumentMap) {
    return argumentMap[argumentSubPage];
  }

  static hasArgumentSearch(Map<String, String> argumentMap) {
    return argumentMap.containsKey(argumentSearch);
  }

  static extractArgumentSearch(Map<String, String> argumentMap) {
    return argumentMap[argumentSearch];
  }

  static gotToApplicationId(
      {required Function handleGoTo, required String applicationId}) {
    handleGoTo(
        page: pageApplication,
        argumentMap: {argumentApplicationId: applicationId});
  }

  static gotToCategoryId(
      {required Function handleGoTo, required String categoryId}) {
    handleGoTo(
        page: pageCategory, argumentMap: {argumentCategoryId: categoryId});
  }

  static goToApplicationInstall(
      {required Function handleGoTo, required String applicationId}) {
    handleGoTo(page: pageApplication, argumentMap: {
      argumentApplicationId: applicationId,
      argumentSubPage: argumentSubPageInstall
    });
  }

  static goToApplicationInstallWithRecipe(
      {required Function handleGoTo, required String applicationId}) {
    handleGoTo(page: pageApplication, argumentMap: {
      argumentApplicationId: applicationId,
      argumentSubPage: argumentSubPageInstallWithRecipe
    });
  }

  static goToApplicationUninstall(
      {required Function handleGoTo,
      required String applicationId,
      required bool willDeleteAppData}) {
    handleGoTo(page: pageApplication, argumentMap: {
      argumentApplicationId: applicationId,
      argumentSubPage: argumentSubPageUninstall,
      if (willDeleteAppData) 'willDeleteAppData': 'yes'
    });
  }

  static goToApplicationUpdate(
      {required Function handleGoTo, required String applicationId}) {
    handleGoTo(page: pageApplication, argumentMap: {
      argumentApplicationId: applicationId,
      argumentSubPage: argumentSubPageUpdate
    });
  }

  static goToApplicationOverride(
      {required Function handleGoTo, required String applicationId}) {
    handleGoTo(page: pageApplication, argumentMap: {
      argumentApplicationId: applicationId,
      argumentSubPage: argumentSubPageOverride
    });
  }
}
