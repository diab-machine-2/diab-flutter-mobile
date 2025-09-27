import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/modal/user/category_item_user_model.dart';
import 'package:medical/src/repo/glucose/glucose_client.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/widget/Bmi_temp/widget/add_bmi.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/block_bottom_sheet.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/spacing_row.dart';

class DiabetesStatusPicker extends StatefulWidget {
  final int? state;
  final Function(int)? onChanged;
  final List<CategoryItemUserModel> levelOfDiabetesList;
  const DiabetesStatusPicker(
      {this.levelOfDiabetesList = const [], this.state, this.onChanged});

  @override
  _DiabetesStatusPickerState createState() => _DiabetesStatusPickerState();
}

class _DiabetesStatusPickerState extends State<DiabetesStatusPicker> {
  FixedExtentScrollController? scrollController;
  int selectedItem = 0;

  List<CategoryItemUserModel>? diabeteStates = [];

  @override
  void initState() {
    super.initState();
    scrollController = FixedExtentScrollController(
        initialItem: widget.state == null ? 0 : (widget.state!));
    selectedItem = widget.state == null ? 0 : (widget.state!);

    diabeteStates = widget.levelOfDiabetesList;
    if (widget.state == null) {
      widget.onChanged!(0);
      selectedItem = 0;
    }
    //  loadData();
  }

  // loadData() async {
  //   BotToast.showLoading();
  //   diabeteStates = await UserClient().fetchDiabeteStates();
  //   if (widget.state == null) {
  //     widget.onChanged!(diabeteStates![0]);
  //     selectedItem = 0;
  //   }

  //   BotToast.closeAllLoading();
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return diabeteStates!.isEmpty
        ? const SizedBox()
        : CupertinoPicker(
            scrollController: scrollController,
            selectionOverlay: null,
            onSelectedItemChanged: (value) {
              widget.onChanged!(value);
              setState(() {
                selectedItem = value;
              });
            },
            itemExtent: 47.0,
            children: List<int>.generate(diabeteStates!.length, (i) => i)
                .map((e) => Center(
                      child: Text(getValue(diabeteStates![e]),
                          style: TextStyle(
                              color: selectedItem == e
                                  ? R.color.mainColor
                                  : R.color.color0xffC0C2C5,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ))
                .toList());
  }

  String getValue(CategoryItemUserModel diabete) {
    print('diabete.text: ${diabete.text}');
    if (diabete.text != null) {
      return diabete.text!;
    } else {
      if (diabete.value != null) {
        return diabete.value!;
      } else {
        return '';
      }
    }
  }
}

class DiabetesInformation extends StatefulWidget {
  final Function onSuccess;
  const DiabetesInformation({Key? key, required this.onSuccess})
      : super(key: key);

  static showModal(
    BuildContext context, {
    required Function onSuccess,
  }) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: true,
      context: context,
      builder: (BuildContext ctx) => Padding(
        padding: EdgeInsets.only(top: AppMediaQuery.deviceSafeAreaTop + 25),
        child: DiabetesInformation(
          onSuccess: onSuccess,
        ),
      ),
    );
  }

  @override
  State<DiabetesInformation> createState() => _DiabetesInformationState();
}

class _DiabetesInformationState extends State<DiabetesInformation> {
  int? tuanThaiKy = 1;
  num? canNangThaiKy = 0;
  bool isExpanded = false;

  @override
  void initState() {
    initData();
    super.initState();
  }

  initData() {
    canNangThaiKy = (AppSettings.userInfo!.weight == null ||
            AppSettings.userInfo!.weight == 0
        ? 50
        : AppSettings.userInfo!.weight)!;
    tuanThaiKy = AppSettings.userInfo!.curentWeekPregnancy ?? 1;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlockBottomSheet(
      title: 'Nhập thông tin thai kỳ',
      description:
          'Nhập thông tin thai kỳ để số liệu được cập nhật phù hợp với Đái tháo đường thai kỳ.',
      child: SizedBox(
        height: isExpanded
            ? AppMediaQuery.deviceHeigthAvailable
            : AppMediaQuery.deviceHeigthAvailable / 2,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            height:
                !isExpanded ? AppMediaQuery.deviceHeigthAvailable / 2 : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                SpacingColumn(
                  children: [
                    SpacingColumn(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tuần thai kỳ',
                          style: TextStyle(
                            color: R.color.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                          child: Container(
                            height: 56,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: isExpanded
                                      ? R.color.mainColor
                                      : Color(0xFFF3F3F3)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: SpacingRow(
                              children: [
                                Expanded(
                                  child: Text(
                                    tuanThaiKy != null
                                        ? 'Tuần $tuanThaiKy'
                                        : 'Chọn tuần thai kỳ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF787A7D),
                                      fontWeight: tuanThaiKy != null
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up_outlined
                                      : Icons.keyboard_arrow_down_outlined,
                                  color: Color(0xff9C9C9C),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isExpanded)
                      SizedBox(
                        height: AppMediaQuery.deviceHeigthAvailable / 2,
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(15),
                          child: SpacingColumn(
                            spacing: 5,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(54, (index) {
                              int number = index + 1;
                              return _itemSelection(number);
                            }),
                          ),
                        ),
                      ),
                    SizedBox(height: 15),
                    SpacingColumn(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Cân nặng trước khi mang thai ',
                            style: TextStyle(
                              color: R.color.textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                text: '(kg)',
                                style: TextStyle(
                                  color: Color(0xFFA1A3A6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => onSelectWeight(),
                          child: Container(
                            height: 56,
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                border: Border.all(color: Color(0xFFF3F3F3)),
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              canNangThaiKy != null
                                  ? canNangThaiKy.toString()
                                  : 'Nhập cân nặng',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF787A7D),
                                fontWeight: canNangThaiKy != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 25),
                SpacingRow(
                  spacing: 20,
                  children: [
                    Expanded(
                      child: ButtonWidget(
                        height: 43,
                        textSize: 14,
                        onPressed: () => Navigator.pop(context),
                        title: R.string.cancel.tr(),
                        textColor: R.color.textDark,
                        backgroundColor: Color(0xFFF4F5F6),
                      ),
                    ),
                    Expanded(
                      child: ButtonWidget(
                        height: 43,
                        title: R.string.cap_nhat.tr(),
                        onPressed: () => updatePregnancyInfo(),
                        textSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppMediaQuery.deviceSafeAreaBottom),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _itemSelection(int value) {
    bool isActive = value == tuanThaiKy;
    return GestureDetector(
      onTap: () {
        setState(() {
          tuanThaiKy = value;
          isExpanded = false;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: SpacingRow(
          spacing: 15,
          children: [
            Expanded(
              child: Text(
                'Tuần $value',
                style: TextStyle(
                  fontSize: 18,
                  color: isActive ? R.color.mainColor : null,
                  fontWeight: isActive ? FontWeight.w600 : null,
                ),
              ),
            ),
            if (isActive)
              Icon(
                Icons.check,
                size: 18,
                color: R.color.mainColor,
              )
          ],
        ),
      ),
    );
  }

  onSelectWeight() {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (_) => CustomWeightPicker(
          callback: (weight) {
            if (weight <= 0) {
              Message.showToastMessage(
                  context, R.string.mes_weight_must_greater_than_zero.tr());
              return;
            }
            setState(() {
              canNangThaiKy = weight;
            });
          },
          title: R.string.enter_weight.tr(),
          max: 180,
          numberDefault: canNangThaiKy ?? 0,
          unit: ''),
    );
  }

  updatePregnancyInfo() async {
    final result = await GlucoseClient()
        .updatePregnancyInfo(week: tuanThaiKy ?? 1, weight: canNangThaiKy ?? 0);
    if (result == true) {
      Navigator.pop(context);
      widget.onSuccess();
    }
  }
}
