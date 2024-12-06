import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/glucose/glucose_input.dart';
import 'package:medical/src/modal/glucose/glucose_range_data.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/modal/user/schedule_glucose_time.dart';
import 'package:medical/src/model/response/config/glucose_color_config.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/BloodSugar/widget/action_list_trend.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';
import 'package:medical/src/widget/nipro/roche_connection/roche_connection_view.dart';
import 'package:medical/src/widgets/btn_add_photo.dart';
import 'package:medical/src/widgets/custom_checkbox_widget.dart';
import 'package:medical/src/widgets/spacing_row.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/CalendarPicker/custom_date_picker.dart';
import '../../widgets/network_image_widget.dart';
import '../my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'widget/level_off_diabetes_rule_picker.dart';

class AddBloodSugarControllerNew extends StatefulWidget {
  final String? type;
  final String? id;
  final String? goalId;

  AddBloodSugarControllerNew({this.type, this.id, this.goalId});

  @override
  _AddBloodSugarControllerNewState createState() =>
      _AddBloodSugarControllerNewState();
}

class _AddBloodSugarControllerNewState
    extends BaseState<AddBloodSugarControllerNew>
    with SingleTickerProviderStateMixin {
  TextEditingController _controller = TextEditingController();
  TextEditingController _controllerNote = TextEditingController();
  int maxMedia = 5;
  List<dynamic> files = [];
  DateTime selectedDate = DateTime.now();
  bool isClicked = false;
  TimeFrameModel? selectedTimeFrame;
  bool isFocus = false;
  bool isChangeStatus = false;
  List<int> _rangeValue = [0, 60, 70, 95, 180];
  List<String> _rangeLabel = ['Rất thấp', "Thấp", 'Tốt', 'Cao', "Rất cao"];
  List<Color> _colorList = [
    Color(0xFFF48222),
    Color(0xFFF9B816),
    Color(0xFF02635A),
    Color(0xFFFE0201),
    Color(0xFFB3020C),
  ];
  double? number = 0;
  InputGlucoseModel? model;
  List<String?> removeIDs = [];
  ShortGuiModel? des;
  double mmollToMgdlFactor = 18.018;
  bool fromNipro = false;
  bool isMgPerDl = false;
  bool isPregnancy = false;
  int clickTime = 0;

  FocusNode _focusNode = FocusNode();
  FocusNode _focusNodeKPI = FocusNode();

  @override
  void initState() {
    _initData();
    super.initState();
  }

  void _initData() async {
    isPregnancy = Utils.isGestationalDiabetes();
    if (widget.type == 'update') {
      loadDetail();
    } else {
      await _loadConfig();
    }
    isMgPerDl = AppSettings.userInfo!.glucoseUnit == 1;
    List<int> valueOfClickTime = await AppSettings.getValueOfClickShortGuide();
    clickTime = valueOfClickTime[ScreenList.BLOOD_SUGAR.index];
    loadDescription();
    firebaseSetup();
  }

  Future firebaseSetup() async {
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

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _controllerNote.dispose();
    super.dispose();
  }

  Future<void> getGlucoseRange(TimeFrameModel selectedTimeFrame) async {
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

  loadDetail() async {
    try {
      BotToast.showLoading();
      model = await GlucoseClient().fetchDetail(widget.id);
      BotToast.closeAllLoading();
      _controller.text = model!.glucose!.round() == model!.glucose
          ? model!.glucose!.round().toString()
          : model!.glucose.toString();
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

      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loadConfig() async {
    BotToast.showLoading();
    // load concurrent 2 api
    final result = await Future.wait([
      GlucoseClient().fetchFlucoseTimeFrame(
          time: selectedDate.millisecondsSinceEpoch ~/ 1000),
      GlucoseClient().fetchColorConfig(),
    ]);

    if (result.length > 1) {
      final timeFrames = result[0] as List<TimeFrameModel>;
      final colors = result[1] as List<GlucoseColorConfig>?;

      if (colors != null) {
        _colorList = colors.map(((e) {
          return Color(int.parse("0xFF" + e.background.substring(1)));
        })).toList();
        _rangeLabel = colors.map(((e) => e.name)).toList();
      }

      selectedTimeFrame = timeFrames.length == 0 ? null : timeFrames.first;
      if (selectedTimeFrame != null) {
        await getGlucoseRange(selectedTimeFrame!);
      }
    }
    // rangeValue = changeRange(selectedTimeFrame);
    BotToast.closeAllLoading();
    setState(() {});
  }

  loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(1);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          _showDialogSave();
          return false;
        },
        child: Scaffold(
          backgroundColor: R.color.backgroundColor,
          body: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(R.drawable.bg_splash),
                    fit: BoxFit.cover)),
            child: Column(
              children: [
                _appBarSection(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(children: [
                      _inforSection(context),
                      Container(
                        margin: const EdgeInsets.only(
                            bottom: 16, left: 16, right: 16),
                        decoration: BoxDecoration(
                          color: R.color.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.all(20),
                        child: SpacingColumn(
                          spacing: 25,
                          children: [
                            _inputSection(),
                            _bloodSugarRange(),
                            _dateTimeSection(),
                            _dateTimeFrame(),
                          ],
                        ),
                      ),
                      _selectImageSection(),
                      if (!AppSettings.isUS) _connectMachine(),
                    ]),
                  ),
                ),
                widget.type == 'input'
                    ? Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: 16,
                          left: 16,
                          right: 16,
                          bottom: AppMediaQuery.deviceSafeAreaBottom,
                        ),
                        color: Colors.white,
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
                                      getGlucoseRange(selectedTimeFrame!);
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
                            GestureDetector(
                              onTap: () async {
                                int indexRange =
                                    findIndexInRanges(number, _rangeValue);
                                if (isChangeStatus) {
                                  LevelOffDiabetesRulePicker.showModal(context,
                                      onSuccess: () {
                                    if (indexRange == 4 || indexRange == 0) {
                                      _showDialogWarning(
                                          onConfirm: () => _submitData(),
                                          range: indexRange);
                                    } else {
                                      _submitData();
                                    }
                                  });
                                } else {
                                  if (indexRange == 4 || indexRange == 0) {
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
                                  borderRadius: BorderRadius.circular(200),
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
                                    R.string.save.tr(),
                                    style: TextStyle(
                                      color: R.color.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _showDialogDelete(context);
                                    },
                                    child: Container(
                                        height: 48,
                                        width: 164,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(200),
                                            border: Border.all(
                                                color: R.color.red, width: 2)),
                                        child: Center(
                                          child: Text(R.string.xoa_du_lieu.tr(),
                                              style: TextStyle(
                                                  color: R.color.red,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600)),
                                        )),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      editData();
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
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ),
                                ])),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  deleteData() async {
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

  editData() async {
    FocusScope.of(context).unfocus();
    final note = _controllerNote.text;
    final numberInput = _controller.text;

    if (numberInput.isEmpty) {
      Message.showToastMessage(context, R.string.mes_blood_sugar_empty.tr());
      return;
    }
    if (selectedDate == null) {
      Message.showToastMessage(context, R.string.ban_chua_nhap_thoi_gian.tr());
      return;
    }
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
          numberInput,
          null,
          note,
          fromNipro,
          removeIDs,
          paths);
      if (result == true) {
        Observable.instance
            .notifyObservers([], notifyName: "glucose_change_data");
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

  _submitData() async {
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
    if (selectedDate == null) {
      Message.showToastMessage(context, R.string.ban_chua_nhap_thoi_gian.tr());
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
      if (result == true) {
        await TrackingManager.analytics.logEvent(
          name: 'glucose_add',
          parameters: {
            "screen_name": 'kpi_glucose_add',
            'index_range': _rangeValue.join(', '),
            'index_time': selectedTimeFrame?.name,
            'method':  fromNipro ? 'device' : 'manual',
          },
        );
        await HomeClient().completeSmartGoal(selectedDate, widget.goalId ?? '',
            1, ScheduleType.blood_sugar.typeIndex);
        // }
        Observable.instance
            .notifyObservers([], notifyName: "glucose_change_data");
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

  changeUnit() async {
    try {
      BotToast.showLoading();
      ScheduleGlucoseTimeModel timeModel =
          await UserClient().fetchScheduleGlucoseSetting();
      await UserClient().updateScheduleGlucoseSetting(ScheduleGlucoseTimeModel(
          beforeEat: timeModel.beforeEat,
          afterEat: timeModel.afterEat,
          beforeSleeping: timeModel.beforeSleeping,
          glucoseUnit: timeModel.glucoseUnit == 1 ? 2 : 1));
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

  _showDialogDelete(BuildContext context) {
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
                            textAlign: TextAlign.center,
                            style: R.style.normalTextStyle),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 16),
                        child: Row(
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
                                    deleteData();
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

  _showDialogSave() {
    final note = _controllerNote.text;
    final numberInput = _controller.text;

    if (model != null) {
      final noteText = model!.note ?? '';
      final date =
          DateTime.fromMillisecondsSinceEpoch(model!.createDate! * 1000);
      if (note == noteText &&
          numberInput == model!.glucose!.round().toString() &&
          files.length == model!.images.length &&
          removeIDs.length == 0 &&
          date.millisecondsSinceEpoch == selectedDate.millisecondsSinceEpoch) {
        Navigator.pop(context);
        return;
      }
    } else if (note.isEmpty && numberInput.isEmpty && files.length == 0) {
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

  _showDialogWarning({required Function onConfirm, required int range}) {
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

  showActionFilter(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(15))),
      backgroundColor: R.color.white,
      context: context,
      isScrollControlled: true,
      builder: (context) => ActionListTrend(
        selected: selectedTimeFrame,
        callback: (value) {
          selectedTimeFrame = value;
          getGlucoseRange(value!);
        },
      ),
    );
  }

  showActionSheet(BuildContext context) {
    FocusScope.of(context).unfocus();
    if (files.length < maxMedia) {
      final action = CupertinoActionSheet(
        actions: <Widget>[
          CupertinoActionSheetAction(
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  Image.asset(R.drawable.ic_photo, width: 24, height: 24),
                  SizedBox(width: 16),
                  Text(R.string.chon_trong_thu_vien.tr(),
                      style: TextStyle(
                          color: R.color.color0xff333333, fontSize: 14)),
                ],
              ),
            ),
            onPressed: () {
              _openGallery(context);
              Navigator.pop(context);
            },
          ),
          CupertinoActionSheetAction(
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8),
              child: Row(
                children: [
                  Image.asset(R.drawable.ic_camera_black,
                      width: 24, height: 24),
                  SizedBox(width: 16),
                  Text(R.string.chup_anh.tr(),
                      style: TextStyle(
                          color: R.color.color0xff333333, fontSize: 14)),
                ],
              ),
            ),
            onPressed: () {
              _openCamera(context);
              Navigator.pop(context);
            },
          )
        ],
        cancelButton: CupertinoActionSheetAction(
          child: Text(R.string.cancel.tr(),
              style: TextStyle(color: R.color.color0xff333333, fontSize: 14)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      );
      showCupertinoModalPopup(context: context, builder: (context) => action);
    } else {
      //Message.showToastMessage(context, R.string.max_image_select.tr());
    }
  }

  _openCamera(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(
          maxWidth: 512,
          maxHeight: 512,
          source: ImageSource.camera,
          preferredCameraDevice: CameraDevice.rear);
      if (pickedFile != null) {
        files.add(pickedFile);

        setState(() {});
      }
    } catch (_) {
      showAlertDialog(context);
    }
  }

  _openGallery(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.getImage(
          maxWidth: 512, maxHeight: 512, source: ImageSource.gallery);
      if (pickedFile != null) {
        files.add(pickedFile);

        setState(() {});
      }
    } catch (_) {
      showAlertDialog(context);
    }
  }

  showGuide(BuildContext context) async {
    Description.showTooltip(context,
        data: des!, title: R.string.blood_sugar_for_diabetes.tr());
    clickTime = clickTime + 1;
    await AppSettings.setValueOfClickShortGuideIndex(
        ScreenList.BLOOD_SUGAR.index, clickTime);
  }

  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text(R.string.cancel.tr()),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text(R.string.allowed.tr()),
      onPressed: () {
        Navigator.pop(context);
        openAppSettings();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(R.string.notification.tr()),
      content: Text(R.string.ask_for_permission.tr()),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget _appBarSection() {
    return CustomAppBar(
      backgroundColor: R.color.transparent,
      title: Text(
          widget.type == 'update'
              ? R.string.update_blood_sugar.tr()
              : R.string.enter_blood_sugar.tr(),
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: R.color.textDark)),
      leadingIcon: IconButton(
          splashColor: R.color.transparent,
          highlightColor: R.color.transparent,
          icon: Icon(Icons.arrow_back, color: R.color.textDark),
          onPressed: () {
            _showDialogSave();
          }),
      actions: [
        GestureDetector(
          onTap: () async {
            if (clickTime >= 2) {
              await showGuide(context);
            } else {
              setState(() {
                isClicked = !isClicked;
                clickTime = clickTime + 1;
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: isClicked
                ? Image.asset(R.drawable.ic_help_circle_active,
                    width: 24, height: 24)
                : Image.asset(R.drawable.ic_help_circle, width: 24, height: 24),
          ),
        ),
      ],
    );
  }

  Widget _inforSection(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: isClicked && clickTime < 2
            ? Description(
                isCreateData: true,
                input: true,
                data: des,
                titleDetail: R.string.blood_sugar_for_diabetes.tr())
            : SizedBox());
  }

  Widget _inputSection() {
    return SpacingColumn(
      spacing: 20,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SpacingRow(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(child: SizedBox(width: 80)),
            Container(
              width: 150,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: R.color.color0xffE5E5E5))),
              child: TextField(
                focusNode: _focusNodeKPI,
                controller: _controller,
                maxLength: isMgPerDl ? 3 : 4,
                autofocus: true,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                    color: R.color.black,
                    fontSize: 48,
                    fontFamily: 'Viga',
                    fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '0.0',
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
            InkWell(
              onTap: () async {
                await changeUnit();

                final glucose = roundAsFixed(
                    AppSettings.userInfo!.glucoseUnit == 1
                        ? number! * mmollToMgdlFactor
                        : number! / mmollToMgdlFactor);
                number = glucose;
                if (_controller.text != "") {
                  _controller.text = glucose.toString();
                }
                setState(() {
                  isMgPerDl = !isMgPerDl;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                color: Colors.white,
                child: SpacingRow(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppSettings.userInfo!.glucoseUnit == 1
                          ? R.string.mg_dl.tr()
                          : R.string.mmol_l.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: R.color.captionColorGray,
                      ),
                    ),
                    Image.asset(R.drawable.ic_change_unit, height: 16)
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _dateTimeSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
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
                },
              ),
            );
          },
          child: Container(
            color: R.color.transparent,
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    convertToUTC(selectedDate.millisecondsSinceEpoch ~/ 1000,
                        'HH:mm - dd/MM/yyyy'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Chỉnh sửa',
                    style: TextStyle(
                      fontSize: 16,
                      color: R.color.accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
              SizedBox(height: 16),
              Container(height: 1, color: R.color.color0xffE5E5E5),
              SizedBox(height: 8),
            ]),
          ),
        )
      ],
    );
  }

  Widget _dateTimeFrame() {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            await TrackingManager.analytics.logEvent(
              name: 'component_clicked',
              parameters: {
                "screen_name": 'kpi_glycemic_add',
                'component_name': 'time_section_glycemic',
              },
            );
            showActionFilter(context);
          },
          child: Container(
            color: R.color.transparent,
            child: Column(
              children: [
                SpacingRow(
                  spacing: 15,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        selectedTimeFrame == null
                            ? R.string.chon_khung_gio.tr()
                            : selectedTimeFrame!.name!,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w400)),
                    Text(
                      'Chỉnh sửa',
                      style: TextStyle(
                        fontSize: 16,
                        color: R.color.accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _connectMachine() {
    return GestureDetector(
      onTap: () async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => RocheConnectionView()));
      },
      child: Container(
          margin: EdgeInsets.only(bottom: 16, left: 16, right: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: R.color.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFFDDF4F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  R.drawable.ic_sugar_blood,
                  width: 24,
                  height: 24,
                ),
              ),
              SizedBox(width: 15),
              SpacingColumn(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kết nối thiết bị và app',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SpacingRow(
                    spacing: 10,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Kết nối',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: R.color.accentColor,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: R.color.accentColor,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Widget _selectImageSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: Container(
        decoration: BoxDecoration(
          color: R.color.white,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: TextField(
              focusNode: _focusNode,
              controller: _controllerNote,
              style: TextStyle(
                  color: R.color.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
              decoration: InputDecoration(
                hintText: R.string.nhap_ghi_chu_cua_ban.tr(),
                contentPadding: EdgeInsets.only(bottom: 8),
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: R.color.primaryGreyColor,
                ),
              ),
            ),
          ),
          Container(height: 1, color: R.color.color0xffE5E5E5),
          GridView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: files.length + 1,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                    onTap: () {
                      if (index == files.length) {
                        showActionSheet(context);
                      }
                    },
                    child: index == files.length
                        ? ButtonAddPhoto()
                        : GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/photo_view',
                                  arguments: {'files': files, 'index': index});
                            },
                            child: Stack(
                                alignment: AlignmentDirectional.topEnd,
                                children: [
                                  Positioned.fill(
                                    child: files[index] is PickedFile
                                        ? Image.file(
                                            File(files[index].path),
                                            fit: BoxFit.cover,
                                          )
                                        : NetWorkImageWidget(
                                            imageUrl: files[index].url,
                                            fit: BoxFit.cover),
                                  ),
                                  IconButton(
                                      icon: Image.asset(R.drawable.ic_trash),
                                      onPressed: () {
                                        setState(() {
                                          if (files[index] is PickedFile) {
                                            files.removeAt(index);
                                          } else {
                                            removeIDs.add(files[index].id);
                                            files.removeAt(index);
                                          }
                                        });
                                      })
                                ]),
                          ));
              }),
        ]),
      ),
    );
  }

  int findIndexInRanges(double? number, List<int> ranges) {
    if (number == null) return -1;
    bool glucoseUnit = AppSettings.userInfo!.glucoseUnit == 1;

    for (int i = 0; i < ranges.length - 1; i++) {
      if (number >=
              (glucoseUnit
                  ? ranges[i]
                  : roundAsFixed(ranges[i] / mmollToMgdlFactor)) &&
          number <=
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
    num widthRange = (AppMediaQuery.deviceWidth - 72) / (_rangeValue.length);
    print('hihi widthRange: $widthRange');
    num width = _number == 0 ? 0 : widthRange * (indexRange);

    // lấy pxPerValue = max - min => 55 - 0
    // lấy pxPerValue * value

    if (_number != null && _number != 0) {
      if (!isMgPerDl) {
        _number = _number * mmollToMgdlFactor;
      }
      num min = _rangeValue[indexRange];
      print('hihi min: $min');
      num max = indexRange + 1 >= _rangeValue.length
          ? _rangeValue[indexRange] + min
          : _rangeValue[indexRange + 1];
      print('hihi max: $max');
      // giá trị từ 0 -> 55 sẽ nằm ở mức 0

      // sau đó tính toán mỗi px trên 1 mức value
      num maximumValue = max - min;
      print('hihi maximumValue: $maximumValue');
      num pxPerValue = widthRange / maximumValue;
      print('hihi pxPerValue: $pxPerValue');
      num widthPlus = pxPerValue * (_number - min);
      print('hihi widthPlus: $widthPlus');
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
