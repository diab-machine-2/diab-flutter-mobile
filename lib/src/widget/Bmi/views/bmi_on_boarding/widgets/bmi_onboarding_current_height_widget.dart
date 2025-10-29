import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/app_setting/app_setting.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_event.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/Bmi/views/bmi_height_input_dialog.dart';
import 'package:medical/src/widget/profile/user_info.dart';

class BmiOnboardingCurrentHeightWidget extends StatelessWidget {
  const BmiOnboardingCurrentHeightWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    BmiBloc _bmiBloc = context.read();

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (previous, current) =>
            current is BmiGetBmiStatisticalState ||
            (current is BmiDataChangedState &&
                current.event == BmiDataChangeEvent.heightChanged),
        builder: (context, state) {
          return InkWell(
            onTap: () {
              BmiHeightInputDialog.show(
                context,
                initialHeight: _bmiBloc.height?.toInt(),
                onConfirmed: (height) async {
                  final userInfo = AppSettings.userInfo!;
                  await ProfileInfoController.updateUserInfo(
                    context,
                    userInfo.copyWith(height: height),
                  );
                  _bmiBloc.height = height;
                },
              );
            },
            child: Container(
              decoration: R.decorationStyle.mediumRadiusCardStyles,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    R.string.chieuCao.tr(),
                    maxLines: 1,
                    style: R.style.largeTextStyle,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${_bmiBloc.height} cm",
                        style: R.style.largeTextStyle.copyWith(
                            color: R.color.mainColor,
                            fontWeight: FontWeight.w700),
                      ),
                      SvgPicture.asset(R.icons.ic_edit)
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }
}
