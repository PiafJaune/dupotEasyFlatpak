import 'package:dupot_easy_flatpak/Domain/Entity/db/application_entity.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Api/command_api.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Api/flathub_api.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Api/recipe_api.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Repository/application_repository.dart';

class ApplicationViewModel {
  Future<ApplicationEntity> getApplicationEntity(String appId) async {
    ApplicationRepository appStreamFactory = ApplicationRepository();

    ApplicationEntity applicationEntity =
        await appStreamFactory.findApplicationEntityById(appId);

    if (applicationEntity.lastUpdateIsOlderThan(7)) {
      print('update from api');
      await FlathubApi(applicationRepository: appStreamFactory)
          .updateAppStream(appId);

      applicationEntity =
          await appStreamFactory.findApplicationEntityById(appId);
    }

    applicationEntity.isAlreadyInstalled = await checkAlreadyInstalled(appId);
    applicationEntity.isOverrided = await checkIsOverrided(appId);

    applicationEntity.hasRecipe = await checkHasRecipe(appId);

    if (applicationEntity.isAlreadyInstalled) {
      applicationEntity.hasUpdate = await checkHasUpdate(appId);
    }

    return applicationEntity;
  }

  Future<bool> checkHasUpdate(String applicationId) async {
    if (CommandApi().hasUpdateAvailableByAppId(applicationId)) {
      return true;
    }
    return false;
  }

  Future<bool> checkHasRecipe(String applicationId) async {
    List<String> recipeList = await RecipeApi().getApplicationList();
    if (recipeList.contains(applicationId.toLowerCase())) {
      return true;
    }
    return false;
  }

  Future<bool> checkAlreadyInstalled(String applicationId) async {
    FlatpakApplication result =
        await CommandApi().isApplicationAlreadyInstalled(applicationId);

    return result.isInstalled;
  }

  Future<bool> checkIsOverrided(String applicationId) async {
    FlatpakOverrideApplication result =
        await CommandApi().isApplicationOverrided(applicationId);
    return result.isOverrided;
  }
}
