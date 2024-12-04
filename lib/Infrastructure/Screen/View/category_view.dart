import 'package:dupot_easy_flatpak/Domain/Entity/db/application_entity.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Repository/application_repository.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/List/grid_application_list_component.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/List/listview_application_list_component.dart';
import 'package:flutter/material.dart';

class CategoryView extends StatefulWidget {
  Function handleGoTo;
  String categoryIdSelected;

  CategoryView(
      {super.key, required this.handleGoTo, required this.categoryIdSelected});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

enum AppDisplay { list, grid }

const List<(AppDisplay, IconData)> appDisplayOptions = <(AppDisplay, IconData)>[
  (AppDisplay.list, Icons.view_list),
  (AppDisplay.grid, Icons.view_compact),
];

class _CategoryViewState extends State<CategoryView> {
  List<ApplicationEntity> stateAppStreamList = [];
  List<String> stateCategoryIdList = [];
  String appPath = '';

  String lastCategoryIdSelected = '';

  ScrollController scrollController = ScrollController();

  Set<AppDisplay> _segmentedButtonSelection = <AppDisplay>{AppDisplay.list};

  @override
  void initState() {
    // TODO: implement initState

    loadData();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant CategoryView oldWidget) {
    if (oldWidget.categoryIdSelected != widget.categoryIdSelected) {
      loadData();
    }

    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  Future<void> loadData() async {
    lastCategoryIdSelected = widget.categoryIdSelected;
    ApplicationRepository appStreamFactory = ApplicationRepository();

    List<ApplicationEntity> appStreamList = await appStreamFactory
        .findListApplicationEntityByCategory(widget.categoryIdSelected);

    setState(() {
      stateAppStreamList = appStreamList;
    });
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return stateAppStreamList.isEmpty
        ? CircularProgressIndicator()
        : Scrollbar(
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
                        segments: appDisplayOptions
                            .map<ButtonSegment<AppDisplay>>(
                                ((AppDisplay, IconData) shirt) {
                          return ButtonSegment<AppDisplay>(
                              value: shirt.$1, label: Icon(shirt.$2));
                        }).toList(),
                      ),
                      const SizedBox(
                        width: 10,
                      )
                    ])),
                Expanded(
                  child: _segmentedButtonSelection.first == AppDisplay.grid
                      ? GridApplicationListComponent(
                          applicationEntityList: stateAppStreamList,
                          handleGoTo: widget.handleGoTo,
                          handleScrollController: scrollController)
                      : ListviewApplicationListComponent(
                          applicationEntityList: stateAppStreamList,
                          handleGoTo: widget.handleGoTo,
                          handleScrollController: scrollController),
                )
              ],
            ));
  }
}