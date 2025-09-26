import 'dart:io';
import 'dart:math';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/glucose/glucose_input.dart';
import 'package:medical/src/modal/glucose/glucose_range_data.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/modal/user/schedule_glucose_time.dart';
import 'package:medical/src/model/response/config/glucose_color_config.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';
import 'package:medical/src/widget/nipro/roche_connection/roche_connection_view.dart';
import 'package:medical/src/widgets/custom_checkbox_widget.dart';
import 'package:medical/src/widgets/gap_widget.dart';
import 'package:medical/src/widgets/spacing_row.dart';
import 'package:medical/src/widgets/toggle_buttons.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/CalendarPicker/custom_date_picker.dart';
import '../my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'bloodSugar_result.dto.dart';
import 'constant/bloodSugar_rangetype.dart';
import 'widget/level_off_diabetes_rule_picker.dart';
import 'widget/section_add_note.dart';

class AddBloodSugarControllerNew extends StatefulWidget {
  final String? type;
  final String? id;
  final String? goalId;
  final String? prefilledValue;
  final String? prefilledUnit;
  final List<String>? selectedImages;

  AddBloodSugarControllerNew({
    this.type,
    this.id,
    this.goalId,
    this.prefilledValue,
    this.prefilledUnit,
    this.selectedImages,
  });

  @override
  _AddBloodSugarControllerNewState createState() =>
      _AddBloodSugarControllerNewState();
}

class _AddBloodSugarControllerNewState
    extends BaseState<AddBloodSugarControllerNew>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controllerNote = TextEditingController();
  final GlobalKey<SectionAddNoteState> _sectionAddNoteKey =
      GlobalKey<SectionAddNoteState>();
  List<dynamic> files = [];
  DateTime selectedDate = DateTime.now();
  bool isClicked = false;
  TimeFrameModel? selectedTimeFrame;
  bool isFocus = false;
  bool isChangeStatus = false;
  List<int> _rangeValue = [0, 60, 70, 95, 180];
  List<String> _rangeLabel = ['Rất thấp', "Thấp", 'Tốt', 'Cao', "Rất cao"];
  List<Color> _colorList = [
    Color(0xFFFF9841),
    Color(0xFFFFCD57),
    Color(0xFF23C559),
    Color(0xFFF86F6F),
    Color(0xFFD02424),
  ];
  double? number = 0;
  InputGlucoseModel? model;
  List<String?> removeIDs = [];
  // ShortGuiModel? des;
  double mmollToMgdlFactor = 18.018;
  bool fromNipro = false;
  bool isMgPerDl = false;
  int _lastUnitIndex = 0;
  bool _changedUnit = false;
  int _lastTimeFrameIndex = 0;

  bool isPregnancy = false;
  int clickTime = 0;

  FocusNode _focusNode = FocusNode();
  FocusNode _focusNodeKPI = FocusNode();

  final List<TimeFrameModel> _times = [
    // After filter from api will look like this
    // TimeFrameModel(id: "Prd01", code: "Prd01", name: R.string.duong_huyet_doi.tr()),
    // TimeFrameModel(id: "Prd02", code: "Prd02", name: R.string.truoc_an.tr()),
    // TimeFrameModel(id: "Prd03", code: "Prd03", name: R.string.sau_an.tr()),
  ];

  @override
  void initState() {
    _initData();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _controllerNote.dispose();
    super.dispose();
  }

  void _initData() async {
    isPregnancy = Utils.isGestationalDiabetes();
    if (widget.type == 'update') {
      await _loadDetail();
      await _loadConfig(selectedTimeframeId: selectedTimeFrame?.id);
    } else {
      await _loadConfig();
    }

    // Handle pre-filled unit first to determine if it's mg/dL
    bool isPrefilledMgDl = false;
    if (widget.prefilledUnit != null && widget.prefilledUnit!.isNotEmpty) {
      isPrefilledMgDl = widget.prefilledUnit!.toLowerCase().contains('mg') ||
          widget.prefilledUnit!.toLowerCase().contains('mg/dl');
    }

    // Handle pre-filled data from image analysis
    if (widget.prefilledValue != null && widget.prefilledValue!.isNotEmpty) {
      // Parse the pre-filled value
      double parsedValue = double.tryParse(widget.prefilledValue!) ?? 0;
      number = parsedValue;

      // For mg/dL values, remove decimal part if it's a whole number
      if (isPrefilledMgDl && parsedValue == parsedValue.roundToDouble()) {
        _controller.text = parsedValue.round().toString();
      } else {
        _controller.text = widget.prefilledValue!;
      }
  }

    if (widget.prefilledUnit != null && widget.prefilledUnit!.isNotEmpty) {
      // Set unit based on prefilled unit
      isMgPerDl = isPrefilledMgDl;

      // Check if the AI analysis unit is different from current default
      bool currentUnitIsMg = AppSettings.userInfo!.glucoseUnit == 1;
      bool aiUnitIsMg = isMgPerDl;

      if (currentUnitIsMg != aiUnitIsMg) {
        // Update the user's default unit to match the AI analysis
        await _changeUnit(newUnit: widget.prefilledUnit!);
        // Refresh glucose range after unit change
        if (selectedTimeFrame != null) {
          await _getGlucoseRange(selectedTimeFrame!);
        }
      }
    } else {
      isMgPerDl = AppSettings.userInfo!.glucoseUnit == 1;
    }

    _lastUnitIndex = isMgPerDl ? 0 : 1;

    // Handle selected images from camera/gallery
    if (widget.selectedImages != null && widget.selectedImages!.isNotEmpty) {
      files = widget.selectedImages!.map((path) => File(path)).toList();
    }

    if (mounted) {
      setState(() {});

      // Update SectionAddNote with the files after setState
      if (_sectionAddNoteKey.currentState != null && files.isNotEmpty) {
        _sectionAddNoteKey.currentState
            ?.updateFilesAndNote(files, _controllerNote.text);
      }
    }
    List<int> valueOfClickTime = await AppSettings.getValueOfClickShortGuide();
    clickTime = valueOfClickTime[ScreenList.BLOOD_SUGAR.index];
    // _loadDescription();
    _firebaseSetup();
  }

  Future _firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "kpi_glycemic_add",
        screenClass: "BloodSugarDetailController");
    AppSettings.currentScreenName = 'kpi_glycemic_add';
    // await TrackingManager.analytics.logEvent(
    //   name: 'kpi_add_begin',
    //   parameters: {
    //     "screen_name": 'kpi_glycemic_add',
    //     'object_type': 'kpi_glycemic',
    //     'object_title': 'Chỉ số đường huyết'
    //   },
    // );
  }

  void _navigateAfterSuccess(String id, List<ImagesModel> images,
      [bool? isDataChange = false]) {
    // Observable.instance.notifyObservers([], notifyName: "glucose_change_data");
    int indexRange = findIndexInRanges(number, _rangeValue);
    final data = BloodSugarResultDto(
        id: id,
        dateTime: selectedDate,
        timeFrame: selectedTimeFrame?.name?.tr() ?? '',
        rangeValue: _rangeValue,
        indexRange: indexRange,
        rangeColor: _colorList[indexRange],
        rangeLabel: indexRange > -1 ? _rangeLabel[indexRange] : '',
        glucose: number ?? 0,
        glucoseUnit: isMgPerDl ? R.string.mg_dl.tr() : R.string.mmol_l.tr(),
        note: _controllerNote.text,
        files: images,
        rangeType: (indexRange == 0 || indexRange == 1)
            ? BloodSugarRangeType.very_low
            : (indexRange == _colorList.length - 1 ||
                    indexRange == _colorList.length - 2)
                ? BloodSugarRangeType.very_high
                : BloodSugarRangeType.normal,
        isFetchAnalysis: isDataChange,
        healthRecommendation: model?.healthRecommendation);
    Navigator.of(context).pushReplacementNamed(
        NavigatorName.add_blood_sugar_result,
        arguments: data);
  }

  Future<void> _getGlucoseRange(TimeFrameModel selectedTimeFrame) async {
    GlucoseRangeData? result = await GlucoseClient().getGlucoseRange(
        thresholdType: isPregnancy ? 1 : 0,
        timeFrameCode: selectedTimeFrame.code!);
    if (result != null) {
      _rangeValue = []..addAll([
          0,
          result.veryLow!.value,
          result.low!.value,
          result.normal!.value,
          // result.high!.value,
          result.veryHigh!.value,
        ]);
      setState(() {});
    }
  }

  Future<void> _loadDetail() async {
    try {
      BotToast.showLoading();
      model = await GlucoseClient().fetchDetail(widget.id);
      BotToast.closeAllLoading();
      _controller.text = model!.glucose!.round() == model!.glucose
          ? model!.glucose!.round().toString()
          : roundNumber(model!.glucose!);
      number = model!.glucose!.round() == model!.glucose
          ? model!.glucose!.round().toDouble()
          : model!.glucose;
      _controllerNote.text = model?.note ?? '';
      files.addAll(model!.images);
      selectedDate =
          DateTime.fromMillisecondsSinceEpoch(model!.createDate! * 1000);
      selectedTimeFrame = TimeFrameModel(
          id: model!.timeFrameId, code: '', name: model!.timeFrame);
      fromNipro = model!.byDevice;
      if (_sectionAddNoteKey.currentState != null) {
        _sectionAddNoteKey.currentState
            ?.updateFilesAndNote(files, model!.note ?? '');
      }
    } catch (e) {
      print(e);
    }
  }

  bool _isDataChange() {
    // If no original model exists, consider it as new data
    if (model == null) {
      return true;
    }

    // Check if number/index has changed
    final currentInputStr = _controller.text;
    final originalValueStr = roundNumber(model!.glucose!);

    if (currentInputStr != originalValueStr) {
      return true;
    }

    // Check if note has changed
    final currentNote = _controllerNote.text;
    if (currentNote != (model!.note ?? '')) {
      return true;
    }

    // Check if date has changed
    final originalDate =
        DateTime.fromMillisecondsSinceEpoch(model!.createDate! * 1000);
    if (selectedDate.millisecondsSinceEpoch !=
        originalDate.millisecondsSinceEpoch) {
      return true;
    }

    // Check if images have changed (either count or removals)
    if (files.length != model!.images.length || removeIDs.isNotEmpty) {
      return true;
    }

    // No changes detected
    return false;
  }

  Future<void> _loadConfig({String? selectedTimeframeId}) async {
    BotToast.showLoading();
    // load concurrent 2 api
    final result = await Future.wait([
      GlucoseClient().fetchFlucoseTimeFrameV2(
          time: selectedDate.millisecondsSinceEpoch ~/ 1000),
      GlucoseClient().fetchColorConfig(),
      GlucoseClient().fetchFlucoseTimeFrameV2(),
    ]);

    if (result.length > 2) {
      final timeFrames = result[0] as List<TimeFrameModel>;
      final colors = result[1] as List<GlucoseColorConfig>?;
      final timeFramesFromApi = result[2] as List<TimeFrameModel>;
      _times.clear();
      _times.addAll(timeFramesFromApi);
      _times.sort((a, b) => a.code!.compareTo(b.code!));

      if (colors != null) {
        _colorList = colors.map(((e) {
          return Color(int.parse("0xFF" + e.background.substring(1)));
        })).toList();
        _rangeLabel = colors.map(((e) => e.name)).toList();
      }

      if (selectedTimeframeId != null) {
        selectedTimeFrame = _times.firstWhere(
          (e) => e.id == selectedTimeframeId,
          orElse: () => _times.first,
        );
      } else {
        selectedTimeFrame = timeFrames.length == 0 ? null : timeFrames.first;
      }
      if (selectedTimeFrame != null) {
        selectedTimeFrame = _times.firstWhere(
          (e) => e.code! == selectedTimeFrame!.code!,
          orElse: () => _times.first,
        );
        _lastTimeFrameIndex = _times.indexOf(selectedTimeFrame!);
        await _getGlucoseRange(selectedTimeFrame!);
      }
    }
    // rangeValue = changeRange(selectedTimeFrame);
    BotToast.closeAllLoading();
  }

  void _doGuide() async {
    Navigator.of(context).pushNamed(NavigatorName.glucose_intro_2nd_page);
  }

  // void _loadDescription() async {
  //   des = await HbA1CClient().fetchShortGuide(1);
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: R.color.glucose_bg_color,
          body: Column(
            children: [
              _appBarSection(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(children: [
                    GapH(16),
                    _inforSection(context),
                    Container(
                      margin: const EdgeInsets.only(
                          bottom: 16, left: 16, right: 16),
                      decoration: BoxDecoration(
                        color: R.color.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _dateTimeSectionV2(),
                          const SizedBox(height: 16),
                          _inputSection(),
                          const SizedBox(height: 30),
                          _bloodSugarRange(),
                          const SizedBox(height: 16),
                          _dateTimeFrameV2(),
                        ],
                      ),
                    ),
                    _selectImageSection(),
                    if (AppSettings.isRegionAllowInputDevice)
                      _connectMachine(context),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
              widget.type == 'input'
                  ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        top: 16,
                        bottom: MediaQuery.of(context).padding.bottom / 2,
                      ),
                      child: SpacingColumn(
                        spacing: 20,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isPregnancy)
                            GestureDetector(
                              onTap: () {
                                LevelOffDiabetesRulePicker.showModal(
                                  context,
                                  onSuccess: () {
                                    isPregnancy = false;
                                    _getGlucoseRange(selectedTimeFrame!);
                                  },
                                );
                              },
                              child: Container(
                                color: Colors.white,
                                child: SpacingRow(
                                  spacing: 15,
                                  children: [
                                    IgnorePointer(
                                      child: CustomCheckboxWidget(
                                        isChecked: isChangeStatus,
                                        onTap: () {},
                                      ),
                                    ),
                                    Text(
                                      'Tôi không còn trong thai kỳ.',
                                      style: TextStyle(fontSize: 16),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          Container(
                            padding: EdgeInsets.only(
                              bottom:
                                  8 + MediaQuery.of(context).padding.bottom / 2,
                              left: 12,
                              right: 12,
                              top: 8,
                            ),
                            color: Colors.white,
                            child: Row(
                              children: [
                                if (_shouldShowTakePhotoButton()) ...[
                                  _buildTakePhotoButton(),
                                  GapW(16),
                                ],
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (number != null && number == 0) {
                                        Message.showToastMessage(
                                            context,
                                            R.string.mes_blood_sugar_empty
                                                .tr());
                                        return;
                                      }
                                      int indexRange = findIndexInRanges(
                                          number, _rangeValue);
                                      if (isChangeStatus) {
                                        LevelOffDiabetesRulePicker.showModal(
                                            context, onSuccess: () {
                                          if (indexRange == 4 ||
                                              indexRange == 0) {
                                            _showDialogWarning(
                                                onConfirm: () => _submitData(),
                                                range: indexRange);
                                          } else {
                                            _submitData();
                                          }
                                        });
                                      } else {
                                        if (indexRange == 4 ||
                                            indexRange == 0) {
                                          _showDialogWarning(
                                              onConfirm: () => _submitData(),
                                              range: indexRange);
                                        } else {
                                          _submitData();
                                        }
                                      }
                                    },
                                    child: Container(
                                      height: 48,
                                      width: 195,
                                      decoration: BoxDecoration(
                                        color: R.color.mainColor,
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            R.color.greenGradientTop,
                                            R.color.greenGradientBottom
                                          ],
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          R.string.confirm.tr(),
                                          style: TextStyle(
                                            color: R.color.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : SafeArea(
                      top: false,
                      child: Container(
                          margin: EdgeInsets.all(16),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _showDialogDelete(context);
                                  },
                                  child: Container(
                                      height: 48,
                                      width: 164,
                                      decoration: BoxDecoration(
                                          color: R.color.color0xffFFE9E9,
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          border: Border.all(
                                              color: R.color.attentionText,
                                              width: 2)),
                                      child: Center(
                                        child: Text(R.string.xoa_du_lieu.tr(),
                                            style: TextStyle(
                                                color: R.color.color0xff830000,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700)),
                                      )),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Prevent editing blood glucose index to 0 when type is 'update'
                                    if (number != null && number == 0) {
                                      Message.showToastMessage(context,
                                          R.string.mes_blood_sugar_empty.tr());
                                      return;
                                    }
                                    int indexRange =
                                        findIndexInRanges(number, _rangeValue);
                                    if (indexRange == 4 || indexRange == 0) {
                                      _showDialogWarning(
                                        onConfirm: () => _editData(),
                                        range: indexRange,
                                      );
                                    } else {
                                      _editData();
                                    }
                                  },
                                  child: Container(
                                    height: 48,
                                    width: 164,
                                    decoration: BoxDecoration(
                                        color: R.color.mainColor,
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              R.color.greenGradientTop,
                                              R.color.greenGradientBottom
                                            ])),
                                    child: Center(
                                      child: Text(R.string.save.tr(),
                                          style: TextStyle(
                                              color: R.color.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                ),
                              ])),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTakePhotoButton() {
    return InkWell(
      onTap: () => _takePhoto(context),
      child: Container(
        width: 60,
        height: 48,
        decoration: BoxDecoration(
          color: Color(0xffDCFFFC),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: Image.asset(
            R.drawable.ic_camera_green,
            width: 20,
            height: 20,
          ),
        ),
      ),
    );
  }

  void deleteData() async {
    try {
      BotToast.showLoading();
      final result = await GlucoseClient().deleteIndexGlucose(widget.id);
      if (result == true) {
        Message.showToastMessage(context, R.string.xoa_thanh_cong.tr());
        Observable.instance
            .notifyObservers([], notifyName: "glucose_change_data");
      }

      BotToast.closeAllLoading();
      // if(result.)
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  void _editData() async {
    FocusScope.of(context).unfocus();
    final data = _sectionAddNoteKey.currentState?.getNote();
    if (data != null) {
      files.clear();
      // Convert all files to a consistent format
      for (var file in data.files) {
        if (file is XFile) {
          files.add(File(file.path)); // Convert XFile to File
        } else {
          files.add(file); // Keep File as is
        }
      }
      removeIDs.clear();
      removeIDs.addAll(data.removeIDs);
    }
    final note = data?.note ?? '';
    final numberInput = _controller.text;

    if (numberInput.isEmpty) {
      Message.showToastMessage(context, R.string.mes_blood_sugar_empty.tr());
      return;
    }
    // if (selectedDate == null) {
    //   Message.showToastMessage(context, R.string.ban_chua_nhap_thoi_gian.tr());
    //   return;
    // }
    if (selectedTimeFrame == null) {
      Message.showToastMessage(context, R.string.ban_chua_chon_khung_gio.tr());
      return;
    }
    // if (note.isEmpty) {
    //   Message.showToastMessage(context, R.string.ban_chua_nhap_ghi_chu.tr());
    //   return;
    // }
    BotToast.showLoading();

    try {
      List<String> paths = [];
      for (var file in files) {
        if (file is PickedFile) {
          paths.add(file.path);
        }
      }
      final result = await GlucoseClient().putIndexGlucose(
          widget.id,
          selectedTimeFrame!.id,
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          number.toString(),
          null,
          note,
          fromNipro,
          removeIDs,
          paths);
      _navigateAfterSuccess(
          widget.id ?? '', result?.images ?? [], _isDataChange());

      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  void _submitData() async {
    final data = _sectionAddNoteKey.currentState?.getNote();
    if (data != null) {
      files.clear();
      // Convert all files to a consistent format
      for (var file in data.files) {
        if (file is XFile) {
          files.add(File(file.path)); // Convert XFile to File
        } else {
          files.add(file); // Keep File as is
        }
      }
      removeIDs.clear();
      removeIDs.addAll(data.removeIDs);
    }
    // await TrackingManager.analytics.logEvent(
    //   name: 'cta_button_clicked',
    //   parameters: {
    //     "screen_name": 'kpi_glycemic_add',
    //     'cta_button_name': 'cta_save_glycemic',
    //   },
    // );
    FocusScope.of(context).unfocus();
    final note = _controllerNote.text;

    if (number == 0) {
      Message.showToastMessage(context, R.string.mes_blood_sugar_empty.tr());
      return;
    }
    if (selectedTimeFrame == null) {
      Message.showToastMessage(context, R.string.ban_chua_chon_khung_gio.tr());
      return;
    }
    BotToast.showLoading();

    try {
      List<String> paths = [];
      for (var file in files) {
        paths.add(file.path);
      }
      final result = await GlucoseClient().postIndexGlucose(
          selectedTimeFrame!.id,
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          number.toString(),
          null,
          note,
          fromNipro,
          paths);
      if (result?.id.isNotEmpty == true) {
        await TrackingManager.trackEvent(
          'glucose_add',
          'kpi_glucose_add',
          params: {
            'index_time': selectedTimeFrame?.name,
            'method': fromNipro
                ? 'device'
                : (_hasCameraCapturedData() ? 'camera' : 'manual'),
          },
        );
        if (widget.goalId != null && widget.goalId?.isNotEmpty == true) {
          await HomeClient().completeSmartGoal(selectedDate,
              widget.goalId ?? '', 1, ScheduleType.blood_sugar.typeIndex);
        }
        _navigateAfterSuccess(result!.id, result.images);
      }

      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  Future<void> _changeUnit({String? newUnit}) async {
    try {
      BotToast.showLoading();
      ScheduleGlucoseTimeModel timeModel =
          await UserClient().fetchScheduleGlucoseSetting();

      // Determine the new unit value
      int newGlucoseUnit;
      if (newUnit != null) {
        // Use the provided unit from AI analysis
        newGlucoseUnit = newUnit.toLowerCase().contains('mg') ? 1 : 2;
      } else {
        // Toggle between current units (manual change)
        newGlucoseUnit = timeModel.glucoseUnit == 1 ? 2 : 1;
      }

      await UserClient().updateScheduleGlucoseSetting(ScheduleGlucoseTimeModel(
          beforeEat: timeModel.beforeEat,
          afterEat: timeModel.afterEat,
          beforeSleeping: timeModel.beforeSleeping,
          glucoseUnit: newGlucoseUnit));
      await UserClient().fetchUser();
      Observable.instance
          .notifyObservers([], notifyName: "setup_schedule_change");
      Observable.instance.notifyObservers([], notifyName: "refresh_home");
      BotToast.closeAllLoading();
    } catch (e, _) {
      BotToast.closeAllLoading();
      if (e is Error) {
        Message.showToastMessage(context, e.message);
      } else {
        Message.showToastMessage(context, e.toString());
      }
    }
  }

  void _showDialogDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16.0))),
              contentPadding: EdgeInsets.all(0),
              content: Stack(children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0),
                        child: Text(
                          R.string.ban_muon_xoa_du_lieu.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: R.color.color0xff111515,
                              fontSize: 15,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          R.string.confirm_to_remove_data.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: R.color.color0xff5E6566,
                              fontSize: 13,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 16),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                  deleteData();
                                },
                                child: Container(
                                  height: 43,
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: R.color.attentionText,
                                    borderRadius: BorderRadius.circular(200),
                                  ),
                                  child: Center(
                                    child: Text(R.string.confirm.tr(),
                                        style: TextStyle(
                                            color: R.color.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ),
                            ]),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                      icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )
              ])),
        );
      },
    );
  }

  void _showDialogSave() {
    final note = _controllerNote.text;
    final numberInput = _controller.text;

    if (model != null) {
      final noteText = model!.note ?? '';
      final date =
          DateTime.fromMillisecondsSinceEpoch(model!.createDate! * 1000);
      if (note == noteText &&
          numberInput == roundNumber(model!.glucose!) &&
          files.length == model!.images.length &&
          removeIDs.length == 0 &&
          date.millisecondsSinceEpoch == selectedDate.millisecondsSinceEpoch) {
        if (_changedUnit)
          Observable.instance
              .notifyObservers([], notifyName: "glucose_data_refresh");
        Navigator.pop(context);
        return;
      }
    } else if (note.isEmpty && numberInput.isEmpty && files.length == 0) {
      if (_changedUnit)
        Observable.instance
            .notifyObservers([], notifyName: "glucose_data_refresh");
      Navigator.pop(context);
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: Stack(children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.ic_back_icon,
                          width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(R.string.ban_muon_quay_lai.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(R.string.confirm_to_back.tr(),
                            textAlign: TextAlign.center,
                            style: R.style.normalTextStyle),
                      ),
                      SizedBox(height: 16),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                      height: 43,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          color: R.color.grayBorder),
                                      child: Center(
                                        child: Text(R.string.van_o_lai.tr(),
                                            style: TextStyle(
                                                color: R.color.textDark,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ))),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    if (_changedUnit)
                                      Observable.instance.notifyObservers([],
                                          notifyName: "glucose_data_refresh");
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                        color: R.color.red,
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              R.color.greenGradientTop,
                                              R.color.greenGradientBottom
                                            ])),
                                    child: Center(
                                      child: Text(R.string.exit.tr(),
                                          style: TextStyle(
                                              color: R.color.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  )),
                            ),
                          ])
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                      icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )
              ])),
        );
      },
    );
  }

  void _showDialogWarning({required Function onConfirm, required int range}) {
    showDialog(
      context: context,
      builder: (context) {
        return Container(
          child: AlertDialog(
              contentPadding: EdgeInsets.all(0),
              content: Stack(children: [
                Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(R.drawable.ic_warning, width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                            'Đường Huyết ở mức rất ${range == 0 ? 'thấp' : 'cao'}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 20,
                                fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                            'Nếu có các triệu chứng thở nhanh, đau bụng, nôn ói,... gặp bác sĩ sớm để được tư vấn và điều chỉnh toa thuốc.',
                            textAlign: TextAlign.center,
                            style: R.style.normalTextStyle),
                      ),
                      SizedBox(height: 16),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    _focusNodeKPI.requestFocus();
                                    _controller.selection = TextSelection(
                                        baseOffset: 0,
                                        extentOffset: _controller.text.length);
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                      height: 43,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(200),
                                          color: R.color.grayBorder),
                                      child: Center(
                                        child: Text('Nhập lại',
                                            style: TextStyle(
                                                color: R.color.textDark,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ))),
                            ),
                            SizedBox(width: 14),
                            Expanded(
                              child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    onConfirm();
                                  },
                                  child: Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                        color: R.color.red,
                                        borderRadius:
                                            BorderRadius.circular(200),
                                        gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              R.color.greenGradientTop,
                                              R.color.greenGradientBottom
                                            ])),
                                    child: Center(
                                      child: Text('Tôi đã hiểu',
                                          style: TextStyle(
                                              color: R.color.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                  )),
                            ),
                          ])
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                      icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                      onPressed: () {
                        Navigator.pop(context);
                      }),
                )
              ])),
        );
      },
    );
  }

  Future<void> showGuide(BuildContext context) async {
    // Description.showTooltip(context,
    //     data: des!, title: R.string.blood_sugar_for_diabetes.tr());
    // clickTime = clickTime + 1;
    // await AppSettings.setValueOfClickShortGuideIndex(
    //     ScreenList.BLOOD_SUGAR.index, clickTime);
  }

  Widget _appBarSection() {
    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      centerTitle: false,
      title: Text(
          widget.type == 'update'
              ? R.string.update_blood_sugar.tr()
              : R.string.enter_blood_sugar.tr(),
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: R.color.white)),
      leadingIcon: IconButton(
          splashColor: R.color.transparent,
          highlightColor: R.color.transparent,
          icon: Icon(Icons.arrow_back, color: R.color.white),
          onPressed: () {
            _showDialogSave();
          }),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                _doGuide();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  R.string.huong_dan.tr(),
                  style: TextStyle(color: R.color.white, fontSize: 15),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inforSection(BuildContext context) {
    return SizedBox();
    // return Padding(
    //     padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
    //     child: isClicked && clickTime < 2
    //         ? Description(
    //             isCreateData: true,
    //             input: true,
    //             data: des,
    //             titleDetail: R.string.blood_sugar_for_diabetes.tr())
    //         : SizedBox());
  }

  Widget _inputSection() {
    return Container(
      height: 80,
      width: double.infinity,
      child: Stack(
        children: [
          // bottom line
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(height: 1, color: R.color.color0xffE5E5E5),
          ),
          // text field
          Positioned.fill(
            child: TextField(
              focusNode: _focusNodeKPI,
              controller: _controller,
              maxLength: isMgPerDl ? 5 : 4,
              autofocus: widget.type != 'update',
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                  color: R.color.black,
                  fontSize: 48,
                  fontFamily: 'Viga',
                  fontWeight: FontWeight.w500),
              inputFormatters: [
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (isMgPerDl) {
                    // 3 digits
                    if (RegExp(r'^\d{0,3}$').hasMatch(newValue.text)) {
                      return newValue;
                    }
                  } else {
                    // 2 digits and 1 decimal (optional)
                    if (RegExp(r'^\d{0,2}([.,]\d{0,1})?$')
                        .hasMatch(newValue.text)) {
                      return newValue;
                    }
                  }
                  return oldValue;
                }),
              ],
              decoration: InputDecoration(
                counterText: '',
                hintText: isMgPerDl ? '0' : '0,0',
                contentPadding: EdgeInsets.only(bottom: 8),
                border: InputBorder.none,
                hintStyle: TextStyle(
                    fontFamily: 'Viga',
                    color: Color(0xffDDDDDD),
                    fontSize: 48,
                    fontWeight: FontWeight.w700),
              ),
              onChanged: (value) {
                fromNipro = false;
                final newValue = value.split(',').join('.');
                number = newValue.isEmpty ? 0 : double.parse(newValue);
                setState(() {});
              },
            ),
          ),
          // buttons
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ToggleButtonsVertical(
                names: [R.string.mg_dl, R.string.mmol_l],
                backgroundColor: Color(0xFFF2F6F9),
                width: 65,
                selectedIndex: _lastUnitIndex,
                onChange: (index) async {
                  if (index == _lastUnitIndex) return;
                  _lastUnitIndex = index;
                  _changedUnit = true;
                  await _changeUnit();
                  
                  // Refresh glucose range after unit change
                  if (selectedTimeFrame != null) {
                    await _getGlucoseRange(selectedTimeFrame!);
                  }

                  final glucose = roundAsFixed(
                      AppSettings.userInfo!.glucoseUnit == 1
                          ? number! * mmollToMgdlFactor
                          : number! / mmollToMgdlFactor);
                  if (AppSettings.userInfo!.glucoseUnit == 1) {
                    number = glucose.round().toDouble();
                  } else {
                    number = glucose;
                  }
                  if (_controller.text != "") {
                    _controller.text = AppSettings.userInfo!.glucoseUnit == 1
                        ? glucose.round().toString()
                        : roundNumber(glucose);
                  }
                  setState(() {
                    isMgPerDl = index == 0;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateTimeSectionV2() {
    return Center(
      child: InkWell(
        onTap: _onTapDateTime,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: R.color.color0xffE5E5E5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  convertToUTC(selectedDate.millisecondsSinceEpoch ~/ 1000,
                      'HH:mm - dd/MM/yyyy'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: R.color.textDark,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: R.color.textDark,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateTimeFrameV2() {
    return Container(
      width: double.infinity,
      height: 32.h,
      child: ToggleButtonsHorizontal(
        names: _times.map((e) => e.name!).toList(),
        flexes: _times.length > 1
            ? [3, ...List.generate(_times.length - 1, (index) => 2)]
            : null,
        backgroundColor: Color(0xFFF2F6F9),
        selectedIndex: _lastTimeFrameIndex,
        onChange: (index) async {
          _lastTimeFrameIndex = index;
          selectedTimeFrame = _times[index];
          try {
            BotToast.showLoading();
            await _getGlucoseRange(selectedTimeFrame!);
          } catch (e) {
            BotToast.showText(text: R.string.error_unexpected_error.tr());
          } finally {
            BotToast.closeAllLoading();
            setState(() {});
          }
        },
        height: 32.h,
      ),
    );
  }

  Widget _connectMachine(BuildContext context) {
    final action = () async {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => RocheConnectionView()));
    };
    final connectMachineW = InkWell(
      onTap: action,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            Utils.getBoxShadowDropCard(),
          ],
        ),
        height: 64,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(R.drawable.im_glucose_input_device,
                width: 40, height: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                R.string.glucose_connect_device_title.tr(),
                style: TextStyle(
                  fontSize: 15,
                  color: R.color.color0xff111515,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right,
              color: R.color.primaryGreyColor,
              size: 24,
            ),
          ],
        ),
      ),
    );

    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TODO: Enhance this
          // magic number follow sum on design or edit 1by1 :D
          SizedBox(height: max(height - 800 - (files.length > 0 ? 72 : 0), 8)),
          Container(
            width: 235,
            height: 20,
            alignment: Alignment.center,
            child: Row(
              children: [
                Expanded(
                    child: Container(
                        height: 1, color: R.color.greenGradientBottom)),
                Text(
                  '   ${R.string.or.tr()}   ',
                  style: TextStyle(
                    fontSize: 14,
                    color: R.color.greenGradientBottom,
                  ),
                ),
                Expanded(
                    child: Container(
                        height: 1, color: R.color.greenGradientBottom)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          connectMachineW,
        ],
      ),
    );
  }

  bool _shouldShowTakePhotoButton() {
    // Don't show take photo button if data came from camera capture
    return !_hasCameraCapturedData();
  }

  bool _hasCameraCapturedData() {
    // Check if data came from camera capture (has prefilled data from AI analysis)
    return (widget.prefilledValue != null &&
            widget.prefilledValue!.isNotEmpty) ||
        (widget.prefilledUnit != null && widget.prefilledUnit!.isNotEmpty) ||
        (widget.selectedImages != null && widget.selectedImages!.isNotEmpty);
  }

  void _takePhoto(BuildContext context) async {
    await TrackingManager.trackEvent(
      'glucose_select_method',
      'kpi_glucose',
      params: {
        'method': 'camera',
      },
    );
    // Navigate to blood glucose image capture
    Navigator.pushNamed(context, NavigatorName.blood_sugar_image_capture);
  }

  Widget _selectImageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SectionAddNote(
        focusNode: _focusNode,
        controllerNote: _controllerNote,
        maxMedia: 5,
        key: _sectionAddNoteKey,
        initialFiles: files,
        // If images come from camera capture flow, mark them as non-removable (camera icon)
        initialFilesFromCamera: _hasCameraCapturedData(),
        noteTitle: R.string.ghi_chu.tr(),
        subText: _shouldShowSubText()
            ? R.string.result_from_blood_glucose_device.tr()
            : null,
        showCameraIcons:
            widget.type != 'update', // Hide camera icons for update flow
      ),
    );
  }

  bool _shouldShowSubText() {
    // For update mode: show subText if byDevice is true and there are images
    if (widget.type == 'update') {
      return fromNipro && files.isNotEmpty;
    }
    // For new mode: show subText if there are camera-captured images
    return files.any((file) => file is File);
  }

  int findIndexInRanges(double? number, List<int> ranges) {
    if (number == null) return -1;
    bool glucoseUnit = AppSettings.userInfo!.glucoseUnit == 1;

    for (int i = 0; i < ranges.length - 1; i++) {
      if (i == ranges.length - 1) break;
      if (number >=
              (glucoseUnit
                  ? ranges[i]
                  : roundAsFixed(ranges[i] / mmollToMgdlFactor)) &&
          number <
              (glucoseUnit
                  ? ranges[i + 1]
                  : roundAsFixed(ranges[i + 1] / mmollToMgdlFactor))) {
        return i;
      }
    }
    return ranges.length - 1;
  }

  Widget _bloodSugarRange() {
    double? _number = number;

    bool glucoseUnit = AppSettings.userInfo!.glucoseUnit == 1;
    int index = -1;
    int indexRange = findIndexInRanges(_number, _rangeValue);
    num widthRange =
        (MediaQuery.of(context).size.width - 72) / (_rangeValue.length);
    // print('hihi widthRange: $widthRange');
    num width = _number == 0 ? 0 : widthRange * (indexRange);

    // lấy pxPerValue = max - min => 55 - 0
    // lấy pxPerValue * value

    if (_number != null && _number != 0) {
      if (!isMgPerDl) {
        _number = _number * mmollToMgdlFactor;
      }
      num min = _rangeValue[indexRange];
      // print('hihi min: $min');
      num max = indexRange + 1 >= _rangeValue.length
          ? _rangeValue[indexRange] + min
          : _rangeValue[indexRange + 1];
      // print('hihi max: $max');
      // giá trị từ 0 -> 55 sẽ nằm ở mức 0

      // sau đó tính toán mỗi px trên 1 mức value
      num maximumValue = max - min;
      // print('hihi maximumValue: $maximumValue');
      num pxPerValue = widthRange / maximumValue;
      // print('hihi pxPerValue: $pxPerValue');
      num widthPlus = pxPerValue * (_number - min);
      // print('hihi widthPlus: $widthPlus');
      width += widthPlus;

      width = width > (widthRange * _rangeValue.length)
          ? widthRange * _rangeValue.length
          : width;

      //   print('hihi number: $number');
    }

    return SpacingColumn(
      spacing: 40,
      children: [
        if (number != 0)
          RichText(
            text: TextSpan(
              text: 'Đường huyết đang ở mức ',
              style: TextStyle(
                  color: R.color.textDark,
                  fontWeight: FontWeight.w400,
                  fontSize: 16),
              children: <TextSpan>[
                TextSpan(
                  text: '“${_rangeLabel[indexRange]}”',
                  style: TextStyle(
                    color: _colorList[indexRange],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Row(
                  children: _colorList.map(
                    (e) {
                      index++;
                      return Container(
                        height: 8,
                        width: widthRange.toDouble(),
                        color: _colorList[index],
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
            Positioned(
              left: width.toDouble() - 20,
              bottom: 40,
              child: Container(
                  child: Icon(Icons.arrow_drop_down_rounded, size: 40)),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Row(
                  children: _rangeValue
                      .map(
                        (e) => Expanded(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              SizedBox(),
                              Positioned(
                                left: e.toString().length == 3 ? -10 : -7,
                                child: Text(
                                    '${e == 0 ? '' : glucoseUnit ? e : roundAsFixed(e / mmollToMgdlFactor)}'),
                              )
                            ],
                          ),
                        ),
                      )
                      .toList()),
            ),
            Positioned(
              left: -2,
              right: 0,
              bottom: 25,
              child: Row(
                  children: _rangeValue
                      .map(
                        (e) => Expanded(
                          child: Container(
                            width: 30,
                            child: Text(
                              '|',
                              style: TextStyle(
                                color: e == 0
                                    ? Colors.transparent
                                    : Color(0xFFD7D7D7),
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList()),
            ),
          ],
        ),
      ],
    );
  }

  void _onTapDateTime() async {
    // await TrackingManager.analytics
    //     .logEvent(name: 'component_clicked', parameters: {
    //   "screen_name": 'kpi_glycemic_add',
    //   'component_name': 'date_picker_glycemic',
    // });

    showDialog(
      barrierColor: R.color.color0xff003F38.withOpacity(0.5),
      context: context,
      builder: (_) => DateMultiPicker(
        initDate: selectedDate,
        callback: (date) {
          setState(() {
            selectedDate = date ?? DateTime.now();
          });
          _loadConfig();
          setState(() {});
        },
      ),
    );
  }
}

typedef TimeCallback = Function(DateTime?);

class DateMultiPicker extends StatefulWidget {
  final DateTime? initDate;
  final TimeCallback? callback;
  DateMultiPicker({this.initDate, this.callback});
  @override
  _DateMultiPickerState createState() => _DateMultiPickerState();
}

class _DateMultiPickerState extends State<DateMultiPicker> {
  DateTime? selectedDate = DateTime.now();
  int selectedHour = DateTime.now().hour;
  int selectedMinute = DateTime.now().minute;

  @override
  void initState() {
    if (widget.initDate != null) {
      selectedDate = widget.initDate;
      selectedHour = widget.initDate!.hour;
      selectedMinute = widget.initDate!.minute;
    }
    firebaseSetup();
    super.initState();
  }

  Future firebaseSetup() async {
    // await TrackingManager.analytics.logEvent(
    //   name: 'component_displayed',
    //   parameters: {
    //     "screen_name": 'kpi_glycemic_add',
    //     'component_name': 'date_picker_glycemic',
    //   },
    // );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: R.color.transparent,
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(left: 16, right: 16),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: R.color.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, right: 4),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(R.string.pick_date.tr(),
                                style: TextStyle(
                                    color: R.color.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            IconButton(
                                icon: Icon(Icons.close,
                                    color: R.color.color0xffBEC0C8),
                                onPressed: () async {
                                  // await TrackingManager.analytics.logEvent(
                                  //   name: 'cta_button_clicked',
                                  //   parameters: {
                                  //     "screen_name": 'date_picker_glycemic',
                                  //     'cta_button_name': 'cate_cancel',
                                  //   },
                                  // );
                                  Navigator.pop(context);
                                })
                          ]),
                    ),
                    CustomCalendarDatePicker(
                        initialDate: widget.initDate == null
                            ? DateTime.now()
                            : widget.initDate!,
                        firstDate: DateTime.parse("1969-07-20 20:18:04Z"),
                        lastDate: DateTime.now(),
                        onDateChanged: (datetime) async {
                          // await TrackingManager.analytics.logEvent(
                          //   name: 'component_clicked',
                          //   parameters: {
                          //     "screen_name": 'date_picker_glycemic',
                          //     'component_name': 'time_section_glycemic',
                          //   },
                          // );
                          selectedDate = datetime ?? DateTime.now();
                        }),
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                        ),
                        Text(R.string.pick_time.tr(),
                            style: TextStyle(
                                color: R.color.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    SizedBox(height: 20),
                    CustomTimePicker(
                        selectedHour: selectedHour,
                        selectedMinute: selectedMinute,
                        callback: (hour, minute) async {
                          // await TrackingManager.analytics.logEvent(
                          //   name: 'component_clicked',
                          //   parameters: {
                          //     "screen_name": 'date_picker_glycemic',
                          //     'component_name': 'time_section_glycemic',
                          //   },
                          // );
                          selectedHour = hour ?? selectedHour;
                          selectedMinute = minute ?? selectedMinute;
                        }),
                    SizedBox(height: 20),
                    Row(children: [
                      SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            // await TrackingManager.analytics.logEvent(
                            //   name: 'cta_button_clicked',
                            //   parameters: {
                            //     "screen_name": 'date_picker_glycemic',
                            //     'cta_button_name': 'cate_cancel',
                            //   },
                            // );
                            Navigator.pop(context);
                          },
                          child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                  color: R.color.grayBorder,
                                  borderRadius: BorderRadius.circular(21.5)),
                              child: Center(
                                  child: Text(R.string.cancel.tr(),
                                      style: TextStyle(
                                          color: R.color.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)))),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            selectedDate = DateTime(
                                selectedDate!.year,
                                selectedDate!.month,
                                selectedDate!.day,
                                selectedHour,
                                selectedMinute);

                            widget.callback!(selectedDate);
                            // await TrackingManager.analytics.logEvent(
                            //   name: 'cta_button_clicked',
                            //   parameters: {
                            //     "screen_name": 'date_picker_glycemic',
                            //     'cta_button_name': 'cta_done',
                            //   },
                            // );

                            Navigator.pop(context);
                          },
                          child: Container(
                              height: 43,
                              decoration: BoxDecoration(
                                  color: R.color.mainColor,
                                  borderRadius: BorderRadius.circular(21.5)),
                              child: Center(
                                  child: Text(R.string.yes.tr(),
                                      style: TextStyle(
                                          color: R.color.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)))),
                        ),
                      ),
                      SizedBox(width: 16),
                    ]),
                    SizedBox(height: 16)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef TimeHourCallback = Function(int?, int?);

class CustomTimePicker extends StatefulWidget {
  final int? selectedHour;
  final int? selectedMinute;
  final TimeHourCallback? callback;
  CustomTimePicker({this.selectedHour, this.selectedMinute, this.callback});
  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  FixedExtentScrollController? hourController;
  FixedExtentScrollController? minuteController;
  int? selectedHour = 1;
  int? selectedMinute = 1;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedHour = now.hour;
    selectedMinute = now.minute;
    if (widget.selectedHour != null) {
      selectedHour = widget.selectedHour;
    }
    if (widget.selectedMinute != null) {
      selectedMinute = widget.selectedMinute;
    }
    hourController = FixedExtentScrollController(initialItem: selectedHour!);
    minuteController =
        FixedExtentScrollController(initialItem: selectedMinute!);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            height: 150,
            width: 106,
            child: CupertinoPicker(
                scrollController: hourController,
                selectionOverlay: null,
                onSelectedItemChanged: (value) {
                  setState(() {
                    selectedHour = value;
                    widget.callback!(selectedHour, selectedMinute);
                  });
                },
                itemExtent: 47.0,
                children: List<int>.generate(24, (i) => i)
                    .map((e) => Center(
                          child: Text(e.toString().length == 1 ? '0$e' : '$e',
                              style: TextStyle(
                                  color: selectedHour == e
                                      ? R.color.mainColor
                                      : R.color.color0xffC0C2C5,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ))
                    .toList())),
        SizedBox(width: 24),
        Container(
            height: 150,
            width: 106,
            child: CupertinoPicker(
                scrollController: minuteController,
                selectionOverlay: null,
                onSelectedItemChanged: (value) {
                  setState(() {
                    selectedMinute = value;
                    widget.callback!(selectedHour, selectedMinute);
                  });
                },
                itemExtent: 47.0,
                children: List<int>.generate(60, (i) => i)
                    .map((e) => Center(
                          child: Text(e.toString().length == 1 ? '0$e' : '$e',
                              style: TextStyle(
                                  color: selectedMinute == e
                                      ? R.color.mainColor
                                      : R.color.color0xffC0C2C5,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ))
                    .toList()))
      ],
    );
  }
}

String formatDate(int timeStamp) {
  final date = DateTime.fromMillisecondsSinceEpoch(timeStamp);

  return '${R.string.month} ${date.month}, ${date.year}';
}
