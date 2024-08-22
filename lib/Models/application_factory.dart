import 'dart:convert';
import 'dart:io';

import 'package:dupot_easy_flatpak/Localizations/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'application.dart';

class ApplicationFactory {
  static bool isDebug = true;

  static Future<List<String>> getApplicationList(context) async {
    String recipiesString =
        await DefaultAssetBundle.of(context).loadString("assets/recipies.json");
    List<String> recipieList = List<String>.from(json.decode(recipiesString));

    final directory = await getApplicationDocumentsDirectory();

    final subDirectory = Directory('${directory.path}/EasyFlatpak');

    if (await subDirectory.exists()) {
      var fileList = subDirectory.listSync();
      for (var fileLoop in fileList) {
        recipieList.add(
            path.basename(fileLoop.path).toString().replaceAll('.json', ''));
      }
    }

    if (isDebug) {
      print(recipieList);
    }

    return recipieList;
  }

  static Future<Application> getApplication(context, app) async {
    final languageCode = AppLocalizations.of(context).getLanguageCode();

    print('languageCode:$languageCode');

    final directory = await getApplicationDocumentsDirectory();

    final subDirectory = Directory('${directory.path}/EasyFlatpak');

    String applicaitonRecipieString = '';

    File userFile = File('${subDirectory.path}/$app.json');
    if (await userFile.exists()) {
      applicaitonRecipieString = await userFile.readAsString();
    } else {
      applicaitonRecipieString = await DefaultAssetBundle.of(context)
          .loadString("assets/recipies/$app.json");
    }

    Map jsonApp = json.decode(applicaitonRecipieString);

    List<dynamic> rawList = jsonApp['flatpakPermissionToOverrideList'];

    if (jsonApp.containsKey('description_$languageCode')) {
      jsonApp['description'] = jsonApp['description_$languageCode'];
    }

    List<Map<String, dynamic>> objectList = [];
    for (Map<String, dynamic> rawLoop in rawList) {
      if (rawLoop.containsKey('label_$languageCode')) {
        rawLoop['label'] = rawLoop['label_$languageCode'];
      }
      objectList.add(rawLoop);
    }

    Application applicationLoaded = Application(jsonApp['title'],
        jsonApp['description'], jsonApp['flatpak'], objectList);

    return applicationLoaded;
  }
}
