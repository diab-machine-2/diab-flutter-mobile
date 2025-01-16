import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/glucose/glucose_input.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/modal/user/schedule_glucose_time.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/repo/user/user_client.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/widget/BloodSugar/widget/action_list_trend.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/nipro/roche_connection/roche_connection_view.dart';
import 'package:medical/src/widgets/btn_add_photo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../widgets/CalendarPicker/custom_date_picker.dart';
import '../../widgets/network_image_widget.dart';
import '../my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';

class AddBloodSugarController extends StatefulWidget {
  final String? type;
  final String? id;
  final String? goalId;

  AddBloodSugarController({this.type, this.id, this.goalId});

  @override
  _AddBloodSugarControllerState createState() =>
      _AddBloodSugarControllerState();
}

class _AddBloodSugarControllerState extends BaseState<AddBloodSugarController>
    with SingleTickerProviderStateMixin {
  TextEditingController _controller = TextEditingController();
  TextEditingController _controllerReason = TextEditingController();
  TextEditingController _controllerNote = TextEditingController();
  int maxMedia = 5;
  List<dynamic> files = [];
  DateTime selectedDate = DateTime.now();
  bool isClicked = false;
  TimeFrameModel? selectedTimeFrame;
  bool isFocus = false;

  bool showReason = false;
  double? number = 0;

  InputGlucoseModel? model;
  List<String?> removeIDs = [];

  ShortGuiModel? des;

  double mmollToMgdlFactor = 18.018;
  bool fromNipro = false;

  FocusNode _focusNode = FocusNode();

  void initState() {
    super.initState();
    if (widget.type == 'update') {
      loadDetail();
    } else {
      loadTimeFrame();
    }
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

  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _controllerNote.dispose();
    super.dispose();
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
      _controllerReason.text = model?.reason ?? '';
      showReason = _controllerReason.text.isNotEmpty;
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

  loadTimeFrame() async {
    BotToast.showLoading();
    final timeFrames = await GlucoseClient().fetchFlucoseTimeFrame(
        time: selectedDate.millisecondsSinceEpoch ~/ 1000);
    selectedTimeFrame = timeFrames.length == 0 ? null : timeFrames.first;
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
                CustomAppBar(
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
                  child: SingleChildScrollView(
                    child: Column(
                        // keyboardDismissBehavior:
                        //     ScrollViewKeyboardDismissBehavior.onDrag,
                        // padding: EdgeInsets.all(0),
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 16, left: 16, right: 16),
                              child: isClicked
                                  ? Description(
                                      input: true,
                                      data: des,
                                      titleDetail: R
                                          .string.blood_sugar_for_diabetes
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
                              child: Column(children: [
                                Center(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 160,
                                          decoration: BoxDecoration(border: Border(bottom: BorderSide(
                                            color: R.color.color0xffE5E5E5
                                          ))),
                                          child: TextField(
                                              controller: _controller,
                                              maxLength: 3,
                                              textAlign: TextAlign.center,
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: true),
                                              style: TextStyle(
                                                  color: R.color.black,
                                                  fontSize: 34,
                                                  fontWeight: FontWeight.w500),
                                              decoration: InputDecoration(
                                                  counterText: '',
                                                  hintText: '0.0',
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          bottom: 8),
                                                  border: InputBorder.none,
                                                  hintStyle: TextStyle(
                                                      color: R.color
                                                          .captionColorGray,
                                                      fontSize: 34,
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              onChanged: (value) {
                                                fromNipro = false;
                                                final newValue =
                                                    value.split(',').join('.');
                                                number = newValue.isEmpty
                                                    ? 0
                                                    : double.parse(newValue);

                                                setState(() {
                                                  showReason = (AppSettings
                                                                  .userInfo!
                                                                  .glucoseUnit ==
                                                              1
                                                          ? (number! < 55 ||
                                                              number! > 250)
                                                          : (number! <
                                                                  55 /
                                                                      mmollToMgdlFactor ||
                                                              number! >
                                                                  250 /
                                                                      mmollToMgdlFactor)) &&
                                                      number! > 0;
                                                });
                                              }),
                                        ),
                                        Text(
                                            AppSettings.userInfo!.glucoseUnit ==
                                                    1
                                                ? R.string.mg_dl.tr()
                                                : R.string.mmol_l.tr(),
                                            style: TextStyle(fontSize: 16))
                                      ]),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await changeUnit();
                                    final glucose = roundAsFixed(
                                        AppSettings.userInfo!.glucoseUnit == 1
                                            ? number! * mmollToMgdlFactor
                                            : number! / mmollToMgdlFactor);
                                    _controller.text = glucose.toString();
                                    number = glucose;
                                    setState(() {});
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(top: 20),
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        color: Color(0xffE5F6F0),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(R.drawable.ic_change_unit,
                                              height: 16),
                                          SizedBox(width: 6),
                                          Text(
                                              'Chuyển đơn vị: ' +
                                                  (AppSettings.userInfo!
                                                              .glucoseUnit ==
                                                          2
                                                      ? R.string.mg_dl.tr()
                                                      : R.string.mmol_l.tr()),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Color(0xff4BB2AB),
                                                  fontWeight: FontWeight.w500))
                                        ]),
                                  ),
                                ),
                                // _controller.text.isEmpty
                                //     ? SizedBox()
                                //     : Padding(
                                //         padding: EdgeInsets.only(top: 16),
                                //         child: Row(
                                //             mainAxisAlignment:
                                //                 MainAxisAlignment.spaceBetween,
                                //             children: [
                                //               Row(children: [
                                //                 Image.asset(R.drawable.ic_repeat,
                                //                     width: 22, height: 22),
                                //                 SizedBox(width: 8),
                                //                 Text(
                                //                     R.string.corresponding_to
                                //                         .tr(),
                                //                     style:
                                //                         TextStyle(fontSize: 16))
                                //               ]),
                                //               Text(
                                //                   roundNumber(roundAsFixed(AppSettings
                                //                                       .userInfo!
                                //                                       .glucoseUnit ==
                                //                                   1
                                //                               ? number! /
                                //                                   mmollToMgdlFactor
                                //                               : number! *
                                //                                   mmollToMgdlFactor))
                                //                           .toString() +
                                //                       (AppSettings.userInfo!
                                //                                   .glucoseUnit ==
                                //                               2
                                //                           ? ' ${R.string.mg_dl.tr()}'
                                //                           : ' ${R.string.mmol_l.tr()}'),
                                //                   style: TextStyle(fontSize: 16)),
                                //             ]),
                                //       ),
                                SizedBox(height: 8),
                                !showReason
                                    ? SizedBox()
                                    : Text(R.string.mes_unsafe_blood_sugar.tr(),
                                        style: TextStyle(color: R.color.red),
                                        textAlign: TextAlign.center)
                              ]),
                            ),
                          ),
                          //TODO: Kết nối máy đo đường huyết
                          GestureDetector(
                            onTap: () async {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          RocheConnectionView()));
                              // final data = await Navigator.pushNamed(context,
                              //     NavigatorName.connection_instructions);
                              // if (data != null && data is Map) {
                              //   fromNipro = true;

                              //   if (AppSettings.userInfo!.glucoseUnit != 1) {
                              //     await changeUnit();
                              //   }

                              //   final glucose =
                              //       double.tryParse(data['glucose']) ?? 0;
                              //   number = glucose;
                              //   _controller.text = number.toString();

                              //   showReason =
                              //       (AppSettings.userInfo!.glucoseUnit == 1
                              //               ? (number! < 55 || number! > 250)
                              //               : (number! <
                              //                       55 / mmollToMgdlFactor ||
                              //                   number! >
                              //                       250 / mmollToMgdlFactor)) &&
                              //           number! > 0;
                              //   selectedDate =
                              //       DateTime.fromMillisecondsSinceEpoch(
                              //           (int.tryParse(data['date']) ?? 0) *
                              //               1000);
                              //   loadTimeFrame();
                              //   setState(() {});
                              // }
                            },
                            child: Container(
                                margin: EdgeInsets.only(
                                    bottom: 16, left: 16, right: 16),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: R.color.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(R.drawable.ic_device,
                                            width: 24, height: 24),
                                        SizedBox(width: 8),
                                        Text('Kết nối thiết bị và app',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700)),
                                      ],
                                    ),
                                    Icon(Icons.navigate_next,
                                        color: R.color.grayCaption)
                                  ],
                                )),
                          ),
                          !showReason
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
                                                    fontWeight:
                                                        FontWeight.w600))
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
                                                      EdgeInsets.only(
                                                          bottom: 8),
                                                  border: InputBorder.none,
                                                  hintStyle: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400,
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
                              child: Column(children: [
                                GestureDetector(
                                  onTap: () async {
                                    // await TrackingManager.analytics.logEvent(
                                    //     name: 'component_clicked',
                                    //     parameters: {
                                    //       "screen_name": 'kpi_glycemic_add',
                                    //       'component_name':
                                    //           'date_picker_glycemic',
                                    //     });

                                    showDialog(
                                      barrierColor: R.color.color0xff003F38
                                          .withOpacity(0.5),
                                      context: context,
                                      builder: (_) => DateMultiPicker(
                                        initDate: selectedDate,
                                        callback: (date) {
                                          setState(() {
                                            selectedDate =
                                                date ?? DateTime.now();
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
                                            Text(
                                                convertToUTC(
                                                    selectedDate
                                                            .millisecondsSinceEpoch ~/
                                                        1000,
                                                    'HH:mm - dd/MM/yyyy'),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w400))
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
                                  onTap: () async {
                                    // await TrackingManager.analytics.logEvent(
                                    //   name: 'component_clicked',
                                    //   parameters: {
                                    //     "screen_name": 'kpi_glycemic_add',
                                    //     'component_name':
                                    //         'time_section_glycemic',
                                    //   },
                                    // );
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
                                                    ? R.string.chon_khung_gio
                                                        .tr()
                                                    : selectedTimeFrame!.name!,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w400))
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
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                      },
                                      child: TextField(
                                          focusNode: _focusNode,
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
                                                  color: R.color
                                                      .primaryGreyColor))),
                                    ),
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
                                                  ? ButtonAddPhoto()
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
                                                              child: files[
                                                                          index]
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
                                        }),
                                  ]),
                            ),
                          ),
                        ]),
                  ),
                ),
                widget.type == 'input'
                    ? GestureDetector(
                        onTap: () async {
                          _submitData();
                        },
                        child: SafeArea(
                          top: false,
                          //bottom: false,
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
    final reason = _controllerReason.text;
    final note = _controllerNote.text;
    final numberInput = _controller.text;

    if (numberInput.isEmpty) {
      Message.showToastMessage(context, R.string.mes_blood_sugar_empty.tr());
      return;
    }
    if (reason.isEmpty && showReason) {
      Message.showToastMessage(context, R.string.mes_reason_empty.tr());
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
          showReason ? reason : null,
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
    final reason = _controllerReason.text;
    final note = _controllerNote.text;

    if (number == 0) {
      Message.showToastMessage(context, R.string.mes_blood_sugar_empty.tr());
      return;
    }
    if (reason.isEmpty && showReason) {
      Message.showToastMessage(context, R.string.mes_reason_empty.tr());
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
          showReason ? reason : null,
          note,
          fromNipro,
          paths);
      if (result?.id.isNotEmpty == true) {
        await TrackingManager.analytics.logEvent(
          name: 'kpi_add_success',
          parameters: {
            "screen_name": 'kpi_glycemic_add',
            'object_type': 'kpi_glycemic',
            'object_title': 'Chỉ số đường huyết'
          },
        );
        // if(widget.goalId != null && widget.goalId?.isNotEmpty == true){
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
      // DartNotificationCenter.post(channel: 'setup_schedule_change');
      // DartNotificationCenter.post(channel: 'refresh_home');
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
    final reason = _controllerReason.text;
    final note = _controllerNote.text;
    final numberInput = _controller.text;

    if (model != null) {
      final noteText = model!.note ?? '';
      final reasonText = model!.reason ?? '';
      final date =
          DateTime.fromMillisecondsSinceEpoch(model!.createDate! * 1000);
      if (note == noteText &&
          numberInput == model!.glucose!.round().toString() &&
          reason == reasonText &&
          files.length == model!.images.length &&
          removeIDs.length == 0 &&
          date.millisecondsSinceEpoch == selectedDate.millisecondsSinceEpoch) {
        Navigator.pop(context);
        return;
      }
    } else if (note.isEmpty &&
        numberInput.isEmpty &&
        reason.isEmpty &&
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
