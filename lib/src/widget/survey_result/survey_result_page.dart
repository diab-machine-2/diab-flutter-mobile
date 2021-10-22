import 'package:bot_toast/bot_toast.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/survey/survey.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

import 'survey_result.dart';

class SurveyResultPage extends StatefulWidget {
  const SurveyResultPage({Key? key}) : super(key: key);

  @override
  _SurveyResultPageState createState() => _SurveyResultPageState();
}

class _SurveyResultPageState extends State<SurveyResultPage> {
  late SurveyResultCubit _cubit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppRepository repository = AppRepository();
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
              padding: EdgeInsets.all(16.h),
              shrinkWrap: true,
              children: [
                Center(
                  child: Image.asset(
                    R.drawable.ic_learn_result_high,
                    width: double.infinity,
                    height: 240.h,
                  ),
                ),
                SizedBox(
                  height: 16.h,
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.symmetric(horizontal: 40.h),
                  child: Text(
                    R.string.text_congratulation_survey.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: R.color.greenGradientBottom,
                        height: 1.4
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              width: 200.w,
              margin: EdgeInsets.only(bottom: 30.h, top: 10.h),
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
