import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widgets/button_widget.dart';

class NoticeChangePage extends StatelessWidget {
  final VoidCallback onClick;

  NoticeChangePage({required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: R.color.white,
            ),
            child: Column(
              children: [
                SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.only(top: 4, bottom: 24),
                  child: Image.asset(R.drawable.img_upgrade_package, width: 155 , height: 150),
                ),
                Text(
                  R.string.confirm_change.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: R.color.textDark,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  R.string.consumption.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: R.color.textDark,
                  ),
                  maxLines: 3,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: ButtonWidget(
                          title: R.string.cancel.tr(),
                          backgroundColor: R.color.grayBorder,
                          textColor: R.color.textDark,
                          height: 43,
                          onPressed: () => NavigationUtil.pop(context),
                        )),
                    SizedBox(width: 15),
                    Expanded(
                        flex: 1,
                        child: ButtonWidget(
                          title: R.string.agree.tr(),
                          height: 43,
                          onPressed: () {
                            onClick();
                            NavigationUtil.pop(context);
                          },
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
