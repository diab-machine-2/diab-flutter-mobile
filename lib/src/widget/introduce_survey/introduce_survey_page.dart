import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:medical/src/widget/helper/show_message.dart';
import 'package:medical/src/widget/survey/survey_page.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';

import 'introduce_survey.dart';

class IntroduceSurveyPage extends StatefulWidget {
  const IntroduceSurveyPage({Key? key}) : super(key: key);

  @override
  _IntroduceSurveyPageState createState() => _IntroduceSurveyPageState();
}

class _IntroduceSurveyPageState extends State<IntroduceSurveyPage> {
  late IntroduceSurveyCubit _cubit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AppRepository repository = AppRepository();
    _cubit = IntroduceSurveyCubit(repository);
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
              padding: EdgeInsets.all(16),
              shrinkWrap: true,
              children: [
                Image.asset(
                  R.drawable.img_survey,
                  width: double.infinity,
                  height: 170,
                  fit: BoxFit.fill,
                ),
                SizedBox(
                  height: 32,
                ),
                Text(
                  R.string.introduction_to_the_survey.tr(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: R.color.textDark,
                    height: 1.4
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  R.string.introduction.tr(),
                  style: TextStyle(
                      fontSize: 16,
                      color: R.color.textDark,
                      height: 1.37
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              width: 200 ,
              margin: EdgeInsets.only(bottom: 30, top: 10),
              child: ButtonWidget(
                title: R.string.start_survey.tr(),
                onPressed: () {
                  NavigationUtil.navigatePage(context, SurveyPage());
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
