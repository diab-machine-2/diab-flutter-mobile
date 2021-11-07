import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widgets/button_widget.dart';

class NoticeChangePage extends StatelessWidget {
  const NoticeChangePage(
      {this.title,
      required this.description,
      this.negativeButtonTitle,
      this.positiveButtonTitle,
      this.onClick,
      this.gradientColor});

  final String? title;
  final String description;
  final String? negativeButtonTitle;
  final String? positiveButtonTitle;
  final VoidCallback? onClick;
  final bool? gradientColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: gradientColor == true
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        R.color.white,
                        R.color.main_6,
                      ],
                    ),
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: R.color.white,
                  ),
            child: Column(
              children: [
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  child: Image.asset(R.drawable.img_upgrade_package,
                      width: 155, height: 150),
                ),
                Text(
                  title ?? R.string.confirm_change.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: R.color.textDark,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: R.color.textDark,
                  ),
                  maxLines: 3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                        flex: 1,
                        child: ButtonWidget(
                          title: negativeButtonTitle ?? R.string.cancel.tr(),
                          backgroundColor: R.color.grayBorder,
                          textColor: R.color.textDark,
                          height: 43,
                          onPressed: () => NavigationUtil.pop(context),
                        )),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 1,
                      child: ButtonWidget(
                          title: positiveButtonTitle ?? R.string.agree.tr(),
                          height: 43,
                          onPressed: () {
                            if (onClick != null) {
                              onClick?.call();
                            }
                            NavigationUtil.pop(context);
                          }),
                    ),
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
