import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

import 'survey_result.dart';

class SurveyResultPage extends StatefulWidget {
  @override
  _SurveyResultPageState createState() => _SurveyResultPageState();
}

class _SurveyResultPageState extends State<SurveyResultPage> {
  late SurveyResultCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    _cubit = SurveyResultCubit(repository);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<SurveyResultCubit, SurveyResultState>(
          listener: (context, state) {
            if (state is SurveyResultFailure) {
              Message.showToastMessage(context, state.error);
            }
          },
          builder: (context, state) {
            if (state is SurveyResultLoading) {
              BotToast.showLoading();
            } else {
              BotToast.closeAllLoading();
            }
            return buildPage(context, state);
          },
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, SurveyResultState state) {
    return CommonPage(
      background: R.drawable.bg_welcome,
      title: R.string.survey.tr(),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              children: [
                SizedBox(height: 50.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.w),
                  child: Image.asset(R.drawable.img_survey_completed),
                ),
                const SizedBox(height: 24),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    R.string.thank_you_for_survey.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: R.color.greenGradientBottom,
                        height: 1.4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    R.string.thank_you_for_survey_description.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: R.color.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              alignment: Alignment.center,
              width: 195,
              margin: const EdgeInsets.only(bottom: 20, top: 10),
              child: ButtonWidget(
                title: R.string.completed.tr(),
                onPressed: () {
                  // NavigationUtil.navigatePage(context, SurveyResultPage());
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
