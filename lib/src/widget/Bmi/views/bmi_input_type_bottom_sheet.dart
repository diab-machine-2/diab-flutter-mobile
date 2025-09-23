import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/dimens.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/utils/app_media_query.dart';
import 'package:medical/src/utils/navigator_name.dart';
import 'package:medical/src/widget/bmi/views/add_bmi/add_bmi_page.dart';
import 'package:medical/src/widget/bmi/views/bmi_height_input_dialog.dart';

class BmiInputTypeBottomSheet {
  static Future show(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        builder: (context) => const _BmiInputTypeBottomSheetView(),
        backgroundColor: Colors.transparent);
  }
}

class _BmiInputTypeBottomSheetView extends StatelessWidget {
  const _BmiInputTypeBottomSheetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppDimens.mediumRadius),
          topRight: Radius.circular(AppDimens.mediumRadius),
        ),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.clear_rounded,
                size: 24,
                color: Colors.transparent,
              ),
              Expanded(
                  child: Text(
                R.string.choose_how_to_enter.tr(),
                style: R.style.boldLargeStyle,
                textAlign: TextAlign.center,
              )),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Icons.clear_rounded,
                  size: 24,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 24,
          ),
          _BmiInputOptionItem(
            name: R.string.connect_from_Health_Connect.tr(),
            description: "jkjasdklj ajkal skjkd askjk sskksjs smsms sk",
            image: R.drawable.logo_healthConnect,
          ),
          const SizedBox(
            height: 12,
          ),
          _BmiInputOptionItem(
            name: R.string.enter_manually.tr(),
            description: "jkjasdklj ajkal skjkd askjk sskksjs smsms sk",
            image: R.drawable.im_glucose_input_manual,
            onTap: () {
              BmiHeightInputDialog.show(
                context,
                onConfirmed: (height) {
                  Navigator.pushNamed(
                    context,
                    NavigatorName.bmiInputPage,
                    arguments: {AddBmiPage.bmiInputCurrentHeightKey: height},
                  );
                },
              );
              // .then((value) => Navigator.pop(context));
            },
          ),
        ],
      ),
    );
  }
}

class _BmiInputOptionItem extends StatelessWidget {
  const _BmiInputOptionItem({
    super.key,
    required this.name,
    required this.description,
    required this.image,
    this.onTap,
  });

  final String name;
  final String description;
  final String image;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.mediumRadius),
          color: R.color.color0xffF4F4F5,
        ),
        child: Row(
          children: [
            Image.asset(
              image,
              width: AppMediaQuery.deviceWidth * 0.22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: R.style.boldLargeStyle.textDark,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    description,
                    style: R.style.normalTextStyle.neutral3,
                  )
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 20,
              color: AppColors.neutral3,
            )
          ],
        ),
      ),
    );
  }
}
