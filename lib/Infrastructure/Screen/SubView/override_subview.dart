import 'package:dupot_easy_flatpak/Domain/Entity/db/application_entity.dart';
import 'package:dupot_easy_flatpak/Domain/Entity/recipe/permission_entity.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Api/localization_api.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Control/Model/SubView/override_control.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Entity/override_form_control.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Repository/application_repository.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/SharedComponents/Button/close_subview_button.dart';
import 'package:dupot_easy_flatpak/Infrastructure/Screen/Theme/theme_button_style.dart';
import 'package:flutter/material.dart';
import 'package:ini/ini.dart';

class OverrideSubview extends StatefulWidget {
  String applicationId;

  Function handleGoToApplication;

  OverrideSubview({
    super.key,
    required this.applicationId,
    required this.handleGoToApplication,
  });

  @override
  State<OverrideSubview> createState() => _OverrideSubviewState();
}

class _OverrideSubviewState extends State<OverrideSubview> {
  ApplicationEntity? stateApplicationEntity;
  bool stateIsLoaded = true;
  String stateInstallationOutput = '';

  bool stateIsInstalling = false;

  String applicationId = '';

  late PermissionEntity statePermission = PermissionEntity('', 'label');
  Config stateOverrideConfig = Config();

  String appPath = '';

  final ScrollController scrollController = ScrollController();

  List<OverrideFormControl> stateOverrideFormControlList = [];

  late OverrideControl overrideControl;

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadData() async {
    applicationId = widget.applicationId;
    ApplicationRepository appStreamFactory = ApplicationRepository();

    ApplicationEntity appStream =
        await appStreamFactory.findApplicationEntityById(applicationId);

    await loadApplicationRecipeOverride(applicationId);

    setState(() {
      stateApplicationEntity = appStream;
    });
  }

  Future<void> loadApplicationRecipeOverride(String applicationId) async {
    overrideControl = OverrideControl();
    List<OverrideFormControl> overrideFormControlList =
        await overrideControl.getOverrideControlList(applicationId);

    setState(() {
      stateOverrideFormControlList = overrideFormControlList;
      stateIsLoaded = false;
    });

    //print(flatpakOverrideApplication);
  }

  @override
  @mustCallSuper
  void didChangeDependencies() {
    loadData();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle outputTextStyle =
        TextStyle(color: Colors.white, fontSize: 14.0);

    return stateApplicationEntity == null
        ? const CircularProgressIndicator()
        : Scrollbar(
            interactive: false,
            thumbVisibility: true,
            controller: scrollController,
            child: ListView(
              controller: scrollController,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    getSaveButton(),
                    const SizedBox(width: 20),
                    stateIsInstalling
                        ? const CircularProgressIndicator()
                        : CloseSubViewButton(
                            applicationId: widget.applicationId,
                            handle: widget.handleGoToApplication),
                    const SizedBox(width: 20)
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 800),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: stateOverrideFormControlList.map(
                                (OverrideFormControl
                                    stateOverrideFormControlLoop) {
                              if (stateOverrideFormControlLoop
                                  .isTypeFileSystem()) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(stateOverrideFormControlLoop.label,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    TextField(
                                      controller: stateOverrideFormControlLoop
                                          .textEditingController,
                                    )
                                  ],
                                );
                              } else if (stateOverrideFormControlLoop
                                  .isTypeEnv()) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(stateOverrideFormControlLoop.label,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    Row(
                                      children: [
                                        Switch(
                                          value: stateOverrideFormControlLoop
                                              .boolValue,
                                          onChanged: (bool value) {
                                            stateOverrideFormControlLoop
                                                .boolValue = value;

                                            List<OverrideFormControl>
                                                tmpOverrideFormControlList =
                                                stateOverrideFormControlList;

                                            setState(() {
                                              stateOverrideFormControlList =
                                                  tmpOverrideFormControlList;
                                            });
                                          },
                                        ),
                                        Text(LocalizationApi().tr('Yes'))
                                      ],
                                    )
                                  ],
                                );
                              }

                              return SizedBox();
                            }).toList()),
                      ),
                    )),
              ],
            ),
          );
  }

  Widget getSaveButton() {
    return FilledButton.icon(
      style: ThemeButtonStyle(context: context).getButtonStyle(),
      onPressed: () async {
        await overrideControl.save(
            widget.applicationId, stateOverrideFormControlList);

        setState(() {
          stateIsInstalling = false;
        });
      },
      label: Text(LocalizationApi().tr('save')),
      icon: const Icon(Icons.save),
    );
  }
}