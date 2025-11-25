import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

class BmiStatisticalDataAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const BmiStatisticalDataAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final BmiBloc bmiBloc = context.read();

    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      title: Text(
        R.string.detail.tr(),
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: R.color.white,
        ),
      ),
      leadingIcon: IconButton(
          splashColor: R.color.white,
          highlightColor: R.color.white,
          icon: Icon(Icons.arrow_back, color: R.color.white),
          onPressed: () {
            bmiBloc.restorePeriodTypeAndRefetch();
            NavigationUtil.pop(context);
          }),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
