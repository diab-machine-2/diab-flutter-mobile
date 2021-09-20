import 'dart:io';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/exercrises/exercrise_Input_detail_model.dart';
import 'package:medical/src/modal/exercrises/exercrises_Category.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/repo/exercrises/exercrises_client.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/widget/BloodSugar/widget/action_list_trend.dart';
import 'package:medical/src/widget/Exercrises/input_detail_exercrise.dart';
import 'package:medical/src/widget/Exercrises/search_exercrises.dart';
import 'package:medical/src/widget/HbA1C/widget/CalendarPicker/custom_date_picker.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:easy_localization/easy_localization.dart';

class AddExercrisesController extends StatefulWidget {
  final String type;
  final String id;
  AddExercrisesController({this.type, this.id});

  @override
  _AddExercrisesControllerState createState() =>
      _AddExercrisesControllerState();
}

class _AddExercrisesControllerState extends BaseState<AddExercrisesController> {
  TextEditingController _controller = TextEditingController();
  TextEditingController _controllerNote = TextEditingController();
  int maxMedia = 5;
  List<dynamic> files = [];
  DateTime selectedDate = DateTime.now();
  bool isClicked = false;
  TimeFrameModel selectedTimeFrame;
  int sumCalories = 0;
  List<ExercrisesCategoryModel> selectedCategory = [];
  List<ListExercriseModel> updatedCategory;
  List<ExercrisesCategoryModel> exercriseRegularly = [];

  InputDetailExercriseModel model;
  List<String> removeIDs = [];

  ShortGuiModel des;

  void initState() {
    super.initState();
    if (widget.type == 'update') {
      loadDetail();
    } else {
      loadTimeFrame();
    }
    loadDescription();
    TrackingManager.analytics.setCurrentScreen(screenName: 'Exercise Input');
  }

  void dispose() {
    _controller.dispose();
    _controllerNote.dispose();
    super.dispose();
  }

  loadDetail() async {
    BotToast.showLoading();
    model = await ExercrisesClient().fetchDetail(widget.id);
    selectedDate = DateTime.fromMillisecondsSinceEpoch(model.date * 1000);
    sumCalories = model != null ? model.burnedCalorie.toInt() : 0;
    selectedCategory = model != null ? [...model.exercise] : [];
    _controllerNote.text = model != null ? model.note : '';
    selectedTimeFrame =
        TimeFrameModel(id: model.timeFrameId, code: '', name: model.timeFrame);
    files.addAll(model.imageUrls);

    if (widget.type == 'update') {
      BotToast.closeAllLoading();
      setState(() {});
    } else {
      loadExercriseRegularly();
    }
  }

  loadTimeFrame() async {
    BotToast.showLoading();
    final timeFrames = await GlucoseClient().fetchFlucoseTimeFrame(
        time: selectedDate.millisecondsSinceEpoch ~/ 1000);
    selectedTimeFrame = timeFrames.length == 0 ? null : timeFrames.first;
    loadExercriseRegularly();
  }

  loadExercriseRegularly() async {
    exercriseRegularly = await ExercrisesClient().fetchExercriseRegularly();
    BotToast.closeAllLoading();
    setState(() {});
  }

  loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(3);
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
                          ? R.string.chinh_sua_van_dong.tr()
                          : R.string.nhap_chi_so_van_dong.tr(),
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
                                    input: false,
                                    data: des,
                                    titleDetail: R.string
                                        .che_do_tap_luyen_doi_voi_benh_tieu_duong
                                        .tr())
                                : SizedBox()),
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 16, left: 16, right: 16),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: R.color.color0xffB1DDDB),
                            padding: EdgeInsets.only(right: 20),
                            child: Row(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(right: 16),
                                  child: Image.asset(R.drawable.im_runner_left,
                                      height: 130),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '${R.string.luong_calo_ban_da_tieu_hao.tr()}:',
                                          style: TextStyle(
                                              color: R.color.textDark,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w400)),
                                      SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(
                                              formatNumber(
                                                  sumCalories.toDouble()),
                                              style: TextStyle(
                                                  color: R.color.textDark,
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w700)),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 2.0, left: 2),
                                            child: Text(
                                              R.string.kcal.tr(),
                                              style: TextStyle(
                                                  color: R.color.textDark,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16.0),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
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
                                          selectedDate = date;
                                        });
                                        loadTimeFrame();
                                      },
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
                                                  : selectedTimeFrame.name,
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
                            child: Column(children: [
                              Container(
                                color: R.color.transparent,
                                child: Column(children: [
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(R.drawable.ic_pulse,
                                                width: 24, height: 24),
                                            SizedBox(width: 8),
                                            Text(R.string.van_dong.tr(),
                                                style: TextStyle(
                                                    color: R.color.black,
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w500))
                                          ],
                                        ),
                                        selectedCategory.length == 0
                                            ? GestureDetector(
                                                onTap: () {
                                                  addActivity();
                                                },
                                                child: Container(
                                                  color: R.color.transparent,
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        R.drawable
                                                            .ic_circle_plus_exe,
                                                        width: 24,
                                                        height: 24,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                          R.string
                                                              .them_hoat_dong
                                                              .tr(),
                                                          style: TextStyle(
                                                              color: R.color
                                                                  .mainColor,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : SizedBox(),
                                      ]),
                                  SizedBox(height: 16),
                                  selectedCategory.length == 0
                                      ? SizedBox()
                                      : Container(
                                          height: 1,
                                          color: R.color.color0xffD6D8E0),
                                  ListView.separated(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.all(0),
                                      itemCount: selectedCategory.length,
                                      separatorBuilder: (context, index) {
                                        return Container(
                                            height: 1,
                                            color: R.color.color0xffD6D8E0);
                                      },
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                barrierColor: R
                                                    .color.color0xff003F38
                                                    .withOpacity(0.5),
                                                context: context,
                                                builder: (_) =>
                                                    CustomInputTimePicker(
                                                        title: R.string
                                                            .chinh_sua_thoi_gian
                                                            .tr(),
                                                        time: selectedCategory[
                                                                index]
                                                            .duration,
                                                        callback:
                                                            (hour, minute) {
                                                          calculatorCalo(index,
                                                              minute, hour);
                                                        }));
                                          },
                                          child: Container(
                                            color: R.color.transparent,
                                            padding: EdgeInsets.only(
                                                bottom: 12, top: 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Stack(
                                                        alignment:
                                                            AlignmentDirectional
                                                                .center,
                                                        children: [
                                                          Image.asset(
                                                              R.drawable
                                                                  .bg_activity_empty,
                                                              width: 50,
                                                              height: 50),
                                                          Image.network(
                                                            selectedCategory[
                                                                        index]
                                                                    .cover
                                                                    .url ??
                                                                '',
                                                            width: 30,
                                                            height: 30,
                                                          )
                                                        ]),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            selectedCategory[
                                                                    index]
                                                                .category,
                                                            style: TextStyle(
                                                                color: R.color
                                                                    .textDark,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                                '${selectedCategory[index].duration.toInt().toString()} ${R.string.minute.tr()},',
                                                                style: TextStyle(
                                                                    color: R
                                                                        .color
                                                                        .textDark,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400)),
                                                            SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                                '${formatNumber(selectedCategory[index].burnedCalorie)} ${selectedCategory[index].unit}',
                                                                style: TextStyle(
                                                                    color: R
                                                                        .color
                                                                        .textDark,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400)),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    final category =
                                                        selectedCategory[index];
                                                    if (category.categoryId ==
                                                        null) {
                                                      exercriseRegularly
                                                          .add(category);
                                                    }
                                                    setState(() {
                                                      selectedCategory
                                                          .removeAt(index);
                                                    });
                                                    sumCalo();
                                                  },
                                                  child: Image.asset(
                                                    R.drawable
                                                        .ic_remove_excersire,
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                  exercriseRegularly.length == 0
                                      ? SizedBox()
                                      : Container(
                                          height: 1,
                                          color: R.color.color0xffD6D8E0),
                                  ListView.separated(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.all(0),
                                      itemCount: exercriseRegularly.length,
                                      separatorBuilder: (context, index) {
                                        return Container(
                                            height: 1,
                                            color: R.color.color0xffD6D8E0);
                                      },
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Stack(children: [
                                          Container(
                                            color: R.color.transparent,
                                            padding: EdgeInsets.only(
                                                bottom: 12, top: 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Stack(
                                                        alignment:
                                                            AlignmentDirectional
                                                                .center,
                                                        children: [
                                                          Image.asset(
                                                              R.drawable
                                                                  .bg_activity_empty,
                                                              width: 50,
                                                              height: 50),
                                                          Image.network(
                                                            exercriseRegularly[
                                                                        index]
                                                                    .cover
                                                                    .url ??
                                                                '',
                                                            width: 30,
                                                            height: 30,
                                                          )
                                                        ]),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            exercriseRegularly[
                                                                    index]
                                                                .category,
                                                            style: TextStyle(
                                                                color: R.color
                                                                    .textDark,
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                                '${exercriseRegularly[index].duration.toInt().toString()} ${R.string.minute.tr()},',
                                                                style: TextStyle(
                                                                    color: R
                                                                        .color
                                                                        .textDark,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400)),
                                                            SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                                '${exercriseRegularly[index].burnedCalorie.round()} ${exercriseRegularly[index].unit}',
                                                                style: TextStyle(
                                                                    color: R
                                                                        .color
                                                                        .textDark,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400)),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedCategory.add(
                                                          exercriseRegularly[
                                                              index]);

                                                      exercriseRegularly
                                                          .removeAt(index);
                                                    });
                                                    sumCalo();
                                                  },
                                                  child: Image.asset(
                                                    R.drawable.ic_add_excersire,
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned.fill(
                                            right: 20,
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: R.color.white
                                                        .withOpacity(0.6))),
                                          )
                                        ]);
                                      }),
                                  selectedCategory.length != 0
                                      ? GestureDetector(
                                          onTap: () {
                                            addActivity();
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                  height: 1,
                                                  color:
                                                      R.color.color0xffD6D8E0),
                                              Container(
                                                color: R.color.transparent,
                                                padding:
                                                    EdgeInsets.only(top: 16),
                                                child: Row(
                                                  children: [
                                                    Image.asset(
                                                      R.drawable
                                                          .ic_circle_plus_exe,
                                                      width: 24,
                                                      height: 24,
                                                    ),
                                                    SizedBox(width: 4),
                                                    Text(
                                                        R.string.them_hoat_dong
                                                            .tr(),
                                                        style: TextStyle(
                                                            color: R.color
                                                                .mainColor,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : SizedBox()
                                ]),
                              ),
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
                            // color: R.color.white,
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
                                                : Stack(
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
                                                              : Image.network(
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
                                                                if (files[index]
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
                                                      ]));
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
                              margin: EdgeInsets.only(bottom: 16, top: 16),
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
                    : Container(
                        margin: EdgeInsets.only(bottom: 32),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, top: 16),
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
                              ]),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  calculatorCalo(int index, int selectedMinute, int selectedHour) async {
    final selected = selectedCategory[index];
    final duration = selectedHour * 60 + selectedMinute;
    BotToast.showLoading();
    final response = await ExercrisesClient().fetchCalories(
        selectedCategory[index].categoryId,
        selectedCategory[index].exerciseIntensityId,
        selectedCategory[index].exerciseId,
        duration);
    BotToast.closeAllLoading();
    print(response);
    final calorisesNumber = response['calories'];
    final unit = response['unit'];
    final description = response['description'];

    setState(() {
      selectedCategory[index] = ExercrisesCategoryModel(
          categoryId: selected.categoryId,
          category: selected.category,
          exerciseId: selected.exerciseId,
          code: selected.code,
          duration: (selectedHour * 60 + selectedMinute).toDouble(),
          burnedCalorie: calorisesNumber,
          exerciseIntensityId: selected.exerciseIntensityId,
          unit: unit,
          description: selected.description,
          order: selected.order,
          cover: selected.cover);
    });

    if (description.isNotEmpty) {
      showDialog(
          barrierColor: R.color.color0xff003F38.withOpacity(0.5),
          context: context,
          builder: (_) {
            Future.delayed(const Duration(seconds: 5), () {
              Navigator.pop(context);
            });
            return Scaffold(
                backgroundColor: R.color.transparent,
                body: Center(
                    child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Container(
                      decoration: BoxDecoration(
                          color: R.color.white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.only(top: 32, left: 32, right: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(R.string.chuc_mung.tr(),
                              style: TextStyle(
                                  color: R.color.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500)),
                          SizedBox(height: 16),
                          Text(
                              '${R.string.ky_luc.tr()}:',
                              textAlign: TextAlign.center),
                          SizedBox(height: 8),
                          Text(
                              (selectedHour * 60 + selectedMinute)
                                      .toDouble()
                                      .round()
                                      .toString() +
                                  ' ${R.string.minute.tr()}',
                              style: TextStyle(
                                  color: R.color.mainColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600)),
                          Image.asset(R.drawable.im_congrat),
                        ],
                      )),
                )));
          });
    }
  }

  addActivity() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => SearchExercrisesController(
            type: widget.type,
            model: selectedCategory,
            callback: (callback, sum) {
              print(sum);
              setState(() {
                selectedCategory.addAll(callback);
                //sumCalories = sum;
                sumCalo();
              });
            },
          ),
        ));
  }

  sumCalo() {
    sumCalories = 0;
    selectedCategory.forEach((element) {
      sumCalories += element.burnedCalorie.toInt();
    });
    setState(() {});
  }

  deleteData() async {
    try {
      BotToast.showLoading();
      final result = await ExercrisesClient().deleteExercrises(widget.id);
      if (result == true) {
        DartNotificationCenter.post(channel: 'active_change_data');
        Navigator.pop(context);
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
    final note = _controllerNote.text ?? '';

    FocusScope.of(context).unfocus();

    if (selectedDate == null) {
      Message.showToastMessage(context, R.string.ban_chua_nhap_thoi_gian.tr());
      return;
    }
    if (selectedTimeFrame == null) {
      Message.showToastMessage(context, R.string.ban_chua_chon_khung_gio.tr());
      return;
    }
    if (selectedCategory.length == 0) {
      Message.showToastMessage(context, R.string.ban_chua_chon_hoat_dong.tr());
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
      final result = await ExercrisesClient().updateExercrises(
          widget.id,
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          selectedTimeFrame.id,
          note,
          selectedCategory,
          removeIDs,
          paths);
      if (result == true) {
        DartNotificationCenter.post(channel: 'active_change_data');
        Navigator.pop(context);
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
    final note = _controllerNote.text ?? '';

    if (selectedDate == null) {
      Message.showToastMessage(context, R.string.ban_chua_nhap_thoi_gian.tr());
      return;
    }
    if (selectedTimeFrame == null) {
      Message.showToastMessage(context, R.string.ban_chua_chon_khung_gio.tr());
      return;
    }
    if (selectedCategory.length == 0) {
      Message.showToastMessage(context, R.string.ban_chua_chon_hoat_dong.tr());
      return;
    }
    BotToast.showLoading();

    try {
      List<String> paths = [];
      for (var file in files) {
        paths.add(file.path);
      }
      final result = await ExercrisesClient().postIndexExercrises(
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          selectedTimeFrame.id,
          note,
          selectedCategory,
          paths);
      if (result == true) {
        DartNotificationCenter.post(channel: 'active_change_data');
        Navigator.pop(context);
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
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
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
    FocusScope.of(context).unfocus();
    final note = _controllerNote.text ?? '';
    if (model != null && model.exercise.length == selectedCategory.length) {
      final noteText = model.note ?? '';
      final date = DateTime.fromMillisecondsSinceEpoch(model.date * 1000);
      if (noteText == note &&
          selectedCategory.length == model.exercise.length &&
          files.length == model.imageUrls.length &&
          removeIDs.length == 0 &&
          selectedDate.millisecondsSinceEpoch == date.millisecondsSinceEpoch) {
        Navigator.pop(context);
        return;
      }
    }
    if (note.isEmpty && selectedCategory.length == 0 && files.length == 0) {
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
                            style: TextStyle(
                                color: R.color.textDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w400)),
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
    Widget cancelButton = FlatButton(
      child: Text(R.string.cancel.tr()),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = FlatButton(
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

typedef TimeCallback = Function(DateTime);

class DateMultiPicker extends StatefulWidget {
  final DateTime initDate;
  final TimeCallback callback;
  DateMultiPicker({this.initDate, this.callback});
  @override
  _DateMultiPickerState createState() => _DateMultiPickerState();
}

class _DateMultiPickerState extends State<DateMultiPicker> {
  DateTime selectedDate = DateTime.now();
  int selectedHour = DateTime.now().hour;
  int selectedMinute = DateTime.now().minute;

  @override
  void initState() {
    if (widget.initDate != null) {
      selectedDate = widget.initDate;
      selectedHour = widget.initDate.hour;
      selectedMinute = widget.initDate.minute;
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
                            : widget.initDate,
                        firstDate: DateTime.parse("1969-07-20 20:18:04Z"),
                        lastDate: DateTime.now(),
                        onDateChanged: (DateTime datetime) {
                          selectedDate = datetime;
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
                          selectedHour = hour;
                          selectedMinute = minute;
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
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                selectedHour,
                                selectedMinute);

                            widget.callback(selectedDate);

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

typedef TimeHourCallback = Function(int, int);

class CustomTimePicker extends StatefulWidget {
  final int selectedHour;
  final int selectedMinute;
  final TimeHourCallback callback;
  CustomTimePicker({this.selectedHour, this.selectedMinute, this.callback});
  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  FixedExtentScrollController hourController;
  FixedExtentScrollController minuteController;
  int selectedHour = 1;
  int selectedMinute = 1;

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
    hourController = FixedExtentScrollController(initialItem: selectedHour);
    minuteController = FixedExtentScrollController(initialItem: selectedMinute);
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
                    widget.callback(selectedHour, selectedMinute);
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
                    widget.callback(selectedHour, selectedMinute);
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
