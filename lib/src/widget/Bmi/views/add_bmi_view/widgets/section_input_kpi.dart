import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/utils/utils.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi_view/add_bmi_cubit.dart';
import 'package:medical/src/widgets/spacing_row.dart';
import 'custom_height_picker.dart';
import 'custome_weight_picker.dart';

class SectionInputKpi extends StatelessWidget {
  final AddBmiCubit cubit;
  const SectionInputKpi({Key? key, required this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isGestationalDiabetes = Utils.isGestationalDiabetes();
    return SpacingRow(
      spacing: 20,
      children: [
        _inputKpi(
            value: "${cubit.selectedWeight != 0 ? cubit.selectedWeight : ''}",
            label: R.string.enter_weight_label.tr(),
            onTap: () {
              showDialog(
                barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                context: context,
                builder: (_) => CustomWeightPicker(
                    callback: (number) {
                      cubit.infoChanged(selectedWeight: number);
                      // handleBMI();
                    },
                    title: R.string.enter_weight.tr(),
                    max: 180,
                    numberDefault: cubit.selectedWeight != 0
                        ? cubit.selectedWeight
                        : cubit.selectedWeightDefault,
                    unit: R.string.kg.tr()),
              );
            }),
        if (AppSettings.userInfo!.height == 0 ||
            AppSettings.userInfo!.height == null)
          _inputKpi(
            value: "${cubit.selectedHeight != 0 ? cubit.selectedHeight : ''}",
            label: R.string.enter_height_label.tr(),
            onTap: () {
              showDialog(
                barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                context: context,
                builder: (_) => CustomNumPicker(
                    callback: (num) {
                      cubit.infoChanged(selectedHeight: num);
                      // handleBMI();
                    },
                    title: R.string.enter_height.tr(),
                    max: 250,
                    numberDefault:
                        cubit.selectedHeight == 0 ? 150 : cubit.selectedHeight,
                    unit: R.string.cm.tr()),
              );
            },
          ),
        if (!isGestationalDiabetes)
          _inputKpi(
              value: "${cubit.selectedHip != 0 ? cubit.selectedHip : ''}",
              label: R.string.enter_waist_label.tr(),
              onTap: () {
                showDialog(
                  barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                  context: context,
                  builder: (_) => CustomNumPicker(
                      callback: (num) {
                        cubit.infoChanged(selectedHip: num);
                      },
                      title: R.string.enter_waist.tr(),
                      max: 180,
                      numberDefault:
                          cubit.selectedHip == 0 ? 60 : cubit.selectedHip,
                      unit: R.string.cm.tr()),
                );
              }),
      ],
    );
  }

  Widget _inputKpi({
    required String label,
    required String value,
    required GestureTapCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: SpacingColumn(
          spacing: 15,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: 80),
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Color(0xFFE2E4E7)),
                ),
              ),
              child: AutoSizeText(
                value,
                maxLines: 1,
                style: TextStyle(
                    color: R.color.mainColor,
                    fontSize: 48,
                    fontFamily: 'Viga',
                    fontWeight: FontWeight.w500),
              ),
            ),
            AutoSizeText(
              label,
              maxLines: 1,
              style: TextStyle(fontSize: 14, color: R.color.textDark),
            )
          ],
        ),
      ),
    );
  }

  // Widget _inputWeight(BuildContext context) {
  //   return Expanded(
  //     child: SpacingColumn(
  //       spacing: 15,
  //       children: [
  //         Container(
  //           padding: EdgeInsets.only(bottom: 5),
  //           decoration: BoxDecoration(
  //             border: Border(
  //               bottom: BorderSide(color: Color(0xFFE2E4E7)),
  //             ),
  //           ),
  //           child: TextField(
  //             textAlign: TextAlign.center,
  //             keyboardType: TextInputType.numberWithOptions(decimal: true),
  //             style: TextStyle(
  //                 color: R.color.black,
  //                 fontSize: 48,
  //                 fontFamily: 'Viga',
  //                 fontWeight: FontWeight.w500),
  //             readOnly: true,
  //             onTap: () {},
  //             decoration: InputDecoration(
  //               counterText: '',
  //               contentPadding: EdgeInsets.only(bottom: 8),
  //               border: InputBorder.none,
  //               hintStyle: TextStyle(
  //                   fontFamily: 'Viga',
  //                   color: Color(0xffDDDDDD),
  //                   fontSize: 48,
  //                   fontWeight: FontWeight.w700),
  //             ),
  //           ),
  //         ),
  //         AutoSizeText(
  //           "Cân nặng (kg)",
  //           maxLines: 1,
  //           style: TextStyle(fontSize: 14, color: R.color.textDark),
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget _inputHeight(BuildContext context) {
    return Expanded(
      child: SpacingColumn(
        spacing: 15,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E4E7)),
              ),
            ),
            child: TextField(
              textAlign: TextAlign.center,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextStyle(
                  color: R.color.black,
                  fontSize: 48,
                  fontFamily: 'Viga',
                  fontWeight: FontWeight.w500),
              readOnly: true,
              onTap: () {
                showDialog(
                  barrierColor: R.color.color0xff003F38.withOpacity(0.5),
                  context: context,
                  builder: (_) => CustomNumPicker(
                      callback: (num) {
                        cubit.infoChanged(selectedHeight: num);
                        // handleBMI();
                      },
                      title: R.string.enter_height.tr(),
                      max: 250,
                      numberDefault: cubit.selectedHeight == 0
                          ? 150
                          : cubit.selectedHeight,
                      unit: R.string.cm.tr()),
                );
              },
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.only(bottom: 8),
                border: InputBorder.none,
                hintStyle: TextStyle(
                    fontFamily: 'Viga',
                    color: Color(0xffDDDDDD),
                    fontSize: 48,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          AutoSizeText(
            R.string.enter_height_label.tr(),
            maxLines: 1,
            style: TextStyle(fontSize: 14, color: R.color.textDark),
          )
        ],
      ),
    );
  }
}
