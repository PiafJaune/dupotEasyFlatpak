import 'dart:io';

import 'package:dupot_easy_flatpak/Localizations/app_localizations.dart';
import 'package:dupot_easy_flatpak/Models/Flathub/appstream.dart';
import 'package:dupot_easy_flatpak/Models/Flathub/appstream_factory.dart';
import 'package:dupot_easy_flatpak/Process/commands.dart';
import 'package:flutter/material.dart';

class UpdatesAvailablesAppsView extends StatefulWidget {
  final Function handleGoToApplication;
  const UpdatesAvailablesAppsView({
    super.key,
    required this.handleGoToApplication,
  });

  @override
  State<UpdatesAvailablesAppsView> createState() =>
      _UpdatesAvailablesAppsViewState();
}

class _UpdatesAvailablesAppsViewState extends State<UpdatesAvailablesAppsView> {
  List<AppStream> stateAppStreamList = [];
  String appPath = '';

  String stateSearch = '';

  String lastCategoryIdSelected = '';

  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    AppStreamFactory appStreamFactory = AppStreamFactory();
    appPath = await appStreamFactory.getPath();

    print(Commands().getAppIdUpdateAvailableList());

    List<AppStream> appStreamList = await appStreamFactory
        .findListAppStreamByIdList(Commands().getAppIdUpdateAvailableList());

    setState(() {
      stateAppStreamList = appStreamList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return stateAppStreamList.isEmpty
        ? Center(
            child: Text(
            AppLocalizations().tr('NoUpdates'),
          ))
        : Scrollbar(
            interactive: false,
            thumbVisibility: true,
            controller: scrollController,
            child: ListView.builder(
                itemCount: stateAppStreamList.length,
                controller: scrollController,
                itemBuilder: (context, index) {
                  AppStream appStreamLoop = stateAppStreamList[index];

                  if (!appStreamLoop.hasAppIcon()) {
                    return Card(
                      child: Column(
                        children: [
                          ListTile(
                              title: Text(
                            stateAppStreamList[index].id,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .headlineLarge!
                                    .color),
                          )),
                        ],
                      ),
                    );
                  } else {
                    return InkWell(
                        borderRadius: BorderRadius.circular(10.0),
                        onTap: () {
                          widget.handleGoToApplication(appStreamLoop.id);
                        },
                        child: Card(
                          color: Theme.of(context).cardColor,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 10),
                                  Image.file(
                                      height: 80,
                                      File(
                                          '$appPath/${appStreamLoop.getAppIcon()}')),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          appStreamLoop.name,
                                          style: TextStyle(
                                              fontSize: 32,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .headlineLarge!
                                                  .color),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          appStreamLoop.summary,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(Commands().getAppUpdateVersionByAppId(
                                      appStreamLoop.id)),
                                  const SizedBox(width: 20),
                                ],
                              ),
                            ],
                          ),
                        ));
                  }
                }));
  }
}
