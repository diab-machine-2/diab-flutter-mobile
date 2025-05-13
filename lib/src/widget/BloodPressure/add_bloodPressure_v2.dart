import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/base/images.dart';
import 'package:medical/src/modal/base/keyvalue.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/model/response/config/blood_pressure_color_config.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/repo/blood_pressure/bloodPressure_client.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodSugar/widget/section_add_note.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/nipro/health_app/widgets/request_health_connect.dart';
import 'package:medical/src/widgets/toggle_buttons.dart';

import '../../widgets/CalendarPicker/custom_date_picker.dart';
import '../../widgets/spacing_row.dart';
import 'bloodpressure_result.dto.dart';
import 'widget/bloodpressure_warning_popup.dart';

class AddBloodPressureController extends StatefulWidget {
  final String? type;
  final String? id;
  final String? goalId;

  AddBloodPressureController({this.type, this.id, this.goalId});
  @override
  _AddBloodPressureControllerState createState() => _AddBloodPressureControllerState();
}

class _AddBloodPressureControllerState extends BaseState<AddBloodPressureController>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controllerSystolic = TextEditingController();
  final TextEditingController _controllerDiastolic = TextEditingController();
  final TextEditingController _controllerHeart = TextEditingController();
  final TextEditingController _controllerNote = TextEditingController();
  final GlobalKey<SectionAddNoteState> _sectionAddNoteKey = GlobalKey<SectionAddNoteState>();
  FocusNode _systolicFocus = FocusNode();
  FocusNode _diastolicFocus = FocusNode();
  FocusNode _heartFocus = FocusNode();
  final List<dynamic> _files = [];
  DateTime selectedDate = DateTime.now();
  bool isClicked = false;
  DateTime time = DateTime.now();
  BloodPressureModel? model;
  TimeFrameModel? _selectedTimeFrame;
  List<String?> removeIDs = [];
  String? textValidate = '';
  ShortGuiModel? des;
  List<int> _rangeValueSystolic = [0, 90, 130, 140, 160, 180];
  List<int> _rangeValueDiastolic = [0, 60, 85, 90, 100, 110];
  List<String> _rangeLabel = [
    "Thấp",
    "Bình thường",
    "Bình thường cao",
    "Tăng huyết áp độ 1",
    "Tăng huyết áp độ 2",
    "Tăng huyết áp độ 3",
  ];
  // Range tâm thu (systolic): 30-300
  // Range tâm trương (diastolic): 25-250
  // Systolic phải lớn hơn diastolic
  bool get _isNotValidInput {
    if (_controllerSystolic.text.isNotEmpty && _controllerDiastolic.text.isNotEmpty) {
      double systolic = double.tryParse(_controllerSystolic.text) ?? 0;
      double diastolic = double.tryParse(_controllerDiastolic.text) ?? 0;
      if (systolic < 30 ||
          systolic > 300 ||
          diastolic < 25 ||
          diastolic > 250 ||
          systolic < diastolic) {
        return true;
      }
    }
    return false;
  }

  // Range nhịp tim (pulse): 40-300
  bool get _isNotValidHeartRate {
    if (_controllerHeart.text.isNotEmpty) {
      double pulse = double.tryParse(_controllerHeart.text) ?? 0;
      if (pulse < 40 || pulse > 300) {
        return true;
      }
    }
    return false;
  }

  List<Color> _colorList = [
    // "Thấp"
    Color(0xFFF9BA1A),
    // "Bình thường"
    Color(0xFF16AA47),
    // "Bình thường cao"
    Color(0xFFA1F0BC),
    // "Tăng huyết áp độ 1"
    Color(0xFFFFCDD2),
    // "Tăng huyết áp độ 2"
    Color(0xFFF86F6F),
    // "Tăng huyết áp độ 3"
    Color(0xFFAF0000),
  ];
  bool isLoading = true;
  late AnimationController _controller;
  final FocusNode _focusNode = FocusNode();

  int _lastTimeFrameIndex = 0;
  final List<TimeFrameModel> _times = [
    // After filter from api will look like this
    TimeFrameModel(id: "Prd01", code: "Prd01", name: "Thức giấc"),
    TimeFrameModel(id: "Prd19", code: "Prd19", name: "Bất kì"),
  ];
  List<KeyValue>? _reasons = [];
  bool _isInputHeartRate = false;

  // UI affect
  bool get _isInputEnough {
    if (!mounted) return false;
    bool activating = _controllerSystolic.text.isNotEmpty && _controllerDiastolic.text.isNotEmpty;
    if (_isInputHeartRate) {
      activating = activating && _controllerHeart.text.isNotEmpty;
    }
    return activating;
  }

  @override
  void initState() {
    super.initState();
    if (widget.type == 'update') {
      _loadConfig(false).then((value) {
        _loadDataDetail();
      });
    } else {
      _loadConfig();
    }
    _loadDescription();
    _firebaseSetup();
    _initData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _controllerSystolic.dispose();
    _controllerDiastolic.dispose();
    _controllerHeart.dispose();
    _controllerNote.dispose();
    super.dispose();
  }

  void _doGuide() async {
    Navigator.of(context).pushNamed(NavigatorName.blood_pressure_intro_2nd_page);
  }

  void _initData() async {
    BotToast.showLoading();

    // Init input heart rate at the first time
    bool? willInputHeartRate = await AppSettings.getInputHeartRateWithBloodPressure();
    if (willInputHeartRate == null) {
      willInputHeartRate = true;
      AppSettings.setInputHeartRateWithBloodPressure(willInputHeartRate);
    } else {
      _isInputHeartRate = willInputHeartRate;
    }
    try {
      Map<String, List<int>> ranges = await BloodPressureClient().fetchRange();
      _rangeValueSystolic = ranges['systolic']!;
      _rangeValueDiastolic = ranges['diastolic']!;
      isLoading = false;
      BotToast.closeAllLoading();
    } catch (e) {
      // Handle errors
      print('Error: $e');
      BotToast.showText(text: 'Error fetching data');
      isLoading = false;
      BotToast.closeAllLoading();
    }
  }

  Future<void> _firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
        screenName: "kpi_blood_pressure_add", screenClass: "AddBloodPressureController");

    AppSettings.currentScreenName = 'kpi_blood_pressure_add';
    await TrackingManager.analytics.logEvent(
      name: 'kpi_glycemic_add',
      parameters: {
        "screen_name": 'kpi_blood_pressure_add',
        'object_type': 'kpi_blood_pressure',
        'object_title': 'Chỉ số huyết áp'
      },
    );
  }

  void _loadDataDetail() async {
    BotToast.showLoading();
    model = await BloodPressureClient().fetchBloodPressureDetail(widget.id);
    BotToast.closeAllLoading();

    if (model != null) {
      _controllerSystolic.text = model!.systolic?.toInt().toString() ?? '';
      _controllerDiastolic.text = model!.diastolic?.toInt().toString() ?? '';
      _controllerHeart.text = model!.pulseRate?.toInt().toString() ?? '';
      _controllerNote.text = model?.note ?? '';
      selectedDate = DateTime.fromMillisecondsSinceEpoch(model!.date! * 1000);
      _files.addAll(model!.images);
      if (_sectionAddNoteKey.currentState != null) {
        _sectionAddNoteKey.currentState!.updateFilesAndNote(_files, model?.note ?? '');
      }
      if (_times.isNotEmpty) {
        if (model!.timeFrameId == null) {
          _lastTimeFrameIndex = 0;
          _selectedTimeFrame = _times.first;
        } else {
          _lastTimeFrameIndex =
              _times.indexWhere((timeFrame) => timeFrame.id == model!.timeFrameId);
          if (_lastTimeFrameIndex != -1) {
            _selectedTimeFrame = _times[_lastTimeFrameIndex];
          }
        }
      }
    }
    if ((_selectedTimeFrame == null || _lastTimeFrameIndex == -1) && _times.isNotEmpty) {
      _lastTimeFrameIndex = 0;
      _selectedTimeFrame = _times.first;
    }
    _checkValidateInput();
    setState(() {});
  }

  Future<void> _loadConfig([bool needSelectTimeFrame = true]) async {
    BotToast.showLoading();
    final result = await Future.wait([
      BloodPressureClient().fetchBloodPressureTimeFrame(),
      BloodPressureClient().fetchColorConfig(),
      BloodPressureClient()
          .fetchBloodPressureTimeFrame(time: selectedDate.millisecondsSinceEpoch ~/ 1000),
    ]);
    BloodPressureClient().fetchReasons().then((value) {
      _reasons = value;
    });
    if (result.length > 2) {
      final timeFrames = result[0] as List<TimeFrameModel>;
      _times.clear();
      _times.addAll(timeFrames);
      final colors = result[1] as List<BloodPressureColorConfig>?;
      if (needSelectTimeFrame) {
        final timeFramesSelected = result[2] as List<TimeFrameModel>?;
        if (timeFramesSelected?.isNotEmpty == true &&
            timeFrames.any((e) => timeFramesSelected!.first.id == e.id)) {
          final firstTimeframeId = timeFramesSelected!.first.id;
          _selectedTimeFrame = timeFrames.where((e) => firstTimeframeId == e.id).first;
          _lastTimeFrameIndex = _times.indexWhere((timeFrame) => timeFrame.id == firstTimeframeId);
        } else {
          _selectedTimeFrame = timeFrames.first;
          _lastTimeFrameIndex = 0;
        }
      }

      if (colors != null) {
        _colorList = colors.map(((e) {
          return Color(int.parse("0xFF" + e.background.substring(1)));
        })).toList();
        _rangeLabel = colors.map(((e) => e.name)).toList();
      }
    }
    BotToast.closeAllLoading();
    setState(() {});
  }

  void _loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(2);
    setState(() {});
  }

  void _onTapDateTime() async {
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
        },
      ),
    );
  }

  void _doHealthConnect() async {
    RequestHealthConnect.showModal(context, callback: () => Navigator.pop(context));
  }

  BloodPressureRangeType _fromIndexDetected(int index) {
    return BloodPressureRangeType.fromInt(index + 1);
  }

  bool _isDataChange() {
    // If no original model exists, consider it as new data
    if (model == null) {
      return true;
    }

    // Check if number/index has changed
    final currentSystolicInputStr = _controllerSystolic.text;
    final originalSystolicValueStr = roundNumber(model!.systolic!);

    if (currentSystolicInputStr != originalSystolicValueStr) {
      return true;
    }

    // Check if diastolic input has changed
    final currentDiastolicInputStr = _controllerDiastolic.text;
    final originalDiastolicValueStr = roundNumber(model!.diastolic!);
    if (currentDiastolicInputStr != originalDiastolicValueStr) {
      return true;
    }

    // Check if heart rate input has changed
    final currentHeartRateInputStr = _controllerHeart.text;
    final originalHeartRateValueStr = roundNumber(model!.pulseRate ?? 0);
    if (currentHeartRateInputStr != originalHeartRateValueStr) {
      return true;
    }

    // Check if note has changed
    final currentNote = _controllerNote.text;
    if (currentNote != (model!.note ?? '')) {
      return true;
    }

    // Check if date has changed
    // final originalDate =
    //     DateTime.fromMillisecondsSinceEpoch(model!.createDate! * 1000);
    // if (selectedDate.millisecondsSinceEpoch !=
    //     originalDate.millisecondsSinceEpoch) {
    //   return true;
    // }

    // Check if images have changed (either count or removals)
    if (_files.length != model!.images.length || removeIDs.isNotEmpty) {
      return true;
    }

    // No changes detected
    return false;
  }

  void _navigateAfterSuccess(
      String id, List<ImagesModel> images, List<String> reasons, String pulseRateStatus,
      [bool? isDataChange = false]) {
    // Observable.instance.notifyObservers([], notifyName: "glucose_change_data");
    double _valueOfSystolic = double.tryParse(_controllerSystolic.text.replaceAll(",", ".") != ""
        ? _controllerSystolic.text.replaceAll(",", ".")
        : "0")!;
    double _valueOfDiastolic = double.tryParse(_controllerDiastolic.text.replaceAll(",", ".") != ""
        ? _controllerDiastolic.text.replaceAll(",", ".")
        : "0")!;
    int indexRange = _determineBloodPressureType(_valueOfSystolic, _valueOfDiastolic);
    BloodPressureRangeType rangeType = _fromIndexDetected(indexRange);
    final data = BloodPressureResultDto(
      id: id,
      dateTime: selectedDate,
      timeFrameId: _selectedTimeFrame?.id ?? '',
      timeFrame: _selectedTimeFrame?.name?.tr() ?? '',
      rangeValue: _rangeValueSystolic.map((e) => e.toDouble()).toList(),
      indexRange: indexRange,
      rangeColors: _colorList,
      diastolic: _valueOfDiastolic,
      systolic: _valueOfSystolic,
      pulse: _isInputHeartRate ? double.parse(_controllerHeart.text) : 0,
      pulseRateStatus: pulseRateStatus,
      reasons: reasons,
      note: _controllerNote.text,
      files: images,
      rangeType: rangeType,
      isFetchAnalysis: isDataChange,
      healthRecommendation: null, // TODO: fill healthRecommendation
      goalId: widget.goalId,
      isNew: widget.type == 'update' ? false : true,
    );
    Navigator.of(context)
        .pushReplacementNamed(NavigatorName.add_bloodpressure_result, arguments: data);
  }

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
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              _appBarSection(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: R.color.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _dateTimeSectionV2(),
                            const SizedBox(height: 24),
                            _inputSection(),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: _bloodPressureRange(),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: _dateTimeFrameV2(),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: R.color.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _heartRateSection(),
                      ),
                      const SizedBox(height: 16),
                      _noteSection(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: _showInputWithHealthConnect(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              _buildButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _appBarSection() {
    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      centerTitle: false,
      title: Text(
        widget.type == 'update'
            ? R.string.update_blood_pressure.tr()
            : R.string.enter_blood_pressure.tr(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: R.color.white,
        ),
      ),
      leadingIcon: IconButton(
          splashColor: R.color.white,
          highlightColor: R.color.white,
          icon: Icon(Icons.arrow_back, color: R.color.white),
          onPressed: () {
            _showDialogSave();
          }),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 12.0),
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
                  convertToUTC(selectedDate.millisecondsSinceEpoch ~/ 1000, 'HH:mm - dd/MM/yyyy'),
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

  Widget _inputSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: R.color.color0xffDFE4E4,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // dummy text
          Opacity(
            opacity: 0,
            child: Text(R.string.mm_hg.tr(),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
          ),
          Column(
            children: [
              Container(
                width: 90,
                child: TextField(
                  autofocus: widget.type != 'update',
                  focusNode: _systolicFocus,
                  onChanged: (value) {
                    _checkValidateInput();
                    if (value.length == 3) {
                      _diastolicFocus.requestFocus();
                    }
                    setState(() {});
                  },
                  controller: _controllerSystolic,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(3),
                  ],
                  textAlign: TextAlign.right,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: R.color.black, fontSize: 48, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                      hintText: '0',
                      counterText: '',
                      contentPadding: EdgeInsets.only(bottom: 8),
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                          color: R.color.captionColorGray,
                          fontSize: 48,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 3, right: 3),
            child: Text('/',
                style: TextStyle(
                  fontSize: 42,
                  color: Color(0xFF636A6B),
                )),
          ),
          Column(
            children: [
              Container(
                width: 90,
                child: TextField(
                  focusNode: _diastolicFocus,
                  onChanged: (value) {
                    _checkValidateInput();
                    if (value.length == 3) {
                      _heartFocus.requestFocus();
                    }
                    setState(() {});
                  },
                  controller: _controllerDiastolic,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(3),
                  ],
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: R.color.black, fontSize: 48, fontWeight: FontWeight.w500),
                  decoration: InputDecoration(
                    hintText: '0',
                    contentPadding: EdgeInsets.only(bottom: 8),
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        color: R.color.captionColorGray, fontSize: 48, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
          Text(R.string.mm_hg.tr(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _bloodPressureRange() {
    // double? _number = 0;
    double _valueOfSystolic = 0;
    double _valueOfDiastolic = 0;

    try {
      _valueOfSystolic = double.tryParse(_controllerSystolic.text.replaceAll(",", ".") != ""
          ? _controllerSystolic.text.replaceAll(",", ".")
          : "0")!;
      _valueOfDiastolic = double.tryParse(_controllerDiastolic.text.replaceAll(",", ".") != ""
          ? _controllerDiastolic.text.replaceAll(",", ".")
          : "0")!;
    } catch (e) {
      _valueOfSystolic = 0;
      _valueOfDiastolic = 0;
    }

    int indexRangeSystolic = _findIndexInRanges(_valueOfSystolic, _rangeValueSystolic);
    int indexRangeDiastolic = _findIndexInRanges(_valueOfDiastolic, _rangeValueDiastolic);
    // 12*2 side padding + 16*2 component padding
    num widthRange = (AppMediaQuery.deviceWidth - (12 * 2) - (12 * 2)) / (_rangeLabel.length + 1);
    widthRange = widthRange.roundToDouble();

    // num width = _number == 0 ? 0 : widthRange * (indexRange);
    num widthOfSystolic = _valueOfSystolic == 0 ? 0 : widthRange * (indexRangeSystolic);
    if (indexRangeSystolic >= 2) {
      widthOfSystolic += widthRange;
    } else {
      widthOfSystolic *= 2;
    }
    num widthDiastolic = _valueOfDiastolic == 0 ? 0 : widthRange * (indexRangeDiastolic);
    if (indexRangeDiastolic >= 2) {
      widthDiastolic += widthRange;
    } else {
      widthDiastolic *= 2;
    }

    if (_valueOfDiastolic != 0 || _valueOfSystolic != 0) {
      num minSystolic = _rangeValueSystolic[indexRangeSystolic];
      num minDiastolic = _rangeValueDiastolic[indexRangeDiastolic];

      num maxSystolic = indexRangeSystolic + 1 >= _rangeValueSystolic.length
          ? _rangeValueSystolic[indexRangeSystolic] + minSystolic
          : _rangeValueSystolic[indexRangeSystolic + 1];
      num maxDiastolic = indexRangeDiastolic + 1 >= _rangeValueDiastolic.length
          ? _rangeValueDiastolic[indexRangeDiastolic] + minDiastolic
          : _rangeValueDiastolic[indexRangeDiastolic + 1];

      num maximumValueSystolic = maxSystolic - minSystolic;
      num maximumValueDiastolic = maxDiastolic - minDiastolic;

      num pxPerValueSystolic = widthRange / maximumValueSystolic;
      num pxPerValueDiastolic = widthRange / maximumValueDiastolic;

      num widthPlusSystolic = pxPerValueSystolic * (_valueOfSystolic - minSystolic);
      num widthPlusDiastolic = pxPerValueDiastolic * (_valueOfDiastolic - minDiastolic);

      widthOfSystolic += widthPlusSystolic;
      widthDiastolic += widthPlusDiastolic;

      widthOfSystolic = widthOfSystolic > (widthRange * _rangeValueSystolic.length)
          ? widthRange * _rangeValueSystolic.length
          : widthOfSystolic;
      widthDiastolic = widthDiastolic > (widthRange * _rangeValueDiastolic.length)
          ? widthRange * _rangeValueDiastolic.length
          : widthDiastolic;
    }
    int indexRange = _determineBloodPressureType(_valueOfSystolic, _valueOfDiastolic);
    return SpacingColumn(
      spacing: 16,
      children: [
        if (_isNotValidInput)
          Text(
            'Chỉ số không hợp lệ!',
            style: TextStyle(color: Color(0xFFFF3C3C), fontSize: 13, fontWeight: FontWeight.w400),
          )
        else if (_valueOfSystolic != 0 && _valueOfDiastolic != 0)
          RichText(
            text: TextSpan(
              text: 'Huyết áp đang ở mức ',
              style: TextStyle(color: R.color.textDark, fontWeight: FontWeight.w400, fontSize: 16),
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
            // height for all elements = 100
            Container(height: 100, width: double.infinity),
            Positioned.fill(
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Row(
                    children: _colorList.asMap().entries.map(
                      (entry) {
                        return Expanded(
                          flex: entry.key == 0 ? 2 : 1,
                          child: Container(
                            height: 8,
                            color: entry.value,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
              ),
            ),
            // Arrow diastolic
            Positioned(
              left: widthDiastolic.toDouble() - 18,
              bottom: -5,
              child: Container(child: Icon(Icons.arrow_drop_up_rounded, size: 40)),
            ),
            // Arrow systolic
            Positioned(
              left: widthOfSystolic.toDouble() - 18,
              top: -5,
              child: Container(child: Icon(Icons.arrow_drop_down_rounded, size: 40)),
            ),
            // Range diastolic (text values)
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 28),
                  child: Row(
                      children: _rangeValueDiastolic
                          .map(
                            (e) => Expanded(
                              flex: e == 0 ? 2 : 1,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  SizedBox(),
                                  Positioned(
                                    left: e == 0
                                        ? 0
                                        : e.toString().length == 3
                                            ? -10
                                            : -6,
                                    child: e == 0
                                        ? Text(
                                            'Tâm trương',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : Text(
                                            '$e',
                                            style: TextStyle(
                                              fontSize: 12,
                                              // Default style for other values of e
                                            ),
                                          ),
                                  )
                                ],
                              ),
                            ),
                          )
                          .toList()),
                ),
              ),
            ),
            // Range systolic (text values)
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Row(
                      children: _rangeValueSystolic
                          .map(
                            (e) => Expanded(
                              flex: e == 0 ? 2 : 1,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  SizedBox(),
                                  Positioned(
                                    left: e == 0
                                        ? 0
                                        : e.toString().length == 3
                                            ? -10
                                            : -8,
                                    child: e == 0
                                        ? Text(
                                            'Tâm thu',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : Text(
                                            '$e',
                                            style: TextStyle(
                                              fontSize: 12,
                                              // Default style for other values of e
                                            ),
                                          ),
                                  )
                                ],
                              ),
                            ),
                          )
                          .toList()),
                ),
              ),
            ),
            // Range systolic (separator)
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                      children: _rangeValueSystolic
                          .asMap()
                          .entries
                          .map(
                            (entry) => Expanded(
                              flex: entry.key == 0 ? 2 : 1,
                              child: Container(
                                width: 30,
                                child: Text(
                                  '|',
                                  style: TextStyle(
                                    color: entry.key == 0 ? Colors.transparent : Color(0xFFD7D7D7),
                                    fontSize: 5,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList()),
                ),
              ),
            ),
            // Range diastolic (separator)
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Row(
                      children: _rangeValueDiastolic
                          .asMap()
                          .entries
                          .map(
                            (entry) => Expanded(
                              flex: entry.key == 0 ? 2 : 1,
                              child: Container(
                                width: 30,
                                child: Text(
                                  '|',
                                  style: TextStyle(
                                    color: entry.key == 0 ? Colors.transparent : Color(0xFFD7D7D7),
                                    fontSize: 5,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dateTimeFrameV2() {
    return Container(
      width: double.infinity,
      height: 32.h,
      child: ToggleButtonsHorizontal(
        names: _times.map((e) => e.name!).toList(),
        flexes: List.generate(_times.length, (index) => 1),
        backgroundColor: Color(0xFFF2F6F9),
        selectedIndex: _lastTimeFrameIndex,
        selectionTextStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
        onChange: (index) async {
          _lastTimeFrameIndex = index;
          _selectedTimeFrame = _times[index];
          try {
            BotToast.showLoading();
            // TODO: BLOOD PRESSURE
            // await _getGlucoseRange(selectedTimeFrame!);
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

  Widget _heartRateSection() {
    return Container(
      decoration: BoxDecoration(
        color: R.color.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  R.string.heart_rate.tr(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              CupertinoSwitch(
                value: _isInputHeartRate,
                onChanged: (bool value) {
                  setState(() {
                    _isInputHeartRate = value;
                  });
                  AppSettings.setInputHeartRateWithBloodPressure(value);
                },
                activeColor: R.color.greenGradientBottom,
              ),
            ],
          ),
          if (_isInputHeartRate) ...[
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, right: 4),
                    child: SizedBox(
                      width: 120,
                      child: TextField(
                        focusNode: _heartFocus,
                        onChanged: (value) {
                          // _checkValidateInput();
                          setState(() {});
                        },
                        controller: _controllerHeart,
                        textAlign: TextAlign.right,
                        maxLength: 3,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            color: R.color.black, fontSize: 48, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: '0',
                          counterText: '',
                          contentPadding: EdgeInsets.only(bottom: 8),
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                              color: R.color.captionColorGray,
                              fontSize: 48,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(R.string.time_per_minute.tr(),
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2),
            Container(height: 1, width: double.infinity, color: R.color.color0xffE5E5E5),
            if (_isNotValidHeartRate)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Center(
                  child: Text(
                    'Chỉ số không hợp lệ!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFF3C3C),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              )
          ],
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _noteSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SectionAddNote(
        focusNode: _focusNode,
        controllerNote: _controllerNote,
        maxMedia: 5,
        key: _sectionAddNoteKey,
        initialFiles: _files,
        noteTitle: R.string.ghi_chu.tr(),
        horizontalPadding: 12,
      ),
    );
  }

  Widget _showInputWithHealthConnect() {
    return FutureBuilder(
      future: AppStorages.getHealthAppPermission(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || snapshot.hasError) {
          return SizedBox.shrink();
        }

        if (snapshot.hasData) {
          bool? hasPermission = snapshot.data as bool?;
          if (hasPermission == true) {
            return SizedBox.shrink();
          }
        }

        String healthIcon =
            Platform.isIOS ? R.drawable.logo_healthkit : R.drawable.logo_healthConnect;
        String healthTitle = Platform.isIOS
            ? R.string.connect_from_Apple_Health.tr()
            : R.string.connect_from_Health_Connect.tr();
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 235,
              height: 20,
              alignment: Alignment.center,
              child: Row(
                children: [
                  Expanded(child: Container(height: 1, color: R.color.greenGradientBottom)),
                  Text(
                    '   ${R.string.or.tr()}   ',
                    style: TextStyle(
                      fontSize: 14,
                      color: R.color.greenGradientBottom,
                    ),
                  ),
                  Expanded(child: Container(height: 1, color: R.color.greenGradientBottom)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _doHealthConnect,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                decoration: BoxDecoration(
                  color: R.color.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                height: 64,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(healthIcon, width: 40, height: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        healthTitle,
                        style: TextStyle(
                          fontSize: 15,
                          color: R.color.dark,
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
            ),
          ],
        );
      },
    );
  }

  Widget _buildButton() {
    return widget.type == 'input'
        ? GestureDetector(
            onTap: _isInputEnough
                ? () async {
                    _submitData();
                  }
                : null,
            child: SafeArea(
              top: false,
              child: Container(
                  margin: EdgeInsets.only(top: 16, bottom: 16, left: 12, right: 12),
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: R.color.mainColor,
                      borderRadius: BorderRadius.circular(200),
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.centerRight,
                          colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
                  child: Center(
                      child: Text(R.string.confirm.tr(),
                          style: TextStyle(
                              color: R.color.white, fontWeight: FontWeight.w600, fontSize: 16)))),
            ),
          )
        : SafeArea(
            top: false,
            child: Container(
                margin: EdgeInsets.all(16),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  GestureDetector(
                    onTap: () {
                      _showDialogDelete(context);
                    },
                    child: Container(
                        height: 48,
                        width: 164,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(200),
                            border: Border.all(color: R.color.red, width: 2)),
                        child: Center(
                          child: Text(R.string.xoa_du_lieu.tr(),
                              style: TextStyle(
                                  color: R.color.red, fontSize: 16, fontWeight: FontWeight.w600)),
                        )),
                  ),
                  GestureDetector(
                    onTap: _isInputEnough
                        ? () {
                            _editData();
                          }
                        : null,
                    child: Container(
                      height: 48,
                      width: 164,
                      decoration: BoxDecoration(
                          color: R.color.mainColor,
                          borderRadius: BorderRadius.circular(200),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.centerRight,
                              colors: [R.color.greenGradientTop, R.color.greenGradientBottom])),
                      child: Center(
                        child: Text(R.string.confirm.tr(),
                            style: TextStyle(
                                color: R.color.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ])),
          );
  }

  int _determineBloodPressureType(double systolic, double diastolic) {
    int systolicIndex = -1;
    int diastolicIndex = -1;

    for (int i = 0; i < _rangeValueSystolic.length - 1; i++) {
      if (systolic >= _rangeValueSystolic[i] && systolic < _rangeValueSystolic[i + 1]) {
        systolicIndex = i;
        break;
      }
    }

    for (int i = 0; i < _rangeValueDiastolic.length - 1; i++) {
      if (diastolic >= _rangeValueDiastolic[i] && diastolic < _rangeValueDiastolic[i + 1]) {
        diastolicIndex = i;
        break;
      }
    }

    int typeIndex = -1;

    switch (systolicIndex) {
      case 0:
        if (diastolicIndex == 0) {
          typeIndex = 0;
        }
        break;
      case 1:
        if (diastolicIndex == 1) {
          typeIndex = 1;
        }
        break;
      case 2:
        if (diastolicIndex == 2) {
          typeIndex = 2;
        }
        break;
      case 3:
        if (diastolicIndex == 3) {
          typeIndex = 3;
        }
        break;
      case 4:
        if (diastolicIndex == 4) {
          typeIndex = 4;
        }
        break;
      case 5:
        typeIndex = 5;
        break;
      default:
        typeIndex = -1; // None
    }

    if (typeIndex == -1) {
      if (systolic > diastolic) {
        typeIndex = _determineCustomTypeIndex(systolic, false);
      } else if (systolic < diastolic) {
        typeIndex = _determineCustomTypeIndex(diastolic, true);
      } else if (systolic == diastolic) {
        typeIndex = _determineCustomTypeIndex(systolic, false);
      }
    }

    return typeIndex;
  }

  int _determineCustomTypeIndex(double value, bool isDiastolic) {
    if (isDiastolic) {
      if (value < 60)
        return 0;
      else if (value >= 60 && value < 85)
        return 1;
      else if (value >= 85 && value < 90)
        return 2;
      else if (value >= 90 && value < 100)
        return 3;
      else if (value >= 100 && value < 110)
        return 4;
      else
        return 5;
    } else {
      if (value < 90)
        return 0;
      else if (value >= 90 && value < 130)
        return 1;
      else if (value >= 130 && value < 140)
        return 2;
      else if (value >= 140 && value < 160)
        return 3;
      else if (value >= 160 && value < 180)
        return 4;
      else
        return 5;
    }
  }

  int _findIndexInRanges(double number, List<int> ranges) {
    for (int i = 0; i < ranges.length - 1; i++) {
      if (number >= ranges[i] && number < ranges[i + 1]) {
        return i;
      }
    }
    // If the number is greater than or equal to the last range value
    return ranges.length - 1;
  }

  void _checkValidateInput() async {
    final systolic = _controllerSystolic.text;
    final diastolic = _controllerDiastolic.text;
    if (systolic.isNotEmpty && diastolic.isNotEmpty) {
      try {
        final result = await BloodPressureClient().checkBloodPressureInput(systolic, diastolic);
        setState(() {
          textValidate = result;
          // TODO: BLOOD PRESSURE
          // if (textValidate!.isEmpty) {
          //   _controllerReason.text = '';
          // }
        });
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
  }

  void _deleteData() async {
    try {
      BotToast.showLoading();
      final result = await BloodPressureClient().deleteBloodPressureInput(widget.id);
      if (result == true) {
        Message.showToastMessage(context, R.string.xoa_thanh_cong.tr());
        Observable.instance.notifyObservers([], notifyName: "BloodPressure_change_data");
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

  bool _validateInput(String systolic, String diastolic, String pulseRate) {
    if (systolic.isEmpty) {
      Message.showToastMessage(context, R.string.mes_systolic_empty.tr());
      return false;
    }
    if (diastolic.isEmpty) {
      Message.showToastMessage(context, R.string.mes_diastolic_empty.tr());
      return false;
    }
    if (_isInputHeartRate) {
      int pulseRateValue = int.tryParse(pulseRate.replaceAll(',', '.')) ?? 0;
      if (pulseRateValue < 40 || pulseRateValue > 300) {
        Message.showToastMessage(context, R.string.mes_heart_rate_invalid.tr());
        return false;
      }
    }
    if (_selectedTimeFrame == null) {
      Message.showToastMessage(context, R.string.ban_chua_chon_khung_gio.tr());
      return false;
    }
    return true;
  }

  void _editData() async {
    // prevent submit button
    if (_isNotValidInput) return;
    if (_isInputHeartRate && _isNotValidHeartRate) return;

    FocusScope.of(context).unfocus();
    final systolic = _controllerSystolic.text;
    final diastolic = _controllerDiastolic.text;
    final pulseRate = _isInputHeartRate ? _controllerHeart.text : '';

    if (!_validateInput(systolic, diastolic, pulseRate)) return;

    try {
      List<String> paths = [];
      final data = _sectionAddNoteKey.currentState!.getNote();
      for (var file in (data.files)) {
        if (file is PickedFile) {
          paths.add(file.path);
        }
      }
      final reasonsOrNull = await _showReasonsDialog('', systolic, diastolic);
      if (reasonsOrNull == false) {
        // request focus on systolic input
        _systolicFocus.requestFocus();
        return;
      }
      BotToast.showLoading();
      final result = await BloodPressureClient().updateBloodPressureInput(
          widget.id,
          systolic,
          diastolic,
          pulseRate,
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          _selectedTimeFrame!.id,
          data.note, // updated to use data.note
          '', // reason
          data.removeIDs,
          paths);
      if (result != null) {
        List<String> reasons = [];
        if (reasonsOrNull is List<KeyValue>) {
          final List<String> reasonKeys = reasonsOrNull.map((e) => e.key).toList();
          if (reasonKeys.isNotEmpty) {
            await BloodPressureClient().updateReasons(result.id, reasonKeys);
          }
          reasons = reasonsOrNull.map((e) => e.value).toList();
        }
        _navigateAfterSuccess(
            result.id, result.images, reasons, result.pulseRateStatus, _isDataChange());
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

  void _submitData() async {
    // prevent submit button
    if (_isNotValidInput) return;
    if (_isInputHeartRate && _isNotValidHeartRate) return;

    FocusScope.of(context).unfocus();
    final systolic = _controllerSystolic.text;
    final diastolic = _controllerDiastolic.text;
    final pulseRate = _isInputHeartRate ? _controllerHeart.text : '';

    if (!_validateInput(systolic, diastolic, pulseRate)) return;

    try {
      List<String> paths = [];
      final data = _sectionAddNoteKey.currentState!.getNote();
      for (var file in (data.files)) {
        // newly add from system
        paths.add(file.path);
      }
      final reasonsOrNull = await _showReasonsDialog('', systolic, diastolic);
      if (reasonsOrNull == false) {
        // request focus on systolic input
        _systolicFocus.requestFocus();
        return;
      }
      BotToast.showLoading();
      final result = await BloodPressureClient().postBloodPressureInput(
          systolic,
          diastolic,
          pulseRate,
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          _selectedTimeFrame!.id,
          data.note,
          '', // reason
          paths);
      if (result != null) {
        // await TrackingManager.analytics.logEvent(
        //   name: 'kpi_add_success',
        //   parameters: {
        //     "screen_name": 'kpi_blood_pressure_add',
        //     'object_type': 'kpi_blood_pressure',
        //     'object_title': 'Chỉ số huyết áp'
        //   },
        // );
        List<String> reasons = [];
        if (reasonsOrNull is List<KeyValue>) {
          final List<String> reasonKeys = reasonsOrNull.map((e) => e.key).toList();
          if (reasonKeys.isNotEmpty) {
            await BloodPressureClient().updateReasons(result.id, reasonKeys);
          }
          reasons = reasonsOrNull.map((e) => e.value).toList();
        }
        _navigateAfterSuccess(result.id, result.images, reasons, result.pulseRateStatus);
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

  Future<dynamic> _showReasonsDialog(String id, String systolic, String diastolic) async {
    double systolicValue = double.tryParse(systolic.replaceAll(",", ".")) ?? 0;
    double diastolicValue = double.tryParse(diastolic.replaceAll(",", ".")) ?? 0;
    int indexRange = _determineBloodPressureType(systolicValue, diastolicValue);
    BloodPressureRangeType detectedType = _fromIndexDetected(indexRange);
    if (detectedType.value > BloodPressureRangeType.normal_high.value) {
      final reasons = _reasons ?? await BloodPressureClient().fetchReasons();
      if (reasons.isEmpty) {
        return [];
      }
      // show input reason dialog
      return showDialog(
          context: context,
          builder: (context) {
            return BloodPressureWarningPopupWidget(
              reasons: reasons,
            );
          });
    }
    return null;
  }

  void _showDialogDelete(BuildContext context) {
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
                      Image.asset(R.drawable.ic_earse, width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(R.string.ban_muon_xoa_du_lieu.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(R.string.confirm_to_remove_data.tr(),
                            textAlign: TextAlign.center, style: R.style.normalTextStyle),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 16),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                  height: 43,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(200),
                                      color: R.color.grayBorder),
                                  child: Center(
                                    child: Text(R.string.back.tr(),
                                        style: TextStyle(
                                            color: R.color.textDark,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  )),
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                _deleteData();
                              },
                              child: Container(
                                height: 43,
                                decoration: BoxDecoration(
                                  color: R.color.red,
                                  borderRadius: BorderRadius.circular(200),
                                ),
                                child: Center(
                                  child: Text(R.string.delete.tr(),
                                      style: TextStyle(
                                          color: R.color.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                ),
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
    final systolic = _controllerSystolic.text;
    final diastolic = _controllerDiastolic.text;
    final pulseRate = _controllerHeart.text;
    final note = _controllerNote.text;
    final reason = '';
    if (model != null) {
      final noteText = model!.note ?? '';
      final reasonText = model!.reason ?? '';
      final date = DateTime.fromMillisecondsSinceEpoch(model!.date! * 1000);
      if (systolic == model!.systolic!.toInt().toString() &&
          diastolic == model!.diastolic!.toInt().toString() &&
          pulseRate == model!.pulseRate!.toInt().toString() &&
          note == noteText &&
          reasonText == reason &&
          _files.length == model!.images.length &&
          removeIDs.length == 0 &&
          date.millisecondsSinceEpoch == selectedDate.millisecondsSinceEpoch &&
          _selectedTimeFrame!.id == model!.timeFrameId) {
        Navigator.pop(context);
        return;
      }
    } else if (systolic.isEmpty &&
        diastolic.isEmpty &&
        pulseRate.isEmpty &&
        note.isEmpty &&
        _files.length == 0) {
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
                      Image.asset(R.drawable.ic_back_icon, width: 64, height: 64),
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
                            textAlign: TextAlign.center, style: R.style.normalTextStyle),
                      ),
                      SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Expanded(
                          child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                  height: 43,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(200),
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
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 43,
                                decoration: BoxDecoration(
                                    color: R.color.red,
                                    borderRadius: BorderRadius.circular(200),
                                    gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          R.color.greenGradientTop,
                                          R.color.greenGradientBottom
                                        ])),
                                child: Center(
                                  child: Text(R.string.confirm.tr(),
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
    super.initState();
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
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(R.string.pick_date.tr(),
                            style: TextStyle(
                                color: R.color.black, fontSize: 16, fontWeight: FontWeight.w700)),
                        IconButton(
                            icon: Icon(Icons.close, color: R.color.color0xffBEC0C8),
                            onPressed: () {
                              Navigator.pop(context);
                            })
                      ]),
                    ),
                    CustomCalendarDatePicker(
                        initialDate: widget.initDate == null ? DateTime.now() : widget.initDate!,
                        firstDate: DateTime.parse("1969-07-20 20:18:04Z"),
                        lastDate: DateTime.now(),
                        onDateChanged: (datetime) {
                          selectedDate = datetime ?? DateTime.now();
                        }),
                    Row(
                      children: [
                        SizedBox(
                          width: 16,
                        ),
                        Text(R.string.pick_time.tr(),
                            style: TextStyle(
                                color: R.color.black, fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    SizedBox(height: 20),
                    CustomTimePicker(
                        selectedHour: selectedHour,
                        selectedMinute: selectedMinute,
                        callback: (hour, minute) {
                          selectedHour = hour ?? DateTime.now().hour;
                          selectedMinute = minute ?? DateTime.now().minute;
                        }),
                    SizedBox(height: 20),
                    Row(children: [
                      SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
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
                          onTap: () {
                            selectedDate = DateTime(selectedDate!.year, selectedDate!.month,
                                selectedDate!.day, selectedHour, selectedMinute);

                            widget.callback!(selectedDate);

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
  DateTime now = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedHour = now.hour;
    selectedMinute = now.minute;
    if (widget.selectedHour != null) {
      selectedHour = widget.selectedHour;
    }
    if (widget.selectedMinute != null) {
      selectedMinute = widget.selectedMinute;
    }
    hourController = FixedExtentScrollController(initialItem: selectedHour!);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute!);
  }

  // Check if a time is in the future
  bool _isTimeInFuture(int hour, int minute) {
    final now = DateTime.now();
    return now.hour < hour || (now.hour == hour && now.minute < minute);
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
                    // Prevent selecting future hours on current date
                    if (_isTimeInFuture(value, selectedMinute ?? 0)) {
                      // Reset to current hour and minute
                      selectedHour = now.hour;
                      selectedMinute = now.minute;
                      hourController!.jumpToItem(selectedHour!);
                      minuteController!.jumpToItem(selectedMinute!);
                    } else {
                      selectedHour = value;
                      widget.callback!(selectedHour, selectedMinute);
                    }
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
                    // Prevent selecting future minutes in the current hour
                    if (_isTimeInFuture(selectedHour ?? 0, value)) {
                      // Reset to current minute
                      selectedMinute = now.minute;
                      minuteController!.jumpToItem(selectedMinute!);
                    } else {
                      selectedMinute = value;
                      widget.callback!(selectedHour, selectedMinute);
                    }
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
