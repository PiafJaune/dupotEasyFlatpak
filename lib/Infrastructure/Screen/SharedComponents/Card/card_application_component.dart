import 'dart:io';

import 'package:dupot_easy_flatpak/Infrastructure/Entity/navigation_entity.dart';
import 'package:flutter/material.dart';

class CardApplicationComponent extends StatelessWidget {
  final String id;
  final String title;
  final String sumary;
  final String icon;
  final Function handleGoTo;

  const CardApplicationComponent(
      {super.key,
      required this.id,
      required this.title,
      required this.sumary,
      required this.icon,
      required this.handleGoTo});

  @override
  Widget build(BuildContext context) {
    if (icon.length > 10) {
      return InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: () {
            NavigationEntity.gotToApplicationId(
                handleGoTo: handleGoTo, applicationId: id);
          },
          child: Card(
              color: Theme.of(context).primaryColorLight,
              clipBehavior: Clip.hardEdge,
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                ListTile(
                  title: Text(
                    title.length > 8 ? '${title.substring(0, 8)}...' : title,
                    style: TextStyle(
                        fontSize: 20,
                        color:
                            Theme.of(context).textTheme.headlineLarge!.color),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                    child: Image.file(
                  File(icon),
                  width: 60,
                ))
              ])));
    }

    return Card(
        color: Theme.of(context).primaryColorLight,
        clipBehavior: Clip.hardEdge,
        child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          ListTile(
            title: Text(
              title.length > 8 ? '${title.substring(0, 8)}...' : title,
              style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).textTheme.headlineLarge!.color),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
              child: Image.asset(
            'assets/logos/512x512.png',
            width: 60,
          ))
        ]));
  }
}
