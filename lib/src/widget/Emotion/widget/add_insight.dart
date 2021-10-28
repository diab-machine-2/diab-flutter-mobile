import 'dart:io';
import 'dart:ui';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:flutter_tags/flutter_tags.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/emotion/activity_model.dart';
import 'package:medical/src/modal/emotion/emotion_model.dart';
import 'package:medical/src/modal/emotion/input_emotion_model.dart';
import 'package:medical/src/modal/emotion/symptom_model.dart';
import 'package:medical/src/modal/glucose/glucose_timeFrame.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/repo/emotion/emotion_client.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/widget/BloodSugar/widget/action_list_trend.dart';
import 'package:medical/src/widget/Emotion/widget/add_emo.dart';
import 'package:medical/src/widget/Emotion/widget/add_symbo.dart';
import 'package:medical/src/widget/Emotion/widget/add_work.dart';
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

class AddInsightController extends StatefulWidget {
  final String? type;
  final String? id;
  final EmotionModel? emotion;
  final List<SymptomModel>? symptoms;
  final List<ActivityModel>? activities;
  final String? otherSymptom;
  final String? otherActivity;

  AddInsightController(
      {this.type,
      this.id,
      this.emotion,
      this.symptoms,
      this.activities,
      this.otherSymptom,
      this.otherActivity});

  @override
  _AddInsightControllerState createState() => _AddInsightControllerState();
}

class _AddInsightControllerState extends BaseState<AddInsightController> {
  TextEditingController _controllerNote = TextEditingController();
  int maxMedia = 5;
  List<dynamic> files = [];
  DateTime selectedDate = DateTime.now();
  bool isClicked = false;
  DateTime time = DateTime.now();
  TimeFrameModel? selectedTimeFrame;
  List<String?> removeIDs = [];

  InputEmotionModel? model;

  EmotionModel? emotion;
  List<SymptomModel> symptoms = [];
  List<ActivityModel> activities = [];
  String? otherSymptom;
  String? otherActivity;

  ShortGuiModel? des;

  void initState() {
    super.initState();
    if (widget.type == 'input') {
      emotion = widget.emotion;
      symptoms = widget.symptoms ?? [];
      activities = widget.activities ?? [];
      otherSymptom = widget.otherSymptom;
      otherActivity = widget.otherActivity;
      loadTimeFrame();
    } else {
      loadDataDetail();
    }
    loadDescription();
    TrackingManager.analytics.setCurrentScreen(screenName: 'Emotion Input');
  }

  void dispose() {
    super.dispose();
  }

  loadDataDetail() async {
    BotToast.showLoading();
    model = await EmotionClient().fetchDetail(widget.id);
    BotToast.closeAllLoading();

    selectedDate = DateTime.fromMillisecondsSinceEpoch(model!.date! * 1000);
    selectedTimeFrame = TimeFrameModel(
        id: model!.timeFrameId, code: '', name: model!.timeFrameText);
    files.addAll(model!.images);

    emotion = EmotionModel(
        id: model!.emotionId,
        code: null,
        vietnameseName: model!.emotionText,
        englishName: null,
        description: null,
        emotionCategoryId: null,
        coverId: null,
        status: null,
        imageUrl: model!.emotionIcon.url);
    symptoms = model!.symptoms;
    activities = model!.activities;
    otherSymptom = model!.otherSymptom;
    otherActivity = model!.otherActivity;
    _controllerNote.text = model!.note ?? '';
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
    des = await HbA1CClient().fetchShortGuide(6);
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
                          ? R.string.chinh_sua_cam_xuc.tr()
                          : R.string.nhap_cam_xuc.tr(),
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
                        isClicked
                            ? Padding(
                                padding: EdgeInsets.only(
                                    left: 16, right: 16, bottom: 16),
                                child: Description(
                                    input: true,
                                    data: des,
                                    titleDetail: R.string
                                        .kiem_soat_cam_xuc_benh_tieu_duong
                                        .tr()),
                              )
                            : SizedBox(),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                                builder: (BuildContext context) {
                              return AddEmoController(
                                type: 'update',
                                emotion: emotion,
                                callback: (data) {
                                  setState(() {
                                    emotion = data;
                                  });
                                },
                              );
                            }));
                          },
                          child: Container(
                            color: R.color.transparent,
                            child: Column(
                              children: [
                                Image.network(
                                    emotion == null
                                        ? ''
                                        : emotion!.imageUrl ?? '',
                                    width: 60,
                                    height: 60),
                                SizedBox(height: 16),
                                Text(
                                    emotion == null
                                        ? ''
                                        : emotion!.vietnameseName!,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                                SizedBox(height: 20),
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
                            // color: R.color.white,
                            padding: EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        Image.asset(R.drawable.ic_chatting,
                                            width: 24, height: 24),
                                        SizedBox(width: 8),
                                        Text(
                                            R.string.trieu_chung_cua_ban
                                                .tr(),
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    FontWeight.w700)),
                                      ]),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(context,
                                              MaterialPageRoute(builder:
                                                  (BuildContext context) {
                                            return AddSymboController(
                                              type: 'update',
                                              symptoms: symptoms,
                                              otherSymptom: otherSymptom,
                                              callback: (data, other) {
                                                setState(() {
                                                  symptoms = data ?? [];
                                                  otherSymptom = other;
                                                });
                                              },
                                            );
                                          }));
                                        },
                                        child: Text(R.string.chinh_sua.tr(),
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: R.color.mainColor)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  Tags(
                                    // key: _tagStateKey,
                                    alignment: WrapAlignment.start,
                                    runAlignment: WrapAlignment.start,
                                    spacing: 2,
                                    horizontalScroll: false,
                                    itemCount: symptoms.length,
                                    itemBuilder: (index) {
                                      final item = symptoms[index];

                                      return ItemTags(
                                          padding: EdgeInsets.only(
                                              bottom: 0,
                                              top: 0,
                                              left: 4,
                                              right: 8),
                                          pressEnabled: false,
                                          key: Key(index.toString()),
                                          index: index,
                                          image: ItemTagsImage(
                                            child: Image.network(
                                                item.icon.url ?? '',
                                                width: 24,
                                                height: 24),
                                          ),
                                          title: item.name!,
                                          activeColor: R.color.white,
                                          textOverflow:
                                              TextOverflow.visible,
                                          splashColor: R.color.green,
                                          combine:
                                              ItemTagsCombine.withTextAfter,
                                          textActiveColor: R.color.textDark,
                                          textStyle:
                                              TextStyle(fontSize: 14),
                                          elevation: 0,
                                          onPressed: (item) => null);
                                    },
                                  ),
                                  otherSymptom == null ||
                                          otherSymptom!.isEmpty
                                      ? SizedBox()
                                      : Column(children: [
                                          SizedBox(
                                            height: 16,
                                          ),
                                          Container(
                                              height: 1,
                                              color:
                                                  R.color.color0xffE5E5E5),
                                          Column(
                                            children: [
                                              SizedBox(
                                                height: 16,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(R.string.khac.tr(),
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          color: R.color
                                                              .textDark,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w700)),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                        otherSymptom!,
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color: R.color
                                                                .textDark,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400)),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        ]),
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
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(children: [
                                            Image.asset(R.drawable.ic_pulse,
                                                width: 24, height: 24),
                                            SizedBox(width: 8),
                                            Text(
                                                R.string.hoat_dong_cua_ban.tr(),
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w700)),
                                          ]),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(builder:
                                                      (BuildContext context) {
                                                return AddWorkController(
                                                  type: 'update',
                                                  activities: activities,
                                                  otherActivity: otherActivity,
                                                  callback: (data, other) {
                                                    setState(() {
                                                      activities = data ?? [];
                                                      otherActivity = other;
                                                    });
                                                  },
                                                );
                                              }));
                                            },
                                            child: Text(R.string.chinh_sua.tr(),
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: R.color.mainColor)),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Tags(
                                        // key: _tagStateKey,
                                        alignment: WrapAlignment.start,
                                        runAlignment: WrapAlignment.start,
                                        //columns: 3,
                                        horizontalScroll: false,
                                        itemCount: activities.length,
                                        itemBuilder: (index) {
                                          final item = activities[index];
                                          print(item.icon.url);

                                          return ItemTags(
                                              pressEnabled: false,
                                              key: Key(index.toString()),
                                              padding: EdgeInsets.only(
                                                  bottom: 2,
                                                  top: 0,
                                                  left: 8,
                                                  right: 8),
                                              index: index,
                                              image: ItemTagsImage(
                                                child: Image.network(
                                                    item.icon.url ?? '',
                                                    width: 24,
                                                    height: 24),
                                              ),
                                              title: item.name!,
                                              activeColor: R.color.white,
                                              textOverflow:
                                                  TextOverflow.visible,
                                              splashColor: R.color.green,
                                              combine:
                                                  ItemTagsCombine.withTextAfter,
                                              textActiveColor: R.color.textDark,
                                              textStyle:
                                                  TextStyle(fontSize: 14),
                                              elevation: 0,
                                              onPressed: (item) => null);
                                        },
                                      ),
                                      otherActivity == null ||
                                              otherActivity!.isEmpty
                                          ? SizedBox()
                                          : Column(children: [
                                              SizedBox(
                                                height: 16,
                                              ),
                                              Container(
                                                  height: 1,
                                                  color:
                                                      R.color.color0xffE5E5E5),
                                              Column(
                                                children: [
                                                  SizedBox(
                                                    height: 16,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(R.string.khac.tr(),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: R.color
                                                                  .textDark,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700)),
                                                      SizedBox(width: 8),
                                                      Expanded(
                                                        child: Text(
                                                            otherActivity!,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: R.color
                                                                    .textDark,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400)),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            ]),
                                    ]),
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
                                        if (date != null) {
                                          setState(() {
                                            selectedDate = date;
                                          });
                                          loadTimeFrame();
                                        }
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
                          margin: EdgeInsets.only(top: 16, bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 16),
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
                                ]),
                          ),
                        ),
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
      final result = await EmotionClient().deleteIndexEmotion(widget.id);
      if (result == true) {
        Observable.instance
            .notifyObservers([], notifyName: "Emotion_change_data");
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
    final note = _controllerNote.text;
    List<String?> symptomIds = [];
    List<String?> activityIds = [];

    symptoms.forEach((element) {
      symptomIds.add(element.id);
    });
    activities.forEach((element) {
      activityIds.add(element.id);
    });

    // if (symptomIds.length == 0) {
    //   Message.showToastMessage(context, 'Bạn chưa chọn triệu chứng');
    //   return;
    // }
    // if (activityIds.length == 0) {
    //   Message.showToastMessage(context, R.string.ban_chua_chon_hoat_dong.tr());
    //   return;
    // }

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
        if (file is PickedFile) {
          paths.add(file.path);
        }
      }
      final result = await EmotionClient().updateEmotionInput(
          widget.id,
          emotion!.id,
          symptomIds,
          activityIds,
          otherSymptom,
          otherActivity,
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          selectedTimeFrame!.id,
          note,
          removeIDs,
          paths);
      if (result == true) {
        Observable.instance
            .notifyObservers([], notifyName: "Emotion_change_data");
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
    final note = _controllerNote.text;
    List<String?> symptomIds = [];
    List<String?> activityIds = [];

    symptoms.forEach((element) {
      symptomIds.add(element.id);
    });
    activities.forEach((element) {
      activityIds.add(element.id);
    });

    // if (symptomIds.length == 0) {
    //   Message.showToastMessage(context, 'Bạn chưa chọn triệu chứng');
    //   return;
    // }
    // if (activityIds.length == 0) {
    //   Message.showToastMessage(context, R.string.ban_chua_chon_hoat_dong.tr());
    //   return;
    // }

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
      final result = await EmotionClient().postEmotionInput(
          emotion!.id,
          symptomIds,
          activityIds,
          otherSymptom,
          otherActivity,
          (selectedDate.millisecondsSinceEpoch ~/ 1000).toInt(),
          selectedTimeFrame!.id,
          note,
          paths);
      if (result == true) {
        Observable.instance
            .notifyObservers([], notifyName: "Emotion_change_data");
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
    final note = _controllerNote.text;
    if (model != null) {
      final noteText = model!.note ?? '';
      final date = DateTime.fromMillisecondsSinceEpoch(model!.date! * 1000);
      if (model!.symptoms == symptoms &&
          model!.activities == activities &&
          note == noteText &&
          files.length == model!.images.length &&
          removeIDs.length == 0 &&
          date.millisecondsSinceEpoch == selectedDate.millisecondsSinceEpoch) {
        Navigator.pop(context);
        return;
      }
    } else {
      if ((symptoms.isEmpty && widget.symptoms == null) &&
          (activities.isEmpty && widget.activities == null) &&
          note.isEmpty &&
          files.length == 0) {
        Navigator.pop(context);
        return;
      }
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
                  Image.asset(R.drawable.ic_camera_black,
                      width: 24, height: 24),
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
                  Image.asset(R.drawable.ic_photo, width: 24, height: 24),
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
      content: Text(R.string.camera_permission_required.tr()),
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
