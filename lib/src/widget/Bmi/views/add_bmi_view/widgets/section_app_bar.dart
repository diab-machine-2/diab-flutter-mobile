import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi_view/add_bmi_cubit.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi_view/widgets/add_bmi_mixin.dart';
import 'package:medical/src/widget/HbA1C/widget/description/description.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

class SectionAppBar extends StatelessWidget with AddBmiMixin {
  final AddBmiCubit cubit;
  const SectionAppBar({Key? key, required this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomAppBar(
          backgroundColor: R.color.transparent,
          title: Text(
              cubit.type == 'update'
                  ? R.string.update_weight_info.tr()
                  : R.string.enter_weight_info.tr(),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: R.color.textDark)),
          leadingIcon: IconButton(
              splashColor: R.color.transparent,
              highlightColor: R.color.transparent,
              icon: Icon(Icons.arrow_back, color: R.color.textDark),
              onPressed: () {
                showDialogSave(context, cubit: cubit);
              }),
          actions: [
            GestureDetector(
              onTap: () => cubit.infoChanged(isClicked: !cubit.isClicked),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: cubit.isClicked
                    ? Image.asset(R.drawable.ic_help_circle_active,
                        width: 24, height: 24)
                    : Image.asset(R.drawable.ic_help_circle,
                        width: 24, height: 24),
              ),
            ),
          ],
        ),
        Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: cubit.isClicked
                ? Description(
                    input: true,
                    data: cubit.des,
                    titleDetail: R.string.diabetes_weight_control.tr())
                : SizedBox()),
      ],
    );
  }
}
