import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:medical/src/widget/Bmi_temp/views/add_bmi/bloc/bmi_input_bloc.dart';

class BmiOverviewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BmiOverviewAppBar({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final BmiInputBloc _bmiInputBloc = context.read();
    final DateFormat _dateFormat = DateFormat(Const.DATE_FORMAT_POST);

    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      title: Text(
        _dateFormat.format(_bmiInputBloc.currentInputTime!),
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
            NavigationUtil.pop(context);
          }),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushNamed(NavigatorName.blood_pressure_intro_2nd_page);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  R.string.huong_dan.tr(),
                  style: TextStyle(color: R.color.white, fontSize: 15),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}