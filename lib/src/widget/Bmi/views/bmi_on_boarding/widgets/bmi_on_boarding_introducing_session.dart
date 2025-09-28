import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/views/add_bmi/add_bmi_page.dart';
import 'package:medical/src/widget/Bmi/views/bmi_height_input_dialog.dart';
import 'package:medical/src/widget/Bmi/views/bmi_input_type_bottom_sheet.dart';
import 'package:medical/src/widgets/button/primary_rounded_button.dart';

class BmiOnBoardingIntroducingSession extends StatelessWidget {
  const BmiOnBoardingIntroducingSession({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            R.drawable.im_bloodpressure_intro,
            width: 319,
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: R.decorationStyle.mediumRadiusCardStyles,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  R.string.did_you_know.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  R.string.bloodpressure_benefit_observe.tr(),
                  style: TextStyle(
                    fontSize: 15,
                    height: 24 / 15,
                    fontWeight: FontWeight.w400,
                    color: R.color.primaryGreyColor,
                  ),
                ),
                const SizedBox(height: 16),
                PrimaryRoundedButton(
                  title: R.string.enter_weight,
                  onPressed: () => _onInputBmiTapped(context),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToInputSelection() async {
    bool? hasHealthConnection = await AppStorages.getHealthAppPermission();
    // Grant access to HealthKit already
    // if (hasHealthConnection == true) {
    //   Navigator.pushNamed(
    //     context,
    //     NavigatorName.add_blood_pressure,
    //     arguments: {'type': 'input', 'goalId': widget.goalId},
    //   );
    //   return;
    // }
    // // Show the modal to choose methods
    // BloodPressureFunctions.showModalAddData(context,
    //     popPrevious: true, goalId: widget.goalId);
  }

  void _onInputBmiTapped(BuildContext context) async {
    // bool? hasHealthConnection = await AppStorages.getHealthAppPermission();

    BmiInputTypeBottomSheet.show(
      context,
      onManualInputSelected: () => _onSelectMethodInput(context),
    );
  }

  void _onSelectMethodInput(BuildContext context) {
    BmiBloc bmiBloc = context.read();

    if (bmiBloc.height != null) {
      _redirectToInputPage(context, height: bmiBloc.height!);
    } else {
      BmiHeightInputDialog.show(
        context,
        onConfirmed: (height) {
          _redirectToInputPage(context, height: height);
        },
      );
    }
  }

  void _redirectToInputPage(
    BuildContext context, {
    required double height,
  }) async {
    BmiBloc bmiBloc = context.read();

    final result = await Navigator.pushNamed(
      context,
      NavigatorName.bmiInputPage,
      arguments: {
        AddBmiPage.bmiInputCurrentHeightKey: height,
        AddBmiPage.bmiBlocKey: bmiBloc,
      },
    );

    if (result == true) {
      bmiBloc
        ..hasNewData = true
        ..init();
    }
  }
}
