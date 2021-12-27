import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/const.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/detail_package/detail_package.dart';
import 'package:medical/src/widget/upgrade_account/upgrade_account.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/upgrade_package_widget.dart';

class UpdateRequiredWidget extends StatelessWidget {
  const UpdateRequiredWidget({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonPage(
        title: title,
        background: R.drawable.bg_detail_pro,
        child: Padding(
          padding: EdgeInsets.fromLTRB(30 , 50, 30 , 0),
          child: Column(
            children: [
              UpgradePackageWidget(
                text: description,
                onClickUpgrade: () {
                  NavigationUtil.navigatePage(
                    context,
                    const UpgradeAccountPage(
                      code: 'Const.PRO',
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: ButtonWidget(
                    title: R.string.tim_hieu_them.tr(),
                    backgroundColor: R.color.white,
                    borderColor: R.color.accentColor,
                    textColor: R.color.accentColor,
                    onPressed: () {
                      NavigationUtil.navigatePage(
                          context,
                          const DetailPackagePage(code: 'Const.PRO'));
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
