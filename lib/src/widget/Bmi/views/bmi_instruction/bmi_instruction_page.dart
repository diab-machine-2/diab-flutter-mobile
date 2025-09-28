import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/Bmi/views/bmi_instruction/bmi_threshold_model.dart';
import 'package:medical/src/widget/Bmi/views/bmi_on_boarding/widgets/bmi_instruction_session.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';

class BmiInstructionPage extends StatefulWidget {
  const BmiInstructionPage({super.key});

  @override
  State<BmiInstructionPage> createState() => _BmiInstructionPageState();

  static const String bmiBlocKey = "bmi_bloc_key";
}

class _BmiInstructionPageState extends State<BmiInstructionPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: R.color.glucose_bg_color,
      resizeToAvoidBottomInset: true,
      appBar: const BmiInstructionAppBar(),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const BmiInstructionSession(),
              const SizedBox(
                height: 12,
              ),
              Container(
                decoration: R.decorationStyle.mediumRadiusCardStyles,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        R.string.range_bmi_title.tr(),
                        style: R.style.boldLargeStyle,
                      ),
                    ),
                    const _ThresholdTable(),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        "Nguồn tham khảo: Việt P. K. B. V. Đ. H. Y. D. 1.-. C. T. C. Y. (2022, May 19). "
                        "CHỈ SỐ KHỐI CƠ THỂ BMI LÀ GÌ? Ngày tham khảo April 25, 2025, "
                        "từ https://umcclinic.com.vn/chi-so-khoi-co-the-bmi-la-gi",
                        style: R.style.smallBodyStyle.neutral5,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThresholdTable extends StatelessWidget {
  const _ThresholdTable({
    super.key,
  });

  static const double _dividerSize = 2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                  color: AppColors.neutral5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Text(
                    R.string.bmi_type.tr(),
                    style: R.style.boldNormalStyle,
                  )),
            ),
            const SizedBox(
              width: _dividerSize,
            ),
            Expanded(
              child: Container(
                  color: AppColors.neutral5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Text(
                    R.string.bmi_threshold.tr(),
                    style: R.style.boldNormalStyle,
                  )),
            ),
          ],
        ),
        ...BmiThresholds.thresholds.map((e) => Row(
              children: [
                Expanded(
                  child: Container(
                      color: e.thresholdColor,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      child: Text(
                        e.thresholdName.tr(),
                        style: R.style.boldNormalStyle
                            .copyWith(color: e.textColor),
                      )),
                ),
                const SizedBox(
                  width: _dividerSize,
                ),
                Expanded(
                  child: Container(
                      color: e.thresholdColor.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                      child: Text(
                        e.description,
                        style: R.style.boldNormalStyle,
                        textAlign: TextAlign.center,
                      )),
                ),
              ],
            ))
      ],
    );
  }
}

class BmiInstructionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const BmiInstructionAppBar({
    super.key,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      backgroundColor: R.color.greenGradientBottom,
      title: Text(
        R.string.exercise_help_title.tr(),
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
    );
  }
}
