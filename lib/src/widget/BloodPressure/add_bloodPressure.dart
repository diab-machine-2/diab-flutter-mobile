import 'dart:io';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/blood_pressure/blood_pressure.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/repo/blood_pressure/bloodPressure_client.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/widget/BloodSugar/widget/action_list_trend.dart';
import 'package:medical/src/widget/HbA1C/widget/CalendarPicker/custom_date_picker.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/network_image_widget.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../repo/home/home_client.dart';
import '../my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';

class AddBloodPressureController extends StatefulWidget {
  final String? type;
  final String? id;
  final String? goalId;

  AddBloodPressureController({this.type, this.id, this.goalId});
  @override
  _AddBloodPressureControllerState createState() =>
      _AddBloodPressureControllerState();
}

class _AddBloodPressureControllerState
    extends BaseState<AddBloodPressureController> {
  TextEditingController _controllerSystolic = TextEditingController();
  TextEditingController _controllerDiastolic = TextEditingController();
  TextEditingController _controllerNote = TextEditingController();
  TextEditingController _controllerHeart = TextEditingController();
  TextEditingController _controllerReason = TextEditingController();
  FocusNode diastolicFocus = FocusNode();
  FocusNode heartFocus = FocusNode();
  int maxMedia = 5;
  List<dynamic> files = [];
  DateTime selectedDate = DateTime.now();
  bool isClicked = false;
  DateTime time = DateTime.now();
  BloodPressureModel? model;
  TimeFrameModel? selectedTimeFrame;
  List<String?> removeIDs = [];
  String? textValidate = '';

  ShortGuiModel? des;

  @override
  void initState() {
    super.initState();
    if (widget.type == 'update') {
      loadDataDetail();
    } else {
      loadTimeFrame();
    }
    loadDescription();
    TrackingManager.analytics
        .setCurrentScreen(screenName: 'Blood Pressure Input');
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadDataDetail() async {
    BotToast.showLoading();
    model = await BloodPressureClient().fetchBloodPressureDetail(widget.id);
    BotToast.closeAllLoading();
    print(model);
    if (model != null) {
      _controllerSystolic.text = model!.systolic?.toInt().toString() ?? '';
      _controllerDiastolic.text = model!.diastolic?.toInt().toString() ?? '';
      _controllerNote.text = model?.note ?? '';
      _controllerHeart.text = model!.pulseRate?.toInt().toString() ?? '';
      _controllerReason.text = model!.reason ?? '';
      selectedDate = DateTime.fromMillisecondsSinceEpoch(model!.date! * 1000);
      selectedTimeFrame = TimeFrameModel(
          id: model!.timeFrameId ?? '', code: '', name: model!.timeFrame ?? '');
      files.addAll(model!.images);
    }
    checkValidateInput();
    setState(() {});
  }

  loadTimeFrame() async {
    BotToast.showLoading();
    final timeFrames = await GlucoseClient().fetchFlucoseTimeFrame(
        time: selectedDate.millisecondsSinceEpoch ~/ 1000);
    selectedTimeFrame = timeFrames.length == 0 ? null : timeFrames.first;
    BotToast.closeAllLoading();
    setState(() {});
  }

  loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(2);
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
                CustomAppBar(
                  backgroundColor: R.color.transparent,
                  title: Text(
                      widget.type == 'update'
                          ? R.string.update_blood_pressure.tr()
                          : R.string.enter_blood_pressure.tr(),
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
                      onTap: () {
                        setState(() {
                          isClicked = !isClicked;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: isClicked
                            ? Image.asset(R.drawable.ic_help_circle_active,
                                width: 24, height: 24)
                            : Image.asset(R.drawable.ic_help_circle,
                                width: 24, height: 24),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.all(0),
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, bottom: 16),
                            child: isClicked
                                ? Description(
                                    input: true,
                                    data: des,
                                    titleDetail: R
                                        .string.blood_pressure_for_diabetes
                                        .tr())
                                : SizedBox()),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(20),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Image.asset(R.drawable.ic_heart_rate,
                                        width: 24, height: 24),
                                    SizedBox(width: 8),
                                    Text(R.string.systolic_diastolic.tr(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                    // SizedBox(height: 16),
                                  ]),
                                  SizedBox(height: 8),
                                  Center(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                width: 80,
                                                child: TextField(
                                                    autofocus:
                                                        widget.type != 'update',
                                                    onChanged: (value) {
                                                      checkValidateInput();
                                                      if (value.length == 3) {
                                                        diastolicFocus
                                                            .requestFocus();
                                                      }
                                                    },
                                                    controller:
                                                        _controllerSystolic,
                                                    inputFormatters: [
                                                      LengthLimitingTextInputFormatter(
                                                          3),
                                                    ],
                                                    textAlign: TextAlign.center,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    style: TextStyle(
                                                        color: R.color.black,
                                                        fontSize: 34,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    decoration: InputDecoration(
                                                        hintText: '-',
                                                        counterText: '',
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                bottom: 8),
                                                        border:
                                                            InputBorder.none,
                                                        hintStyle: TextStyle(
                                                            color: R.color
                                                                .captionColorGray,
                                                            fontSize: 34,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))),
                                              ),
                                              Container(
                                                  height: 1,
                                                  width: 54,
                                                  color:
                                                      R.color.color0xffE5E5E5)
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8.0),
                                            child: Text('/',
                                                style: TextStyle(
                                                  fontSize: 30,
                                                )),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                width: 80,
                                                child: TextField(
                                                    focusNode: diastolicFocus,
                                                    onChanged: (value) {
                                                      checkValidateInput();
                                                      if (value.length == 3) {
                                                        heartFocus
                                                            .requestFocus();
                                                      }
                                                    },
                                                    controller:
                                                        _controllerDiastolic,
                                                    inputFormatters: [
                                                      LengthLimitingTextInputFormatter(
                                                          3),
                                                    ],
                                                    textAlign: TextAlign.center,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    style: TextStyle(
                                                        color: R.color.black,
                                                        fontSize: 34,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    decoration: InputDecoration(
                                                        hintText: '-',
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                bottom: 8),
                                                        border:
                                                            InputBorder.none,
                                                        hintStyle: TextStyle(
                                                            color: R.color
                                                                .captionColorGray,
                                                            fontSize: 34,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))),
                                              ),
                                              Container(
                                                  height: 1,
                                                  width: 54,
                                                  color:
                                                      R.color.color0xffE5E5E5)
                                            ],
                                          ),
                                          Text(R.string.mm_hg.tr(),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400))
                                        ]),
                                  ),
                                  textValidate!.isNotEmpty
                                      ? Column(
                                          children: [
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(textValidate!,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: R.color.red,
                                                    fontWeight:
                                                        FontWeight.w400)),
                                          ],
                                        )
                                      : SizedBox(),
                                ]),
                          ),
                        ),
                        textValidate!.isEmpty && _controllerReason.text.isEmpty
                            ? SizedBox()
                            : Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 16, left: 16, right: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: R.color.white,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Image.asset(R.drawable.ic_note_text,
                                              width: 24, height: 24),
                                          SizedBox(width: 8),
                                          Text(R.string.ly_do.tr(),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600))
                                        ]),
                                        SizedBox(height: 16),
                                        TextField(
                                            controller: _controllerReason,
                                            style: TextStyle(
                                                color: R.color.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400),
                                            decoration: InputDecoration(
                                                hintText:
                                                    R.string.nhap_ly_do.tr(),
                                                contentPadding:
                                                    EdgeInsets.only(bottom: 8),
                                                border: InputBorder.none,
                                                hintStyle: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w400,
                                                    color: R.color
                                                        .primaryGreyColor))),
                                        Container(
                                            height: 1,
                                            color: R.color.color0xffE5E5E5),
                                        SizedBox(height: 8),
                                      ]),
                                ),
                              ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Image.asset(R.drawable.ic_heart,
                                        width: 24, height: 24),
                                    SizedBox(width: 8),
                                    Text(R.string.heart_rate.tr(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600))
                                  ]),
                                  SizedBox(height: 24),
                                  Center(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            children: [
                                              Container(
                                                width: 80,
                                                child: TextField(
                                                    focusNode: heartFocus,
                                                    controller:
                                                        _controllerHeart,
                                                    textAlign: TextAlign.center,
                                                    maxLength: 3,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    style: TextStyle(
                                                        color: R.color.black,
                                                        fontSize: 34,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                    decoration: InputDecoration(
                                                        hintText: '-',
                                                        counterText: '',
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                bottom: 8),
                                                        border:
                                                            InputBorder.none,
                                                        hintStyle: TextStyle(
                                                            color: R.color
                                                                .captionColorGray,
                                                            fontSize: 34,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500))),
                                              ),
                                              Container(
                                                  height: 1,
                                                  width: 54,
                                                  color:
                                                      R.color.color0xffE5E5E5)
                                            ],
                                          ),
                                          Text(R.string.time_per_minute.tr(),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400))
                                        ]),
                                  ),
                                  SizedBox(height: 8),
                                ]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    barrierColor: R.color.color0xff003F38
                                        .withOpacity(0.5),
                                    context: context,
                                    builder: (_) => DateMultiPicker(
                                      initDate: selectedDate,
                                      callback: (date) {
                                        setState(() {
                                          selectedDate = date ?? DateTime.now();
                                        });
                                        loadTimeFrame();
                                      },
                                      // selectedHour: (hour) {
                                      //   setState(() {
                                      //     selectedHour = hour;
                                      //   });
                                      // },
                                      // selectedMinute: (minute) {
                                      //   setState(() {
                                      //     selectedMinute = minute;
                                      //   });
                                      // },
                                    ),
                                  );
                                },
                                child: Container(
                                  color: R.color.transparent,
                                  child: Column(children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Image.asset(R.drawable.ic_calendar,
                                              width: 24, height: 24),
                                          SizedBox(width: 8),
                                          Row(
                                            children: [
                                              Text(
                                                  convertToUTC(
                                                      selectedDate
                                                              .millisecondsSinceEpoch ~/
                                                          1000,
                                                      'HH:mm - dd/MM/yyyy'),
                                                  style: TextStyle(
                                                      color: R.color.textDark,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                            ],
                                          )
                                        ]),
                                    SizedBox(height: 16),
                                    Container(
                                        height: 1,
                                        color: R.color.color0xffE5E5E5),
                                    SizedBox(height: 8),
                                  ]),
                                ),
                              )
                            ]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(children: [
                              GestureDetector(
                                onTap: () {
                                  showActionFilter(context);
                                },
                                child: Container(
                                  color: R.color.transparent,
                                  child: Column(children: [
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Image.asset(R.drawable.ic_clock,
                                              width: 24, height: 24),
                                          SizedBox(width: 8),
                                          Text(
                                              selectedTimeFrame == null
                                                  ? R.string.chon_khung_gio.tr()
                                                  : selectedTimeFrame!.name!,
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w400))
                                        ]),
                                    SizedBox(height: 16),
                                    Container(
                                        height: 1,
                                        color: R.color.color0xffE5E5E5),
                                    SizedBox(height: 8),
                                  ]),
                                ),
                              )
                            ]),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: R.color.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Image.asset(R.drawable.ic_note_text,
                                        width: 24, height: 24),
                                    SizedBox(width: 8),
                                    Text(R.string.ghi_chu.tr(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600))
                                  ]),
                                  SizedBox(height: 24),
                                  TextField(
                                      controller: _controllerNote,
                                      style: TextStyle(
                                          color: R.color.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                          hintText: R
                                              .string.nhap_ghi_chu_cua_ban
                                              .tr(),
                                          contentPadding:
                                              EdgeInsets.only(bottom: 8),
                                          border: InputBorder.none,
                                          hintStyle: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400,
                                              color:
                                                  R.color.primaryGreyColor))),
                                  Container(
                                      height: 1,
                                      color: R.color.color0xffE5E5E5),
                                  SizedBox(height: 8),
                                  GridView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: files.length + 1,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              childAspectRatio: 1,
                                              crossAxisSpacing: 16,
                                              mainAxisSpacing: 16),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                            onTap: () {
                                              if (index == files.length) {
                                                showActionSheet(context);
                                              }
                                            },
                                            child: index == files.length
                                                ? Container(
                                                    child: Image.asset(R
                                                        .drawable.ic_add_photo))
                                                : GestureDetector(
                                                    onTap: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          '/photo_view',
                                                          arguments: {
                                                            'files': files,
                                                            'index': index
                                                          });
                                                    },
                                                    child: Stack(
                                                        alignment:
                                                            AlignmentDirectional
                                                                .topEnd,
                                                        children: [
                                                          Positioned.fill(
                                                            child: files[index]
                                                                    is PickedFile
                                                                ? Image.file(
                                                                    File(files[
                                                                            index]
                                                                        .path),
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  )
                                                                : NetWorkImageWidget(
                                                                    imageUrl:
                                                                        files[index]
                                                                            .url,
                                                                    fit: BoxFit
                                                                        .cover),
                                                          ),
                                                          IconButton(
                                                              icon: Image.asset(R
                                                                  .drawable
                                                                  .ic_trash),
                                                              onPressed: () {
                                                                setState(() {
                                                                  if (files[
                                                                          index]
                                                                      is PickedFile) {
                                                                    files.removeAt(
                                                                        index);
                                                                  } else {
                                                                    removeIDs.add(
                                                                        files[index]
                                                                            .id);
                                                                    files.removeAt(
                                                                        index);
                                                                  }
                                                                });
                                                              })
                                                        ]),
                                                  ));
                                      })
                                ]),
                          ),
                        ),
                      ]),
                ),
                widget.type == 'input'
                    ? GestureDetector(
                        onTap: () async {
                          _submitData();
                        },
                        child: SafeArea(
                          top: false,
                          child: Container(
                              margin: EdgeInsets.only(top: 16, bottom: 16),
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
                                      ])),
                              child: Center(
                                  child: Text(R.string.save.tr(),
                                      style: TextStyle(
                                          color: R.color.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16)))),
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

  checkValidateInput() async {
    final systolic = _controllerSystolic.text;
    final diastolic = _controllerDiastolic.text;
    if (systolic.isNotEmpty && diastolic.isNotEmpty) {
      try {
        final result = await BloodPressureClient()
            .checkBloodPressureInput(systolic, diastolic);
        setState(() {
          textValidate = result;
          if (textValidate!.isEmpty) {
            _controllerReason.text = '';
          }
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

  deleteData() async {
    try {
      BotToast.showLoading();
      final result =
          await BloodPressureClient().deleteBloodPressureInput(widget.id);
      if (result == true) {
        Message.showToastMessage(context, R.string.xoa_thanh_cong.tr());
        Observable.instance
            .notifyObservers([], notifyName: "BloodPressure_change_data");
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

  editData() async {
    FocusScope.of(context).unfocus();
    final systolic = _controllerSystolic.text;
    final diastolic = _controllerDiastolic.text;
    final pulseRate = _controllerHeart.text;
    final note = _controllerNote.text;
    final reason = _controllerReason.text;

    if (systolic.isEmpty) {
      Message.showToastMessage(context, R.string.mes_systolic_empty.tr());
      return;
    }
    if (textValidate!.isNotEmpty && reason.isEmpty) {
      Message.showToastMessage(context, R.string.ban_chua_nhap_ly_do.tr());
      return;
    }
    if (diastolic.isEmpty) {
      Message.showToastMessage(context, R.string.mes_diastolic_empty.tr());
      return;
    }
    if (pulseRate.isEmpty) {
      Message.showToastMessage(context, R.string.mes_heart_rate_empty.tr());
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
    if (note == null) {
      Message.showToastMessage(context, R.string.ban_chua_nhap_ly_do.tr());
      return;
    }
    BotToast.showLoading();

    try {
      List<String> paths = [];
      for (var file in files) {
        if (file is PickedFile) {
          paths.add(file.path);
        }
      }
      final result = await BloodPressureClient().updateBloodPressureInput(
          widget.id,
          systolic,
          diastolic,
          pulseRate,
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          selectedTimeFrame!.id,
          note,
          reason,
          removeIDs,
          paths);
      if (result == true) {
        Observable.instance
            .notifyObservers([], notifyName: "BloodPressure_change_data");
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
    FocusScope.of(context).unfocus();
    final systolic = _controllerSystolic.text;
    final diastolic = _controllerDiastolic.text;
    final pulseRate = _controllerHeart.text;
    final note = _controllerNote.text;
    final reason = _controllerReason.text;

    if (systolic.isEmpty) {
      Message.showToastMessage(context, R.string.mes_systolic_empty.tr());
      return;
    }
    if (textValidate!.isNotEmpty && reason.isEmpty) {
      Message.showToastMessage(context, R.string.ban_chua_nhap_ly_do.tr());
      return;
    }
    if (diastolic.isEmpty) {
      Message.showToastMessage(context, R.string.mes_diastolic_empty.tr());
      return;
    }
    if (pulseRate.isEmpty) {
      Message.showToastMessage(context, R.string.mes_heart_rate_empty.tr());
      return;
    }
    if (int.parse(pulseRate.splitMapJoin(',')) > 200) {
      Message.showToastMessage(context, R.string.mes_heart_rate_invalid.tr());
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
    if (note == null) {
      Message.showToastMessage(context, R.string.ban_chua_nhap_ly_do.tr());
      return;
    }
    BotToast.showLoading();

    try {
      List<String> paths = [];
      for (var file in files) {
        paths.add(file.path);
      }
      final result = await BloodPressureClient().postBloodPressureInput(
          systolic,
          diastolic,
          pulseRate,
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          selectedTimeFrame!.id,
          note,
          reason,
          paths);
      if (result == true) {
        // if(widget.goalId != null && widget.goalId?.isNotEmpty == true){
        await HomeClient().completeSmartGoal(selectedDate, widget.goalId ?? '',
            1, ScheduleType.blood_pressure.typeIndex);
        // }
        Observable.instance
            .notifyObservers([], notifyName: "BloodPressure_change_data");
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
    final systolic = _controllerSystolic.text;
    final diastolic = _controllerDiastolic.text;
    final pulseRate = _controllerHeart.text;
    final note = _controllerNote.text;
    final reason = _controllerReason.text;
    if (model != null) {
      final noteText = model!.note ?? '';
      final reasonText = model!.reason ?? '';
      final date = DateTime.fromMillisecondsSinceEpoch(model!.date! * 1000);
      if (systolic == model!.systolic!.toInt().toString() &&
          diastolic == model!.diastolic!.toInt().toString() &&
          pulseRate == model!.pulseRate!.toInt().toString() &&
          note == noteText &&
          reasonText == reason &&
          files.length == model!.images.length &&
          removeIDs.length == 0 &&
          date.millisecondsSinceEpoch == selectedDate.millisecondsSinceEpoch &&
          selectedTimeFrame!.id == model!.timeFrameId) {
        Navigator.pop(context);
        return;
      }
    } else if (systolic.isEmpty &&
        diastolic.isEmpty &&
        pulseRate.isEmpty &&
        note.isEmpty &&
        files.length == 0) {
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
              print(value);
              setState(() {
                selectedTimeFrame = value;
              });
            }));
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
      Message.showToastMessage(context, R.string.max_image_select.tr());
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
                                onPressed: () {
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
                                color: R.color.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
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
                            selectedDate = DateTime(
                                selectedDate!.year,
                                selectedDate!.month,
                                selectedDate!.day,
                                selectedHour,
                                selectedMinute);

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

  return 'Tháng ${date.month}, ${date.year}';
}
