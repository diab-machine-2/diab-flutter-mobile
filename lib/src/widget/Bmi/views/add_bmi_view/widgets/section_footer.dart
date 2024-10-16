import 'package:medical/src/app.dart';
import 'package:medical/src/widget/BloodSugar/widget/level_off_diabetes_rule_picker.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/profile/widgets/diabetes_status_picker.dart';
import 'package:medical/src/widgets/custom_checkbox_widget.dart';
import 'package:medical/src/widgets/spacing_row.dart';

import 'add_bmi_mixin.dart';
import 'package:medical/res/R.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi_view/add_bmi_cubit.dart';

class SectionFooter extends StatelessWidget with AddBmiMixin {
  final AddBmiCubit cubit;
  const SectionFooter({Key? key, required this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white),
      child: SpacingColumn(
        spacing: 15,
        children: [
          GestureDetector(
            onTap: () {
              LevelOffDiabetesRulePicker.showModal(
                context,
                onSuccess: () async {
                  cubit.infoChanged(isPregnancy: !cubit.isPregnancy);
                  await Future.delayed(Duration(milliseconds: 300));
                  if (cubit.isPregnancy) {
                    DiabetesInformation.showModal(
                      context,
                      onSuccess: () {},
                    );
                  }
                },
              );
            },
            child: Container(
              color: Colors.white,
              child: SpacingRow(
                spacing: 15,
                children: [
                  // IgnorePointer(
                  //   child: CustomCheckboxWidget(
                  //     isChecked: false,
                  //     onTap: () {},
                  //   ),
                  // ),
                  // Text(
                  //   cubit.isPregnancy
                  //       ? R.string.no_longer_pregnant.tr()
                  //       : R.string.in_longer_pregnant.tr(),
                  //   style: TextStyle(fontSize: 16),
                  // )
                ],
              ),
            ),
          ),
          cubit.type == 'input'
              ? GestureDetector(
                  onTap: () {
                    if (cubit.selectedWeight == 0) {
                      Message.showToastMessage(
                          context, R.string.mes_weight_empty.tr());
                      return;
                    }
                    if (cubit.selectedHeight == 0) {
                      Message.showToastMessage(
                          context, R.string.mes_height_empty.tr());
                      return;
                    }
                    if (cubit.selectedHip == 0) {
                      Message.showToastMessage(
                          context, R.string.mes_weight_empty.tr());
                      return;
                    }
                    int indexRange = findIndexInRanges(cubit: cubit);
                    if (indexRange == 0 ||
                        indexRange == cubit.rangeValue.length - 1) {
                      showDialogWarning(context, cubit: cubit);
                    } else {
                      cubit.submitData();
                    }
                  },
                  child: Container(
                      height: 48,
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
                          child: Text(R.string.text_continue.tr(),
                              style: TextStyle(
                                  color: R.color.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)))),
                )
              : SpacingRow(
                  spacing: 15,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => showDialogDelete(context, cubit),
                        child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(200),
                                border:
                                    Border.all(color: R.color.red, width: 2)),
                            child: Text(R.string.xoa_du_lieu.tr(),
                                style: TextStyle(
                                    color: R.color.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600))),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => cubit.editData(),
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
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
                          child: Text(R.string.save.tr(),
                              style: TextStyle(
                                  color: R.color.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
