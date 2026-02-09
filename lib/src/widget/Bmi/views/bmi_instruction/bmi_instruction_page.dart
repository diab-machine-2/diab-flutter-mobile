import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/res/colors.dart';
import 'package:medical/res/text_styles_extension.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_bloc.dart';
import 'package:medical/src/widget/Bmi/bloc/bmi_state.dart';
import 'package:medical/src/widget/Bmi/views/bmi_instruction/bmi_threshold_model.dart';
import 'package:medical/src/widget/Bmi/views/bmi_on_boarding/widgets/bmi_instruction_session.dart';
import 'package:medical/src/widget/base/custom_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

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
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${R.string.reference_source.tr()}:",
                            style: TextStyle(
                              fontSize: 14,
                              color: R.color.color0xffBFC6C6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse(
                                'https://www.diabetes.ca/resources/tools-resources/body-mass-index-(bmi)-calculator',
                              );
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Text(
                              'https://www.diabetes.ca/resources/tools-resources/body-mass-index-(bmi)-calculator',
                              style: TextStyle(
                                fontSize: 14,
                                color: R.color.color0xffBFC6C6,
                              ),
                            ),
                          ),
                        ],
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
    BmiBloc _bmiBloc = context.read();

    return BlocBuilder<BmiBloc, BmiState>(
        buildWhen: (previous, current) => current is BmiGetWeightThresholdState,
        builder: (context, state) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                        color: AppColors.neutral5,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Text(
                          R.string.bmi_threshold.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: R.style.boldNormalStyle,
                        )),
                  ),
                ],
              ),
              ...BmiThresholds.applyWith(_bmiBloc.weightThreshold)
                  .map((e) => Row(
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
                      )),
              // ..._bmiBloc.weightThreshold.mapIndexed(((index, e) => Row(
              //       children: [
              //         Expanded(
              //           child: Container(
              //               color: Utils.parseStringToColor(e.backgroundColorCode),
              //               padding: const EdgeInsets.symmetric(
              //                   horizontal: 12, vertical: 16),
              //               child: Text(
              //                 e.name?.tr() ?? "--",
              //                 style: R.style.boldNormalStyle.copyWith(
              //                   color: Colors.white,
              //                 ),
              //               )),
              //         ),
              //         const SizedBox(
              //           width: _dividerSize,
              //         ),
              //         Expanded(
              //           child: Container(
              //               color: Utils.parseStringToColor(e.backgroundColorCode)
              //                   .withOpacity(0.2),
              //               padding: const EdgeInsets.symmetric(
              //                   horizontal: 12, vertical: 16),
              //               child: Text(

              //                 e.weight?.toString() ?? "--",
              //                 style: R.style.boldNormalStyle,
              //                 textAlign: TextAlign.center,
              //               )),
              //         ),
              //       ],
              //     )))
            ],
          );
        });
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
