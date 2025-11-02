import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/views/bmi_exit_confirm_dialog.dart';
import 'package:medical/src/widget/Bmi/views/bmi_instruction/bmi_instruction_page.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

class AddBmiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AddBmiAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final BmiBloc bmiBloc = context.read();

    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      title: Text(
        R.string.enter_weight_info.tr(),
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
            BmiExitConfirmDialog.show(context).then((value) {
              if (value == true) NavigationUtil.pop(context);
            });
          }),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(
                  NavigatorName.bmiInstructionPage,
                  arguments: {
                    BmiInstructionPage.bmiBlocKey: bmiBloc,
                  },
                );
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
