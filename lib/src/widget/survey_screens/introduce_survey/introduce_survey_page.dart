import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/survey_screens/survey/survey.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/network_image_widget.dart';

import 'introduce_survey.dart';

class IntroduceSurveyPage extends StatefulWidget {
  const IntroduceSurveyPage({Key? key}) : super(key: key);

  @override
  _IntroduceSurveyPageState createState() => _IntroduceSurveyPageState();
}

class _IntroduceSurveyPageState extends State<IntroduceSurveyPage> {
  late IntroduceSurveyCubit _cubit;
  final String surveyId = "8463c809-ff12-4cf6-f4ac-08d99a8a6f6d";

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    _cubit = IntroduceSurveyCubit(repository);
    _cubit.getDetailSurvey(surveyId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<IntroduceSurveyCubit, IntroduceSurveyState>(
          listener: (context, state) {
            if (state is IntroduceSurveyFailure) {
              Message.showToastMessage(context, state.error);
            }
          },
          builder: (context, state) {
            if (state is IntroduceSurveyLoading) {
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

  Widget buildPage(BuildContext context, IntroduceSurveyState state) {
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
                Container(
                  height: 172,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: NetWorkImageWidget(
                      imageUrl: _cubit.surveyData?.image?.url),
                ),
                const SizedBox(height: 32),
                Text(
                  _cubit.surveyData?.name ?? '',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: R.color.textDark,
                      height: 1.4),
                ),
                const SizedBox(height: 16),
                Text(
                  _cubit.surveyData?.description ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    color: R.color.textDark,
                    height: 1.37,
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
                title: R.string.start_survey.tr(),
                onPressed: () {
                  if (_cubit.surveyData == null) return;
                  NavigationUtil.navigatePage(
                    context,
                    SurveyPage(
                      index: 0,
                      surveyData: _cubit.surveyData!,
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
