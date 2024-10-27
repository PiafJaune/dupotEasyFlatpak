import 'dart:io';

import 'package:dupot_easy_flatpak/Models/Flathub/appstream.dart';
import 'package:dupot_easy_flatpak/Models/Flathub/appstream_factory.dart';
import 'package:dupot_easy_flatpak/Models/settings.dart';
import 'package:dupot_easy_flatpak/Process/commands.dart';
import 'package:flutter/material.dart';

class InstalledAppsView extends StatefulWidget {
  final Function handleGoToApplication;
  const InstalledAppsView({
    super.key,
    required this.handleGoToApplication,
  });

  @override
  State<InstalledAppsView> createState() => _InstalledAppsViewState();
}

class _InstalledAppsViewState extends State<InstalledAppsView> {
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
    Commands commands = Commands();

    List<String> installedApplicationIdList =
        await commands.getInstalledApplicationList();

    AppStreamFactory appStreamFactory = AppStreamFactory();
    appPath = await appStreamFactory.getPath();

    List<AppStream> appStreamList = await appStreamFactory
        .findListAppStreamByIdList(installedApplicationIdList);

    setState(() {
      stateAppStreamList = appStreamList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        interactive: false,
        thumbVisibility: true,
        controller: scrollController,
        child: ListView.builder(
            itemCount: stateAppStreamList.length,
            controller: scrollController,
            itemBuilder: (context, index) {
              AppStream appStreamLoop = stateAppStreamList[index];

              String icon = appStreamLoop.icon;
              if (icon.length < 10) {
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
                    borderRadius: BorderRadius.circular(12.0),
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
                                  File('$appPath/${appStreamLoop.getIcon()}')),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      appStreamLoop.name,
                                      style: TextStyle(
                                          fontSize: 28,
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
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ));
              }
            }));
  }
}
