import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:medical/src/widget/HbA1C/widget/hba1c_warning_popup.dart';
import 'package:medical/src/widget/BloodSugar/widget/section_add_note.dart';
import 'package:medical/src/widget/base/base_state.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/helper/helper.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widget/home/fliter_enum.dart';
import 'package:medical/src/widget/my_plan_screens/activity_tab/activity_tab/models/schedule_type.dart';
import 'package:medical/src/widget/nipro/roche_connection/roche_connection_view.dart';

import '../../utils/app_media_query.dart';
import '../../utils/app_storages.dart';
import '../../utils/navigator_name.dart';
import '../../widgets/CalendarPicker/custom_date_picker.dart';
import 'hba1c_result.dto.dart';

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
  final GlobalKey<SectionAddNoteState> _sectionAddNoteKey =
      GlobalKey<SectionAddNoteState>();
  final FocusNode _focusNode = FocusNode();
  DateTime time = DateTime.now();
  int maxMedia = 5;
  int maxLength = 250;
  List<dynamic> files = []; // Keep for initialization only
  DateTime selectedDate = DateTime.now();
  bool isClicked = false;
  DateTime today = DateTime.now();
  bool btnAction = true;
  List<int> rangeValue = [0, 60, 65, 75];
  List<String> _rangeLabel = ["Lý tưởng", "Tốt", "Cao", "Rất cao"];
  List<Color> _colorList = [
    Color(0xFF64E18E), // #64E18E - Lý tưởng
    Color(0xFF23C559), // #23C559 - Tốt
    Color(0xFFF86F6F), // #F86F6F - Cao
    Color(0xFFD02424), // #D02424 - Rất cao
  ];
  InputHbA1CModel? model;
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

    // Auto-focus to text field when page opens (only for input, not update)
    if (widget.type == 'input') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNode);
      });
    }
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
    _focusNode.dispose();
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
    time = DateTime.fromMillisecondsSinceEpoch((model!.date ?? 0) * 1000,
            isUtc: true)
        .toLocal();
    files.addAll(model!.images);
    if (_sectionAddNoteKey.currentState != null) {
      _sectionAddNoteKey.currentState!
          .updateFilesAndNote(files, model?.description ?? '');
    }
    setState(() {});
  }

  loadDescription() async {
    des = await HbA1CClient().fetchShortGuide(5);
    setState(() {});
  }

  void _doHealthConnect() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RocheConnectionView()),
    );
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
                      // Description section
                      if (isClicked && clickTime < 2)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Description(
                              input: true,
                              isCreateData: true,
                              data: des,
                              titleDetail: R
                                  .string.chi_so_hba1c_doi_voi_benh_tieu_duong
                                  .tr()),
                        ),
                      if (isClicked && clickTime < 2)
                        const SizedBox(height: 16),
                      // Main input container
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
                            if (!isLoading)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: _hba1cRange(),
                              ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Notes section
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
            ? R.string.cap_nhat_chi_so_hba1c.tr()
            : R.string.nhap_chi_so_hba1c.tr(),
        style: TextStyle(
          fontFamily: R.font.sfpro,
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
                Navigator.pushNamed(
                    context, NavigatorName.hba1c_intro_1st_page);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  R.string.huong_dan.tr(),
                  style: TextStyle(
                      fontFamily: R.font.sfpro,
                      color: R.color.white,
                      fontSize: 15),
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
        onTap: () {
          showDialog(
            barrierColor: R.color.color0xff003F38.withOpacity(0.5),
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
                  convertToUTC(time.millisecondsSinceEpoch ~/ 1000,
                      'HH:mm - dd/MM/yyyy'),
                  style: TextStyle(
                    fontFamily: R.font.sfpro,
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
          Container(
            width: 120,
            child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLength: 4,
                onChanged: (value) {
                  setState(() {});
                },
                textAlign: TextAlign.center,
                inputFormatters: [],
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                    color: R.color.black,
                    fontSize: 48,
                    fontFamily: R.font.sfpro,
                    fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                    counterText: '',
                    hintText: '0.0',
                    contentPadding: EdgeInsets.only(bottom: 8),
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        fontFamily: R.font.sfpro,
                        color: R.color.captionColorGray,
                        fontSize: 48,
                        fontWeight: FontWeight.w700))),
          ),
          Text('%',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _noteSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SectionAddNote(
        key: _sectionAddNoteKey,
        controllerNote: _controllerNote,
        maxMedia: maxMedia,
        maxLength: maxLength,
        initialFiles: files,
        noteTitle: R.string.ghi_chu.tr(),
        horizontalPadding: 16,
      ),
    );
  }

  Widget _showInputWithHealthConnect() {
    return FutureBuilder(
      future: AppStorages.getHealthAppPermission(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.hasError) {
          return SizedBox.shrink();
        }

        if (snapshot.hasData) {
          bool? hasPermission = snapshot.data as bool?;
          if (hasPermission == true) {
            return SizedBox.shrink();
          }
        }

        String healthIcon = Platform.isIOS
            ? R.drawable.logo_healthkit
            : R.drawable.logo_healthConnect;
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
    // Kiểm tra input có hợp lệ không
    final validationResult = _validateHbA1cInput(_controller.text);
    final bool _isInputValid =
        validationResult['isValid'] && _controller.text.isNotEmpty;

    return widget.type == 'input'
        ? GestureDetector(
            onTap: _isInputValid
                ? () async {
                    _submitData();
                  }
                : null,
            child: SafeArea(
              top: false,
              child: Container(
                  margin:
                      EdgeInsets.only(top: 0, bottom: 16, left: 12, right: 12),
                  height: 48,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: _isInputValid
                          ? R.color.greenGradientBottom
                          : R.color.grayBorder,
                      borderRadius: BorderRadius.circular(200),
                      gradient: _isInputValid
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.centerRight,
                              colors: [
                                  R.color.greenGradientTop,
                                  R.color.greenGradientBottom
                                ])
                          : null),
                  child: Center(
                      child: Text(R.string.confirm.tr(),
                          style: TextStyle(
                              color: _isInputValid
                                  ? R.color.white
                                  : R.color.textDark,
                              fontWeight: FontWeight.w600,
                              fontSize: 16)))),
            ),
          )
        : SafeArea(
            top: false,
            child: Container(
                margin: EdgeInsets.all(16),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  GestureDetector(
                    onTap: () {
                      _showDialogDelete(context);
                    },
                    child: Container(
                        height: 48,
                        width: 164,
                        decoration: BoxDecoration(
                            color: const Color(0xFFFFE9E9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: R.color.attentionText, width: 1)),
                        child: Center(
                          child: Text(R.string.xoa_du_lieu.tr(),
                              style: TextStyle(
                                  fontFamily: R.font.sfpro,
                                  color: R.color.hba1c_detail_text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  height: 1.46,
                                  letterSpacing: 0.4)),
                        )),
                  ),
                  const SizedBox(width: 11),
                  GestureDetector(
                    onTap: _isInputValid
                        ? () {
                            editData();
                          }
                        : null,
                    child: Container(
                      height: 48,
                      width: 164,
                      decoration: BoxDecoration(
                          color: _isInputValid
                              ? R.color.greenGradientBottom
                              : R.color.grayBorder,
                          borderRadius: BorderRadius.circular(200),
                          gradient: _isInputValid
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                      R.color.greenGradientTop,
                                      R.color.greenGradientBottom
                                    ])
                              : null),
                      child: Center(
                        child: Text('Lưu',
                            style: TextStyle(
                                color: _isInputValid
                                    ? R.color.white
                                    : R.color.textDark,
                                fontSize: 15,
                                fontFamily: R.font.sfpro,
                                fontWeight: FontWeight.w700,
                                height: 1.46,
                                letterSpacing: 0.4)),
                      ),
                    ),
                  ),
                ])),
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
                      // Image.asse t(R.drawable.ic_earse, width: 64, height: 64),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(R.string.ban_muon_xoa_du_lieu.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: R.font.sfpro,
                              color: R.color.textDark,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              letterSpacing: 0.2,
                            )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(R.string.confirm_to_remove_data.tr(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: R.font.sfpro,
                              color: R.color.hba1c_desc_delete_text,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              height: 1.46,
                              letterSpacing: 0.4,
                            )),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 24),
                        child: Column(
                          children: [
                            // Nút Xác nhận (màu đỏ)
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                deleteData();
                              },
                              child: Container(
                                width: 137,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: R.color.attentionText,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: Text(
                                    'Xác nhận',
                                    style: TextStyle(
                                      color: R.color.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: R.font.sfpro,
                                      height: 1.46,
                                      letterSpacing: 0.4,
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
    final data = _sectionAddNoteKey.currentState?.getNote();

    if (model != null) {
      final des = model!.description ?? '';
      final parseTime =
          DateTime.fromMillisecondsSinceEpoch(model!.date! * 1000);
      if (note == des &&
          double.parse(numberInput) == model!.hbA1C &&
          parseTime.millisecondsSinceEpoch == time.millisecondsSinceEpoch &&
          (data?.removeIDs.length ?? 0) == 0 &&
          (data?.files.length ?? 0) == model!.images.length) {
        Navigator.pop(context);
        return;
      }
    } else if (note.isEmpty &&
        numberInput.isEmpty &&
        (data?.files.length ?? 0) == 0) {
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

  deleteData() async {
    try {
      BotToast.showLoading();
      final result = await HbA1CClient().deleteIndexHbA1C(model!.id);
      if (result == true) {
        Message.showToastMessage(context, R.string.xoa_thanh_cong.tr());

        // Navigate to dashboard first, then notify observers
        Navigator.pushNamedAndRemoveUntil(
          context,
          NavigatorName.hba1c_dashboard,
          (route) => route.isFirst,
        );

        // Notify observers AFTER navigation to prevent any interference
        Future.delayed(Duration(milliseconds: 100), () {
          Observable.instance.notifyObservers(
            [],
            notifyName: "hba1c_change_data",
            map: {
              'isNew': false,
              'skipNavigation': true
            }, // Skip any navigation logic
          );
        });
        return;
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
    String numberInput = _controller.text;

    if (numberInput.isEmpty) {
      Message.showToastMessage(
          context, R.string.ban_chua_nhap_chi_so_hba1c.tr());
      return;
    }

    // Sử dụng hàm validation
    final validationResult = _validateHbA1cInput(numberInput);
    if (!validationResult['isValid']) {
      Message.showToastMessage(context, R.string.invalid_hba1c.tr());
      return;
    }

    // Kiểm tra nếu chỉ số nguy hiểm, hiển thị popup cảnh báo
    if (validationResult['isDangerous']) {
      _showHbA1cEditWarningPopup();
      return;
    }

    // Nếu không nguy hiểm, tiếp tục edit bình thường
    _editDataAfterWarning();
  }

  _editDataAfterWarning() async {
    String numberInput = _controller.text;

    // Convert back to original format for API
    numberInput = numberInput.split(',').join('.');
    // 'time' is always initialized; no null check needed
    // if (note == '') {
    //   Message.showToastMessage(context, R.string.ban_chua_nhap_ghi_chu.tr());
    //   return;
    // }
    BotToast.showLoading();

    try {
      List<String> paths = [];
      final data = _sectionAddNoteKey.currentState!.getNote();
      for (var file in (data.files)) {
        if (file is PickedFile) {
          paths.add(file.path);
        }
      }

      // Use exact user-selected timestamp (consistent with _submitData)
      final exactTimestamp = time.millisecondsSinceEpoch ~/ 1000;

      print("HbA1C Edit - User Time: ${time.toIso8601String()}");
      print("HbA1C Edit - Timestamp: $exactTimestamp");

      final result = await HbA1CClient().putIndexHbA1C(
          model!.id,
          exactTimestamp,
          numberInput,
          data.note, // updated to use data.note
          data.removeIDs,
          paths);
      if (result == true) {
        Message.showToastMessage(context, R.string.luu_thanh_cong.tr());
        // Navigate back to dashboard after successful edit first, before notifying observers
        // This prevents any home screen navigation logic from interfering
        Navigator.pushNamedAndRemoveUntil(
          context,
          NavigatorName.hba1c_dashboard,
          (route) => route.isFirst,
          arguments: {
            'currentValue': double.parse(numberInput),
            'currentLevel': _getHbA1cLevelFromValue(double.parse(numberInput)),
            'currentColor': _getHbA1cColorFromValue(double.parse(numberInput)),
          },
        );

        // Notify observers AFTER navigation to prevent any interference
        // Use a delayed notification to ensure navigation completes first
        Future.delayed(Duration(milliseconds: 100), () {
          Observable.instance.notifyObservers(
            [],
            notifyName: "hba1c_change_data",
            map: {
              'isNew': false,
              'skipNavigation': true
            }, // Skip any navigation logic
          );
        });

        return;
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
    String numberInput = _controller.text;

    if (numberInput.isEmpty) {
      Message.showToastMessage(
          context, R.string.ban_chua_nhap_chi_so_hba1c.tr());
      return;
    }

    // Sử dụng hàm validation
    final validationResult = _validateHbA1cInput(numberInput);
    if (!validationResult['isValid']) {
      Message.showToastMessage(context, R.string.invalid_hba1c.tr());
      return;
    }

    // Kiểm tra nếu chỉ số nguy hiểm, hiển thị popup cảnh báo
    if (validationResult['isDangerous']) {
      _showHbA1cWarningPopup();
      return;
    }

    // Nếu không nguy hiểm, tiếp tục submit bình thường
    _submitDataAfterWarning();
  }

  _submitDataAfterWarning() async {
    String numberInput = _controller.text;

    // Convert back to original format for API
    numberInput = numberInput.split(',').join('.');
    // 'time' is always initialized; no null check needed
    // if (note == '') {
    //   Message.showToastMessage(context, R.string.ban_chua_nhap_ghi_chu.tr());
    //   return;
    // }
    BotToast.showLoading();

    try {
      List<String> paths = [];
      final data = _sectionAddNoteKey.currentState!.getNote();
      for (var file in (data.files)) {
        // newly add from system
        paths.add(file.path);
      }

      // Use exact user-selected timestamp with milliseconds for uniqueness
      // This approach is similar to BloodPressure and more reliable than static counter
      final exactTimestamp = time.millisecondsSinceEpoch ~/ 1000;

      print("HbA1C Submit - User Time: ${time.toIso8601String()}");
      print("HbA1C Submit - Timestamp: $exactTimestamp");

      final result = await HbA1CClient()
          .postIndexHbA1C(exactTimestamp, numberInput, data.note, paths);
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

        // Mark user as not first time after successful HbA1C input
        await AppStorages.setHbA1COnboardingCompleted();

        // Notify listeners to refresh HbA1C lists
        Observable.instance.notifyObservers(
          [],
          notifyName: "hba1c_change_data",
          map: {'isNew': true},
        );

        BotToast.closeAllLoading();

        // Navigate to result page
        _navigateToResult(double.parse(numberInput), data.note, data.files);
        return;
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

  void _navigateToResult(double hba1cValue, String note, List<dynamic> files) {
    // Create result DTO
    final resultDto = HbA1CResultDto.fromData(
      id: '', // No ID for new records, will use parameters for analysis
      hba1c: hba1cValue,
      dateTime: time,
      note: note,
      files: files,
      rangeValue:
          rangeValue.map((e) => e / 10.0).toList(), // Convert back to double
      rangeLabels: _rangeLabel,
      colorList: _colorList,
      isNew: true,
      isFetchAnalysis: true,
    );

    // Navigate to result page
    Navigator.of(context).pushReplacementNamed(
      NavigatorName.add_hba1c_result,
      arguments: resultDto,
    );
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

  String _getHbA1cLevelFromValue(double value) {
    // Updated level names to match 4 ranges:
    if (value < 5.7) return 'Lý tưởng';
    if (value < 6.5) return 'Tốt';
    if (value < 9.0) return 'Cao';
    return 'Rất cao';
  }

  Color _getHbA1cColorFromValue(double value) {
    // Updated color scheme matching dashboard and chart:
    if (value < 5.7) {
      // Lý tưởng - Light Green
      return const Color(0xFF64E18E); // #64E18E
    } else if (value < 6.5) {
      // Tốt - Green
      return const Color(0xFF23C559); // #23C559
    } else if (value < 9.0) {
      // Cao - Light Red
      return const Color(0xFFF86F6F); // #F86F6F
    } else {
      // Rất cao - Dark Red
      return const Color(0xFFD02424); // #D02424
    }
  }

  /// Kiểm tra input HbA1c có hợp lệ không
  /// Returns: Map với keys 'isValid' (bool), 'value' (double), 'isDangerous' (bool)
  Map<String, dynamic> _validateHbA1cInput(String inputText) {
    bool isValid = true;
    double value = 0;
    bool isDangerous = false;

    try {
      String cleanInput = inputText.replaceAll(",", ".");
      if (cleanInput.isNotEmpty) {
        double? parsedValue = double.tryParse(cleanInput);
        if (parsedValue == null) {
          isValid = false; // Ký tự không phải số
        } else if (parsedValue > 30) {
          isValid = false; // Số quá lớn (>30%)
        } else {
          value = parsedValue * 10; // Convert to internal format
          isValid = true;
          // Kiểm tra nguy hiểm: HbA1c >= 9%
          isDangerous = parsedValue >= 9.0;
        }
      }
    } catch (e) {
      isValid = false;
    }

    return {
      'isValid': isValid,
      'value': value,
      'isDangerous': isDangerous,
    };
  }

  /// Hiển thị popup cảnh báo HbA1c nguy hiểm
  void _showHbA1cWarningPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return HbA1cWarningPopup(
          onReInput: () {
            Navigator.of(context).pop();
            // Focus vào input field để user nhập lại
            FocusScope.of(context).requestFocus(_focusNode);
          },
          onConfirm: () {
            Navigator.of(context).pop();
            // Tiếp tục submit data sau khi user đã hiểu
            _submitDataAfterWarning();
          },
        );
      },
    );
  }

  /// Hiển thị popup cảnh báo HbA1c nguy hiểm cho edit
  void _showHbA1cEditWarningPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return HbA1cWarningPopup(
          onReInput: () {
            Navigator.of(context).pop();
            // Focus vào input field để user nhập lại
            FocusScope.of(context).requestFocus(_focusNode);
          },
          onConfirm: () {
            Navigator.of(context).pop();
            // Tiếp tục edit data sau khi user đã hiểu
            _editDataAfterWarning();
          },
        );
      },
    );
  }

  Widget _hba1cRange() {
    // Sử dụng hàm validation
    final validationResult = _validateHbA1cInput(_controller.text);
    final bool _isValidInput = validationResult['isValid'];
    final double _number = validationResult['value'];

    int indexRange = _isValidInput ? findIndexInRanges(_number, rangeValue) : 0;

    // Calculate width for each range segment
    double totalWidth =
        AppMediaQuery.deviceWidth - 48; // 24px padding on each side
    double segmentWidth = totalWidth / 4; // 4 segments

    // Calculate arrow position
    double arrowPosition = 0;
    if (_number != 0 && _isValidInput) {
      // Calculate position within the current range
      double min = rangeValue[indexRange].toDouble();
      double max = indexRange + 1 >= rangeValue.length
          ? rangeValue[indexRange] + 50.0 // fallback for last segment
          : rangeValue[indexRange + 1].toDouble();

      double positionInSegment = (_number - min) / (max - min);
      arrowPosition =
          (indexRange * segmentWidth) + (positionInSegment * segmentWidth);

      // Ensure arrow stays within bounds - limit to range bar width
      arrowPosition =
          arrowPosition.clamp(0.0, totalWidth - 40); // 40 = arrow icon width
    }

    return Container(
      margin:
          const EdgeInsets.only(top: 16), // 50px margin top from line height
      child: Column(
        children: [
          // Status text
          if (_controller.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: !_isValidInput
                  ? Text(
                      'Chỉ số không hợp lệ!',
                      style: TextStyle(
                        color: Color(0xFFFF3C3C),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        fontFamily: R.font.sfpro,
                      ),
                    )
                  : RichText(
                      text: TextSpan(
                        text: 'HbA1c đang ở mức ',
                        style: TextStyle(
                            fontFamily: R.font.sfpro,
                            color: R.color.textDark,
                            fontWeight: FontWeight.w400,
                            fontSize: 16),
                        children: <TextSpan>[
                          TextSpan(
                            text: '"${_rangeLabel[indexRange]}"',
                            style: TextStyle(
                              color: _colorList[indexRange],
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

          // Range bar with arrow
          Container(
            height: 84,
            child: Stack(
              children: [
                // Arrow pointing down to current value
                Positioned(
                  left: (() {
                    // Keep arrow fully visible within the range width
                    // Calculate left position with arrow centered
                    double leftPosition =
                        arrowPosition - 20; // 20 = half arrow width

                    // Clamp to keep arrow within visible bounds
                    // Left boundary: -14 (small negative offset for start position)
                    // Right boundary: totalWidth - 40 (full arrow width from right edge)
                    return leftPosition.clamp(-14.0, totalWidth - 40.0);
                  })(),
                  top: -10,
                  child: Icon(
                    Icons.arrow_drop_down_rounded,
                    size: 40,
                    color: Colors.black87,
                  ),
                ),

                // Percentage labels below the range bar
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 30,
                        alignment: Alignment.center,
                        child: Text(
                          '6.5%',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: R.font.sfpro,
                            color: R.color.textDark,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Container(
                        width: 30,
                        alignment: Alignment.center,
                        child: Text(
                          '7%',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: R.font.sfpro,
                            color: R.color.textDark,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Container(
                        width: 30,
                        alignment: Alignment.center,
                        child: Text(
                          '8%',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: R.font.sfpro,
                            color: R.color.textDark,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Color segments (at the bottom)
                Positioned(
                  top: 45,
                  left: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      children: List.generate(4, (index) {
                        return Container(
                          height: 8,
                          width: segmentWidth,
                          color: _colorList[index],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
  DateTime? selectedDate;
  int selectedHour = DateTime.now().hour;
  int selectedMinute = DateTime.now().minute;
  final GlobalKey<CustomTimePickerState> _calendarDatePickerKey =
      GlobalKey<CustomTimePickerState>();

  @override
  void initState() {
    super.initState();
    if (widget.initDate != null) {
      selectedDate = widget.initDate;
      selectedHour = widget.initDate!.hour;
      selectedMinute = widget.initDate!.minute;
    } else {
      selectedDate = DateTime.now();
      selectedHour = DateTime.now().hour;
      selectedMinute = DateTime.now().minute;
    }
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
                          if (_calendarDatePickerKey.currentState != null) {
                            _calendarDatePickerKey.currentState!
                                .setSelectedDate(selectedDate!);
                          }
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
                        key: _calendarDatePickerKey,
                        initSelectedDate: selectedDate,
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
                              borderRadius: BorderRadius.circular(21.5),
                              border: Border.all(
                                  color: R.color.greenGradientBottom),
                            ),
                            child: Center(
                              child: Text(R.string.cancel.tr(),
                                  style: TextStyle(
                                      color: R.color.greenGradientBottom,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
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
                                  color: R.color.greenGradientBottom,
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
  final DateTime? initSelectedDate;
  CustomTimePicker(
      {Key? key,
      this.selectedHour,
      this.selectedMinute,
      this.callback,
      this.initSelectedDate})
      : super(key: key);
  @override
  CustomTimePickerState createState() => CustomTimePickerState();
}

class CustomTimePickerState extends State<CustomTimePicker> {
  FixedExtentScrollController? hourController;
  FixedExtentScrollController? minuteController;
  int? selectedHour = 1;
  int? selectedMinute = 1;
  DateTime now = DateTime.now();
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initSelectedDate;
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

  void setSelectedDate(DateTime date) {
    selectedDate = date;
    if (_isTimeInFuture(selectedHour!, selectedMinute!)) {
      selectedHour = now.hour;
      selectedMinute = now.minute;
      hourController!.jumpToItem(selectedHour!);
      minuteController!.jumpToItem(selectedMinute!);
    }
    setState(() {});
  }

  // Check if a time is in the future
  bool _isTimeInFuture(int hour, int minute) {
    final now = DateTime.now();
    if (selectedDate != null &&
        selectedDate!.isBefore(DateTime(now.year, now.month, now.day))) {
      return false;
    }
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
                                      ? R.color.greenGradientBottom
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
                                      ? R.color.greenGradientBottom
                                      : R.color.color0xffC0C2C5,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ))
                    .toList()))
      ],
    );
  }
}
