import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/model/response/survey_data.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/survey/survey.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

import '../survey_question/survey_question_page.dart';

class SurveyPage extends StatefulWidget {
  final int index;
  final SurveyData surveyData;
  const SurveyPage({
    Key? key,
    required this.index,
    required this.surveyData,
  }) : super(key: key);

  @override
  _SurveyPageState createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  late SurveyCubit _cubit;
  SectionSurvey? _sectionSurvey;

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    _cubit = SurveyCubit(repository);
    if (widget.surveyData.sections != null) {
      _sectionSurvey = widget.surveyData.sections![widget.index];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _cubit,
        child: BlocConsumer<SurveyCubit, SurveyState>(
          listener: (context, state) {
            if (state is SurveyFailure) {
              Message.showToastMessage(context, state.error);
            }
          },
          builder: (context, state) {
            if (state is SurveyLoading) {
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

  Widget buildPage(BuildContext context, SurveyState state) {
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
                Image.asset(
                  R.drawable.ic_survey,
                  width: double.infinity,
                  height: 240,
                ),
                const SizedBox(height: 40),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _sectionSurvey?.name ?? '',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: R.color.textDark,
                        height: 1.4),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Viverra amet mauris, vehicula sollicitudin tristique. Nullam mauris aliquet faucibus quis. Pellentesque quam mattis nec dolor, mattis vel ultricies dictum tincidunt. Fermentum urna id malesuada rutrum.',
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
                title: R.string.text_continue.tr(),
                onPressed: () {
                  NavigationUtil.navigatePage(
                    context,
                    SurveyQuestionPage(
                      index: widget.index,
                      surveyData: widget.surveyData,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
