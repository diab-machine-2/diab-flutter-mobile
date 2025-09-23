import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/app_decoration_styles.dart';
import 'package:medical/src/app_setting/firebase_tracking/activity_list_tracking.dart';
import 'package:medical/src/utils/app_storages.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/BloodPressure/bloodpressure_functions.dart';
import 'package:medical/src/widget/bmi/views/bmi_input_type_bottom_sheet.dart';
import 'package:medical/src/widget/my_plan_screens/lesson_tab/lesson_detail/lesson_detail.dart';
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

    BmiInputTypeBottomSheet.show(context);
  }
}
