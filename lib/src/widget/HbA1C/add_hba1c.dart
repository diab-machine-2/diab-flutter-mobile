import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/HbA1C/HbA1C_Input.dart';
import 'package:medical/src/modal/HbA1C/short_gui.dart';
import 'package:medical/src/modal/error/error_model.dart';
import 'package:medical/src/repo/HbA1C/HbA1C_client.dart';
import 'package:medical/src/repo/home/home_client.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';
import 'package:medical/src/widget/subscription/phone_validation_manager.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:medical/src/widgets/btn_add_photo.dart';
import 'package:medical/src/widgets/spacing_row.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/app_media_query.dart';
import '../../widgets/CalendarPicker/custom_date_picker.dart';
import '../../widgets/network_image_widget.dart';

class AddHBA1CController extends StatefulWidget {
  final String? type;
  final String? id;
  final String? goalId;

  AddHBA1CController({this.type, this.id, this.goalId});
  @override
  _AddHBA1CControllerState createState() => _AddHBA1CControllerState();
}

class _AddHBA1CControllerState extends BaseState<AddHBA1CController> {
  TextEditingController _controller = TextEditingController();
  TextEditingController _controllerNote = TextEditingController();
  DateTime time = DateTime.now();
  int maxMedia = 5;
  List<dynamic> files = []; //PickedFile
  DateTime selectedDate = DateTime.now();
  bool isClicked = false;
  DateTime today = DateTime.now();
  bool btnAction = true;
  List<int> rangeValue = [0, 60, 65, 75];
  List<String> _rangeLabel = ["Tuyệt vời", "Tốt", "Khá cao", "Rất cao"];
  List<Color> _colorList = [
    Color(0xFF20A468),
    Color(0xFF9CD9B8),
    Color(0xFFFFCCD1),
    Color(0xFFE53935),
  ];
  InputHbA1CModel? model;
  List<String?> removeIDs = [];
  bool isLoading = true;
  ShortGuiModel? des;

  int clickTime = 0;
  void initState() {
    initData();
    super.initState();
    if (widget.type == 'update') {
      loadDetail();
    }

    loadDescription();
    firebaseSetup();
  }

  showGuide(BuildContext context) async {
    Description.showTooltip(context,
        data: des!, title: R.string.chi_so_hba1c_doi_voi_benh_tieu_duong.tr());
    clickTime = clickTime + 1;
    await AppSettings.setValueOfClickShortGuideIndex(
        ScreenList.HBA1C.index, clickTime);
  }

  Future firebaseSetup() async {
    await TrackingManager.analytics.logScreenView(
      screenName: "kpi_hba1c_add",
      screenClass: "AddHBA1CController",
    );
    // await TrackingManager.analytics.logEvent(
    //   name: 'kpi_add_begin',
    //   parameters: {
    //     "screen_name": 'kpi_hba1c_add',
    //     'object_type': 'kpi_hba1c',
    //     'object_title': 'Chỉ số HBA1C'
    //   },
    // );
    AppSettings.currentScreenName = 'kpi_hba1c_add';
  }

  void initData() async {
    BotToast.showLoading();
    List<double> values = await HbA1CClient().fetchRange();
    rangeValue = values.map((value) => (value * 10).toInt()).toList();
    isLoading = false;
    List<int> valueOfClickTime = await AppSettings.getValueOfClickShortGuide();
    clickTime = valueOfClickTime[ScreenList.HBA1C.index];
    final colors = await HbA1CClient().fetchColorConfig();
    if (colors != null) {
      _colorList = colors.map((e) {
        return Color(int.parse("0xFF" + e.background.substring(1)));
      }).toList();
      _rangeLabel = colors.map(((e) => e.name)).toList();
    }
    setState(() {});
    BotToast.closeAllLoading();
  }

  void dispose() {
    _controller.dispose();
    _controllerNote.dispose();
    super.dispose();
  }

  loadDetail() async {
    BotToast.showLoading();
    model = await HbA1CClient().fetchDetail(widget.id);
    BotToast.closeAllLoading();
    if (model == null) return;
    _controller.text = model!.hbA1C?.round() == model!.hbA1C
        ? model!.hbA1C!.round().toString()
        : model!.hbA1C.toString();
    _controllerNote.text = model!.description ?? '';
    time = DateTime.fromMillisecondsSinceEpoch((model!.date ?? 0) * 1000);
    files.addAll(model!.images);
    setState(() {});
  }

  loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(5);
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
                          ? R.string.cap_nhat_chi_so_hba1c.tr()
                          : R.string.nhap_chi_so_hba1c.tr(),
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
                      // physics: NeverScrollableScrollPhysics(),

                      children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                bottom: 16, left: 16, right: 16),
                            child: isClicked && clickTime < 2
                                ? Description(
                                    input: true,
                                    isCreateData: true,
                                    data: des,
                                    titleDetail: R.string
                                        .chi_so_hba1c_doi_voi_benh_tieu_duong
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
                            padding: EdgeInsets.all(16),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 100,
                                            child: TextField(
                                                controller: _controller,
                                                maxLength: 4,
                                                onChanged: (value) {
                                                  setState(() {});
                                                },
                                                textAlign: TextAlign.center,
                                                inputFormatters: [],
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                style: TextStyle(
                                                    color: R.color.black,
                                                    fontSize: 34,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                decoration: InputDecoration(
                                                    counterText: '',
                                                    hintText: '0,0',
                                                    contentPadding:
                                                        EdgeInsets.only(
                                                            bottom: 8),
                                                    border: InputBorder.none,
                                                    hintStyle: TextStyle(
                                                        color: R.color
                                                            .captionColorGray,
                                                        fontSize: 34,
                                                        fontWeight:
                                                            FontWeight.w500))),
                                          ),
                                          Text('%')
                                        ]),
                                  ),
                                  Center(
                                      child: Container(
                                          height: 1,
                                          width: 74,
                                          color: R.color.color0xffE5E5E5)),
                                  SizedBox(height: 8),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  isLoading ? SizedBox() : _hba1cRange(),
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
                                        initDate: time,
                                        callback: (value) {
                                          if (value != null)
                                            setState(() {
                                              time = value;
                                            });
                                        }),
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
                                                  getStringToday(
                                                          time.millisecondsSinceEpoch ~/
                                                              1000) +
                                                      (getStringToday(
                                                                  time.millisecondsSinceEpoch ~/
                                                                      1000)
                                                              .isEmpty
                                                          ? ''
                                                          : ', ') +
                                                      convertToUTC(
                                                          time.millisecondsSinceEpoch ~/
                                                              1000,
                                                          'dd/MM/yyyy'),
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                            ],
                                          )
                                          // : Text(
                                          //     convertToUTC(widget.model.date,
                                          //         'dd/MM/yyyy'),
                                          //     style: TextStyle(
                                          //         fontSize: 16,
                                          //         fontWeight:
                                          //             FontWeight.w400)),
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
                                      maxLines: 3,
                                      keyboardType: TextInputType.multiline,
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
                                  SizedBox(height: 16),
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
                    : SafeArea(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
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
      final des = model!.description ?? '';
      final parseTime =
          DateTime.fromMillisecondsSinceEpoch(model!.date! * 1000);
      if (note == des &&
          double.parse(numberInput) == model!.hbA1C &&
          parseTime.millisecondsSinceEpoch == time.millisecondsSinceEpoch &&
          removeIDs.length == 0 &&
          files.length == model!.images.length) {
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

  deleteData() async {
    try {
      BotToast.showLoading();
      final result = await HbA1CClient().deleteIndexHbA1C(model!.id);
      if (result == true) {
        Message.showToastMessage(context, R.string.xoa_thanh_cong.tr());
        Observable.instance
            .notifyObservers([], notifyName: "hba1c_change_data");
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
    final note = _controllerNote.text;
    String numberInput = _controller.text;
    numberInput = numberInput.split(',').join('.');

    if (numberInput == null) {
      Message.showToastMessage(
          context, R.string.ban_chua_nhap_chi_so_hba1c.tr());
      return;
    }
    if (double.parse(numberInput) > 30) {
      Message.showToastMessage(context, R.string.invalid_hba1c.tr());
      return;
    }
    if (time == null) {
      Message.showToastMessage(context, R.string.ban_chua_nhap_thoi_gian.tr());
      return;
    }
    // if (note == '') {
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
      final result = await HbA1CClient().putIndexHbA1C(
          model!.id,
          (time.millisecondsSinceEpoch ~/ 1000).toInt(),
          numberInput,
          note,
          removeIDs,
          paths);
      if (result == true) {
        Message.showToastMessage(context, R.string.luu_thanh_cong.tr());
        Observable.instance
            .notifyObservers([], notifyName: "hba1c_change_data");
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
    final note = _controllerNote.text;
    String numberInput = _controller.text;
    numberInput = numberInput.split(',').join('.');

    if (numberInput.isEmpty) {
      Message.showToastMessage(
          context, R.string.ban_chua_nhap_chi_so_hba1c.tr());
      return;
    }
    if (double.parse(numberInput) > 30) {
      Message.showToastMessage(context, R.string.invalid_hba1c.tr());
      return;
    }
    if (time == null) {
      Message.showToastMessage(context, R.string.ban_chua_nhap_thoi_gian.tr());
      return;
    }
    // if (note == '') {
    //   Message.showToastMessage(context, R.string.ban_chua_nhap_ghi_chu.tr());
    //   return;
    // }
    BotToast.showLoading();

    try {
      List<String> paths = [];
      for (var file in files) {
        paths.add(file.path);
      }
      final result = await HbA1CClient().postIndexHbA1C(
          (time.millisecondsSinceEpoch ~/ 1000).toInt(),
          numberInput,
          note,
          paths);
      if (result == true) {
        // await TrackingManager.analytics.logEvent(
        //   name: 'kpi_add_success',
        //   parameters: {
        //     "screen_name": 'kpi_hba1c_add',
        //     'object_type': 'kpi_hba1c',
        //     'object_title': 'Chỉ số HBA1C'
        //   },
        // );
        HomeClient().completeSmartGoal(DateTime.now(), widget.goalId, 1,
            ScheduleType.hba1c_recommend.typeIndex);
        Observable.instance
            .notifyObservers([], notifyName: "hba1c_change_data");

        // Set flag to show phone validation after successful HbA1C input
        PhoneValidationManager.setShouldShowPhoneValidation();
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

  int findIndexInRanges(double number, List<int> ranges) {
    for (int i = 0; i < ranges.length - 1; i++) {
      if (number >= ranges[i] && number < ranges[i + 1]) {
        return i;
      }
    }
    // If the number is greater than or equal to the last range value
    return ranges.length - 1;
  }

  Widget _hba1cRange() {
    double _number = 0;
    try {
      _number = double.tryParse(_controller.text.replaceAll(",", ".") != ""
              ? _controller.text.replaceAll(",", ".")
              : "0")! *
          10;
    } catch (e) {}

    int index = -1;
    int indexRange = findIndexInRanges(_number, rangeValue);
    num widthRange = (AppMediaQuery.deviceWidth - 64) / (rangeValue.length);
    print('hihi widthRange: $widthRange');
    num width = _number == 0 ? 0 : widthRange * (indexRange);

    // lấy pxPerValue = max - min => 55 - 0
    // lấy pxPerValue * value

    if (_number != null && _number != 0) {
      num min = rangeValue[indexRange];
      print('hihi min: $min');
      num max = indexRange + 1 >= rangeValue.length
          ? rangeValue[indexRange] + min
          : rangeValue[indexRange + 1];
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

      width = width > (widthRange * rangeValue.length)
          ? widthRange * rangeValue.length
          : width;

      //   print('hihi number: $number');
    }

    return SpacingColumn(
      spacing: 30,
      children: [
        if (_number != 0)
          RichText(
            text: TextSpan(
              text: 'HbA1c đang ở mức ',
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
                  children: rangeValue
                      .map(
                        (e) => Expanded(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              SizedBox(),
                              Positioned(
                                left: e.toString().length == 2 ? -9 : -7,
                                child: Text('${e == 0 ? '' : '${e / 10}%'}'),
                              )
                            ],
                          ),
                        ),
                      )
                      .toList()),
            ),
            Positioned(
              left: -3,
              right: 0,
              bottom: 25,
              child: Row(
                  children: rangeValue
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
      final pickedFile = await picker.pickImage(
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
      final pickedFile = await picker.pickImage(
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

  @override
  void initState() {
    if (widget.initDate != null) {
      selectedDate = widget.initDate;
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
                          // setState(() {
                          selectedDate = datetime;
                          // });
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
