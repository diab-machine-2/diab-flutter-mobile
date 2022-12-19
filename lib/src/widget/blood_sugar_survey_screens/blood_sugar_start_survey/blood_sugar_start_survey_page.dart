import 'package:bot_toast/bot_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical/res/R.dart';
import 'package:medical/src/model/repository/app_repository.dart';
import 'package:medical/src/utils/navigation_util.dart';
import 'package:medical/src/widget/helper/tracking_manager.dart';
import 'package:medical/src/widgets/button_widget.dart';
import 'package:medical/src/widgets/common_page.dart';
import 'package:medical/src/widgets/update_required_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/navigator_name.dart';
import '../blood_sugar_schedule_template/blood_sugar_schedule_template.dart';
import '../blood_sugar_survey/blood_sugar_survey.dart';
import 'blood_sugar_start_survey.dart';

class BloodSugarStartSurveyPage extends StatefulWidget {
  const BloodSugarStartSurveyPage({
    this.comeFromBloodSugarScreen = false,
  });
  final bool comeFromBloodSugarScreen;

  @override
  State<BloodSugarStartSurveyPage> createState() => _BloodSugarStartSurveyPageState();
}

class _BloodSugarStartSurveyPageState extends State<BloodSugarStartSurveyPage> {
  late final BloodSugarStartSurveyCubit _cubit;

  @override
  void initState() {
    super.initState();
    final AppRepository repository = AppRepository();
    _cubit = BloodSugarStartSurveyCubit(repository);
    _cubit.getCurrentUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _cubit,
      child: BlocConsumer<BloodSugarStartSurveyCubit, BloodSugarStartSurveyState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is BloodSugarStartSurveyLoading) {
            BotToast.showLoading();
          } else {
            BotToast.closeAllLoading();
          }
          return _cubit.isBasicUser
              ? UpdateRequiredWidget(
                  title: R.string.blood_sugar_testing_schedule_suggest.tr(),
                  description: R.string.blood_sugar_survey_update_require.tr())
              : Scaffold(
                  body: CommonPage(
                    title: R.string.blood_sugar_testing_schedule_suggest.tr(),
                    background: R.drawable.bg_detail_pro,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(32, 51, 32, 32),
                        child: Column(
                          children: [
                            const SizedBox(height: 51),
                            Image.asset(R.drawable.img_blood_sugar_start_survey),
                            Padding(
                              padding: const EdgeInsets.only(top: 48, bottom: 28),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _cubit.surveyCode.isEmpty
                                        ? R.string.blood_sugar_survey_description.tr()
                                        : R.string.blood_sugar_survey_done_description.tr(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Nguồn: ',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: R.color.textDark,
                                          ),
                                        ),
                                        TextSpan(
                                          text: R.string.blood_sugar_survey_description_link.tr(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                            color: R.color.blue,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              launch(R.string.blood_sugar_survey_description_link.tr());
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildButton(
                              onTakeSurvey: () {
                                NavigationUtil.navigatePage(
                                    context,
                                    BloodSugarSurveyPage(
                                      comeFromBloodSugarScreen: widget.comeFromBloodSugarScreen,
                                    ));
                              },
                              onShowResult: () {
                                if(widget.comeFromBloodSugarScreen){
                                  Navigator.pushNamed(context, NavigatorName.schedule_glucose);
                                } else {
                                  Navigator.pop(context);
                                }
                                // NavigationUtil.navigatePage(
                                //   context,
                                //   BloodSugarScheduleTemplatePage(
                                //     templateCode: _cubit.surveyCode,
                                //     comeFromBloodSugarScreen: widget.comeFromBloodSugarScreen,
                                //   ),
                                // );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }

  Widget _buildButton({VoidCallback? onTakeSurvey, VoidCallback? onShowResult}) {
    return _cubit.surveyCode.isEmpty
        ? Container(
            width: 195,
            child: ButtonWidget(
              title: R.string.start.tr(),
              onPressed: onTakeSurvey,
            ),
          )
        : Column(
            children: [
              Container(
                width: 195,
                child: ButtonWidget(
                  title: R.string.show_result.tr(),
                  onPressed: onShowResult,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 195,
                child: ButtonWidget(
                  title: R.string.survey_again.tr(),
                  onPressed: onTakeSurvey,
                  backgroundColor: R.color.white,
                  borderColor: R.color.accentColor,
                  textColor: R.color.accentColor,
                ),
              ),
            ],
          );
  }
}
