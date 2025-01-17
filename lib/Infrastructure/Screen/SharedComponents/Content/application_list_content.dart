import 'package:dupot_easy_flatpak/Domain/Entity/db/application_entity.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/List/grid_application_list_component.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/List/listview_application_list_component.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/Theme/theme_button_style.dart';
import 'package:flutter/material.dart';

class ApplicationListContent extends StatefulWidget {
  ApplicationListContent(
      {super.key,
      required this.applicationEntityList,
      required this.handleGoTo});

  Function handleGoTo;
  List<ApplicationEntity> applicationEntityList = [];

  @override
  State<ApplicationListContent> createState() => _ApplicationListContentState();
}

enum AppDisplay { list, grid }

const List<(AppDisplay, IconData)> appDisplayOptions = <(AppDisplay, IconData)>[
  (AppDisplay.list, Icons.view_list),
  (AppDisplay.grid, Icons.view_compact),
];

class _ApplicationListContentState extends State<ApplicationListContent> {
  ScrollController scrollController = ScrollController();

  Set<AppDisplay> _segmentedButtonSelection = <AppDisplay>{AppDisplay.list};

  @override
  Widget build(BuildContext context) {
    ThemeButtonStyle themeButtonStyle = ThemeButtonStyle(context: context);

    return Scrollbar(
        interactive: false,
        thumbVisibility: true,
        controller: scrollController,
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(children: [
                  const Expanded(child: SizedBox()),
                  SegmentedButton<AppDisplay>(
                    style: themeButtonStyle.getSegmentedButtonStyle(),
                    // ToggleButtons above allows multiple or no selection.
                    // Set `multiSelectionEnabled` and `emptySelectionAllowed` to true
                    // to match the behavior of ToggleButtons.
                    multiSelectionEnabled: false,
                    emptySelectionAllowed: false,

                    // Hide the selected icon to match the behavior of ToggleButtons.
                    showSelectedIcon: true,
                    // SegmentedButton uses a Set<T> to track its selection state.
                    selected: _segmentedButtonSelection,
                    // This callback updates the set of selected segment values.
                    onSelectionChanged: (Set<AppDisplay> newSelection) {
                      setState(() {
                        _segmentedButtonSelection = newSelection;
                      });
                    },
                    // SegmentedButton uses a List<ButtonSegment<T>> to build its children
                    // instead of a List<Widget> like ToggleButtons.
                    segments: appDisplayOptions.map<ButtonSegment<AppDisplay>>(
                        ((AppDisplay, IconData) shirt) {
                      return ButtonSegment<AppDisplay>(
                          value: shirt.$1,
                          label: Icon(shirt.$2,
                              color:
                                  themeButtonStyle.getButtonTextStyle().color));
                    }).toList(),
                  ),
                  const SizedBox(
                    width: 10,
                  )
                ])),
            Expanded(
              child: _segmentedButtonSelection.first == AppDisplay.grid
                  ? GridApplicationListComponent(
                      applicationEntityList: widget.applicationEntityList,
                      handleGoTo: widget.handleGoTo,
                      handleScrollController: scrollController)
                  : ListviewApplicationListComponent(
                      applicationEntityList: widget.applicationEntityList,
                      handleGoTo: widget.handleGoTo,
                      handleScrollController: scrollController),
            )
          ],
        ));
  }
}
