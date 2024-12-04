class NavigationEntity {
  static const String pageLoading = 'loading';
  static const String pageHome = 'home';
  static const String pageCategory = 'category';
  static const String pageApplication = 'application';

  static const String argumentApplicationId = 'applicationId';
  static const String argumentCategoryId = 'categoryId';

  static const String argumentSubPage = 'subPage';

  static const String argumentSubPageInstall = 'application_install';
  static const String argumentSubPageInstallWithRecipe =
      'application_installWithRecipe';

  static const String argumentSubPageUninstall = 'application_uninstall';
  static const String argumentSubPageUpdate = 'application_update';
  static const String argumentSubPageOverride = 'application_override';

  static goToHome({required Function handleGoTo}) {
    handleGoTo(page: pageHome, argumentMap: {'': ''});
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
      {required Function handleGoTo, required String applicationId}) {
    handleGoTo(page: pageApplication, argumentMap: {
      argumentApplicationId: applicationId,
      argumentSubPage: argumentSubPageUninstall
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